%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 三月 2016 15:40
%%%-------------------------------------------------------------------
-author("Xinfeng").

-record(ero_object,{
  ero_subobjects::list()
}).

-type ero_object()::#ero_object{}.

-record(ero_ipv4_subobject,{
  ero_ipv4_subobject_l::boolean(),
  ero_ipv4_subobject_type = 1::integer(),
  ero_ipv4_subobject_length::integer(),
  ero_ipv4_subobject_ipv4_add::integer(),
  ero_ipv4_subobject_prefix_len::integer(),
  ero_ipv4_subobject_resvd::integer()
}).

-type ero_ipv4_subobject()::#ero_ipv4_subobject{}.

%% -record(ero_ipv6_subobject,{
%%   ero_ipv6_subobject_l::boolean(),
%%   ero_ipv6_subobject_type = 2::integer(),
%%   ero_ipv6_subobject_length::integer(),
%%   ero_ipv6_subobject_ipv4_add::integer(),
%%   ero_ipv6_subobject_prefix_len::integer(),
%%   ero_ipv6_subobject_resvd::integer()
%% }).

%% -type ero_ipv6_subobject()::#ero_ipv6_subobject{}.

-record(ero_auto_sys_num_subobject,{
  ero_auto_sys_num_subobject_l::boolean(),
  ero_auto_sys_num_subobject_type = 3::integer(),
  ero_auto_sys_num_subobject_length::integer(),
  ero_auto_sys_num_subobject_as_num::integer() %% TODO 2-octet
}).

-type ero_auto_sys_num_subobject()::#ero_auto_sys_num_subobject{}.

-record(ero_pathkey_subobject,{
  ero_pathkey_subobject_l::boolean(),
  ero_pathkey_subobject_type = 4::integer(),
  ero_pathkey_subobject_length::integer(),
  ero_pathkey_subobject_path_key::integer(),
  ero_pathkey_subobject_pce_id::integer()
}).

-type ero_pathkey_subobject()::#ero_pathkey_subobject{}.

-record(ero_sr_ero_subobject,{
  ero_sr_ero_subobject_l::boolean(),
  ero_sr_ero_subobject_type = 5::integer(),
  ero_sr_ero_subobject_length::integer(),
  ero_sr_ero_subobject_st::integer(),
  ero_sr_ero_subobject_flags::integer(),
  ero_sr_ero_subobject_f::boolean(),
  ero_sr_ero_subobject_s::boolean(),
  ero_sr_ero_subobject_c::boolean(),
  ero_sr_ero_subobject_m::boolean(),
  ero_sr_ero_subobject_sid::integer(),
  ero_sr_ero_subobject_nai::list()
}).

-type ero_sr_ero_subobject()::#ero_sr_ero_subobject{}.

-record(label_object,{
  label_object_res::integer(),
  label_object_flags::integer(),
  label_object_o::boolean(),
  label_object_label::integer(),
  tlvs::list()
}).

-type label_object()::#label_object{}.

-record(next_hop_ipv4_add_tlv,{
  next_hop_ipv4_add_tlv_type :: integer(),
  next_hop_ipv4_add_tlv_length :: integer(),
  nexthop_IPv4_add::integer()
}).

-type next_hop_ipv4_add_tlv()::#next_hop_ipv4_add_tlv{}.

-record(next_hop_unnumbered_ipv4_id_tlv,{
  next_hop_unnumbered_ipv4_id_tlv_type :: integer(),
  next_hop_unnumbered_ipv4_id_tlv_length :: integer(),
  node_id::integer(),
  inferface_id::integer()
}).

-type next_hop_unnumbered_ipv4_id_tlv()::#next_hop_unnumbered_ipv4_id_tlv{}.

-record(fec_ipv4_object,{
  ipv4_node_id::integer()
}).

-type fec_ipv4_object()::#fec_ipv4_object{}.

%% -record(fec_ipv6_object,{
%%   ipv6_node_id::integer()
%% }).
%%
%% -type fec_ipv6_object()::#fec_ipv6_object{}.

-record(fec_ipv4_adjacency_object,{
  local_ipv4_add::integer(),
  remote_ipv4_add::integer()
}).

-type fec_ipv4_adjacency_object()::#fec_ipv4_adjacency_object{}.
%%
%% -record(fec_ipv6_adjacency_object,{
%%   local_ipv6_add::integer(),
%%   remote_ipv6_add::integer()
%% }).
%%
%% -type fec_ipv6_adjacency_object()::#fec_ipv6_adjacency_object{}.

-record(label_range_object,{
  label_type::integer(),
  range_size::integer(),
  label_base::integer(),
  tlvs::list()
}).

-type label_range_object()::#label_range_object{}.

-record(pcep_subobject,{

}).