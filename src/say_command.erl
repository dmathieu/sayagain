-module(say_command).

-export([run/2]).

run(Cmd, Args) when is_atom(Cmd) ->
  execute(Cmd, Args);
run(Cmd, Args) ->
  run(list_to_atom(string:to_lower(binary_to_list(Cmd))), Args).

execute(get, [Key]) -> say_value:read(Key);
execute(set, [Key, Value]) -> say_value:write(Key, Value);
execute(flushall, _Args) -> say_value:flush();
execute(command, _Args) ->
  [
    [get, 1, [readonly], 1, 1, 1],
    [set, 2, [write, denyroom], 1, 1, 1],
    [flushall, 0, [write, denyroom], 1, 1, 1]
  ];
execute(Msg, _Args) ->
  {error, lists:concat(["unknown command '", Msg, "'"])}.
