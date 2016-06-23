%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 六月 2016 16:26
%%%-------------------------------------------------------------------
-module(lsrpt_msg_encode).
-author("Xinfeng").
-include("pcep_protocol.hrl").
-include("pcep_v1.hrl").
%% -include("pcep_ls_v2.hrl").
-include("pcep_logger.hrl").
%% API
-export([]).
encode_ls_msg() ->
Ls_msg1 = #pcep_message{
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
      ls_object_ls_id = 1,
      ls_object_tlv = #optical_link_attribute_tlv{
        optical_link_attribute_tlv_type = 10001,
        optical_link_attribute_tlv_length = 100,
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
        shared_risk_link_group_sub_tlv_body = #shared_risk_link_group_sub_tlv{
          shared_risk_link_group_sub_tlv_type = 16,
          shared_risk_link_group_sub_tlv_length = 4,
          shared_risk_link_group_value = 0},
        port_label_res_sub_tlv_body = #port_label_restrictions_sub_tlv{
          port_label_restrictions_sub_tlv_type = 34,
          port_label_restrictions_sub_tlv_length = 8,
          matrix_ID = 255,
          res_type = 2,
          switching_cap = 150,
          encoding = 8,
          additional_res = 0}
      }
    }
  }
},
  Ls_msg2 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_NODE_MSG_LENGTH,
    body = #pcep_object_message{object_class = 224,
      object_type = 2,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_NODE_MSG_LENGTH-4,
      body = #ls_link_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 1,
        ls_object_s = 1,
        ls_object_ls_id = 1,
        ls_object_tlv = #optical_link_attribute_tlv{
          optical_link_attribute_tlv_type = 10001,
          optical_link_attribute_tlv_length = 100,
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
          shared_risk_link_group_sub_tlv_body = #shared_risk_link_group_sub_tlv{
            shared_risk_link_group_sub_tlv_type = 16,
            shared_risk_link_group_sub_tlv_length = 4,
            shared_risk_link_group_value = 0},
          port_label_res_sub_tlv_body = #port_label_restrictions_sub_tlv{
            port_label_restrictions_sub_tlv_type = 34,
            port_label_restrictions_sub_tlv_length = 8,
            matrix_ID = 255,
            res_type = 2,
            switching_cap = 150,
            encoding = 8,
            additional_res = 0}
        }
      }
    }
  },
  Ls_msg4 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_MSG_LENGTH,
    body = #pcep_object_message{object_class = 224,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_MSG_LENGTH-4,
      body = #ls_node_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 1,
        ls_object_s = 0,
        ls_object_ls_id = 1,
        ls_node_object_tlv = #optical_node_attribute_tlv{
          optical_node_attribute_tlv_type = 10002,
          optical_node_attribute_tlv_length = 8,
          node_pre = 32,
          node_ip = 167772673,
          res_bytes = 0}

      }
    }
  },
  Ls_msg3 = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 224,
    message_length = ?LSReport_MSG_LENGTH,
    body = #pcep_object_message{object_class = 224,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?LSReport_MSG_LENGTH-4,
      body = #ls_node_object{ls_object_protocol_id = 4,
        ls_object_flag = 0,
        ls_object_r = 1,
        ls_object_s = 1,
        ls_object_ls_id = 1,
        ls_node_object_tlv = #optical_node_attribute_tlv{
          optical_node_attribute_tlv_type = 10002,
          optical_node_attribute_tlv_length = 8,
          node_pre = 32,
          node_ip = 167772417,
          res_bytes = 0}

      }
    }
  },