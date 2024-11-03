

% Married characters
married("Caroline").
married("Demetrius").
married("Evelyn").
married("George").
married("Jodi").
married("Kent").
married("Robin").
married("Pam").
married("Marnie").
married("Lewis").

% Bachelors
bachelor("Alex").
bachelor("Elliott").
bachelor("Harvey").
bachelor("Sam").
bachelor("Sebastian").
bachelor("Shane").

% Bachelorettes
bachelorette("Abigail").
bachelorette("Emily").
bachelorette("Haley").
bachelorette("Leah").
bachelorette("Maru").
bachelorette("Penny").

% Children
child("Jas").
child("Vincent").
child("Leo").


% Spouse relationships (canon couples)
spouse("Kent", "Jodi").
spouse("Jodi", "Kent").
spouse("Demetrius", "Robin").
spouse("Robin", "Demetrius").
spouse("Caroline", "Pierre").
spouse("Pierre", "Caroline").
spouse("Evelyn", "George").
spouse("George", "Evelyn").

% Parent relationships
parent("Kent", "Sam").
parent("Kent", "Vincent").
parent("Jodi", "Sam").
parent("Jodi", "Vincent").

parent("Robin", "Sebastian").
parent("Robin", "Maru").
parent("Demetrius", "Maru").

parent("Caroline", "Abigail").
parent("Pierre", "Abigail").

parent("Pam", "Penny").
parent("Lewis", "Alex").
parent("Marnie", "Alex").

parent("Evelyn", "Marnie").
parent("George", "Marnie").


%rules

divorced(X) :- 
	married(X),       % X is in married list
      	\+ spouse(X, _).  % but have no couple in spouse list


siblings(X, Y) :-
       	parent(Z, X), %Z is a parent of X%
       	parent(Z, Y), % Z is a parent of Y
	Y \= X.     % it's not the same person

grandparent(X, Y) :- 
	parent(X, Z), % X is a parent of Z
	parent(Z, Y).  % when Z is a parent of Y

half_siblings(S1, S2):-
	parent(P1, S1),  %P1 is parent of the first child
	spouse(P1, P2),  %P1 is P2 husband or wife
       	parent(P2, S2),  %find the second sibling, whose parent is P2
	S1 \= S2,        % S1 and S2 cannot be one person
       	P1 \= P2, 	 % parents also couldn't be one person
	not(parent(P2,S1)).  %the second parent can't be bio-parent of the first child )

%spouse(X, Y) :- spouse(Y, X).
