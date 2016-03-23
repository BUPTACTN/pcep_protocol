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

%% API
-export([do/1]).

%% encode pcep_message
-spec do(Message ::pcep_message()) ->binary().
do(#pcep_message{version = ?VERSION, flags=Flags, message_type=MessageType, message_length=MessageLength, body=Body}) ->
  BodyBin = encode_object_msg(Body),
  <<?VERSION:3, Flags:5, MessageType:8, MessageLength:16, BodyBin/bytes>>.


%% encode common body, which is object related message
-spec encode_object_msg(ObjectMessage::pcep_object_message()) -> binary() | null(). %%todo whether null() is right?
encode_object_msg(#pcep_object_message{}) ->



%% encode open message as object related message's body.
-spec encode_object_open_msg(OpenMessage::pcep_open()) -> binary() | null(). %%todo whether null() is right?



-spec encode_object_open_tlv_demo_msg(OpenTlvDemo::open_object_tlv_demo()) ->binary() | null(). %%todo whether null() is right?

%% TODO