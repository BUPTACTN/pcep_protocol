
%%Protocol Version
-define(VERSION, 1).

%% -include("pcep_protocol.hrl").
%% -include("pcep_ls_v2.hrl").

-define(MESSAGETYPEMOD(MessageType), case MessageType of
                                       1 -> open_msg;
                                       2 -> keepalive_msg;
                                       3 -> path_computation_reqest_msg;
                                       4 -> path_computation_reply_msg;
                                       5 -> notification_msg;
                                       6 -> error_msg;
                                       7 -> close_msg;
                                       %% TODO for fxf
                                       _ -> unsupported_msg
                                     end).


-define(CLASSTYPEMOD(ObjectClass, ObjectType), case ObjectClass of
                                             1 -> open_ob_type;
                                             2 -> rp_ob_type;
                                             3 -> no_path_ob_type;
                                             4 -> case ObjectType of
                                                    1 -> end_points_v4_ob_type;
                                                    2 -> end_points_v6_ob_type
                                                  end;
                                             5 -> case ObjectType of
                                                    1 -> bdwidth_req_ob_type;
                                                    2 -> bdwidth_lsp_ob_type
                                                  end;
                                                 %% TODO for fxf
                                             _ -> unsupported_class

                                           end).

% Message-Type (8 bits):
% 1     Open
% 2     Keepalive
% 3     Path Computation Request
% 4     Path Computation Reply
% 5     Notification
% 6     Error
% 7     Close


%% Common TLV format ---------------------------------------------------------------
%% TODO error
%%-record(tlv, {
%%  name::atom(),  %% the name of this tlv's type
%%  type::integer(),
%%  length::integer(),
%%  value::any()
%%}).
%%
%%-type tlv()::#tlv{}.



%% Open Message ---------------------------------------------------------------
%% open message tlvs
-record(gmpls_cap_tlv, {
  gmpls_cap_tlv_type :: integer(),
  gmpls_cap_tlv_len :: integer(),
  gmpls_cap_flag :: integer()
}).

-type gmpls_cap_tlv()::#gmpls_cap_tlv{}.

-record(stateful_pec_cap_tlv,{
  stateful_pce_cap_tlv_type::integer(),
  stateful_pce_cap_tlv_len::integer(),
  stateful_pce_cap_tlv_flag::integer(),
  stateful_pce_cap_tlv_d::boolean(),
  stateful_pce_cap_tlv_t::boolean(),
  stateful_pce_cap_tlv_i::boolean(),
  stateful_pce_cap_tlv_s::boolean(),
  stateful_pce_cap_tlv_u::boolean()
}).

-type stateful_pec_cap_tlv()::#stateful_pec_cap_tlv{}.

-record(pcecc_cap_tlv,{
  pcecc_cap_tlv_type::integer(),
  pcecc_cap_tlv_len::integer(),
  pcecc_cap_tlv_flag::integer(),
  pcecc_cap_tlv_g::boolean(),
  pcecc_cap_tlv_l::boolean()
}).

-type pcecc_cap_tlv()::#pcecc_cap_tlv{}.

-record(lsp_db_version_tlv,{
  lsp_db_version_tlv_type::integer(),
  lsp_db_version_tlv_len::integer(),
  lsp_db_version_tlv_ver::integer()
}).

-type lsp_db_version_tlv()::#lsp_db_version_tlv{}.

-record(ted_cap_tlv,{
  ted_cap_tlv_type::integer(),
  ted_cap_tlv_flag::integer(),
  ted_cap_tlv_r::boolean()
}).

-type ted_cap_tlv()::#ted_cap_tlv{}.

-record(label_db_version_tlv,{
  label_db_version_tlv_type::integer(),
  label_db_version_tlv_len::integer(),
  lsp_db_version_tlv_ver::integer()
}).

-type label_db_version_tlv()::#label_db_version_tlv{}.

-record(open_object, {
%%   open_object_header::pcep_object_message(),
  version::integer(), %% 3bits
  flags::integer(), %% 5bits
  keepAlive::integer(), %% 8bits maximum period of time in seconds between two consecutive PCEP messages
  deadTimer::integer(), %%
  sid::integer(),
  tlvs::list()
%%  open_object_tlv_gmpls_cap_tlv::gmpls_cap_tlv(),
%%  open_object_tlv_stateful_pec_cap_tlv::stateful_pec_cap_tlv(),
%%  open_object_tlv_pcecc_cap_tlv::pcecc_cap_tlv()
}).

-type open_object()::#open_object{}.

%% -record(open_msg,{
%%   open_msg::pcep_message(),
%%   open_object::open_object()
%% }).
%%
%% -type open_msg()::#open_msg{}.


%% Keepalive message ---------------------------------------------------------------

%% empty

%% PCInitiate Message ---------------------------------------------------------------
%% -record(srp_object,{
%%   flags::integer(),   %% 32bits
%%   srp_id_number::integer(),  %% 32bits
%%   body
%% }).
%%
%% -type srp_object()::#srp_object{}.
%%
%% -record(srp_object_tlv_demo,{
%%   symbolic_path_name_type::integer(),   %%16bits   17
%%   symbolic_path_name_len::integer(),    %%16bits
%%   symbolic_path_name::integer()          %%variable
%% }).
%%
%% -record(lsp_object,{
%%   plsp_id::integer(),
%%   flag::integer(),
%%   o::integer(),
%%   a::boolean(),
%%   r::boolean(),
%%   s::boolean(),
%%   d::boolean(),
%%   body
%% }).
%%
%% -type lsp_object()::#lsp_object{}.

%% -record(end_points_object_ipv4,{
%%   source_ipv4_add::integer(),  %% 32bits
%%   destination_ipv4_add::integer()  %%32bits
%% }).
%%
%% -record(end_points_object_ipv6,{
%%   source_ipv6_add::integer(),  %% 128bits
%%   destination_ipv6_add::integer()  %% 128bits
%% }).
%%
%% -type end_points_object_ipv4()::#end_points_object_ipv4{}.
%%
%% -type end_points_object_ipv6()::#end_points_object_ipv6{}.

%% -record(error_object,{
%%   reserved::integer(),   %%8bits
%%   flags::integer(),    %%8bits
%%   error_type::integer(),  %%8bits
%%   error_value::integer(),  %%8bits
%%   body
%% }).
%%
%% -type error_object()::#error_object{}.
%%
%% -record(bandwidth_object,{
%%   bandwidth::integer()
%% }).

%% Path Computation Request ---------------------------------------------------------------

-record(rp_object,{
  flags::integer(),  %%26bits
  o::boolean(),      %%1bit
  b::boolean(),      %%1bit
  r::boolean(),      %%1bit
  pri::integer(),    %%3bits
  request_id_num::integer(),  %%32bits
  body
}).

-type rp_object()::#rp_object{}.

-record(end_points_object_ipv4,{
  source_ipv4_add::integer(),  %% 32bits
  destination_ipv4_add::integer()  %%32bits
}).

-record(end_points_object_ipv6,{
  source_ipv6_add::integer(),  %% 128bits
  destination_ipv6_add::integer()  %% 128bits
}).

-type end_points_object_ipv4()::#end_points_object_ipv4{}.

-type end_points_object_ipv6()::#end_points_object_ipv6{}.

%% -record(pcreq_msg,{
%%   pcreq_msg_header::pcep_message(),
%%   pcreq_msg_rp_object::rp_object(),
%%   pcreq_msg_end_points_object_ipv4::end_points_object_ipv4(),
%%   pcreq_msg_end_points_object_ipv6::end_points_object_ipv6()
%% }).
%%
%% -type pcreq_msg()::#pcreq_msg{}.

%% Path Computation Reply ---------------------------------------------------------------


%% Path report ---------------------------------------------------------------
%% pcep_stateful_pce_v2



%% Notification ---------------------------------------------------------------
%% unused




%% Error ---------------------------------------------------------------
-record(error_object,{
  reserved::integer(), %%8bits
  flags::integer(),%%8bits
  error_type::integer(),%%8bits
  error_value::integer(),%%8bits
  body
}).

-type error_object()::#error_object{}.

%% -record(error_msg,{
%%   error_msg_header::pcep_message(),
%%   error_msg_error_object::error_object(),
%%   error_msg_open_object::open_object()
%% }).

%%
%% -type error_msg()::#error_msg{}.
%% Close ---------------------------------------------------------------
-record(close_object,{
  reserved::integer(),%%16bits
  flags::integer(),%%8bits
  reason::integer(),%%8bits
  body
}).

-type close_object()::#close_object{}.

%% -record(close_msg,{
%%   close_msg_header::pcep_message(),
%%   close_msg_object::close_object()
%% }).
%%
%% -type close_msg()::#close_msg{}.