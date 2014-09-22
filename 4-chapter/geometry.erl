-module (geometry).
-export ([area/1, test/0]).

test() -> 
	12 = area({rectangle, 3, 4}),
	144 = area({square, 12}),
	tests_succeed.

area({rectangle, Width, Height}) -> Width * Height;
area({square, Side}) -> Side * Side.
