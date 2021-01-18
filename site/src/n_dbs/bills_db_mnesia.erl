-module(bills_db_mnesia).
-record(bill, 
    {
	id = n_utils:create_id(),
	user_id,
        entity,
	date = qdate:unixtime(),
	description,
        link,
	amount
}).
-export(
    [
	init_table/0,
	put_record/1,
	get_all_values/1,
	get_all/0,
	get_record/1,
	delete/1,
        map_to_record/1,
	record_to_map/1,
	get_records_by_entity/2,
	get_records_by_date/3,
	search/3,
	id/1,
	user_id/1,
	entity/1,
        date/1,
	description/1,
        link/1,
	amount/1,
	id/2,
	user_id/2,
	entity/2,
        date/2,
	description/2,
        link/2,
	amount/2
]).

-include_lib("stdlib/include/qlc.hrl").

-define(TABLE, bill).

init_table() ->
    mnesia:create_table(?TABLE,
	[   {disc_copies, [node()] },
	    {attributes, 
		record_info(fields,?TABLE)}
    ]).

%% Copy and paste the following functions
put_record(Record) ->
    FormattedDate = qdate:to_string("Y-m-d", date(Record)),
    Record2 = date(Record,FormattedDate),
    Insert =
    fun() ->
	mnesia:write(Record2)
    end,
    {atomic, Results} = mnesia:transaction(Insert),
    Results.

get_all_values(Record) ->
    [_|Tail] = tuple_to_list(Record),
    Tail.
get_all() ->
    Query =
    fun() ->
	qlc:eval( qlc:q(
	    [ Record || Record <- mnesia:table(?TABLE) ]
	))
    end,
    {atomic, Results} = mnesia:transaction(Query),
    Results.

get_record(Key) ->
    Query =
       fun() ->
	mnesia:read({?TABLE, Key})
       end,
    {atomic,Results} = mnesia:transaction(Query),
    case length(Results) < 1 of
	true ->
	    [];
	false -> hd(Results)
    end.

delete(Key) ->
    Insert = 
    fun () ->
	    mnesia:delete({?TABLE, Key})
    end,
    {atomic, Results} = mnesia:transaction(Insert),
    Results.

map_to_record(Map) ->
    n_utils:map_to_record(#bill{}, record_info(fields, bill), Map).

record_to_map(Record) ->
    n_utils:record_to_map(Record, record_info(fields, bill)).

get_records_by_entity(UserID, Entity) ->
    Query =
    fun() ->
	qlc:eval( qlc:q(
	    [Record || Record <- mnesia:table(?TABLE),
	    Record#bill.id == UserID,
	    Record#bill.entity == Entity]
	))
    end,
    {atomic, Results} = mnesia:transaction(Query),
    Results.

get_records_by_date(UserID, Entity, Date) ->
    DateTime = qdate:to_date(Date),
    {FirstDate, LastDate} = n_dates:date_span(DateTime, 7),
    Query =
    fun() ->
	qlc:eval( qlc:q(
	    [Record || Record <- mnesia:table(?TABLE),
	    qdate:between(FirstDate, Record#bill.date, LastDate),
	    Record#bill.user_id == UserID,
	    Record#bill.entity == Entity
    ]))
    end,
    {atomic, Results} = mnesia:transaction(Query),
    Results.

search(_,_,undefined) -> [];
search(UserID, Entity, SearchList) ->
    Query =
    fun() ->
	qlc:eval( qlc:q(
	    [Record || Record <- mnesia:table(?TABLE),
	    Record#bill.user_id == UserID,
	    Record#bill.entity == Entity,
	    n_search:filter(SearchList, Record)]
	))
    end,
    {atomic, Results} = mnesia:transaction(Query),
    Results.


%% GETTERS
id(Record) -> Record#bill.id.
user_id(Record) -> Record#bill.user_id.
entity(Record) -> Record#bill.entity.
date(Record) -> Record#bill.date.
description(Record) -> Record#bill.description.
link(Record) -> Record#bill.link.
amount(Record) -> Record#bill.amount.

%% SETTERS
id(Record, ID) ->
    Record#bill{id=ID}.
user_id(Record, UserID) ->
    Record#bill{user_id=UserID}.
entity(Record, Entity) ->
    Record#bill{entity=Entity}.
date(Record, Date) ->
    Record#bill{date=Date}.
description(Record, Description) ->
    Record#bill{description=Description}.
link(Record, Link) ->
    Record#bill{link=Link}.
amount(Record, Amount) ->
    Record#bill{amount=Amount}.

