-module(n_menus).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").

%%%%%%%%%%%%%%%
%% Main Menu %%
%%%%%%%%%%%%%%%
menulist() ->
    [
	{"Home","/"},
	{"Pay the bills",cuentas},
	{"Account",account}
    ].

main_menu(Selected) ->
  [ displaymenu(X,Selected) || X <- menulist() ].

displaymenu({Name,Link},Selected) ->
    #link {postback=Link,text=Name, class=["w3-bar-item w3-button w3-hover-black ",classselected(Name,Selected)], click="closeNav();",delegate=?MODULE }.

classselected(Text,Selected) ->
    case Text == Selected of
	true ->
	    "w3-text-red";
	false -> 
	    "w3-text-grey"
    end.


event(account) ->
    wf:redirect_to_login("/login");
event(URL) ->
    wf:redirect(URL).
