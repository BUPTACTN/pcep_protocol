%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 三月 2016 下午7:06
%%%-------------------------------------------------------------------
-module(test).
-author("root").

%% Common TLV format ---------------------------------------------------------------
-record(tlv, {
  name::atom(),  %% the name of this tlv's type
  type::integer(),
  length::integer(),
  value::any()
}).

-type tlv()::#tlv{}.

%% API
-export([encode_tlvs/1, test/0, encode_tlv/1, other/0]).


-spec encode_tlv(Tlv::tlv()) -> binary().
encode_tlv(#tlv{type = Type, length = Length, value = Value}) ->
  <<Type:16, Length:16, Value/bytes>>.

%%-spec encode_tlvs(list()) ->binary().

encode_tlvs([Tlv | T]) ->
  T2 = encode_tlv(Tlv),
  T3 = encode_tlvs(T),
<<T2/bytes, T3/bytes>>;

%%  <<T2, T3>>;
encode_tlvs([]) ->
  <<>>.

test() ->
  Bs = erlang:list_to_bitstring("abc"),
  Sample = #tlv{type = 1, length = 2, value = Bs},
%%  M = [Sample, Sample, Sample],
  encode_tlvs([Sample, Sample]).


other()->
  Bin1 = <<1,2,3>>,
  <<5,6,Bin1/bytes>>.