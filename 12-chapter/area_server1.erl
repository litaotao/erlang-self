-module (area_server1).
-export ([loop/0, rpc/2]).


rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive
		Response -> Response
	end.


loop() -> 
	receive
		{From, {rectangle, Width, Ht}} -> 
			% From ! io:format("Area of rectangle is ~p~n", [Width*Ht]),
			From ! Width*Ht,
			loop();
		{From, {cicle, R}} ->
			% From ! io:format("Area of cicle is ~p~n", [3.14159*R*R]),
			From ! 3.14159*R*R,
			loop;
		{From, {square, Side}} ->
			% From ! io:format("Area of square is ~p~n", [Side*Side]),
			From ! Side*Side,
			loop();
		{From, Other} ->
			From ! {error, Other},
			loop()
	end.