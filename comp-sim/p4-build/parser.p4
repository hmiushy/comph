/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
/*
=========================================================================================
======================================== INGRESS ========================================
=========================================================================================
*/
/*************************************************
**********  I N G R E S S   P A R S E R **********
**************************************************/

parser TofinoIngressParser(
    packet_in pkt,
    out ingress_intrinsic_metadata_t ig_intr_md) {
    state start {
      pkt.extract(ig_intr_md);
        transition select(ig_intr_md.resubmit_flag) {
            1 : parse_resubmit;
            0 : parse_port_metadata;
        }
    }

    state parse_resubmit {
        transition reject;
    }

    state parse_port_metadata {
      pkt.advance(PORT_METADATA_SIZE);
        transition accept;
    }
}

parser SwitchIngressParser(
    packet_in pkt,
    out switch_header_t hdr,
    out switch_ingress_metadata_t ig_md,
    out ingress_intrinsic_metadata_t ig_intr_md) {
    
  TofinoIngressParser() tofino_parser;
    
    state start {
      tofino_parser.apply(pkt, ig_intr_md);
      transition parse_ethernet;
    }
    state parse_ethernet {
      pkt.extract(hdr.ethernet);
      transition select (hdr.ethernet.ether_type) {
      ETHERTYPE_IPV4 : parse_ipv4_no_options;
        default : reject;
      }
    }

    state parse_ipv4_no_options {
      pkt.extract(hdr.ipv4);
      transition select(hdr.ipv4.protocol, hdr.ipv4.frag_offset) {
      (IP_PROTOCOLS_TCP, 0)  : parse_tcp;
      (IP_PROTOCOLS_UDP, 0)  : parse_udp;
      (IP_PROTOCOLS_COMP, 0) : parse_comp_0;
        default : accept;
      }
    }
    
    // I wanted to use array structure but doesn't work
    // (I did not use hdr.comp_x.next and hdr.comp_x.last)
    state parse_comp_0 {
      pkt.extract(hdr.comp_0);
      transition select(hdr.comp_0.comp_type) {
      IP_PROTOCOLS_TCP  : parse_tcp;
      IP_PROTOCOLS_UDP  : parse_udp;
      IP_PROTOCOLS_COMP : parse_comp_1;
        default: accept;
      }
    }
    state parse_comp_1 {
      pkt.extract(hdr.comp_1);
      transition select(hdr.comp_1.comp_type) {
      IP_PROTOCOLS_TCP  : parse_tcp;
      IP_PROTOCOLS_UDP  : parse_udp;
      IP_PROTOCOLS_COMP : parse_comp_2;
        default: accept;
      }
    }
    state parse_comp_2 {
      pkt.extract(hdr.comp_2);
      transition select(hdr.comp_2.comp_type) {
      IP_PROTOCOLS_TCP  : parse_tcp;
      IP_PROTOCOLS_UDP  : parse_udp;
      IP_PROTOCOLS_COMP : parse_comp_3;
        default: accept;
      }
    }
    state parse_comp_3 {
      pkt.extract(hdr.comp_3);
      transition select(hdr.comp_3.comp_type) {
      IP_PROTOCOLS_TCP  : parse_tcp;
      IP_PROTOCOLS_UDP  : parse_udp;
        default: accept;
      }
    }

    state parse_udp {
      pkt.extract(hdr.udp);
      transition accept;
    }
    

    state parse_tcp {
      pkt.extract(hdr.tcp);
      transition accept;
    }
}

/*************************************************
********  I N G R E S S   D E P A R S E R ********
**************************************************/
control SwitchIngressDeparser(
    packet_out pkt,
    inout switch_header_t hdr,
    in switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr){
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
        pkt.emit(hdr.comp_0);
        pkt.emit(hdr.comp_1);
        pkt.emit(hdr.comp_2);
        pkt.emit(hdr.comp_3);
        pkt.emit(hdr.tcp);
        pkt.emit(hdr.udp);
    }
}

/*
=========================================================================================
======================================== EGRESS =========================================
=========================================================================================
*/
/***************************************************************
****************  E G R E S S   P A R S E R  ******************* 
****************************************************************/
parser TofinoEgressParser(
        packet_in pkt,
        out egress_intrinsic_metadata_t eg_intr_md) {
    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}
parser SwitchEgressParser(
        packet_in pkt,
        out switch_header_t hdr,
        out switch_egress_metadata_t eg_md,
        out egress_intrinsic_metadata_t eg_intr_md) {    
  TofinoEgressParser() tofino_parser;
   
  state start {
        tofino_parser.apply(pkt, eg_intr_md);

        //transition parse_ethernet;
        
        mirror_h mirror_md = pkt.lookahead<mirror_h>();
        transition select(mirror_md.type) {
            SWITCH_MIRROR_TYPE_COMP : parse_mirrored_comp;
            //0 : parse_mirrored_comp;
            default : parse_ethernet;
        }
    }

    // Added by Miura
    state parse_mirrored_comp {
        mirror_h update_mirror_md;
        pkt.extract(update_mirror_md);
        // add some process?
        //hdr.ethernet.setInvalid();
        //hdr.ipv4.setInvalid();
        transition parse_ethernet;
    }
    
  state parse_ethernet {
    pkt.extract(hdr.ethernet);
    transition select (hdr.ethernet.ether_type) {
    ETHERTYPE_IPV4 : parse_ipv4_no_options;
      default : reject;
    }
  }

  state parse_ipv4_no_options {
    pkt.extract(hdr.ipv4);
    //transition select(hdr.ipv4.protocol, hdr.ipv4.frag_offset) {
    transition select(hdr.ipv4.protocol) {
      /* (IP_PROTOCOLS_TCP, 0)  : parse_tcp; */
      /* (IP_PROTOCOLS_UDP, 0)  : parse_udp; */
      /* (IP_PROTOCOLS_COMP, 0) : parse_comp; */
    IP_PROTOCOLS_TCP  : parse_tcp;
    IP_PROTOCOLS_UDP  : parse_udp;
    IP_PROTOCOLS_COMP : parse_comp_0;
      default : accept;
    }
  }
    state parse_comp_0 {
      pkt.extract(hdr.comp_0);
      transition select(hdr.comp_0.comp_type) {
      IP_PROTOCOLS_TCP  : parse_tcp;
      IP_PROTOCOLS_UDP  : parse_udp;
      IP_PROTOCOLS_COMP : parse_comp_1;
        default: accept;
      }
    }
    state parse_comp_1 {
      pkt.extract(hdr.comp_1);
      transition select(hdr.comp_1.comp_type) {
      IP_PROTOCOLS_TCP  : parse_tcp;
      IP_PROTOCOLS_UDP  : parse_udp;
      IP_PROTOCOLS_COMP : parse_comp_2;
        default: accept;
      }
    }
    state parse_comp_2 {
      pkt.extract(hdr.comp_2);
      transition select(hdr.comp_2.comp_type) {
      IP_PROTOCOLS_TCP  : parse_tcp;
      IP_PROTOCOLS_UDP  : parse_udp;
      IP_PROTOCOLS_COMP : parse_comp_3;
        default: accept;
      }
    }
    state parse_comp_3 {
      pkt.extract(hdr.comp_3);
      transition select(hdr.comp_3.comp_type) {
      IP_PROTOCOLS_TCP  : parse_tcp;
      IP_PROTOCOLS_UDP  : parse_udp;
        default: accept;
      }
    }

    state parse_udp {
      pkt.extract(hdr.udp);
      transition accept;
    }

    state parse_tcp {
      pkt.extract(hdr.tcp);
      transition accept;
    }
}

/***************************************************************
****************  E G R E S S   D E P A R S E R  ***************
****************************************************************/
control SwitchEgressDeparser(
    packet_out pkt,
    inout switch_header_t hdr,
    in switch_egress_metadata_t eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr) {
        Checksum() ipv4_checksum;
        Mirror() mirror;
        apply {
            ///*
            if (eg_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_COMP_E2E ) {
                mirror.emit(eg_md.eg_mir_ses);
            }
            //*/
            /* // Mirror
            if (eg_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_COMP_E2E ) {
                mirror.emit<mirror_h>(eg_md.eg_mir_ses, {
                    eg_md.pkt_mirror_type});
            }
            */
            
      hdr.ipv4.hdr_checksum = ipv4_checksum.update({
          hdr.ipv4.version,
          hdr.ipv4.ihl,
          hdr.ipv4.diffserv,
          hdr.ipv4.total_len,
          hdr.ipv4.identification,
          hdr.ipv4.flags,
          hdr.ipv4.frag_offset,
          hdr.ipv4.ttl,
          hdr.ipv4.protocol,
          hdr.ipv4.src_addr,
          hdr.ipv4.dst_addr
        });
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
        pkt.emit(hdr.comp_0);
        pkt.emit(hdr.comp_1);
        pkt.emit(hdr.comp_2);
        pkt.emit(hdr.comp_3);
        pkt.emit(hdr.tcp);
        pkt.emit(hdr.udp);
    }
}
