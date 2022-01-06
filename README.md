# web-mobi

## A web based highly customisable controller written in node.js and plain old javascript

Build with ease complex OSC controllers that are available as a web application in any modern browser. A typical example looks like this:

![boing!](https://github.com/zetof/web-mobi/blob/main/images/web_mobi.png)

This requires no more code than the following:

```html
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html>
<html>
  <head>
    <link rel="stylesheet" href="core/main.css">
    <script type="text/javascript" src="core/helpers.js"></script>
    <script type="text/javascript" src="core/panel.js"></script>
    <script type="text/javascript" src="core/boundaries.js"></script>
    <script type="text/javascript" src="core/event.js"></script>
    <script type="text/javascript" src="core/events_dispatcher.js"></script>
    <script type="text/javascript" src="core/osc_sender.js"></script>
    <script type="text/javascript" src="core/color.js"></script>
    <script type="text/javascript" src="core/group.js"></script>
    <script type="text/javascript" src="core/switch.js"></script>
    <script type="text/javascript" src="core/pad.js"></script>
    <script type="text/javascript" src="core/knob.js"></script>
    <script type="text/javascript" src="core/selector.js"></script>
    <script type="text/javascript" src="core/xy_track.js"></script>
    <script type="text/javascript" src="core/light.js"></script>
  </head>
  <body>
    <script>
      myPanel = new Panel();
      ed_1 = new EventsDispatcher(myPanel);
      osc_1 = new OscSender({baseUrl:"192.168.1.7", route:"/control"});

      // Definition of colors
      c_on_1 = new Color(255,215,0);
      c_on_2 = new Color(220, 20, 60);
      c_on_3 = new Color(255, 140, 0);
      c_on_4 = new Color(50, 205, 50);
      c_led_on = new Color(255, 69, 0);

      // Definition of groups
      g_1 = new Group({panel:myPanel, x:20, y:30, width:400, height:430, caption:"OSC 1"})
      g_2 = new Group({panel:myPanel, x:860, y:30, width:400, height:430, caption:"OSC 2"})
      g_3 = new Group({panel:myPanel, x:440, y:30, width:400, height:430, caption:"MASTER"})
      g_4 = new Group({panel:myPanel, x:20, y:490, width:1240, height:120, caption:"EFFECTS"})      

      // OSC 1 controls
      t_11 = new XYTrack({panel:myPanel, group:g_1, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"atck_dcay_1", x:110, y:20, size:180, min:[0.05, 0.1], max:[1, 5], val:[0.05, 1], decimal:true, caption:"ATTACK/DECAY"});
      k_11 = new Knob({panel:myPanel, group:g_1, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"pitch_1", x:40, y:230, min:36, max:84, val:48, onColor:c_on_1, caption:"PITCH"});
      k_12 = new Knob({panel:myPanel, group:g_1, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"dtn_1", x:50, y:340, size:60, min:-0.05, max:0.05, val:0, decimal:true, onColor:c_on_1, caption:"DETUNE"});
      k_13 = new Knob({panel:myPanel, group:g_1, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"wav_frm_1", x:160, y:230, min:1, max:50, val:1, onColor:c_on_1, caption:"WAVEFORM"});
      k_14 = new Knob({panel:myPanel, group:g_1, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"duty_1", x:170, y:340, size:60, min:0.01, max:0.5, val:0.5, decimal:true, onColor:c_on_1, caption:"DUTY"});
      k_15 = new Knob({panel:myPanel, group:g_1, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"sld_1", x:280, y:230, min:0, max:0.5, val:0, decimal:true, onColor:c_on_1, caption:"SLIDE"});
      k_16 = new Knob({panel:myPanel, group:g_1, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"sld_dec_1", x:290, y:340, size: 60, min:0, max:1, val:0, decimal:true, onColor:c_on_1, caption:"DECAY"});
      s_11 = new Switch({panel:myPanel, group:g_1, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"osc_1_on_off", x:25, y:20, width:60, height:30, onColor:c_on_1, caption:"ON/OFF", val:0});
      l_11 = new Light({panel:myPanel, group:g_1, x:325, y:20, onColor:c_led_on});
      osc_1.subscribe("/beat_1", l_11, l_11.blink);

      // OSC 2 controls
      t_21 = new XYTrack({panel:myPanel, group:g_2, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"atck_dcay_2", x:110, y:20, size:180, min:[0.05, 0.1], max:[1, 5], val:[0.05, 1], decimal:true, caption:"ATTACK/DECAY"});
      k_21 = new Knob({panel:myPanel, group:g_2, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"pitch_2", x:40, y:230, min:36, max:84, val:60, onColor:c_on_2, caption:"PITCH"});
      k_22 = new Knob({panel:myPanel, group:g_2, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"dtn_2", x:50, y:340, size: 60, min:-0.05, max:0.05, val:0, decimal:true, onColor:c_on_2, caption:"DETUNE"});
      k_23 = new Knob({panel:myPanel, group:g_2, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"wav_frm_2", x:160, y:230, min:1, max:50, val:1, onColor:c_on_2, caption:"WAVEFORM"});
      k_24 = new Knob({panel:myPanel, group:g_2, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"duty_2", x:170, y:340, size:60, min:0.01, max:0.5, val:0.5, decimal:true, onColor:c_on_2, caption:"DUTY"});
      k_25 = new Knob({panel:myPanel, group:g_2, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"sld_2", x:280, y:230, min:0, max:0.5, val:0, decimal:true, onColor:c_on_2, caption:"SLIDE"});
      k_26 = new Knob({panel:myPanel, group:g_2, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"sld_dec_2", x:290, y:340, size: 60, min:0, max:1, val:0, decimal:true, onColor:c_on_2, caption:"DECAY"});
      s_21 = new Switch({panel:myPanel, group:g_2, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"osc_2_on_off", x:25, y:20, width:60, height:30, onColor:c_on_2, caption:"ON/OFF", val:0});
      l_21 = new Light({panel:myPanel, group:g_2, x:325, y:20, onColor:c_led_on});
      osc_1.subscribe("/beat_2", l_21, l_21.blink);

      // MASTER controls
      t_31 = new XYTrack({panel:myPanel, group:g_3, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"fm_fdbk", x:110, y:20, size:180, min:[0, 0], max:[100, 100], val:[0, 0], caption:"FM FEEDBACK"});
      k_31 = new Knob({panel:myPanel, group:g_3, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"mstr_vol", x:90, y:230, min:0, max:1, val:0.5, decimal:true, onColor:c_on_3, caption:"MASTER VOL"});
      k_32 = new Knob({panel:myPanel, group:g_3, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"mstr_tempo", x:260, y:285, min:0.5, max:5, val:1, decimal:true, onColor:c_on_3, caption:"MASTER TEMPO"});
      k_33 = new Knob({panel:myPanel, group:g_3, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"vol_1", x:50, y:340, size:60, min:0, max:1, val:0.5,  decimal:true, onColor:c_on_3, caption:"VOL 1"});
      k_34 = new Knob({panel:myPanel, group:g_3, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"vol_2", x:150, y:340, size:60, min:0, max:1, val:0.5, decimal:true, onColor:c_on_3, caption:"VOL 2"});
      s_31 = new Switch({panel:myPanel, group:g_3, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"mster_on_off", x:25, y:20, width:60, height:30, onColor:c_on_3, caption:"ON/OFF", val:0});

      // EFFECTS controls
      k_41 = new Knob({panel:myPanel, group:g_4, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"delay", x:20, y:15, min:0, max:0.5, val:0, decimal:true, onColor:c_on_4, caption:"DELAY"});
      k_42 = new Knob({panel:myPanel, group:g_4, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"decay", x:120, y:15, min:0, max:5, val:0, decimal:true, onColor:c_on_4, caption:"DECAY"});
      k_43 = new Knob({panel:myPanel, group:g_4, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"low_pass", x:220, y:15, min:10, max:10000, val:10, onColor:c_on_4, caption:"LOW"});
      k_44 = new Knob({panel:myPanel, group:g_4, eventsDispatcher:ed_1, oscSender:osc_1, oscLabel:"high_pass", x:320, y:15, min:10, max:10000, val:10000, onColor:c_on_4, caption:"HIGH"});
    </script>
  </body>
</html>
```

## Installing and operating

- Clone this repository: `git clone https://github.com/zetof/web-mobi.git`
- Move to the cloned directory: `cd web-mobi`
- Install de dependencies: `npm install`
- Run the application: `node start`

Open a web browser and navigate to the default address: http://localhost:3000 and you should be able to see the controller interface

## Configuration

Everything should pretty be working out of the box. However, here are some parameters you might have to change:

### `start.js` file

```javascript
const web_app_port = 3000;
const ws_server_ip = "127.0.0.1";
const ws_server_port = 3061;
const osc_client_ip = "127.0.0.1";
const osc_client_port = 57120;
const osc_server_port = 57121;
```

- `web_app_port`: if you want the web application to be served on another port than 3000, change this value
- `osc_client_ip`: if the OSC device you're wanting to pilot is not on your local machine, change this value
- `osc_client_port`: if the OSC device you're wanting to pilot is not listening on this port, change this value
- `osc_server_port`: if you want to listen to incoming OSC messages on another port, change this value

### `index.html` file

```javascript
osc_1 = new OscSender({baseUrl:"127.0.0.1", route:"/control"});
```

- If you're accessing the web application from another device than your server, it is wise to change the `baseUrl` value to your server ip address otherwise you won't be able to talk to the OSC websocket gateway

The OSC gateway uses websockets to communicate with the web browser and forwards / reads OSC UDP websocket messages. It has been tested using SuperCollider (see SC test program in this project).