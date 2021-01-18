-module(payments_db_mnesia).
-record(payment, 
    {
	id = n_utils:create_id(),
	user_id,
        bill_id,
        date,
	paydate,
	amount,
        boletapdf
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
	get_records_by_bill_id/2,
	get_records_by_date/3,
	search/3,
	id/1,
	user_id/1,
	bill_id/1,
	date/1,
	paydate/1,
	amount/1,
        boletapdf/1,
	id/2,
	user_id/2,
	bill_id/2,
	date/2,
	paydate/2,
	amount/2,
        boletapdf/2
]).

-include_lib("stdlib/include/qlc.hrl").

-define(TABLE, payment).

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
    n_utils:map_to_record(#payment{}, record_info(fields, payment), Map).

record_to_map(Record) ->
    n_utils:record_to_map(Record, record_info(fields, payment)).

get_records_by_bill_id(UserID, Bill_id) ->
    Query =
    fun() ->
	qlc:eval( qlc:q(
	    [Record || Record <- mnesia:table(?TABLE),
	    Record#payment.id == UserID,
	    Record#payment.bill_id == Bill_id]
	))
    end,
    {atomic, Results} = mnesia:transaction(Query),
    Results.

get_records_by_date(UserID, Bill_id, Date) ->
    DateTime = qdate:to_date(Date),
    {FirstDate, LastDate} = n_dates:date_span(DateTime, 7),
    Query =
    fun() ->
	qlc:eval( qlc:q(
	    [Record || Record <- mnesia:table(?TABLE),
	    qdate:between(FirstDate, Record#payment.date, LastDate),
	    Record#payment.user_id == UserID,
	    Record#payment.bill_id == Bill_id
    ]))
    end,
    {atomic, Results} = mnesia:transaction(Query),
    Results.

search(_,_,undefined) -> [];
search(UserID, Bill_id, SearchList) ->
    Query =
    fun() ->
	qlc:eval( qlc:q(
	    [Record || Record <- mnesia:table(?TABLE),
	    Record#payment.user_id == UserID,
	    Record#payment.bill_id == Bill_id,
	    n_search:filter(SearchList, Record)]
	))
    end,
    {atomic, Results} = mnesia:transaction(Query),
    Results.


%% GETTERS
id(Record) -> Record#payment.id.
user_id(Record) -> Record#payment.user_id.
bill_id(Record) -> Record#payment.bill_id.
date(Record) -> Record#payment.date.
paydate(Record) -> Record#payment.paydate.
amount(Record) -> Record#payment.amount.
boletapdf(Record) -> Record#payment.boletapdf.

%% SETTERS
id(Record, ID) ->
    Record#payment{id=ID}.
user_id(Record, UserID) ->
    Record#payment{user_id=UserID}.
bill_id(Record, BillID) ->
    Record#payment{bill_id=BillID}.
date(Record, Date) ->
    Record#payment{date=Date}.
paydate(Record, Paydate) ->
    Record#payment{paydate=Paydate}.
amount(Record, Amount) ->
    Record#payment{amount=Amount}.
boletapdf(Record, Boletapdf) ->
    Record#payment{boletapdf=Boletapdf}.

