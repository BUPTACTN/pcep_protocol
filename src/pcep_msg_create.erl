%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 八月 2016 10:04
%%%-------------------------------------------------------------------

%% PCEP Message Created(OPEN...)
-module(pcep_msg_create).
-author("Xinfeng").
-include("pcep_protocol.hrl").
%% -include("pcep_v1.hrl").
-define(OPEN_MSG_LENGTH,52).
-define(LSReport_MSG_LENGTH,152).
-define(Report_MSG_LENGTH,60).
-define(ERO_OBJECT_LENGTH,20).
-define(LSP_OBJECT_LENGTH,36).
%% API
-export([open_msg_creating/0,
  keepalive_msg_creating/0,
  ls_report_link_msg_1_creating/1,
  ls_report_node_msg_creating/1,
  ls_report_link_msg_0_creating/1,
  pcrpt_msg_creating/2]).

open_msg_creating() ->
  Open_Message = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 1,
    message_length = ?OPEN_MSG_LENGTH,
    body = #pcep_object_message{object_class = 1,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?OPEN_MSG_LENGTH-4,
      body = #open_object{version = 1,
        flags = 0,
        keepAlive = 30,
        deadTimer = 0,
        sid = 0,
        open_object_tlvs = #open_object_tlvs{
          open_pcecc_cap_tlv = #pcecc_cap_tlv{
            pcecc_cap_tlv_type = 32,
            pcecc_cap_tlv_length = 4,
            pcecc_cap_tlv_flag = 0,
            pcecc_cap_tlv_g = 1,
            pcecc_cap_tlv_l = 1},
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
          open_ted_cap_tlv = #ted_cap_tlv{
            ted_cap_tlv_type = 132,
            ted_cap_tlv_length = 4,
            ted_cap_tlv_flag = 0,
            ted_cap_tlv_r = 1},
          open_ls_cap_tlv = #ls_cap_tlv{
            ls_cap_tlv_type = 10003,
            ls_cap_tlv_length = 4,
            ls_cap_tlv_flag = 0,
            ls_cap_tlv_r = 1}}}}},
  pcep_protocol:encode(Open_Message).

keepalive_msg_creating() ->
  <<32,2,0,4>>.

ls_report_link_msg_1_creating(SwitchId) ->
  N = trunc(1076363280*math:pow(2,96)),
  P = trunc(4294967295*math:pow(2,32)+4278190080),
  M = P+N,
  Link_Config = linc_pcep_config:link_ip_extract(SwitchId),
  Link_Num = linc_pcep_config:link_ip_num(SwitchId),
%%   linc_pcep_config:for(1,Link_Num)
  %% S = 1 Msg
  LS_Report_Link_Msgs_1 = linc_pcep_config:for(1,Link_Num-1,fun(I) ->
    Link_Config_I = lists:nth(I,Link_Config),
    Link_Id = element(1,Link_Config_I),
    Link_IP = element(2,Link_Config_I),
    Link_Local_IP = element(1,Link_IP),
    Link_Remote_IP  = element(2,Link_IP),
    LS_Report_Link_Msg_1 = #pcep_message{
      version = 1,
      flags = 0,
      message_type = 224,
      message_length = ?LSReport_MSG_LENGTH,
      body = #pcep_object_message{object_class = 224,
        object_type = 2,
        res_flags = 0,
        p = 1,
        i = 1,
        object_length = ?LSReport_MSG_LENGTH-4,
        body = #ls_link_object{ls_object_protocol_id = 4,
          ls_object_flag = 0,
          ls_object_r = 1,
          ls_object_s = 1,
          ls_object_ls_id = 12,
          ls_object_tlv = #optical_link_attribute_tlv{
            optical_link_attribute_tlv_type = 10001,
            optical_link_attribute_tlv_length = 128,
            link_type_sub_tlv_body = #link_type_sub_tlv{
              link_type_sub_tlv_type = 1,
              link_type_sub_tlv_length = 1,
              link_type = 1},
            res_bytes = 0,
            link_id_sub_tlv_body = #link_id_sub_tlv{
              link_id_sub_tlv_type = 2,
              link_id_sub_tlv_length = 4,
              link_id = Link_Id
            },
            local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
              local_interface_ip_address_sub_tlv_type = 3,
              local_interface_ip_address_sub_tlv_length = 4,
              local_interface_address = Link_Local_IP
            },
            remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
              remote_interface_ip_address_sub_tlv_type = 4,
              remote_interface_ip_address_sub_tlv_length = 4,
              remote_interface_address = Link_Remote_IP
            },
            te_metric_body = #te_metric_sub_tlv{
              te_metric_sub_tlv_type = 5,
              te_metric_sub_tlv_length = 4,
              te_link_metric = 1},
            interface_switching_cap_des_sub_tlv_body = #interface_switching_capability_descriptor_sub_tlv{
              interface_switching_capability_descriptor_sub_tlv_type = 15,
              interface_switching_capability_descriptor_sub_tlv_length = 36,
              switching_cap = 150,
              encoding = 8,
              reserved = 0,
              priority_0 = 1,
              priority_1 = 0,
              priority_2 = 0,
              priority_3 = 0,
              priority_4 = 0,
              priority_5 = 0,
              priority_6 = 0,
              priority_7 = 0},
            port_label_res_sub_tlv_body = #port_label_restrictions_sub_tlv{
              port_label_restrictions_sub_tlv_type = 34,
              port_label_restrictions_sub_tlv_length = 20,
              matrix_ID = 255,
              res_type = 2,
              switching_cap = 150,
              encoding = 8,
              additional_res = M},
            available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
              available_labels_field_sub_tlv_type = 10004,
              available_labels_field_sub_tlv_length = 20,
              pri = 255,
              res = 0,
              label_set_field = M
            }
          }
        }
      }
    },
    pcep_protocol:encode(LS_Report_Link_Msg_1)
  end),
  list_to_binary(LS_Report_Link_Msgs_1).
ls_report_link_msg_0_creating(SwitchId) ->
  N = trunc(1076363280*math:pow(2,96)),
  P = trunc(4294967295*math:pow(2,32)+4278190080),
  M = P+N,
  Link_Config = linc_pcep_config:link_ip_extract(SwitchId),
  Link_Num = linc_pcep_config:link_ip_num(SwitchId),
  Link_Config_Num = lists:nth(Link_Num,Link_Config),
  Link_Id = element(1,Link_Config_Num),
  Link_IP = element(2,Link_Config_Num),
  Link_Local_IP = element(1,Link_IP),
  Link_Remote_IP  = element(2,Link_IP),
%%   linc_pcep_config:for(1,Link_Num)
  %% S = 1 Msg

  LS_Report_Link_Msg_0 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_MSG_LENGTH,
    body = #pcep_object_message{object_class = 224,
      object_type = 2,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_MSG_LENGTH-4,
      body = #ls_link_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 1,
        ls_object_s = 0,
        ls_object_ls_id = 12,
        ls_object_tlv = #optical_link_attribute_tlv{
          optical_link_attribute_tlv_type = 10001,
          optical_link_attribute_tlv_length = 128,
          link_type_sub_tlv_body = #link_type_sub_tlv{
            link_type_sub_tlv_type = 1,
            link_type_sub_tlv_length = 1,
            link_type = 1},
          res_bytes = 0,
          link_id_sub_tlv_body = #link_id_sub_tlv{
            link_id_sub_tlv_type = 2,
            link_id_sub_tlv_length = 4,
            link_id = Link_Id
          },
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = Link_Local_IP
          },
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = Link_Remote_IP
          },
          te_metric_body = #te_metric_sub_tlv{
            te_metric_sub_tlv_type = 5,
            te_metric_sub_tlv_length = 4,
            te_link_metric = 1},
          interface_switching_cap_des_sub_tlv_body = #interface_switching_capability_descriptor_sub_tlv{
            interface_switching_capability_descriptor_sub_tlv_type = 15,
            interface_switching_capability_descriptor_sub_tlv_length = 36,
            switching_cap = 150,
            encoding = 8,
            reserved = 0,
            priority_0 = 1,
            priority_1 = 0,
            priority_2 = 0,
            priority_3 = 0,
            priority_4 = 0,
            priority_5 = 0,
            priority_6 = 0,
            priority_7 = 0},
          port_label_res_sub_tlv_body = #port_label_restrictions_sub_tlv{
            port_label_restrictions_sub_tlv_type = 34,
            port_label_restrictions_sub_tlv_length = 20,
            matrix_ID = 255,
            res_type = 2,
            switching_cap = 150,
            encoding = 8,
            additional_res = M},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = M
          }
        }
      }
    }
  },
  pcep_protocol:encode(LS_Report_Link_Msg_0).

ls_report_node_msg_creating(SwitchId) ->
  Num = linc_pcep_config:switch_ip_num(SwitchId),
  A = Num div 4,
  B = Num rem 4,
  if B /= 0 ->
    C = A+1+Num;
    true ->
      C = A+Num
  end,
  Node_Msg_Length = (7+C) * 4,
  Ls_node_msg = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = Node_Msg_Length,
    body = #pcep_object_message{object_class = 224,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = Node_Msg_Length-4,
      body = #ls_node_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 1,
        ls_object_s = 1,
        ls_object_ls_id = 1,
        ls_node_object_tlv = #optical_node_attribute_tlv{
          optical_node_attribute_tlv_type = 10002,
          optical_node_attribute_tlv_length = Node_Msg_Length-24,
          optical_node_attribute = case Num of
                                     2 ->
                                       #actn_node_sub_tlv_2{actn_node_sub_tlv_type = 1,
                                         actn_node_sub_tlv_length = Num*5,
                                         prefix1 = 32,
                                         ipv4_prefix1 = lists:nth(1,linc_pcep_config:switch_ip(SwitchId)),
                                         prefix2 = 32,
                                         ipv4_prefix2 = lists:nth(2,linc_pcep_config:switch_ip(SwitchId)),
                                         res_bytes = 0
                                       };
                                     1 ->
                                       #actn_node_sub_tlv{actn_node_sub_tlv_type = 1,
                                         actn_node_sub_tlv_length = Num*5,
                                         prefix = 32,
                                         ipv4_prefix = lists:nth(1,linc_pcep_config:switch_ip(SwitchId)),
                                         res_bytes = 0
                                       };
                                     3 ->
                                       #actn_node_sub_tlv_3{actn_node_sub_tlv_type = 1,
                                         actn_node_sub_tlv_length = Num*5,
                                         prefix1 = 32,
                                         ipv4_prefix1 = lists:nth(1,linc_pcep_config:switch_ip(SwitchId)),
                                         prefix2 = 32,
                                         ipv4_prefix2 = lists:nth(2,linc_pcep_config:switch_ip(SwitchId)),
                                         prefix3 = 32,
                                         ipv4_prefix3 = lists:nth(3,linc_pcep_config:switch_ip(SwitchId)),
                                         res_bytes = 0
                                       };
                                     4 ->
                                       #actn_node_sub_tlv_4{actn_node_sub_tlv_type = 1,
                                         actn_node_sub_tlv_length = Num*5,
                                         prefix1 = 32,
                                         ipv4_prefix1 = lists:nth(1,linc_pcep_config:switch_ip(SwitchId)),
                                         prefix2 = 32,
                                         ipv4_prefix2 = lists:nth(2,linc_pcep_config:switch_ip(SwitchId)),
                                         prefix3 = 32,
                                         ipv4_prefix3 = lists:nth(3,linc_pcep_config:switch_ip(SwitchId)),
                                         prefix4 = 32,
                                         ipv4_prefix4 = lists:nth(3,linc_pcep_config:switch_ip(SwitchId))
                                       }
                                   end

        }
      }
    }
  },
  pcep_protocol:encode(Ls_node_msg).

pcrpt_msg_creating(IP_1,IP_2) ->
  Pcrpt_msg = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 10,
    message_length = ?Report_MSG_LENGTH,
    body = #pcep_object_2{
      pcep_object1 = #pcep_object_message{
        object_class = 32,
        object_type = 1,
        res_flags = 0,
        p = 1,
        i = 1,
        object_length = ?LSP_OBJECT_LENGTH,
        body = #lsp_object{
          plsp_id = 1,
          flag = 0,
          c = 1,
          o = 1,
          a = 1,
          r = 1,
          s = 1,
          d = 1,
          lsp_object_tlvs = #lsp_object_tlvs{
            lsp_object_lsp_identifier_tlv = #ipv4_lsp_identifiers_tlv{
              ipv4_lsp_identifiers_tlv_type = 18,
              ipv4_lsp_identifiers_tlv_length = 16,
              ipv4_lsp_identifiers_tlv_tunnel_sender_add = 1,
              ipv4_lsp_identifiers_tlv_lsp_id = 1,
              ipv4_lsp_identifiers_tlv_tunnel_id = 1,
              ipv4_lsp_identifiers_tlv_exrended_tunnel_id = 2,
              ipv4_lsp_identifiers_tlv_tunnel_endpoint_add = 3},
            lsp_object_symbolic_path_name_tlv = #symbolic_path_name_tlv{
              symbolic_path_name_tlv_type = 17,
              symbolic_path_name_tlv_length = 4,
              symbolic_path_name = 1
            }
          }
        }
      },
      pcep_object2 = #pcep_object_message{
        object_class = 7,
        object_type = 1,
        res_flags = 0,
        p = 1,
        i = 1,
        object_length = ?ERO_OBJECT_LENGTH,
        body = #ero_object{
          ero_subobject1 = #ipv4_subobject{
            ipv4_subobject_type = 1,
            ipv4_subobject_len = 8,
            ipv4_subobject_add = IP_1,
            ipv4_subobject_prefix_len = 32,
            ipv4_subobject_flags = 0},
          ero_subobject2 = #ipv4_subobject{
            ipv4_subobject_type = 1,
            ipv4_subobject_len = 8,
            ipv4_subobject_add = IP_2,
            ipv4_subobject_prefix_len = 32,
            ipv4_subobject_flags = 0
          }
        }
      }
    }
  },
  pcep_protocol:encode(Pcrpt_msg).

