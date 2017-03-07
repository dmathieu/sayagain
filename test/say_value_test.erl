-module(say_value_test).
-include_lib("eunit/include/eunit.hrl").

write_test() ->
  ?assertEqual(ok, say_value:write(foobar, test)).

read_test() ->
  say_value:write(hello, world),
  ?assertEqual(world, say_value:read(hello)).

unknown_value_read_test() ->
  ets:delete(value),
  ?assertEqual(nil, say_value:read(hello)).

flush_test() ->
  say_value:write(hello, world),
  ?assertEqual(ok, say_value:flush()),
  ?assertEqual(nil, say_value:read(hello)).
