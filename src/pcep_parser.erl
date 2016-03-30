%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 三月 2016 下午9:17
%%%-------------------------------------------------------------------
-module(pcep_parser).
-author("root").

%% API
-export([parse/2, new/1, encode/2]).

-include("pcep_protocol.hrl").

-spec new(integer()) -> {ok, pcep_parser()}.
new(Version) ->
  case ?MOD(Version) of
    unsupported ->
      {error, unsupported_version};
    Module ->
      {ok, #pcep_parser{version = Version,
        module = Module}}
  end.

%% @doc Parse binary to Pcep Protocol messages.
-spec parse(pcep_parser(), binary()) -> {ok, pcep_parser(), [pcep_message()]}.
parse(Parser, Binary) ->
  case parse(Binary, Parser, []) of
    {ok, NewParser, Messages} ->
      {ok, NewParser, lists:reverse(Messages)};
    {error,Exception} ->
      {error,Exception}
  end.

%% @doc Encode a message using a parser.
-spec encode(pcep_parser(), pcep_message()) -> {ok, Binary :: binary()} |
{error, Reason :: term()}.
encode(#pcep_parser{module = Module}, Message) ->
  Module:encode(Message).


%%%-----------------------------------------------------------------------------
%%% Internal functions
%%%-----------------------------------------------------------------------------

-spec parse(binary(), pcep_parser(), [pcep_message()]) ->
  {ok, pcep_parser(), [pcep_message()]} | {error,term()}.
parse(Binary, #pcep_parser{module = Module, stack = Stack} = Parser, Messages) ->
  NewBinary = <<Stack/binary, Binary/binary>>,
  case Module:decode(NewBinary) of
    {error, binary_too_small} ->
      {ok, Parser#pcep_parser{stack = NewBinary}, Messages};
    {error,Exception} ->
      {error,Exception};
    {ok, Message, Leftovers} ->
      parse(Leftovers, Parser#pcep_parser{stack = <<>>},
        [Message | Messages])
  end.