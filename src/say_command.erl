-module(say_command).

-export([run/2]).

run(<<"GET">>, _Args) ->
  {ok, "Hello!"};
run(<<"SET">>, _Args) ->
  {ok, "OK"};
run(Msg, Args) ->
  {error, {unknown_command, Msg, Args}}.
