.preamble(io)
  io : meme:io;
.code

// AF_UNSPEC = 0;
// AF_INET = 2;
// AF_INET6 = 10;

getaddrinfo: fun(node, service, hints) {
  <primitive "net_getaddrinfo">
}

main: fun() {
  io.print("getaddrinfo");
  io.print(getaddrinfo("gnu.org", null, {}));
  return 0;
}

.endcode

.end
