-module(say_command).

-export([run/2]).

run(<<"GET">>, _Args) ->
  <<"Hello">>;
run(<<"SET">>, _Args) ->
  ok;
run(<<"FLUSHDB">>, _Args) ->
  ok;
run(<<"COMMAND">>, _Args) ->
	[
	 	[<<"get">>, <<"1">>, [<<"readonly">>], <<"1">>, <<"1">>, <<"1">>],
	 	[<<"set">>, <<"2">>, [<<"write">>, <<"denyroom">>], <<"1">>, <<"1">>, <<"1">>],
	 	[<<"flushdb">>, <<"0">>, [<<"write">>, <<"denyroom">>], <<"1">>, <<"1">>, <<"1">>]
	];
run(Msg, _Args) ->
  {error, lists:concat(["unknown command '", erlang:binary_to_list(Msg), "'"])}.
