%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. ���� 2016 9:56
%%%-------------------------------------------------------------------
-author("Xinfeng").


%% Path report ---------------------------------------------------------------

-record(symbolic_path_name_tlv,{
  symbolic_path_name_tlv_type :: integer(),
  symbolic_path_name_tlv_length :: integer(),
  symbolic_path_name::integer()          %%variable
}).

-type symbolic_path_name_tlv()::#symbolic_path_name_tlv{}.

-record(srp_object,{
  flags = <<0:32>> ::integer(),   %% 32bits
  srp_id_number::integer(),  %% 32bits
%%  srp_object_tlv_symbolic_path_name_tlv::symbolic_path_name_tlv()
  tlvs::list()
}).

-type srp_object()::#srp_object{}.

-record(ipv4_lsp_identifiers_tlv, {
  ipv4_lsp_identifiers_tlv_type :: integer(),
  ipv4_lsp_identifiers_tlv_length :: integer(),
  ipv4_lsp_identifiers_tlv_tunnel_sender_add :: integer(),%%32bits
  ipv4_lsp_identifiers_tlv_lsp_id :: integer(),%%16bits
  ipv4_lsp_identifiers_tlv_tunnel_id :: integer(),%%16bits
  ipv4_lsp_identifiers_tlv_exrended_tunnel_id :: integer(),%%32bits
  ipv4_lsp_identifiers_tlv_tunnel_endpoint_add :: integer()%%32bits
  %%ipv4_lsp_identifiers_tlv����IPv4ʹ��
}).

-type ipv4_lsp_identifiers_tlv()::#ipv4_lsp_identifiers_tlv{}.

-record(lsp_error_code_tlv,{     %% 在PCInitiate消息中用不到
  lsp_error_code_tlv_type :: integer(),
  lsp_error_code_tlv_length :: integer(),
  lsp_error_code::integer()           %%32bits
}).

-type lsp_error_code_tlv()::#lsp_error_code_tlv{}.

-record(rsvp_error_spec_tlv,{  %% 在PCInitiate消息中用不到
  rsvp_error_spec_tlv_type :: integer(),
  rsvp_error_spec_tlv_length :: integer(),
  rsvp_error_spec_tlv_body1,  %%RSVP ERROR_SPEC object
  rsvp_error_spec_tlv_body2   %%USER_ERROR_SPEC Object
}).

-type rsvp_error_spec_tlv()::#rsvp_error_spec_tlv{}.

%%-record(lsp_object_optional_tlv,{
%%  lsp_object_tlv_ipv4_lsp_identifiers_tlv::ipv4_lsp_identifiers_tlv(),
%%  lsp_object_tlv_lsp_error_code_tlv::lsp_error_code_tlv(),
%%  lsp_object_tlv_rsvp_error_spec_tlv::rsvp_error_spec_tlv()
%%}).

%%-type lsp_object_optional_tlv()::#lsp_object_optional_tlv{}.
-record(lsp_object,{
  plsp_id::integer(),
  flag::integer(),
  o::integer(),
  a::boolean(),
  r::boolean(),
  s::boolean(),
  d::boolean(),
  tlvs::list()
}).

-type lsp_object()::#lsp_object{}.

%% subobject, not tlvs,
-record(ipv4_subobject,{
  ipv4_subobject_type=1 ::integer(),%%8bits
  ipv4_subobject_len = 8 ::integer(),%%8bits
  ipv4_subobject_add::integer(),%%32bits
  ipv4_subobject_prefix_len::integer(),%%8bits
  ipv4_subobject_flags::integer() %%8bits
}).

-type ipv4_subobject()::#ipv4_subobject{}.

%% -record(ipv6_subobject_value,{
%% %%   ipv6_subobject_type = 2 ::integer(),%%8bits
%% %%   ipv6_subobject_len= 20 ::integer(),%%8bits
%%   ipv6_subobject_add::integer(),%%128bits
%%   ipv6_subobject_prefix_len::integer(),%%8bits
%%   ipv6_subobject_flags::integer() %%8bits
%% }).
%%
%% -type ipv6_subobject_value()::#ipv6_subobject_value{}.

-record(label_subobject,{
  label_subobject_type = 3 ::integer(),%%8bits
  label_subobject_len = 8::integer(),%%8bits
  label_subobject_flags::integer(),%%8bits
  label_subobject_c_type::integer(),%%8bits
  label_subobject_contents::integer()%%32bits
}).

-type label_subobject()::#label_subobject{}.

-record(rro_object,{
  rro_subobjects::list()
}).

-type rro_object()::#rro_object{}.

%% -record(pcrpt_msg,{
%%   pcrpt_msg_header::pcep_message(),
%%   pcrpt_msg_srp_object::srp_object(),
%%   pcrpt_msg_lsp_object::lsp_object(),
%%   pcrpt_msg_rro_object::rro_object()
%% }).
%%
%% -type pcrpt_msg()::#pcrpt_msg{}.