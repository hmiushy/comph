/* -*- P4_16 -*- */
#ifndef _CONST_P4_
#define _CONST_P4_

const bit<16> ETHERTYPE_ARP  = 0x0806;
const bit<16> ETHERTYPE_VLAN = 0x8100;
const bit<16> ETHERTYPE_IPV4 = 0x0800;

const bit<8>  IP_PROTOCOLS_ICMP = 0x01;
const bit<8>  IP_PROTOCOLS_IPv4 = 0x04;
const bit<8>  IP_PROTOCOLS_TCP  = 0x06;
const bit<8>  IP_PROTOCOLS_UDP  = 0x11;

/* Added by Miura */
#define IP_PROTOCOLS_COMP 146
#define NUM_PACK 4
#define NUM_TUPPLE 5
#define SWITCH_MIRROR_TYPE_COMP 7  // didn't use
#define SWITCH_MIRROR_TYPE_COMP_E2E 8


#endif
