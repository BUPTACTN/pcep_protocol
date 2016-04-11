%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% timeout的时候需要重连。对于openflow协议来说，重连无非是发个hello消息；
%%% 但是对于pcep协议来说，要发open消息，而发open消息需要加入节点属性信息，节点属性信息放到哪里还没想好。
%%% 因此，先开一个behaviour出来，后续直接实现它就是了。
%%% @end
%%% Created : 01. 四月 2016 下午3:01
%%%-------------------------------------------------------------------
-module(pcep_open_message).
-author("root").
-include("pcep_protocol.hrl").

%% API
-export([]).

-callback create_open_message(Version) ->pcep_message().