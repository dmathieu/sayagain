-module(say_tcp_server).
-behavior(gen_nb_server).

-export([start_link/0]).
-export([init/2, handle_call/3, handle_cast/2, handle_info/2]).
-export([terminate/2, sock_opts/0, new_connection/4]).

start_link() ->
    case gen_nb_server:start_link(?MODULE, []) of
      {ok, Pid} ->
        case gen_server:call(Pid, {add_listener, say_config:get_address(), say_config:get_port()}) of
          ok -> {ok, Pid};
          {error, Error} -> {error, add_listener, Error}
        end;
      {error, Error} -> {error, start_link, Error}
    end.

init([], State) ->
    {ok, State}.

handle_call({add_listener, IpAddr, Port}, _From, State) ->
    case gen_nb_server:add_listen_socket({IpAddr, Port}, State) of
        {ok, State1} ->
            {reply, ok, State1};
        Error ->
            {reply, Error, State}
    end;
handle_call({remove_listener, IpAddr, Port}, _From, State) ->
    case gen_nb_server:remove_listen_socket({IpAddr, Port}, State) of
        {ok, State1} ->
            {reply, ok, State1};
        Error ->
            {reply, Error, State}
    end;
handle_call(_Msg, _From, State) ->
    {reply, ignored, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({tcp, Sock, Data}, State) ->
    Me = self(),
    P = spawn(fun() -> worker(Me, Sock, Data) end),
    gen_tcp:controlling_process(Sock, P),
    {noreply, State};

handle_info(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

sock_opts() ->
    [binary, {active, once}, {packet, 0}].

new_connection(_IpAddr, _Port, Sock, State) ->
    Me = self(),
    P = spawn(fun() -> worker(Me, Sock) end),
    gen_tcp:controlling_process(Sock, P),
    {ok, State}.

worker(Owner, Sock) ->
    gen_tcp:send(Sock, "Hello\n"),
    inet:setopts(Sock, [{active, once}]),
    gen_tcp:controlling_process(Sock, Owner).

worker(Owner, Sock, Data) ->
    gen_tcp:send(Sock, Data),
    inet:setopts(Sock, [{active, once}]),
    gen_tcp:controlling_process(Sock, Owner).
