#!/usr/bin/env python3
import random
import socket
import sys

from scapy.all import IP, TCP, Ether, get_if_hwaddr, get_if_list, sendp
from scapy.all import *

def get_if():
    ifs=get_if_list()
    iface=None 
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print("Cannot find eth0 interface")
        exit(1)
    return iface

def main():
    if len(sys.argv)<10:
        print('pass 10 arguments: <src_addr> <dst_addr> <src_port> <dst_port> <tcp/udp> "<message>" <rnd/fixed>')
        print('(ex)')
        print('sudo python3 sendtcpudp.py 10.10.10.10 9.9.9.9 5 6 udp 1 hello fixed veth1')
        print('Please attach sudo')
        exit(1)
        
    src_addr = sys.argv[1]
    dst_addr = sys.argv[2]
    src_port = int(sys.argv[3])
    dst_port = int(sys.argv[4])
    
    tcpudp = sys.argv[5]
    count = sys.argv[6]
    message  = sys.argv[7]
    rnd_or_not = sys.argv[8]
    iface = sys.argv[9]
    
    scr_addr = socket.gethostbyname(src_addr)
    dst_addr = socket.gethostbyname(dst_addr)
    
    macdst = "08:00:00:00:01:00"
    print("sending on interface %s to %s" % (iface, str(dst_addr)))
    try:
        pkt = Ether(src=get_if_hwaddr(iface), dst=macdst)
    except OSError:
        ifs = get_if_list()
        print("Please attach sudo or,")
        print("Chose: {}".format(ifs))
        exit(1)

    if rnd_or_not == "rnd":
        if tcpudp == "tcp":
            pkt = pkt /IP(src=src_addr,dst=dst_addr) /\
                TCP(dport=1234, sport=random.randint(49152,65535)) /\
                message
            
        if tcpudp == "udp":
            pkt = pkt /IP(src=src_addr,dst=dst_addr) / \
                UDP(dport=1234, sport=random.randint(49152,65535)) / \
                message
    else:
        if tcpudp == "tcp":
            pkt = pkt /IP(src=src_addr,dst=dst_addr) / \
                TCP(dport=dst_port, sport=src_port) / message
        if tcpudp == "udp":
            pkt = pkt /IP(src=src_addr,dst=dst_addr) /\
                UDP(dport=dst_port, sport=src_port) / message
        
    pkt.show()
    for i in range(int(count)):
        sendp(pkt, iface=iface)

if __name__ == '__main__':
    main()
