-module(say_tcp_server_test).
-include_lib("eunit/include/eunit.hrl").

setup() ->
  process_flag(trap_exit, true),
  {ok, Pid} = say_tcp_server:start_link(),
  Pid.

cleanup(Pid) ->
  exit(Pid, kill), %% brutal kill!
  ?assertEqual(false, is_process_alive(Pid)).

start_server_test() ->
  Pid = setup(),
  ?assertEqual(true, is_process_alive(Pid)),
  cleanup(Pid).

listen_test() ->
  Pid = setup(),
  ?assertEqual(ok, say_tcp_server:add_listener(Pid, "127.0.0.1", 5000)),
  ?assertEqual(ok, say_tcp_server:remove_listener(Pid, "127.0.0.1", 5000)),
  cleanup(Pid).

request_test() ->
  Pid = setup(),
  say_tcp_server:add_listener(Pid, "127.0.0.1", 5000),
  {ok, Socket} = gen_tcp:connect({127,0,0,1}, 5000, [{active,false}]),
  ?assertEqual({ok, "Hello\n"}, gen_tcp:recv(Socket, 0)),
  ?assertEqual(ok, gen_tcp:close(Socket)),
  cleanup(Pid).

request_with_data_test() ->
  Pid = setup(),
  say_tcp_server:add_listener(Pid, "127.0.0.1", 5000),
  {ok, Socket} = gen_tcp:connect({127,0,0,1}, 5000, [{active,false}]),
  gen_tcp:recv(Socket, 0),
  ?assertEqual(ok, gen_tcp:send(Socket, "Hello World!")),
  ?assertEqual({ok, "Hello World!"}, gen_tcp:recv(Socket, 0)),
  ?assertEqual(ok, gen_tcp:close(Socket)),
  cleanup(Pid).
