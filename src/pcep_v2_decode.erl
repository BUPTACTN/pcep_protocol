%% %%%-------------------------------------------------------------------
%% %%% @author Xinfeng
%% %%% @copyright (C) 2016, <COMPANY>
%% %%% @doc
%% %%%
%% %%% @end
%% %%% Created : 10. 十一月 2016 21:22
%% %%%-------------------------------------------------------------------
%% -module(pcep_v2_decode).
%% -author("Xinfeng").
%% -include("pcep_logger.hrl").
%% -include("pcep_protocol.hrl").
%% %% API
%% -export([]).
%%
%% do(Binary) when ?PCEP_COMMON_HEADER_SIZE > erlang:byte_size(Binary) ->
%%   {error,binary_too_small};
%% do(Binary) ->
%%   <<Version:3,Flags:5,MsgType:8,MsgLength:16,Binary2/bytes>> = Binary,
%%   case MsgLength > erlang:byte_size(Binary) of
%%     true ->
%%       {error,binary_too_small};
%%     false ->
%%       BodyLength = MsgLength - 4,
%%       <<BodyBin:BodyLength/bytes,Rest/bytes>> = Binary2,
%%       decode_object_msg(BodyBin),
%%       {ok,}
%%   end.
%%
%% decode_object_msg(Binary) ->
%%   <<Class:8,OT:4,Flags:2,P:1,I:1,Ob_length:16>> = binary_part(Binary,{0,4}),
%%   <<Ob_body>> = binary_part(Binary,{4,Ob_length}),
%%   if Ob_length < byte_size(Binary) ->
%%     Num = byte_size(Binary)-Ob_length,
%%     <<Res>> = binary_part(Binary,{byte_size(Binary),Ob_length-byte_size(Binary)}),
%%     decode_object_msg(Res);
%%     true ->
%%       <<>>
%%   end.
