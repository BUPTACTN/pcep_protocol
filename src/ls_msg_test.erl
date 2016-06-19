%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 六月 2016 20:30
%%%-------------------------------------------------------------------
-module(ls_msg_test).
-author("Xinfeng").

-include("pcep_v1.hrl").
-include("pcep_protocol.hrl").
-define(LSReport_MSG_LENGTH,88).
%% API
-export([ls_msg_encode/0]).
-import(pcep_protocol,[encode/1,decode/1]).
ls_msg_encode() ->
  Ls_msg = #pcep_message{
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
    body = #ls_object{ls_object_protocol_id = 4,
      ls_object_flag = 0,
      ls_object_r = 1,
      ls_object_s = 1,
      ls_object_ls_id = 1,
      ls_object_tlvs = #ls_object_tlvs{
        actn_link_tlv = #optical_link_attribute_tlv{
          optical_link_attribute_tlv_type = 10001,
          optical_link_attribute_tlv_length = 100,
          link_type_sub_tlv_body = #link_type_sub_tlv{
            link_type_sub_tlv_type = 1,
            link_type_sub_tlv_length = 1,
            link_type = 1}, res_bytes = 0,
          link_id_sub_tlv_body = #link_id_sub_tlv{
            link_id_sub_tlv_type = 2,
            link_id_sub_tlv_length = 4,
            link_id = 1},
          local_interface_ip_add_sub_tlv_body = #local_interface_ip_address_sub_tlv{
            local_interface_ip_address_sub_tlv_type = 3,
            local_interface_ip_address_sub_tlv_length = 4,
            local_interface_address = 174862593},
          remote_interface_ip_add_sub_tlv_body = #remote_interface_ip_address_sub_tlv{
            remote_interface_ip_address_sub_tlv_type = 4,
            remote_interface_ip_address_sub_tlv_length = 4,
            remote_interface_address = 174862594},
          te_metric_body = #te_metric_sub_tlv{
            te_metric_sub_tlv_type = 5,
            te_metric_sub_tlv_length = 4,
            te_link_metric = 1},
          interface_switching_cap_des_sub_tlv_body = #interface_switching_capability_descriptor_sub_tlv{
            interface_switching_capability_descriptor_sub_tlv_type = 15,
            interface_switching_capability_descriptor_sub_tlv_length = 4,
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
          shared_risk_link_group_sub_tlv_body = #shared_risk_link_group_sub_tlv{shared_risk_link_group_sub_tlv_type = 16,
            shared_risk_link_group_sub_tlv_length = 4,
            shared_risk_link_group_value = 0},
          port_label_res_sub_tlv_body = #port_label_restrictions_sub_tlv{
            port_label_restrictions_sub_tlv_type = 34,
            port_label_restrictions_sub_tlv_length = 8,
            matrix_ID = 1,
            res_type = 2,
            switching_cap = 150,
            encoding = 8,
            additional_res = 0}
          }
        }
      }
    }
  },
  {ok,LsrptMessage} = encode(Ls_msg),
  io:format("LsrptMessage in the ls_msg_test is ~p~n", [LsrptMessage]).