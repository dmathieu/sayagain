-module(say_command_parser).

-export([to_redis/1, from_redis/1]).

%% Parse a string to be sent to redis
to_redis(ok) -> <<"+OK\r\n">>;
to_redis({error, Msg}) -> list_to_binary(["-ERR ", Msg, "\r\n"]);
to_redis([]) -> <<"">>;
to_redis(Msg) -> parse_to_redis(Msg).


parse_to_redis(Msg) -> list_to_binary(format_entry(Msg)).

parse_to_redis([], Data) -> Data;
parse_to_redis([H|T], Data) -> parse_to_redis(T, [Data, format_entry(H)]);
parse_to_redis(E, Data) -> list_to_binary([Data, format_entry(E)]).

format_entry(E) when is_list(E)->
  [
    <<"*">>,
    entry_length(E),
    <<"\r\n">>,
    parse_to_redis(E, [])
  ];
format_entry(E)->
	[
		<<"$">>,
    entry_length(E),
		<<"\r\n">>,
    entry_value(E),
		<<"\r\n">>
	].

entry_value(E) when is_atom(E) -> atom_to_binary(E, utf8);
entry_value(E) when is_integer(E) -> integer_to_binary(E);
entry_value(E) when is_list(E) -> list_to_binary(E);
entry_value(E) when is_binary(E) -> E.

entry_length(E) when is_atom(E) -> entry_length(atom_to_list(E));
entry_length(E) when is_binary(E) -> entry_length(binary_to_list(E));
entry_length(E) when is_integer(E) -> <<"1">>;
entry_length(E) when is_list(E) -> integer_to_binary(length(E)).

%% Parse redis array to a string
from_redis(<<"+OK\r\n">>) -> ok;
from_redis(Msg) ->
  SplittedMsg = binary:split(Msg, [<<"\r\n">>], [global,trim]),
  parse_from_redis(SplittedMsg).

parse_from_redis(Data) -> parse_from_redis(Data, []).
parse_from_redis([], Data) -> Data;
parse_from_redis([<<"$", _/binary>>|T], Data) -> parse_from_redis(T, Data);
parse_from_redis([<<"*", I/binary>>|T], Data) ->
  [Msg, E] = unnest_array(T, list_to_integer(binary_to_list(I))),
  Entry = parse_from_redis(E),
  case length(Data) of
    0 -> parse_from_redis(Msg, Entry);
    _ -> parse_from_redis(Msg, [Data, Entry])
  end;
parse_from_redis([H|T], Data) ->
  Entry = split_entry(H),
  parse_from_redis(T, lists:append(Data, Entry)).

split_entry(E) -> binary:split(E, [<<" ">>], [global,trim]).

unnest_array(Msg, I) -> unnest_array(Msg, [], I).
unnest_array(Msg, Array, 0) -> [Msg, lists:reverse(Array)];
unnest_array([], Array, _) -> unnest_array([], Array, 0);
unnest_array([H|T], Array, I) ->
  case H of
    <<"$", _/binary>> -> unnest_array(T, [H|Array], I);
    _ -> unnest_array(T, [H|Array], I-1)
  end.
