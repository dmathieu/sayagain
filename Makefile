clean:
	rebar3 clean

test: clean
	rebar3 eunit; rebar3 ct

run: clean
	rebar3 shell
