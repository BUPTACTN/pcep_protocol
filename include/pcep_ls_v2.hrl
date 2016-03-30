
%%-include("pcep_protocol.hrl").
%% open message tlvs
-record(ls_cap_tlv_value, {
  ls_cap_tlv_flag = <<0:31>> ::integer(),%%31bits
  ls_cap_tlv_r = true ::boolean()%%1bit
}).

-type ls_cap_tlv_value()::#ls_cap_tlv_value{}.

-record(routing_universe_tlv_value,{
  routing_universe_tlv_identifier::integer()
}).

-type routing_universe_tlv_value()::#routing_universe_tlv_value{}.

-record(local_node_descriptor_tlv_value,{
  local_node_descriptor_tlv_sub_tlv::integer()
}).

-type local_node_descriptor_tlv_value()::#local_node_descriptor_tlv_value{}.

-record(remote_node_descriptor_tlv_value,{
  remote_node_descriptor_tlv_sub_tlv::integer()
}).

-type remote_node_descriptor_tlv_value()::#remote_node_descriptor_tlv_value{}.

-record(node_descriptors_tlv_value,{
  node_descriptors_tlv_sub_tlv::integer()
}).

-type node_descriptors_tlv_value()::#node_descriptors_tlv_value{}.

-record(link_descriptors_tlv_value,{
  link_descriptors_tlv_sub_tlv::integer()
}).

-type link_descriptors_tlv_value()::#link_descriptors_tlv_value{}.

-record(node_attributes_tlv_value,{
  node_attributes_tlv_sub_tlv::integer()
}).

-type node_attributes_tlv_value()::#node_attributes_tlv_value{}.

-record(link_attributes_tlv_value,{
  link_attributes_tlv_sub_tlv::integer()
}).

-type link_attributes_tlv_value()::#link_attributes_tlv_value{}.

-record(ls_object,{
  ls_object_protocol_id::integer(),%%8bits
  ls_object_flag::integer(),%%22bits
  ls_object_r::boolean(),
  ls_object_s::boolean(),
  ls_object_ls_id::integer(),
  tlvs
}).

-type ls_object()::#ls_object{}.

%% -record(ls_rpt_msg,{
%%   ls_rpt_msg_header::pcep_object_message(),
%%   ls_rpt_msg_object::ls_object()
%% }).
%%
%% -type ls_rpt_msg()::#ls_rpt_msg{}.