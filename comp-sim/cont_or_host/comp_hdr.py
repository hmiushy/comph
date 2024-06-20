from scapy.all import *

TYPE_COMP = 146
TYPE_IPV4 = 0x0800

class COMP(Packet):
   name = "TYPE_COMP"
   fields_desc = [BitField("src_addr", 0, 32),
                  BitField("dst_addr", 0, 32),
                  BitField("src_port", 0, 16),
                  BitField("dst_port", 0, 16),
                  ByteField("protocol",0),
                  ByteField("comp_type",0)]
   
bind_layers(Ether, IP, type=TYPE_IPV4)
bind_layers(IP, COMP, proto=TYPE_COMP)
bind_layers(COMP, COMP)
