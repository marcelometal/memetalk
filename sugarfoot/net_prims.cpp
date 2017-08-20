#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#include <iostream>
#include "process.hpp"
#include "vm.hpp"

/* -- getaddrinfo -- */

static char *get_ip_str(const struct sockaddr *sa, char *s, size_t maxlen)
{
  switch (sa->sa_family) {
  case AF_INET:
    inet_ntop(AF_INET, &(((struct sockaddr_in *)sa)->sin_addr), s, maxlen);
    break;
  case AF_INET6:
    inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)sa)->sin6_addr), s, maxlen);
    break;
  default:
    strncpy(s, "Unknown AF", maxlen);
    return NULL;
  }
  return s;
}

static int lookup_symbol_in_dict(Process* proc, const char* symbol, oop dict) {
  oop key = proc->mmobj()->mm_symbol_new(symbol);
  if (proc->mmobj()->mm_dictionary_has_key(proc, dict, key)) {
    return untag_small_int(proc->mmobj()->mm_dictionary_get(proc, dict, key));
  }
  return 0;
}

static oop create_addrinfo_dict(Process* proc, struct addrinfo* addrinfo) {
  oop addrinfo_dict = proc->mmobj()->mm_dictionary_new();
  proc->mmobj()->mm_dictionary_set(proc,
                                   addrinfo_dict,
                                   proc->mmobj()->mm_string_new("family"),
                                   tag_small_int(addrinfo->ai_family));
  proc->mmobj()->mm_dictionary_set(proc,
                                   addrinfo_dict,
                                   proc->mmobj()->mm_string_new("socktype"),
                                   tag_small_int(addrinfo->ai_socktype));
  proc->mmobj()->mm_dictionary_set(proc,
                                   addrinfo_dict,
                                   proc->mmobj()->mm_string_new("flags"),
                                   tag_small_int(addrinfo->ai_socktype));
  proc->mmobj()->mm_dictionary_set(proc,
                                   addrinfo_dict,
                                   proc->mmobj()->mm_string_new("protocol"),
                                   tag_small_int(addrinfo->ai_socktype));

  char addr_str[addrinfo->ai_addrlen];
  get_ip_str(addrinfo->ai_addr, addr_str, addrinfo->ai_addrlen);
  proc->mmobj()->mm_dictionary_set(proc,
                                   addrinfo_dict,
                                   proc->mmobj()->mm_string_new("addr"),
                                   proc->mmobj()->mm_string_new(addr_str));
  return addrinfo_dict;
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
      oop addrinfo_dict = create_addrinfo_dict(proc, rp);
      proc->mmobj()->mm_list_append(proc, output, addrinfo_dict);
    }
    freeaddrinfo(result);
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

void net_init_primitives(VM *vm) {
  vm->register_primitive("net_getaddrinfo", prim_net_getaddrinfo);
  vm->register_primitive("net_socket", prim_net_socket);
}
