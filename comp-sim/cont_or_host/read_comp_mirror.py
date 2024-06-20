#!/usr/bin/env python
from __future__ import print_function

import os
import sys
import pdb
import logging
import copy
import pprint
import time
sys.path.append("/usr/lib/python3/dist-packages")

SDE_INSTALL   = os.environ['SDE_INSTALL']
SDE_PYTHON_27 = os.path.join(SDE_INSTALL, 'lib', 'python2.7', 'site-packages')
SDE_PYTHON_38 = os.path.join(SDE_INSTALL, 'lib', 'python3.8', 'site-packages')
SDE_PYTHON_37 = os.path.join(SDE_INSTALL, 'lib', 'python3.7', 'site-packages')
sys.path.append(SDE_PYTHON_27)
sys.path.append(os.path.join(SDE_PYTHON_27, 'tofino'))
sys.path.append(SDE_PYTHON_38)
sys.path.append(os.path.join(SDE_PYTHON_38, 'tofino'))
sys.path.append(os.path.join(SDE_PYTHON_38, 'tofino/bfrt_grpc'))
sys.path.append(SDE_PYTHON_37)
sys.path.append(os.path.join(SDE_PYTHON_37, 'tofino'))
sys.path.append(os.path.join(SDE_PYTHON_37, 'tofino/bfrt_grpc'))
#pprint.pprint(sys.path)

import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as bfrt_client

#
# Connect to the BF Runtime Server
#    #grpc_addr = '0.0.0.0:50052',
notification = bfrt_client.Notifications(enable_learn=False)
interface = bfrt_client.ClientInterface(
    grpc_addr = '0.0.0.0:50052',
    client_id = 0,
    device_id = 0)
print('Connected to BF Runtime Server')

#
# Get the information about the running program
#
bfrt_info = interface.bfrt_info_get()
print('The target runs the program ', bfrt_info.p4_name_get())

#
# Establish that you are using this program on the given connection
#
#interface.bind_pipeline_config(bfrt_info.p4_name_get())
try:
    interface.bind_pipeline_config(bfrt_info.p4_name_get())
except bfrt_client.BfruntimeForwardingRpcException as bfruntime_error:
    print(bfruntime_error)
################### You can now use BFRT CLIENT ###########################
key_list = []
data_list = []
dev_tgt = bfrt_client.Target(device_id = 0, pipe_id=0xffff) #,pipe_id=0x0)

## see array pos
## check the value to run "bfshell and bfrt_python"
## memo : bfshell -> bfrt_python -> bfrt."name".pipe.SwitchIngress....
pos = 0
    
def look_tbl_all(tbl_name,dev_tgt, num):
    global bfrt_info
    global bfrt_client
    global pprint
    global pos
    #my_packet = {"packet_count": [], "packet_length": []}
    for i in range(num):
        reg = bfrt_info.table_get("pipe."+tbl_name)
        reg.operations_execute(dev_tgt, 'Sync')
        resp = reg.entry_get(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX", i)]
        )],{"from_hw":True})
        data,_ = next(resp)
        data_dict = data.to_dict()
        for tmp_name in data_dict.keys():
            if tbl_name in tmp_name:
                str_len = len(tbl_name)+1
                see_val = tmp_name[str_len:len(tmp_name)]
                see_k = tbl_name+"."+see_val
                val = data_dict[see_k][pos]
                #print("{}:[{}]".format(i, val), end=" ")
                #my_packet[see_val].append(val)
                print("[{}]".format(val), end=" ")
    """
    for tkey in my_packet.keys():
        print(tkey)
        for i in my_packet[tkey]:
            print(i, end=" ")
        print()
    """
    print()
def look_tbl(tbl_name,dev_tgt):
    global bfrt_info
    global bfrt_client
    reg = bfrt_info.table_get("pipe."+tbl_name)
    reg.operations_execute(dev_tgt, 'Sync')
    resp = reg.entry_get(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX",
                                            0)])],
                         {"from_hw":True})
    data,_ = next(resp)
    data_dict = data.to_dict()
    for tmp_name in data_dict.keys():
        if tbl_name in tmp_name:
            str_len = len(tbl_name)+1
            see_val = tmp_name[str_len:len(tmp_name)]
            see_k = tbl_name+"."+see_val
            val = data_dict[see_k][pos]
            print("{}.{}: {} ".format(tbl_name,see_val,
                                      val,
                                      end=" "))
            
def look_tbl_comp(tbl_name,dev_tgt):
    global bfrt_info
    global bfrt_client
    reg = bfrt_info.table_get("pipe."+tbl_name)
    reg.operations_execute(dev_tgt, 'Sync')
    resp = reg.entry_get(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX",
                                            0)])],
                         {"from_hw":True})
    data,_ = next(resp)
    data_dict = data.to_dict()
    for tmp_name in data_dict.keys():
        if tbl_name in tmp_name:
            str_len = len(tbl_name)+1
            see_val = tmp_name[str_len:len(tmp_name)]
            see_k = tbl_name+"."+see_val
            val = data_dict[see_k][0]
            print("{}.{}: {} ".format(tbl_name,see_val,
                                      val,
                                      end=" "))
def get_time(tbl_name,dev_tgt):
    global bfrt_info
    global bfrt_client
    reg = bfrt_info.table_get("pipe."+tbl_name)
    reg.operations_execute(dev_tgt, 'Sync')
    resp = reg.entry_get(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX",
                                            0)])],
                         {"from_hw":True})
    data,_ = next(resp)
    data_dict = data.to_dict()
    return_val = -1
    for tmp_name in data_dict.keys():
        if tbl_name in tmp_name:
            str_len = len(tbl_name)+1
            see_val = tmp_name[str_len:len(tmp_name)]
            see_k = tbl_name+"."+see_val
            val = data_dict[see_k][0]
            return_val = val
            
    return return_val

def del_tbl(tbl_name,dev_tgt):
    global bfrt_info
    global bfrt_client
    reg = bfrt_info.table_get("pipe."+tbl_name)
    reg.operations_execute(dev_tgt, 'Sync')
    resp = reg.entry_mod(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX",
                                            0)])])

def cms_get(tbl_name,dev_tgt, num, t, cmsnum):
    global bfrt_info
    global bfrt_client
    global pprint
    #out_filename = "./p4src/miura/cms/res/cms"+str(cmsnum)+"/t"+str(t)+".txt"
    out_filename = "./res/cms"+str(cmsnum)+"/t"+str(t)+".txt"
    with open(out_filename,"w") as f:
        for i in range(num):        
            reg = bfrt_info.table_get("pipe."+tbl_name)
            reg.operations_execute(dev_tgt, 'Sync')
            resp = reg.entry_get(dev_tgt,
                [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX", i)]
                )],{"from_hw":True})
            data,_ = next(resp)
            data_dict = data.to_dict()
            for tmp_name in data_dict.keys():
                if tbl_name in tmp_name:
                    str_len = len(tbl_name)+1
                    see_val = tmp_name[str_len:len(tmp_name)]
                    see_k = tbl_name+"."+see_val
                    val = data_dict[see_k][0]
                    #print("{}:[{}]".format(i, val), end=" ")
                    #my_packet[see_val].append(val)
                    tmp_res = "{} ".format(val)
                    f.write(tmp_res)
            
            
time_step = 0
pre_time = -1
all_timestep = []
all_data = []
def com_name(func1, reg_name):
    return "SwitchIngress."+func1+"."+reg_name

#bfrt.switch_tofino2_y1.pipe.SwitchIngress.comp.ipv4_exact.entry_with_set_port(valid=1,port=9).push()

"""
swi = "switch_tofino2_y1"
func1 = "comp"
func2 = "comp"

script = "bfrt."+swi+".pipe.SwitchEgress."+func2+".mirror_fwd.entry_with_set_md(valid=1,eg_ses=28).push()"
eval(script)
"""

bfrt.switch_tofino2_y1.pipe.SwitchIngress.comp.ipv4_set_port.entry_with_set_port(valid=1,port=9).push()
bfrt.switch_tofino2_y1.pipe.SwitchEgress.comp.mirror_fwd.entry_with_set_md(
    valid=1,
    eg_ses=28).push()

bfrt.mirror.cfg.entry_with_normal(sid=28, direction="EGRESS", session_enable=True, ucast_egress_port=2, ucast_egress_port_valid=1).push()


while True:
    print("------ ====================================== -------")
    #bname = "bfrt.p4_main.pipe.SwitchIngress"
    bname = "bfrt.p4_main.pipe.SwitchIngress"
    func1 = "comp"
    time.sleep(1)
    # tbl_name = com_name(func1, "debug")
    # now_time = get_time(tbl_name, dev_tgt)
    # print("debug", end=" ")
    # look_tbl_all(tbl_name, dev_tgt, 2)
    
    tbl_name = com_name(func1, "packet_count")
    now_time = get_time(tbl_name, dev_tgt)
    print("p_count", end=" ")
    look_tbl_all(tbl_name, dev_tgt, 2)

    print("------ =========== Info-0 =========== -------")
    tbl_name = com_name(func1, "src_addr_0")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_addr", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "dst_addr_0")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_addr", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "src_port_0")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_port", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "dst_port_0")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_port", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "protocol_0")
    now_time = get_time(tbl_name, dev_tgt)
    print("protocol", end=" ")
    look_tbl(tbl_name, dev_tgt)
    

    print("------ =========== Info-1 =========== -------")
    tbl_name = com_name(func1, "src_addr_1")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_addr", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "dst_addr_1")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_addr", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "src_port_1")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_port", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "dst_port_1")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_port", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "protocol_1")
    now_time = get_time(tbl_name, dev_tgt)
    print("protocol", end=" ")
    look_tbl(tbl_name, dev_tgt)
    

    print("------ =========== Info-2 =========== -------")
    tbl_name = com_name(func1, "src_addr_2")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_addr", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "dst_addr_2")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_addr", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "src_port_2")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_port", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "dst_port_2")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_port", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "protocol_2")
    now_time = get_time(tbl_name, dev_tgt)
    print("protocol", end=" ")
    look_tbl(tbl_name, dev_tgt)
    

    print("------ =========== Info-3 =========== -------")
    tbl_name = com_name(func1, "src_addr_3")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_addr", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "dst_addr_3")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_addr", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "src_port_3")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_port", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "dst_port_3")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_port", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    tbl_name = com_name(func1, "protocol_3")
    now_time = get_time(tbl_name, dev_tgt)
    print("protocol", end=" ")
    look_tbl(tbl_name, dev_tgt)
    
    """
    tbl_name = com_name(func1, "info_src_addr")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_addr", end=" ")
    look_tbl_all(tbl_name, dev_tgt, 4)
    
    tbl_name = com_name(func1, "info_dst_addr")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_addr", end=" ")
    look_tbl_all(tbl_name, dev_tgt, 4)
    
    tbl_name = com_name(func1, "info_src_port")
    now_time = get_time(tbl_name, dev_tgt)
    print("src_port", end=" ")
    look_tbl_all(tbl_name, dev_tgt, 4)
    
    tbl_name = com_name(func1, "info_dst_port")
    now_time = get_time(tbl_name, dev_tgt)
    print("dst_port", end=" ")
    look_tbl_all(tbl_name, dev_tgt, 4)
    
    tbl_name = com_name(func1, "info_protocol")
    now_time = get_time(tbl_name, dev_tgt)
    print("protocol", end=" ")
    look_tbl_all(tbl_name, dev_tgt, 4)
    """
    #time.sleep(1)
    #tbl_name = com_name(func1, "next_report_miri")
    #look_tbl(tbl_name,dev_tgt)
    
    #tbl_name = com_name(func1, "check_value")
    #look_tbl_all(tbl_name,dev_tgt, 10)
    
    #queue_size = 30
    #tbl_name = com_name(func1, "src_ip_queue")
    #look_tbl_all(tbl_name,dev_tgt,queue_size)
    
    #tbl_name = com_name(func1, "arrival_miri")
    #look_tbl(tbl_name,dev_tgt)
    
    #tbl_name = com_name(func1, "next_report_miri")
    #look_tbl(tbl_name,dev_tgt)
    #now_time = get_time(tbl_name, dev_tgt)
    
############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")
