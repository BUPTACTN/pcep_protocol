%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 三月 2016 下午2:53
%%%-------------------------------------------------------------------
-module(pcep_channel_sup).
-author("root").

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link(integer()) ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link(SwitchId) ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, [SwitchId]).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).
init([SwitchId]) ->
  Tid = pcep_channel:get_ets(SwitchId),
  %% Tid --
  %% bag -- 同键表，允许多个元素拥有相同的键
  %% public -- 创建一个公共表，任何知道此表标识符的进程都能读取和写入它
  %% named_table -- 如果设置了此选项，Tid就可以作为tableId被用于后续的表操作
  %% {read_concurrency,true} -- 允许并发的读操作
  ets:new(Tid, [named_table, public, bag, {read_concurrency, true}]),
  %% http://erlang.org/doc/man/supervisor.html
  %% Page 350
  %% TODO call pcep_client:start_link(Tid), but I cannot find this function in pcep_client
  ClientSpec = {pcep_client, {pcep_client, start_link, [Tid]}, transient, 1000, worker, [pcep_client]},
  %% 10秒内重启超过5次，就关掉全部进程然后退出
  {ok, {{simple_one_for_one, 5, 10}, [ClientSpec]}}.


%%%===================================================================
%%% Internal functions
%%%===================================================================
