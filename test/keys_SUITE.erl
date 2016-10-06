-module(keys_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

all() -> 
  [set_and_get].

init_per_suite(Config) ->
  application:set_env(sayagain, address, "127.0.0.1"),
  application:set_env(sayagain, port, 5000),
  process_flag(trap_exit, true),
  {ok, Pid} = say_tcp_server:start_link(),

  {ok, Client} = connect_erldis(10),
  lists:keystore(client, 1,
                 lists:keystore(server, 1,
                                Config,
                                {server, Pid}),
                 {client, Client}).

init_per_testcase(_TestCase,Config) ->
  {client,Client} = lists:keyfind(client, 1, Config),
  erldis_client:sr_scall(Client,[<<"flushdb">>]),
  Config.

end_per_suite(Config) ->
  application:unset_env(sayagain, address),
  application:unset_env(sayagain, port),
  {server, Pid} = lists:keyfind(server, 1, Config),
  exit(Pid, kill), %% brutal kill!
  ok.

connect_erldis(0) -> {error,{socket_error,econnrefused}};
connect_erldis(Times) ->
  timer:sleep(2000),
  case erldis:connect(localhost, 5000) of
    {ok,Client} -> {ok,Client};
    _ -> connect_erldis(Times - 1)
  end.

%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%

set_and_get(Config)->
  {client,Client} = lists:keyfind(client, 1, Config),
  ok = erldis_client:sr_scall(Client, [<<"set">>,<<"string">>,<<"foo">>]),
  ok = erldis_client:sr_scall(Client, [<<"set">>,<<"string">>,<<"bar">>]),
  <<"bar">> = erldis_client:sr_scall(Client, [<<"get">>,<<"string">>]),
  nil = erldis_client:sr_scall(Client, [<<"get">>,<<"string2">>]).