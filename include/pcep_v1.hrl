
%%Protocol Version
-define(VERSION, 1).

% Message-Type (8 bits):
% 1     Open
% 2     Keepalive
% 3     Path Computation Request
% 4     Path Computation Reply
% 5     Notification
% 6     Error
% 7     Close

%% Open Message ---------------------------------------------------------------

-record(open_object, {
  version::integer(), %% 3bits
  flags::integer(), %% 5bits
  keepAlive::integer(), %% 8bits maximum period of time in seconds between two consecutive PCEP messages
  deadTimer::integer(), %%
  sid::integer(),
  body
}).

-type open_object()::#open_object{}.

%% open message tlvs
-record(open_object_tlv_demo, {

}).

-type open_object_tlv_demo()::#open_object_tlv_demo{}.


%% Keepalive message ---------------------------------------------------------------

%% empty


%% Path Computation Request ---------------------------------------------------------------





%% Path Computation Reply ---------------------------------------------------------------




%% Notification ---------------------------------------------------------------





%% Error ---------------------------------------------------------------




%% Close ---------------------------------------------------------------