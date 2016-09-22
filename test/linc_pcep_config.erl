%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(linc_pcep_config).
-author("Xinfeng").

%% API
-export([switch_ip_num/1,switch_ip/1,link_ip_num/1,for/3,link_ip_extract/1]).

%% LS Report Link Msg create
link_ip_extract(SwitchId) ->
  Links = switch_filter(SwitchId),
  Link_Num = length(Links),
  for(1,Link_Num,fun(I) ->
    Link_I = lists:nth(I,Links),
    {{S1_I,P1_I},{S2_I,P2_I}} = Link_I,
    Sour_IP = get_link_ip(S1_I,P1_I),
    Dest_IP = get_link_ip(S2_I,P2_I),
    Link_Id = lists:min(switch_ip(S2_I)),
    {Link_Id,{Sour_IP,Dest_IP}}
  end).

link_ip_num(SwitchId) ->
  {ok,Link_ip} = link_ip_extract(SwitchId),
  length(Link_ip).

%% get_link_id(SwitchId) ->


get_link_ip(Switch_Id,Port_No) ->
  {ok,SwitchLists} = application:get_env(linc,logical_switches),
  Capable_Switch_Ports = application:get_env(linc,capable_switch_ports),
  Switch_Config = lists:nth((Switch_Id+1),SwitchLists),
  Ports_Config = element(3,Switch_Config),
  Ports_Config1 = lists:nth(1,Ports_Config),
  Ports_List = element(2,Ports_Config1),
  Port_Config_I = lists:nth(Port_No,Ports_List),
  Port_No1 = element(2,Port_Config_I),
  Logical_Port_Config = element(3,lists:nth(Port_No1,Capable_Switch_Ports)),
  IP_Config = lists:nth(3,Logical_Port_Config),
  IP_Add = element(2,IP_Config),
  ip_to_int(IP_Add).


get_capable_switch(Switch_Id) ->
  {ok,Links} = application: get_env(linc,optical_links),
  Link_Num = length(Links),
%%   for(1,Link_Num,fun(I) -> LinkI = lists:nth(I,Links),
%%     Switch_Port_First = element(1,LinkI),
%%     Switch_First = element(1,Switch_Port_First),
%%     Switch_Port_Second = element(2,LinkI),
%%     Switch_Second = element(1,Switch_Port_Second),
%%     if Switch_First == Switch_Id ->
%%       R1 = element(2,LinkI),
%%       {S1,_D1} = R1,
%%       if S1 > Switch_Id ->
%%         R1;
%%         true ->
%%           {error,unfinded}
%%         end;
%%       Switch_Second == Switch_Id ->
%%         R2 = element(1,LinkI),
%%         {S2,_D2} = R2,
%%         if S2 > Switch_Id ->
%%           R2;
%%           true ->
%%             {error,unfinded}
%%           end;
%%       true ->
%%         {error,unfinded}
%%       end
%%   end).
  for(1,Link_Num,fun(I) ->
    LinkI = lists:nth(I,Links),
    Switch = element(1,LinkI),
    SwitchI = element(1,Switch),
    PortI = element(2,Switch),
    Switch1 = element(2,LinkI),
    SwitchJ = element(1,Switch1),
    PortJ = element(2,Switch1),
    if SwitchI == Switch_Id ->
      {{SwitchI,PortI},{SwitchJ,PortJ}};
      SwitchJ == Switch_Id ->
        {{SwitchJ,PortJ},{SwitchI,PortI}};
    true ->
      {{error,unfinded},{error,unfinded}}
  end
end).

%% switch_ip_extract(Switch_Id) ->
%%   {ok,Switchs} = application:get_env(linc,logical_switches),
%%   Switch_able_list = switch_filter(Switch_Id),
%%   Switch_able_list_Num = length(Switch_able_list),
%%   for(1,Switch_able_list_Num,fun(J) ->
%%     Switch_Port_J = lists:nth(J,Switch_able_list),
%%     {Switch,Port} = Switch_Port_J,
%%     Switch_N = lists:nth(Switch,Switchs),  %% {switch,1,[{...},...]}
%%     Ports = element(3,Switch_N),  %% [{ports,[{port,1,[{...},...]}]}]
%%     Port_N = lists:nth(1,Ports),  %% {ports,[{port,1,[{...},...]}]}
%%     Ports_N = element(2,Port_N),  %% [{port,1,[{...},...]}]
%%     D = lists:nth(Port,Ports_N),  %% {port,1,[{...},...]}
%%     element(2,D)       %% Output is [Logical_ports]
%%   end).

switch_ip(Switch_Id) ->
  {ok,Switch_Lists} = application:get_env(linc,logical_switches),
  {ok,Capable_Switch_Ports} = application:get_env(linc,capable_switch_ports),
  Switch_Config = lists:nth(Switch_Id+1,Switch_Lists),
  Ports_Config = element(3,Switch_Config),
  Ports_Config1 = lists:nth(1,Ports_Config),
  Ports_List = element(2,Ports_Config1),
  Switch_Port_Num = length(Ports_List),
  _Port_Num = length(Capable_Switch_Ports),
  for(1,Switch_Port_Num,fun(I) ->
    Port_Config_I = lists:nth(I,Ports_List),
    Port_No = element(2,Port_Config_I),
%%     for(1,Port_Num,fun(J) ->
    Logical_Port_Config = element(3,lists:nth(Port_No,Capable_Switch_Ports)),
    IP_Config = lists:nth(3,Logical_Port_Config),
    IP_Add = element(2,IP_Config),
    ip_to_int(IP_Add)
  end).

switch_ip_num(Switch_Id) ->
  {ok,Switch_IP_List} = switch_ip(Switch_Id),
  length(Switch_IP_List).

%% switch_ip_extract(Switch_Id) ->
%%   {ok,Switchs} = application:get_env(linc,logical_switches),
%%   Switch_Config = lists:nth(Switch_Id,Switchs),


switch_filter(N) ->
  A = get_capable_switch(N),
  B = delete({{error,unfinded},{error,unfinded}},A),
  lists:reverse(B,[]).










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
