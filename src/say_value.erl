-module(say_value).

-export([read/1, write/2, flush/0]).

flush() ->
  setup(),
  ets:delete(value),
  ok.

write(Key, Value) ->
  setup(),
  ets:insert(value, {Key, Value}),
  ok.

read(Key) ->
  setup(),
  Reply = case ets:lookup(value, Key) of
            [{Key, Value}] ->
              Value;
            [] ->
              nil
          end,
  Reply.

setup() ->
  case ets:info(value) of
    undefined -> ets:new(value, [set, named_table]);
    _ -> nil
  end.
