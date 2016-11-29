-module(keys_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

all() -> 
  [set_and_get].

start_server() ->
  application:set_env(sayagain, address, localhost),
  application:set_env(sayagain, port, 1304),
  process_flag(trap_exit, true),
  say_sup:start_link().

stop_server(Pid) ->
  application:unset_env(sayagain, address),
  application:unset_env(sayagain, port),
  exit(Pid, kill). %% brutal kill!

connect_erldis(0) -> {error,{socket_error,econnrefused}};
connect_erldis(Times) ->
  timer:sleep(2000),
  case erldis:connect(localhost, 1304) of
    {ok,Client} -> {ok, Client};
    _ -> connect_erldis(Times - 1)
  end.

%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%

set_and_get(_Config)->
  {ok, Pid} = start_server(),
  {ok, Client} = connect_erldis(10),
  ok = erldis_client:sr_scall(Client, [<<"flushall">>]),

  ok = erldis_client:sr_scall(Client, [<<"set">>,<<"string">>,<<"foo">>]),
  ok = erldis_client:sr_scall(Client, [<<"set">>,<<"string">>,<<"bar">>]),
  <<"bar">> = erldis_client:sr_scall(Client, [<<"get">>,<<"string">>]),
  nil = erldis_client:sr_scall(Client, [<<"get">>,<<"string2">>]),

  stop_server(Pid).
