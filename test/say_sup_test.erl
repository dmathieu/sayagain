-module(say_sup_test).
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

start_sup_test() ->
  Pid = setup(),
  ?assertEqual(true, is_process_alive(Pid)),
  cleanup(Pid).
