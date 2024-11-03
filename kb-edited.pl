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
spouse_canon(kent, jodi).
spouse_canon(demetrius, robin).
spouse_canon(caroline, pierre).
spouse_canon(evelyn, george).
spouse_canon(marnie, lewis).

% Parents class
parents(kent, sam).
parents(kent, vincent).
parents(jodi, sam).
parents(jodi, vincent).
parents(robin, sebastian).
parents(robin, maru).
parents(demetrius, maru).
parents(caroline, abigail).
parents(pierre, abigail).
parents(pam, penny).
parents(lewis, alex).
parents(marnie, alex).
parents(evelyn, marnie).
parents(george, marnie).


friend(abigail, haley).
friend(haley, abigail).


friendship_level(abigail, haley, 5).
friendship_level(haley, abigail, 5).


max_friendship_level(10).
min_friendship_level(-5).


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

children(C, P) :- parents(P, C).
grandparents(G, C) :- parents(G, P), parents(P, C).
spouse(X, Y) :- (spouse_canon(X, Y); spouse_canon(Y, X)), !.


step-siblings(S1, S2):-
	parents(P1, S1),
	spouse(P1, P2),
    parents(P2, S2),
	S1 \= S2,
    P1 \= P2,
	not(parents(P2,S1)).


siblings(X, Y) :-
    parents(Z, X),
    parents(Z, Y),
	Y \= X.

residents_by_age(N, A) :- resident(N, _, A).
residents_by_sex(N, S) :- resident(N, S, _).
list_all_residents :- findall((N, S, A), resident(N, S, A), Residents), Residents.



make_friends(Person1, Person2) :-
    ((friend(Person1, Person2) ; friend(Person2, Person1))
    ->  false
    ;( Person1 = Person2 -> false
       ;
       assertz(friend(Person1, Person2)),
       assertz(friend(Person2, Person1)),
       assertz(friendship_level(Person1, Person2, 0)),
       assertz(friendship_level(Person2, Person1, 0))
    )).



gave_gift(Person, Friend, Gift) :-
        (gift_effect(Gift, Effect) ->
            friendship_level(Person, Friend, CurrentLevel),
            NewLevel is CurrentLevel + Effect,
            clamp_friendship(NewLevel, ClampedLevel),
            retract(friendship_level(Person, Friend, CurrentLevel)),
            retract(friendship_level(Friend, Person, CurrentLevel)),
            assertz(friendship_level(Person, Friend, ClampedLevel)),
            assertz(friendship_level(Friend, Person, ClampedLevel))
            ;
            false
            ).


clamp_friendship(Level, ClampedLevel) :-
    max_friendship_level(Max),
    min_friendship_level(Min),
    (Level > Max -> ClampedLevel = Max;
     Level < Min -> ClampedLevel = Min;
     ClampedLevel = Level).


check_friendship_status(Person, Friend, Level) :-
    min_friendship_level(Min),
    Level =:= Min, !,
    retract(friend(Person, Friend)),
    retract(friend(Friend, Person)),
    retract(friendship_level(Person, Friend, Level)),
    retract(friendship_level(Friend, Person, Level)),
    false.

check_friendship_status(Person, Friend, Level) :-
    Person \= Friend,
    max_friendship_level(Max),
    min_friendship_level(Min),
    Level > Min, Level =< Max, !.


check_friendship(Person, Friend) :-
    (friendship_level(Person, Friend, Level) ->  write(Person), write(' и '), write(Friend), write(' друзья! Уровень дружбы: '), write(Level), nl ;
    false).

list_gifts(GiftEffects) :-
    findall([Gift, Effect], gift_effect(Gift, Effect), GiftEffects).

print_gift_effects([]).
print_gift_effects([(Gift, Effect)|Rest]) :-
    write(Gift), write(': Уровень дружбы изменяется на '), write(Effect), nl,
    print_gift_effects(Rest).



list_friends(Person) :-
    findall(Friend, friend(Person, Friend), Friends),
    (Friends = [] ->
        write(Person), write(' не имеет друзей.'), nl
        ;
        write(Person), write(' имеет следующих друзей: '),
        write_list(Friends),  % Выводим список друзей
        nl
    ).


write_list([]).
write_list([H|T]) :-
    (T = [] -> write(H), write('.'), !; write(H), write(', '), write_list(T)).



list_all_friends :-
    findall(Person, resident(Person, _, _), Residents), write(Residents).


print_all_friends([]).
print_all_friends([Person | Rest]) :-
    list_friends(Person),
    print_all_friends(Rest).
% spouse(A, B) :- (B @< A -> spouse(B, A), !, true).