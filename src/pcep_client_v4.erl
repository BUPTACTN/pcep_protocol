%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 十一月 2016 15:40
%%%-------------------------------------------------------------------
-module(pcep_client_v4).
-author("Xinfeng").
-define(PCEP_PORT,4189).
%% API
-export([start/2,timer_stop/1]).


start(Host,SwitchNum) ->
%%   Host = ?Controller_Host,
  Port = ?PCEP_PORT,
%%   io:format("Host IP is ~p~n",[Host]),
  {ok,OpenMessage} = pcep_msg_create:open_msg_creating(),
%%   io:format("OpenMsg in v3 is ~p~n",[OpenMessage]),
  KeepaliveMessage = <<32,2,0,4>>,
  Ls_report_nodes_Message = pcep_msg_create_v2:ls_report_nodes_msg_creating(SwitchNum),
%%   Link_Num = linc_pcep_config:link_ip_num(SwitchId),
%%   io:format("NodeMsg in v3 is ~p~n",[Ls_report_node_Message]),
%%   case Link_Num of
%%     0 ->
%%       io:format("No Link exist on the switch~n");
%%     1 ->
%%       {ok,Ls_report_link_0_Message} = pcep_msg_create:ls_report_link_msg_0_creating(SwitchId),
%%       {ok,Socket} = gen_tcp:connect(Host,Port,[binary,{packet,0}]),
%%       gen_tcp:send(Socket,OpenMessage),
%%       receive_data(Socket,[]),
%%       gen_tcp:send(Socket,KeepaliveMessage),
%%       receive_data(Socket,[]),
%%       gen_tcp:send(Socket,Ls_report_node_Message),
%% %%       gen_tcp:send(Socket,Ls_report_link_1_Message),
%%       gen_tcp:send(Socket,Ls_report_link_0_Message),
%%       Pid = spawn(fun() -> receive_data1(Socket,[]) end),
%%       gen_tcp:controlling_process(Socket,Pid),
%%       timer_start(30000,fun() -> gen_tcp:send(Socket,KeepaliveMessage) end);
%%     _ ->
      Ls_report_links_1_Message = pcep_msg_create_v2:ls_report_links_msg_1_creating(SwitchNum),
  io:format("LinksMsg_1 is ~p~n",[Ls_report_links_1_Message]),
      Ls_report_link_1_Message = pcep_msg_create:ls_report_link_msg_1_creating(SwitchNum-1),
      io:format("LinkMsg_1 in v3 is ~p~n",[Ls_report_link_1_Message]),
  {ok,Ls_report_link_0_Message} = pcep_msg_create:ls_report_link_msg_0_creating(SwitchNum-1),
      io:format("LinkMsg_0 in v3 is ~p~n",[Ls_report_link_0_Message]),
      {ok,Socket} = gen_tcp:connect(Host,Port,[binary,{packet,0}]),
%%       io:format("connect start~n"),
      gen_tcp:send(Socket,OpenMessage),
      receive_data(Socket,[]),
      gen_tcp:send(Socket,KeepaliveMessage),
      receive_data(Socket,[]),
      gen_tcp:send(Socket,Ls_report_nodes_Message),
      gen_tcp:send(Socket,Ls_report_links_1_Message),
  gen_tcp:send(Socket,Ls_report_link_1_Message),
  gen_tcp:send(Socket,Ls_report_link_0_Message),
      Pid = spawn(fun() -> receive_data1(Socket,[]) end),
      io:format("Pid in v3 is~p~n",[Pid]),
      gen_tcp:controlling_process(Socket,Pid),
      timer_start(30000,fun() -> gen_tcp:send(Socket,KeepaliveMessage) end).
%%   end.

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