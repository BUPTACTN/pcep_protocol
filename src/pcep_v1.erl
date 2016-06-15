%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc pcep protocol version 1. See http://www.rfc-editor.org/rfc/rfc5440.txt
%%% in this module,
%%%
%%% @end
%%% Created : 23. 三月 2016 下午8:40
%%%-------------------------------------------------------------------
-module(pcep_v1).
-author("root").

-include("pcep_protocol.hrl").
-include("pcep_v1.hrl").

-behaviour(gen_pcep_protocol).

%% API
-export([encode/1, decode/1]).


%%------------------------------------------------------------------------------
%% gen_pcep_protocol callbacks
%%------------------------------------------------------------------------------
-spec encode(Message :: pcep_message()) -> {ok, binary()} | {error, any()}.

%% @doc Encode erlang representation to binary.
encode(Message) ->
  try
    io:format("Enter pcep_v1 module ~n~n"),
    {ok, pcep_v1_encode:do(Message)},
    io:format("pcep_v1 module encode output ~p~n", [pcep_v1_encode:do(Message)])
  catch
    _:Exception ->
      {error, Exception}
  end.

%% @doc Decode binary to erlang representation.
-spec decode(Binary :: binary()) -> {ok, pcep_message(), binary()} | {error, any()}.
decode(Binary) ->
  try
    pcep_v1_decode:do(Binary)
  catch
    _:Exception ->
      {error, Exception}
  end.