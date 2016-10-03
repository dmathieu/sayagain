setup:
	cp -n sayagain.config.sample sayagain.config; echo ""

clean:
	rebar3 clean

test: setup clean
	rebar3 eunit; rebar3 ct

run: setup clean
	rebar3 shell
