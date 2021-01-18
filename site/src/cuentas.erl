%% -*- mode: nitrogen -*-
-module (cuentas).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-define(MSELECTED,"Pay the bills").
-define(TITLE,"Claudio's App").

main() -> n_common:template().

title() -> ?TITLE.

access() ->
     private.

menu() ->
    n_menus:main_menu(?MSELECTED).

image() -> 
    "images/cuentas.png".


home() ->
    [
	#h1 {class="w3-jumbo", body="<b>Claudio Vaucheret</b>"},
	#p { text="Bills Payable" },
	#image { image=image(), class="w3-image w3-hide-large w3-hide-small w3-round", style="display:block;width:60%;margin:auto;" } ,
	#image { image=image(), class="w3-image w3-hide-large w3-hide-medium w3-round", width="1000", height="1333" } 
    ].

