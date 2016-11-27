%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. ���� 2016 14:01
%%%-------------------------------------------------------------------
-module(pcep_client_v7).
-author("Xinfeng").

%% API
%% -export([send_topo_update_msg/1]).
%% -include("linc_logger.hrl").
% -include_lib("pcep_protocol/include/pcep_v1.hrl").
-include_lib("pcep_protocol/include/pcep_protocol.hrl").
-include_lib("kernel/include/file.hrl").
-import(pcep_protocol,[encode/1, decode/1]).
%% -import(ls_msg_test,[ls_msg_encode/0]).
-define(PCEP_PORT, 4189).
%% -define(CONTROLLER_IP_ADDRESS,{10, 108, 0, X}).   %% TODO
-define(DEFAULT_CONTROLLER_ROLE, master).
-define(LSReport_MSG_LENGTH,152).
-define(OPEN_MSG_LENGTH, 52).
-define(TIME_TICK,40000).
-define(KEEPALIVE_MSG_LENGTH, 4).
-define(LSReport_NODE_MSG_LENGTH,36).
-define(LSReport_NODE_MSG_LENGTH_2,40).
-define(LSReport_NODE_MSG_LENGTH_3,44).
-define(LSReport_NODE_MSG_LENGTH_4,48).

%% API
-export([timer_stop/1, start/1, receive_data1/2,link_down/0]).
%% make() ->
%%   {ok,Tree}=epp:parse_file("myheader.hrl",["./"],[])
%% mutipart_test() ->
%%   [{setup,
%%     fun start/0
%%   }].

start(Host) ->
  Port = ?PCEP_PORT,
  {ok, Socket} = gen_tcp:connect(Host, Port, [binary, {packet, 0}]),
  io:format("Socket is ~p~n",[Socket]),
  ets:new(socket_list,[named_table]),
  ets:insert(socket_list,{socket,Socket}).




%%
receive_data(Socket, SoFar) ->
  receive
    {tcp, Socket, Bin} ->
      io:format(Bin);
    {tcp_closed, Socket} ->
      list_to_binary(SoFar)
  end.
receive_data1(Socket, SoFar) ->
  receive
    {tcp, Socket, Bin} ->
      {H,_L} = split_binary(Bin,2),
      if
        H =:= <<32,12>> ->
          {ok,PcrptMsg} = pcrpt_msg:pcrpt_msg_encode(),
          gen_tcp:send(Socket,PcrptMsg),
          receive_data1(Socket,[]);
        true ->
          io:format("It is not keepalive msg~n"),
          receive_data1(Socket,[])
      end,
      io:format(Bin);
    {tcp_closed, Socket} ->
      list_to_binary(SoFar)
  end.

link_down() ->
  Message1 = #pcep_message{
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
  Ls_node_msg1 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_NODE_MSG_LENGTH_3,
    body = #pcep_object_message{object_class = 224,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_NODE_MSG_LENGTH_3-4,
      body = #ls_node_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 1,
        ls_node_object_tlv = #optical_node_attribute_tlv{
          optical_node_attribute_tlv_type = 10002,
          optical_node_attribute_tlv_length = 20,
          optical_node_attribute = #actn_node_sub_tlv_3{actn_node_sub_tlv_type = 1,
            actn_node_sub_tlv_length = 15,
            prefix1 = 32,
            ipv4_prefix1 = 167772417,
            prefix2 = 32,
            ipv4_prefix2 = 167772418,
            prefix3 = 32,
            ipv4_prefix3 = 167772419,
            res_bytes = 0}}

      }
    }
  },
  Ls_node_msg3 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_NODE_MSG_LENGTH_3,
    body = #pcep_object_message{object_class = 224,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_NODE_MSG_LENGTH_3-4,
      body = #ls_node_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 3,
        ls_node_object_tlv = #optical_node_attribute_tlv{
          optical_node_attribute_tlv_type = 10002,
          optical_node_attribute_tlv_length = 20,
          optical_node_attribute = #actn_node_sub_tlv_3{actn_node_sub_tlv_type = 1,
            actn_node_sub_tlv_length = 15,
            prefix1 = 32,
            ipv4_prefix1 = 167772929,
            prefix2 = 32,
            ipv4_prefix2 = 167772931,
            prefix3 = 32,
            ipv4_prefix3 = 167772930,
            res_bytes = 0}
        }
      }
    }
  },
  Ls_node_msg6 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_NODE_MSG_LENGTH_4,
    body = #pcep_object_message{object_class = 224,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_NODE_MSG_LENGTH_4-4,
      body = #ls_node_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 4,
        ls_node_object_tlv = #optical_node_attribute_tlv{
          optical_node_attribute_tlv_type = 10002,
          optical_node_attribute_tlv_length = 24,
          optical_node_attribute = #actn_node_sub_tlv_4{actn_node_sub_tlv_type = 1,
            actn_node_sub_tlv_length = 20,
            prefix1 = 32,
            ipv4_prefix1 = 167773185,
            prefix2 = 32,
            ipv4_prefix2 = 167773186,
            prefix3 = 32,
            ipv4_prefix3 = 167773187,
            prefix4 = 32,
            ipv4_prefix4 = 167773188
          }
        }
      }
    }
  },
  Ls_node_msg2 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_NODE_MSG_LENGTH_4,
    body = #pcep_object_message{object_class = 224,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_NODE_MSG_LENGTH_4-4,
      body = #ls_node_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 5,
        ls_node_object_tlv = #optical_node_attribute_tlv{
          optical_node_attribute_tlv_type = 10002,
          optical_node_attribute_tlv_length = 24,
          optical_node_attribute = #actn_node_sub_tlv_4{actn_node_sub_tlv_type = 1,
            actn_node_sub_tlv_length = 20,
            prefix1 = 32,
            ipv4_prefix1 = 167772673,
            prefix2 = 32,
            ipv4_prefix2 = 167772674,
            prefix3 = 32,
            ipv4_prefix3 = 167772675,
            prefix4 = 32,
            ipv4_prefix4 = 167772676
          }
        }
      }
    }
  },
  Ls_node_msg5 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_NODE_MSG_LENGTH_4,
    body = #pcep_object_message{object_class = 224,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_NODE_MSG_LENGTH_4-4,
      body = #ls_node_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 6,
        ls_node_object_tlv = #optical_node_attribute_tlv{
          optical_node_attribute_tlv_type = 10002,
          optical_node_attribute_tlv_length = 24,
          optical_node_attribute = #actn_node_sub_tlv_4{actn_node_sub_tlv_type = 1,
            actn_node_sub_tlv_length = 20,
            prefix1 = 32,
            ipv4_prefix1 = 167773441,
            prefix2 = 32,
            ipv4_prefix2 = 167773442,
            prefix3 = 32,
            ipv4_prefix3 = 167773443,
            prefix4 = 32,
            ipv4_prefix4 = 167773444
          }
        }
      }
    }
  },
  Ls_link_msg1 = #pcep_message{ %% 1.1 -> 2.1
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167772417,
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
            link_id = 167772673},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167772417},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167772673},
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
            additional_res = linc_pcep_config:get_resource(300)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(300)
          }
        }
      }
    }
  },
  Ls_link_msg2 = #pcep_message{ %% 2.1 -> 1.1
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167772673,
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
            link_id = 167772417},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167772673},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167772417},
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
            additional_res = linc_pcep_config:get_resource(300)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(300)
          }
        }
      }
    }
  },
  Ls_link_msg3 = #pcep_message{ %% 2.2 -> 3.1
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167772674,
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
            link_id = 167772929},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167772674},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167772929},
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
            additional_res = linc_pcep_config:get_resource(300)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(300)
          }
        }
      }
    }
  },
  Ls_link_msg4 = #pcep_message{ %% 3.1 -> 2.2
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167772929,
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
            link_id = 167772673},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167772929},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167772674},
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
            additional_res = linc_pcep_config:get_resource(300)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(300)
          }
        }
      }
    }
  },
  Ls_link_msg5 = #pcep_message{  %% 4.3 -> 5.1
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167773187,
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
            link_id = 167773441},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167773187},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167773441},
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
            additional_res = linc_pcep_config:get_resource(300)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(300)
          }
        }
      }
    }
  },
  Ls_link_msg6 = #pcep_message{ %% 5.1 -> 4.3
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167773441,
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
            link_id = 167773185},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167773441},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167773187},
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
            additional_res = linc_pcep_config:get_resource(300)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(300)
          }
        }
      }
    }
  },
  Ls_link_msg9 = #pcep_message{ %% 4.1 -> 1.2
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167773185,
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
            link_id = 167772417},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167773185},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167772418},
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
            additional_res = linc_pcep_config:get_resource(100)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(100)
          }
        }
      }
    }
  },
  Ls_link_msg10 = #pcep_message{ %% 1.2 -> 4.1
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167772418,
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
            link_id = 167773185},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167772418},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167773185},
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
            additional_res = linc_pcep_config:get_resource(100)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(100)
          }
        }
      }
    }
  },
  Ls_link_msg11 = #pcep_message{  %% 5.2 -> 2.3
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167773442,
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
            link_id = 167772673},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167773442},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167772675},
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
            additional_res = linc_pcep_config:get_resource(100)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(100)
          }
        }
      }
    }
  },
  Ls_link_msg12 = #pcep_message{  %% 2.3 -> 5.2
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167772675,
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
            link_id = 167773441},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167772675},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167773442},
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
            additional_res = linc_pcep_config:get_resource(100)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(100)
          }
        }
      }
    }
  },
  Ls_link_msg15 = #pcep_message{  %% 4.2 -> 2.4
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167773186,
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
            link_id = 167772673},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167773186},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167772676},
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
            additional_res = linc_pcep_config:get_resource(100)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(100)
          }
        }
      }
    }
  },
  Ls_link_msg16 = #pcep_message{  %% 2.4 -> 4.2
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167772676,
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
            link_id = 167773185},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167772676},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167773186},
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
            additional_res = linc_pcep_config:get_resource(100)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(100)
          }
        }
      }
    }
  },
  Ls_link_msg17 = #pcep_message{  %% 5.3 -> 3.3
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
        ls_object_r = 0,
        ls_object_s = 1,
        ls_object_ls_id = 167773443,
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
            link_id = 167772929},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167773443},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167772930},
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
            additional_res = linc_pcep_config:get_resource(100)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(100)
          }
        }
      }
    }
  },
  Ls_link_msg18 = #pcep_message{  %% 3.3 -> 5.3
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
        ls_object_r = 0,
        ls_object_s = 0,
        ls_object_ls_id = 167772930,
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
            link_id = 167773441},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 167772930},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 167773443},
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
            additional_res = linc_pcep_config:get_resource(100)},
          available_labels_field_sub_tlv_body = #available_labels_field_sub_tlv{
            available_labels_field_sub_tlv_type = 10004,
            available_labels_field_sub_tlv_length = 20,
            pri = 255,
            res = 0,
            label_set_field = linc_pcep_config:get_resource(100)
          }
        }
      }
    }
  },
  Socket = ets:match(socket_list,{socket,'$1'}),
  {ok, OpenMessage} = encode(Message1),
  {ok,Ls_report_node_msg1} = encode(Ls_node_msg1),
  {ok,Ls_report_node_msg2} = encode(Ls_node_msg2),
  {ok,Ls_report_node_msg3} = encode(Ls_node_msg3),
  {ok,Ls_report_node_msg5} = encode(Ls_node_msg5),
  {ok,Ls_report_node_msg6} = encode(Ls_node_msg6),
  {ok,Ls_report_link_msg1} = encode(Ls_link_msg1),
  {ok,Ls_report_link_msg2} = encode(Ls_link_msg2),
  {ok,Ls_report_link_msg3} = encode(Ls_link_msg3),
  {ok,Ls_report_link_msg4} = encode(Ls_link_msg4),
  {ok,Ls_report_link_msg5} = encode(Ls_link_msg5),
  {ok,Ls_report_link_msg6} = encode(Ls_link_msg6),
  {ok,Ls_report_link_msg9} = encode(Ls_link_msg9),
  {ok,Ls_report_link_msg10} = encode(Ls_link_msg10),
  {ok,Ls_report_link_msg11} = encode(Ls_link_msg11),
  {ok,Ls_report_link_msg12} = encode(Ls_link_msg12),
  {ok,Ls_report_link_msg15} = encode(Ls_link_msg15),
  {ok,Ls_report_link_msg16} = encode(Ls_link_msg16),
  {ok,Ls_report_link_msg17} = encode(Ls_link_msg17),
  {ok,Ls_report_link_msg18} = encode(Ls_link_msg18),
  KeepaliveMessage = <<32,2,0,4>>,
  gen_tcp:send(Socket, OpenMessage),
  receive_data(Socket, []),
  gen_tcp:send(Socket,KeepaliveMessage),
  receive_data(Socket, []),
  gen_tcp:send(Socket, Ls_report_node_msg1),
  gen_tcp:send(Socket, Ls_report_node_msg2),
  gen_tcp:send(Socket, Ls_report_node_msg3),
  gen_tcp:send(Socket, Ls_report_node_msg5),
  gen_tcp:send(Socket, Ls_report_node_msg6),
  gen_tcp:send(Socket, Ls_report_link_msg1),
  gen_tcp:send(Socket, Ls_report_link_msg2),
  gen_tcp:send(Socket, Ls_report_link_msg3),
  gen_tcp:send(Socket, Ls_report_link_msg4),
  gen_tcp:send(Socket, Ls_report_link_msg5),
  gen_tcp:send(Socket, Ls_report_link_msg6),
  gen_tcp:send(Socket, Ls_report_link_msg9),
  gen_tcp:send(Socket, Ls_report_link_msg10),
  gen_tcp:send(Socket, Ls_report_link_msg11),
  gen_tcp:send(Socket, Ls_report_link_msg12),
  gen_tcp:send(Socket, Ls_report_link_msg15),
  gen_tcp:send(Socket, Ls_report_link_msg16),
  gen_tcp:send(Socket, Ls_report_link_msg17),
  gen_tcp:send(Socket, Ls_report_link_msg18),
  Pid = spawn(fun() -> receive_data1(Socket,[]) end),
  gen_tcp:controlling_process(Socket,Pid),
  timer_start(30000, fun()->gen_tcp:send(Socket, KeepaliveMessage) end ).



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