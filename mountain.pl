% Facts

% Dynamic predicates for game state
:- dynamic(location/1).
:- dynamic(status/1).
:- dynamic(supplies/1).
:- dynamic(miku_status/1).
:- dynamic(teto_status/1).
:- dynamic(altitude_level/1).
:- dynamic(hp/2).

% Starting state
location(base_camp).
status(alive).
supplies(5).
miku_status(ok).
teto_status(ok).
altitude_level(1).

% Health points
hp(mori, 100).
hp(miku, 100).
hp(teto, 100).

% Check if player is alive
alive(Name) :-
    hp(Name, HP),
    HP > 0.

% Rules

start :-
    nl,
    write('   ___  ___                  _        _                __  ______           _   _     '), nl,
    write('   |  \\/  |                 | |      (_)              / _| |  _  \\         | | | |    '), nl,
    write('   | .  . | ___  _   _ _ __ | |_ __ _ _ _ __     ___ | |_  | | | |___  __ _| |_| |__  '), nl,
    write('   | |\\/| |/ _ \\| | | | \'_ \\| __/ _` | | \'_ \\   / _ \\|  _| | | | / _ \\/ _` | __| \'_ \\ '), nl,
    write('   | |  | | (_) | |_| | | | | || (_| | | | | | | (_) | |   | |/ /  __/ (_| | |_| | | |'), nl,
    write('   \\_|  |_/\\___/ \\__,_|_| |_|\\__\\__,_|_|_| |_|  \\___/|_|   |___/ \\___|\\__,_|\\__|_| |_|'), nl,
    nl,
    write('You are Mori, a determined climber.'), nl,
    write('You are trying to climb the mountain of death.'), nl,
    nl,
    write('Your team members are:'), nl,
    write('  - Teto: Experienced Navigator'), nl,
    write('  - Miku: Well Trained Medic & Survival Expert'), nl,
    game_loop.

game_loop :-
    nl,
    write('Type "help." for a list of commands.'), nl,
    write('What do you want to do: '),
    read(Input),
    handle_input(Input).

% Handle Input

handle_input(help) :-
    nl,
    write('Available Commands:'), nl,
    write('  climb              - Climb higher on the mountain'), nl,
    write('  status             - Show your current status'), nl,
    write('  use_supplies(Name) - Ask Miku to Use supplies on "mori", "miku", or "teto" to heal them for 25HP'), nl,
    write('  show_map           - Ask Teto where you are and see the map'), nl,
    write('  portrait(Name)     - Show a portrait of "mori", "miku", or "teto"'), nl,
    write('  help               - Show these commands again'), nl,
    write('  quit               - End game'), nl,
    game_loop.

handle_input(climb) :-
    altitude_level(L),
    L < 10,
    L1 is L + 1,
    retract(altitude_level(L)),
    asserta(altitude_level(L1)),
    nl, write('You climb higher...'), nl,
    check_random_event,
    ( L1 = 10 -> describe(10)
    ; true ),
    game_loop.

handle_input(status) :-
    show_status,
    game_loop.

handle_input(show_map) :-
    hp(teto, HP), HP =< 0, !,
    write('Teto is no longer with you... you can\'t talk to her.'), nl,
    game_loop.

handle_input(show_map) :-
    altitude_level(Level),
    altitude_meter(Level, Alt),
    nl,
    write('Teto looks at you and says: "We are at about '), write(Alt), write(' meters."'), nl,
    describe(Level),
    game_loop.

handle_input(use_supplies(_)) :-
    hp(miku, HP), HP =< 0, !,
    nl, 
    write('Miku is no longer with you... you can\'t ask her to use a supply.'), nl,
    game_loop.

handle_input(use_supplies(Name)) :-
    \+ alive(Name), !,
    nl,
    write(Name), write(' is dead and cannot be healed.'), nl,
    game_loop.


handle_input(use_supplies(Name)) :-
    supplies(S),
    ( S > 0 ->
        heal(Name, 25),
        S1 is S - 1,
        retract(supplies(S)),
        asserta(supplies(S1)),
        write('You used supplies on '), write(Name), write('.'), nl
    ; write('You have no supplies left!'), nl
    ),
    game_loop.

handle_input(portrait(Name)) :-
    describe(Name),
    game_loop.

handle_input(quit) :-
    nl,
    write('You abandon the climb. Game over.'), nl.

handle_input(_) :-
    write('Invalid command.'), nl,
    game_loop.

% Altitude Mapping

altitude_meter(1, 5100).
altitude_meter(2, 5450).
altitude_meter(3, 6150).
altitude_meter(4, 6500).
altitude_meter(5, 6850).
altitude_meter(6, 7200).
altitude_meter(7, 7550).
altitude_meter(8, 7900).
altitude_meter(9, 8250).
altitude_meter(10, 8611).

% Show Status

show_status :-
    altitude_level(Level), altitude_meter(Level, Alt),
    hp(mori, PHP), hp(miku, MHP), hp(teto, THP),
    write('Altitude Level: '), write(Level), write(' ('), write(Alt), write(' m)'), nl,
    supplies(S), write('Supplies left: '), write(S), nl,
    write('Health:'), nl,
    write('  Mori  : '), write(PHP), nl,
    write('  Miku  : '), write(MHP), nl,
    write('  Teto  : '), write(THP), nl.

% Random Events

check_random_event :-
    random(1, 6, X),
    handle_event(X).

handle_event(1) :-
    ( alive(teto) ->
        write('An avalanche strikes and Teto barely gets away.'), nl,
        damage(teto, 45)
    ;
        write('The weather is stable. You continue climbing.'), nl
    ).

handle_event(2) :-
     ( alive(miku) ->
        write('Frostbite hits Miku hard.'), nl,
        damage(miku, 35)
    ; 
        write('The weather is stable. You continue climbing.'), nl
    ).

handle_event(3) :-
    write('A rockslide hits you and you barely get away!'), nl,
    damage(mori, 40).

handle_event(4) :-
    supplies(S),
    ( S > 0 ->
        S1 is S - 1,
        retract(supplies(S)),
        asserta(supplies(S1)),
        write('You drop some supplies during a storm!'), nl,
        write('Supplies remaining: '), write(S1), nl
    ; write('A storm rages, but you have no supplies left to lose.'), nl
    ).

handle_event(5) :-
    write('Everyone is exhausted from the wind. Minor injuries all around.'), nl,
    damage(mori, 10),
    ( alive(miku) ->
        damage(miku, 10)
    ),
    ( alive(teto) ->
        damage(teto, 10)
    ).

handle_event(_) :-
    write('The weather is stable. You continue climbing.'), nl.

% Damage System

damage(Name, _) :-
    hp(Name, HP),
    HP =< 0,
    !,
    write(Name), write(' is already gone. No further harm can be done.'), nl.

damage(Name, Amount) :-
    hp(Name, Current),
    NewHP is max(0, Current - Amount),
    retract(hp(Name, Current)),
    asserta(hp(Name, NewHP)),
    write(Name), write(' took '), write(Amount), write(' damage!'), nl,
    ( NewHP =< 0 ->
        ( Name = mori ->
            nl, write('You have succumbed to the mountain. Game over.'), nl,
            end_game
        ; write(Name), write(' passed away...'), nl
        )
    ; true ).

% Healing

heal(Name, Amount) :-
    hp(Name, Current),
    NewHP is min(100, Current + Amount),
    retract(hp(Name, Current)),
    asserta(hp(Name, NewHP)),
    write(Name), write(' recovered to '), write(NewHP), write(' HP.'), nl.

% Game End

win_game :-
    nl,
    write('You have reached the summit!'), nl,
    write('Against all odds, you have made it.'), nl,
    hp(miku, MHP),
    hp(teto, THP),
    ( MHP > 0 -> write('Miku survived the climb.'), nl ; write('Miku didn\'t make it...'), nl ),
    ( THP > 0 -> write('Teto survived the climb.'), nl ; write('Teto didn\'t make it...'), nl ),
    nl,
    write('Thank you for playing!'), nl,
    nl,
    write('Type anything and add "." to close the console: '),
    read(_),
    halt.
    


% Player Descriptions


describe(teto) :-
    nl,
    write('                          X+++$.'), nl,
    write('                        X.     +'), nl,
    write('                 ++++++xx++++&'), nl,
    write('              .$++++++++++++++++.'), nl,
    write('             X+++++++++++X+++++++$'), nl,
    write('   .Xx+++xxX$+x+$+;;;;+++x+x+++$++$ . . . .'), nl,
    write('  XXXXXXXXXX;+$;;;;;;X++++++++++$+xXXXXXXX$$x.'), nl,
    write('   x++++++x$Xx;++++$.++++$$++++++$xXx$XXX$++x.'), nl,
    write('   x++x++$X+++$++$...++++..;+++++++xx+++++++X'), nl,
    write('   .$++++$xXX+++&$$..++x.....$++X$$$x$$$$$$x.'), nl,
    write('   .x++++X$x$XX.xxx$.X..;;$. &xx$+.X+++++++X'), nl,
    write('   .++++X$XX$+$..........x::.x++X+.X+xxxxxxX'), nl,
    write('    X++++++X xx&............xx+$+. .x+$$$$x$'), nl,
    write('        +$x  .$ +.xx.......x.+;.    .X$$$Xx.'), nl,
    write('     .X$$.       ..+x$&+X.. .       .$+x+x'), nl,
    write('        .$.      .x&xxxX;.$.          X$'), nl,
    write('               .$xxXx$xxxxxx;'), nl,
    write('              .+xx xx&xxxx+xx&'), nl,
    write('              .&. XXx$xxxXx&xxx'), nl,
    write('                .xXxxxxXx&x+:&.'), nl,
    write('                   +;:&;+X&&'), nl,
    write('                   X$$&&$$&'), nl,
    write('                    $$&.$$&'), nl,
    write('                   .&&. $x'), nl,
    nl.

describe(mori) :-
    nl,
    write('                  .&..  :&.                       '), nl,
    write('                  .&X.&:&&.                       '), nl,
    write('                 ..:&&&&&&&&&&+.:.                '), nl,
    write('               :&&&&&&&&&&&&&&&&&&:               '), nl,
    write('        ..  .:+&&&&&&&&&&&&&&&&&&&&::             '), nl,
    write('          .&+;&&&&&&&&&&&&&&&&&&&&&&.             '), nl,
    write('             .&&&&&&&&&&&&&&&&&&&&&&;             '), nl,
    write('            .&&&&&&&&&&&&&&&&&&&&&&&&.            '), nl,
    write('           ..&&&&&&&&&&&&&&&&&&&&&&&&..           '), nl,
    write('           .&&&&&&&&&&&&&&&&&&&&&&&&&:&.          '), nl,
    write('           ;&&&&&&&&&&&&&&&&&&&&&&&&&&:           '), nl,
    write('         ...$X.&&&&&&&&&&&&&&&&&&&&&&:...         '), nl,
    write('            .&.&&&&&.&&&&&&&.&&&&&&;:..           '), nl,
    write('           ..$&&&&&&&$&&&&&&x&&&&&&&;:            '), nl,
    write('            ...&&&&.....X&&x....&&&&++.           '), nl,
    write('            .:.&&&&.............&&&.&             '), nl,
    write('             .&.&&&+....&X.....&&+&..             '), nl,
    write('               :.&&.&...$&$..$.&&$                '), nl,
    write('               .&&&..$......+..&&&.               '), nl,
    write('               .&&&...:X&&:$..&&&&                '), nl,
    write('               :&&&&.........&&&&&.               '), nl,
    write('              .&&&&&&.......&&&&&&&&&             '), nl,
    write('          .;&&&&&&&&&....$..&&&&&&&&&&&&.         '), nl,
    write('       .X&&&&&&&&&&&&X&.;...&&&&&&&&&&&&&&&:.     '), nl,
    write('    .&&&&&&&&&&&&&&&&...&.&x&&&&&&&&&&&&&&&&&&&:. '), nl,
    write('.&&&&&&&&&&&&&&&&&&&&&&&.&&&&&&&&&&&&&&&&&&&&&&&&&'), nl,
    write('&&&&&&&&&&&&&&&&&&&&$&&&.&&&&&&&&&&&&&&&&&&&&&&&&&'), nl,
    nl.

describe(miku) :-
    nl,
    write('                                              '), nl,
    write('                                              '), nl,
    write('              .xX&+.:XXX;.                    '), nl,
    write('             $X.$;;;;;;;;;;;;$$&XX            '), nl,
    write('           xX&$::::::::;;;;;;;;$+X&           '), nl,
    write('           $&;::;:;;;;;;;;;;;;;$+XX&          '), nl,
    write('           .X:;;;::;;;+;;;;;;;;+X;$X&         '), nl,
    write('           XX;;x;.Xx;;X:;$;x;;;;$x&&.         '), nl,
    write('           ;+;;+&&..x;X..$.$;;;;$$$;          '), nl,
    write('          .;;:;&+x+$.x;.&$&&$;;;Xx+;.         '), nl,
    write('          $;+$;;.x;...$:x+x $;+;;Xx;$         '), nl,
    write('         .;;x +$............+;$. Xx;x         '), nl,
    write('         .;+x  X$;+;......x:x+.  ;x;;         '), nl,
    write('         $;xX      .++$$.. .     .x;;.        '), nl,
    write('         :;x$    .$& + .&x.      .x;;:        '), nl,
    write('        .;;x$  .$$$X +:.:$$X     .X;;$        '), nl,
    write('        :;;XX  :Xx$..;.: &$$$    .$;;+        '), nl,
    write('        .x;;x    $$$$$&&$$&;.    +;;;:        '), nl,
    write('         XX;;.     &xxx$X&      .$;x;;        '), nl,
    write('          .xxx.    XXX.XX&      x;xx;         '), nl,
    write('            ..      XX.XX;     Xxx$.          '), nl,
    write('                    .  $$                     '), nl,
    write('                                              '), nl, 
    nl.

% Location Descriptions

describe(1) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp (You are here!)'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(2) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\      <-- (You are here!)'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(3) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1 (You are here!)'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(4) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\         <-- (You are here!)'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(5) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2 (You are here!)'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(6) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\            <-- (You are here!)'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(7) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone (You are here!)'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(8) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_               <-- (You are here!)'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(9) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit'), nl,
    write('              _/ \\_                 <-- (You are here!)'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    nl.

describe(10) :-
    nl,
    write('                +'), nl,
    write('                |                   <--- Summit (You are here!)'), nl,
    write('              _/ \\_'), nl,
    write('            _/     \\_'), nl,
    write('          _////////  \\_             <--- Death Zone'), nl,
    write('         /  |       \\\\\\\\'), nl,
    write('       _/^^^^^^^^^^^^^^^\\_          <--- Camp 2'), nl,
    write('      /\\\\\\\\\\\\\\\\\\|/////////\\'), nl,
    write('    _///////////|\\\\\\\\\\\\\\\\\\\\\\_       <--- Camp 1'), nl,
    write('   /-------------------------\\'), nl,
    write(' _/___________________________\\_    <--- Basecamp'), nl,
    write('/_______________________________\\'), nl,
    win_game,
    nl.