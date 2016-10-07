-module(say_tcp_sup).
-behaviour(supervisor).

-export([start_link/0, start_socket/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  lager:debug("Starting TCP server on port ~p", [say_config:get_port()]),
  {ok, ListenSocket} = gen_tcp:listen(say_config:get_port(), [{active,once}]),
  spawn_link(fun empty_listeners/0),
  {ok, { {simple_one_for_one, 60, 3600},
         [
          {say_tcp_server, {say_tcp_server, start_link, [ListenSocket]}, temporary, 1000, worker, [say_tcp_server]}
         ]
       } }.

start_socket() ->
  supervisor:start_child(?MODULE, []).

%% Start with 20 listeners so that many multiple connections can
%% be started at once, without serialization. In best circumstances,
%% a process would keep the count active at all times to insure nothing
%% bad happens over time when processes get killed too much.
empty_listeners() ->
  [start_socket() || _ <- lists:seq(1,20)],
  ok.
