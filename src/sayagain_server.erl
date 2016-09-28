-module(sayagain_server).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, terminate/2, handle_info/2, code_change/3, stop/1]).

% public api

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

% state should be change with State that you will pass
init([]) ->
  {ok, state}.

stop(_Pid) ->
  stop().

stop() ->
  gen_server:cast(?MODULE, stop).

handle_call({method_name_and_params}, _From, State) ->
  Response = ok,
  {reply, Response, State};

handle_call(_Message, _From, State) ->
  {reply, error, State}.

handle_cast(_Message, State) -> {noreply, State}.
handle_info(_Message, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVersion, State, _Extra) -> {ok, State}.
