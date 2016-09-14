%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 四月 2016 21:04
%%%-------------------------------------------------------------------
%%% message recv and send module, simple fsm
-module(pcep_client_v2).
-author("Xinfeng").


-include("pcep_protocol.hrl").
-include("pcep_v1.hrl").
%% -include("pcep_ls_v2.hrl").
%% -include("pcep_stateful_pce_v2.hrl").
%% -include("pcep_onos.hrl").
-define(PCEP_Port,4189).
-define(IP_Add,"10.108.68.180").
%% API
-export([create_error/2,
  start_client/0]).

%% @doc Create an error message.
-spec create_error(atom(),atom()) -> pcep_error_msg().
create_error(Type,Value) ->
  #error_object{error_type = Type,
  error_value = Value}.

start_client() ->
  {ok,Socket} = gen_tcp:connect(?IP_Add,?PCEP_Port,[binary,{packet,0}]),
  %% 新建一个进程负责接收消息
  Pid = spawn(fun() -> loop() end),
  %% 监听指定进程
  gen_tcp:controlling_process(Socket,Pid),
  %% 发送消息
  KeepaliveMessage = <<32,2,0,4>>,
  timer_start(30000, fun()->gen_tcp:send(Socket, KeepaliveMessage) end ).

loop() ->
  receive
    {tcp,Socket,Bin} ->
%%       Res = binary_to_term(Bin),
      io:format("Client:Receive message = ~p~n",[Bin]),
      {H,L} = split_binary(Bin,2),
      if
        H =:= <<32,2>> ->
          KeepaliveMsg = <<32,2,0,4>>,
          gen_tcp:send(Socket,KeepaliveMsg);  %% TODO Keepalive needn't
        %% TODO after LINC finished
      true ->
        io:format("It is not correct msg~n")

      end,
      loop();
    {tcp_closed,Socket} ->
      io:format("Scoket is closed! ~n")
  end.

%% sendMsg(Socket) ->
%%   gen_tcp:send(Socket,)

timer_start(Time, Fun) ->
  register(keepalive, spawn(
    fun() -> tick(Time, Fun) end
  )).

timer_stop(Process_name) ->
  Pid = whereis(Process_name),
  if Pid == undefined ->
    io:format("can not find process in register table")
  end,
  if true ->
    Pid ! stop
  end.

tick(Time, Fun) ->
  receive
    stop ->
      void
  after Time ->
    Fun(),
    tick(Time, Fun)
  end.