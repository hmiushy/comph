/* -*- P4_16 -*- */
#define NUM_PACK  4
#define NUM_TUPLE 5
#define IP_PROTOCOLS_TCP 6
#define IP_PROTOCOLS_UDP 17
#define IP_PROTOCOLS_COMP 146
control COMPegress (inout switch_header_t hdr,
    inout switch_egress_metadata_t eg_md,
    inout egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr) {
    Register<bit<1>,_> (1, 0) flag;
    RegisterAction<bit<1>,_,bit<1>> (flag) flag_up = {
        void apply(inout bit<1> value, out bit<1> read_value) {
            read_value = value; value = 1; } };
    RegisterAction<bit<1>,_,bit<1>> (flag) flag_down = {
        void apply(inout bit<1> value, out bit<1> read_value) {
            read_value = value; value = 0; } };
    
    action set_md(MirrorId_t eg_ses /*, bit<32> dst_addr*/) {
        //hdr.ipv4.dst_addr = dst_addr;
        eg_md.eg_mir_ses = eg_ses;
        eg_intr_md_for_dprsr.mirror_type = SWITCH_MIRROR_TYPE_COMP_E2E;
    }
    
    table  mirror_fwd {
        key = { hdr.comp_0.isValid() : exact; }
        actions = { set_md; }
        size = 512;
    }
    apply {
        // Only once mirroring
        bit<1> tmp_flag;
        if (!hdr.comp_0.isValid()) {
            flag_down.execute(0);
        }
        if (hdr.comp_0.isValid()) {
            tmp_flag = flag_up.execute(0);
            if (tmp_flag == 0) {
                mirror_fwd.apply();
            }
        }
    }
}

