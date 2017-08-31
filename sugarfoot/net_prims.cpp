#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#include <iostream>
#include "process.hpp"
#include "vm.hpp"

#define TYPE_CHECK(o, t, e)                                             \
  if (!(proc->mmobj()->mm_object_vt(o) == proc->vm()->get_prime(t))) {  \
    proc->raise("TypeError", e);                                        \
  }

#define TYPE_CHECK_ARG(n, t)                                            \
  TYPE_CHECK(proc->get_arg(n), t, "Argument " #n " Expected " t)

/* -- getaddrinfo -- */

static int lookup_symbol_in_dict(Process* proc, const char* symbol, oop dict) {
  oop key = proc->mmobj()->mm_symbol_new(symbol);
  if (proc->mmobj()->mm_dictionary_has_key(proc, dict, key)) {
    return untag_small_int(proc->mmobj()->mm_dictionary_get(proc, dict, key));
  }
  return 0;
}

static oop create_addrinfo(Process* proc, struct addrinfo* addrinfo) {
  int exc;
  oop imod = proc->mp();
  oop mmclass = proc->send_0(imod, proc->vm()->new_symbol("AddrInfo"), &exc);
  if (exc != 0) {
    return mmclass;
  }
  oop addrdict = proc->mmobj()->mm_dictionary_new();
  oop instance = proc->mmobj()->alloc_instance(proc, mmclass);

  ((struct addrinfo**) instance)[2] = addrinfo;
  ((oop*) instance)[3] = addrdict;

#define addrdict_set(k, v) proc->mmobj()->                              \
    mm_dictionary_set(proc, addrdict, proc->vm()->new_symbol(k),        \
                      tag_small_int(v));

  addrdict_set("ai_flags", addrinfo->ai_flags);
  addrdict_set("ai_family", addrinfo->ai_family);
  addrdict_set("ai_socktype", addrinfo->ai_socktype);
  addrdict_set("ai_protocol", addrinfo->ai_protocol);
#undef addrdict_set

  return instance;
}

static int prim_net_getaddrinfo(Process* proc) {
  oop node_oop = proc->get_arg(0);
  oop service_oop = proc->get_arg(1);
  TYPE_CHECK_ARG(2, "Dictionary");
  oop hints_oop = proc->get_arg(2);

  const char* node = (node_oop == MM_NULL ? NULL :
                      proc->mmobj()->mm_string_cstr(proc, node_oop));
  const char* service = (service_oop == MM_NULL ? NULL :
                         proc->mmobj()->mm_string_cstr(proc, service_oop));

  struct addrinfo hints;
  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_flags = lookup_symbol_in_dict(proc, "ai_flags", hints_oop);
  hints.ai_family = lookup_symbol_in_dict(proc, "ai_family", hints_oop);
  hints.ai_socktype = lookup_symbol_in_dict(proc, "ai_socktype", hints_oop);
  hints.ai_protocol = lookup_symbol_in_dict(proc, "ai_protocol", hints_oop);

  int s;
  oop output = proc->mmobj()->mm_list_new();
  struct addrinfo *result, *rp;
  if ((s = getaddrinfo(node, service, &hints, &result)) != 0) {
    oop ex = proc->mm_exception("Exception", gai_strerror(s));
    proc->stack_push(ex);
    return PRIM_RAISED;
  } else {
    for (rp = result; rp != NULL; rp = rp->ai_next) {
      proc->mmobj()->mm_list_append(proc, output, create_addrinfo(proc, rp));
    }
  }

  proc->stack_push(output);
  return 0;
}

/* -- socket -- */

static int prim_net_socket(Process* proc) {
  TYPE_CHECK_ARG(0, "Integer");
  int domain = untag_small_int(proc->get_arg(0));
  TYPE_CHECK_ARG(1, "Integer");
  int type = untag_small_int(proc->get_arg(1));
  TYPE_CHECK_ARG(2, "Integer");
  int protocol = untag_small_int(proc->get_arg(2));
  int sockfd = socket(domain, type, protocol);
  proc->stack_push(tag_small_int(sockfd));
  return 0;
}

/* -- bind -- */

static int prim_net_bind(Process* proc) {
  TYPE_CHECK_ARG(0, "Integer");
  int sockfd = untag_small_int(proc->get_arg(0));
  //TYPE_CHECK_ARG(1, "Object");
  oop addrinfo_oop = proc->get_arg(1);
  struct addrinfo* addrinfo = (struct addrinfo *) ((oop *) addrinfo_oop)[2];
  int result = bind(sockfd, addrinfo->ai_addr, addrinfo->ai_addrlen);
  proc->stack_push(tag_small_int(result));
  return 0;
}

/* -- listen -- */

static int prim_net_listen(Process* proc) {
  TYPE_CHECK_ARG(0, "Integer");
  int sockfd = untag_small_int(proc->get_arg(0));
  TYPE_CHECK_ARG(1, "Integer");
  int backlog = untag_small_int(proc->get_arg(1));
  int result = listen(sockfd, backlog);
  proc->stack_push(tag_small_int(result));
  return 0;
}

/* -- accept -- */

static oop create_sockaddr(Process* proc, struct sockaddr_storage* addr, socklen_t addrlen) {
  int exc;
  oop imod = proc->mp();
  oop mmclass = proc->send_0(imod, proc->vm()->new_symbol("SockAddr"), &exc);
  if (exc != 0) {
    return mmclass;
  }
  oop instance = proc->mmobj()->alloc_instance(proc, mmclass);
  ((struct sockaddr_storage**) instance)[2] = addr;
  ((socklen_t*) instance)[3] = addrlen;
  return instance;
}

static int prim_net_accept(Process* proc) {
  TYPE_CHECK_ARG(0, "Integer");
  int sockfd = untag_small_int(proc->get_arg(0));

  struct sockaddr_storage* addr = (struct sockaddr_storage*) malloc(sizeof(struct sockaddr_storage));
  socklen_t addrlen = sizeof(struct sockaddr_storage);
  int result = accept(sockfd, (struct sockaddr *) addr, &addrlen);

  oop output = proc->mmobj()->mm_list_new();
  proc->mmobj()->mm_list_append(proc, output, tag_small_int(result));
  proc->mmobj()->mm_list_append(proc, output, create_sockaddr(proc, addr, addrlen));
  proc->stack_push(output);
  return 0;
}

/* -- recv -- */

static int prim_net_recv(Process* proc) {
  TYPE_CHECK_ARG(0, "Integer");
  int sockfd = untag_small_int(proc->get_arg(0));
  TYPE_CHECK_ARG(1, "Integer");
  size_t len = untag_small_int(proc->get_arg(1));
  TYPE_CHECK_ARG(2, "Integer");
  int flags = untag_small_int(proc->get_arg(2));
  char buf[len];
  ssize_t result = recv(sockfd, &buf, len, flags);
  if (result == -1) {
    oop ex = proc->mm_exception("Exception", "recv() failed");
    proc->stack_push(ex);
    return PRIM_RAISED;
  }
  buf[result] = '\0';
  proc->stack_push(proc->mmobj()->mm_string_new(buf));
  return 0;
}

/* -- send -- */

static int prim_net_send(Process* proc) {
  TYPE_CHECK_ARG(0, "Integer");
  int sockfd = untag_small_int(proc->get_arg(0));
  TYPE_CHECK_ARG(1, "String");
  oop buf_oop = proc->get_arg(1);
  TYPE_CHECK_ARG(2, "Integer");
  int flags = untag_small_int(proc->get_arg(2));

  size_t len = proc->mmobj()->mm_string_size(proc, buf_oop);
  const char *buf = proc->mmobj()->mm_string_cstr(proc, buf_oop);
  ssize_t result = send(sockfd, (const void *) buf, len, flags);
  proc->stack_push(tag_small_int(result));

  return 0;
}

static int prim_net_setsockopt(Process* proc) {
  TYPE_CHECK_ARG(0, "Integer");
  int sockfd = untag_small_int(proc->get_arg(0));
  TYPE_CHECK_ARG(1, "Integer");
  int level = untag_small_int(proc->get_arg(1));
  TYPE_CHECK_ARG(2, "Integer");
  int optname = untag_small_int(proc->get_arg(2));
  TYPE_CHECK_ARG(3, "Integer");
  int optval = untag_small_int(proc->get_arg(3));

  // TODO: Only int flags are supported for now, which means that
  // SO_LINGER can't really be used. Maybe instead of just assuming
  // that `optval` is an integer, it could accept instancess of the
  // class "LingerOptions".
  int result = setsockopt(sockfd, level, optname, &optval, sizeof(optval));
  proc->stack_push(tag_small_int(result));
  return 0;
}

/* -- inet_ntop -- */

static int prim_net_inet_ntop(Process* proc) {
  //TYPE_CHECK_ARG(0, "Object");
  oop addr_oop = proc->get_arg(0);
  struct sockaddr_storage* addr =
    (struct sockaddr_storage*) ((oop *) addr_oop)[2];

  char buffer[INET6_ADDRSTRLEN] = { 0 };
  switch (addr->ss_family) {
  case AF_INET:
    inet_ntop(addr->ss_family,
              &((struct sockaddr_in *) addr)->sin_addr,
              buffer, INET_ADDRSTRLEN);
    break;
  case AF_INET6:
    inet_ntop(addr->ss_family,
              &((struct sockaddr_in6 *) addr)->sin6_addr,
              buffer, INET6_ADDRSTRLEN);
    break;
  }
  proc->stack_push(proc->mmobj()->mm_string_new(buffer));
  return 0;
}

/* -- close -- */

static int prim_net_close(Process* proc) {
  TYPE_CHECK_ARG(0, "Integer");
  int fd = untag_small_int(proc->get_arg(0));
  proc->stack_push(tag_small_int(close(fd)));
  return 0;
}

void net_init_primitives(VM *vm) {
  vm->register_primitive("net_getaddrinfo", prim_net_getaddrinfo);
  vm->register_primitive("net_socket", prim_net_socket);
  vm->register_primitive("net_setsockopt", prim_net_setsockopt);
  vm->register_primitive("net_bind", prim_net_bind);
  vm->register_primitive("net_listen", prim_net_listen);
  vm->register_primitive("net_accept", prim_net_accept);
  vm->register_primitive("net_inet_ntop", prim_net_inet_ntop);
  vm->register_primitive("net_recv", prim_net_recv);
  vm->register_primitive("net_send", prim_net_send);
  vm->register_primitive("net_close", prim_net_close);
}
