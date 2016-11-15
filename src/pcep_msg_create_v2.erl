%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 十一月 2016 14:48
%%%-------------------------------------------------------------------
-module(pcep_msg_create_v2).
-author("Xinfeng").

%% API
-export([ls_report_nodes_msg_creating/1,ls_report_links_msg_1_creating/1]).

ls_report_nodes_msg_creating(SwitchNum) ->
  LS_Report_Nodes_Msgs_1 = linc_pcep_config:for(1,SwitchNum,fun(I) ->
    LS_Report_Node_Msgs_1 = pcep_msg_create:ls_report_node_msg_creating(I-1),
%%     io:format("LS_Report_Node_Msg is ~p~n",[LS_Report_Node_Msgs_1]),
    element(2,LS_Report_Node_Msgs_1)
  end),
  list_to_binary(LS_Report_Nodes_Msgs_1).



ls_report_links_msg_1_creating(SwitchNum) ->
  LS_Report_Links_Msgs_1 = linc_pcep_config:for(1,SwitchNum-1,fun(I) ->
%%     LS_Report_Link_Msgs_1 =
  pcep_msg_create:ls_report_link_msgs_1_creating(I-1)
%%     io:format("LS_Report_Node_Msg is ~p~n",[LS_Report_Link_Msgs_1])
%%     element(2,LS_Report_Link_Msgs_1)
  end),
  list_to_binary(LS_Report_Links_Msgs_1).

