%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 四月 2016 20:39
%%%-------------------------------------------------------------------
-module(pcep_client_tests).

-author("Xinfeng").

-include_lib("eunit/include/eunit.hrl").
-include("pcep_v1.hrl").
-include("pcep_protocol.hrl").
-import(pcep_protocol,[encode/1]).
-define(PCEP_PORT, 4189).
%% -define(CONTROLLER_IP_ADDRESS,{10, 108, 0, X}).   %% TODO
-define(DEFAULT_CONTROLLER_ROLE, master).
-define(OPEN_MSG_LENGTH, 100).
-define(KEEPALIVE_MSG_LENGTH, 4).
%% API
-export([timer_stop/1]).
mutipart_test_() ->
  [{setup,
    fun start/0
  }].
start() ->
  Message1 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 1,
    message_length = ?OPEN_MSG_LENGTH,
    body = #pcep_object_message{object_class = 1,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 0,
      object_length = ?OPEN_MSG_LENGTH-4,
      body = #pcep_open_msg{
        pcep_open_object = #open_object{version = 1,
          flags = 0,
          keepAlive = 30,
          deadTimer = 0,
          sid = 0,
          open_object_tlvs = #open_object_tlvs{
            open_gmpls_cap_tlv = #gmpls_cap_tlv{
              gmpls_cap_tlv_type = 14,
              gmpls_cap_tlv_length = 4,
              gmpls_cap_flag = 0},
            open_stateful_pce_cap_tlv = #stateful_pec_cap_tlv{
              stateful_pec_cap_tlv_type = 16,
              stateful_pec_cap_tlv_length = 4,
              stateful_pce_cap_tlv_flag = 0,
              stateful_pce_cap_tlv_d = 1,
              stateful_pce_cap_tlv_t = 1,
              stateful_pce_cap_tlv_i = 1,
              stateful_pce_cap_tlv_s = 1,
              stateful_pce_cap_tlv_u = 1},
            open_pcecc_cap_tlv = #pcecc_cap_tlv{
              pcecc_cap_tlv_type = 32,
              pcecc_cap_tlv_length = 4,
              pcecc_cap_tlv_flag = 0,
              pcecc_cap_tlv_g = 1,
              pcecc_cap_tlv_l = 1},
            open_ted_cap_tlv = #ted_cap_tlv{
              ted_cap_tlv_type = 132,
              ted_cap_tlv_length = 4,
              ted_cap_tlv_flag = 0,
              ted_cap_tlv_r = 1},
            open_ls_cap_tlv = #ls_cap_tlv{
              ls_cap_tlv_type = 65280,
              ls_cap_tlv_length = 4,
              ls_cap_tlv_flag = 0,
              ls_cap_tlv_r = 1}}}}}},
  {ok, OpenMessage} = pcep_procotol:encode(Message1),
  Message2 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 2,
    message_length = ?KEEPALIVE_MSG_LENGTH,
    body = #pcep_object_message{}},
  {ok, KeepaliveMessage} = pcep_procotol:encode(Message2),
  Host = "127.0.0.1",
  Port = ?PCEP_PORT,
  {ok, Socket} = gen_tcp:connect(Host, Port, [binary, {packet, 0}]),
  gen_tcp:send(Socket, OpenMessage),
  receive_data(Socket, []),
  timer_start(5000, fun()->gen_tcp:send(Socket, KeepaliveMessage) end ).

receive_data(Socket, SoFar) ->
  receive
    {tcp, Socket, Bin} ->
      io:format(Bin);
    {tcp_closed, Socket} ->
      list_to_binary(SoFar)
  end.
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
%% open_msg_marge() ->
%%   Message = #pcep_message{
%%   version = 1,
%%   flags = 0,
%%   message_type = 1,
%%   message_length = ?OPEN_MSG_LENGTH,
%%   body = #pcep_object_message{object_class = 1,
%%     object_type = 1,
%%     res_flags = 0,
%%     p = 1,
%%     i = 0,
%%     object_length = ?OPEN_MSG_LENGTH-4,
%%     body = #pcep_open_msg{
%%       pcep_open_object = #open_object{version = 1,
%%         flags = 0,
%%         keepAlive = 30,
%%         deadTimer = 0,
%%         sid = 0,
%%         open_object_tlvs = #open_object_tlvs{
%%           open_gmpls_cap_tlv = #gmpls_cap_tlv{
%%             gmpls_cap_tlv_type = 14,
%%             gmpls_cap_tlv_length = 4,
%%             gmpls_cap_flag = 0},
%%           open_stateful_pce_cap_tlv = #stateful_pec_cap_tlv{
%%             stateful_pec_cap_tlv_type = 16,
%%             stateful_pec_cap_tlv_length = 4,
%%             stateful_pce_cap_tlv_flag = 0,
%%             stateful_pce_cap_tlv_d = 1,
%%             stateful_pce_cap_tlv_t = 1,
%%             stateful_pce_cap_tlv_i = 1,
%%             stateful_pce_cap_tlv_s = 1,
%%             stateful_pce_cap_tlv_u = 1},
%%           open_pcecc_cap_tlv = #pcecc_cap_tlv{
%%             pcecc_cap_tlv_type = 32,
%%             pcecc_cap_tlv_length = 4,
%%             pcecc_cap_tlv_flag = 0,
%%             pcecc_cap_tlv_g = 1,
%%             pcecc_cap_tlv_l = 1},
%%           open_ted_cap_tlv = #ted_cap_tlv{
%%             ted_cap_tlv_type = 132,
%%             ted_cap_tlv_length = 4,
%%             ted_cap_tlv_flag = 0,
%%             ted_cap_tlv_r = 1},
%%           open_ls_cap_tlv = #ls_cap_tlv{
%%             ls_cap_tlv_type = 65280,
%%             ls_cap_tlv_length = 4,
%%             ls_cap_tlv_flag = 0,
%%             ls_cap_tlv_r = 1}}}}}},
%%   {ok, OpenMessage} = pcep_procotol:encode(Message).
%%
%% keepalive_msg_marge() ->
%%   Message = #pcep_message{
%%     version = 1,
%%     flags = 0,
%%     message_type = 1,
%%     message_length = ?KEEPALIVE_MSG_LENGTH,
%%     body = #pcep_object_message{}},
%%   {ok, KeepaliveMessage} = pcep_procotol:encode(Message).





%% test() ->
%%   Message = {
%%   version = 1,
%%   flags = 0,
%%   message_type = 1,
%%   message_length = ?OPEN_MSG_LENGTH,
%%   body = {object_class = 1,
%%     object_type = 1,
%%     res_flags = 0,
%%     p = 1,
%%     i = 0,
%%     object_length = ?OPEN_MSG_LENGTH-4,
%%     body = 1}},
%%     io:format("msg is ~p~n",Message).
