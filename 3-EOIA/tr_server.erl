%%%------------------------------------------
%%% @author Taotao.li <litaotao@vip.163.com>
%%% @copyright litaotao
%%% @doc RPC over TCP server. This module defines a server process
%%%		 that listens for incoming TCP connections and allows the user
%%%		 to execute RPC commands via that TCP stream.
%%% @end
%%%------------------------------------------

-module (tr_server).
-behaviour (gen_server).

%%API
-export ([]).
%%gen_server callbacks
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2,
		  terminate/2, code_change/3]).

-define (SERVER, ?MODULE).
-define (DEFAULT_PORT, 1055).

%% store the state of process
-record (state, {port, lsock, request_count=0}).


%%%==========================================
%%% API
%%%==========================================

%%------------------------------------------
%% @doc Starts the server.
%% 
%% @spec start_link(Port::integer()) -> {ok, Pid}
%% where
%% 	Pid = pid()
%% @end
%%------------------------------------------
start_link(Port) ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [Port], []).

%% @spec start_link() -> {ok, Pid}
%% @doc calls 'start_link(Port)' using the default port.
start_link() ->
	start_link(?DEFAULT_PORT).

%%-------------------------------------------
%% @doc Fetched the number of requests made to this server.
%% @spec get_count() -> {ok, Count}
%% where
%% 	Count = integer()
%% @end
%%-------------------------------------------
get_count() ->
	gen_server:call(?SERVER, get_count). %% synchronousl

%%-------------------------------------------
%% @doc Stops the server.
%% @spec stop() -> ok
%% @end.
%%-------------------------------------------
stop() ->
	gen_server:cast(?SERVER, stop).  	%% asynchronous

%%%------------------------------------------
%%% gen_server callbacks
%%%------------------------------------------
init([Port]) ->
	{ok, LSock} = gen_tcp:listen(Port, [{active, true}]),
	{ok, #state{Port=Port, lsock=LSock}, 0}.

handle_call(get_count, _From, State) ->
	{reply, {ok, State#state.request_count}, State}.

handle_cast(stop, State) ->
	{stop, normal, State}.	


