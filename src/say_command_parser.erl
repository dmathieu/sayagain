-module(say_command_parser).

-export([to_redis/1, from_redis/1]).

%% Parse a string to be sent to redis
to_redis(ok) ->
  <<"+OK\r\n">>;
to_redis({error, Msg}) ->
  list_to_binary(["-ERR ", Msg, "\r\n"]);
to_redis([]) ->
  <<"">>;
to_redis([F|R]) when is_integer(F)->
  list_to_binary([string_header([F|R]), [F|R], "\r\n"]);
to_redis([Msg|Others]) ->
  list_to_binary([array_header([Msg|Others]), to_redis(Msg), to_redis(Others, [{array_header, false}])]).

to_redis([], _Options) ->
  <<"">>;
to_redis([Msg|Others], Options) ->
  case lists:keyfind(array_header, 1, Options) of
    false -> to_redis([Msg|Others]);
    {array_header, true} -> to_redis([Msg|Others]);
    {array_header, false} -> list_to_binary([to_redis(Msg), to_redis(Others, Options)])
  end.

string_header(Data) ->
  list_to_binary(["$", integer_to_list(length(Data)), "\r\n"]).
array_header(Data) ->
  list_to_binary(["*", integer_to_list(length(Data)), "\r\n"]).

%% Parse redis data to a string
from_redis(<<"+OK\r\n">>) -> ok;
from_redis(Msg) ->
  SplittedMsg = binary:split(Msg, [<<"\r\n">>], [global,trim]),
  parse_from_redis(SplittedMsg).

parse_from_redis([<<"$", _/binary>>, Msg | []]) ->
  SplittedMsg = binary:split(Msg, [<<" ">>], [global,trim]),
  parse_from_redis(SplittedMsg);
parse_from_redis([<<"$", _/binary>>, Msg | Others]) ->
  SplittedMsg = binary:split(Msg, [<<" ">>], [global,trim]),
  [parse_from_redis(SplittedMsg), parse_from_redis(Others)];
parse_from_redis([<<"*", _/binary>> | Msg]) ->
  parse_from_redis(Msg);
parse_from_redis(Msg) ->
  Msg.
