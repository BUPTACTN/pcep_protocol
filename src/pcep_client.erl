%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 三月 2016 下午4:23
%%%-------------------------------------------------------------------
-module(pcep_client).
-author("root").

-behaviour(gen_server).

-include("pcep_protocol.hrl").
-include("pcep_v1.hrl").
-include("pcep_ls_v2.hrl").
-include("pcep_stateful_pce_v2.hrl").
-include_lib("kernel/include/inet.hrl").



-define(DEFAULT_HOST, "localhost").
-define(DEFAULT_PORT, 4189).
-define(DEFAULT_VERSION, 1).
-define(DEFAULT_TIMEOUT, timer:seconds(3)). %% TODO

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
  id :: integer(),
  resource_id :: string(),
  controller :: {string(), integer(), atom()},
  aux_connections = [] :: [{tcp, integer()}],
  parent :: pid(),
  version :: integer(),
  versions :: [integer()],
  generation_id :: integer(),
%%  filter = #async_config{},
  socket :: inet:socket(),
  parser :: ofp_parser(),
  timeout :: integer(),
  supervisor :: pid(),
  ets :: ets:tid(),
%%  hello_buffer = <<>> :: binary(),
  reconnect :: true | false
  %% LINC-OE
%%  no_multipart = false :: boolean()
}).

%%%===================================================================
%%% API
%%%===================================================================


start_link(Tid, ResourceId, ControllerHandle, Opts) ->
  start_link(Tid, ResourceId, ControllerHandle, Opts, main).


%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%% For more information on `ControllerHandle' see {@link pcep_channel:open/4}.
%% @end
%%--------------------------------------------------------------------
-spec start_link(Tid :: ets:tid(), ResourceId :: string(),
    ControllerHandle ::
    {remote_peer, inet:ip_address(), inet:port_number(), Proto} |
    {socket, inet:socket(), Proto},
    Opts :: proplists:proplist(),
    Type :: main | {aux, integer(), pid()}) ->
  {ok, Pid :: pid()} | ignore |
  {error, Error :: term()} when
  Proto :: tcp | tls.
start_link(Tid, ResourceId, ControllerHandle, Opts, Type) ->
  Parent = get_opt(controlling_process, Opts, self()),
  gen_server:start_link(?MODULE, {Tid, ResourceId, ControllerHandle, Parent,
    Opts, Type, self()}, []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
