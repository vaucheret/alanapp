%% -*- mode: nitrogen -*-
%% vim: ts=4 sw=4 et
-module(nitrogen_sup).
-behaviour(supervisor).
-export([
    start_link/0,
    init/1
]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    n_mnesia:one_time(),
    erlias:build(account_db_mnesia, account_api),
    erlias:build(bills_db_mnesia, bill_api),
    erlias:build(payments_db_mnesia, payment_api),
    application:load(nitrogen_core),
    application:start(nitro_cache),
    application:start(crypto),
    application:start(nprocreg),
    application:start(simple_bridge),
    application:ensure_all_started(erlpass),
    {ok, { {one_for_one, 5, 10}, []} }.
