-module(say_command_parser_test).
-include_lib("eunit/include/eunit.hrl").

to_redis_ok_test() ->
  ?assertEqual(<<"+OK\r\n">>, say_command_parser:to_redis(ok)).

to_redis_error_test() ->
  ?assertEqual(
     <<"-ERR unknown command 'foobar'\r\n">>,
     say_command_parser:to_redis({error, "unknown command 'foobar'"})).

to_redis_msg_test() ->
  ?assertEqual(<<"$5\r\nHello\r\n">>, say_command_parser:to_redis("Hello")).

to_redis_array_test() ->
  ?assertEqual(
     <<"*2\r\n$5\r\nHello\r\n$5\r\nWorld\r\n">>,
     say_command_parser:to_redis(["Hello", "World"])).

from_redis_ok_test() ->
  ?assertEqual(ok, say_command_parser:from_redis(<<"+OK\r\n">>)).

from_redis_msg_test() ->
  ?assertEqual([<<"Hello">>, <<"World">>], say_command_parser:from_redis(<<"$5\r\nHello\r\n$5\r\nWorld\r\n">>)).

from_redis_array_test() ->
  ?assertEqual(
     [[<<"GET">>, <<"foobar">>], [<<"SET">>, <<"foobar">>, <<"hello">>]],
     say_command_parser:from_redis(<<"*2\r\n$3\r\nGET\r\n$6\r\nfoobar\r\n*3\r\n$3\r\nSET\r\n$6\r\nfoobar\r\n$5\r\nhello">>)).
