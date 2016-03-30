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

-include("pcep_protocol.hrl").
-include("pcep_ls_v2.hrl").
-include("pcep_v1.hrl").
-include("pcep_stateful_pce_v2.hrl").
-include("pcep_logger.hrl").

%% API
-export([]).


%%------------------------------------------------------------------------------
%% API functions
%%------------------------------------------------------------------------------

%% @doc Actual decoding of the message.
-spec do(Binary::binary()) -> {ok, pcep_message(), binary()}.
do(Binary) when ?PCEP_COMMON_HEADER_SIZE > byte_size(Binary) ->
  {error, binary_too_small};
do(Binary) ->
  <<Version:3, Flags:5, MessageType:8, MessageLength:16, Binary2/bytes>> = Binary,
  case MessageLength =:= byte_size(Binary) of
    false ->
      {error, binary_too_small};
    true ->
      MsgType = ?MESSAGETYPEMOD(MessageType),
      Body = decode_object_msg(MsgType, Binary2),
      {ok, #pcep_message{version = Version, message_type = MessageType, message_length = MessageLength, body = Body}}
  end.



%% @doc decode Object
%%-spce decode_object_msg(atom(), binary()) -> pcep_object_message().
decode_object_msg(Atom, Binary) ->
  <<Class:8, Type:4, Flags:2, P:1, I:1, Ob_length:16, BodyBin/bytes>> = Binary,
  ClassType = ?CLASSTYPEMOD(Class, Type),
  IsLegal = ?ISLEGAL(Atom, ClassType),
  case IsLegal of
    true ->
      Tlvs = decode_object_body(ClassType, BodyBin),
      #pcep_object_message{object_class = Class, object_type = Type, res_flags = Flags, p = P, i = I, object_length = Ob_length, body = Tlvs};
    false ->
      ?ERROR("Message Type and Class type don't match!"),
      <<>>
  end.

%% @doc decode object body
-spec decode_object_body(atom(), binary()) -> any().
decode_object_body(open_ob_type, Binary) ->
  <<Version:3, Flags:5, Keepalive:8, DeadTimer:8, SID:8, Tlvs/bytes>> = Binary,
  DTlvs = decode_tlvs(Tlvs),
  #open_object{version = Version, flags = Flags, keepAlive = Keepalive, deadTimer = DeadTimer, sid = SID, tlvs = DTlvs}.
%%decode_object_body(rp_ob_type, Binary) ->
  .%% TODO for fxf 2016-03-28


%% @doc decode the list of tlvs from binary format to object format
-spec decode_tlvs(binary()) -> list().
decode_tlvs(Binary) ->
  <<Type:16/integer, Length:16,RstTlvs/bytes>> = Binary,
  M = Length*8,
  <<Value:M, Tlvs/bytes>> = RstTlvs,
  if
    byte_size(Tlvs)>0 ->
      Tlv = decode_tlv(Type, Length, Value),
      [Tlv, decode_tlvs(Tlvs)];
    true ->
      Tlv = decode_tlv(Type, Length, Value),
      [Tlv]
  end.


-spec decode_tlv(Type, Length, Value) -> Rtn when Type::integer(),Length::integer(),Value::binary(),Rtn::any().
decode_tlv(Type, Length, Value) ->
  %% TODO for fxf 2016-03-28
  "a".