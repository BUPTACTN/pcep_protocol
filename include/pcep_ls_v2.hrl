
%%-include("pcep_protocol.hrl").
%% open message tlvs
-record(ls_cap_tlv, {
  ls_cap_tlv_type :: integer(),
  ls_cap_tlv_length :: integer(),
  ls_cap_tlv_flag = <<0:31>> ::integer(),%%31bits
  ls_cap_tlv_r = true ::boolean()%%1bit
}).

-type ls_cap_tlv()::#ls_cap_tlv{}.

%% -record(routing_universe_tlv_value,{
%%   routing_universe_tlv_identifier::integer()
%% }).
%%
%% -type routing_universe_tlv_value()::#routing_universe_tlv_value{}.
%%
%% -record(local_node_descriptor_tlv_value,{
%%   local_node_descriptor_tlv_sub_tlv::integer()
%% }).
%%
%% -type local_node_descriptor_tlv_value()::#local_node_descriptor_tlv_value{}.
%%
%% -record(remote_node_descriptor_tlv_value,{
%%   remote_node_descriptor_tlv_sub_tlv::integer()
%% }).
%%
%% -type remote_node_descriptor_tlv_value()::#remote_node_descriptor_tlv_value{}.
%%
%% -record(node_descriptors_tlv_value,{
%%   node_descriptors_tlv_sub_tlv::integer()
%% }).
%%
%% -type node_descriptors_tlv_value()::#node_descriptors_tlv_value{}.
%%
%% -record(link_descriptors_tlv_value,{
%%   link_descriptors_tlv_sub_tlv::integer()
%% }).
%%
%% -type link_descriptors_tlv_value()::#link_descriptors_tlv_value{}.
%%
%% -record(node_attributes_tlv_value,{
%%   node_attributes_tlv_sub_tlv::integer()
%% }).
%%
%% -type node_attributes_tlv_value()::#node_attributes_tlv_value{}.
%%
%% -record(link_attributes_tlv_value,{
%%   link_attributes_tlv_sub_tlv::integer()
%% }).
%%
%% -type link_attributes_tlv_value()::#link_attributes_tlv_value{}.

-record(ls_link_object,{
  ls_object_protocol_id::integer(),%%8bits
  ls_object_flag::integer(),%%22bits
  ls_object_r::boolean(),
  ls_object_s::boolean(),
  ls_object_ls_id::integer(),
  ls_object_tlv :: optical_link_attribute_tlv()
}).

-type ls_link_object()::#ls_link_object{}.

-record(ls_node_object,{
  ls_object_protocol_id::integer(),%%8bits
  ls_object_flag::integer(),%%22bits
  ls_object_r::boolean(),
  ls_object_s::boolean(),
  ls_object_ls_id::integer(),
  ls_node_object_tlv :: optical_node_attribute_tlv()
}).

-type ls_node_object() :: #ls_node_object{}.

-record(optical_node_attribute_tlv,{
  optical_node_attribute_tlv_type :: integer(),
  optical_node_attribute_tlv_length :: integer(),
  node_pre ::integer(),
  node_ip :: integer(),
  res_bytes :: integer()
}).

-type optical_node_attribute_tlv() :: #optical_node_attribute_tlv{}.

-record(ls_object_tlvs,{
  actn_link_tlv :: optical_link_attribute_tlv(),
  link_descriptor_tlv :: link_descriptors_tlv()
}).

-type ls_object_tlvs() :: #ls_object_tlvs{}.

-record(link_id_sub_tlv, {
  link_id_sub_tlv_type :: integer(),
  link_id_sub_tlv_length :: integer(),
  link_id :: integer()
}).

-type link_id_sub_tlv() :: #link_id_sub_tlv{}.

-record(local_interface_ip_address_sub_tlv, {
  local_interface_ip_address_sub_tlv_type::integer(),
  local_interface_ip_address_sub_tlv_length :: integer(),
  local_interface_address :: integer()
}).

-type local_interface_ip_address_sub_tlv() :: #local_interface_ip_address_sub_tlv{}.

-record(remote_interface_ip_address_sub_tlv, {
  remote_interface_ip_address_sub_tlv_type :: integer(),
  remote_interface_ip_address_sub_tlv_length :: integer(),
  remote_interface_address :: integer()
}).

-type remote_interface_ip_address_sub_tlv() :: #remote_interface_ip_address_sub_tlv{}.

-record(te_metric_sub_tlv, {
  te_metric_sub_tlv_type :: integer(),
  te_metric_sub_tlv_length :: integer(),
  te_link_metric :: integer()
}).

-type te_metric_sub_tlv() :: #te_metric_sub_tlv{}.

-record(interface_switching_capability_descriptor_sub_tlv, {
  interface_switching_capability_descriptor_sub_tlv_type::integer(),
  interface_switching_capability_descriptor_sub_tlv_length :: integer(),
  switching_cap = 150 :: integer(),
  encoding = 8 :: integer(),
  reserved :: integer(),
  priority_0 :: integer(),
  priority_1 :: integer(),
  priority_2 :: integer(),
  priority_3 :: integer(),
  priority_4 :: integer(),
  priority_5 :: integer(),
  priority_6 :: integer(),
  priority_7 :: integer()
}).

-type interface_switching_capability_descriptor_sub_tlv() ::
#interface_switching_capability_descriptor_sub_tlv{}.

-record(shared_risk_link_group_sub_tlv, {
  shared_risk_link_group_sub_tlv_type :: integer(),
  shared_risk_link_group_sub_tlv_length :: integer(),
  shared_risk_link_group_value :: integer()
}).

-type shared_risk_link_group_sub_tlv() :: #shared_risk_link_group_sub_tlv{}.

-record(port_label_restrictions_sub_tlv, {
  %% TODO how to finished it?
  port_label_restrictions_sub_tlv_type :: integer(),
  port_label_restrictions_sub_tlv_length :: integer(),
  matrix_ID ::integer(),
  res_type :: integer(),
  switching_cap :: integer(),
  encoding :: integer(),
  additional_res :: any()
}).

-type port_label_restrictions_sub_tlv_value() :: #port_label_restrictions_sub_tlv{}.

-record(available_labels_field_sub_tlv,{
  available_labels_field_sub_tlv_type :: integer(),
  available_labels_field_sub_tlv_length :: integer(),
  pri :: integer(),
  res :: integer(),
  label_set_field ::integer()
}).

-type available_labels_field_sub_tlv() :: #available_labels_field_sub_tlv{}.

-record(ipv4_interface_address_sub_tlv, {
  ipv4_interface_address_sub_tlv_type :: integer(),
  ipv4_interface_address_sub_tlv_length :: integer(),
  ipv4_interface_address :: integer()
}).

-type ipv4_interface_address_sub_tlv() :: #ipv4_interface_address_sub_tlv{}.

-record(ipv4_neighbor_address_sub_tlv, {
  ipv4_neighbor_address_sub_tlv_type :: integer(),
  ipv4_neighbor_address_sub_tlv_length :: integer(),
  ipv4_neighbor_address :: integer()
}).

-type ipv4_neighbor_address_sub_tlv() :: #ipv4_neighbor_address_sub_tlv{}.

-record(link_type_sub_tlv, {
  link_type_sub_tlv_type :: integer(),
  link_type_sub_tlv_length :: integer(),
  link_type = 16777216 :: integer()   %% high 8bits are linc type,taking 1,low 24bits are 0.
}).

-type link_type_sub_tlv() :: #link_type_sub_tlv{}.

-record(ipv4_router_id_of_local_node_sub_tlv, {
  ipv4_router_id_of_local_node_sub_tlv_type :: integer(),
  ipv4_router_id_of_local_node_sub_tlv_length :: integer(),
  ipv4_router_id_of_local_node :: integer()
}).

-type ipv4_router_id_of_local_node_sub_tlv() :: #ipv4_router_id_of_local_node_sub_tlv{}.

-record(optical_link_attribute_tlv,{
  optical_link_attribute_tlv_type :: integer(),
  optical_link_attribute_tlv_length :: integer(),
  link_type_sub_tlv_body :: any(),
  res_bytes :: integer(),
  link_id_sub_tlv_body :: any(),
  local_interface_ip_add_sub_tlv_body :: any(),
  remote_interface_ip_add_sub_tlv_body :: any(),
  te_metric_body :: any(),
  interface_switching_cap_des_sub_tlv_body :: any(),
  shared_risk_link_group_sub_tlv_body :: any(),
  port_label_res_sub_tlv_body ::any(),
available_labels_field_sub_tlv_body :: any()
}).

-type optical_link_attribute_tlv() :: #optical_link_attribute_tlv{}.

-record(link_descriptors_tlv,{
  link_descriptors_tlv_type ::integer(),
  link_descriptors_tlv_length :: integer(),
  ipv4_interface_add_sub_tlv_body :: any(),
  ipv4_neighbor_add_sub_tlv_body :: any()
}).

-type link_descriptors_tlv() :: #link_descriptors_tlv{}.

-record(node_attributes_tlv,{
  node_attributes_tlv_type :: integer(),
  node_attributes_tlv_length :: integer(),
  ipv4_router_id_of_local_Node_sub_tlv_body :: any()
}).

-type node_attributes_tlv() :: #node_attributes_tlv{}.
%% -record(ls_rpt_msg,{
%%   ls_rpt_msg_header::pcep_object_message(),
%%   ls_rpt_msg_object::ls_object()
%% }).
%%
%% -type ls_rpt_msg()::#ls_rpt_msg{}.