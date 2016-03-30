
%% @author Boyuan Yan <yanliuzhangyan@gmail.com>
%% @doc Common header file for all protocol versions.


%% 4bytes
-define(PCEP_COMMON_HEADER_SIZE, 4).

-define(MOD(Version), case Version of
                          1 -> pcep_v1;
                          _ -> unsupported
                      end).
%% PCEP Common Object Header ----------------------------------------------------------------------
-record(pcep_object_message, {
  object_class::integer(),
  object_type::integer(),
  res_flags::integer(),
  p::integer(),
  i::integer(),
  object_length::integer(),
  body
}).

-type pcep_object_message()::#pcep_object_message{}.


%% PCEP Message Common Header ----------------------------------------------------------------------

-record(pcep_message, {
          version=1 :: integer(), %% 3 bits
          flags=0 :: integer(), %% 5bits
          message_type :: atom(), %% 8bits 
          message_length = 4 :: integer(), %% 16btis, total length of the PCEP message including the common header, expressed in bytes.
          body::pcep_object_message() %%
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
%% TODO it should be hello message other than open message
%%-type pcep_open_element() :: {versionbitmap, [integer()]}.
%%
%%-record(pcep_open, {
%%          elements = [] :: [pcep_open_element()]
%%         }).
%%-type pcep_open() :: #pcep_open{}.

%% Parser ----------------------------------------------------------------------
%% 其用处在于通过module来调用不同协议版本的实现函数。而module的定义则需要使用？MOD(version)来得到。后面的stack暂时不知有何用处。
-record(pcep_parser, {
          version :: integer(),
          module :: atom(),
          stack = <<>> :: binary()
         }).
-type pcep_parser() :: #pcep_parser{}.

%% Client ----------------------------------------------------------------------

%% normally controller must be pce
-type controller_role() :: pce | pcc.

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
          supported_versions :: list(integer()) %% there is no need to set this because there is only one version.
         }).

%%-record(async_config, { TODO
%%          master_equal_packet_in =
%%              [
%%               %% Defaults for v4:
%%               no_match, action,
%%               %% Defaults for v5:
%%               table_miss, apply_action, action_set, group, packet_out],
%%          master_equal_port_status = [add, delete, modify],
%%          master_equal_flow_removed = [idle_timeout, hard_timeout,
%%                                       delete, group_delete, meter_delete],
%%          slave_packet_in = [],
%%          slave_port_status = [add, delete, modify],
%%          slave_flow_removed = []
%%         }).
