(
// Wait for the server to boot before creating synth definitions and groups
s.waitForBoot({

// Include code in a routine so all synth definitions load smoothly before being instanciated
Routine({

// A SynthDef that allows to grow an original sine wave to a full blown square wave with up to 50 harmonics
// This synth also allows to control the duty cycle of the formed square wave
// Parameters:
//   * note           : the midi note to play
//   * detune         : a percentage of detuning from original frequency
//   * vol            : a multiplier to adjust master volume
//   * harmonics      : the number of harmonics to add to travel from a sine wave (=1) to a full blown square wave (=50)
//   * duty           : the duty cycle of thee formed square ware (effective from harmonics > 1)
//   * attack         : the attack time of the evelope
//   * release        : the release time of the evelope
//   * sweep          : the percentage of played frequency that is added to the original freaquency to start a sweep
//   * swwep_time     : the percentage of total sound time used for the sweep
//   * feed_in        : channel number for incoming feedback signal
//   * feed_out       : channel number for outgoing feedback signal
//   * mod_index      : modulation index from incoming signal
//   * output_channel : output channel, sent to additional effects or audio output
//
SynthDef(\squared_sin, {
	arg note=60, detune=0, vol=1,
	harmonics=1, duty=0.5,
	attack=0.1, release=1,
	sweep=0, sweep_time=0,
	feed_in=nil, feed_out=nil, mod_index=0,
	output_channel=0;
	var modulator = 0;
	var sweep_line = Line.kr(1 + sweep, 1, sweep_time * (attack + release));
	var freq = (1 + detune) * note.midicps;
	var env = EnvGen.ar(Env.perc(attack, release), doneAction:Done.freeSelf);
	var signal;
	if(feed_in.notNil, modulator = mod_index * InFeedback.ar(feed_in, 1));
	signal = {
		(1..50).sum {
			arg i;
			SinOsc.ar(freq * (sweep_line * i + modulator)
				, -0.5pi, -2 * InRange.kr(i, 1, harmonics) * vol / (i * pi) * (pi * duty * i).sin);
		}
	};
	signal = env * (duty * vol + signal);
	Out.ar(feed_out, signal);
	Out.ar(output_channel, signal);
}).add;

// A SynthDef that allows filtering of the generated signal
// Parameters:
//   * input_channel  : the channel number of the input signal before filtering
//   * output_channel : the channel number of the output signal after filtering
//
SynthDef(\filter, {
	arg input_channel=10, output_channel=12;
	Out.ar(output_channel, In.ar(input_channel, 1));
}).add;

// A SynthDef that introduces a delay on the input signal
// Delay is split through a low pass filter and a high pass filter so effect can be controlled more accurately
// Parameters:
//   * input_channel  : the channel number of the input signal before delaying
//   * output_channel : the channel number of the output signal after delaying
//   * delay          : delay time in seconds - basically the time of one echo
//   * decay          : decay time in seconds - basically the time it takes for the sound to completely fade away
//   * low-freq       : low frequency cutoff limit for the low pass filter
//   * high-freq      : high frequency cutoff limit for the high pass filter
//
SynthDef(\delay, {
	arg input_channel=12, output_channel=20, delay=0.25, decay=2, low_freq=440, high_freq=1000;
	var sig = In.ar(input_channel, 1);
	var low_delay = CombN.ar(LPF.ar(sig, low_freq), delay, delay, decay);
	var high_delay = CombN.ar(HPF.ar(sig, high_freq), delay, delay, decay);
	Out.ar(output_channel, sig + low_delay + high_delay);
}).add;

// A SynthDef that ouputs final sound and allows master level and balance controls
// Parameters:
//   * input_channel : the channel number at the end of synth and effects chain
//   * vol           : master volume control
//   * bal           : master balance (-1: left, 1: right)
//
SynthDef(\mixer, {
	arg input_channel=20, vol=0.5, bal=0;
	Out.ar(0, Pan2.ar(vol * In.ar(input_channel, 1), bal));
}).add;

// Sync point to wait for synth definitions to load
s.sync;

// Set groups and their precedence
~synth_group = Group.new;
~filter_group = Group.after(~synth_group);
~delay_group = Group.after(~filter_group);
~output_group = Group.after(~delay_group);

// Instanciate effects and mixer synths
~filter_synth = Synth(\filter, target:~filter_group);
~delay_synth = Synth(\delay, target:~delay_group);
~mixer_synth = Synth(\mixer, target:~output_group);

// Master metronome
~metronome = TempoClock.new;

// Default params for mixer module
~master_volume = 0.5;
~master_balance = 0;

// Defaults params for delay module
~delay = 0;
~decay = 0;
~low_freq = 10;
~high_freq = 10;

// Default params for the oscillator synths
~play = [false, false, false];
~note = [60, 60];
~detune = [0, 0];
~vol = [0.5, 0.5];
~harmonics = [25, 25];
~duty = [0.125, 0.5];
~attack = [0.01, 0.1];
~release = [1, 1];
~sweep = [0, 0];
~sweep_time = [0, 0];
~mod_index = [0, 0];

// Make two pulsating synths from synth definition, all elements are adjustable from the outside world
// Each pulsating synth send an OSC message at start time, to allow a synchronization with the outside world
~osc = [Pbind(
	\instrument, \squared_sin,
	\note, Pfunc({ ~note[0] }, inf),
	\detune,  Pfunc({ ~detune[0] }),
	\vol,  Pfunc({ ~vol[0] }),
	\harmonics, Pfunc({ ~harmonics[0] }),
	\duty, Pfunc({ ~duty[0] }),
	\attack, Pfunc({ ~attack[0] / ~metronome.tempo }),
	\release, Pfunc({ ~release[0] / ~metronome.tempo }),
	\sweep,  Pfunc({ ~sweep[0] }),
	\sweep_time, Pfunc({ ~sweep_time[0] / ~metronome.tempo }),
	\feed_in, 2,
	\feed_out, 3,
	\output_channel, 10,
	\group, ~synth_group,
	\mod_index, Pfunc({ ~mod_index[0] }),
	\dur, Pfunc({ ~attack[0] + ~release[0] }),
	\osc, Pfunc({~oscServer.sendMsg("/beat_1", 1) })
).play(~metronome, quant:1),
Pbind(
	\instrument, \squared_sin,
	\note, Pfunc({ ~note[1] }, inf),
	\detune,  Pfunc({ ~detune[1] }),
	\vol,  Pfunc({ ~vol[1] }),
	\harmonics, Pfunc({ ~harmonics[1] }),
	\duty, Pfunc({ ~duty[1] }),
	\attack, Pfunc({ ~attack[1] / ~metronome.tempo }),
	\release, Pfunc({ ~release[1] / ~metronome.tempo }),
	\sweep,  Pfunc({ ~sweep[1] }),
	\sweep_time,  Pfunc({ ~sweep_time[1] / ~metronome.tempo }),
	\feed_in, 3,
	\feed_out, 2,
	\output_channel, 10,
	\group, ~synth_group,
	\mod_index, Pfunc({ ~mod_index[1] }),
	\dur, Pfunc({ ~attack[1] + ~release[1] }),
	\osc, Pfunc({ ~oscServer.sendMsg("/beat_2", 2) })
).play(~metronome, quant:1)];
~osc[0].stop;
~osc[1].stop;

// OSC address of pilot program and OSC event driver
~oscServer = NetAddr("127.0.0.1", 57121);

// All knobs controls, split into bank effects (see LPD8 python program for more explanations)
OSCdef.new(\control, {
	arg msg;
	if(msg[1] == 'pitch_1', { ~note[0] = msg[2] });
	if(msg[1] == 'wav_frm_1', { ~harmonics[0] = msg[2] });
	if(msg[1] == 'atck_dcay_1', { ~attack[0] = msg[2] });
	if(msg[1] == 'sld_1', { ~sweep[0] = msg[2] });
	if(msg[1] == 'dtn_1', { ~detune[0] = msg[2] });
	if(msg[1] == 'duty_1', { ~duty[0] = msg[2] });
	if(msg[1] == 'atck_dcay_1', { ~release[0] = msg[3] });
	if(msg[1] == 'sld_dec_1', { ~sweep_time[0] = msg[2] });
	if(msg[1] == 'pitch_2', { ~note[1] = msg[2] });
	if(msg[1] == 'wav_frm_2', { ~harmonics[1] = msg[2] });
	if(msg[1] == 'atck_dcay_2', { ~attack[1] = msg[2] });
	if(msg[1] == 'sld_2', { ~sweep[1] = msg[2] });
	if(msg[1] == 'dtn_2', { ~detune[1] = msg[2] });
	if(msg[1] == 'duty_2', { ~duty[1] = msg[2] });
	if(msg[1] == 'atck_dcay_2', { ~release[1] = msg[3] });
	if(msg[1] == 'sld_dec_2', { ~sweep_time[1] = msg[2] });
	if(msg[1] == 'fm_fdbk', { ~mod_index[0] = msg[2] });
	if(msg[1] == 'vol_1', { ~vol[0] = msg[2] });
	if(msg[1] == 'mstr_vol', { ~master_volume = msg[2]; ~mixer_synth.set(\vol, ~master_volume) });
	if(msg[1] == 'mstr_tempo', { ~metronome.tempo = msg[2] });
	if(msg[1] == 'fm_fdbk', { ~mod_index[1] = msg[3] });
	if(msg[1] == 'vol_2', { ~vol[1] = msg[2] });
	if(msg[1] == 'osc_1_on_off' && msg[2] == 0, { ~play[0] = false; ~osc[0].stop; });
	if(msg[1] == 'osc_1_on_off' && msg[2] == 1, { ~play[0] = true; if(~play[2], {~osc[0].play}); });
	if(msg[1] == 'osc_2_on_off' && msg[2] == 0, { ~play[1] = false; ~osc[1].stop; });
	if(msg[1] == 'osc_2_on_off' && msg[2] == 1, { ~play[1] = true; if(~play[2], {~osc[1].play}); });
	if(msg[1] == 'mster_on_off' && msg[2] == 0, { ~play[2] = false; ~osc[0].stop; ~osc[1].stop; });
	if(msg[1] == 'mster_on_off' && msg[2] == 1, { ~play[2] = true; if(~play[0], {~osc[0].play}); if(~play[1], {~osc[1].play}); });
	if(msg[1] == 'delay', { ~delay = msg[2]; ~delay_synth.set(\delay, ~delay.lag(1)) });
	if(msg[1] == 'decay', { ~decay = msg[2]; ~delay_synth.set(\decay, ~decay) });
	if(msg[1] == 'low_pass', { ~low_freq = msg[2]; ~delay_synth.set(\low_freq, ~low_freq) });
	if(msg[1] == 'high_pass', { ~high_freq = msg[2]; ~delay_synth.set(\high_freq, ~high_freq) });
}, "/control"); }).play(AppClock); })
)