-module(say_value_test).
-include_lib("eunit/include/eunit.hrl").

setup() ->
  process_flag(trap_exit, true),
  {ok, Pid} = say_value:start_link(),
  Pid.

cleanup(Pid) ->
  exit(Pid, kill), %% brutal kill!
  ?assertEqual(false, is_process_alive(Pid)).

start_server_test() ->
  Pid = setup(),
  ?assertEqual(true, is_process_alive(Pid)),
  cleanup(Pid).

unknown_method_test() ->
  Pid = setup(),
  ?assertEqual({error, unknown_command}, gen_server:call(Pid, foobar)),
  cleanup(Pid).

write_test() ->
  Pid = setup(),
  ?assertEqual(ok, gen_server:call(Pid, {write, [<<"foobar">>, <<"test">>]})),
  cleanup(Pid).

read_test() ->
  Pid = setup(),
  gen_server:call(Pid, {write, [<<"hello">>, world]}),
  ?assertEqual(world, gen_server:call(Pid, {read, [<<"hello">>]})),
  cleanup(Pid).
unknown_value_read_test() ->
  Pid = setup(),
  ?assertEqual(nil, gen_server:call(Pid, {read, [<<"hello">>]})),
  cleanup(Pid).

flush_test() ->
  Pid = setup(),
  gen_server:call(Pid, {write, [hello, world]}),
  ?assertEqual(ok, gen_server:call(Pid, {flush, []})),
  ?assertEqual(nil, gen_server:call(Pid, {read, [<<"hello">>]})),
  cleanup(Pid).
