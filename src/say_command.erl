-module(say_command).

-export([run/2]).

run(<<"GET">>, _Args) ->
  "Hello";
run(<<"SET">>, _Args) ->
  ok;
run(<<"FLUSHDB">>, _Args) ->
  ok;
run(<<"COMMAND">>, _Args) ->
  ["GET", "SET", "FLUSHDB"];
run(Msg, _Args) ->
  {error, lists:concat(["unknown command '", erlang:binary_to_list(Msg), "'"])}.
