function Pad({panel, group, eventsDispatcher, oscSender, oscLabel, x, y, size, color, onColor, offColor, val, caption}) {
  this.context = panel.getContext();
  this.group = group || null;
  this.oscSender = oscSender;
  this.oscLabel = oscLabel;
  this.x = x;
  this.y = y;
    if(group != null){
    this.x += this.group.getX();
    this.y += this.group.getY();
  }
  this.size = size || 80;
  this.color = color || new Color(255, 255, 255);
  this.onColor = onColor || new Color(190, 190, 190);
  this.offColor = offColor || new Color(63, 63, 63);
  this.val = val || 0;
  this.caption = caption || "";
  this.lineWidth = 5;
  this.cornerSize = 10;
  if(this.caption != ""){
    this.context.fillStyle = this.color.rgb();
    this.context.font = "14px monospace";
    this.context.textAlign = "center";
    this.context.textBaseline = "top";
    this.context.fillText(this.caption, this.x + this.size / 2, this.y + this.size + this.lineWidth);
  }
  downIndex = eventsDispatcher.addEvent(Event.MOUSE_DOWN, new Boundaries(Boundaries.RECT, this.x, this.y, this.size, this.size), this.switchState.bind(this));
  eventsDispatcher.addEvent(Event.MOUSE_UP, new Boundaries(Boundaries.RECT, this.x, this.y, this.size, this.size), this.switchState.bind(this), downIndex);
  this.draw();
}

Pad.prototype.draw = function(){
  if(this.group == null)
    this.context.clearRect(this.x - this.lineWidth, this.y - this.lineWidth, this.size + 2 * this.lineWidth, this.size + 2 * this.lineWidth);
  else {
    this.context.fillStyle = this.group.getBgColor().rgb();
    this.context.fillRect(this.x - this.lineWidth, this.y - this.lineWidth, this.size + 2 * this.lineWidth, this.size + 2 * this.lineWidth);
  }
  this.context.lineWidth = this.lineWidth;
  this.context.strokeStyle = this.color.rgb();
  this.context.fillStyle = this.val == 1?this.onColor.rgb():this.offColor.rgb();
  this.context.beginPath();
  this.context.moveTo(this.x + this.cornerSize, this.y);
  this.context.lineTo(this.x + this.size - this.cornerSize, this.y);
  this.context.arc(this.x + this.size - this.cornerSize, this.y + this.cornerSize, this.cornerSize, -Math.PI / 2, 0);
  this.context.lineTo(this.x + this.size, this.y + this.size - this.cornerSize);
  this.context.arc(this.x + this.size - this.cornerSize, this.y + this.size - this.cornerSize, this.cornerSize, 0, Math.PI / 2);
  this.context.lineTo(this.x + this.cornerSize, this.y + this.size);
  this.context.arc(this.x + this.cornerSize, this.y + this.size - this.cornerSize, this.cornerSize, Math.PI / 2, Math.PI);
  this.context.lineTo(this.x, this.y + this.cornerSize);
  this.context.arc(this.x + this.cornerSize, this.y + this.cornerSize, this.cornerSize, Math.PI, 3 * Math.PI / 2);
  this.context.stroke();
  this.context.fill();
}

Pad.prototype.switchState = function(s, x, y){
  this.val = s;
  this.oscSender.send([this.oscLabel, this.val])
  this.draw();
}