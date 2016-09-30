-module(say_config_test).
-include_lib("eunit/include/eunit.hrl").

get_address_test() ->
  ?assertEqual("127.0.0.1", say_config:get_address()),
  application:set_env(sayagain, address, "localhost"),
  ?assertEqual("localhost", say_config:get_address()),
  application:unset_env(sayagain, address).

get_port_test() ->
  ?assertEqual(2504, say_config:get_port()),
  application:set_env(sayagain, port, 6379),
  ?assertEqual(6379, say_config:get_port()),
  application:unset_env(sayagain, port).
