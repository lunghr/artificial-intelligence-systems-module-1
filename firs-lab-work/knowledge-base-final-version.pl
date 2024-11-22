:- discontiguous(spouse/2).
:- dynamic(friend/2).
:- dynamic(friendship_level/3).

% Age class
age(child).
age(teenager).
age(young_adult).
age(adult).
age(elder).

% Sex class
sex(male).
sex(female).

% Residents class
resident(abigail, female, young_adult).
resident(alex, male, young_adult).
resident(caroline, female, adult).
resident(clint, male, adult).
resident(demetrius, male, adult).
resident(elliott, male, adult).
resident(emily, female, adult).
resident(evelyn, female, elder).
resident(george, male, elder).
resident(gus, male, elder).
resident(haley, female, young_adult).
resident(jas, female, child).
resident(jodi, female, adult).
resident(kent, male, adult).
resident(leah, female, adult).
resident(lewis, male, elder).
resident(linus, male, elder).
resident(maru, female, young_adult).
resident(marnie, female, adult).
resident(pam, female, adult).
resident(penny, female, young_adult).
resident(pierre, male, adult).
resident(robin, female, adult).
resident(sam, male, young_adult).
resident(sandy, female, adult).
resident(sebastian, male, young_adult).
resident(shane, male, adult).
resident(vincent, male, child).

% Spouses class
spouse(kent, jodi).
spouse(demetrius, robin).
spouse(caroline, pierre).
spouse(evelyn, george).
spouse(marnie, lewis).

% Parents class
parent(kent, sam).
parent(kent, vincent).
parent(jodi, sam).
parent(jodi, vincent).
parent(robin, sebastian).
parent(robin, maru).
parent(demetrius, maru).
parent(caroline, abigail).
parent(pierre, abigail).
parent(pam, penny).
parent(lewis, alex).
parent(marnie, alex).
parent(evelyn, marnie).
parent(george, marnie).

% friends facts
friend(abigail, haley).
friend(haley, abigail).

% frienship level facts
friendship_level(abigail, haley, 5).
friendship_level(haley, abigail, 5).

% consts for max and min level of frienship
max_friendship_level(10).
min_friendship_level(-5).

% available gifts with point of their effects
gift_effect(chocolate_cake, 2).
gift_effect(pufferfish, -4).
gift_effect(ice_cream, 3).
gift_effect(coffee, 1).
gift_effect(dandelion, 0).
gift_effect(tulip, 1).
gift_effect(starfruit, 4).
gift_effect(amethyst, 3).
gift_effect(diamond, 5).


% rules

% child rule
child(C, P) :- parent(P, C).

%grandparent rule
grandparent(G, C) :- parent(G, P), parent(P, C).

% rule for symmetric spouse fact
% Y@<X - we are check if pair spouse(Y, X) is already exist, we don't need to create
% one more pair: spouse (X, jodi) -> spouse (kent, jodi)
% in other hand, if "Y less than X", we check pair (Y, X): if this pair exists, then
% pair (X, Y) also can be created
spouse(X, Y) :- Y @< X, spouse(Y, X), !.

% step-siblings rule (find 1 parent -> find ther spouse -> find spouse child -> check
% that siblings and parents not one persone -> then check that 1 parent not a bio-parent
% for second sibling)
step-siblings(S1, S2):-
	parent(P1, S1),
	spouse(P1, P2),
    parent(P2, S2),
	S1 \= S2,
    P1 \= P2,
	not(parent(P2,S1)).

% sibling rule
siblings(X, Y) :-
    parent(Z, X),
    parent(Z, Y),
	Y \= X.

% literally unnecessary rules
residents_by_age(N, A) :- resident(N, _, A).
residents_by_sex(N, S) :- resident(N, S, _).



% making two persons friends
make_friends(Person1, Person2) :-
% if two args not one person but pair friend(X, Y) or friend(Y, X) exists -> false
    ( Person1 \= Person2, (friend(Person1, Person2) ; friend(Person2, Person1))
    ->  write(Person1), write(' и '), write(Person2), write(' уже друзья!'), nl
    % else: write new facts: friend(X, Y) & friend(Y, X)
    ;   assertz(friend(Person1, Person2)),
        assertz(friend(Person2, Person1)),
        assertz(friendship_level(Person1, Person2, 0)),
        assertz(friendship_level(Person2, Person1, 0)),
        write(Person1), write(' и '), write(Person2), write(' теперь друзья!'), nl
    ).


% gave gift from one frend to another
gave_gift(Person, Friend, Gift) :-
		%if persons are friends
    ((friend(Person, Friend); friend(Friend, Person)) ->
		    % and input gift exists
        (gift_effect(Gift, Effect) ->
		        % find friends friendship level (int)
            friendship_level(Person, Friend, CurrentLevel),
            % counting new friendship level, which based on gift effect
            NewLevel is CurrentLevel + Effect,
            % frienship level must be in [-5, 10] diapason, so cutting level
            clamp_friendship(NewLevel, ClampedLevel),
            % delete old frienship level
            retract(friendship_level(Person, Friend, CurrentLevel)),
            retract(friendship_level(Friend, Person, CurrentLevel)),
            % paste new friendship level
            assertz(friendship_level(Person, Friend, ClampedLevel)),
            assertz(friendship_level(Friend, Person, ClampedLevel)),
            % if friendship level less than -5 persons not friends anymore
            % so we need to check this
            check_friendship_status(Person, Friend, ClampedLevel)
            ;
            write('Подарка '), write(Gift), write(' не существует.'), nl
        );  write(Person), write(' и '), write(Friend), write(' не друзья!'), nl
    ).

% a rule of thumb to keep the friendship level within a given diapason [-5, 10]
clamp_friendship(Level, ClampedLevel) :-
    max_friendship_level(Max),
    min_friendship_level(Min),
    (Level > Max -> ClampedLevel = Max;
     Level < Min -> ClampedLevel = Min;
     ClampedLevel = Level).

% rule for checking is persons still friends after the gift
check_friendship_status(Person, Friend, Level) :-
    min_friendship_level(Min),
    % if friendship level more than -5 then we go to another rule  version,
    Level =:= Min, !,
    % else we delete all facts about this friendship
    retract(friend(Person, Friend)),
    retract(friend(Friend, Person)),
    retract(friendship_level(Person, Friend, Level)),
    retract(friendship_level(Friend, Person, Level)),
    write(Person), write(' и '), write(Friend), write(' больше не друзья!'), nl.

% rule for checking is persons still friends after the gift
check_friendship_status(Person, Friend, Level) :-
    max_friendship_level(Max),
    min_friendship_level(Min),
    % if everything is okay, we write message
    Level > Min, Level =< Max, !,
    write(Person), write(' и '), write(Friend), write(' друзья! Уровень дружбы: '), write(Level), nl.

% simple rule for checking friendship level
check_friendship(Person, Friend) :-
    (friendship_level(Person, Friend, Level) ->  write(Person), write(' и '), write(Friend), write(' друзья! Уровень дружбы: '), write(Level), nl ;
    write(Person), write(' и '), write(Friend), write(' не друзья!'), nl).

% list of all available gifts with their effects
list_gifts :-
    findall((Gift, Effect), gift_effect(Gift, Effect), GiftEffects),
    (   GiftEffects \= []
    ->  write('Список всех подарков и их эффектов:'), nl,
        print_gift_effects(GiftEffects)
    ;   write('Нет доступных подарков.'), nl
    ).

%printers for gifts
print_gift_effects([]).
print_gift_effects([(Gift, Effect)|Rest]) :-
    write(Gift), write(': Уровень дружбы изменяется на '), write(Effect), nl,
    print_gift_effects(Rest).


% list all friends of specific person
list_friends(Person) :-
    findall(Friend, friend(Person, Friend), Friends),
    (Friends = [] ->
        write(Person), write(' не имеет друзей.'), nl
        ;
        write(Person), write(' имеет следующих друзей: '),
        write_list(Friends),
        nl
    ).

% printers for list of friends
write_list([]).
write_list([H|T]) :-
    (T = [] -> write(H), write('.'), !; write(H), write(', '), write_list(T)).


% list of all friends for all residents
list_all_friends :-
    findall(Person, resident(Person, _, _), Residents),
    print_all_friends(Residents), !.


print_all_friends([]).
print_all_friends([Person | Rest]) :-
    list_friends(Person),
    print_all_friends(Rest).