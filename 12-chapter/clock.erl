-module (clock).
-export ([start/2, stop/0]).

start(Time, Fun) -> 
	register(clock, spawn(fun() -> timer(Time, Fun) end)).

stop() -> 
	% clock ! cancel.
	clock ! stop.

timer(Time, Fun) ->
	receive
		stop -> void
	after Time ->
		Fun(),
		timer(Time, Fun)
	end.
