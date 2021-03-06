-module (lib_trigrams).
-export ([for_each_trigram_in_the_english_language/2,
		  make_tables/0, timer_tests/0, is_word/2,
		  open/0, close/1, is_this_a_trigram/2,
		  how_many_trigrams/0]).
-import (list, [reverse/1]).

make_tables() ->
	{Micro1, N} = timer:tc(?MODULE, how_many_trigrams, []),
	io:format("count - No of trigrams = ~p, time/trigrams=~p~n", [N, Micro1/n]),
	{Micro2, Ntri} = timer:tc(?MODULE, make_ets_ordered_set, []),
	FileSize1 = filelib:file_size("trigrams0S.tab"),
	io:format("Ets ordered_sets size = ~p, time/trigram = ~p~n", [FileSize1/Ntri, Micro2/N]),
	{Micro3, _} = timer:tc(?MODULE, make_ets_set, []),
	FileSize2 = filelib:file_size("trigramS.tab"),
	io:format("Ets set size = ~p, time/trigram = ~p~n", [FileSize2/Ntri, Micro3/N]),
	{Micro4, _} = timer:tc(?MODULE, make_mod_set, []),
	FileSize3 = filelib:file_size("trigrams.set"),
	io:format("Module sets size = ~p, time/trigram = ~p~n", [FileSize3/Ntri, Micro4/N]).

make_ets_ordered_set() -> make_a_set(ordered_set, "trigrams0S.tab").
make_ets_set() -> make_a_set(set, "trigramsS.tab").

make_a_set(Type, FileName) ->
	Tab = ets:new(table, [Type]),
	F = fun(Str, _) -> ets:insert(Tab, {list_to_binary(Str)}) end,
	for_each_trigram_in_the_english_language(F, 0),
	ets:tab2file(Tab, FileName),
	Size = ets:info(Tab, size),
	ets:delete(Tab),
	Size.

make_mod_set() ->
	D = sets:new(),
	F = fun(Str, Set) -> sets:add_element(list_to_binary(Str), Set) end,
	D1 = for_each_trigram_in_the_english_language(F, D),
	file:write_file("trigrams.set", [term_to_binary(D1)]).

%%%
timer_tests() ->
	time_lookup_ets_set("Ets ordered set", "trigramsOS.tab"),
	time_lookup_ets_set("Ets set", "trigramsS.tab"),
	time_lookup_module_sets().

time_lookup_ets_set(Type, File) ->
	{ok, Tab} = ets:file2tab(File),
	L = ets:tab2list(Tab),
	Size = length(L),
	{M, _} = timer:tc(?MODULE, lookup_all_set, [Tab, L]),
	io:format("~s lookup=~p micro seconds~n", [Type, M/Size]),
	ets:delete(Tab).

time_lookup_module_sets()->
	{ok, Bin} = file:read_file("trigrams.set"),
	Set = binary_to_term(Bin),
	Keys = sets:to_list(Set),
	Size = length(Keys),
	{M, _} = timer:tc(?MODULE, lookup_all_set, [Set, Keys]),
	io:format("Module set lookup = ~p micro seconds~n", [M/Size]).

lookup_all_set(Set, L) ->
	lists:foreach(fun(Key) -> sets:is_element(Key, Set) end, L).

how_many_trigrams() ->
	F = fun(_, N) -> 1+N end,
	for_each_trigram_in_the_english_language(F, 0).

%%%
for_each_trigram_in_the_english_language(F, A0) ->
	{ok, Bin0} = file:read_file("words.ngl.gz"),
	Bin = zlib:gunzip(Bin0),
	scan_word_list(binary_to_list(Bin), F, A0).

scan_word_list([], _, A) ->
	A;

scan_word_list(L, F, A) ->
	{Word, L1} = get_next_word(L, []),
	A1 = scan_trigrams([$\s | Word], F, A),
	scan_word_list(L1, F, A1).

get_next_word([$\r,$\n | T], L) -> {reverse([$\s | L]), T};
get_next_word([H | T], L) -> get_next_word(T, [H|L]);
get_next_word([], L) -> {reverse([$\s | L]), []}.

scan_trigrams([X, Y, Z], F, A) ->
	F([X, Y, Z], A);

scan_trigrams([X, Y, Z|T], F, A) ->
	A1 = F([X, Y, Z], A),
	scan_trigrams([Y, Z|T], F, A1);

scan_trigrams(_, _, A) ->
	A.

%%%
is_word(Tab, Str) ->  is_word1(Tab, "\s"++Str++"\s").
is_word1(Tab, [_,_,_]=X) -> is_this_a_trigram(Tab, X);
is_word1(Tab, [A,B,C|D]) ->
	case is_this_a_trigram(Tab, [A,B,C]) of
		true -> is_word1(Tab, [B,C|D]);
		false -> false
	end;
is_word1(_, _) ->
	false.

is_this_a_trigram(Tab, X) ->	
	case ets:lookup(Tab, list_to_binary(X)) of
		[] -> false;
		_  -> true
	end.

open() -> 
	{ok, I} = ets:file2tab(filename:dirname(code:which(?MODULE))) ++ "/trigramsS.tab",
	I.

close(Tab) ->
	ets:delete(Tab).



