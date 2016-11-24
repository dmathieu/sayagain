-module(say_command).
-behaviour(gen_server).

-export([start_link/0, run/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  {ok, {}}.

run(Cmd, Args) ->
  gen_server:call(?MODULE, {Cmd, Args}).

handle_call({Cmd, Args}, _From, State) ->
  {reply, execute(Cmd, Args), State}.

handle_cast(_Message, Tab) -> {noreply, Tab}.
handle_info(_Message, Tab) -> {noreply, Tab}.
terminate(_Reason, _Tab) -> ok.
code_change(_OldVersion, Tab, _Extra) -> {ok, Tab}.

execute(<<"GET">>, _Args) ->
  <<"Hello">>;
execute(<<"SET">>, _Args) ->
  ok;
execute(<<"FLUSHDB">>, _Args) ->
  ok;
execute(<<"COMMAND">>, _Args) ->
  [
    [<<"get">>, <<"1">>, [<<"readonly">>], <<"1">>, <<"1">>, <<"1">>],
    [<<"set">>, <<"2">>, [<<"write">>, <<"denyroom">>], <<"1">>, <<"1">>, <<"1">>],
    [<<"flushdb">>, <<"0">>, [<<"write">>, <<"denyroom">>], <<"1">>, <<"1">>, <<"1">>]
  ];
execute(Msg, _Args) ->
  {error, lists:concat(["unknown command '", erlang:binary_to_list(Msg), "'"])}.
