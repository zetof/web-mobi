// Import section
import WebSocket, { WebSocketServer } from "ws";
import express from "express"
import osc from "osc"
import { fileURLToPath } from "url";
import { dirname } from "path";

// Manually define __dirname function as it was not available from the start
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Constants section
const web_app_port = 3000;
const ws_server_ip = "127.0.0.1";
const ws_server_port = 3061;
const osc_client_ip = "127.0.0.1";
const osc_client_port = 57120;
const osc_server_port = 57121;
const forward_osc = ["/beat_1", "/beat_2"];
const app = express();

// Define a base address for the starting page of the appplication
app.get("/", (req, res) => {
  res.sendFile("./web_app/index.html", { root: __dirname });
});

// Serve javascript pages of the application
app.use(express.static("web_app"));

// Start web server for frontend application
app.listen(web_app_port, () => console.log(`Your mobi controller is available  on port ${web_app_port}`));

// Start a websocket server and listen to incoming messages
const wss = new WebSocketServer({ port: ws_server_port });
wss.on("connection", function connection(ws) {
  ws.on("message", function message(data) {
    var parse = JSON.parse(data);
    if(forward_osc.includes(parse.address)) {
      wss.clients.forEach(function each(client) {
        if(client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify(parse));
        }
      });
    }
    else {
      udpPort.send({
        address: parse.address,
        args: parse.args }, osc_client_ip, osc_client_port);
    }
  });
  ws.send("Connected to mobi backend");
});

// Start a websocket client to forward OSC messages
const ws = new WebSocket("ws://" + ws_server_ip + ":" + String(ws_server_port));

// Define an osc.js UDP server listening on port 57121.
var udpPort = new osc.UDPPort({
  localAddress: "0.0.0.0",
  localPort: osc_server_port,
  metadata: true
});

// Listen for incoming OSC messages
udpPort.on("message", function (oscMsg, timeTag, info) {
  ws.send(JSON.stringify(oscMsg));
});

// Open the socket.
udpPort.open();
