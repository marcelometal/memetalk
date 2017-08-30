.preamble(io, net)
  io: meme:io;
  net: meme:net;
.code

main: fun() {
  var server = net.TCPServer.new();
  server.bindAndListen("::", "8000");

  while (true) {
    var client = server.acceptClient();
    io.print("Client " + client.addr() + " connected");
    client.send("What's your name? ");
    var name = client.recv(1024).trim();
    client.send("Hi " + name + "!\n");
    client.send("bye " + name + "!\n");
    client.close();
  }
  server.close();
}

.endcode
