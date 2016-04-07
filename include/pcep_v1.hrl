
%%Protocol Version
-define(VERSION, 1).


-include("pcep_logger.hrl").

%% TODO for fxf
-define(ISLEGAL(MessageType, Object), case MessageType of
                                        open_msg -> case Object of
                                                      open_ob_type -> true
                                                    end;
                                        keepalive_msg -> true;
                                        path_computation_request_msg -> case Object of
                                                                          rp_ob_type -> true;
                                                                          end_points_v4_ob_type -> true;
                                                                          end_points_v6_ob_type -> true;
                                                                          lspa_ob_type -> true;
                                                                          bdwidth_req_ob_type ->true;
                                                                          bdwidth_lsp_ob_type ->true;
                                                                          metric_ob_type -> true;
                                                                          iro_ob_type -> true;
                                                                          load_balancing_ob_type -> true
                                                                        end;
                                        path_computation_reply_msg -> case Object of
                                                                        rp_ob_type -> true
                                                                      end;
                                        notification_msg -> case Object of
                                                              rp_ob_type -> true;
                                                              notification_ob_type -> true
                                                            end;
                                        error_msg -> case Object of
                                                       open_ob_type -> true;
                                                       pcep_error_ob_type -> true
                                                     end;
                                        close_msg -> case Object of
                                                       close_ob_type -> true
                                                     end;
                                        pcinitiate_msg -> case Object of
                                                            srp_ob_type -> true;
                                                            lsp_ob_type -> true;
                                                            end_points_v4_ob_type -> true;
                                                            end_points_v6_ob_type -> true;
                                                            ero_ob_type -> true;
                                                            bdwidth_req_ob_type -> true;
                                                            bdwidth_lsp_ob_type -> true
                                                          end;
                                        pcupd_msg -> case Object of
                                                       srp_ob_type -> true;
                                                       lsp_ob_type -> true;
                                                       ero_ob_type -> true;
                                                       bdwidth_req_ob_type -> true;
                                                       bdwidth_lsp_ob_type -> true
                                                     end;
                                        pcrpt_msg -> case Object of
                                                       srp_ob_type -> true;
                                                       lsp_ob_type -> true;
                                                       rro_ob_type -> true;
                                                       bdwidth_req_ob_type -> true;
                                                       bdwidth_lsp_ob_type -> true
                                                     end;
                                        pclabelupd_msg -> case Object of
                                                            srp_ob_type -> true;
                                                            label_ob_type -> true;
                                                            fec_ipv4_ob_type -> true;
                                                            fec_ipv6_ob_type -> true;
                                                            fec_ipv4_adjacency_ob_type -> true;
                                                            fec_ipv6_adjacency_ob_type -> true
                                                           %% fec_ipv4_unnumbered_ob_type -> true
                                                          end;
                                        lsrpt_msg -> case Object of
                                                       ls_link_ob_type -> true;
                                                       ls_node_ob_type -> true;
                                                       ls_ipv4_topo_prefix_ob_type -> true;
                                                       ls_ipv6_topo_prefix_ob_type -> true
                                                     end;
                                        pclrresv_msg -> case Object of
                                                          srp_ob_type -> true;
                                                          label_range_ob_type -> true
                                                        end
                                      end ).

-define(MESSAGETYPEMOD(MessageType), case MessageType of
                                       1 -> open_msg;
                                       2 -> keepalive_msg;
                                       3 -> path_computation_request_msg;
                                       4 -> path_computation_reply_msg;
                                       5 -> notification_msg;
                                       6 -> error_msg;
                                       7 -> close_msg;
                                       %% TODO for fxf
                                       10 -> pcrpt_msg;%% TODO draft-ietf-pce-stateful-pce-12
                                       11 -> pcupd_msg; %% TODO draft-ietf-pce-stateful-pce-12
                                       12 -> pcinitiate_msg; %% TODO PCE initiated tunnel setup draft-ietf-pce-pce-initiated-lsp-03, section 5.1
                                       224 -> lsrpt_msg; %% TODO draft-dhodylee-pce-pcep-ls-02
                                       225 -> pclrresv_msg;
                                       226 -> pclabelupd_msg;
                                       _ -> unsupported_msg
                                     end).


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
    7 -> ero_ob_type; %% TODO EXPLICIT_ROUTE object,Only the first one is meaningful
    8 -> rro_ob_type;
    9 -> lspa_ob_type;
    10 -> iro_ob_type;
    11 -> svec_ob_type;
    12 -> notification_ob_type;
    13 ->pcep_error_ob_type;
    14 -> load_balancing_ob_type;
    15 -> close_ob_type;
    32 -> lsp_ob_type;
    33 -> srp_ob_type;
    60 -> label_range_ob_type;
    224 -> case ObjectType of
             1 -> ls_link_ob_type; %% TODO draft-dhodylee-pce-pcep-ls-02
             2 -> ls_node_ob_type;
             3 -> ls_ipv4_topo_prefix_ob_type;
             4 -> ls_ipv6_topo_prefix_ob_type
           end;
    225 -> label_ob_type;
    226 -> case ObjectType of
             1 -> fec_ipv4_ob_type;  %%TODO draft-zhao-pce-pcep-extension-for-pce-controller-01 , section : 7.5
             2 -> fec_ipv6_ob_type;
             3 -> fec_ipv4_adjacency_ob_type;
             4 -> fec_ipv6_adjacency_ob_type
          %%   5 -> fec_ipv4_unnumbered_ob_type
             end;
    _ -> unsupported_class
  end).

-define(TLV_Type(Type),
  case Type of
    14 -> gmpls_cap_tlv_type;
    16 -> stateful_pce_cap_tlv_type;
    32 -> pcecc_cap_tlv_type;
    23 -> label_db_version_tlv_type;
    132 -> ted_cap_tlv_type;
    65280 -> ls_cap_tlv_type;
    65281 -> routing_universe_tlv_type;
    65282 -> local_node_descriptor_tlv_type;
    65283 -> remote_node_descriptor_tlv_type;
    65284 -> link_descriptors_tlv_type;
    65285 -> node_attributes_tlv_type;
    17 -> symbolic_path_name_tlv_type;
    18 -> ipv4_lsp_identifiers_tlv_type;
    20 -> lsp_error_code_tlv_type;
    21 -> rsvp_error_spec_tlv_type;
    2 -> next_hop_ipv4_add_tlv_type;
    1 -> next_hop_unnumbered_ipv4_id_tlv_type;
    _ -> unsupported_tlv_type
end).
-define(Subobject_Type(SubObjectType),  %% TODO RRO Object and ERO Object
case SubObjectType of
  1 -> ipv4_subobject_type; %% TODO RFC 4874:3.1.1
  2 -> ipv6_subobject_type;%% TODO RFC 4874
  3 -> label_subobject_type;%% TODO RFC 3209
  96 -> sr_ero_subobject_type; %% TODO draft-ietf-pce-segment-routing-00
  64 -> path_key_subobject_type; %% TODO RFC 5520
  _ -> unsupported_subobject_type
end).
-define(Error_Object_TYPE_VALUE(ErrorType,ErrorValue),
  case ErrorType of
    1 -> case ErrorValue of
           1 -> ?ERROR("reception of an invalid Open message or a non Open message");
           2 -> ?ERROR("no Open message received before the expiration of the OpenWait timer");
           3 -> ?ERROR("unacceptable and non-negotiable session characteristics");
           4 -> ?ERROR("unacceptable but negotiable session characteristics");
           5 -> ?ERROR("reception of a second Open message with still unacceptable session characteristics");
           6 -> ?ERROR("reception of a PCErr message proposing unacceptable session characteristics");
           7 -> ?ERROR("No Keepalive or PCErr message received before the expiration of the KeepWait timer");
           8 -> ?ERROR("PCEP version not supported")
         end;
    2 -> ?ERROR("Capability not supported");
    3 -> case ErrorValue of
           1 -> ?ERROR("Unrecognized object class");
           2 -> ?ERROR("Unrecognized object Type");
           _ -> unsupported_error_value
         end;
    4 -> case ErrorValue of
           1 -> ?ERROR("Not supported object class");
           2 -> ?ERROR("Not supported object Type");
           _ -> unsupported_error_value
         end;
    5 -> case ErrorValue of
           1 -> ?ERROR("C bit of the METRIC object set (request rejected)");
           2 -> ?ERROR("O bit of the RP object cleared (request rejected)");
           _ -> unsupported_error_value
         end;
    6 -> case ErrorValue of
           1 -> ?ERROR("RP object missing");
           2 -> ?ERROR("RRO missing for a reoptimization request (R bit of the RP object set)");
           3 -> ?ERROR("END-POINTS object missing");
           8 -> ?ERROR("LSP Object missing");  %% TODO 8~11 draft-ietf-pce-stateful-pce-12
           9 -> ?ERROR("ERO Object missing");
           10 -> ?ERROR("SRP Object missing");
           11 -> ?ERROR("LSP-IDENTIFIERS TLV missing");
           _ -> unsupported_error_value
         end;
    7 -> ?ERROR("Synchronized path computation request missing");
    8 -> ?ERROR("Unknown request reference");
    9 -> ?ERROR("Attempt to establish a second PCEP session");
    10 -> case ErrorValue of
            1 -> ?ERROR("reception of an object with P flag not set although the P flag must be set according to this specification.");
            _ -> unsupported_error_value
          end;
    19 ->case ErrorValue of
           1 -> ?ERROR("Attempted LSP Update Request for a nondelegated LSP.");
           2 -> ?ERROR("Attempted LSP Update Request if the stateful PCE capability was not advertised.");
           3 -> ?ERROR("Attempted LSP Update Request for an LSP identified by an unknown PLSP-ID.");
           4 -> ?ERROR("A PCE indicates to a PCC that it has exceeded the resource limit allocated for its state, and thus it cannot accept and process its LSP State Report message.");
           5 -> ?ERROR("Attempted LSP State Report if active stateful PCE capability was not advertised.");
           _ -> unsupported_error_value
    end;
    20 -> case ErrorValue of
            1 -> ?ERROR("A PCE indicates to a PCC that it can not process (an otherwise valid) LSP State Report. The PCEP-ERROR Object is followed by the LSP Object that identifies the LSP.");
            5 -> ?ERROR("A PCC indicates to a PCE that it can not complete the state synchronization,")
          end
  end
).
-define(Close_Object_REASONS(CloseReasons),
case CloseReasons of
  1 -> erlang:io:format("No explanation provided");
  2 -> erlang:io:format("DeadTimer expired");
  3 -> erlang:io:format("Reception of a malformed PCEP message");
  4 -> erlang:io:format("Reception of an unacceptable number of unknown requests/replies");
  5 -> erlang:io:format("Reception of an unacceptable number of unrecognized PCEP messages")
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
%% TODO error
-record(tlv, {
 type::integer(),
 length::integer(),
 value::any()
}).

-type tlv()::#tlv{}.

%% Common Subobject format ---------------------------------------------------------------
-record(subobject, {
  subobject_type::integer(), %%8bits
  subobject_length::integer(),%%8bits
  subobject_value::any()
}).

-type subobject()::#subobject{}.

%% Open Message ---------------------------------------------------------------
%% open message tlvs
-record(gmpls_cap_tlv_value, {
  gmpls_cap_flag = <<0:32>> :: integer()
}).

-type gmpls_cap_tlv_value()::#gmpls_cap_tlv_value{}.

-record(stateful_pec_cap_tlv_value,{
  stateful_pce_cap_tlv_flag = <<0:27>> ::integer(),
  stateful_pce_cap_tlv_d = true::boolean(),
  stateful_pce_cap_tlv_t = true::boolean(),
  stateful_pce_cap_tlv_i = true::boolean(),
  stateful_pce_cap_tlv_s = true::boolean(),
  stateful_pce_cap_tlv_u = true::boolean()
}).

-type stateful_pec_cap_tlv_value()::#stateful_pec_cap_tlv_value{}.

-record(pcecc_cap_tlv_value,{
  pcecc_cap_tlv_flag = <<0:30>>::integer(),
  pcecc_cap_tlv_g = true ::boolean(),
  pcecc_cap_tlv_l = true ::boolean()
}).

-type pcecc_cap_tlv_value()::#pcecc_cap_tlv_value{}.

-record(lsp_db_version_tlv_value,{
  lsp_db_version_tlv_ver = <<0:24>> ::integer()
}).

-type lsp_db_version_tlv_value()::#lsp_db_version_tlv_value{}.

-record(ted_cap_tlv_value,{
  ted_cap_tlv_flag = <<0:31>> ::integer(),
  ted_cap_tlv_r = true ::boolean()
}).

-type ted_cap_tlv_value()::#ted_cap_tlv_value{}.

-record(label_db_version_tlv_value,{
  label_db_version_tlv_ver = <<0:64>>::integer()
}).

-type label_db_version_tlv_value()::#label_db_version_tlv_value{}.

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
-record(bandwidth_req_object,{
  bandwidth::integer()
}).

-record(bandwidth_lsp_object,{
  bandwidth::integer()
}).

-type bandwidth_req_object()::#bandwidth_req_object{}.

-type bandwidth_lsp_object()::#bandwidth_lsp_object{}.
%% Path Computation Request ---------------------------------------------------------------

-record(rp_object,{
  flags::integer(),  %%26bits
  o::boolean(),      %%1bit
  b::boolean(),      %%1bit
  r::boolean(),      %%1bit
  pri::integer(),    %%3bits
  request_id_num::integer(),  %%32bits
  tlvs
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
  tlvs
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
  tlvs
}).

-type close_object()::#close_object{}.

%% -record(close_msg,{
%%   close_msg_header::pcep_message(),
%%   close_msg_object::close_object()
%% }).
%%
%% -type close_msg()::#close_msg{}.