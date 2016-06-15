

%% in of_protocol application, there is no application's callback function
%% but I don't know why
%%-behaviour(application).

-module(pcep_protocol).

-include("pcep_protocol.hrl").

-export([encode/1, decode/1, parse/2]).


%% @doc encode pcep_message to binary
-spec encode(pcep_message()) -> {ok, binary()} | {error, any()}.
encode(#pcep_message{version = Version} = Message) ->
  case ?PCEP_MOD(Version) of
    unsupported ->
      {error, unsupported_version};
    Module ->
      io:format("pcep protocol Message is ~p~n", [Message]),
      Module:encode(Message)

  end.

%% @doc Decode binary to pcep message representation.
-spec decode(binary()) -> {ok, pcep_message(), binary()} | {error, any()}  |{error, unsupported_version, integer()}.
decode(Binary) when byte_size(Binary) >= ?PCEP_COMMON_HEADER_SIZE ->
  %% Flags is meaningless in pcep protocol v1.
  <<Version:3, 0:5, MessageType:8, MessageLength:16, _/bytes>> = Binary,
  case ?PCEP_MOD(Version) of
    unsupported ->
      {error, unsupported_version, MessageType};
    Module ->
      case byte_size(Binary) >= MessageLength of
        false ->
          {error, binary_too_small};
        true ->
          Module:decode(Binary)
      end
  end;
decode(_Binary) ->
  {error, binary_too_small}.

%% @doc Parse binary to pcep message representation.
-spec parse(pcep_parser(), binary()) ->{ok, pcep_parser(), [pcep_message()]}.
parse(Parse, Binary) ->
  pcep_parser:parse(Parse, Binary).