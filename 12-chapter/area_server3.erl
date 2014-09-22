-module (area_server3).
-export ([loop/0, area/2, start/0]).


start() -> spawn(area_server3, loop, []).

area(Pid, What) -> rpc(Pid, What).

rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive
		{Pid, Response} -> Response
	end.

loop() -> 
	receive
		{From, {rectangle, Width, Ht}} -> 
			% From ! io:format("Area of rectangle is ~p~n", [Width*Ht]),
			From ! {self(), Width*Ht},
			loop();
		{From, {circle, R}} ->
			% From ! io:format("Area of cicle is ~p~n", [3.14159*R*R]),
			From ! {self(), 3.14159*R*R},
			loop();
		{From, {square, Side}} ->
			% From ! io:format("Area of square is ~p~n", [Side*Side]),
			From ! {self(), Side*Side},
			loop();
		{From, Other} ->
			From ! {self(), {error, Other}},
			loop()
	end.