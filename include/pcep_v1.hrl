
%%Protocol Version
-define(VERSION, 1).


-include("pcep_logger.hrl").
-include("pcep_stateful_pce_v2.hrl").
-include("pcep_onos.hrl").
-include("pcep_ls_v2.hrl").
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
                                                                          bdwidth_req_ob_type -> true;
                                                                          bdwidth_lsp_ob_type -> true;
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
                                      end).

-define(MESSAGETYPEMOD(MessageType), case MessageType of
                                       1 -> open_msg;
                                       2 -> keepalive_msg;
                                       3 -> path_computation_request_msg;
                                       4 -> path_computation_reply_msg;
                                       5 -> notification_msg;
                                       6 -> error_msg;
                                       7 -> close_msg;
                                       %% TODO for fxf

                                       10 -> pcrpt_msg;%% draft-ietf-pce-stateful-pce-12
                                       11 -> pcupd_msg; %% draft-ietf-pce-stateful-pce-12
                                       12 -> pcinitiate_msg; %% PCE initiated tunnel setup draft-ietf-pce-pce-initiated-lsp-03, section 5.1
                                       224 -> lsrpt_msg; %% draft-dhodylee-pce-pcep-ls-02

                                       10 -> pcrpt_msg;%% draft-ietf-pce-stateful-pce-12
                                       11 -> pcupd_msg; %% draft-ietf-pce-stateful-pce-12
                                       12 ->
                                         pcinitiate_msg; %% PCE initiated tunnel setup draft-ietf-pce-pce-initiated-lsp-03, section 5.1
                                       224 -> lsrpt_msg; %% draft-dhodylee-pce-pcep-ls-02

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
    7 -> ero_ob_type; %% EXPLICIT_ROUTE object,Only the first one is meaningful
    8 -> rro_ob_type;
    9 -> lspa_ob_type;
    10 -> iro_ob_type;
    11 -> svec_ob_type;
    12 -> notification_ob_type;
    13 -> pcep_error_ob_type;
    14 -> load_balancing_ob_type;
    15 -> close_ob_type;
    32 -> lsp_ob_type;
    33 -> srp_ob_type;
    60 -> label_range_ob_type;
    224 -> case ObjectType of
             1 -> ls_link_ob_type; %% draft-dhodylee-pce-pcep-ls-02
             2 -> ls_node_ob_type;
             3 -> ls_ipv4_topo_prefix_ob_type;
             4 -> ls_ipv6_topo_prefix_ob_type
           end;
    225 -> label_ob_type;
    226 -> case ObjectType of
             1 -> fec_ipv4_ob_type;  %%draft-zhao-pce-pcep-extension-for-pce-controller-01 , section : 7.5
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
-define(Subobject_Type(SubObjectType),  %% RRO Object and ERO Object
case SubObjectType of
  1 -> ipv4_subobject_type; %% RFC 4874:3.1.1
  2 -> ipv6_subobject_type;%% RFC 4874
  3 -> label_subobject_type;%% RFC 3209
  96 -> sr_ero_subobject_type; %% draft-ietf-pce-segment-routing-00
  64 -> path_key_subobject_type; %% RFC 5520
  _ -> unsupported_subobject_type
end).
%% -define(Error_Object_TYPE_VALUE(ErrorType,ErrorValue),
%%
%%   end).

-define(Error_Object_TYPE_VALUE(ErrorType, ErrorValue),
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
           8 -> ?ERROR("LSP Object missing");  %% 8~11 draft-ietf-pce-stateful-pce-12
           9 -> ?ERROR("ERO Object missing");
           10 -> ?ERROR("SRP Object missing");
           11 -> ?ERROR("LSP-IDENTIFIERS TLV missing");
           _ -> unsupported_error_value
         end;
    7 -> ?ERROR("Synchronized path computation request missing");
    8 -> ?ERROR("Unknown request reference");
    9 -> ?ERROR("Attempt to establish a second PCEP session");
    10 -> case ErrorValue of
            1 ->
              ?ERROR("reception of an object with P flag not set although the P flag must be set according to this specification.");
            _ -> unsupported_error_value
          end;
    19 -> case ErrorValue of
            1 -> ?ERROR("Attempted LSP Update Request for a nondelegated LSP.");
            2 -> ?ERROR("Attempted LSP Update Request if the stateful PCE capability was not advertised.");
            3 -> ?ERROR("Attempted LSP Update Request for an LSP identified by an unknown PLSP-ID.");
            4 ->
              ?ERROR("A PCE indicates to a PCC that it has exceeded the resource limit allocated for its state, and thus it cannot accept and process its LSP State Report message.");
            5 -> ?ERROR("Attempted LSP State Report if active stateful PCE capability was not advertised.");
            _ -> unsupported_error_value
          end;
    20 -> case ErrorValue of
            1 ->
              ?ERROR("A PCE indicates to a PCC that it can not process (an otherwise valid) LSP State Report. The PCEP-ERROR Object is followed by the LSP Object that identifies the LSP.");
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

%% 策略一：link与Node分开定义
-define(Link_SubTLV_Type(LinkSubTLVType),
case LinkSubTLVType of
  1 -> Link_type;
  2 -> Link_ID;
  3 -> Local_interface_IP_add;
  4 -> Remote_interface_IP_add;
  5 -> TE_Metric;
  15 -> Interface_Switching_Cap_Descriptor;
  16 -> Shared_Risk_Link_Group;
  34 -> Port_Label_Restriction;
  _ -> ?ERROR("Other SubTLV Type")
end
).
-define(Node_SubTLV_Type(NodeSubTLVType),
case NodeSubTLVType of
  1 -> Node_IPv4_Local_Add;
  _ -> ?ERROR("Other NodeSubTLV Type")
end
).
%% 策略二：Link与Node一起定义，但增加参数ObjectType
-define(SubTLV_Type(ObjectType,SubTLVType),
case ObjectType of
  1 -> case SubTLVType of
         1 -> Link_type;
         2 -> Link_ID;
         3 -> Local_interface_IP_add;
         4 -> Remote_interface_IP_add;
         5 -> TE_Metric;
         15 -> Interface_Switching_Cap_Descriptor;
         16 -> Shared_Risk_Link_Group;
         34 -> Port_Label_Restriction;
         _ -> ?ERROR("Other LinkSubTLV Type")
       end;
  2 -> case SubTLVType of
         1 -> Node_IPv4_Local_Add;
         _ -> ?ERROR("Other NodeSubTLV Type")
       end;
  _ -> ?ERROR("Other LSObject Type")
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
  type :: integer(),
  length :: integer(),
  value :: any()
}).

-type tlv() :: #tlv{}.

%% Common Subobject format ---------------------------------------------------------------
-record(subobject, {
  subobject_type :: integer(), %%8bits
  subobject_length :: integer(),%%8bits
  subobject_value :: any()
}).

-type subobject() :: #subobject{}.

%% Open Message ---------------------------------------------------------------
%% open message tlvs
-record(gmpls_cap_tlv_value, {
  gmpls_cap_flag = <<0:32>> :: integer()
}).

-type gmpls_cap_tlv_value() :: #gmpls_cap_tlv_value{}.

-record(stateful_pec_cap_tlv_value, {
  stateful_pce_cap_tlv_flag = <<0:27>> :: integer(),
  stateful_pce_cap_tlv_d = true :: boolean(),
  stateful_pce_cap_tlv_t = true :: boolean(),
  stateful_pce_cap_tlv_i = true :: boolean(),
  stateful_pce_cap_tlv_s = true :: boolean(),
  stateful_pce_cap_tlv_u = true :: boolean()
}).

-type stateful_pec_cap_tlv_value() :: #stateful_pec_cap_tlv_value{}.

-record(pcecc_cap_tlv_value, {
  pcecc_cap_tlv_flag = <<0:30>> :: integer(),
  pcecc_cap_tlv_g = true :: boolean(),
  pcecc_cap_tlv_l = true :: boolean()
}).

-type pcecc_cap_tlv_value() :: #pcecc_cap_tlv_value{}.

-record(lsp_db_version_tlv_value, {
  lsp_db_version_tlv_ver = <<0:24>> :: integer()
}).

-type lsp_db_version_tlv_value() :: #lsp_db_version_tlv_value{}.

-record(ted_cap_tlv_value, {
  ted_cap_tlv_flag = <<0:31>> :: integer(),
  ted_cap_tlv_r = true :: boolean()
}).

-type ted_cap_tlv_value() :: #ted_cap_tlv_value{}.

-record(label_db_version_tlv_value, {
  label_db_version_tlv_ver = <<0:64>> :: integer()
}).

-type label_db_version_tlv_value() :: #label_db_version_tlv_value{}.

-record(open_object, {
%%   open_object_header::pcep_object_message(),
  version :: integer(), %% 3bits
  flags :: integer(), %% 5bits
  keepAlive :: integer(), %% 8bits maximum period of time in seconds between two consecutive PCEP messages
  deadTimer :: integer(), %%
  sid :: integer(),
  tlvs :: list()
%%  open_object_tlv_gmpls_cap_tlv::gmpls_cap_tlv(),
%%  open_object_tlv_stateful_pec_cap_tlv::stateful_pec_cap_tlv(),
%%  open_object_tlv_pcecc_cap_tlv::pcecc_cap_tlv()
}).

-type open_object() :: #open_object{}.

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
-record(bandwidth_req_object, {
  bandwidth :: integer()
}).

-record(bandwidth_lsp_object, {
  bandwidth :: integer()
}).

-type bandwidth_req_object() :: #bandwidth_req_object{}.

-type bandwidth_lsp_object() :: #bandwidth_lsp_object{}.
%% Path Computation Request ---------------------------------------------------------------

-record(rp_object, {
  flags :: integer(),  %%26bits
  o :: boolean(),      %%1bit
  b :: boolean(),      %%1bit
  r :: boolean(),      %%1bit
  pri :: integer(),    %%3bits
  request_id_num :: integer(),  %%32bits
  tlvs
}).

-type rp_object() :: #rp_object{}.

-record(end_points_object_ipv4, {
  source_ipv4_add :: integer(),  %% 32bits
  destination_ipv4_add :: integer()  %%32bits
}).

-record(end_points_object_ipv6, {
  source_ipv6_add :: integer(),  %% 128bits
  destination_ipv6_add :: integer()  %% 128bits
}).

-type end_points_object_ipv4() :: #end_points_object_ipv4{}.

-type end_points_object_ipv6() :: #end_points_object_ipv6{}.

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
-record(error_object, {
  reserved :: integer(), %%8bits
  flags :: integer(),%%8bits
  error_type :: integer(),%%8bits
  error_value :: integer(),%%8bits
  tlvs
}).

-type error_object() :: #error_object{}.

%% -record(error_msg,{
%%   error_msg_header::pcep_message(),
%%   error_msg_error_object::error_object(),
%%   error_msg_open_object::open_object()
%% }).

%%
%% -type error_msg()::#error_msg{}.
%% Close ---------------------------------------------------------------
-record(close_object, {
  reserved :: integer(),%%16bits
  flags :: integer(),%%8bits
  reason :: integer(),%%8bits
  tlvs
}).

-type close_object() :: #close_object{}.

%% -record(close_msg,{
%%   close_msg_header::pcep_message(),
%%   close_msg_object::close_object()
%% }).
%%
%% -type close_msg()::#close_msg{}.


%% 奇怪的结构定义，在linc_pcep_ls_oe中有使用
%% TODO
-record(linc_port_desc_prop_optical_transport, {
  type :: integer(),
  length :: integer(),
  port_signal_type :: integer(),
  reserved :: integer(),
  features = [] :: [linc_port_optical_transport_feature()]
}).

-type linc_port_desc_prop_optical_transport() :: #linc_port_desc_prop_optical_transport{}.

-record(linc_port_optical_transport_application_code, {
  feature_type :: integer(),
  length :: integer(),
  oic_type :: integer(),
  app_code :: binary()
}).

-type linc_port_optical_transport_application_code() :: #linc_port_optical_transport_application_code{}.

-type linc_port_optical_transport_feature() :: #linc_port_optical_transport_application_code{} |
#linc_port_optical_transport_layer_stack{}.

-record(linc_port_optical_transport_layer_stack, {
  feature_type :: integer(),
  length :: integer(),
  value = [] :: [ofp_port_optical_transport_layer_entry()]
}).
-record(ofp_port_optical_transport_layer_entry, {
  layer_class :: integer(),
  signal_type :: integer(),
  apaptation :: integer()
}).

-type ofp_port_optical_transport_layer_entry() :: #ofp_port_optical_transport_layer_entry{}.
-type linc_port_optical_transport_layer_stack() :: #linc_port_optical_transport_layer_stack{}.

%%%-----------------------------------------------------------------------------
%%% Common Structures (A 2)
%%%-----------------------------------------------------------------------------

%%%-----------------------------------------------------------------------------
%%% Port Structures (A 2.1)
%%%-----------------------------------------------------------------------------

-type pcep_port_config() :: port_down
                          | no_recv
                          | no_fwd
                          | no_packet_in.

-type pcep_port_state() :: link_down
                          | blocked
                          | live.

-type pcep_port_reserved() :: in_port
                          | table
                          | normal
                          | flood
                          | all
                          | controller
                          | local
                          | any.

-type pcep_port_no() :: integer()
                          | pcep_port_reserved().

-type pcep_port_feature() :: '10mb_hd'
                          | '10mb_fd'
                          | '100mb_hd'
                          | '100mb_fd'
                          | '1gb_hd'
                          | '1gb_fd'
                          | '10gb_fd'
                          | '40gb_fd'
                          | '100gb_fd'
                          | '1tb_fd'
                          | other
                          | copper
                          | fiber
                          | autoneg
                          | pause
                          | pause_asym.

-record(pcep_port, {
  port_no :: pcep_port_no(),
  hw_addr :: binary(),
  name :: binary(),
  config = [] :: [pcep_port_config()],
  state = [] :: [pcep_port_state()],
  curr = [] :: [pcep_port_feature()],
  advertised = [] :: [pcep_port_feature()],
  supported = [] :: [pcep_port_feature()],
  peer = [] :: [pcep_port_feature()],
  curr_speed = 0 :: integer(),
  max_speed = 0 :: integer()
}).
-type pcep_port() :: #pcep_port{}.

-type pcep_messsage_body() :: pcep_open_msg() |
                              pcep_error_msg() |
                              pcep_keepalive_msg() |
                              pcep_pcinitiate_msg() |
                              pcep_pcupd_msg() |
                              pcep_pcrpt_msg() |
                              pcep_pclabelupd_msg() |
                              pcep_lsrpt_msg() |
                              pcep_pclrresv_msg().

%% -type pcep_message_body() :: pcep_error_msg() |
%%                              %% Open Message handle
%%                              pcep_open_request() |
%%                              pcep_open_reply() |
%%                              %% Keepalive Message handle
%%                              pcep_keepalive_request() |
%%                              pcep_keepalive_reply() |
%%                              %% PCInitiate Message handle
%%                              pcep_pcinitiate_request() |
%%                              pcep_pcinitiate_reply() |
%%
%%                              pcep_report_msg() |
%%                              pcep_lsrpt_msg() |
%%                              %% PCUpd Message handle
%%                              pcep_pcupd_request() |
%%                              pcep_pcupd_reply() |
%%                              %% PCLabelUpd Message handle
%%                              pcep_pclabelupd_request() |
%%                              pcep_pclabelupd_reply() |
%%                              %% PCLRResv Message handle
%%                              pcep_pclrresv_request() |
%%                              pcep_pclrresv_reply().
-record(pcep_error_msg, {
  pcep_error_object :: error_object()
}).

-type pcep_error_msg() :: #pcep_error_msg{}.

-record(pcep_open_msg, {
  pcep_open_object :: open_object()
}).

-type pcep_open_msg() :: #pcep_open_msg{}.

-record(pcep_keepalive_msg, {
  %% TODO how to write null?
}).

-type pcep_keepalive_msg() :: #pcep_keepalive_msg{}.

-record(pcep_pcinitiate_msg, {
  pcep_pcinit_srp_object :: srp_object(),
  pcep_pcinit_lsp_object :: lsp_object(),  %% TODO lsp object number of every bit
  pcep_pcinit_end_points_object :: end_points_object_ipv4(),
  pcep_pcinit_ero_object :: ero_object(),
  pcep_pcinit_bandwidth_object :: bandwidth_lsp_object()   %% two bandwidth objects have been defined???!!!!
}).

-type pcep_pcinitiate_msg() :: #pcep_pcinitiate_msg{}.

-record(pcep_pcupd_msg, {
  pcep_pcupd_srp_object::srp_object(),
  pcep_pcupd_lsp_object::lsp_object(),
  pcep_pcupd_ero_object::ero_object(),
  pcep_pcupd_bandwidth_object::bandwidth_lsp_object()
}).

-type pcep_pcupd_msg() :: #pcep_pcupd_msg{}.

-record(pcep_pcrpt_msg, {
  pcep_pcrpt_srp_object::srp_object(),
  pcep_pcrpt_lsp_object::lsp_object(),
  pcep_pcrpt_rro_object::rro_object(),
  pcep_pcrpt_bandwidth_object::bandwidth_lsp_object()
}).

-type pcep_pcrpt_msg() :: #pcep_pcrpt_msg{}.
%% TODO PCLabelUpd msg needed?????
-record(pcep_pclabelupd_msg, {
  pcep_pclabelupd_srp_object::srp_object(),
  pcep_pclabelupd_label_object::label_object(),
  pcep_pclabelupd_fec_object::fec_ipv4_object()
}).

-type pcep_pclabelupd_msg() :: #pcep_pclabelupd_msg{}.

-record(pcep_pclrresv_msg, {
  pcep_pclrresv_srp_object::srp_object(),
  pcep_pclrresv_label_range_object::label_range_object()
}).

-type pcep_pclrresv_msg() :: #pcep_pclrresv_msg{}.

-record(pcep_lsrpt_msg, {
  pcep_lsrpt_msg :: ls_object()
}).

-type pcep_lsrpt_msg() :: #pcep_lsrpt_msg{}.