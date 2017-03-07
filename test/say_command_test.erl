-module(say_command_test).
-include_lib("eunit/include/eunit.hrl").

unknown_command_test() ->
  say_value:flush(),
  ?assertEqual({error, "unknown command 'foobar'"}, say_command:run(<<"foobar">>, test)).

get_command_test() ->
  say_value:flush(),
  say_command:run(<<"SET">>, [foobar, "Hello"]),
  ?assertEqual("Hello", say_command:run(<<"GET">>, [foobar])).

get_lower_command_test() ->
  say_value:flush(),
  say_command:run(<<"set">>, [foobar, "Hello"]),
  ?assertEqual("Hello", say_command:run(<<"get">>, [foobar])).

get_unknown_key_test() ->
  say_value:flush(),
  ?assertEqual(nil, say_command:run(<<"GET">>, [foobar])).

set_command_test() ->
  say_value:flush(),
  ?assertEqual(ok, say_command:run(<<"SET">>, [foobar, test])).

flushall_command_test() ->
  say_value:flush(),
  ?assertEqual(ok, say_command:run(<<"FLUSHALL">>, [])).
