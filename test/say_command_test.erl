-module(say_command_test).
-include_lib("eunit/include/eunit.hrl").

setup() ->
  process_flag(trap_exit, true),
  {ok, Pid} = say_command:start_link(),
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
  ?assertEqual(<<"Hello">>, say_command:run(<<"GET">>, "foobar")),
  cleanup(Pid).

set_command_test() -> 
  Pid = setup(),
  ?assertEqual(ok, say_command:run(<<"SET">>, ["foobar", "test"])),
  cleanup(Pid).
