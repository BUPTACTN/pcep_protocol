%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 三月 2016 下午10:04
%%%-------------------------------------------------------------------
-module(pcep_v1_encode).
-author("root").

-include("pcep_protocol.hrl").
-include("pcep_v1.hrl").
%% -include("pcep_ls_v2.hrl").
-include("pcep_logger.hrl").
%% -include("pcep_stateful_pce_v2.hrl").

%% API
-export([do/1]).
%% -export([encode_tlv/1]).
%% -export([encode_tlvs/1]).
%% -export([encode_object_msg/1]).
%% -export([encode_object_body/2]).
%% -export([encode_objects/1]).
%%-export([encode_rro_object_body/3]).

%%-spec encode_objects(list()) ->binary().

%% encode_objects([#pcep_object_message{} = Object | H]) ->
%%   H2 = encode_objects(H),
%%   H3 = encode_object_msg(Object),
%%   <<H3/bytes,H2/bytes>>;
%% encode_objects([]) ->
%%   <<>>.

%% encode pcep_message -------------------------------------------------------------------
-spec do(Message ::pcep_message()) ->binary().
do(#pcep_message{version = ?VERSION, flags=Flags, message_type=MessageType,message_length=MessageLength, body=Body}=_Msg) ->
%%   when MessageLength =:= erlang:byte_size(msg) ->
%%   io:format("do start11111111111~n"),
%%   BodyBin = encode_objects(Body),  %% one msg can include many objects
  BodyBin = encode_object_msg(Body),
%%   io:format("BodyBin in do is ~p~n",[BodyBin]),
%%   MessageLength = ?PCEP_OBJECT_MESSAGE_HEADER_SIZE + byte_size(BodyBin),
  list_to_binary([<<?VERSION:3, Flags:5, MessageType:8, MessageLength:16>>, BodyBin]).
%% do(#pcep_message{message_length=MessageLength}=msg)
%%   when MessageLength /= erlang:byte_size(msg) ->
%%   ?ERROR("message length doesn't math the field message_length"),
%%   <<>>.


%% encode tlvs' list -------------------------------------------------------------------
%% encode subobject
-spec encode_subobject(Subobject::subobject()) -> binary().
encode_subobject(#subobject{subobject_type = Type,subobject_length = Length,subobject_value = Value}) ->
  case Type of
    1 -> #ipv4_subobject{ipv4_subobject_add = Ipv4_add,
    ipv4_subobject_prefix_len = Ipv4_prefix_len,
    ipv4_subobject_flags = Ipv4_flags} = Value,
      Value_1 = << <<Value1/bytes>> || Value1 <- [<<Ipv4_add:32,Ipv4_prefix_len:8,Ipv4_flags:8>>]>>,
      erlang:list_to_binary([<<Type:8, Length:8>>, Value_1]);
%%     2 -> #ipv6_subobject_value{ipv6_subobject_add = Ipv6_add,
%%     ipv6_subobject_prefix_len = Ipv6_prefix_len,
%%     ipv6_subobject_flags = Ipv6_flags} = Value,
%%       Value_2 = << <<Value2/bytes>> || Value2 <- [<<Ipv6_add:128,Ipv6_prefix_len:8,Ipv6_flags:8>>]>>,
%%       erlang:list_to_binary([<<Type:8, Length:8>>, Value_2]);
    3 -> #label_subobject{label_subobject_flags =Label_flags,
    label_subobject_c_type = Label_c_type,
    label_subobject_contents = Label_contents} = Value,
      Value_3 = << <<Value3/bytes>> || Value3 <- [<<Label_flags:8,Label_c_type:8,Label_contents:32>>]>>,
      erlang:list_to_binary([<<Type:8, Length:8>>, Value_3]);
    _ ->
      ?ERROR("Other Subobject Type,but cannot be recognized")
  end.


%% LS Report SubTlvs encoded
%% encode_sub_tlvs([#tlv{}=Sub_Tlv | T]) ->
%%   T4 = encode_sub_tlvs(T),
%%   T5 = encode_sub_tlv(Sub_Tlv),
%%   <<T4/bytes,T5/bytes>>;
%% encode_sub_tlvs([]) ->
%%   <<>>.
%% LS-Report Msg Sub_TLV
%% encode_sub_tlv(#tlv{type=Type,length = Length,value = Value}) ->
%% -spec encode_tlvs(list()) ->binary().
%% encode_tlvs([#tlv{}=Tlv | T]) ->
%%   T2 = encode_tlvs(T),
%%   T3 = encode_tlv(Tlv),
%%   <<T3/bytes, T2/bytes>>;
%% encode_tlvs([]) ->
%%   <<>>.


%% encode_tlv
%% -spce encode_sub_tlv(ObjectType::integer(),Sub_Tlv::sub_tlv()) -> binary().
%% encode_sub_tlv(ObjectType,#sub_tlv{sub_type = Sub_type, sub_length = Sub_length, sub_value = Sub_value}) ->
%%   St = ?SubTLV_Type(ObjectType,Sub_type),
%%   case St of
%%     link_type ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>;
%%     link_id ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>;
%%     local_interface_IP_add ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>;
%%     remote_interface_IP_add ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>;
%%     te_metric ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>;
%%     interface_switching_cap_descriptor ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>;
%%     shared_risk_link_group ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>;
%%     port_label_restriction ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>;
%%     node_IPv4_local_add ->
%%       <<Sub_type:16,Sub_length:16,Sub_value/bytes>>
%%   end,
%% TODO ERROR, tlv !!!
%% -spec encode_tlv() -> binary().

encode_tlv1(#gmpls_cap_tlv{
%%   gmpls_cap_tlv_type = Type,gmpls_cap_tlv_length = Length,
  gmpls_cap_flag = Gmpls_cap_flag}) ->
%%   io:format("encode gmpls_cap_tlv start~n"),
  Type = 14,
  Length = 4,
  <<Type:16,Length:16,Gmpls_cap_flag:32>>.
encode_tlv2(#stateful_pec_cap_tlv{
%%   stateful_pec_cap_tlv_type = Type,stateful_pec_cap_tlv_length = Length,
  stateful_pce_cap_tlv_flag = Stateful_pce_flag, stateful_pce_cap_tlv_d = State_pce_d,
  stateful_pce_cap_tlv_t = State_pce_t, stateful_pce_cap_tlv_i = State_pce_i, stateful_pce_cap_tlv_s = State_pce_s,
  stateful_pce_cap_tlv_u = State_pce_u}) ->
%%   io:format("encode stateful_pce_cap_tlv start~n"),
  Type = 16,
  Length =4,
  <<Type:16,Length:16,Stateful_pce_flag:27,State_pce_d:1,State_pce_t:1,State_pce_i:1,State_pce_s:1,State_pce_u:1>>.
encode_tlv3(#pcecc_cap_tlv{
%%   pcecc_cap_tlv_type = Type,pcecc_cap_tlv_length = Length,
  pcecc_cap_tlv_flag = Pcecc_flag, pcecc_cap_tlv_g = Pcecc_g, pcecc_cap_tlv_l = Pcecc_l}) ->
  Type = 32,
  Length = 4,
  <<Type:16,Length:16,Pcecc_flag:30,Pcecc_g:1,Pcecc_l:1>>.
encode_tlv4(#lsp_db_version_tlv{
%%   lsp_db_version_tlv_type = Type,lsp_db_version_tlv_length = Length,
  lsp_db_version_tlv_ver = Lsp_db_version}) ->
  Type = 23,
  Length = 8,
  <<Type:16,Length:16,Lsp_db_version:64>>.
encode_tlv5(#ted_cap_tlv{
%%   ted_cap_tlv_type = Type,ted_cap_tlv_length = Length,
  ted_cap_tlv_flag = Ted_flag, ted_cap_tlv_r = Ted_r}) ->
  Type = 132,
  Length = 4,
  <<Type:16,Length:16,Ted_flag:31,Ted_r:1>>.
encode_tlv6(#label_db_version_tlv{
%%   label_db_version_tlv_type = Type,label_db_version_tlv_length = Length,
  label_db_version_tlv_ver = Label_db_version}) ->
  Type = 23,
  Length = 8,
  <<Type:16,Length:8,Label_db_version:64>>.
encode_tlv7(#symbolic_path_name_tlv{
%%   symbolic_path_name_tlv_type = Type,symbolic_path_name_tlv_length = Length,
  symbolic_path_name = Symbolic_path_name}) ->
  Type = 17,
  Length = 4,  %% TODO ???
  <<Type:16,Length:16,Symbolic_path_name/bytes>>.
encode_tlv8(#ipv4_lsp_identifiers_tlv{
%%   ipv4_lsp_identifiers_tlv_type = Type,ipv4_lsp_identifiers_tlv_length = Length,
  ipv4_lsp_identifiers_tlv_tunnel_sender_add = Ipv4_lsp_tunnel_sender_add,
ipv4_lsp_identifiers_tlv_lsp_id = Ipv4_lsp_lsp_id,ipv4_lsp_identifiers_tlv_tunnel_id = Ipv4_lsp_tunnel_id,
  ipv4_lsp_identifiers_tlv_exrended_tunnel_id = Ipv4_exrended_tunnel_id,
  ipv4_lsp_identifiers_tlv_tunnel_endpoint_add = Ipv4_lsp_tunnel_endpoint_add}) ->
  Type = 18,
  Length = 16,
  <<Type:16,Length:16,Ipv4_lsp_tunnel_sender_add:32,Ipv4_lsp_lsp_id:16,Ipv4_lsp_tunnel_id:16,Ipv4_exrended_tunnel_id:32,Ipv4_lsp_tunnel_endpoint_add:32>>.
encode_tlv9(#lsp_error_code_tlv{
%%   lsp_error_code_tlv_type = Type,lsp_error_code_tlv_length = Length,
  lsp_error_code = Lsp_error_code}) ->
  Type = 20,
  Length = 4,
  <<Type:16,Length:16,Lsp_error_code:32>>.
encode_tlv10(#rsvp_error_spec_tlv{
%%   rsvp_error_spec_tlv_type = Type,rsvp_error_spec_tlv_length = Length,
  rsvp_error_spec_tlv_body1 = SVP_ERROR_SPEC_object,rsvp_error_spec_tlv_body2 = User_error_spec_object}) ->
  %% TODO after two objects finished
  <<SVP_ERROR_SPEC_object/bytes,User_error_spec_object/bytes>>.
encode_tlv11(#next_hop_unnumbered_ipv4_id_tlv{
%%   next_hop_unnumbered_ipv4_id_tlv_type = Type,next_hop_unnumbered_ipv4_id_tlv_length = Length,
  node_id = Node_id,inferface_id = Interface_id}) ->
  Type = 1,
  Length = 8,  %%  onos defines Length as header+value, namely 12.
  <<Type:16,Length:16,Node_id:32/bytes,Interface_id:32/bytes>>.
encode_tlv12(#ls_cap_tlv{
%%   ls_cap_tlv_type = Type,ls_cap_tlv_length = Length,
  ls_cap_tlv_flag = Ls_cap_flag, ls_cap_tlv_r = Ls_r}) ->
  Type = 10003,
  Length = 4,
  <<Type:16,Length:16,Ls_cap_flag:31,Ls_r:1>>.
encode_tlv13(#optical_link_attribute_tlv{
%%   optical_link_attribute_tlv_type = Type,optical_link_attribute_tlv_length = Length,
  link_type_sub_tlv_body = Link_type,
  link_id_sub_tlv_body = Link_id, local_interface_ip_add_sub_tlv_body = Local_interface_ip_add,
  remote_interface_ip_add_sub_tlv_body = Remote_interface_ip_add,te_metric_body = Te_metric,
  interface_switching_cap_des_sub_tlv_body = Interface_switching_cap_des,
%%   shared_risk_link_group_sub_tlv_body = Shared_risk_link_group,
  port_label_res_sub_tlv_body = Port_label_res,available_labels_field_sub_tlv_body = Available_labels_field}) ->
  io:format("encode_actn_link_tlv start~n"),
  ValueBin1 = encode_sub_tlv10(Link_type),
  io:format("Link_type is ~p~n",[ValueBin1]),
  ValueBin2 = encode_sub_tlv1(Link_id),
  io:format("Link_id is ~p~n",[ValueBin2]),
  ValueBin3 = encode_sub_tlv2(Local_interface_ip_add),
  io:format("Local_interface_ip_add is ~p~n",[ValueBin3]),
  ValueBin4 = encode_sub_tlv3(Remote_interface_ip_add),
  io:format("Remote_interface_ip_add is ~p~n",[ValueBin4]),
  ValueBin5 = encode_sub_tlv4(Te_metric),
  io:format("Te_metric is ~p~n",[ValueBin5]),
  ValueBin6 = encode_sub_tlv5(Interface_switching_cap_des),
  io:format("Interface_switching_cap_des is ~p~n",[ValueBin6]),
%%   ValueBin7 = encode_sub_tlv6(Shared_risk_link_group),
%%   io:format("Shared_risk_link_group is ~p~n",[ValueBin7]),
  ValueBin8 = encode_sub_tlv7(Port_label_res),
  io:format("Port_label_res is ~p~n",[ValueBin8]),
  ValueBin9 = encode_sub_tlv12(Available_labels_field),
  io:format("Available_labels_field is ~p~n",[ValueBin9]),
  Type = 10001,
  Length = 128, %% TODO
  Resbytes = 0,
  list_to_binary([<<Type:16,Length:16>>,ValueBin1,<<Resbytes:24>>,ValueBin2,ValueBin3,ValueBin4,ValueBin5,ValueBin6,ValueBin8,ValueBin9]).
encode_tlv14(#link_descriptors_tlv{
%%   link_descriptors_tlv_type = Type,link_descriptors_tlv_length = Length,
  ipv4_interface_add_sub_tlv_body = Ipv4_interface_add,
ipv4_neighbor_add_sub_tlv_body = Ipv4_neighbor_add}) ->
  %% TODO after subTLV
  Type = 65284,

  ValueBin1 =encode_sub_tlv8(Ipv4_interface_add),
  ValueBin2 = encode_sub_tlv9(Ipv4_neighbor_add),
  Length = byte_size(ValueBin1)+byte_size(ValueBin2),
  list_to_binary([<<Type:16,Length:16>>,ValueBin1,ValueBin2]).
encode_tlv15(#node_attributes_tlv{ipv4_router_id_of_local_Node_sub_tlv_body = Ipv4_router_id_of_local_Nodes}) ->
  Type = 65285,

  ValueBin1 = list_to_binary([encode_sub_tlv11(Ipv4_router_id_of_local_Node) || Ipv4_router_id_of_local_Node <- Ipv4_router_id_of_local_Nodes]),
  Length = byte_size(ValueBin1),
  <<Type:16,Length:16,ValueBin1/bytes>>.
encode_tlv16(#optical_node_attribute_tlv{optical_node_attribute = Optical_node_attribute}) ->
  Type = 10002,
  Length = 12,
  Optical_node_attribute1 = encode_sub_tlv13(Optical_node_attribute),
  list_to_binary([<<Type:16,Length:16>>,Optical_node_attribute1]).

encode_tlv17(#optical_node_attribute_tlv{optical_node_attribute = Optical_node_attribute}) ->
  Type = 10002,
  Length = 16,
  Optical_node_attribute1 = encode_sub_tlv14(Optical_node_attribute),
  list_to_binary([<<Type:16,Length:16>>,Optical_node_attribute1]).

encode_tlv18(#optical_node_attribute_tlv{optical_node_attribute = Optical_node_attribute}) ->
  Type = 10002,
  Length = 20,
  Optical_node_attribute1 = encode_sub_tlv15(Optical_node_attribute),
  list_to_binary([<<Type:16,Length:16>>,Optical_node_attribute1]).

encode_tlv19(#optical_node_attribute_tlv{optical_node_attribute = Optical_node_attribute}) ->
  Type = 10002,
  Length = 24,
  Optical_node_attribute1 = encode_sub_tlv16(Optical_node_attribute),
  list_to_binary([<<Type:16,Length:16>>,Optical_node_attribute1]).

encode_sub_tlv1(#link_id_sub_tlv{link_id_sub_tlv_type = Link_id_type,
  link_id_sub_tlv_length = Link_id_length,link_id = Link_id}) ->
  <<Link_id_type:16,Link_id_length:16,Link_id:32>>.

encode_sub_tlv2(#local_interface_ip_address_sub_tlv{local_interface_ip_address_sub_tlv_type = Local_interface_ip_add_type,
  local_interface_ip_address_sub_tlv_length = Local_interface_ip_add_length,local_interface_address = Local_interface_add}) ->
  <<Local_interface_ip_add_type:16,Local_interface_ip_add_length:16,Local_interface_add:32>>.

encode_sub_tlv3(#remote_interface_ip_address_sub_tlv{remote_interface_ip_address_sub_tlv_type = Remote_interface_ip_address_type,
  remote_interface_ip_address_sub_tlv_length = Remote_interface_ip_address_length, remote_interface_address = Remote_interface_address}) ->
  <<Remote_interface_ip_address_type:16,Remote_interface_ip_address_length:16,Remote_interface_address:32>>.

encode_sub_tlv4(#te_metric_sub_tlv{te_metric_sub_tlv_type = TE_metric_type,te_metric_sub_tlv_length = TE_metric_length,
  te_link_metric = TE_link_metric}) ->
  <<TE_metric_type:16,TE_metric_length:16,TE_link_metric:32>>.

encode_sub_tlv5(#interface_switching_capability_descriptor_sub_tlv{interface_switching_capability_descriptor_sub_tlv_type = Interface_switching_cap_des_type,
  interface_switching_capability_descriptor_sub_tlv_length = Interface_switching_cap_des_length,switching_cap = Switch_cap,
  encoding = Encoding,reserved = Reserved,priority_0 = Priority_0,priority_1 = Priority_1,priority_2 = Priority_2,
  priority_3 = Priority_3,priority_4 = Priority_4,priority_5 = Priority_5,priority_6 = Priority_6,priority_7 = Priority_7}) ->
  <<Interface_switching_cap_des_type:16,Interface_switching_cap_des_length:16,Switch_cap:8,Encoding:8,Reserved:16,
  Priority_0:32,Priority_1:32,Priority_2:32,Priority_3:32,Priority_4:32,Priority_5:32,Priority_6:32,Priority_7:32>>.

encode_sub_tlv6(#shared_risk_link_group_sub_tlv{shared_risk_link_group_sub_tlv_type = Shared_risk_link_group_type,
  shared_risk_link_group_sub_tlv_length = Shared_risk_link_group_length,shared_risk_link_group_value = Shared_risk_link_group_value}) ->
%%   N = Shared_risk_link_group_length*8,
  <<Shared_risk_link_group_type:16,Shared_risk_link_group_length:16,Shared_risk_link_group_value:32>>.

encode_sub_tlv7(#port_label_restrictions_sub_tlv{port_label_restrictions_sub_tlv_type = Type, port_label_restrictions_sub_tlv_length = Length,
  matrix_ID = Matrix_ID,res_type = Res_type,switching_cap = Switching_cap,encoding = Encoding,additional_res = Additional_res}) ->
  %% TODO after defined.

  <<Type:16,Length:16,Matrix_ID:8,Res_type:8,Switching_cap:8,Encoding:8,Additional_res:128>>.

encode_sub_tlv8(#ipv4_interface_address_sub_tlv{ipv4_interface_address_sub_tlv_type = Ipv4_interface_add_type,
  ipv4_interface_address_sub_tlv_length = Ipv4_interface_add_length,ipv4_interface_address = Ipv4_interface_address}) ->
  <<Ipv4_interface_add_type:16,Ipv4_interface_add_length:16,Ipv4_interface_address:32>>.

encode_sub_tlv9(#ipv4_neighbor_address_sub_tlv{ipv4_neighbor_address_sub_tlv_type = Ipv4_neighbor_add_type,
  ipv4_neighbor_address_sub_tlv_length = Ipv4_neighbor_add_length, ipv4_neighbor_address = Ipv4_neighbor_add}) ->
  <<Ipv4_neighbor_add_type:16,Ipv4_neighbor_add_length:16,Ipv4_neighbor_add:32>>.

encode_sub_tlv10(#link_type_sub_tlv{link_type_sub_tlv_type = Link_type_type, link_type_sub_tlv_length = Link_type_length,
  link_type = Link_type_value}) ->
  <<Link_type_type:16,Link_type_length:16,Link_type_value:8>>.

encode_sub_tlv11(#ipv4_router_id_of_local_node_sub_tlv{ipv4_router_id_of_local_node_sub_tlv_type = Ipv4_router_id_of_local_node_type,
  ipv4_router_id_of_local_node_sub_tlv_length = Ipv4_router_id_of_local_node_length,
  ipv4_router_id_of_local_node = Ipv4_router_id_of_local_node}) ->
  <<Ipv4_router_id_of_local_node_type:16,Ipv4_router_id_of_local_node_length:16,Ipv4_router_id_of_local_node:32>>.

encode_sub_tlv12(#available_labels_field_sub_tlv{available_labels_field_sub_tlv_type = Available_labels_field_sub_tlv_type,
available_labels_field_sub_tlv_length = Available_labels_field_sub_tlv_Length,pri = Pri,res = Res, label_set_field = Label_set_field}) ->
  <<Available_labels_field_sub_tlv_type:16,Available_labels_field_sub_tlv_Length:16,Pri:8,Res:24,Label_set_field:128>>.

encode_sub_tlv13(#actn_node_sub_tlv{actn_node_sub_tlv_type = Actn_node_sub_tlv_type,actn_node_sub_tlv_length = Actn_node_sub_tlv_length,
  prefix = Prefix,ipv4_prefix = Ipv4_prefix,res_bytes = Res_bytes}) ->
  <<Actn_node_sub_tlv_type:16,Actn_node_sub_tlv_length:16,Prefix:8,Ipv4_prefix:32,Res_bytes:24>>.

encode_sub_tlv14(#actn_node_sub_tlv_2{actn_node_sub_tlv_type = Actn_node_sub_tlv_2_type,
  actn_node_sub_tlv_length = Actn_node_sub_tlv_2_length,prefix1 = Prefix1,
  ipv4_prefix1 = Ipv4_prefix_1,prefix2 = Prefix2,ipv4_prefix2 = Ipv4_prefix_2,res_bytes = Res_bytes}) ->
  <<Actn_node_sub_tlv_2_type:16,Actn_node_sub_tlv_2_length:16,Prefix1:8,Ipv4_prefix_1:32,Prefix2:8,Ipv4_prefix_2:32,Res_bytes:16>>.

encode_sub_tlv15(#actn_node_sub_tlv_3{actn_node_sub_tlv_type = Actn_node_sub_tlv_3_type,
  actn_node_sub_tlv_length = Actn_node_sub_tlv_3_length,prefix1 = Prefix1,
  ipv4_prefix1 = Ipv4_prefix_1,prefix2 = Prefix2,ipv4_prefix2 = Ipv4_prefix_2,prefix3 = Prefix3,ipv4_prefix3 = Ipv4_prefix_3,res_bytes = Res_bytes}) ->
  <<Actn_node_sub_tlv_3_type:16,Actn_node_sub_tlv_3_length:16,Prefix1:8,Ipv4_prefix_1:32,Prefix2:8,Ipv4_prefix_2:32,Prefix3:8,Ipv4_prefix_3:32,Res_bytes:8>>.

encode_sub_tlv16(#actn_node_sub_tlv_4{actn_node_sub_tlv_type = Actn_node_sub_tlv_4_type,
  actn_node_sub_tlv_length = Actn_node_sub_tlv_4_length,prefix1 = Prefix1, ipv4_prefix1 = Ipv4_prefix_1,prefix2 = Prefix2,
  ipv4_prefix2 = Ipv4_prefix_2,prefix3 = Prefix3,ipv4_prefix3 = Ipv4_prefix_3,prefix4 = Prefix4,ipv4_prefix4 = Ipv4_prefix_4}) ->
  <<Actn_node_sub_tlv_4_type:16,Actn_node_sub_tlv_4_length:16,Prefix1:8,Ipv4_prefix_1:32,Prefix2:8,Ipv4_prefix_2:32,Prefix3:8,Ipv4_prefix_3:32,Prefix4:8,Ipv4_prefix_4:32>>.
%% -spec encode_tlv(Tlv::tlv()) -> binary().
%% encode_tlv(#tlv{type = Type, length = Length, value = Value}) ->
%%   case Type of
%%     14 -> #gmpls_cap_tlv_value{gmpls_cap_flag = Gm} = Value,
%%       Value_14 = << <<Value14/bytes>> || Value14 <- [<<Gm:32>>]>>,
%%       erlang:list_to_binary([<<Type:16, Length:16>>, Value_14]);
%%     16 -> #stateful_pec_cap_tlv_value{stateful_pce_cap_tlv_flag = Flag1,
%%       stateful_pce_cap_tlv_d = D_flag,
%%       stateful_pce_cap_tlv_t = T_flag,
%%       stateful_pce_cap_tlv_i = I_flag,
%%       stateful_pce_cap_tlv_s = S_flag,
%%       stateful_pce_cap_tlv_u = U_flag} = Value,
%%       Value_16 = << <<Value16/bytes>> || Value16 <- [<<Flag1:27,D_flag:1,T_flag:1,I_flag:1,S_flag:1,U_flag:1>>]>>,
%%       erlang:list_to_binary([<<Type:16, Length:16>>, Value_16]);
%%     32 -> #pcecc_cap_tlv_value{pcecc_cap_tlv_flag = Flag2,
%%       pcecc_cap_tlv_g = G_flag,
%%       pcecc_cap_tlv_l = L_flag} = Value,
%%       Value_32 = << <<Value32/bytes>> || Value32 <- [<<Flag2:30,G_flag:1,L_flag:1>>]>>,
%%       erlang:list_to_binary([<<Type:16, Length:16, Value_32>>]);
%%     23 -> #label_db_version_tlv_value{label_db_version_tlv_ver = Version1} = Value,
%%       Value23 = <<Version1:64>>,
%%       <<Type:16, Length:16, Value23:Length/bytes>>;
%%     132 -> #ted_cap_tlv_value{ted_cap_tlv_flag = Flag3,
%%       ted_cap_tlv_r = R_flag} = Value,
%%       Value_132 = << <<Value132/bytes>> || Value132 <- [<<Flag3:31,R_flag:1>>]>>,
%%       erlang:list_to_binary([<<Type:16, Length:16>>, Value_132]);
%% %%     %% ls
%%     65280 -> #ls_cap_tlv_value{ls_cap_tlv_flag = Flag4,
%%       ls_cap_tlv_r = R_flag1}=Value,
%%       Value_65280 = << <<Value65280/bytes>> || Value65280 <- [<<Flag4:31,R_flag1:1>>]>>,
%%       erlang:list_to_binary([<<Type:16, Length:16>>, Value_65280]);
%% %%       Length = 4;
%%     65281 -> #routing_universe_tlv_value{routing_universe_tlv_identifier = Identifier} = Value,
%%       Value_65281 = << <<Value65281/bytes>> || Value65281 <- [<<Identifier:64>>]>>,
%%       erlang:list_to_binary([<<Type:16, Length:16, Value_65281>>]);
%% %%       Length = size(Value);
%%     65282 -> #local_node_descriptor_tlv_value{local_node_descriptor_tlv_sub_tlv = Sub_tlv1} = Value,
%%       Value_65282 = << <<Value65282/bytes>> || Value65282 <- [<<Sub_tlv1:(Length*8)>>]>>,
%%       erlang:list_to_binary([<<Type:16, Length:16>>, Value_65282]);
%% %%       Length = size(Value);
%%     65283 -> #remote_node_descriptor_tlv_value{remote_node_descriptor_tlv_sub_tlv = Sub_tlv2} =Value,
%%       Value_65283 = << <<Value65283/bytes>> || Value65283 <- [<<Sub_tlv2:(Length*8)>>]>>,
%%       erlang:list_to_binary([<<Type:16, Length:16>>,Value_65283]);
%% %%       Length = size(Value);
%%     65284 -> #link_descriptors_tlv_value{link_descriptors_tlv_sub_tlv = Sub_tlv3} = Value,
%%       Value_65284 = << <<Value65284/bytes>> || Value65284 <- [<<Sub_tlv3:(Length*8)>>]>>,
%%       erlang:list_to_binary([<<Type:16,Length:16>>,Value_65284]);
%% %%       Length = size(Value);
%%     65285 -> #node_attributes_tlv_value{node_attributes_tlv_sub_tlv = Sub_tlv4} = Value,
%%       Value_65285 = << <<Value65285/bytes>> || Value65285 <- [<<Sub_tlv4:(Length*8)>>]>>,
%%       erlang:list_to_binary([<<Type:16,Length:16>>,Value_65285]);
%% %%       Length = size(Value);
%%     65286 -> #link_attributes_tlv_value{link_attributes_tlv_sub_tlv = Sub_tlv5} = Value,
%%       Value_65286 = << <<Value65286/bytes>> || Value65286 <- [<<Sub_tlv5:(Length*8)>>]>>,
%%       erlang:list_to_binary([<<Type:16,Length:16>>,Value_65286]);
%% %%       Length = size(Value);
%% %%     %% stateful pce
%%     17 -> #symbolic_path_name_tlv_value{symbolic_path_name = Name} = Value,
%%       Value_17 = << <<Value17/bytes>> || Value17 <- [<<Name:(Length*8)>>]>>,
%%       erlang:list_to_binary([<<Type:16,Length:16>>,Value_17]);
%% %%       Length = size(Value);
%%     18 -> #ipv4_lsp_identifiers_tlv_value{ipv4_lsp_identifiers_tlv_tunnel_sender_add = Sender_add,
%%       ipv4_lsp_identifiers_tlv_lsp_id = Lsp_id,
%%       ipv4_lsp_identifiers_tlv_tunnel_id = Tunnel_id,
%%       ipv4_lsp_identifiers_tlv_exrended_tunnel_id = Exrended_tunnel_id,
%%       ipv4_lsp_identifiers_tlv_tunnel_endpoint_add = Endpoint_add} =Value,
%%       Value_18 = << <<Value18/bytes>> || Value18 <- [<<Sender_add:32,Lsp_id:16,Tunnel_id:16,Exrended_tunnel_id:32,Endpoint_add:32>>]>>,
%%       erlang:list_to_binary([<<Type:16,Length:16>>,Value_18]);
%% %%       Length = 16;
%%     20 -> #lsp_error_code_tlv_value{lsp_error_code = Code} = Value,
%%       Value_20 = << <<Value20/bytes>> || Value20 <- [<<Code:32>>]>>,
%%       erlang:list_to_binary([<<Type:16,Length:16>>,Value_20]);
%% %%       Length = 4;
%%     21 -> #rsvp_error_spec_tlv_value{} = Value;
%%
%% %%       Length = size(Value);
%%     _ -> ?ERROR("Unrecognized TLV Type")
%%   end.

%%   Tlv_value = term_to_binary(Value),
%%   <<Type:16, Length:16, Va:Length/bytes>>.





encode_subobjects([#subobject{}=Subobject | T]) ->
  T2 =encode_subobjects(T),
  T3 = encode_subobject(Subobject),
  <<T3/bytes,T2/bytes>>;
encode_subobjects([]) ->
  <<>>.


%% encode common body, which is object related message -------------------------------------------------------------------
-spec encode_object_msg(ObjectMessage::pcep_object_message()) -> binary().
encode_object_msg(#pcep_object_message{
  object_class = Class, object_type = Type, res_flags=Flags, p=P,i=I,object_length=Ob_length,body=Body}=_Object_msg) ->
%%   when Ob_length =:= erlang:byte_size(Object_msg) ->
%%   io:format("encode_object_msg start~n"),
  Ct = ?CLASSTYPEMOD(Class, Type),
  case Ct of
    unsupported_class ->
      ?ERROR(Ct),<<>>;
    _ ->
      io:format("5555555555555~n"),
      BodyBin=encode_object_body(Ct, Body),%% TODO
      io:format("BodyBin in the encode_object_msg888888888888 is ~p~n", [BodyBin]),
      list_to_binary([<<Class:8, Type:4, Flags:2, P:1, I:1, Ob_length:16>>, BodyBin])
  end.
%% encode_object_msg(#pcep_object_message{object_length=_Ob_length}=Object_msg) ->
%% %%   when Ob_length /= erlang:byte_size(Object_msg)
%%   ?ERROR("object message length doesn't math the field message_length"),
%%   <<>>.
encode_open_object_tlvs(#open_object_tlvs{open_gmpls_cap_tlv = Gmpls_cap_tlv,open_stateful_pce_cap_tlv = Stateful_pce_cap_tlv,
   open_pcecc_cap_tlv = Pcecc_cap_tlv,open_ted_cap_tlv = Ted_cap_tlv, open_ls_cap_tlv = Ls_cap_tlv}) ->
%%   io:format("encode_open_object_tlvs start, input is ~p~n", [Gmpls_cap_tlv]),
  Gmpls_cap_tlv1 = encode_tlv1(Gmpls_cap_tlv),
%%   io:format("Gmpls_cap_tlv output is ~p~n",[Gmpls_cap_tlv]),
  Stateful_pce_cap_tlv1 = encode_tlv2(Stateful_pce_cap_tlv),
  Pcecc_cap_tlv1 = encode_tlv3(Pcecc_cap_tlv),
  Ted_cap_tlv1 = encode_tlv5(Ted_cap_tlv),
  Ls_cap_tlv1 = encode_tlv12(Ls_cap_tlv),
%%   io:format("Ls_cap_tlv output is ~p~n",[Gmpls_cap_tlv]),

  list_to_binary([Gmpls_cap_tlv1,Stateful_pce_cap_tlv1,Pcecc_cap_tlv1,Ted_cap_tlv1,Ls_cap_tlv1]).
encode_lsp_object_tlvs(#lsp_object_tlvs{lsp_object_lsp_identifier_tlv = Lsp_identifier_tlv,lsp_object_symbolic_path_name_tlv = Symbolic_path_name_tlv}) ->
  Lsp_identifier_tlv1 = encode_tlv8(Lsp_identifier_tlv),
  Symbolic_path_name_tlv1 = encode_tlv7(Symbolic_path_name_tlv),
  list_to_binary([<<Lsp_identifier_tlv1,Symbolic_path_name_tlv1>>]).
encode_ls_object_tlvs(#ls_object_tlvs{actn_link_tlv = Actn_link_tlv,link_descriptor_tlv = Link_des_tlv}) ->
  io:format("encode_ls_object_tlvs start~n"),
  Actn_link_tlv1 = encode_tlv13(Actn_link_tlv),
  io:format("Actn_link_tlv1 in encode_ls_object_tlvs is ~p~n", [Actn_link_tlv1]),
  Link_des_tlv1 = encode_tlv14(Link_des_tlv),
  list_to_binary([Actn_link_tlv1,Link_des_tlv1]).

%% encode open object -------------------------------------------------------------------
encode_object_body(open_ob_type, #open_object{
  version=Version, flags = Flags, keepAlive = KeepAlive, deadTimer=DeadTimer, sid = Sid,
  open_object_tlvs = Open_object_tlvs
%%   #open_object_tlvs{open_gmpls_cap_tlv = Gmpls_cap_tlv,open_stateful_pce_cap_tlv = Stateful_pce_cap_tlv,
%%   open_pcecc_cap_tlv = Pcecc_cap_tlv,open_ted_cap_tlv = Ted_cap_tlv, open_ls_cap_tlv = Ls_cap_tlv}
}) when Version =:= 1 ->
%%   io:format("encode_object_body start, Open_object_tlvs is ~p~n", [Open_object_tlvs]),
%%   TlvsBin=encode_tlv1(Tlvs),
  Open_object_tlvs1 = encode_open_object_tlvs(Open_object_tlvs),
%%   io:format("Open_object_tlv1 is ~p~n",[Open_object_tlvs1]),
%%   Gmpls_cap_tlv1 = list_to_binary([encode_tlv1(Gmpls_cap_tlvs) || Gmpls_cap_tlvs <- Gmpls_cap_tlv]),
%%   Stateful_pce_cap_tlv1 = list_to_binary([encode_tlv2(Stateful_pce_cap_tlvs) || Stateful_pce_cap_tlvs <- Stateful_pce_cap_tlv]),
%%   Pcecc_cap_tlv1 = list_to_binary([encode_tlv3(Pcecc_cap_tlvs) || Pcecc_cap_tlvs <- Pcecc_cap_tlv]),
%%   Ted_cap_tlv1 = list_to_binary([encode_tlv5(Ted_cap_tlvs) || Ted_cap_tlvs <- Ted_cap_tlv]),
%%   Ls_cap_tlv1 = list_to_binary([encode_tlv12(Ls_cap_tlvs) || Ls_cap_tlvs <- Ls_cap_tlv]),

  Sid=0,  %%TODO after connecting
  list_to_binary([<<Version:3, Flags:5, KeepAlive:8, DeadTimer:8, Sid:8>>, Open_object_tlvs1]);
encode_object_body(open_ob_type, #open_object{version = Version}) when Version /= 1 ->
  ?ERROR("open object version is not mached"),
  <<>>;
%% encode lsp object
encode_object_body(lsp_ob_type,#lsp_object{
  plsp_id = Plsp_id,flag = Flag,c = C,o = O,a = A,r = R,s = S,d =D,lsp_object_tlvs = Tlvs
}) ->
  TlvsBin=encode_lsp_object_tlvs(Tlvs),
  list_to_binary([<<Plsp_id:20,Flag:4,C:1,O:3,A:1,R:1,S:1,D:1>>,TlvsBin]);

%% encode rp object -------------------------------------------------------------------
encode_object_body(rp_object_type, #rp_object{
  flags=Flags,o = O,b = B,r = R,pri = Pri,request_id_num = Req_id,tlvs = Tlvs
}) ->
  TlvsBin = encode_tlv1(Tlvs),
  <<Flags:26,O:1,B:1,R:1,Pri:3,Req_id:32,TlvsBin/bytes>>;

%% encode end points IPv4 object
encode_object_body(end_points_v4_ob_type,#end_points_object_ipv4{
  source_ipv4_add=Src_v4_add,destination_ipv4_add = Des_v4_add
}) ->
  <<Src_v4_add:32,Des_v4_add:32>>;

%% encode end points IPv6 object
%% encode_object_body(end_points_v6_ob_type,#end_points_object_ipv6{
%%   source_ipv6_add = Src_v6_add,destination_ipv6_add = Des_v6_add
%% }) ->
%%   <<Src_v6_add:128,Des_v6_add:128>>;

%% encode error object
encode_object_body(pcep_error_ob_type,#error_object{
  reserved = Res,flags = Flags,error_type = Error_type,error_value = Error_value,tlvs = Tlvs
}) ->
  TlvsBin = encode_tlv1(Tlvs),
  <<Res:8,Flags:8,Error_type:8,Error_value:8,TlvsBin/bytes>>;

%% encode close object
encode_object_body(close_ob_type,#close_object{
  reserved = Res,flags = Flags,reason = Reason,tlvs = Tlvs
}) ->
  TlvsBin=encode_tlv1(Tlvs),
  <<Res:16,Flags:8,Reason:8,TlvsBin/bytes>>;

%% encode ls object
encode_object_body(ls_link_ob_type,#ls_link_object{
  ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,ls_object_tlv = Tlvs
}) ->
  io:format("encode_ls_object_body start~n"),
  TlvsBin=encode_tlv13(Tlvs),
  io:format("TlvsBin in encode_ls_object_body is ~p~n",[TlvsBin]),
  list_to_binary([<<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64>>,TlvsBin]);
%% ls object protocol id
%%| 1 | IS-IS Level 1
%%| 2 | IS-IS Level 2
%%| 3 | OSPFv2
%%| 4 | Direct
%%| 5 | Static configuration
%%| 6 | OSPFv3
%%| 7 | BGP-LS
encode_object_body(ls_node_ob_type,#ls_node_object{
  ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,ls_node_object_tlv = Tlvs
}) ->
  Q = #ls_node_object{
    ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,ls_node_object_tlv = Tlvs},
  io:format("Q is ~p~n",[Q]),
  E = element(7,Q),
  io:format("E is ~p~n",[E]),
  Ip_num = tuple_size(element(4,E)),
  case Ip_num of
    6 ->
      TlvsBin1=encode_tlv16(Tlvs),
      list_to_binary([<<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64>>,TlvsBin1]);
    8 ->
      TlvsBin2 = encode_tlv17(Tlvs),
      list_to_binary([<<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64>>,TlvsBin2]);
    10 ->
      TlvsBin3 = encode_tlv18(Tlvs),
      list_to_binary([<<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64>>,TlvsBin3]);

    11 ->
      TlvsBin4 = encode_tlv19(Tlvs),
      list_to_binary([<<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64>>,TlvsBin4]);

    _ ->
      io:format("unsupported length~n")
  end;
%%   TlvsBin=encode_tlv16(Tlvs),
%%   list_to_binary([<<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64>>,TlvsBin]);

encode_object_body(ls_ipv4_topo_prefix_ob_type,#ls_link_object{
  ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,ls_object_tlv = Tlvs
}) ->
  TlvsBin=encode_tlv1(Tlvs),
  list_to_binary([<<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64>>,TlvsBin]);

%% encode_object_body(ls_ipv6_topo_prefix_ob_type,#ls_object{
%%   ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = Tlvs
%% }) ->
%%   TlvsBin=encode_tlv1(Tlvs),
%%   <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,TlvsBin/bytes>>;



%% encode rro object
%% TODO for fxf 2016-03-30
encode_object_body(rro_ob_type,#rro_object{
  rro_subobjects = Subobjects
}) ->
  SubobjectsBin = encode_subobjects(Subobjects),
  <<SubobjectsBin/bytes>>.


%%TODO for fxf
%% encode_tlv1([#tlv{}=Tlv | T]) ->
%%
%%   T2 = encode_tlv1(T),
%%   <<encode_tlv(Tlv), T2/bytes>>;
%% encode_tlv1([]) ->
%%   <<>>.

