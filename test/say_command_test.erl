-module(say_command_test).
-include_lib("eunit/include/eunit.hrl").

unknown_command_test() ->
  Cmd = say_command:run(<<"foobar">>, test),
  ?assertEqual({error, "unknown command 'foobar'"}, Cmd).

get_command_test() -> 
  Cmd = say_command:run(<<"GET">>, "foobar"),
  ?assertEqual("Hello", Cmd).

set_command_test() -> 
  Cmd = say_command:run(<<"SET">>, "foobar"),
  ?assertEqual(ok, Cmd).
