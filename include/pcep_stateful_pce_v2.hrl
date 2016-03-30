%%%-------------------------------------------------------------------
%%% @author Xinfeng
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 三月 2016 9:56
%%%-------------------------------------------------------------------
-author("Xinfeng").


%% Path report ---------------------------------------------------------------

-record(symbolic_path_name_tlv,{
  symbolic_path_name_type::integer(),   %%16bits   17
  symbolic_path_name_len::integer(),    %%16bits
  symbolic_path_name::integer()          %%variable
}).

-type symbolic_path_name_tlv()::#symbolic_path_name_tlv{}.

-record(srp_object,{
  flags::integer(),   %% 32bits
  srp_id_number::integer(),  %% 32bits
  srp_object_tlv_symbolic_path_name_tlv::symbolic_path_name_tlv()
}).

-type srp_object()::#srp_object{}.

-record(ipv4_lsp_identifiers_tlv, {
  ipv4_lsp_identifiers_tlv_type :: integer(),      %%16bits
  ipv4_lsp_identifiers_tlv_len :: integer(),      %%16bits
  ipv4_lsp_identifiers_tlv_tunnel_sender_add :: integer(),%%32bits
  ipv4_lsp_identifiers_tlv_lsp_id :: integer(),%%16bits
  ipv4_lsp_identifiers_tlv_tunnel_id :: integer(),%%16bits
  ipv4_lsp_identifiers_tlv_exrended_tunnel_id :: integer(),%%32bits
  ipv4_lsp_identifiers_tlv_tunnel_endpoint_add :: integer()%%32bits
  %%ipv4_lsp_identifiers_tlv仅在IPv4使用
}).
-type ipv4_lsp_identifiers_tlv()::#ipv4_lsp_identifiers_tlv{}.

-record(lsp_error_code_tlv,{
  lsp_error_code_tlv_type::integer(), %%16bits
  lsp_error_code_tlv_len::integer(),  %%16bits
  lsp_error_code::integer()           %%32bits
}).

-type lsp_error_code_tlv()::#lsp_error_code_tlv{}.

-record(rsvp_error_spec_tlv,{
  rsvp_error_spec_tlv_type::integer(),  %%16bits
  rsvp_error_spec_tlv_len::integer(),  %%16bits
  rsvp_error_spec_tlv_body1,  %%RSVP ERROR_SPEC object
  rsvp_error_spec_tlv_body2   %%USER_ERROR_SPEC Object
}).

-type rsvp_error_spec_tlv()::#rsvp_error_spec_tlv{}.

-record(lsp_object_optional_tlv,{
  lsp_object_tlv_ipv4_lsp_identifiers_tlv::ipv4_lsp_identifiers_tlv(),
  lsp_object_tlv_lsp_error_code_tlv::lsp_error_code_tlv(),
  lsp_object_tlv_rsvp_error_spec_tlv::rsvp_error_spec_tlv()
}).

-type lsp_object_optional_tlv()::#lsp_object_optional_tlv{}.
-record(lsp_object,{
  plsp_id::integer(),
  flag::integer(),
  o::integer(),
  a::boolean(),
  r::boolean(),
  s::boolean(),
  d::boolean(),
  lsp_object_optional_tlv
}).

-type lsp_object()::#lsp_object{}.

-record(ipv4_subobject,{
  ipv4_subobject_type::integer(),%%8bits
  ipv4_subobject_len::integer(),%%8bits
  ipv4_subobject_add::integer(),%%32bits
  ipv4_subobject_prefix_len::integer(),%%8bits
  ipv4_subobject_flags::integer() %%8bits
}).

-type ipv4_subobject()::#ipv4_subobject{}.

-record(ipv6_subobject,{
  ipv6_subobject_type::integer(),%%8bits
  ipv6_subobject_len::integer(),%%8bits
  ipv6_subobject_add::integer(),%%128bits
  ipv6_subobject_prefix_len::integer(),%%8bits
  ipv6_subobject_flags::integer() %%8bits
}).

-type ipv6_subobject()::#ipv6_subobject{}.

-record(label_subobject,{
  label_subobject_type::integer(),%%8bits
  label_subobject_len::integer(),%%8bits
  label_subobject_flags::integer(),%%8bits
  label_subobject_c_type::integer(),%%8bits
  label_subobject_contents::integer()%%32bits
}).

-type label_subobject()::#label_subobject{}.

-record(rro_object,{
  rro_object_ipv4_subobject::ipv4_subobject(),
  rro_object_ipv6_subobject::ipv6_subobject(),
  rro_object_label_subobject::label_subobject()
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