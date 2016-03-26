%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% Pcep Protcol behaviour.
%%% @end
%%% Created : 23. 三月 2016 下午4:42
%%%-------------------------------------------------------------------
-module(gen_pcep_protocol).
-author("root").

%% API
-export([]).


%% encode Pcep Protocol message from Erlang representation to binary.
-callback encode(Message::pcep_protocol:pcep_message()) ->
  {ok, Binary::binary()} | {error, Reason::any()}.


%% Decode Pcep Protocol message from binary to Erlang representation.
-callback decode(Binary::binary()) ->
  {ok, Message::pcep_protocol:pcep_message(), binary()} | {error, Reason::any()}.
