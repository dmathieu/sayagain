-module(say_command_test).
-include_lib("eunit/include/eunit.hrl").

unknown_command_test() ->
  Cmd = say_command:run(foobar, test),
  ?assertEqual({error, {unknown_command, foobar, test}}, Cmd).

get_command_test() -> 
  Cmd = say_command:run(<<"GET">>, "foobar"),
  ?assertEqual({ok, "Hello!"}, Cmd).

set_command_test() -> 
  Cmd = say_command:run(<<"SET">>, "foobar"),
  ?assertEqual({ok, "OK"}, Cmd).
