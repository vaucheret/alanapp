%% -*- mode: nitrogen -*-
-module (index).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-define(MSELECTED,"Home").
-define(TITLE,"Claudio App").

main() -> n_common:template().

title() -> ?TITLE.

access() ->
     public.

menu() ->
    n_menus:main_menu(?MSELECTED).

image() -> 
    "images/turingbombe.png".


home() ->
    SignedOut = (wf:user()==undefined),
    [
	#h1 {class="w3-jumbo", body="<b>Claudio Vaucheret</b>"},
	#p { text="Web Application" },
	#image { image=image(), class="w3-image w3-hide-large w3-hide-small w3-round", style="display:block;width:60%;margin:auto;" } ,
	#image { image=image(), class="w3-image w3-hide-large w3-hide-medium w3-round", width="1000", height="1333" } ,
	buttonslog(SignedOut)
    ].

buttonslog(SignedOut) ->
    #panel {id=buttons, body=[
	#button {class="w3-button w3-light-grey w3-padding-large w3-margin-top", body="<i class='fa fa-sign-in'></i> Login",postback=account,show_if=SignedOut},
	#button {class="w3-button w3-light-grey w3-padding-large w3-margin-top", body="<i class='fa fa-sign-out'></i> Logout",postback=account,show_if=not(SignedOut)}
    ]}.

event(account) ->
    wf:redirect_to_login("/login").

