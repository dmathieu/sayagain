-module(say_value).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, terminate/2, handle_info/2, code_change/3, stop/1]).

% public api

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  Tab = ets:new(?MODULE, []),
  {ok, Tab}.

stop(_Pid) ->
  stop().

stop() ->
  gen_server:cast(?MODULE, stop).

handle_call({write, Key, Value}, _From, Tab) ->
  ets:insert(Tab, {Key, Value}),
  {reply, ok, Tab};
handle_call({read, Key}, _From, Tab) ->
  Reply = case ets:lookup(Tab, Key) of
            [{Key, Value}] ->
             {ok, Value};
            [] ->
              {error, unknown_key}
          end,
  {reply, Reply, Tab};
handle_call(_Message, _From, Tab) ->
  {reply, {error, unknown_command}, Tab}.

handle_cast(_Message, Tab) -> {noreply, Tab}.
handle_info(_Message, Tab) -> {noreply, Tab}.
terminate(_Reason, _Tab) -> ok.
code_change(_OldVersion, Tab, _Extra) -> {ok, Tab}.
