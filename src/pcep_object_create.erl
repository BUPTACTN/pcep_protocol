%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 十月 2016 11:33
%%%-------------------------------------------------------------------
-module(pcep_object_create).
-author("Xinfeng").
-include("pcep_protocol.hrl").

%% API
-export([]).

%% lsp_object_create() ->
%%   Lsp_Object = #pcep_object_message{
%%     object_class = 32,
%%     object_type = 1,
%%     res_flags = 0,
%%     p = 1,
%%     i = 1,
%%     object_length = ?LSP_OBJERC_LENGTH,
%%     body =#lsp_object{
%%       plsp_id = 1,
%%       flag = 0,
%%       c = 1,
%%       o = 1,
%%       a = 1,
%%       r = R,
%%       s = 1,
%%       d = 1,
%%       lsp_object_tlvs = #lsp_object_tlvs{
%%         lsp_object_lsp_identifier_tlv = #ipv4_lsp_identifiers_tlv{
%%           ipv4_lsp_identifiers_tlv_type = 18,
%%           ipv4_lsp_identifiers_tlv_length = 16,ipv4_lsp_identifiers_tlv_tunnel_sender_add = 1,
%%         }
%%       }
%%     }
%%   }