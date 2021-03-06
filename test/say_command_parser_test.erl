-module(say_command_parser_test).
-include_lib("eunit/include/eunit.hrl").

to_redis_ok_test() ->
  ?assertEqual(<<"+OK\r\n">>, say_command_parser:to_redis(ok)).

to_redis_nil_test() ->
  ?assertEqual(<<"$-1\r\n">>, say_command_parser:to_redis(nil)).

to_redis_error_test() ->
  ?assertEqual(
     <<"-ERR unknown command 'foobar'\r\n">>,
     say_command_parser:to_redis({error, "unknown command 'foobar'"})).

to_redis_msg_test() ->
  ?assertEqual(<<"$5\r\nhello\r\n">>, say_command_parser:to_redis(<<"hello">>)).

to_redis_array_test() ->
  ?assertEqual(
     <<"*2\r\n$5\r\nhello\r\n$5\r\nworld\r\n">>,
     say_command_parser:to_redis([hello, world])).

to_redis_nested_array_test() ->
	?assertEqual(
		 <<"*3\r\n*6\r\n$3\r\nget\r\n$1\r\n1\r\n*1\r\n$8\r\nreadonly\r\n$1\r\n1\r\n$1\r\n1\r\n$1\r\n1\r\n*6\r\n$3\r\nset\r\n$1\r\n2\r\n*2\r\n$5\r\nwrite\r\n$8\r\ndenyroom\r\n$1\r\n1\r\n$1\r\n1\r\n$1\r\n1\r\n*6\r\n$8\r\nflushall\r\n$1\r\n0\r\n*2\r\n$5\r\nwrite\r\n$8\r\ndenyroom\r\n$1\r\n1\r\n$1\r\n1\r\n$1\r\n1\r\n">>,
		 say_command_parser:to_redis([
                                  [get, 1, [readonly], 1, 1, 1],
                                  [set, 2, [write, denyroom], 1, 1, 1],
                                  [flushall, 0, [write, denyroom], 1, 1, 1]
																 ])).

from_redis_ok_test() ->
  ?assertEqual(ok, say_command_parser:from_redis(<<"+OK\r\n">>)).

from_redis_nil_test() ->
  ?assertEqual(nil, say_command_parser:from_redis(<<"$-1\r\n">>)).

from_redis_msg_test() ->
  ?assertEqual([<<"Hello">>, <<"World">>], say_command_parser:from_redis(<<"$5\r\nHello\r\n$5\r\nWorld\r\n">>)).

from_redis_array_test() ->
  ?assertEqual(
     [[<<"GET">>, <<"foobar">>], [<<"SET">>, <<"foobar">>, <<"hello">>]],
     say_command_parser:from_redis(<<"*2\r\n$3\r\nGET\r\n$6\r\nfoobar\r\n*3\r\n$3\r\nSET\r\n$6\r\nfoobar\r\n$5\r\nhello">>)).
