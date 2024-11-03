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

child(C, P) :- parent(P, C).
grandparent(G, C) :- parent(G, P), parent(P, C).
spouse(X, Y) :- Y @< X, spouse(Y, X), !.

step-siblings(S1, S2):-
	parent(P1, S1),  
	spouse(P1, P2),  
    parent(P2, S2), 
	S1 \= S2,       
    P1 \= P2, 	
	not(parent(P2,S1)).

siblings(X, Y) :-
    parent(Z, X),
    parent(Z, Y), 
	Y \= X.    

residents_by_age(N, A) :- resident(N, _, A).
residents_by_sex(N, S) :- resident(N, S, _).



make_friends(Person1, Person2) :-
    ( Person1 \= Person2, (friend(Person1, Person2) ; friend(Person2, Person1))  
    ->  write(Person1), write(' и '), write(Person2), write(' уже друзья!'), nl
    ;   assertz(friend(Person1, Person2)),  
        assertz(friend(Person2, Person1)),
        write(Person1), write(' и '), write(Person2), write(' теперь друзья!'), nl
    ).



gave_gift(Person, Friend, Gift) :-
    ((friend(Person, Friend); friend(Friend, Person)) -> 
        (gift_effect(Gift, Effect) ->
            % Обновляем уровень дружбы
            friendship_level(Person, Friend, CurrentLevel),
            NewLevel is CurrentLevel + Effect,
            clamp_friendship(NewLevel, ClampedLevel),
            retract(friendship_level(Person, Friend, CurrentLevel)),
            retract(friendship_level(Friend, Person, CurrentLevel)),
            assertz(friendship_level(Person, Friend, ClampedLevel)),
            assertz(friendship_level(Friend, Person, ClampedLevel)),
            check_friendship_status(Person, Friend, ClampedLevel)
            ;
            write('Подарка '), write(Gift), write(' не существует.'), nl
        );  write(Person), write(' и '), write(Friend), write(' не друзья!'), nl
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
    write(Person), write(' и '), write(Friend), write(' больше не друзья!'), nl.

check_friendship_status(Person, Friend, Level) :-
    max_friendship_level(Max),
    min_friendship_level(Min),
    Level > Min, Level =< Max, !,
    write(Person), write(' и '), write(Friend), write(' друзья! Уровень дружбы: '), write(Level), nl.

check_friendship(Person, Friend) :-
    (friendship_level(Person, Friend, Level) ->  write(Person), write(' и '), write(Friend), write(' друзья! Уровень дружбы: '), write(Level), nl ;
    write(Person), write(' и '), write(Friend), write(' не друзья!'), nl).


list_gifts :-
    findall((Gift, Effect), gift_effect(Gift, Effect), GiftEffects),
    (   GiftEffects \= []
    ->  write('Список всех подарков и их эффектов:'), nl,
        print_gift_effects(GiftEffects)
    ;   write('Нет доступных подарков.'), nl
    ).


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
    findall(Person, resident(Person, _, _), Residents),
    print_all_friends(Residents), !.


print_all_friends([]).
print_all_friends([Person | Rest]) :-
    list_friends(Person),  
    print_all_friends(Rest).  
% spouse(A, B) :- (B @< A -> spouse(B, A), !, true).