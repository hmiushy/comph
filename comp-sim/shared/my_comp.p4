/* -*- P4_16 -*- */
#define NUM_PACK  4

#define IP_PROTOCOLS_TCP 6
#define IP_PROTOCOLS_UDP 17
#define IP_PROTOCOLS_COMP 146
control COMP (inout switch_header_t hdr,
    inout switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
    inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm) {
    
    // Information 0 ---------------------------
    Register<bit<32>, bit<1>> (1, 0) src_addr_0;
    Register<bit<32>, bit<1>> (1, 0) dst_addr_0;
    Register<bit<16>, bit<1>> (1, 0) src_port_0;
    Register<bit<16>, bit<1>> (1, 0) dst_port_0;
    Register<bit<8>,  bit<1>> (1, 0) protocol_0;
    RegisterAction<bit<32>,bit<1>,bit<32>> (src_addr_0) save_src_addr_0 = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            read_value = value;
            value = hdr.ipv4.src_addr;
        }
    };
    RegisterAction<bit<32>,bit<1>,bit<32>> (dst_addr_0) save_dst_addr_0 = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            read_value = value;
            value = hdr.ipv4.dst_addr;
        }
    };
    RegisterAction<bit<16>,bit<1>,bit<16>> (src_port_0) save_src_port_0 = {
        void apply(inout bit<16> value, out bit<16> read_value) {
            read_value = value;
            value = ig_md.comp_info.src_port;
        }
    };
    RegisterAction<bit<16>,bit<1>,bit<16>> (dst_port_0) save_dst_port_0 = {
        void apply(inout bit<16> value, out bit<16> read_value) {
            read_value = value;
            value = ig_md.comp_info.dst_port;
        }
    };
    RegisterAction<bit<8>,bit<1>,bit<8>> (protocol_0) save_protocol_0 = {
        void apply(inout bit<8> value, out bit<8> read_value) {
            read_value = value;
            value = hdr.ipv4.protocol;
        }
    };
    
    // Information 1 ---------------------------
    Register<bit<32>, bit<1>> (1, 0) src_addr_1;
    Register<bit<32>, bit<1>> (1, 0) dst_addr_1;
    Register<bit<16>, bit<1>> (1, 0) src_port_1;
    Register<bit<16>, bit<1>> (1, 0) dst_port_1;
    Register<bit<8>,  bit<1>> (1, 0) protocol_1;
    RegisterAction<bit<32>,bit<1>,bit<32>> (src_addr_1) save_src_addr_1 = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            read_value = value;
            value = hdr.ipv4.src_addr;
        }
    };
    RegisterAction<bit<32>,bit<1>,bit<32>> (dst_addr_1) save_dst_addr_1 = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            read_value = value;
            value = hdr.ipv4.dst_addr;
        }
    };
    RegisterAction<bit<16>,bit<1>,bit<16>> (src_port_1) save_src_port_1 = {
        void apply(inout bit<16> value, out bit<16> read_value) {
            read_value = value;
            value = ig_md.comp_info.src_port;
        }
    };
    RegisterAction<bit<16>,bit<1>,bit<16>> (dst_port_1) save_dst_port_1 = {
        void apply(inout bit<16> value, out bit<16> read_value) {
            read_value = value;
            value = ig_md.comp_info.dst_port;
        }
    };
    RegisterAction<bit<8>,bit<1>,bit<8>> (protocol_1) save_protocol_1 = {
        void apply(inout bit<8> value, out bit<8> read_value) {
            read_value = value;
            value = hdr.ipv4.protocol;
        }
    };
    
    // Information of tuple_2    
    Register<bit<32>, bit<1>> (1, 0) src_addr_2;
    Register<bit<32>, bit<1>> (1, 0) dst_addr_2;
    Register<bit<16>, bit<1>> (1, 0) src_port_2;
    Register<bit<16>, bit<1>> (1, 0) dst_port_2;
    Register<bit<8>,  bit<1>> (1, 0) protocol_2;
    RegisterAction<bit<32>,bit<1>,bit<32>> (src_addr_2) save_src_addr_2 = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            read_value = value;
            value = hdr.ipv4.src_addr;
        }
    };
    RegisterAction<bit<32>,bit<1>,bit<32>> (dst_addr_2) save_dst_addr_2 = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            read_value = value;
            value = hdr.ipv4.dst_addr;
        }
    };
    RegisterAction<bit<16>,bit<1>,bit<16>> (src_port_2) save_src_port_2 = {
        void apply(inout bit<16> value, out bit<16> read_value) {
            read_value = value;
            value = ig_md.comp_info.src_port;
        }
    };
    RegisterAction<bit<16>,bit<1>,bit<16>> (dst_port_2) save_dst_port_2 = {
        void apply(inout bit<16> value, out bit<16> read_value) {
            read_value = value;
            value = ig_md.comp_info.dst_port;
        }
    };
    RegisterAction<bit<8>,bit<1>,bit<8>> (protocol_2) save_protocol_2 = {
        void apply(inout bit<8> value, out bit<8> read_value) {
            read_value = value;
            value = hdr.ipv4.protocol;
        }
    };
    
    // Information of tuple_3 ---------------
    Register<bit<32>, bit<1>> (1, 0) src_addr_3;
    Register<bit<32>, bit<1>> (1, 0) dst_addr_3;
    Register<bit<16>, bit<1>> (1, 0) src_port_3;
    Register<bit<16>, bit<1>> (1, 0) dst_port_3;
    Register<bit<8>,  bit<1>> (1, 0) protocol_3;
    RegisterAction<bit<32>,bit<1>,bit<32>> (src_addr_3) save_src_addr_3 = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            value = hdr.ipv4.src_addr;
            read_value = value;
        }
    };
    RegisterAction<bit<32>,bit<1>,bit<32>> (dst_addr_3) save_dst_addr_3 = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            value = hdr.ipv4.dst_addr;
            read_value = value;
        }
    };
    RegisterAction<bit<16>,bit<1>,bit<16>> (src_port_3) save_src_port_3 = {
        void apply(inout bit<16> value, out bit<16> read_value) {
            value = ig_md.comp_info.src_port;
            read_value = value;
        }
    };
    RegisterAction<bit<16>,bit<1>,bit<16>> (dst_port_3) save_dst_port_3 = {
        void apply(inout bit<16> value, out bit<16> read_value) {
            value = ig_md.comp_info.dst_port;
            read_value = value;
        }
    };
    RegisterAction<bit<8>,bit<1>,bit<8>> (protocol_3) save_protocol_3 = {
        void apply(inout bit<8> value, out bit<8> read_value) {
            value = hdr.ipv4.protocol;
            read_value = value;
        }
    };

    // Current Packet counter
    // If value > number of packets to be compressed, the value is reseted.
    Register<bit<8>, _> (2, 0) packet_count;
    RegisterAction<bit<8>, bit<2>, bit<8>> (packet_count) p_count = {
        void apply(inout bit<8> value, out bit<8> read_value) {
            read_value = value;
            if (value >= NUM_PACK-1) { value = 0; }
            else { value = value + 1; }
        }
    };

    // If I didn't specify a port number, I could't mirror the packet
    action set_port(bit<9> port) {
        ig_intr_md_for_tm.ucast_egress_port = port;
    }
    
    table  ipv4_set_port {
        key = { hdr.ipv4.isValid() : exact; }
        actions = { set_port; }
        size = 512;
    }
    apply {
        if (hdr.ipv4.isValid()) {
            if (hdr.tcp.isValid() || hdr.udp.isValid()) {
                if (hdr.ipv4.protocol == IP_PROTOCOLS_TCP) {
                    ig_md.comp_info.src_port = hdr.tcp.src_port;
                    ig_md.comp_info.dst_port = hdr.tcp.dst_port;
                }
                else {
                    ig_md.comp_info.src_port = hdr.udp.src_port;
                    ig_md.comp_info.dst_port = hdr.udp.dst_port;
                }
                // Get the packet count
                ig_md.comp_info.packet_count = p_count.execute(0);
                if (ig_md.comp_info.packet_count == 0) {
                    save_src_addr_0.execute(0);
                    save_dst_addr_0.execute(0);
                    save_src_port_0.execute(0);
                    save_dst_port_0.execute(0);
                    save_protocol_0.execute(0);
                }
                else if (ig_md.comp_info.packet_count == 1) {
                    save_src_addr_1.execute(0);
                    save_dst_addr_1.execute(0);
                    save_src_port_1.execute(0);
                    save_dst_port_1.execute(0);
                    save_protocol_1.execute(0);
                }
                else if (ig_md.comp_info.packet_count == 2) {
                    save_src_addr_2.execute(0);
                    save_dst_addr_2.execute(0);
                    save_src_port_2.execute(0);
                    save_dst_port_2.execute(0);
                    save_protocol_2.execute(0);
                }
                else if (ig_md.comp_info.packet_count >= NUM_PACK-1) {
                    hdr.comp_0.setValid();
                    hdr.comp_0.src_addr = save_src_addr_0.execute(0);
                    hdr.comp_0.dst_addr = save_dst_addr_0.execute(0);
                    hdr.comp_0.src_port = save_src_port_0.execute(0);
                    hdr.comp_0.dst_port = save_dst_port_0.execute(0);
                    hdr.comp_0.protocol = save_protocol_0.execute(0);
                    hdr.comp_0.comp_type = IP_PROTOCOLS_COMP;
                    
                    hdr.comp_1.setValid();
                    hdr.comp_1.src_addr = save_src_addr_1.execute(0);
                    hdr.comp_1.dst_addr = save_dst_addr_1.execute(0);
                    hdr.comp_1.src_port = save_src_port_1.execute(0);
                    hdr.comp_1.dst_port = save_dst_port_1.execute(0);
                    hdr.comp_1.protocol = save_protocol_1.execute(0);
                    hdr.comp_1.comp_type = IP_PROTOCOLS_COMP;
                    
                    hdr.comp_2.setValid();
                    hdr.comp_2.src_addr = save_src_addr_2.execute(0);
                    hdr.comp_2.dst_addr = save_dst_addr_2.execute(0);
                    hdr.comp_2.src_port = save_src_port_2.execute(0);
                    hdr.comp_2.dst_port = save_dst_port_2.execute(0);
                    hdr.comp_2.protocol = save_protocol_2.execute(0);
                    hdr.comp_2.comp_type = IP_PROTOCOLS_COMP;
                    
                    hdr.comp_3.setValid();
                    hdr.comp_3.src_addr = save_src_addr_3.execute(0);
                    hdr.comp_3.dst_addr = save_dst_addr_3.execute(0);
                    hdr.comp_3.src_port = save_src_port_3.execute(0);
                    hdr.comp_3.dst_port = save_dst_port_3.execute(0);
                    hdr.comp_3.protocol = save_protocol_3.execute(0);
                    hdr.comp_3.comp_type = hdr.ipv4.protocol;
                    hdr.ipv4.protocol = IP_PROTOCOLS_COMP;
                    // 14 bytes (comp header) * 4 = 56 bytes
                    hdr.ipv4.total_len = hdr.ipv4.total_len + 56;
                }
            }
            ipv4_set_port.apply();
        }
    }
}