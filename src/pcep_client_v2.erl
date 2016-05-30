%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 四月 2016 21:04
%%%-------------------------------------------------------------------
-module(pcep_client_v2).
-author("Xinfeng").


-include("pcep_protocol.hrl").
-include("pcep_v1.hrl").
%% -include("pcep_ls_v2.hrl").
%% -include("pcep_stateful_pce_v2.hrl").
%% -include("pcep_onos.hrl").
%% API
-export([create_error/2]).

%% @doc Create an error message.
-spec create_error(atom(),atom()) -> pcep_error_msg().
create_error(Type,Value) ->
  #error_object{error_type = Type,
  error_value = Value}.
