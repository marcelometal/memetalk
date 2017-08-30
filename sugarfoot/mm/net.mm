.preamble(io)
  io : meme:io;
.code

// Socket types
SOCK_STREAM: 1;         // stream (connection) socket
SOCK_DGRAM: 2;          // datagram (conn.less) socket
SOCK_RAW: 3;            // raw socket
SOCK_RDM: 4;            // reliably-delivered message
SOCK_SEQPACKET: 5;      // sequential packet socket

// Supported address families
AF_UNSPEC: 0;
AF_UNIX: 1;             // Unix domain sockets
AF_INET: 2;             // Internet IP Protocol
AF_AX25: 3;             // Amateur Radio AX.25
AF_IPX: 4;              // Novell IPX
AF_APPLETALK: 5;        // Appletalk DDP
AF_NETROM: 6;           // Amateur radio NetROM
AF_BRIDGE: 7;           // Multiprotocol bridge
AF_AAL5: 8;             // Reserved for Werner's ATM
AF_X25: 9;              // Reserved for X.25 project
AF_INET6: 10;           // IP version 6
AF_MAX: 12;             // For now..

// For setsockopt (from asm-generic/socket.h)
SOL_SOCKET: 1;

SO_DEBUG: 1;
SO_REUSEADDR: 2;
SO_TYPE: 3;
SO_ERROR: 4;
SO_DONTROUTE: 5;
SO_BROADCAST: 6;
SO_SNDBUF: 7;
SO_RCVBUF: 8;
SO_SNDBUFFORCE: 32;
SO_RCVBUFFORCE: 33;
SO_KEEPALIVE: 9;
SO_OOBINLINE: 10;
SO_NO_CHECK: 11;
SO_PRIORITY: 12;
SO_LINGER: 13;
SO_BSDCOMPAT: 14;
SO_REUSEPORT: 15;
SO_PASSCRED: 16;
SO_PEERCRED: 17;
SO_RCVLOWAT: 18;
SO_SNDLOWAT: 19;
SO_RCVTIMEO: 20;
SO_SNDTIMEO: 21;

inet_ntop: fun(addr) {
  <primitive "net_inet_ntop">
}

getaddrinfo: fun(node, service, hints) {
  <primitive "net_getaddrinfo">
}

socket: fun(domain, type, protocol) {
  <primitive "net_socket">
}

setsockopt: fun(sockfd, level, optname, optval) {
  <primitive "net_setsockopt">
}

bind: fun(sockfd, addrinfo) {
  <primitive "net_bind">
}

listen: fun(sockfd, backlog) {
  <primitive "net_listen">
}

accept: fun(sockfd) {
  <primitive "net_accept">
}

recv: fun(sockfd, len, flags) {
  <primitive "net_recv">
}

send: fun(sockfd, buf, flags) {
  <primitive "net_send">
}

close: fun(sockfd) {
  <primitive "net_close">
}

class AddrInfo
  fields: self, addrdict;

  instance_method index: fun(key) {
    return @addrdict[key];
  }
end

class SockAddr
  fields: self, len;
end

class Client
  fields: fd, addr;

  init new: fun(acceptOutput) {
    @fd = acceptOutput[0];
    @addr = acceptOutput[1];
  }

  instance_method addr: fun() {
    return inet_ntop(@addr);
  }

  instance_method send: fun(data) {
    if (send(@fd, data, 0) != data.size()) {
      return false;
    }
    return true;
  }

  instance_method recv: fun(size) {
    return recv(@fd, size, 0);
  }

  instance_method close: fun() {
    close(@fd);
  }
end

class TCPServer
  fields: sockfd, addrinfo;

  instance_method bindAndListen: fun(host, port) {
    @addrinfo = getaddrinfo(host, port, { :ai_family: AF_INET }).each(fun(_, addr) {
      @sockfd = socket(addr[:ai_family], addr[:ai_socktype], addr[:ai_protocol]);
      if (@sockfd != -1) {
        if (setsockopt(@sockfd, SOL_SOCKET, SO_REUSEADDR, 1) == -1) {
          Exception.throw("setsockopt() failed to set SO_REUSEADDR");
        }
        if (bind(@sockfd, addr) != 0) {
          close(@sockfd);
          Exception.throw("bind() failed");
        }
        if (listen(@sockfd, 1) != 0) {
          close(@sockfd);
          Exception.throw("listen() failed");
        }
      }
      ^ addr;
    });
  }

  instance_method acceptClient: fun() {
    return Client.new(accept(@sockfd));
  }

  instance_method close: fun() {
    close(@sockfd);
  }
end

.endcode
