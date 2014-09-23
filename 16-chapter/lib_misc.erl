-module (lib_misc).
-export ([consult/1, consult_1/1, consult_lib/1]).

consult(File) -> 
	case file:open(File, read) of
		{ok, S} ->
			Val = consult_1(S),
			file:close(S),
			{ok, Val};
		{error, Why} ->
			{error, Why}
	end.

consult_1(S) ->
	case io:read(S, '') of
		{ok, Term} -> [Term | consult_1(S)];
		eof -> [];
		Error -> Error
	end.

%lib
consult_lib(File) ->
    case file:open(File, [read]) of
        {ok, Fd} ->
            R = consult_stream(Fd),
            _ = file:close(Fd),
            R;
        Error ->
            Error
    end.

consult_stream(Fd) ->
    _ = epp:set_encoding(Fd),
    consult_stream(Fd, 1, []).

consult_stream(Fd, Line, Acc) ->
    case io:read(Fd, '', Line) of
        {ok,Term,EndLine} ->
            consult_stream(Fd, EndLine, [Term|Acc]);
        {error,Error,_Line} ->
            {error,Error};
        {eof,_Line} ->
            {ok,lists:reverse(Acc)}
    end.

% -spec close(IoDevice) -> ok | {error, Reason} when
%       IoDevice :: io_device(),
%       Reason :: posix() | badarg | terminated.

% close(File) when is_pid(File) ->
%     case file_request(File, close) of
%         {error, terminated} ->
%             ok;
%         Other ->
%             Other
%     end;
