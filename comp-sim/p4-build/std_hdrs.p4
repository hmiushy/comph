/* -*- P4_16 -*- */

#ifndef _STD_HDRS_P4_
#define _STD_HDRS_P4_

#include "const.p4"
#include <core.p4>
#include <t2na.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

header ethernet_t {
    bit<48>   dst_addr;
    bit<48>   src_addr;
    bit<16>   ether_type;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   total_len;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   frag_offset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdr_checksum;
    bit<32>   src_addr;
    bit<32>   dst_addr;
}

// Added by Miura

header comp_h {
    bit<32> src_addr;
    bit<32> dst_addr;
    bit<16> src_port;
    bit<16> dst_port;
    bit<8> protocol;
    bit<8> comp_type;
}

header tcp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> seq_no;
    bit<32> ack_no;
    bit<4>  data_offset;
    bit<4>  res;
    bit<8>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgent_ptr;
}

header udp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> length;
    bit<16> checksum;
}

struct switch_header_t {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    comp_h       comp_0;
    comp_h       comp_1;
    comp_h       comp_2;
    comp_h       comp_3;
    tcp_t        tcp;
    udp_t        udp;
}

struct comp_info_t {
    bit<8> packet_count;
    bit<16> dst_port;
    bit<16> src_port;
}

struct switch_ingress_metadata_t {
    MirrorId_t ing_mir_ses;
    comp_info_t comp_info;
    bit<9> ingress_port;
}

typedef bit<8> switch_mirror_type_t;
typedef MirrorId_t switch_mirror_session_t;
header mirror_h {
    switch_mirror_type_t type;
}

struct switch_egress_metadata_t {
    MirrorId_t eg_mir_ses;
    switch_mirror_type_t pkt_mirror_type;
    bit<2> mirror_cnt;
    bit<9> my_port;
}

#endif
