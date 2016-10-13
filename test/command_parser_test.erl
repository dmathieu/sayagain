-module(command_parser_test).
-include_lib("eunit/include/eunit.hrl").

to_redis_ok_test() ->
  ?assertEqual(<<"+OK\r\n">>, command_parser:to_redis(ok)).

to_redis_error_test() ->
  ?assertEqual(
     <<"-ERR unknown command 'foobar'\r\n">>,
     command_parser:to_redis({error, "unknown command 'foobar'"})).

to_redis_msg_test() ->
  ?assertEqual(<<"$5\r\nHello\r\n">>, command_parser:to_redis("Hello")).

to_redis_array_test() ->
  ?assertEqual(
     <<"*2\r\n$5\r\nHello\r\n$5\r\nWorld\r\n">>,
     command_parser:to_redis(["Hello", "World"])).

from_redis_ok_test() ->
  ?assertEqual(ok, command_parser:from_redis(<<"+OK\r\n">>)).

from_redis_msg_test() ->
  ?assertEqual([<<"Hello">>, <<"World">>], command_parser:from_redis(<<"$11\r\nHello World\r\n">>)).

from_redis_array_test() ->
  ?assertEqual(
     [[<<"Hello">>, <<"World">>], [<<"Bonjour">>, <<"Monde">>]],
     command_parser:from_redis(<<"*2\r\n$5\r\nHello World\r\n$5\r\nBonjour Monde\r\n">>)).
