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

listen: fun(sockfd, backlog) {
  <primitive "net_listen">
}

accept: fun(sockfd, addrinfo) {
  <primitive "net_accept">
}

recv: fun(sockfd, len, flags) {
  <primitive "net_recv">
}

close: fun(sockfd) {
  <primitive "net_close">
}

class SockAddr
  fields: self, len;
end

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

loop: fun(client) {
  var clientfd = client[0];
  var clientaddr = client[1];

  if (clientfd > 0) {
    io.print("Received info from client...");
    var received = recv(clientfd, 1000, 0);
    io.print(received);
    if (received.trim() != "exit") {
      loop(client);
    }
  }
}

main: fun() {
  io.print("Echo Server");
  getaddrinfo("0.0.0.0", "8000", { :family: AF_INET }).each(fun(_, addr) {
    var sockfd = socket(addr.ai_family, addr.ai_socktype, addr.ai_protocol);
    if (sockfd != -1) {
      io.print("bind");
      if (bind(sockfd, addr) != 0) {
        close(sockfd);
        Exception.throw("bind");
      }

      io.print("listen");
      if (listen(sockfd, 1) != 0) {
        close(sockfd);
        Exception.throw("listen");
      }

      io.print("accept");
      var client = accept(sockfd, addr);
      if (client[0] < 1) {
        Exception.throw("accept");
      }

      loop(client);

      io.print("close0: " + client[0].toString);
      close(client[0]);
      io.print("close1: " + sockfd.toString);
      close(sockfd);

      ^ 0;
    }
  });
  return 0;
}

.endcode

.end
