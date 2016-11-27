%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% Spawn delay solution test
%%% @end
%%% Created : 27. 十一月 2016 20:49
%%%-------------------------------------------------------------------
-module(pcep_client_v6).
-author("Xinfeng").

-define(PCEP_PORT,4189).
%% -define(Controller_Host,"10.108.66.142").

%% API
-export([start_link/2,start/2,timer_stop/1,start1/1,ets_init/0]).

start_link(Host,SwitchId) ->
  spawn(pcep_client_v6,start,[Host,SwitchId]).

ets_init() ->
  ets:new(socket_list,[named_table]).

start(Host,SwitchId) ->
  Port = ?PCEP_PORT,
  {ok,Socket} = gen_tcp:connect(Host,Port,[binary,{packet,0}]),
  io:format("Socket is ~p~n",[Socket]),
  ets:insert(socket_list,{SwitchId,Socket}).

start1(SwitchId) ->
  {ok,OpenMessage} = pcep_msg_create:open_msg_creating(),
  KeepaliveMessage = <<32,2,0,4>>,
  Link_Num = linc_pcep_config:link_ip_num(SwitchId),
  {ok,Ls_report_node_Message} = pcep_msg_create:ls_report_node_msg_creating(SwitchId),
  case Link_Num of
    0 ->
      io:format("No Link exist on the switch~n");
    1 ->
      {ok,Ls_report_link_0_Message} = pcep_msg_create:ls_report_link_msg_0_creating(SwitchId),
      Socket1 = ets:match(socket_list,{SwitchId,'$1'}),
      Socket = element(2,lists:nth(1,Socket1)),
      gen_tcp:send(Socket,OpenMessage),
      receive_data(Socket,[]),
      gen_tcp:send(Socket,KeepaliveMessage),
      receive_data(Socket,[]),
      gen_tcp:send(Socket,Ls_report_node_Message),
      gen_tcp:send(Socket,Ls_report_link_0_Message),
      Pid = spawn(fun() -> receive_data1(Socket,[]) end),
      gen_tcp:controlling_process(Socket,Pid),
      timer_start(30000,fun() -> gen_tcp:send(Socket,KeepaliveMessage) end);
    _ ->
      Ls_report_link_1_Message = pcep_msg_create:ls_report_link_msg_1_creating(SwitchId),
      {ok,Ls_report_link_0_Message} = pcep_msg_create:ls_report_link_msg_0_creating(SwitchId),
      Socket1 = ets:match(socket_list,{SwitchId,'$1'}),
      Socket = element(2,lists:nth(1,Socket1)),
      gen_tcp:send(Socket,OpenMessage),
      receive_data(Socket,[]),
      gen_tcp:send(Socket,KeepaliveMessage),
      receive_data(Socket,[]),
      gen_tcp:send(Socket,Ls_report_node_Message),
      gen_tcp:send(Socket,Ls_report_link_1_Message),
      gen_tcp:send(Socket,Ls_report_link_0_Message),
      Pid = spawn(fun() -> receive_data1(Socket,[]) end),
      io:format("Pid in v3 is~p~n",[Pid]),
      gen_tcp:controlling_process(Socket,Pid),
      timer_start(30000,fun() -> gen_tcp:send(Socket,KeepaliveMessage) end)
  end.

receive_data(Socket,SoFar) ->
  receive
    {tcp,Socket,Bin} ->
      io:format(Bin);
    {tcp_close,Socket} ->
      list_to_binary(SoFar)
  end.

receive_data1(Socket,SoFar) ->   %% TODO
  receive
    {tcp,Socket,Bin} ->
      {H,L} = split_binary(Bin,2),
      if H =:= <<32,12>> ->
        io:format("PCIn Msg is ~p~n",[Bin]),

%%         {B,O1} = split_binary(L,2),
%%         <<Length:16>> = B,
%%         if (Length-4) rem 152 =:= 0 ->
%%           Num = (Length-4) div 152,
%%           case Num of
%%               1->
%%
%%           end
        PcrptMsg = pcep_msg_create:pcrpt_msg_creating(L),
        gen_tcp:send(Socket,PcrptMsg),
        receive_data1(Socket,[]);
        true ->
          receive_data1(Socket,[])
      end,
      io:format(Bin);
    {tcp_closed,Socket} ->
      list_to_binary(SoFar)
  end.

timer_start(Time,Fun) ->
  spawn(fun() -> tick(Time,Fun) end).

timer_stop(Process_name) ->
  Pid = whereis(Process_name),
  if Pid == undefined ->
    io:format("can not find process in register table")
  end,
  if true ->
    Pid ! stop
  end.

tick(Time,Fun) ->
  receive
    stop ->
      void
  after Time ->
    Fun(),
    tick(Time,Fun)
  end.