function Panel(color) {
  if(typeof color === "undefined") {
    color = new Color(0, 0, 0);
  }
  canvas = document.createElement('canvas');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  canvas.style.backgroundColor = color.rgb();
  body = document.getElementsByTagName("body")[0];
  body.appendChild(canvas);
  this.canvas = canvas;
  this.context = canvas.getContext("2d");
}

Panel.prototype.getCanvas = function() {
  return this.canvas;
};

Panel.prototype.getContext = function() {
  return this.context;
};