
%%Protocol Version
-define(VERSION, 1).



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
-record(tlv, {
  name::atom(),  %% the name of this tlv's type
  type::integer(),
  length::integer(),
  value::any()
}).

-type tlv()::#tlv{}.


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