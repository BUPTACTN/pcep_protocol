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
-include("pcep_ls_v2.hrl").
%%-include("pcep_logger.hrl").
-include("pcep_stateful_pce_v2.hrl").

%% API
-export([do/1]).
-export([encode_tlv/1]).
-export([encode_tlvs/1]).
-export([encode_object_msg/1]).
-export([encode_object_body/2]).
-export([encode_objects/1]).
%%-export([encode_rro_object_body/3]).

%%-spec encode_objects(list()) ->binary().

encode_objects([#pcep_object_message{} = Object | H]) ->
  H2 = encode_objects(H),
  H3 = encode_object_msg(Object),
  <<H3/bytes,H2/bytes>>;
encode_objects([]) ->
  <<>>.

%% encode pcep_message -------------------------------------------------------------------
-spec do(Message ::pcep_message()) ->binary().
do(#pcep_message{version = ?VERSION, flags=Flags, message_type=MessageType, message_length=MessageLength, body=Body}=msg)
  when MessageLength =:= erlang:byte_size(msg) ->
  BodyBin = encode_objects(Body),  %% TODO one msg can include many objects
  <<?VERSION:3, Flags:5, MessageType:8, MessageLength:16, BodyBin/bytes>>;
do(#pcep_message{message_length=MessageLength}=msg)
  when MessageLength /= erlang:byte_size(msg) ->
  ?ERROR("message length doesn't math the field message_length"),
  <<>>.


%% encode tlvs' list -------------------------------------------------------------------
%% encode subobject
-spec encode_subobject(Subobject::subobject()) -> binary().
encode_subobject(#subobject{subobject_type = Type,subobject_length = Length,subobject_value = Value}) ->
  case Type of
    1 -> #ipv4_subobject_value{ipv4_subobject_add = Ipv4_add,
    ipv4_subobject_prefix_len = Ipv4_prefix_len,
    ipv4_subobject_flags = Ipv4_flags} = Value,
      Value_1 = << <<Value1/bytes>> || Value1 <- [<<Ipv4_add:32,Ipv4_prefix_len:8,Ipv4_flags:8>>]>>,
      erlang:list_to_binary([<<Type:8, Length:8>>, Value_1]);
    2 -> #ipv6_subobject_value{ipv6_subobject_add = Ipv6_add,
    ipv6_subobject_prefix_len = Ipv6_prefix_len,
    ipv6_subobject_flags = Ipv6_flags} = Value,
      Value_2 = << <<Value2/bytes>> || Value2 <- [<<Ipv6_add:128,Ipv6_prefix_len:8,Ipv6_flags:8>>]>>,
      erlang:list_to_binary([<<Type:8, Length:8>>, Value_2]);
    3 -> #label_subobject_value{label_subobject_flags =Label_flags,
    label_subobject_c_type = Label_c_type,
    label_subobject_contents = Label_contents} = Value,
      Value_3 = << <<Value3/bytes>> || Value3 <- [<<Label_flags:8,Label_c_type:8,Label_contents:32>>]>>,
      erlang:list_to_binary([<<Type:8, Length:8>>, Value_3]);
    _ ->
      ?ERROR("Other Subobject Type,but cannot be recognized")
  end.
%% TODO ERROR, tlv !!!
-spec encode_tlv(Tlv::tlv()) -> binary().
encode_tlv(#tlv{type = Type, length = Length, value = Value}) ->
  case Type of
    14 -> #gmpls_cap_tlv_value{gmpls_cap_flag = Gm} = Value,
      Value_14 = << <<Value14/bytes>> || Value14 <- [<<Gm:32>>]>>,
      erlang:list_to_binary([<<Type:16, Length:16>>, Value_14]);
    16 -> #stateful_pec_cap_tlv_value{stateful_pce_cap_tlv_flag = Flag1,
      stateful_pce_cap_tlv_d = D_flag,
      stateful_pce_cap_tlv_t = T_flag,
      stateful_pce_cap_tlv_i = I_flag,
      stateful_pce_cap_tlv_s = S_flag,
      stateful_pce_cap_tlv_u = U_flag} = Value,
      Value_16 = << <<Value16/bytes>> || Value16 <- [<<Flag1:27,D_flag:1,T_flag:1,I_flag:1,S_flag:1,U_flag:1>>]>>,
      erlang:list_to_binary([<<Type:16, Length:16>>, Value_16]);
    32 -> #pcecc_cap_tlv_value{pcecc_cap_tlv_flag = Flag2,
      pcecc_cap_tlv_g = G_flag,
      pcecc_cap_tlv_l = L_flag} = Value,
      Value_32 = << <<Value32/bytes>> || Value32 <- [<<Flag2:30,G_flag:1,L_flag:1>>]>>,
      erlang:list_to_binary([<<Type:16, Length:16, Value_32>>]);
    23 -> #label_db_version_tlv_value{label_db_version_tlv_ver = Version1} = Value,
      Value23 = <<Version1:64>>,
      <<Type:16, Length:16, Value23:Length/bytes>>;
    132 -> #ted_cap_tlv_value{ted_cap_tlv_flag = Flag3,
      ted_cap_tlv_r = R_flag} = Value,
      Value_132 = << <<Value132/bytes>> || Value132 <- [<<Flag3:31,R_flag:1>>]>>,
      erlang:list_to_binary([<<Type:16, Length:16>>, Value_132]);
%%     %% ls
    65280 -> #ls_cap_tlv_value{ls_cap_tlv_flag = Flag4,
      ls_cap_tlv_r = R_flag1}=Value,
      Value_65280 = << <<Value65280/bytes>> || Value65280 <- [<<Flag4:31,R_flag1:1>>]>>,
      erlang:list_to_binary([<<Type:16, Length:16>>, Value_65280]);
%%       Length = 4;
    65281 -> #routing_universe_tlv_value{routing_universe_tlv_identifier = Identifier} = Value,
      Value_65281 = << <<Value65281/bytes>> || Value65281 <- [<<Identifier:64>>]>>,
      erlang:list_to_binary([<<Type:16, Length:16, Value_65281>>]);
%%       Length = size(Value);
    65282 -> #local_node_descriptor_tlv_value{local_node_descriptor_tlv_sub_tlv = Sub_tlv1} = Value,
      Value_65282 = << <<Value65282/bytes>> || Value65282 <- [<<Sub_tlv1:(Length*8)>>]>>,
      erlang:list_to_binary([<<Type:16, Length:16>>, Value_65282]);
%%       Length = size(Value);
    65283 -> #remote_node_descriptor_tlv_value{remote_node_descriptor_tlv_sub_tlv = Sub_tlv2} =Value,
      Value_65283 = << <<Value65283/bytes>> || Value65283 <- [<<Sub_tlv2:(Length*8)>>]>>,
      erlang:list_to_binary([<<Type:16, Length:16>>,Value_65283]);
%%       Length = size(Value);
    65284 -> #link_descriptors_tlv_value{link_descriptors_tlv_sub_tlv = Sub_tlv3} = Value,
      Value_65284 = << <<Value65284/bytes>> || Value65284 <- [<<Sub_tlv3:(Length*8)>>]>>,
      erlang:list_to_binary([<<Type:16,Length:16>>,Value_65284]);
%%       Length = size(Value);
    65285 -> #node_attributes_tlv_value{node_attributes_tlv_sub_tlv = Sub_tlv4} = Value,
      Value_65285 = << <<Value65285/bytes>> || Value65285 <- [<<Sub_tlv4:(Length*8)>>]>>,
      erlang:list_to_binary([<<Type:16,Length:16>>,Value_65285]);
%%       Length = size(Value);
    65286 -> #link_attributes_tlv_value{link_attributes_tlv_sub_tlv = Sub_tlv5} = Value,
      Value_65286 = << <<Value65286/bytes>> || Value65286 <- [<<Sub_tlv5:(Length*8)>>]>>,
      erlang:list_to_binary([<<Type:16,Length:16>>,Value_65286]);
%%       Length = size(Value);
%%     %% stateful pce
    17 -> #symbolic_path_name_tlv_value{symbolic_path_name = Name} = Value,
      Value_17 = << <<Value17/bytes>> || Value17 <- [<<Name:(Length*8)>>]>>,
      erlang:list_to_binary([<<Type:16,Length:16>>,Value_17]);
%%       Length = size(Value);
    18 -> #ipv4_lsp_identifiers_tlv_value{ipv4_lsp_identifiers_tlv_tunnel_sender_add = Sender_add,
      ipv4_lsp_identifiers_tlv_lsp_id = Lsp_id,
      ipv4_lsp_identifiers_tlv_tunnel_id = Tunnel_id,
      ipv4_lsp_identifiers_tlv_exrended_tunnel_id = Exrended_tunnel_id,
      ipv4_lsp_identifiers_tlv_tunnel_endpoint_add = Endpoint_add} =Value,
      Value_18 = << <<Value18/bytes>> || Value18 <- [<<Sender_add:32,Lsp_id:16,Tunnel_id:16,Exrended_tunnel_id:32,Endpoint_add:32>>]>>,
      erlang:list_to_binary([<<Type:16,Length:16>>,Value_18]);
%%       Length = 16;
    20 -> #lsp_error_code_tlv_value{lsp_error_code = Code} = Value,
      Value_20 = << <<Value20/bytes>> || Value20 <- [<<Code:32>>]>>,
      erlang:list_to_binary([<<Type:16,Length:16>>,Value_20]);
%%       Length = 4;
    21 -> #rsvp_error_spec_tlv_value{} = Value;   %%TODO when encode the object

%%       Length = size(Value);
    _ -> ?ERROR("Unrecognized TLV Type")
  end.

%%   Tlv_value = term_to_binary(Value),
%%   <<Type:16, Length:16, Va:Length/bytes>>.

%%-spec encode_tlvs(list()) ->binary().
encode_tlvs([#tlv{}=Tlv | T]) ->
  T2 = encode_tlvs(T),
  T3 = encode_tlv(Tlv),
  <<T3/bytes, T2/bytes>>;
encode_tlvs([]) ->
  <<>>.

encode_subobjects([#subobject{}=Subobject | T]) ->
  T2 =encode_subobjects(T),
  T3 = encode_subobject(Subobject),
  <<T3/bytes,T2/bytes>>;
encode_subobjects([]) ->
  <<>>.


%% encode common body, which is object related message -------------------------------------------------------------------
-spec encode_object_msg(ObjectMessage::pcep_object_message()) -> binary().
encode_object_msg(#pcep_object_message{
  object_class = Class, object_type = Type, res_flags=Flags, p=P,i=I,object_length=Ob_length,body=Body}=object_msg)
  when Ob_length =:= erlang:byte_size(object_msg) ->
  Ct = ?CLASSTYPEMOD(Class, Type),
  case Ct of
    unsupported_class ->
      ?ERROR(Ct),<<>>;
    _ ->
      BodyBin=encode_object_body(Ct, Body),%% TODO
      <<Class:8, Type:4, Flags:2, P:1, I:1, Ob_length:16, BodyBin/bytes>>
  end;
encode_object_msg(#pcep_object_message{object_length=Ob_length}=object_msg)
  when Ob_length /= erlang:byte_size(object_msg) ->
  ?ERROR("object message length doesn't math the field message_length"),
  <<>>.



%% encode open object -------------------------------------------------------------------
encode_object_body(open_ob_type, #open_object{
  version=Version, flags = Flags, keepAlive = KeepAlive, deadTimer=DeadTimer, sid = Sid, tlvs = Tlvs
}) when Version =:= 1 ->
  TlvsBin=encode_tlvs(Tlvs),
  Sid=0,  %%TODO after connecting
  <<Version:3, Flags:5, KeepAlive:8, DeadTimer:8, Sid:8, TlvsBin/bytes>>;
encode_object_body(open_ob_type, #open_object{version = Version}) when Version /= 1 ->
  ?ERROR("open object version is not mached"),
  <<>>;

%% encode rp object -------------------------------------------------------------------
encode_object_body(rp_object_type, #rp_object{
  flags=Flags,o = O,b = B,r = R,pri = Pri,request_id_num = Req_id,tlvs = Tlvs
}) ->
  TlvsBin = encode_tlvs(Tlvs),
  <<Flags:26,O:1,B:1,R:1,Pri:3,Req_id:32,TlvsBin/bytes>>;

%% encode end points IPv4 object
encode_object_body(end_points_v4_ob_type,#end_points_object_ipv4{
  source_ipv4_add=Src_v4_add,destination_ipv4_add = Des_v4_add
}) ->
  <<Src_v4_add:32,Des_v4_add:32>>;

%% encode end points IPv6 object
encode_object_body(end_points_v6_ob_type,#end_points_object_ipv6{
  source_ipv6_add = Src_v6_add,destination_ipv6_add = Des_v6_add
}) ->
  <<Src_v6_add:128,Des_v6_add:128>>;

%% encode error object
encode_object_body(pcep_error_ob_type,#error_object{
  reserved = Res,flags = Flags,error_type = Error_type,error_value = Error_value,tlvs = Tlvs
}) ->
  TlvsBin = encode_tlvs(Tlvs),
  <<Res:8,Flags:8,Error_type:8,Error_value:8,TlvsBin/bytes>>;

%% encode close object
encode_object_body(close_ob_type,#close_object{
  reserved = Res,flags = Flags,reason = Reason,tlvs = Tlvs
}) ->
  TlvsBin=encode_tlvs(Tlvs),
  <<Res:16,Flags:8,Reason:8,TlvsBin/bytes>>;

%% encode ls object
encode_object_body(ls_link_ob_type,#ls_object{
  ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = Tlvs
}) ->
  TlvsBin=encode_tlvs(Tlvs),
  <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,TlvsBin/bytes>>;

encode_object_body(ls_node_ob_type,#ls_object{
  ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = Tlvs
}) ->
  TlvsBin=encode_tlvs(Tlvs),
  <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,TlvsBin/bytes>>;

encode_object_body(ls_ipv4_topo_prefix_ob_type,#ls_object{
  ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = Tlvs
}) ->
  TlvsBin=encode_tlvs(Tlvs),
  <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,TlvsBin/bytes>>;

encode_object_body(ls_ipv6_topo_prefix_ob_type,#ls_object{
  ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = Tlvs
}) ->
  TlvsBin=encode_tlvs(Tlvs),
  <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,TlvsBin/bytes>>;

%% encode lsp object
encode_object_body(lsp_ob_type,#lsp_object{
  plsp_id = Plsp_id,flag = Flag,o = O,a = A,r = R,s = S,d =D,tlvs = Tlvs
}) ->
  TlvsBin=encode_tlvs(Tlvs),
  <<Plsp_id:20,Flag:5,O:3,A:1,R:1,S:1,D:1,TlvsBin/bytes>>;

%% encode rro object
%% TODO for fxf 2016-03-30
encode_object_body(rro_ob_type,#rro_object{
  rro_subobjects = Subobjects
}) ->
  SubobjectsBin = encode_objects(Subobjects),
  <<SubobjectsBin/bytes>>.


%%TODO for fxf
%% encode_tlvs([#tlv{}=Tlv | T]) ->
%%
%%   T2 = encode_tlvs(T),
%%   <<encode_tlv(Tlv), T2/bytes>>;
%% encode_tlvs([]) ->
%%   <<>>.

%%TODO for fxf





%% TODO