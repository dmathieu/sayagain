-module(say_command_test).
-include_lib("eunit/include/eunit.hrl").

setup() ->
  process_flag(trap_exit, true),
  {ok, Pid} = say_cmd_sup:start_link(),
  Pid.

cleanup(Pid) ->
  exit(Pid, kill), %% brutal kill!
  ?assertEqual(false, is_process_alive(Pid)).

unknown_command_test() ->
  Pid = setup(),
  ?assertEqual({error, "unknown command 'foobar'"}, say_command:run(<<"foobar">>, test)),
  cleanup(Pid).

get_command_test() ->
  Pid = setup(),
  say_command:run(<<"SET">>, [<<"foobar">>, "Hello"]),
  ?assertEqual("Hello", say_command:run(<<"GET">>, [<<"foobar">>])),
  cleanup(Pid).

get_lower_command_test() ->
  Pid = setup(),
  say_command:run(<<"set">>, [<<"foobar">>, "Hello"]),
  ?assertEqual("Hello", say_command:run(<<"get">>, [<<"foobar">>])),
  cleanup(Pid).

get_unknown_key_test() ->
  Pid = setup(),
  ?assertEqual({error, "unknown key 'foobar'"}, say_command:run(<<"GET">>, [<<"foobar">>])),
  cleanup(Pid).

set_command_test() ->
  Pid = setup(),
  ?assertEqual(ok, say_command:run(<<"SET">>, ["foobar", "test"])),
  cleanup(Pid).

flushall_command_test() ->
  Pid = setup(),
  ?assertEqual(ok, say_command:run(<<"FLUSHALL">>, [])),
  cleanup(Pid).
