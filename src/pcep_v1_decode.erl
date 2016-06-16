%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 三月 2016 下午10:05
%%%-------------------------------------------------------------------
-module(pcep_v1_decode).
-author("root").
-include("pcep_logger.hrl").
-include("pcep_protocol.hrl").
%% -include("pcep_ls_v2.hrl").
-include("pcep_v1.hrl").
%% -include("pcep_stateful_pce_v2.hrl").
%% -include("pcep_onos.hrl").

%% API
-export([do/1]).


%%------------------------------------------------------------------------------
%% API functions
%%------------------------------------------------------------------------------

%% @doc Actual decoding of the message.
-spec do(Binary::binary()) -> {ok, pcep_message(), binary()}.
do(Binary) when ?PCEP_COMMON_HEADER_SIZE > erlang:byte_size(Binary) ->
  {error, binary_too_small};
do(Binary) ->
  <<Version:3, Flags:5,MessageType:8, MessageLength:16, Binary2/bytes>> = Binary,
  case MessageLength > erlang:byte_size(Binary) of
    true ->
      {error, binary_too_small};
    false ->
      BodyLength = MessageLength - 4,
      <<BodyBin:BodyLength/bytes,Rest/bytes>> = Binary2,
      io:format("decode do start,input is ~p~n", [Binary]),
      MsgType = ?MESSAGETYPEMOD(MessageType),
      Body = decode_object_msg(MsgType, BodyBin),
      {ok, #pcep_message{version = Version, flags = Flags,message_type = MessageType, message_length = MessageLength, body = Body}, Rest}
  end.


%% @doc decode Object
%%-spce decode_object_msg(atom(), binary()) -> pcep_object_message().
decode_object_msg(Atom, Binary) ->
  io:format("decode_object_msg start, Atom is ~p~n,Binary is ~p~n", [Atom,Binary]),
  <<Class:8, Type:4, Flags:2, P:1, I:1, Ob_length:16, RstObjects/bytes>> = Binary,
  ClassType = ?CLASSTYPEMOD(Class, Type),
  IsLegal = ?ISLEGAL(Atom, ClassType),
%%   N = Ob_length,
%%   Ob_body2 = decode_object_body(Type,Ob_body),
  case IsLegal of
    true ->
      if
        byte_size(Binary) > Ob_length ->
          <<Ob_body:Ob_length/bytes,Objects/bytes>>  = RstObjects,
          Ob_body1 = decode_object_body(Type,Ob_body),
          #pcep_object_message{object_class = Class, object_type = Type, res_flags = Flags, p = P, i = I, object_length = Ob_length, body = Ob_body1},

          decode_object_msg(Atom, Objects);
        true ->
          io:format("only one object,Ob_body in decode_object_msg is ~p~n",[Ob_body]),
          Ob_body2 = decode_object_body(Type,Ob_body),
          #pcep_object_message{object_class = Class, object_type = Type, res_flags = Flags, p = P, i = I, object_length = Ob_length, body = Ob_body2}
          end;
    false ->
      ?ERROR("Message Type and Class type don't match!"),
      <<>>
  end.
%% -spec decode_tlvs(binary()) -> list().
%% decode_tlvs(Binary) ->
%%   <<Type:16/integer, Length:16,RstTlvs/bytes>> = Binary,
%%   M = Length*8,
%%   <<Value:M, Tlvs/bytes>> = RstTlvs,
%%   if
%%     erlang:byte_size(Tlvs)>0 ->
%%       Tlv = decode_tlv(Type, Length, Value),
%%       [Tlv, decode_tlvs(Tlvs)];
%%     true ->
%%       Tlv = decode_tlv(Type, Length, Value),
%%       [Tlv]
%%   end.
%% @doc decode Objects
%% -spec decode_objects(binary()).
%% decode_objects(Binary) ->
%%   <<>>
%% @doc decode object body
%% -spec decode_object_body(atom(), binary()) -> any().
decode_object_body(open_ob_type, Binary) ->
  io:format("decode_open_object_body start,Binary is ~p~n", [Binary]),
  <<Version:3, Flags:5, Keepalive:8, DeadTimer:8, SID:8, Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #open_object{version = Version, flags = Flags, keepAlive = Keepalive, deadTimer = DeadTimer, sid = SID, open_object_tlvs = DTlvs};

decode_object_body(rp_ob_type, Binary) ->
  <<Flags:26,O:1,B:1,R:1,Pri:3,Req_id:32,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #rp_object{flags=Flags,o = O,b = B,r = R,pri = Pri,request_id_num = Req_id,tlvs = DTlvs};

decode_object_body(end_points_v4_ob_type,Binary) ->
  <<Src_v4_add:32,Des_v4_add:32>> = Binary,
  #end_points_object_ipv4{source_ipv4_add=Src_v4_add,destination_ipv4_add = Des_v4_add};

%% decode_object_body(end_points_v6_ob_type,Binary) ->
%%   <<Src_v6_add:128,Des_v6_add:128>> = Binary,
%%   #end_points_object_ipv6{source_ipv6_add = Src_v6_add,destination_ipv6_add = Des_v6_add};

decode_object_body(pcep_error_ob_type,Binary) ->
  <<Res:8,Flags:8,Error_type:8,Error_value:8,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #error_object{reserved = Res,flags = Flags,error_type = Error_type,error_value = Error_value,tlvs = DTlvs};

decode_object_body(close_ob_type,Binary) ->
  <<Res:16,Flags:8,Reason:8,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #close_object{reserved = Res,flags = Flags,reason = Reason,tlvs = DTlvs};

decode_object_body(ls_link_ob_type,Binary) ->
  <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #ls_object{ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = DTlvs};

decode_object_body(ls_node_ob_type,Binary) ->
  <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #ls_object{ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = DTlvs};

decode_object_body(ls_ipv4_topo_prefix_ob_type,Binary) ->
  <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #ls_object{ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = DTlvs};

%% decode_object_body(ls_ipv6_topo_prefix_ob_type,Binary) ->
%%   <<Protocol_id:8,Flag:22,R:1,S:1,Ls_id:64,Tlvs/bytes>> = Binary,
%%   DTlvs = decode_tlvs(1,Tlvs),
%%   #ls_object{ls_object_protocol_id = Protocol_id,ls_object_flag = Flag,ls_object_r = R,ls_object_s = S,ls_object_ls_id = Ls_id,tlvs = DTlvs};

decode_object_body(lsp_ob_type,Binary) ->
  <<Plsp_id:20,Flag:5,O:3,A:1,R:1,S:1,D:1,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #lsp_object{plsp_id = Plsp_id,flag = Flag,o = O,a = A,r = R,s = S,d =D,tlvs = DTlvs};

%% TODO 不存在于encode的object，部分在encode也需要补充
decode_object_body(srp_ob_type,Binary) ->
  <<Flags:32,Srp_id_num:32,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #srp_object{flags= Flags,srp_id_number = Srp_id_num,tlvs = DTlvs};

decode_object_body(end_points_v4_ob_type,Binary) ->
  <<Sou_ipv4_add:32,Des_ipv4_add:32>> = Binary,
  #end_points_object_ipv4{source_ipv4_add = Sou_ipv4_add,destination_ipv4_add = Des_ipv4_add};

%% decode_object_body(end_points_v6_ob_type,Binary) ->
%%   <<Sou_ipv6_add:128,Des_ipv6_add:128>> = Binary,
%%   #end_points_object_ipv6{source_ipv6_add = Sou_ipv6_add,destination_ipv6_add = Des_ipv6_add};

decode_object_body(bdwidth_req_ob_type,Binary) ->
  <<Bandwidth:32>> = Binary,
  #bandwidth_req_object{bandwidth = Bandwidth};

decode_object_body(bdwidth_lsp_ob_type,Binary) ->
  <<Bandwidth:32>> = Binary,
  #bandwidth_lsp_object{bandwidth = Bandwidth};

decode_object_body(label_ob_type,Binary) ->
  <<Reserved1:15,Flags:16,O:1,Label:32,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #label_object{label_object_res = Reserved1,label_object_flags = Flags,label_object_o = O,label_object_label = Label,tlvs = DTlvs};

decode_object_body(fec_ipv4_ob_type,Binary) ->
  <<Ipv4_node_id:32>> = Binary,
  #fec_ipv4_object{ipv4_node_id = Ipv4_node_id};

%% decode_object_body(fec_ipv6_ob_type,Binary) ->
%%   <<Ipv6_node_id:128>> = Binary,
%%   #fec_ipv6_object{ipv6_node_id = Ipv6_node_id};

decode_object_body(fec_ipv4_adjacency_ob_type,Binary) ->
  <<Local_ipv4_add:32,Remote_ipv4_add:32>> = Binary,
  #fec_ipv4_adjacency_object{local_ipv4_add = Local_ipv4_add,remote_ipv4_add = Remote_ipv4_add};

%% decode_object_body(fec_ipv6_adjacency_ob_type,Binary) ->
%%   <<Local_ipv6_add:128,Remote_ipv6_add:128>> = Binary,
%%   #fec_ipv6_adjacency_object{local_ipv6_add = Local_ipv6_add,remote_ipv6_add = Remote_ipv6_add};

%%decode_object_body(fec_ipv4_unnumbered_ob_type,Binary) ->
decode_object_body(label_range_ob_type,Binary) ->
  <<Label_type:8,Range_size:24,Label_base:32,Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(1,Tlvs),
  #label_range_object{label_type = Label_type,range_size = Range_size,label_base = Label_base,tlvs = DTlvs};

decode_object_body(ero_ob_type,Binary) ->
  <<SubObjects/bytes>> = Binary,
  DSubObjects = decode_tlvs(2,SubObjects),
  #ero_object{ero_subobjects = DSubObjects};

decode_object_body(rro_ob_type,Binary) ->
  <<SubObjects/bytes>> = Binary,
  DSubObjects = decode_tlvs(2,SubObjects),
  #rro_object{rro_subobjects = DSubObjects}.

%% TODO for fxf 2016-03-28


%% @doc decode the list of tlvs from binary format to object format
%% -spec decode_tlvs(Priority,binary()) -> list().
decode_tlvs(Priority,Binary) ->    %% Priority=1 indicate the TLV is normal TLV, Priority=2 indicate the TLV is Subobject
  case Priority of
    1 ->
      <<_Type:16/integer, Length:16/integer,RstTlvs/bytes>> = Binary,
      M = Length*8,
      <<_Value:M, Tlvs/bytes>> = RstTlvs,
      if
        erlang:byte_size(Tlvs)>0 ->
          Tlv = decode_tlv(Binary),
          [Tlv, decode_tlvs(Priority,Tlvs)];
        true ->
          Tlv = decode_tlv(Binary),
          [Tlv]
      end;
    2 ->
      <<_Type:8/integer,Length:8,RstTlvs/bytes>> =Binary,
      M = (Length-2)*8,
      <<_Value:M,Tlvs/bytes>> = RstTlvs,
      if erlang:byte_size(Tlvs) > 0 ->
        Tlv = decode_subobject(Binary),
        [Tlv,decode_tlvs(Priority,Tlvs)];
        true ->
          Tlv = decode_subobject(Binary),
          [Tlv]
      end

  end.
%%   <<Type:16/integer, Length:16,RstTlvs/bytes>> = Binary,
%%   M = Length*8,
%%   <<Value:M, Tlvs/bytes>> = RstTlvs,
%%   if
%%     erlang:byte_size(Tlvs)>0 ->
%%       Tlv = decode_tlv(Type, Length, Value,Binary),
%%       [Tlv, decode_tlvs(Priority,Tlvs)];
%%     true ->
%%       Tlv = decode_tlv(Type, Length, Value,Binary),
%%       [Tlv]
%%   end.

%% binary中不能进行计算，即使是加减乘除。
%% -spec decode_tlv(Type, Length, Value,Binary) -> Rtn when Type::integer(),Length::integer(),Value::binary(),Value::binary(),Rtn::any().
decode_tlv(Binary) ->
  Length=erlang:byte_size(Binary)-4,
  <<Type:16>> = erlang:binary_part(Binary,{0,2}),
  L = Length*8,
  <<Value:L>> = erlang:binary_part(Binary,{4,Length}),
  TlvType = ?TLV_Type(Type),
  if <<Type:16,Length:16,Value:L>> =:= Binary ->
    case TlvType of
      gmpls_cap_tlv_type ->
        Flag = erlang:binary_part(Binary,{byte_size(Binary),-4}),
        if Flag =:= <<0,0,0,0>> ->
          erlang:binary_to_list(Flag);
        true ->
          ?ERROR("The gmpls cap TLV is wrong")
        end;
      stateful_pce_cap_tlv_type ->
        Value1 = erlang:binary_part(Binary,{byte_size(Binary),-4}),
%%       Flag=erlang:binary_part(Binary,{32,27}),
%%       D = erlang:binary_part(Binary,{59,1}),
%%       T = erlang:binary_part(Binary,{60,1}),
%%       I = erlang:binary_part(Binary,{61,1}),
%%       S = erlang:binary_part(Binary,{62,1}),
%%       U = erlang:binary_part(Binary,{63,1}),
      <<Flag:27,D:1,T:1,I:1,S:1,U:1>> = Value1,
      if (Flag=:=0)and(D=:=1)and(T=:=1)and(I=:=1)and(S=:=1)and(U=:=1) ->
        erlang:binary_to_list(Value1);
        true ->
          ?ERROR("The stateful pce cap Tlv is wrong")
          end;
    pcecc_cap_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-4}),
      <<Flag:30,G:1,L:1>> = Value1,
      if (Flag =:= 0)and(G=:=1)and(L=:=1) ->
        erlang:binary_to_list(Value1);
        true ->
          ?ERROR("The pcecc cap tlv is wrong")
          end;
    label_db_version_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-8}),
      if Value1 =:= <<0,0,0,0,0,0,0,0>> ->
        erlang:binary_to_list(Value1);
        true ->
          ?ERROR("The label db version tlv is wrong")
      end;
    ted_cap_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-4}),
      <<Flag:31,R:1>> = Value1,
      if (Flag=:=0)and(R=:=1) ->
        erlang:binary_to_list(Value1);
        true ->
          ?ERROR("The ted cap tlv is wrong")
          end;
    ls_cap_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-4}),
      <<Flag:31,R:1>> = Value1,
      if (Flag=:=0)and(R=:=1) ->
        erlang:binary_to_list(Value1);
        true ->
          ?ERROR("The ls cap tlv is wrong")
      end;
    routing_universe_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-8}),
      if Value1 =:= <<0,0,0,0,0,0,0,0>> ->
        erlang:binary_to_list(Value1);
        true ->
          ?ERROR("The ls cap tlv is wrong")
      end;
%%     local_node_descriptor_tlv_type ->;
%%
%%
%%     remote_node_descriptor_tlv_type;
%%     link_descriptors_tlv_type;
%%     node_attributes_tlv_type;
    symbolic_path_name_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-Length}),
      erlang:binary_to_list(Value1);
    ipv4_lsp_identifiers_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-16}),
      <<_Tunnel_sender_add:32,_Lsp_id:16,_Tunnel_id:16,_Exrended_tunnel_id:32,_Tunnel_endpoint_add:32>> = Value1,  %%T TODO address
      erlang:binary_to_list(Value1);
    lsp_error_code_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-4}),
      <<Error_code:32>> = Value1,
      case Error_code of
        1 ->
          ?ERROR("Unknown reason");
        2 ->
          ?ERROR("Limit reached for PCE-controlled LSPs");
        3 ->
          ?ERROR("Too many pending LSP update requests");
        4 ->
          ?ERROR("Unacceptable parameters");
        5 ->
          ?ERROR("Internal error");
        6 ->
          ?ERROR("LSP administratively brought down");
        7 ->
          ?ERROR("LSP preempted");
        8 ->
          ?ERROR("RSVP signaling error");
        _ ->
          ?ERROR("Other error")
      end,
      erlang:binary_to_list(Value1);
    next_hop_ipv4_add_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-4}),
      erlang:binary_to_list(Value1);
    next_hop_unnumbered_ipv4_id_tlv_type ->
      Value1 = erlang:binary_part(Binary,{byte_size(Binary),-8}),
      <<_Node_id:32,_Inferface:32>> = Value1,  %%T TODO address
      erlang:binary_to_list(Value1);
    rsvp_error_spec_tlv_type ->
      <<Obj_len:16,Class_num:8,C_type:8>> = erlang:binary_part(Binary,{4,4}),
      case Class_num of
        6 -> case C_type of
               1 ->
                 if Obj_len =:= 12 ->
                   <<_Ipv4_add:32,_Flags:8,_Error_code:8,_Error_value:16>> = erlang:binary_part(Binary,{8,8}), %%TODO
                   Value1 = erlang:binary_part(Binary,{4,12}),
                   erlang:binary_to_list(Value1);
                   true ->
                     ?ERROR("The ERROR_SPEC Object Length is wrong")
             end;
%%                2 ->
%%                  if Obj_len =:= 24 ->
%%                    <<Ipv6_add:128,Flags:8,Error_code:8,Error_value:16>> = erlang:binary_part(Binary,{8,20}), %%TODO
%%                    Value1 = erlang:binary_part(Binary,{4,24}),
%%                    erlang:binary_to_list(Value1);
%%                    true ->
%%                      ?ERROR("The ERROR_SPEC Object Length is wrong")
%%                  end;
               _ ->
                 ?ERROR("The ERROR_SPEC Object C_type is wrong")
                 end;
        194 ->
          if C_type =:= 1 ->
            <<_Enterprise_num:32,_Sub_org:8,_Err_desc_len:8,_User_error_value:16,_Error_description/bytes>> = erlang:binary_part(Binary,{4,(Obj_len-4)}),
            Value1 = erlang:binary_part(Binary,{4,(Obj_len-8)}),
            erlang:binary_to_list(Value1);
            true ->
              ?ERROR("The USER_ERROR_SPEC Object C_type is wrong")
          end;
        _ ->
          ?ERROR("The rsvp_error_spec_tlv_class_num is unreivable")
      end;
    unsupported_tlv_type ->
      ?ERROR("The TLV is unsupported")
  end;
    true ->
      ?ERROR("It's not matching about tlv")
  end.

%% -spec decode_subobject(Type, Length, Value,Binary) -> Rtn when Type::integer(),Length::integer(),Value::binary(),Value::binary(),Rtn::any().
decode_subobject(Binary) ->
  Length=erlang:byte_size(Binary)-2,
  <<Type:8>> = erlang:binary_part(Binary,{0,1}),
  M = Length*8,
  <<Value:M>> = erlang:binary_part(Binary,{2,Length}),
  SubobType = ?Subobject_Type(Type),
  if <<Type:8,Length:8,Value:M>> == Binary ->
    case SubobType of
      ipv4_subobject_type ->
        <<Type:8,Length:8,Value:48>> = Binary,
        Value1 = erlang:binary_part(Binary,{byte_size(Binary),-6}),
        <<_Ipv4_add:32,_Pre_len:8,_Resvd:8>> = Value1,
        erlang:binary_to_list(Value1);
%%       ipv6_subobject_type ->
%%         Value1 = erlang:binary_part(Binary,{byte_size(Binary),-18}),
%%         <<Ipv4_add:32,Pre_len:8,Resvd:144>> = Value1,
%%         erlang:binary_to_list(Value1);
      label_subobject_type ->
        <<Type:8,Length:8,Value:48>> = Binary,
        Value1 = erlang:binary_part(Binary,{byte_size(Binary),-6}),
        <<_Flags:8,_C_type:8,_Contents:32>> = Value1,
        erlang:binary_to_list(Value1);
      sr_ero_subobject_type ->
        Value1 = erlang:binary_part(Binary,{2,2}),
        <<ST:4,Flags:8,F:1,S:1,C:1,M:1>> = Value1,
        if S=:=1 ->
          if F=:=1 ->
            if Length =:= 4 ->
              erlang:binary_to_list(Value1);
              true ->
                ?ERROR("sr_ero_subobject length is unmatched_1")
            end;
            F=/=1 ->
              if ST=:=1 ->
                if Length =:= 8 ->
                  Value2=erlang:binary_part(Binary,{2,6}),
                  <<ST:4,Flags:8,F:1,S:1,C:1,M:1,_Ipv4_add:32>> = Value2,
                  erlang:binary_to_list(Value2);
                  true ->
                    ?ERROR("sr_ero_subobject length is unmatched_2")
                end;
%%                 ST=:=2 ->
%%                   if Length=:=20 ->
%%                     Value2=erlang:binary_part(Binary,{2,18}),
%%                     <<ST:4,Flags:8,F:1,S:1,C:1,M:1,Ipv6_add:128>> = Value2,
%%                     erlang:binary_to_list(Value2);
%%                     true ->
%%                       ?ERROR("sr_ero_subobject length is unmatched_3")
%%                   end;
                ST=:=3 ->
                  if Length=:=12 ->
                    Value2=erlang:binary_part(Binary,{2,10}),
                    <<ST:4,Flags:8,F:1,S:1,C:1,M:1,_Local_ipv4_add:32,_Remote_ipv4_add:32>> = Value2,
                    erlang:binary_to_list(Value2);
                    true ->
                      ?ERROR("sr_ero_subobject length is unmatched_4")
                  end;
%%                 ST=:=4 ->
%%                   if Length=:=36 ->
%%                     Value2=erlang:binary_part(Binary,{2,34}),
%%                     <<ST:4,Flags:8,F:1,S:1,C:1,M:1,Local_ipv6_add:128,Remote_ipv6_add:128>> = Value2,
%%                     erlang:binary_to_list(Value2);
%%                     true ->
%%                       ?ERROR("sr_ero_subobject length is unmatched_5")
%%                   end;
                ST=:=5 ->
                  if Length=:=20 ->
                    Value2=erlang:binary_part(Binary,{2,18}),
                    <<ST:4,Flags:8,F:1,S:1,C:1,M:1,_Local_node_id:32,_Local_interface_id:32,_Remote_node_id:32,_Remote_interface_id:32>> = Value2,
                    erlang:binary_to_list(Value2);
                    true ->
                      ?ERROR("sr_ero_subobject length is unmatched_5")
                      end;
                true ->
                  ?ERROR("The sr_ero_subobject ST is unreivable")
              end;
            true ->
              ?ERROR("The sr_ero_subobject F is unreivable")
          end;
          S=/=1 ->
            if F=:=1 ->
              if Length =:= 8 ->
                Value2 = erlang:binary_part(Binary,{2,6}),
                <<ST:4,Flags:8,F:1,S:1,C:1,M:1,_SID:32>> = Value2,
                erlang:binary_to_list(Value2);
                true ->
                  ?ERROR("sr_ero_subobject length is unmatched_6")
              end;
              F=/=1 ->
                if ST=:=1 ->
                  if Length =:= 12 ->
                    Value2=erlang:binary_part(Binary,{2,10}),
                    <<ST:4,Flags:8,F:1,S:1,C:1,M:1,_SID:32,_Ipv4_add:32>> = Value2,
                    erlang:binary_to_list(Value2);
                    true ->
                      ?ERROR("sr_ero_subobject length is unmatched_7")
                  end;
%%                   ST=:=2 ->
%%                     if Length=:=24 ->
%%                       Value2=erlang:binary_part(Binary,{2,22}),
%%                       <<ST:4,Flags:8,F:1,S:1,C:1,M:1,SID:32,Ipv6_add:128>> = Value2,
%%                       erlang:binary_to_list(Value2);
%%                       true ->
%%                         ?ERROR("sr_ero_subobject length is unmatched_8")
%%                     end;
                  ST=:=3 ->
                    if Length=:=16 ->
                      Value2=erlang:binary_part(Binary,{2,14}),
                      <<ST:4,Flags:8,F:1,S:1,C:1,M:1,_SID:32,_Local_ipv4_add:32,_Remote_ipv4_add:32>> = Value2,
                      erlang:binary_to_list(Value2);
                      true ->
                        ?ERROR("sr_ero_subobject length is unmatched_9")
                    end;
%%                   ST=:=4 ->
%%                     if Length=:=40 ->
%%                       Value2=erlang:binary_part(Binary,{2,38}),
%%                       <<ST:4,Flags:8,F:1,S:1,C:1,M:1,SID:32,Local_ipv6_add:128,Remote_ipv6_add:128>> = Value2,
%%                       erlang:binary_to_list(Value2);
%%                       true ->
%%                         ?ERROR("sr_ero_subobject length is unmatched_10")
%%                     end;
                  ST=:=5 ->
                    if Length=:=24 ->
                      Value2=erlang:binary_part(Binary,{2,22}),
                      <<ST:4,Flags:8,F:1,S:1,C:1,M:1,_Local_node_id:32,_Local_interface_id:32,_Remote_node_id:32,_Remote_interface_id:32>> = Value2,
                      erlang:binary_to_list(Value2);
                      true ->
                        ?ERROR("sr_ero_subobject length is unmatched_11")
                    end;
                  true ->
                    ?ERROR("The sr_ero_subobject ST is unreivable")
                end;
              true ->
                ?ERROR("The sr_ero_subobject F is unreivable")
            end;
          true ->
            ?ERROR("The sr_ero_subobject S is unreivable")
        end;
      path_key_subobject_type ->
        Value1 = erlang:binary_part(Binary,{byte_size(Binary),-6}),
        <<_Path_key:16,_Pce_id:32>> = Value1,
        erlang:binary_to_list(Value1);
      unsupported_subobject_type ->
        ?ERROR("The Subobject Type is unsupported")
    end;
    true ->
      ?ERROR("It's not matching about subobject")
  end.
