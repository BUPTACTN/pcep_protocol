%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 六月 2016 15:22
%%%-------------------------------------------------------------------
-module(pcrpt_msg).
-author("Xinfeng").

-include("pcep_protocol.hrl").
-include("pcep_v1.hrl").
%% -include("pcep_ls_v2.hrl").
-include("pcep_logger.hrl").

%% API
-export([]).

pcrpt_msg_encode() ->
  Pcrpt_msg = #pcep_message{
    version = 1,
    flags = 0,
    message_type = 10,
    message_length = ?Report_MSG_LENGTH,
    body = #pcep_object_message{
      object_class = 32,
      object_type = 1,
      res_flags = 0,
      p = 1,
      i = 1,
      object_length = ?Report_MSG_LENGTH-4,
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
            symbolic_path_name = 1}}}}}.