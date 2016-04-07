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
%%-include_lib("kernel/include/inet.hrl").



-define(DEFAULT_HOST, "localhost").
-define(DEFAULT_PORT, 4189).
-define(DEFAULT_VERSION, 1).
-define(DEFAULT_TIMEOUT, timer:seconds(3)). %% TODO

%% 暂时就这么一个版本
client_module(1) -> pcep_client_v1.

%% API
-export([start_link/4]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
  %% if id equals 0, the connection is main connection, otherwise is auxiliary connection
%%  id :: integer(),
  resource_id :: string(),
  controller :: {string(), integer(), atom()},
  %% defined in OpenFlow protocol 1.3, no use in Pcep protocol
%%  aux_connections = [] :: [{tcp, integer()}],
  parent :: pid(),
  %% current version
  version :: integer(),
  %% supported versions
  versions :: [integer()],
  generation_id :: integer(),
  %% TODO ? filter
%%  filter = #async_config{},
  socket :: inet:socket(),
  parser :: pcep_parser(),
  timeout :: integer(),
  supervisor :: pid(),
  ets :: ets:tid(),
  %% whether need change hello_buffer to another var.
%%  hello_buffer = <<>> :: binary(),
  reconnect :: true | false
  %% LINC-OE
  %% defined in OpenFlow protocol 1.3, no use in Pcep protocol
%%  no_multipart = false :: boolean()
}).

%%%===================================================================
%%% API
%%%===================================================================


%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%% For more information on `ControllerHandle' see {@link pcep_channel:open/4}.
%% @end
%%--------------------------------------------------------------------
-spec start_link(Tid :: ets:tid(), ResourceId :: string(),
    ControllerHandle :: {remote_peer, inet:ip_address(), inet:port_number(), Proto} | {socket, inet:socket(), Proto},
    Opts :: proplists:proplist()) ->
  {ok, Pid :: pid()} | ignore |
  {error, Error :: term()} when
  Proto :: tcp | tls.
start_link(Tid, ResourceId, ControllerHandle, Opts) ->
  Parent = get_opt(controlling_process, Opts, erlang:self()),%% self() returns pid.
  gen_server:start_link(?MODULE, {Tid, ResourceId, ControllerHandle, Parent,
    Opts, erlang:self()}, []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the pcep client
%% The pcep_client can start in two different ways depending on the
%% `ControllerHandle'. If this variable is a tuple tagged with remote_peer
%% the client will attempt to connect to the controller. On the other hand,
%% if the variable is a tuple tagged with socket the client will assume that
%% the connection has already been established and move on to sending hello
%% message. For more information on `ControllerHandle' see
%% {@link ofp_channel:open/4}.
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
%% @doc Initializes the ofp_client.
%%

init({Tid, ResourceId, ControllerHandle, Parent, Opts, Sup}) ->
  %% The current implementation of TCP sockets in LING throws exceptions on
  %% errors that occur outside the context of a gen_tcp call. We have to
  %% catch these exceptions not to confuse the supervisor.
  %% TODO
  erlang:process_flag(trap_exit, true),
  Version = get_opt(version, Opts, ?DEFAULT_VERSION),
  %% 合并参数中的两个列表list1和list2并且排序，如果list1和list2有同样的元素，则保留list1的元素，删除list2的元素
  Versions = lists:umerge(get_opt(versions, Opts, []), [Version]),
  Timeout = get_opt(timeout, Opts, ?DEFAULT_TIMEOUT),
  State1 = #state{resource_id = ResourceId,
    parent = Parent,
    versions = Versions,
    timeout = Timeout,
    supervisor = Sup,
    ets = Tid},
  %% init controller, socket, reconnect
  State2 = init_controller_handle(ControllerHandle, State1),
  {ok, State2, 0}.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%% Whenever a gen_server receives a request sent using gen_server:call/2,3
%% or gen_server:multi_call/2,3,4, this function is called to handle the request.
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
handle_call({send, _Message}, _From, #state{socket = undefined} = State) ->
  {reply, {error, not_connected}, State};
handle_call({send, _Message}, _From, #state{parser = undefined} = State) ->
  {reply, {error, parser_not_ready}, State};
%% @doc
handle_call({send, Message}, _From, #state{} = State) ->
  %% see pcep_v1.hrl
  case ?MESSAGETYPEMOD(Message#pcep_message.message_type) of
    Type when Type == open_msg;
      Type ==  keepalive_msg;
      Type == path_computation_request_msg;
      Type == path_computation_reply_msg;
      Type == notification_msg;
      Type == error_msg;
      Type == close_msg;
      Type == pcrpt_msg;
      Type == pcupd_msg;
      Type == pcinitiate_msg;
      Type == lsrpt_msg;
      Type == pclrresv_msg;
      Type == pclabelupd_msg ->
      {reply, do_send(Message, State), State};
    _Else ->
      {reply, {error, {bad_message, Message}}, State}
  end;

handle_call({controlling_process, Pid}, _From, State) ->
  {reply, ok, State#state{parent = Pid}};
handle_call(get_resource_id, _From, #state{resource_id = ResourceId} = State) ->
  {reply, ResourceId, State};
%% It seems nothing changed TODO
handle_call(stop, _From, State) ->
  {stop, normal, ok, State};
handle_call(get_controller_state, _From, #state{controller = {ControllerIP,
  ControllerPort,
  Protocol},
  resource_id = ResourceId,
  socket = Socket,
  version = CurrentVersion,
  versions = SupportedVersions
} = State) ->
  Controller = controller_state(ControllerIP, ControllerPort,
    ResourceId, Socket, Protocol,
    CurrentVersion, SupportedVersions),
  {reply, Controller, State};
%% 如果以上都不匹配，则调用该方法。
handle_call(_Request, _From, State) ->
  {reply, {error, unrecognized_call}, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%% Whenever a gen_server receives a request sent using gen_server:cast/2
%% or gen_server:abcast/2,3, this function is called to handle the request.
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
%% when need to call this? TODO
handle_cast({update_connection_config, Config},
    #state{controller = {IP, Port, Protocol}} = State) ->
  NewController = {proplists:get_value(ip, Config, IP),
    proplists:get_value(port, Config, Port),
    proplists:get_value(protocol, Config, Protocol)},
  NewState1 = reestablish_connection_if_required(NewController, State),
  {noreply, NewState1};
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages.
%% This function is called by a gen_server when a timeout occurs or when
%% it receives any other message than a synchronous or asynchronous request (or a system message).
%% Info is either the atom timeout, if a timeout has occurred, or the received message.
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

%% @doc get opt from list Opts, if doesn't exist, return Default.
get_opt(Opt, Opts, Default) ->
  case lists:keyfind(Opt, 1, Opts) of
    false ->
      Default;
    {Opt, Value} ->
      Value
  end.


%% @doc initialize connection's config to controller
init_controller_handle({remote_peer, Host, Port, Proto}, #state{} = State) ->
  State#state{
    controller = {Host, Port, Proto}, socket = undefined, reconnect = true};
init_controller_handle({socket, Socket, Proto}, #state{} = State) ->
  {ok, {Address, Port}} = inet:peername(Socket),
  Host = retrieve_hostname_from_address(Address),
  State#state{
    controller = {Host, Port, Proto}, socket = Socket, reconnect = false}.



%% @doc get hostname from net address
retrieve_hostname_from_address(Address) ->
  case inet:gethostbyaddr(Address) of
    {ok, Hostent} when Hostent#hostent.h_name =/= undefined ->   %% TODO hostent type finished  ???
      Hostent#hostent.h_name;
    _ ->
      inet_parse:ntoa(Address)
  end.

%% @doc generate description of controller status
controller_state(ConfigControllerIP, ConfigControllerPort, ResourceId,
    Socket, Protocol, CurrentVersion, SupportedVersions) ->
  {ControllerIP, ControllerPort, LocalIP, LocalPort} =
    case Socket of
      undefined ->
        {ConfigControllerIP, ConfigControllerPort,
          undefined, undefined};
      _ ->
        {ok, {CIP, CPort}} = inet:peername(Socket),
        {ok, {LIP, LPort}} = inet:sockname(Socket),
        {CIP, CPort, LIP, LPort}
    end,
  ConnectionState = case {Socket, CurrentVersion} of
                      %% Socket to controller not yet opened
                      {undefined, _} ->
                        down;
                      %% Socket to controller opened,
                      %% but hello message with version not received yet
                      {_, undefined} ->
                        down;
                      {_, _} ->
                        up
                    end,
  #controller_status{
    resource_id = ResourceId,
    controller_ip = ControllerIP,
    controller_port = ControllerPort,
    local_ip = LocalIP,
    local_port = LocalPort,
    protocol = Protocol,
    connection_state = ConnectionState,
    current_version = CurrentVersion,
    supported_versions = SupportedVersions}.


%% @doc handle_send all pcep message. But I wonder why there is no checkout about tcp connection
do_send(#pcep_message{version = Vsn}=Message,
    #state{controller = {_, _, Proto},
      socket = Socket,
      parser = Parser,
      version = Version} = State) when Vsn=:= Version ->
  case pcep_parser:encode(Parser, Message) of
    {ok, Binary} ->
      Size = erlang:byte_size(Binary),
      case Size > (?PCEP_COMMON_HEADER_SIZE+?PCEP_OBJECT_MESSAGE_HEADER_SIZE) of
        false ->
          {error, message_too_short};
        true ->
          send(Proto, Socket, Binary)
      end
  end.




%% @doc send tcp binary data to remote
send(tcp, Socket, Data) ->
  gen_tcp:send(Socket, Data);
%% @doc send tls binary data to remote.
%% TODO there is no tls connection now.
send(tls, Socket, Data) ->
  ssl:send(Socket, Data).
%% @doc close connection to remote node.
close(_, undefined) ->
  ok;
close(tcp, Socket) ->
  gen_tcp:close(Socket);
close(tls, Socket) ->
  ssl:close(Socket).


%% @doc reestablish connection to controller if necessary.
reestablish_connection_if_required(NewController, State) ->
  case NewController /= State#state.controller of
    true when erlang:is_port(State#state.socket) ->
      %% The client is connected to the controller
      NewState = terminate_connection(State,
        external_connection_config_update),
      reconnect(NewState#state.timeout),
      NewState#state{controller = NewController};
    true ->
      State#state{controller = NewController};
    false ->
      State
  end.


terminate_connection(#state{
  controller = {Host, Port, Proto},
  socket = Socket,
  parent = Parent,
  supervisor = Sup,
  ets = Tid} = State, Reason) ->
  close(Proto, Socket),
  ets:delete(Tid, erlang:self()),
  %% Pid ! Msg 语法的意思是发送消息 Msg 到进程 Pid 。大括号里的 self() 参数标明了发送消息的进程
  %% TODO Parent可以使self()，那么往gen_server进程发送消息是如何处理的？
  Parent ! {pcep_closed, erlang:self(), {Host, Port, Reason}},
  State#state{socket = undefined, parser = undefined, version = undefined}.

reconnect(Timeout) ->
  erlang:send_after(Timeout, erlang:self(), timeout).