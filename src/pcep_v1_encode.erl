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
-include("pcep_logger.hrl").

%% API
-export([do/1]).

%% encode pcep_message -------------------------------------------------------------------
-spec do(Message ::pcep_message()) ->binary().
do(#pcep_message{version = ?VERSION, flags=Flags, message_type=MessageType, message_length=MessageLength, body=Body}=msg)
  when MessageLength =:= erlang:byte_size(msg) ->
  BodyBin = encode_object_msg(Body),
  <<?VERSION:3, Flags:5, MessageType:8, MessageLength:16, BodyBin/bytes>>;
do(#pcep_message{message_length=MessageLength}=msg)
  when MessageLength /= erlang:byte_size(msg) ->
  ?ERROR("message length doesn't math the field message_length"),
  <<>>.


%% encode tlvs' list -------------------------------------------------------------------
-spec encode_tlv(Tlv::tlv()) -> binary().
encode_tlv(#tlv{type = Type, length = Length, value = Value}) ->
  <<Type:16, Length:16, Value:Length/bytes>>.

-spec encode_tlvs([_]) ->binary().

encode_tlvs([#tlv{}=Tlv | T]) ->
  T2 = encode_tlvs(T),
  <<encode_tlv(Tlv), T2/bytes>>;
encode_tlvs([]) ->
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
  version=Version, flags = Flags, keepAlive = KeepAlive, deadTimer=DeadTimer, sid = Sid, body = Body
}) when Version =:= 1 ->
  BodyBin=encode_tlvs(Body),
  <<Version:3, Flags:5, KeepAlive:8, DeadTimer:8, Sid:8, BodyBin/bytes>>;
encode_object_body(open_ob_type, #open_object{version = Version}) when Version /= 0 ->
  ?ERROR("open object version is not mached"),
  <<>>;
encode_gezhong
%%TODO for fxf
%%TODO for fxf







%% TODO