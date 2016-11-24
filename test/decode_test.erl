%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 四月 2016 20:19
%%%-------------------------------------------------------------------
-module(decode_test).
-author("Xinfeng").
%% -include("pcep_logger.hrl").
%% API
-export([decode_tlv/1]).
decode_tlv(Binary) ->
  Length=erlang:byte_size(Binary)-4,
  <<Type:16>> = erlang:binary_part(Binary,{0,2}),
  M = Length*8,
  <<Value:M>> = erlang:binary_part(Binary,{4,Length}),
  if <<Type:16,Length:16,Value:M>> =:= Binary ->
    Value1 = erlang:binary_part(Binary,{byte_size(Binary),-Length}),
    erlang:binary_to_list(Value1);
    true ->
      <<111111>>
  end,
  calendar:now_to_local_time(B).

%% <<Type:16,Length:16,Value:(Length*8)>>.