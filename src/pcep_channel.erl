%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 三月 2016 下午2:56
%%%-------------------------------------------------------------------
-module(pcep_channel).
-author("root").

%% API
-export([open/4,
         send/2,
         get_ets/1]).



%% @doc Opens the Pcep channel to the controller(PCE) described by the
%% `ControllerHandle'.
%%
%% The channel can be opened only in one way: the switch needs actively try to connect
%% to a controllerr. In the scenario the `ControllerHandle' is a four element tuple tagged
%% with remote_peer. The second, third and fourth tuple's element are ip address
%% of the controller, the port it listens on and the protocol type respectively.
-spec open(ChannelSupPid :: pid(), Id :: string(), ControllerHandle, Opts :: [term()]) ->
  StartChildRet :: term() when
  ControllerHandle::{remote_peer, inet:ip_address(), inet:port_number(), Proto} |  {socket, inet:socket(), Proto},
  Proto :: tcp | tls. %% there is only tcp now.
open(Pid, Id, ControllerHandle, Opts) ->
  supervisor:start_child(Pid, [Id, ControllerHandle, Opts]).

send(SwitchId, Message) when is_integer(SwitchId) ->
  Tid = get_ets(SwitchId),
%% Beware that the contents of the table can change mid flight, Pid may be gone,
%% send() may fail.
  lists:foreach(fun({main,Pid}) ->
      try
        % XXX quietly ignores errors returned by send.
        send(Pid, Message)
      catch _:Error ->
        io:format("Cannot send message to controller ~p: ~p\n", [Pid,Error]),
        ignore
      end
                  end,
    ets:lookup(Tid, main));
send(Pid, Message) when is_pid(Pid) ->
  pcep_client:send(Pid, Message). %% TODO check if send function exists.


get_ets(SwitchId) ->
  list_to_atom("pcep_channel_" ++ integer_to_list(SwitchId)).