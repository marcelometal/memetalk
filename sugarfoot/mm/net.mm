.preamble(io)
  io : meme:io;
.code

// AF_UNSPEC: 0;
// AF_INET: 2;
// AF_INET6: 10;

getaddrinfo: fun(node, service, hints) {
  <primitive "net_getaddrinfo">
}

socket: fun(domain, type, protocol) {
  <primitive "net_socket">
}

main: fun() {
  io.print("getaddrinfo");
  getaddrinfo("localhost", "80", { :family: 2 }).each(fun(_, i) {
    io.print(socket(i["family"], i["socktype"], i["protocol"]));
  });
  return 0;
}

.endcode

.end
