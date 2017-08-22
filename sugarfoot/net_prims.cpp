#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#include <iostream>
#include "process.hpp"
#include "vm.hpp"

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
  oop instance = proc->mmobj()->alloc_instance(proc, mmclass);
  ((struct addrinfo**) instance)[2] = addrinfo;
  return instance;
}

static int prim_net_getaddrinfo(Process* proc) {
  oop node_oop = proc->get_arg(0);
  oop service_oop = proc->get_arg(1);
  oop hints_oop = proc->get_arg(2);

  const char* node = (node_oop == MM_NULL ? NULL :
                      proc->mmobj()->mm_string_cstr(proc, node_oop));
  const char* service = (service_oop == MM_NULL ? NULL :
                         proc->mmobj()->mm_string_cstr(proc, service_oop));

  struct addrinfo hints;
  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_flags = lookup_symbol_in_dict(proc, "flags", hints_oop);
  hints.ai_family = lookup_symbol_in_dict(proc, "family", hints_oop);
  hints.ai_socktype = lookup_symbol_in_dict(proc, "socktype", hints_oop);
  hints.ai_protocol = lookup_symbol_in_dict(proc, "protocol", hints_oop);

  int s;
  oop output = proc->mmobj()->mm_list_new();
  struct addrinfo *result, *rp;
  if ((s = getaddrinfo(node, service, &hints, &result)) != 0) {
    // TODO: Throw exception in case it fails
    std::cout << "Oh No!!: " << gai_strerror(s) << "\n";
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
  int domain = untag_small_int(proc->get_arg(0));
  int type = untag_small_int(proc->get_arg(1));
  int protocol = untag_small_int(proc->get_arg(2));
  int sockfd = socket(domain, type, protocol);
  proc->stack_push(tag_small_int(sockfd));
  return 0;
}

/* -- bind -- */

static int prim_net_bind(Process* proc) {
  int sockfd = untag_small_int(proc->get_arg(0));
  oop addrinfo_oop = proc->get_arg(1);
  struct addrinfo* addrinfo = (struct addrinfo *) ((oop *) addrinfo_oop)[2];
  int result = bind(sockfd, addrinfo->ai_addr, addrinfo->ai_addrlen);
  proc->stack_push(tag_small_int(result));
  return 0;
}

/* -- addrinfo -- */

static int prim_net_addrinfo_ai_family(Process* proc) {
  oop addrinfo_oop = proc->rp();
  struct addrinfo* addrinfo = (struct addrinfo *) ((oop *) addrinfo_oop)[2];
  proc->stack_push(tag_small_int(addrinfo->ai_family));
  return 0;
}

static int prim_net_addrinfo_ai_socktype(Process* proc) {
  oop addrinfo_oop = proc->rp();
  struct addrinfo* addrinfo = (struct addrinfo *) ((oop *) addrinfo_oop)[2];
  proc->stack_push(tag_small_int(addrinfo->ai_socktype));
  return 0;
}

static int prim_net_addrinfo_ai_protocol(Process* proc) {
  oop addrinfo_oop = proc->rp();
  struct addrinfo* addrinfo = (struct addrinfo *) ((oop *) addrinfo_oop)[2];
  proc->stack_push(tag_small_int(addrinfo->ai_protocol));
  return 0;
}

void net_init_primitives(VM *vm) {
  vm->register_primitive("net_getaddrinfo", prim_net_getaddrinfo);
  vm->register_primitive("net_socket", prim_net_socket);
  vm->register_primitive("net_bind", prim_net_bind);
  vm->register_primitive("net_addrinfo_ai_family", prim_net_addrinfo_ai_family);
  vm->register_primitive("net_addrinfo_ai_socktype", prim_net_addrinfo_ai_socktype);
  vm->register_primitive("net_addrinfo_ai_protocol", prim_net_addrinfo_ai_protocol);
}
