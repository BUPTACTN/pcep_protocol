%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 九月 2016 9:57
%%%-------------------------------------------------------------------
-module(test1).
-author("Xinfeng").

%% API
-export([test/0,tuple_test/1,ip_to_int/1,switch_filter/1,switch_find/1]).


test() ->
  O = {a,
  %%  agalgjoaj
  b},
  io:format("agag is ~p~n",[O]).
tuple_test(PP) ->
  Links = [{{1,6},{2,5}},
    {{1,5},{4,6}},
    {{2,7},{3,4}},
    {{4,1},{1,4}},
    {{2,6},{4,5}},
    {{4,4},{3,3}}],
  N = length(Links),
  for(1,N,fun(I) -> LinkI = lists:nth(I,Links),
    Switch = element(1,LinkI),
    SwitchI = element(1,Switch),
    Switch1 = element(2,LinkI),
    SwitchJ = element(1,Switch1),
    if SwitchI == PP ->
      R = element(2,LinkI),
      {S,D} = R,
      if S > PP ->
        R;
        true ->
          {error,unfinded}
            end;
      SwitchJ == PP ->
        T = element(1,LinkI),
        {S1,D1} = T,
        if S1 > PP ->
          T;
          true ->
            {error,unfinded}
        end;
      true ->
        {error,unfinded}
      end
    end).

switch_find(N) ->
  SwitchLists = [{switch,1,
    [{ports,
      [{port,1,[{queues,[]},{port_no,1}]}, {port,3,[{queues,[]},{port_no,2}]}, {port,5,[{queues,[]},{port_no,3}]}, {port,14,[{queues,[]},{port_no,4}]}, {port,19,[{queues,[]},{port_no,5}]}, {port,20,[{queues,[]},{port_no,6}]}, {port,21,[{queues,[]},{port_no,7}]}, {port,22,[{queues,[]},{port_no,8}]}
      ]}]},
    {switch,2,
      [{ports,
        [{port,2,[{queues,[]},{port_no,1}]}, {port,7,[{queues,[]},{port_no,2}]}, {port,9,[{queues,[]},{port_no,3}]}, {port,18,[{queues,[]},{port_no,4}]}, {port,23,[{queues,[]},{port_no,5}]}, {port,24,[{queues,[]},{port_no,6}]}, {port,25,[{queues,[]},{port_no,7}]}, {port,26,[{queues,[]},{port_no,8}]}
        ]}]},
    {switch,3,
      [{ports,
        [{port,8,[{queues,[]},{port_no,1}]}, {port,12,[{queues,[]},{port_no,2}]}, {port,27,[{queues,[]},{port_no,3}]}, {port,28,[{queues,[]},{port_no,4}]}
        ]}]},
    {switch,4,
      [{ports,
        [{port,4,[{queues,[]},{port_no,1}]}, {port,10,[{queues,[]},{port_no,2}]}, {port,11,[{queues,[]},{port_no,3}]}, {port,29,[{queues,[]},{port_no,4}]}, {port,30,[{queues,[]},{port_no,5}]}, {port,31,[{queues,[]},{port_no,6}]}
        ]}]}],
  Switch_able_list = switch_filter(N),
  M = length(Switch_able_list),
  for(1,M,fun(J) ->
    SwitchJ = lists:nth(J,Switch_able_list),
    {A,B} = SwitchJ,
    Switch_N = lists:nth(A,SwitchLists),
    Ports = element(3,Switch_N),
    Port_N = lists:nth(1,Ports),
    Ports_N = element(2,Port_N),
    D = lists:nth(B,Ports_N),
    element(2,D)    %% Output is [Logical_ports]
  end).


switch_filter(N) ->
  A = tuple_test(N),
%%   io:format("A is ~p~n",[A]),
  B = delete({error,unfinded},A),
  lists:reverse(B,[]).   %% Output is [{SwitchId,Port_no}]
%%   F = fun(E) -> E =:= {error,unfinded} end,
%%   lists:dropwhile(F,A).





%%     lists:usort(A),
%%   C = lists:keydelete(unfinded,2,B),
%%   Num = length(A),
%%   for(1,Num,fun(I) ->
%%     if lists:nth(I,A) == {error,unfinded} ->




ip_to_int(A) ->
  B = string:tokens(A,"."),
  IP_1 = element(1,string:to_integer(lists:nth(1,B))),
  IP_2 = element(1,string:to_integer(lists:nth(2,B))),
  IP_3 = element(1,string:to_integer(lists:nth(3,B))),
  IP_4 = element(1,string:to_integer(lists:nth(4,B))),
  (IP_1*16777216)+(IP_2*65536)+(IP_3*256)+IP_4.














for(Max, Max, F) -> [F(Max)];
for(I, Max, F)   -> [F(I)|for(I+1, Max, F)].

delete(Item,List) ->
  delete1(Item,List,[]).

delete1(_,[],L)->
  L;
delete1(Item,[Temp|List],L) ->
  case Item =:= Temp of
    true ->
      delete1(Item,List,L);
    false ->
      delete1(Item,List,[Temp|L])
  end.

