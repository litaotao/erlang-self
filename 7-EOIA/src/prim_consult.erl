%%%
-module (prim_consult).
-export ([prim_consult/1]).

prim_consult(FullName) ->
	case erl_prim_loader:get_file(FullName) of
		{ok, Bin, _} ->
			case file_binary_to_list(Bin) of
				{ok, String} ->
					case erl_scan:string(String) of
						{ok, Tokens, _EndLine} ->
							prim_parse(Tokens, []);
						{error, Reason, _EndLine} ->
							{error, Reason}
					end;
				error ->
					error
			end;
		error ->
			{error, enoent}
	end.

prim_parse(Tokens, Acc) ->
	case lists:splitwith(fun(T) -> element(1,T) =/= dot end, Tokens) of
	{[], []} ->
		{ok, lists:reverse(Acc)};
	{Tokens2, [{dot, _} = Dot | Rest]} ->
		case erl_parse:parse_term(Tokens2 ++ [Dot]) of
			{ok, Term} ->
				prim_parse(Rest, [Term | Acc]);
			{error, _R} = Error ->
				Error
		end;
	{Tokens2, []} ->
		case erl_parse:parse_term(Tokens2) of
			{ok, Term} ->
				{ok, lists:reverse([Term | Acc])};
			{error, _R} = Error ->
				Error
			end
		end.

file_binary_to_list(Bin) ->
	Enc = case epp:read_encoding_from_binary(Bin) of
		none -> epp:default_encoding();
		Encoding -> Encoding
		end,
	case catch unicode:characters_to_list(Bin, Enc) of
		String when is_list(String) ->
			{ok, String};
		_ ->
			error
	end.