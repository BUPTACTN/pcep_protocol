
%% @author Boyuan Yan <yanliuzhangyan@gmail.com>
%% @doc Common header file for all protocol versions.
%% 32bits
-define(PCEP_COMMON_HEADER_SIZE, 32).

-define(MOD(Version), case Version of
                          1 -> pcep_v1;
                          _ -> unsupported
                      end).

%% Header ----------------------------------------------------------------------

-record(pcep_message, {
          version=1 :: integer(), %% 3 bits
          flags=0 :: integer(), %% 5bits
          message_type :: atom(), %% 8bits 
          message_length = 4 :: integer(), %% 16btis, total length of the PCEP message including the common header, expressed in bytes.
          body %% pcep_message_body()
         }).
-type pcep_message() :: #pcep_message{}.

% Message-Type (8 bits):
% 1     Open
% 2     Keepalive
% 3     Path Computation Request
% 4     Path Computation Reply
% 5     Notification
% 6     Error
% 7     Close


%% Open message ---------------------------------------------------------------

-type pcep_open_element() :: {versionbitmap, [integer()]}.

-record(pcep_open, {
          elements = [] :: [ofp_hello_element()]
         }).
-type pcep_open() :: #pcep_open{}.

%% Parser ----------------------------------------------------------------------

-record(ofp_parser, {
          version :: integer(),
          module :: atom(),
          stack = <<>> :: binary()
         }).
-type ofp_parser() :: #ofp_parser{}.

%% Client ----------------------------------------------------------------------

-type controller_role() :: master | equal | slave.

-record(controller_status, {
          resource_id        :: string(),
          role               :: controller_role(),
          controller_ip      :: string(),
          controller_port    :: integer(),
          local_ip           :: string(),
          local_port         :: integer(),
          protocol           :: atom(),
          connection_state   :: atom(),
          current_version    :: integer(),
          supported_versions :: list(integer())
         }).

-record(async_config, {
          master_equal_packet_in =
              [
               %% Defaults for v4:
               no_match, action,
               %% Defaults for v5:
               table_miss, apply_action, action_set, group, packet_out],
          master_equal_port_status = [add, delete, modify],
          master_equal_flow_removed = [idle_timeout, hard_timeout,
                                       delete, group_delete, meter_delete],
          slave_packet_in = [],
          slave_port_status = [add, delete, modify],
          slave_flow_removed = []
         }).
