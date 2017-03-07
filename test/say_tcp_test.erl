-module(say_tcp_test).
-include_lib("eunit/include/eunit.hrl").

setup() ->
  application:set_env(sayagain, address, "127.0.0.1"),
  application:set_env(sayagain, port, 5000),
  process_flag(trap_exit, true),
  {ok, Pid} = say_sup:start_link(),
  Pid.

cleanup(Pid) ->
  application:unset_env(sayagain, address),
  application:unset_env(sayagain, port),
  exit(Pid, kill), %% brutal kill!
  ?assertEqual(false, is_process_alive(Pid)).

start_server_test() ->
  Pid = setup(),
  ?assertEqual(true, is_process_alive(Pid)),
  cleanup(Pid).

listen_test() ->
  Pid = setup(),
  cleanup(Pid).

request_test() ->
  Pid = setup(),
  {ok, Socket} = gen_tcp:connect({127,0,0,1}, 5000, [{active,false}]),
  ?assertEqual(ok, gen_tcp:close(Socket)),
  cleanup(Pid).

request_with_data_test() ->
  Pid = setup(),
  {ok, Socket} = gen_tcp:connect({127,0,0,1}, 5000, [{active,false}]),
  ?assertEqual(ok, say_value:write(<<"hello">>, <<"world">>)),
  ?assertEqual(ok, gen_tcp:send(Socket, "*2\r\n$3\r\nGET\r\n$5\r\nhello\r\n")),
  ?assertEqual({ok, "$5\r\nworld\r\n"}, gen_tcp:recv(Socket, 0)),
  ?assertEqual(ok, gen_tcp:close(Socket)),
  cleanup(Pid).

request_with_data_multiple_line_test() ->
  Pid = setup(),
  {ok, Socket} = gen_tcp:connect({127,0,0,1}, 5000, [{active,false}]),
  ?assertEqual(ok, say_value:write(<<"hello">>, <<"world">>)),
  ?assertEqual(ok, gen_tcp:send(Socket, "*2\r\n")),
  ?assertEqual(ok, gen_tcp:send(Socket, "$3\r\n")),
  ?assertEqual(ok, gen_tcp:send(Socket, "GET\r\n")),
  ?assertEqual(ok, gen_tcp:send(Socket, "$5\r\n")),
  ?assertEqual(ok, gen_tcp:send(Socket, "hello\r\n")),
  ?assertEqual({ok, "$5\r\nworld\r\n"}, gen_tcp:recv(Socket, 0)),
  ?assertEqual(ok, gen_tcp:close(Socket)),
  cleanup(Pid).
