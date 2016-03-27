
%%Protocol Version
-define(VERSION, 1).

%% -include("pcep_protocol.hrl").
%% -include("pcep_ls_v2.hrl").


-define(CLASSTYPEMOD(ObjectClass, ObjectType),
  case ObjectClass of
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
    6 -> metric_ob_type;
    7 -> ero_ob_type;
    8 -> rro_ob_type;
    9 -> lspa_ob_type;
    10 -> iro_ob_type;
    11 -> svec_ob_type;
    12 -> notification_ob_type;
    13 ->pcep_error_ob_type;
    14 -> load_balancing_ob_type;
    15 -> close_ob_type;

    _ -> unsupported_class

  end).
-define(Error_Object_TYPE_VALUE(ErrorType,ErrorValue),
  case ErrorType of
    1 -> case ErrorValue of
           1 -> io:format("reception of an invalid Open message or a non Open message");
           2 -> io:format("no Open message received before the expiration of the OpenWait timer");
           3 -> io:format("unacceptable and non-negotiable session characteristics");
           4 -> io:format("unacceptable but negotiable session characteristics");
           5 -> io:format("reception of a second Open message with still unacceptable session characteristics");
           6 -> io:format("reception of a PCErr message proposing unacceptable session characteristics");
           7 -> io:format("No Keepalive or PCErr message received before the expiration of the KeepWait timer");
           8 -> io:format("PCEP version not supported")
         end;
    2 -> io:format("Capability not supported");
    3 -> case ErrorValue of
           1 -> io:format("Unrecognized object class");
           2 -> io:format("Unrecognized object Type");
           _ -> unsupported_error_value
         end;
    4 -> case ErrorValue of
           1 -> io:format("Not supported object class");
           2 -> io:format("Not supported object Type");
           _ -> unsupported_error_value
         end;
    5 -> case ErrorValue of
           1 -> io:format("C bit of the METRIC object set (request rejected)");
           2 -> io:format("O bit of the RP object cleared (request rejected)");
           _ -> unsupported_error_value
         end;
    6 -> case ErrorValue of
           1 -> io:format("RP object missing");
           2 -> io:format("RRO missing for a reoptimization request (R bit of the RP object set)");
           3 -> io:format("END-POINTS object missing");
           _ -> unsupported_error_value
         end;
    7 -> io:format("Synchronized path computation request missing");
    8 -> io:format("Unknown request reference");
    9 -> io:format("Attempt to establish a second PCEP session");
    10 -> case ErrorValue of
            1 -> io:format("reception of an object with P flag not set although the P flag must be set according to this specification.");
            _ -> unsupported_error_value
          end
  end
).
-define(Close_Object_REASONS(CloseReasons),
case CloseReasons of
  1 -> io:format("No explanation provided");
  2 -> io:format("DeadTimer expired");
  3 -> io:format("Reception of a malformed PCEP message");
  4 -> io:format("Reception of an unacceptable number of unknown requests/replies");
  5 -> io:format("Reception of an unacceptable number of unrecognized PCEP messages")
end
).
% Message-Type (8 bits):
% 1     Open
% 2     Keepalive
% 3     Path Computation Request
% 4     Path Computation Reply
% 5     Notification
% 6     Error
% 7     Close


%% Common TLV format ---------------------------------------------------------------
-record(tlv, {
  name::atom(),  %% the name of this tlv's type
  type::integer(),
  length::integer(),
  value::any()
}).

-type tlv()::#tlv{}.


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
  open_object_tlv_gmpls_cap_tlv::gmpls_cap_tlv(),
  open_object_tlv_stateful_pec_cap_tlv::stateful_pec_cap_tlv(),
  open_object_tlv_pcecc_cap_tlv::pcecc_cap_tlv()
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