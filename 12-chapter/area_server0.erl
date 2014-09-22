-module (area_server0).
-export ([loop/0]).

loop() -> 
	receive
		{From, {rectangle, Width, Ht}} -> 
			From ! io:format("Area of rectangle is ~p~n", [Width*Ht]),
			loop();
		{From, {square, Side}} ->
			From ! io:format("Area of square is ~p~n", [Side*Side]),
			loop()
	end.