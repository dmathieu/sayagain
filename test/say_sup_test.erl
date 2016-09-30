-module(say_sup_test).
-include_lib("eunit/include/eunit.hrl").

setup() ->
  process_flag(trap_exit, true),
  {ok, Pid} = say_sup:start_link(),
  Pid.

cleanup(Pid) ->
  exit(Pid, kill), %% brutal kill!
  ?assertEqual(false, is_process_alive(Pid)).

start_sup_test() ->
  Pid = setup(),
  ?assertEqual(true, is_process_alive(Pid)),
  cleanup(Pid).
