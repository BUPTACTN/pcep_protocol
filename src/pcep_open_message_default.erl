%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% see pcep_open_message.erl
%%% @end
%%% Created : 01. 四月 2016 下午4:19
%%%-------------------------------------------------------------------
-module(pcep_open_message_default).
-author("root").

-behaviour(pcep_open_message).

%% API
-export([create_open_message/1]).


create_open_message(Version) ->
  %% TODO for fxf 2016-03-31