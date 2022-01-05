function rad2Deg(rad) {
  return 180 * rad / Math.PI;
}

function deg2Rad(deg) {
  return Math.PI * deg / 180;
}

function getPixels(val, size) {
  if(val.indexOf("%") != -1)
    return Math.round(parseInt(val.slice(0, -1)) * size / 100);
  else if(val.indexOf("px") != -1)
    return parseInt(val.slice(0, -2));
  else return 0;
}