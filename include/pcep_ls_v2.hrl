
-include("pcep_protocol.hrl").
%% open message tlvs
-record(open_object_tlv_ls_cap_tlv_type, {
  ls_cap_tlv_type::integer(),%%16bits
  ls_cap_tlv_len::integer(),%%16bits
  ls_cap_tlv_flag::integer(),%%31bits
  ls_cap_tlv_r::boolean()%%1bit
}).

-type open_object_tlv_ls_cap_tlv_type()::#open_object_tlv_ls_cap_tlv_type{}.

-record(routing_universe_tlv,{
  routing_universe_tlv_type::integer(),
  routing_universe_tlv_len::integer(),
  routing_universe_tlv_identifier::integer()
}).

-type routing_universe_tlv()::#routing_universe_tlv{}.

-record(local_node_descriptor_tlv,{
  local_node_descriptor_tlv_type::integer(),
  local_node_descriptor_tlv_len::integer(),
  local_node_descriptor_tlv_sub_tlv::integer()
}).

-type local_node_descriptor_tlv()::#local_node_descriptor_tlv{}.

-record(remote_node_descriptor_tlv,{
  remote_node_descriptor_tlv_type::integer(),
  remote_node_descriptor_tlv_len::integer(),
  remote_node_descriptor_tlv_sub_tlv::integer()
}).

-type remote_node_descriptor_tlv()::#remote_node_descriptor_tlv{}.

-record(node_descriptors_tlv,{
  node_descriptors_tlv_type::integer(),
  node_descriptors_tlv_len::integer(),
  node_descriptors_tlv_sub_tlv::integer()
}).

-type node_descriptors_tlv()::#node_descriptors_tlv{}.

-record(link_descriptors_tlv,{
  link_descriptors_tlv_type::integer(),
  link_descriptors_tlv_len::integer(),
  link_descriptors_tlv_sub_tlv::integer()
}).

-type link_descriptors_tlv()::#link_descriptors_tlv{}.

-record(node_attributes_tlv,{
  node_attributes_tlv_type::integer(),
  node_attributes_tlv_len::integer(),
  node_attributes_tlv_sub_tlv::integer()
}).

-type node_attributes_tlv()::#node_attributes_tlv{}.

-record(link_attributes_tlv,{
  link_attributes_tlv_type::integer(),
  link_attributes_tlv_len::integer(),
  link_attributes_tlv_sub_tlv::integer()
}).

-type link_attributes_tlv()::#link_attributes_tlv{}.

-record(ls_object,{
  ls_object_protocol_id::integer(),%%8bits
  ls_object_flag::integer(),%%22bits
  ls_object_r::boolean(),
  ls_object_s::boolean(),
  ls_object_ls_id::integer(),
  body
}).

-type ls_object()::#ls_object{}.

%% -record(ls_rpt_msg,{
%%   ls_rpt_msg_header::pcep_object_message(),
%%   ls_rpt_msg_object::ls_object()
%% }).
%%
%% -type ls_rpt_msg()::#ls_rpt_msg{}.