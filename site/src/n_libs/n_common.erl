-module(n_common).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-define(PAGE,(wf:page_module())).
-define(TEMPLATE,"./site/templates/bare.html").

template() ->
    Access = get_access(),
    case can_access(Access) of
	true -> #template { file=?TEMPLATE };
	false -> wf:redirect_to_login("/login")
    end.

get_access() ->
    case erlang:function_exported(?PAGE, access, 0) of
	true ->
	    ?PAGE:access();
	false -> public
    end.

can_access(public) ->
    true;
can_access(private) ->
   wf:user()=/=undefined.
