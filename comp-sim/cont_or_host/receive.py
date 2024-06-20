#!/usr/bin/env python3
import argparse
import csv
import os
import pprint
import re
import sys
import time

from scapy.all import *
from comp_hdr import *
from scapy.all import IP, TCP, Ether, get_if_hwaddr, get_if_list, sendp


count = 0
info_src_addr = {}
info_dst_addr = {}
info_src_port = {}
info_dst_port = {}
info_protocol = {}
def packet_callback(packet, args):
    pkt = bytes(packet)
    global count
    global info_src_addr, info_dst_addr, info_src_port, info_dst_port, info_protocol
    ## ------------------------------ Packet Info
    IP_PROTO_ICMP = 1
    IP_PROTO_TCP  = 6
    IP_PROTO_UDP  = 17
    IP_PROTO_COMP = 146 ## user defined header
    
    HEADER_LENGTH_ETHERNET = 14#+1 # 1 byte is attached to a mirrored packet
    HEADER_LENGTH_IP       = 20
    HEADER_LENGTH_ICMP     = 8
    HEADER_LENGTH_UDP      = 8
    HEADER_LENGTH_TCP      = 20
    HEADER_LENGTH_COMP     = 14 ## user defined header
    if args.verbose == 1:
        print(" ------------------------- packet-in -------------------------")
    indent = " "
    now_indent = indent
    ## Ethernet header report ## ------------------------
    pre_pos = 0
    end_pos = HEADER_LENGTH_ETHERNET
    eth_report = Ether(pkt[pre_pos:end_pos])
    if args.verbose == 1:
        eth_report.show2()  
    ## IPv4 header report ## ------------------------
    pre_pos = end_pos
    end_pos += HEADER_LENGTH_IP
    ip_report = IP(pkt[pre_pos:end_pos])
    
    if args.verbose == 1:
        ip_report.show2(lvl=now_indent)
    
    if ip_report.proto == IP_PROTO_COMP:
        ## COMP header report ## ------------------------
        comp_type = IP_PROTO_COMP
        comp_header_count = 1
        while comp_type == IP_PROTO_COMP:
            pre_pos = end_pos
            end_pos += HEADER_LENGTH_COMP
            comp_report = COMP(pkt[pre_pos:end_pos])
            comp_type = comp_report.comp_type
            ## ---------- src_addr ----------
            if comp_report.src_addr in info_src_addr:
                info_src_addr[comp_report.src_addr] += 1
            else:
                info_src_addr[comp_report.src_addr] = 1
            ## ---------- dst_addr ----------
            if comp_report.dst_addr in info_dst_addr:
                info_dst_addr[comp_report.dst_addr] += 1
            else:
                info_dst_addr[comp_report.dst_addr] = 1
            ## ---------- src_port ----------
            if comp_report.src_port in info_src_port:
                info_src_port[comp_report.src_port] += 1
            else:
                info_src_port[comp_report.src_port] = 1
            ## ---------- dst_port ----------
            if comp_report.dst_port in info_dst_port:
                info_dst_port[comp_report.dst_port] += 1
            else:
                info_dst_port[comp_report.dst_port] = 1
            ## ---------- protocol ----------
            if comp_report.protocol in info_protocol:
                info_protocol[comp_report.protocol] += 1
            else:
                info_protocol[comp_report.protocol] = 1
                
            
            if args.verbose == 1:
                print("###[ COMP HEADER {} ]###".format(comp_header_count))
                for cnt in range(comp_header_count):
                    now_indent += indent
                comp_report.show2(lvl=now_indent)
            comp_header_count += 1
    count += 1
    if args.verbose == 0:
        pprint.pprint(info_src_addr)
        pprint.pprint(info_dst_addr)
        pprint.pprint(info_src_port)
        pprint.pprint(info_dst_port)
        pprint.pprint(info_protocol)
    if args.verbose == 1:
        print("packet count: {}".format(count))
def info_write(filename: str, info_dict: dict):
    with open(filename, "w") as f:
        new_key = info_dict.keys()
        new_key = sorted(new_key)
        for tmp_key in new_key:
            f.write("{},{}\n".format(tmp_key,info_dict[tmp_key]))
    
def main():
    ## -------------- Get args --------------------
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--iface", type=str, required=True)
    parser.add_argument("-v", "--verbose", required=False,
                        default=False, action="store_true")
    args = parser.parse_args()
    iface = args.iface

    ## -------------- Sniffing --------------------
    print("sniffing on {}".format(iface))
    try:
        sniff(iface=iface,
              prn= lambda x:packet_callback(x,args))
        os.makedirs("./info/",exist_ok=True)
        info_write("./info/src_addr.csv", info_src_addr)
        info_write("./info/dst_addr.csv", info_dst_addr)
        info_write("./info/src_port.csv", info_src_port)
        info_write("./info/dst_port.csv", info_dst_port)
        info_write("./info/protocol.csv", info_protocol)
    except OSError:
        ifs = get_if_list()
        print("Please attach sudo or,")
        print("Chose: {}".format(ifs))


if __name__ == '__main__':
    main()
