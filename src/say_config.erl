-module(say_config).

-export([get_address/0, get_port/0]).

-define(DEFAULT_ADDRESS, "127.0.0.1").
-define(DEFAULT_PORT, 2504).

-spec get_address() -> inet:ip_address().
get_address() ->
  case application:get_env(sayagain, address) of
    {ok, Address} -> Address;
    _ -> ?DEFAULT_ADDRESS
  end.

-spec get_port() -> inet:port_number().
get_port() ->
  case application:get_env(sayagain, port) of
    {ok, Port} -> Port;
    _ -> ?DEFAULT_PORT
  end.
