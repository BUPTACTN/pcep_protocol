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
      Body = decode_object_message(MsgType, Binary2),
      {ok, #pcep_message{version = Version, message_type = MessageType, message_length = MessageLength, body = Body}}
  end.


object_class::integer(),
object_type::integer(),
res_flags::integer(),
p::integer(),
i::integer(),
object_length::integer(),
body

%% @doc decode Object
-spce decode_object_message(atom(), binary()) -> pcep_object_message().
decode_object_message(Atom, Binary) ->



%%TODO