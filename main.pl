cons2(X, Y, L) :- L = [Y|X].

connected(X, Y, E) :- member2([X, Y], E).

member2(E, [E|_]).
member2(E, [_|T]) :- member2(E, T).

reverse2([], []). 
reverse2([X], [X]).
reverse2([X|Xs], R) :- reverse2(Xs,T), append2(T, [X], R).

append2([], X, X).                            
append2([X|Y], Z, [X|W]) :- append2(Y, Z, W).

getNeighbours(X, E, V, [T|Ex]) :- findall(N, (connected(X, N, E), not(member2(N, V))), [T|Ex]).

buildQueue(V, R, [T|Ex], Q) :- maplist(cons2(V), [T|Ex], VEx), append2(R, VEx, Q).
            
breadth_first_search(Y, [ [Y|V]|_ ], _, P) :- reverse2([Y|V], P).
breadth_first_search(Y, [V|R], E, P) :- V = [X|_], not(X = Y), getNeighbours(X, E, V, [T|Ex]), 
	buildQueue(V, R, [T|Ex], Q), breadth_first_search(Y, Q, E, P).
breadth_first_search(Y, [V|R], E, P) :- V = [_,X|_], not(X = Y), getNeighbours(X, E, V, [T|Ex]), 
	buildQueue(V, R, [T|Ex], Q), breadth_first_search(Y, Q, E, P), !.
breadth_first_search(Y, [V|R], E, P) :- V = [_,_,X|_], not(X = Y), getNeighbours(X, E, V, [T|Ex]), 
	buildQueue(V, R, [T|Ex], Q), breadth_first_search(Y, Q, E, P), !.

getPath(X,Y,[N,E],F,P) :- breadth_first_search(Y,[[X]],E,P), formula(P,N,F). 


formula(_,_,valid) :- !.
formula([H|_],N,F) :- member2([H,F], N),!. 
formula(P,N,global(X)) :- global(P,N,X),!.
formula([_,H2|T], N, next(F)) :- formula([H2|T],N,F), !.
formula(P, N, future(X)) :- future(P,N,X), !.
formula(P, N, and(A1, A2)) :- formula(P,N,A1), formula(P,N,A2), !.
formula(P, N, or(A1, A2)) :- formula(P,N,A1); formula(P,N,A2),!.
formula(P, N, not(F)) :- not(formula(P,N,F)),!.
formula(P, N, until(C1,C2)) :- until(P,N,C1,C2),!. 

global([],_,_).
global([H|T], N, X) :- member2([H, X], N), global(T, N, X).

future([H|T], N, X) :- member2([H, X], N); future(T, N, X).

getColor(N,X,C) :- member2([X,C],N).

until([],_,_,_).
until([H|T],N,C1,C2) :- getColor(N,H,C), C = C1, until(T, N, C1, C2).
until([H|_],N,_,C2) :- getColor(N,H,C), C = C2, !.
