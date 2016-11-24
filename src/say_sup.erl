%%%-------------------------------------------------------------------
%% @doc say top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(say_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
  {ok, { {one_for_one, 0, 1},
         [
          {say_value, {say_value, start_link, []}, permanent, 2000, worker, [say_value]},
          {say_command, {say_command, start_link, []}, permanent, 2000, worker, [say_command]},
          {say_tcp_sup, {say_tcp_sup, start_link, []}, permanent, 2000, supervisor, [say_tcp_sup]}
         ]
       } }.
