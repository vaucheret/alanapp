%% -*- mode: nitrogen -*-
-module (login).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-define(MSELECTED,"Account").
-define(TITLE,"Claudio App").

main() -> n_common:template().

title() -> ?TITLE.

access() ->
     public.

menu() ->
    n_menus:main_menu(?MSELECTED).

image() -> 
    "images/candado.jpg".

logged_in_msg(undefined) ->
    "Not Logged In";
logged_in_msg(Username) ->
    ["Logged In as ",Username].

home() ->
    SignedOut = (wf:user()==undefined),
    Username = wf:session(username),
    [
	#flash {},
	#h1 {class="w3-jumbo", body="<b>Login</b>"},
	#p {id=loggedmsg, text=logged_in_msg(Username) },
	#image { image=image(), class="w3-image w3-hide-large w3-hide-small w3-round", style="display:block;width:60%;margin:auto;" } ,
	#image { image=image(), class="w3-image w3-hide-large w3-hide-medium w3-round", width="1000", height="1333" } ,
	buttonslog(SignedOut),
	new_account_form(),
	signin_form()
    ].

buttonslog(SignedOut) ->
    #panel {id=buttons, body=[
    	#button {class="w3-button w3-light-grey w3-padding-large w3-margin-top", body="<i class='fa fa-sign-in'></i> Sign-In",show_if=SignedOut,actions=#event {type=click ,target=signinpanel, actions=#show {}}},
	#button {class="w3-button w3-light-grey w3-padding-large w3-margin-top", body="<i class='fa fa-sign-out'></i> Log Out",show_if=not(SignedOut),postback=logout},
	#br {},
	#button {class="w3-button w3-light-grey w3-padding-large w3-margin-top", body="<i class='fa fa-address-card'></i> Create Account",show_if=SignedOut,actions=#event {type=click ,target=createaccpanel, actions=#show {}}}
    ]}.



signin_form() ->
    wf:defer(signin,usernamesign,#validate{validators=[
	#is_required{text="Username Required"}]}),
    wf:defer(signin,passwordsign,#validate{validators=[
	#is_required{text="Password Required"}]}),
    #panel {class="w3-modal", id=signinpanel, body =[
	#panel {class="w3-modal-content w3-animate-zoom w3-card-4 w3-left-align", body=[
	    #panel {class="w3-container w3-black", body=[
		#span {class="w3-button w3-display-topright", 
		    body ="<i class='fa fa-remove'></i>", 
		    actions=#event {type=click, target=signinpanel, actions=#hide {}}},
		#h2 {text="Sign In" }
	    ]},
	    #panel {class="w3-container", body=[
		#label{class="w3-label",text="Username"},
		#textbox{class="w3-input",id=usernamesign,placeholder="Your Username"},
		#label{class="w3-label",text="Password"},
		#textbox{class="w3-input",id=passwordsign,type=password},
		#br{},
		#button{class="w3-btn w3-blue",id=signin,text="Sign In", postback=signin}
	    ]}
	]}
    ]}.


new_account_form() ->
    wf:defer(save,username,#validate{validators=[
	#is_required{text="Username Required"}]}),
    wf:defer(save,email,#validate{validators=[
	#is_required{text="Email Required"}]}),
    wf:defer(save,password,#validate{validators=[
	#is_required{text="Password Required"}]}),
    wf:defer(save,password2,#validate{validators=[
     	#confirm_same{text="Password do not match",confirm_id=password}]}),
    #panel {class="w3-modal", id=createaccpanel, body =[
	#panel {class="w3-modal-content w3-animate-zoom w3-card-4 w3-left-align", body=[
	    #panel {class="w3-container w3-black", body=[
		#span {class="w3-button w3-display-topright", 
		    body ="<i class='fa fa-remove'></i>", 
		    actions=#event {type=click, target=createaccpanel, actions=#hide {}}},
		#h2 {text="Create Account" }
	    ]},
	    #panel {class="w3-container", body=[
		#label{class="w3-label",text="Username"},
		#textbox{class="w3-input",id=username,placeholder="Your Username"},
		#label{class="w3-label",text="Email"},
		#textbox{class="w3-input",id=email,type=email,placeholder="your@email.com"},
		#label{class="w3-label",text="Password"},
		#textbox{class="w3-input",id=password,type=password},
		#label{class="w3-label",text="Confirm Password"},
		#textbox{class="w3-input",id=password2,type=password},
		#br{},
		#button{class="w3-btn w3-blue",id=save,text="Save Account", postback=save}
	    ]}
	]}
    ]}.

event(logout) -> 
    wf:logout(),
    wf:update(loggedmsg,logged_in_msg(undefined)),
    wf:update(buttons,buttonslog(true));
event(save) ->
    [Username,Email,Password] = wf:mq([username,email,password]),
    Record = account_api:new_account(Username, Email, Password),
    UserID = account_api:id(Record),
    wf:user(UserID),
    wf:session(username,Username),
    wf:wire(createaccpanel, #hide {} ),
    wf:redirect_from_login("/");
event(signin) ->
    wf:wire(signinpanel, #hide {} ),
    [Username,Password] = wf:mq([usernamesign,passwordsign]),
    case account_api:attempt_login(Username, Password) of
	undefined ->
	    wf:flash("No Matching Username or Password. Please Try Again");
	Record ->
	    UserID = account_api:id(Record),
	    wf:user(UserID),
	    wf:session(username,Username),
	    wf:redirect_from_login("/")
    end.

