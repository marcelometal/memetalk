.preamble(io)
  io : meme:io;
.code

AF_UNSPEC: 0;
AF_INET: 2;
AF_INET6: 10;

getaddrinfo: fun(node, service, hints) {
  <primitive "net_getaddrinfo">
}

socket: fun(domain, type, protocol) {
  <primitive "net_socket">
}

bind: fun(sockfd, addrinfo) {
  <primitive "net_bind">
}

class AddrInfo
  fields: self;

  instance_method ai_family: fun() {
    <primitive "net_addrinfo_ai_family">
  }

  instance_method ai_socktype: fun() {
    <primitive "net_addrinfo_ai_socktype">
  }

  instance_method ai_protocol: fun() {
    <primitive "net_addrinfo_ai_protocol">
  }
end

main: fun() {
  io.print("getaddrinfo");
  getaddrinfo("localhost", "8000", {}).each(fun(_, i) {
    var sockfd = socket(i.ai_family, i.ai_socktype, i.ai_protocol);
    if (sockfd != -1) {
      if (bind(sockfd, i) != 0) {
        ^ "error";
      }
      // if (listen(sockfd, 10) != 0) {
      //   ^ "error";
      // }

      //close(sockfd);
    }
  });
  return 0;
}

.endcode

.end
