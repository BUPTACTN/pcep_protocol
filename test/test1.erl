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
-export([test/0,tuple_test/1,ip_to_int/1,switch_filter/1,switch_find/1,switch_ip/1,get_link_ip/2,link_ip_extract/1]).


test() ->
  O = {a,
  %%  agalgjoaj
  b},
  io:format("agag is ~p~n",[O]).
tuple_test(PP) ->
  Links = [{{0,1},{1,1}}, {{1,2},{2,1}}, {{1,3},{3,1}}, {{2,2},{3,2}}],
  N = length(Links),
  for(1,N,fun(I) -> LinkI = lists:nth(I,Links),
    Switch = element(1,LinkI),
    SwitchI = element(1,Switch),
    PortI = element(2,Switch),
    Switch1 = element(2,LinkI),
    SwitchJ = element(1,Switch1),
    PortJ = element(2,Switch1),
    if SwitchI == PP ->
      {{SwitchI,PortI},{SwitchJ,PortJ}};
      SwitchJ == PP ->
        {{SwitchJ,PortJ},{SwitchI,PortI}};
      true ->
            {{error,unfinded},{error,unfinded}}
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
  B = delete({{error,unfinded},{error,unfinded}},A),
  lists:reverse(B,[]).   %% Output is [{SwitchId,Port_no}]
%%   F = fun(E) -> E =:= {error,unfinded} end,
%%   lists:dropwhile(F,A).

link_ip_extract(N) ->
  Links = switch_filter(N),
  Link_Num = length(Links),
  for(1,Link_Num,fun(I) ->
    Link_I = lists:nth(I,Links),
    {{S1_I,P1_I},{S2_I,P2_I}} = Link_I,
    Sour_IP = get_link_ip(S1_I,P1_I),
    Dest_IP = get_link_ip(S2_I,P2_I),
    Link_Id = lists:min(switch_ip(S2_I)),
    {Link_Id,{Sour_IP,Dest_IP}}
  end).

get_link_ip(Switch_Id,Port_No) ->
  SwitchLists = [
    {switch, 0,
      [{ports, [
        {port,1,[{queues,[]},{port_no,1}]},
        {port,9,[{queues,[]},{port_no,2}]}
      ]}
      ]},
    {switch,1,
      [{ports, [
        {port,2,[{queues,[]},{port_no,1}]},
        {port,3,[{queues,[]},{port_no,2}]},
        {port,4,[{queues,[]},{port_no,3}]},
        {port,10,[{queues,[]},{port_no,4}]}
      ]}]},
    {switch,2,
      [{ports, [
        {port,5,[{queues,[]},{port_no,1}]},
        {port,6,[{queues,[]},{port_no,2}]},
        {port,11,[{queues,[]},{port_no,3}]}
      ]}]},
    {switch,3,
      [{ports, [
        {port,7,[{queues,[]},{port_no,1}]},
        {port,8,[{queues,[]},{port_no,2}]},
        {port,12,[{queues,[]},{port_no,3}]}
      ]}]}],
  Capable_Switch_Ports =
    [{port,1,[{interface,"opt1"},{type,optical},{ip,"10.0.1.1"}]},
      {port,2,[{interface,"opt2"},{type,optical},{ip,"10.0.2.1"}]},
      {port,3,[{interface,"opt3"},{type,optical},{ip,"10.0.2.2"}]},
      {port,4,[{interface,"opt4"},{type,optical},{ip,"10.0.2.3"}]},
      {port,5,[{interface,"opt5"},{type,optical},{ip,"10.0.3.1"}]},
      {port,6,[{interface,"opt6"},{type,optical},{ip,"10.0.3.2"}]},
      {port,7,[{interface,"opt7"},{type,optical},{ip,"10.0.4.1"}]},
      {port,8,[{interface,"opt1"},{type,optical},{ip,"10.0.4.2"}]},
      {port,9,[{interface,"tap1"},{type,tap},{ip,"10.0.1.10"}]},
      {port,10,[{interface,"tap1"},{type,tap},{ip,"10.0.2.10"}]},
      {port,11,[{interface,"tap1"},{type,tap},{ip,"10.0.3.10"}]},
      {port,12,[{interface,"tap1"},{type,tap},{ip,"10.0.4.10"}]}],
  Switch_Config = lists:nth((Switch_Id+1),SwitchLists),
  Ports_Config = element(3,Switch_Config),
  Ports_Config1 = lists:nth(1,Ports_Config),
  Ports_List = element(2,Ports_Config1),
  Port_Config_I = lists:nth(Port_No,Ports_List),
  Port_No1 = element(2,Port_Config_I),
%%     for(1,Port_Num,fun(J) ->
  Logical_Port_Config = element(3,lists:nth(Port_No1,Capable_Switch_Ports)),
  IP_Config = lists:nth(3,Logical_Port_Config),
  IP_Add = element(2,IP_Config),
  ip_to_int(IP_Add).
switch_ip(N) ->
  SwitchLists = [
    {switch, 0,
      [{ports, [
          {port,1,[{queues,[]},{port_no,1}]},
          {port,9,[{queues,[]},{port_no,2}]}
        ]}
      ]},
    {switch,1,
      [{ports, [
          {port,2,[{queues,[]},{port_no,1}]},
          {port,3,[{queues,[]},{port_no,2}]},
          {port,4,[{queues,[]},{port_no,3}]},
          {port,10,[{queues,[]},{port_no,4}]}
        ]}]},
    {switch,2,
      [{ports, [
          {port,5,[{queues,[]},{port_no,1}]},
          {port,6,[{queues,[]},{port_no,2}]},
          {port,11,[{queues,[]},{port_no,3}]}
        ]}]},
    {switch,3,
      [{ports, [
          {port,7,[{queues,[]},{port_no,1}]},
          {port,8,[{queues,[]},{port_no,2}]},
          {port,12,[{queues,[]},{port_no,3}]}
        ]}]}],
  Capable_Switch_Ports =
    [{port,1,[{interface,"opt1"},{type,optical},{ip,"10.0.1.1"}]},
    {port,2,[{interface,"opt2"},{type,optical},{ip,"10.0.2.1"}]},
    {port,3,[{interface,"opt3"},{type,optical},{ip,"10.0.2.2"}]},
    {port,4,[{interface,"opt4"},{type,optical},{ip,"10.0.2.3"}]},
    {port,5,[{interface,"opt5"},{type,optical},{ip,"10.0.3.1"}]},
    {port,6,[{interface,"opt6"},{type,optical},{ip,"10.0.3.2"}]},
    {port,7,[{interface,"opt7"},{type,optical},{ip,"10.0.4.1"}]},
    {port,8,[{interface,"opt1"},{type,optical},{ip,"10.0.4.2"}]},
    {port,9,[{interface,"tap1"},{type,tap},{ip,"10.0.1.10"}]},
    {port,10,[{interface,"tap1"},{type,tap},{ip,"10.0.2.10"}]},
    {port,11,[{interface,"tap1"},{type,tap},{ip,"10.0.3.10"}]},
    {port,12,[{interface,"tap1"},{type,tap},{ip,"10.0.4.10"}]}],
  Switch_Config = lists:nth(N+1,SwitchLists),
  Ports_Config = element(3,Switch_Config),
  Ports_Config1 = lists:nth(1,Ports_Config),
  Ports_List = element(2,Ports_Config1),
  Switch_Port_Num = length(Ports_List),
  Port_Num = length(Capable_Switch_Ports),
  for(1,Switch_Port_Num,fun(I) ->
    Port_Config_I = lists:nth(I,Ports_List),
    Port_No = element(2,Port_Config_I),
%%     for(1,Port_Num,fun(J) ->
    Logical_Port_Config = element(3,lists:nth(Port_No,Capable_Switch_Ports)),
    IP_Config = lists:nth(3,Logical_Port_Config),
    IP_Add = element(2,IP_Config),
    ip_to_int(IP_Add)
  end).



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

