-module(say_command).
-behaviour(gen_server).

-export([start_link/0, run/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  {ok, {}}.

run(Cmd, Args) ->
  AtomCmd = list_to_atom(string:to_lower(binary_to_list(Cmd))),
  gen_server:call(?MODULE, {AtomCmd, Args}).

handle_call({Cmd, Args}, _From, State) ->
  {reply, execute(Cmd, Args), State};
handle_call(Param, _From, State) ->
  {reply,
   {error, "unknown command '", erlang:binary_to_list(Param), "'"},
   State}.

handle_cast(_Message, Tab) -> {noreply, Tab}.
handle_info(_Message, Tab) -> {noreply, Tab}.
terminate(_Reason, _Tab) -> ok.
code_change(_OldVersion, Tab, _Extra) -> {ok, Tab}.

execute(get, Args) -> say_value:run(read, Args);
execute(set, Args) -> say_value:run(write, Args);
execute(flushall, _Args) -> say_value:run(flush, []);
execute(command, _Args) ->
  [
    [get, 1, [readonly], 1, 1, 1],
    [set, 2, [write, denyroom], 1, 1, 1],
    [flushall, 0, [write, denyroom], 1, 1, 1]
  ];
execute(Msg, _Args) ->
  {error, lists:concat(["unknown command '", Msg, "'"])}.
