# hello-pentago
Pentago game created on Racket. 

#lang typed/racket
(require typed/test-engine/racket-tests)
(require "../include/uchicago151.rkt")
(require typed/2htdp/image)
(require typed/lang/posn)
(require typed/2htdp/universe)


;;NOTE: Pentago is designed with white player
;;being called first.

;;Project A: create board and game logic
;;Project B: implement game and GUI
;;--Skip to ~~LINE 1325 to begin Project B.
;;Project C: create AI bot player
;;--Skip to ~~LINE 1500 to begin Project C.


;;Guide to Project A
;;== 1) Structures/Type Definitions
;;== 2) Pre-defined quadrants/boards/games/etc.
;;== 3) Pre-defined Pieceloc/Pieces (my structures)
;;== 4) Conversion functions b/t structs/types/etc.
;;== 5) Helper functions for Project A
;;== 6) Helper functions specifically for wins
;;== 7) FINAL functions (and helpers that need them)
;;== 8) Drawing the Board/Game

;;=================== PROJECT A WORK ====================================;;
;;=================== ===================   ================================ ;;
;;=================== ===================   ================================ ;;



;;================1) Structures/ Type Definitions: Project A===============;;
;;======================================================================= ;;




(define-type (Optional a)
  (U 'none (Some a)))

(define-struct (Some a)
  ([x : a]))

(define-type Player 
  (U 'black 'white))

(define-struct Loc
  ([row : Integer]   ;; an integer on the interval [0,5]
   [col : Integer])) ;; an integer on the interval [0,5]

(define-type Quadrant
  (U 'NW 'NE 'SW 'SE))

(define-type Direction
  (U 'clockwise 'counterclockwise))

(define-struct Board
  ([NW : (Listof (Optional Player))] ;; these are all lists of length 9
   [NE : (Listof (Optional Player))]
   [SW : (Listof (Optional Player))]
   [SE : (Listof (Optional Player))]))

(define-struct Game
  ([board : Board]
   [next-player : Player]
   [next-action : (U 'place 'twist)]))

(define-type Outcome
  (U Player 'tie))

(define-struct Piece ;;Note, structure I created. Utilized in drawing and throughout.
  ([color : (Optional Player)] ;;Either 'none (Some 'black) or (Some 'white)
   [place : Integer])) ;;Place within a quadrant, 0-8.

(define-struct Pieceloc ;;Note, structure I created. Utilized throughout.
  ([onboard : Loc] ;;Location on board [row, col]
   [inquad : Integer] ;;Place within a quadrant 0-8
   [marble : (Optional Player)])) ;;Either 'none (Some 'black) or (Some 'white)



;;=========2) Pre-defined quadrants/boards/games/etc.: Project A===========;;
;;======================================================================= ;;

;;These are a bunch of different definitions which are later
;;used in check-expects and utilized throughout. This section
;;includes i) quadrants, ii) boards, and iii) games.
;;But does not include my own structures. 



;;============== i) QUADRANTS==============;;

(: quad1 : (Listof (Optional Player)))
(define quad1 (list 'none (Some 'black) (Some 'white)
                    (Some 'white) (Some 'white) 'none
                    (Some 'black) 'none 'none))
(: quad2 : (Listof (Optional Player)))
(define quad2 (list (Some 'white) (Some 'black) (Some 'white)
                    (Some 'white) (Some 'white) (Some 'black)
                    (Some 'black) (Some 'black) (Some 'black)))

(: quad3 : (Listof (Optional Player)))
(define quad3 (list 'none 'none 'none
                    'none 'none 'none
                    'none 'none 'none))

(: quad4 : (Listof (Optional Player)))
(define quad4 (list 'none (Some 'black) (Some 'black)
                    (Some 'black) (Some 'black) 'none
                    (Some 'black) 'none 'none))
(: quad5 : (Listof (Optional Player)))
(define quad5 (list (Some 'black) (Some 'black) (Some 'black)
                    (Some 'black) (Some 'black) (Some 'black)
                    (Some 'black) (Some 'black) 'none))

(: quad6 : (Listof (Optional Player)))
(define quad6 (list (Some 'black) (Some 'black) (Some 'black)
                    (Some 'black) 'none (Some 'black)
                    (Some 'black) (Some 'black) (Some 'black)))

(: quad7 : (Listof (Optional Player)))
(define quad7 (list 'none (Some 'black) (Some 'black)
                    (Some 'black) (Some 'black) (Some 'black)
                    (Some 'black) (Some 'black) (Some 'black)))



(: quad4black : (Listof (Optional Player)))
(define quad4black (list 'none (Some 'black) (Some 'black)
                         (Some 'black) (Some 'black) 'none
                         (Some 'black) 'none (Some 'black)))

(: quad1clock : (Listof (Optional Player)))
(define quad1clock (list (Some 'black) (Some 'white) 'none
                         'none (Some 'white) (Some 'black)
                         'none 'none (Some 'white)))


(: quadwinnw : (Listof (Optional Player)))
(define quadwinnw (list (Some 'black) 'none 'none
                        'none (Some 'black) 'none
                        'none 'none (Some 'black)))

(: quadwinne : (Listof (Optional Player)))
(define quadwinne (list 'none 'none (Some 'black)
                        'none (Some 'black) 'none
                        (Some 'black) 'none 'none))

(: quadwinse : (Listof (Optional Player)))
(define quadwinse (list (Some 'black) 'none 'none
                        'none (Some 'black) 'none
                        'none 'none 'none))

(: quadwinsw : (Listof (Optional Player)))
(define quadwinsw (list 'none 'none (Some 'black)
                        'none (Some 'black) 'none
                        'none 'none 'none))

(: quadnowin1 : (Listof (Optional Player)))
(define quadnowin1 (list (Some 'black) (Some 'white) (Some 'black)
                         (Some 'white) (Some 'black) (Some 'white) 
                         (Some 'black) (Some 'white) (Some 'black)))

(: quadnowin2 : (Listof (Optional Player)))
(define quadnowin2 (list (Some 'white) (Some 'black)(Some 'white)
                         (Some 'black) (Some 'white) (Some 'black)
                         (Some 'white) (Some 'black) (Some 'white)))

(: quadbothnw : (Listof (Optional Player)))
(define quadbothnw (list 'none 'none 'none
                         (Some 'white) 'none (Some 'black)
                         (Some 'white) 'none (Some 'black)))

(: quadbothsw : (Listof (Optional Player)))
(define quadbothsw (list (Some 'white) 'none (Some 'black)
                         (Some 'white) 'none (Some 'black)
                         (Some 'white) 'none (Some 'black)))

(: quadbegin : (Listof (Optional Player)))
(define quadbegin (list 'none 'none 'none
                        'none 'none 'none
                        'none 'none 'none))
(: move1white : (Listof (Optional Player)))
(define move1white (list (Some 'white) 'none 'none
                         'none 'none 'none
                         'none 'none 'none))

(: quad1counter : (Listof (Optional Player)))
(define quad1counter (reverse quad1clock))

;;============== ii) BOARDS==============;;

(: move1board : Board)
(define move1board (Board move1white quadbegin quadbegin quadbegin))

(: new-board : Board)
(define new-board (Board quadbegin quadbegin quadbegin quadbegin))

(: fullboard : Board)
(define fullboard (Board quad2 quad2 quad2 quad2))

(: exboard1 : Board)
(define exboard1 (Board quad1 quad2 quad3 quad4))

(: exboard2 : Board)
(define exboard2 (Board quad1 quad2 quad3 quad4black))

(: exboard3 : Board)
(define exboard3 (Board quadwinnw quadwinne quadwinsw quadwinse))

(: exboard4 : Board)
(define exboard4 (Board quadwinnw quadwinnw quadwinsw quadwinse))

(: exboard5 : Board)
(define exboard5 (Board quad1 quad2 quad3 quadbothsw))

(: exboard6 : Board)
(define exboard6 (Board quad2 quad2 quad2 quad5))

(: exboard7 : Board)
(define exboard7 (Board quad2 quad2 quad6 quad2))

(: exboard8 : Board)
(define exboard8 (Board quad2 quad7 quad2 quad2))


(: exboardno : Board)
(define exboardno (Board quadnowin1 quadnowin2  quadnowin1 quadnowin2 ))

(: exboardboth : Board)
(define exboardboth (Board quadbothnw quad3 quadbothsw quad3))

(: exboardcount : Board)
;;Twist exboard1 counterclockwise
(define exboardcount (Board quad1counter quad2 quad3 quad4))

(: exboardclock : Board)
;;Twist exboard1 clockwise
(define exboardclock (Board quad1clock quad2 quad3 quad4))

;;============== iii) GAMES==============;;

(: exgame1 : Game)
(define exgame1 (Game exboard1 'black 'place))

(: exgame1place : Game)
(define exgame1place (Game exboard2 'black 'twist))

(: exgame1twist : Game)
(define exgame1twist (Game exboard1 'black 'twist))

(: exgame1counter : Game)
(define exgame1counter (Game exboardcount 'white 'place))

(: exgame1clock : Game)
(define exgame1clock (Game exboardclock 'white 'place))



;;======= 3) Pre-defined Pieceloc/Pieces (my structures): Project A=======;;
;;======================================================================= ;;

;;These are a bunch of different definitions which are later
;;used in check-expects and utilized throughout.
;;This section includes only my own structures,
;; i) Pieces, and ii) Pieceloc


;;============== i) PIECES ==============;;

(: piece1 : (Listof Piece))
(define piece1 (list (Piece 'none 0)
                     (Piece (Some 'black) 1)
                     (Piece (Some 'white) 2)
                     (Piece (Some 'white) 3)
                     (Piece (Some 'white) 4)
                     (Piece 'none 5)
                     (Piece (Some 'black) 6)
                     (Piece 'none 7)
                     (Piece 'none 8)))


;;============== ii) PIECELOCS  ==============;;

(: pieceloc1nw : (Listof Pieceloc))
(define pieceloc1nw (list (Pieceloc (Loc 0 0) 0 'none)
                          (Pieceloc (Loc 0 1) 1 'none)
                          (Pieceloc (Loc 0 2) 2 'none)
                          (Pieceloc (Loc 1 0) 3 'none)
                          (Pieceloc (Loc 1 1) 4 'none)
                          (Pieceloc (Loc 1 2) 5 'none)
                          (Pieceloc (Loc 2 0) 6 'none)
                          (Pieceloc (Loc 2 1) 7 'none)
                          (Pieceloc (Loc 2 2) 8 'none)))

(: pieceloc1sw : (Listof Pieceloc))
(define pieceloc1sw (list (Pieceloc (Loc 3 0) 0 'none)
                          (Pieceloc (Loc 3 1) 1 'none)
                          (Pieceloc (Loc 3 2) 2 'none)
                          (Pieceloc (Loc 4 0) 3 'none)
                          (Pieceloc (Loc 4 1) 4 'none)
                          (Pieceloc (Loc 4 2) 5 'none)
                          (Pieceloc (Loc 5 0) 6 'none)
                          (Pieceloc (Loc 5 1) 7 'none)
                          (Pieceloc (Loc 5 2) 8 'none)))

(: pieceloc1ne : (Listof Pieceloc))
(define pieceloc1ne (list (Pieceloc (Loc 0 3) 0 'none)
                          (Pieceloc (Loc 0 4) 1 'none)
                          (Pieceloc (Loc 0 5) 2 'none)
                          (Pieceloc (Loc 1 3) 3 'none)
                          (Pieceloc (Loc 1 4) 4 'none)
                          (Pieceloc (Loc 1 5) 5 'none)
                          (Pieceloc (Loc 2 3) 6 'none)
                          (Pieceloc (Loc 2 4) 7 'none)
                          (Pieceloc (Loc 2 5) 8 'none)))

(: pieceloc1se : (Listof Pieceloc))
(define pieceloc1se (list (Pieceloc (Loc 3 3) 0 'none)
                          (Pieceloc (Loc 3 4) 1 'none)
                          (Pieceloc (Loc 3 5) 2 'none)
                          (Pieceloc (Loc 4 3) 3 'none)
                          (Pieceloc (Loc 4 4) 4 'none)
                          (Pieceloc (Loc 4 5) 5 'none)
                          (Pieceloc (Loc 5 3) 6 'none)
                          (Pieceloc (Loc 5 4) 7 'none)
                          (Pieceloc (Loc 5 5) 8 'none)))

(: pieceloc2nw : (Listof Pieceloc))
(define pieceloc2nw (list (Pieceloc (Loc 0 0) 0 (Some 'white))
                          (Pieceloc (Loc 0 1) 1 'none)
                          (Pieceloc (Loc 0 2) 2 'none)
                          (Pieceloc (Loc 1 0) 3 'none)
                          (Pieceloc (Loc 1 1) 4 'none)
                          (Pieceloc (Loc 1 2) 5 'none)
                          (Pieceloc (Loc 2 0) 6 'none)
                          (Pieceloc (Loc 2 1) 7 'none)
                          (Pieceloc (Loc 2 2) 8 'none)))

(: pieceloc3nw : (Listof Pieceloc))
(define pieceloc3nw (list (Pieceloc (Loc 0 0) 0 (Some 'white))
                          (Pieceloc (Loc 0 1) 1 (Some 'white))
                          (Pieceloc (Loc 0 2) 2 (Some 'white))
                          (Pieceloc (Loc 1 0) 3 (Some 'white))
                          (Pieceloc (Loc 1 1) 4 'none)
                          (Pieceloc (Loc 1 2) 5 'none)
                          (Pieceloc (Loc 2 0) 6 (Some 'white))
                          (Pieceloc (Loc 2 1) 7 'none)
                          (Pieceloc (Loc 2 2) 8 'none)))

(: pieceloc3sw : (Listof Pieceloc))
(define pieceloc3sw (list (Pieceloc (Loc 3 0) 0 (Some 'white))
                          (Pieceloc (Loc 3 1) 1 'none)
                          (Pieceloc (Loc 3 2) 2 'none)
                          (Pieceloc (Loc 4 0) 3 (Some 'white))
                          (Pieceloc (Loc 4 1) 4 'none)
                          (Pieceloc (Loc 4 2) 5 'none)
                          (Pieceloc (Loc 5 0) 6 'none)
                          (Pieceloc (Loc 5 1) 7 'none)
                          (Pieceloc (Loc 5 2) 8 'none)))

(: pieceloc3ne : (Listof Pieceloc))
(define pieceloc3ne (list (Pieceloc (Loc 0 3) 0 (Some 'white))
                          (Pieceloc (Loc 0 4) 1 (Some 'white))
                          (Pieceloc (Loc 0 5) 2 'none)
                          (Pieceloc (Loc 1 3) 3 'none)
                          (Pieceloc (Loc 1 4) 4 'none)
                          (Pieceloc (Loc 1 5) 5 'none)
                          (Pieceloc (Loc 2 3) 6 'none)
                          (Pieceloc (Loc 2 4) 7 'none)
                          (Pieceloc (Loc 2 5) 8 'none)))

(: pieceloc3se : (Listof Pieceloc))
(define pieceloc3se (list (Pieceloc (Loc 3 3) 0 'none)
                          (Pieceloc (Loc 3 4) 1 'none)
                          (Pieceloc (Loc 3 5) 2 'none)
                          (Pieceloc (Loc 4 3) 3 'none)
                          (Pieceloc (Loc 4 4) 4 'none)
                          (Pieceloc (Loc 4 5) 5 'none)
                          (Pieceloc (Loc 5 3) 6 'none)
                          (Pieceloc (Loc 5 4) 7 'none)
                          (Pieceloc (Loc 5 5) 8 'none)))

(: plocdiag1 : (Listof Pieceloc))
(define plocdiag1 (list (Pieceloc (Loc 0 0) 0 (Some 'black))
                        (Pieceloc (Loc 1 1) 4 (Some 'black))
                        (Pieceloc (Loc 2 2) 8 (Some 'black))
                        (Pieceloc (Loc 3 3) 0 (Some 'black))
                        (Pieceloc (Loc 4 4) 4 (Some 'black))
                        (Pieceloc (Loc 5 5) 8 'none)))

(: plocdiag2 : (Listof Pieceloc))
(define plocdiag2 (list (Pieceloc (Loc 0 5) 2 (Some 'black))
                        (Pieceloc (Loc 1 4) 4 (Some 'black))
                        (Pieceloc (Loc 2 3) 6 (Some 'black))
                        (Pieceloc (Loc 3 2) 2 (Some 'black))
                        (Pieceloc (Loc 4 1) 4 (Some 'black))
                        (Pieceloc (Loc 5 0) 6 'none)))
(: plocdiag2.2 : (Listof Pieceloc))
(define plocdiag2.2 (list (Pieceloc (Loc 0 4) 2 'none)
                          (Pieceloc (Loc 1 3) 4 'none)
                          (Pieceloc (Loc 2 2) 6 'none)
                          (Pieceloc (Loc 3 1) 2 'none)
                          (Pieceloc (Loc 4 0) 4 'none)))

(: pieces3 : (Listof Pieceloc))
(define pieces3 (append pieceloc3nw pieceloc3ne pieceloc3sw pieceloc3se))


;;======4) Conversion functions b/t structs/types/etc.: Project A=========;;
;;======================================================================= ;;

;;These functions convert between
;;Pieces, Piecelocs, Games, Boards, Quadrants, etc.
;; First I will list conversions with i) Pieces/ Pieceloc
;; and then between ii) Games, Boards, etc. 




;;=========Conversions with Pieces/ Pieceloc=====;;

(: make-pieces : (Listof (Optional Player)) ->
   (Listof Piece))
;;Transforms the list of optional players,
;;to a list of piece locations, which holds the
;;color of the piece and a number (0-8).
;;This is used later to work with functions. 
(define (make-pieces ps)
  (match ps
    ['() '()]
    [(cons hd tl)
     (cons (Piece (list-ref ps 0)
                  (- 9 (length ps)))
           (make-pieces tl))]))
(check-expect (make-pieces quad1) piece1)
(check-expect (make-pieces quadbegin)
              (list (Piece 'none 0) (Piece 'none 1) (Piece 'none 2)
                    (Piece 'none 3) (Piece 'none 4) (Piece 'none 5)
                    (Piece 'none 6) (Piece 'none 7) (Piece 'none 8)))



(: make-piece-loc : (Listof Piece) Quadrant
   -> (Listof Pieceloc))
;;Transforms the list of players with the quadrant,
;;so that it has the location within the quadrant,
;;as well as on the board, as well as the player color or none. 
(define (make-piece-loc ps q)
  (match ps
    ['() '()]
    [(cons hd tl) (cons (Pieceloc (transform-loc hd q) (Piece-place hd) (Piece-color hd))
                        (make-piece-loc tl q))]))
(check-expect (make-piece-loc (make-pieces quadbegin) 'NW)
              pieceloc1nw)
(check-expect (make-piece-loc (make-pieces quadbegin) 'NE)
              pieceloc1ne)
(check-expect (make-piece-loc (make-pieces quadbegin) 'SE)
              pieceloc1se)
(check-expect (make-piece-loc (make-pieces move1white) 'NW)
              pieceloc2nw)


(: piece->loc : Piece -> Loc)
;;Transforms a given piece into a piece loc,
;;assuming it is in the upper left quadrant.
(define (piece->loc p)
  (match p
    [(Piece c l)
     (cond
       [(<= l 2)
        (Loc 0 l)]
       [(<= l 5)
        (Loc 1 (abs (- 3 l)))]
       [(<= l 8)
        (Loc 2 (abs (- 6 l)))]
       [else (error "error shouldn't be reached")])]))
(check-expect (piece->loc [Piece 'none 3]) (Loc 1 0))
(check-expect (piece->loc [Piece (Some 'white) 8]) (Loc 2 2))
(check-error (piece->loc [Piece 'none 10]) "error shouldn't be reached")




(: transform-loc : Piece Quadrant -> Loc)
;;Given a Piece, gives its location on the board in [row, col].
(define (transform-loc p q)
  (local {(define base (piece->loc p))
          (define brow (Loc-row base))
          (define bcol (Loc-col base))
          (define nrow (+ 3 brow))
          (define ncol (+ 3 bcol))}
    (match p
      [(Piece c l)
       (match q
         ['NW base]
         ['NE (Loc brow ncol)]
         ['SW (Loc nrow bcol)]
         ['SE (Loc nrow ncol)])])))
(check-expect (transform-loc [Piece 'none 3] 'NW) (Loc 1 0))
(check-expect (transform-loc [Piece 'none 3] 'SW) (Loc 4 0))
(check-expect (transform-loc [Piece 'none 3] 'SE) (Loc 4 3))
(check-expect (transform-loc [Piece 'none 3] 'NE) (Loc 1 3))


(: quad->pieceloc : (Listof (Optional Player)) Quadrant -> (Listof Pieceloc))
;;Given a list of optional players and a quadrant,
;;creates a list of pieceloc.
(define (quad->pieceloc ps q)
  (make-piece-loc (make-pieces ps) q))
(check-expect (quad->pieceloc quad3 'NW)
              (list
               (Pieceloc (Loc 0 0) 0 'none)
               (Pieceloc (Loc 0 1) 1 'none)
               (Pieceloc (Loc 0 2) 2 'none)
               (Pieceloc (Loc 1 0) 3 'none)
               (Pieceloc (Loc 1 1) 4 'none)
               (Pieceloc (Loc 1 2) 5 'none)
               (Pieceloc (Loc 2 0) 6 'none)
               (Pieceloc (Loc 2 1) 7 'none)
               (Pieceloc (Loc 2 2) 8 'none)))
(check-expect (quad->pieceloc quad4 'SE)
              (list
               (Pieceloc (Loc 3 3) 0 'none)
               (Pieceloc (Loc 3 4) 1 (Some 'black))
               (Pieceloc (Loc 3 5) 2 (Some 'black))
               (Pieceloc (Loc 4 3) 3 (Some 'black))
               (Pieceloc (Loc 4 4) 4 (Some 'black))
               (Pieceloc (Loc 4 5) 5 'none)
               (Pieceloc (Loc 5 3) 6 (Some 'black))
               (Pieceloc (Loc 5 4) 7 'none)
               (Pieceloc (Loc 5 5) 8 'none)))

(: pieceloc->quad : (Listof Pieceloc) -> (Listof (Optional Player)))
;;Turns a list of pieceloc back into a list of optional players
;;Basically, returns the quadrant again.
(define (pieceloc->quad ploc)
  (match ploc
    ['() '()]
    [(cons (Pieceloc onb inq m) tl)
     (cons m (pieceloc->quad tl))]))
(check-expect (pieceloc->quad pieceloc1nw) quadbegin)
(check-expect (pieceloc->quad pieceloc2nw) move1white)


(: piece->quad : (Listof Piece) -> (Listof (Optional Player)))
;;Turns a list of pieces back into a list of optional players.
;;basically, returns the quadrant.
(define (piece->quad ps)
  (match ps
    ['() '()]
    [(cons (Piece c p) tl)
     (cons c (piece->quad tl))]))

(: ploc-board : Board -> (Listof Pieceloc))
;;Returns the given board as a list of pieceloc
(define (ploc-board b)
  (match b
    [(Board NW NE SW SE)
     (append (quad->pieceloc NW 'NW)
             (quad->pieceloc NE 'NE)
             (quad->pieceloc SW 'SW)
             (quad->pieceloc SE 'SE))]))

(: jumble-quads : Board -> (Listof Pieceloc))
;;returns the given board as a list of pieceloc, but jumbled.
(define (jumble-quads b)
  (match b
    [(Board NW NE SW SE)
     (append (quad->pieceloc NE 'NE)
             (quad->pieceloc NW 'NW)
             (quad->pieceloc SE 'SE)
             (quad->pieceloc SW 'SW))]))


;;=========== 4) Helper functions: Project A==============================;;
;;======================================================================= ;;

;;These are just various helper functions that made things a lot easier.
;;They do various small tasks like look through the board
;;check if things are true, etc.
;;Some functions utilize Pieceloc as a helper tool.
;;If they are specifically for a certain function, that is noted.
;;This does not include functions that search for wins.



(: in-quad? : Quadrant Loc -> Boolean) 
;;Checks whether the given location is in the given quadrant.
(define (in-quad? q l)
  (local {(define lrow (Loc-row l))
          (define lcol (Loc-col l))
          (define top (and (<= lrow 2) (>= lrow 0)))
          (define bot (and (> lrow 2) (<= lrow 5)))
          (define lft (and (<= lcol 2) (>= lcol 0)))
          (define rgt (and (> lcol 2) (<= lcol 5)))}
    (cond
      [(and (symbol=? q 'NW) top lft) #t]
      [(and (symbol=? q 'NE) top rgt) #t]
      [(and (symbol=? q 'SW) bot lft) #t]
      [(and (symbol=? q 'SE) bot rgt) #t]
      [else #f])))
(check-expect (in-quad? 'NW (Loc 0 2)) #t)
(check-expect (in-quad? 'SE (Loc 0 2)) #f)
(check-expect (in-quad? 'SE (Loc 3 5)) #t)
(check-expect (in-quad? 'SE (Loc 10 10)) #f)



(: on-board? : Loc -> Boolean)
;;Checks whether the given location is on the board.
(define (on-board? l)
  (if (not (or (in-quad? 'NW l)
               (in-quad? 'NE l)
               (in-quad? 'SW l)
               (in-quad? 'SE l))) #f #t))
(check-expect (on-board? (Loc 10 10)) #f)
(check-expect (on-board? (Loc 1 1)) #t)


(: quad? : Loc -> Quadrant)
;;Returns which quadrant the location is in
(define (quad? l)
  (cond
    [(not (on-board? l)) (error "Location off board")]
    [(in-quad? 'NW l) 'NW]
    [(in-quad? 'NE l) 'NE]
    [(in-quad? 'SW l) 'SW]
    [else 'SE]))
(check-expect (quad? [Loc 0 1]) 'NW)
(check-expect (quad? [Loc 3 1]) 'SW)
(check-expect (quad? [Loc 0 3]) 'NE)
(check-expect (quad? [Loc 3 3]) 'SE)

(: choose-quad : Board Quadrant -> (Listof (Optional Player)))
;;Returns the given quadrant of the board. 
(define (choose-quad b q)
  (match q
    ['NW (Board-NW b)]
    ['NE (Board-NE b)]
    ['SW (Board-SW b)]
    ['SE (Board-SE b)]))
(check-expect (choose-quad new-board 'NW) quad3)
(check-expect (choose-quad exboard1 'SE) quad4)



(: quad-ref : (Listof Pieceloc) Loc -> (Optional Player))
;;Iterates through the given list,
;;and returns the (Optional Player) at the given location,
;;assuming the given loc is somewhere in the list.
(define (quad-ref pcs l)
  (match pcs
    ['() (error "Location not in list")]
    [(cons (Pieceloc onb inq marble) tl)
     (if (and (= (Loc-row onb) (Loc-row l))
              (= (Loc-col onb) (Loc-col l)))
         marble
         (quad-ref tl l))]))
(check-expect (quad-ref pieceloc1ne (Loc 2 5)) 'none)
(check-expect (quad-ref pieceloc1se (Loc 3 5)) 'none)


(: loc-empty? : Board Loc -> Boolean)
;;Checks if there is already a marble in the given location.
(define (loc-empty? b l)
  (local {(define bref (board-ref b l))}
    (match bref
      ['none #t]
      [(Some Player) #f])))
(check-expect (loc-empty? new-board (Loc 3 5)) #t)
(check-expect (loc-empty? exboard1 (Loc 2 5)) #f)

(: same-player? : Player Player -> Boolean)
;;Checks if player1 is a different player than player2.
(define (same-player? p1 p2)
  (if (symbol=? p1 p2) #t #f))
(check-expect (same-player? 'black 'white) #f)
(check-expect (same-player? 'black 'black) #t)

(: opp-player : Player -> Player)
;;Returns the opposing player.
;;i.e. (opp-player 'white) => 'black
(define (opp-player p)
  (match p
    ['white 'black]
    ['black 'white]))
(check-expect (opp-player 'white) 'black)
(check-expect (opp-player 'black) 'white)


(: change-quad : Board Quadrant (Listof (Optional Player))
   -> Board)
;;Changes the given quadrant of the board to an updated quadrant.
(define (change-quad b q l)
  (match b
    [(Board NW NE SW SE)
     (match q
       ['NW (Board l NE SW SE)]
       ['NE (Board NW l SW SE)]
       ['SW (Board NW NE l SE)]
       ['SE (Board NW NE SW l)])]))

(: return-sym : (Optional Player) -> (U 'black 'white 'none))
;;Returns the symbol of an optional player
(define (return-sym p)
  (match p
    ['none 'none]
    [(Some x) x]))

(: return-loc : Pieceloc -> (U 'black 'white 'none))
;;Returns the symbol of an optional player from a Pieceloc. 
(define (return-loc p)
  (match p
    [(Pieceloc onb inq c)
     (return-sym c)]))


;; ================== SPECIFIC :PLACE MARBLE HELPERS ==================;;

(: update-location : (Listof Pieceloc) Loc Player -> (Listof Pieceloc))
;;Updates the location and player in the list of pieceloc.
;;Then can turn this back to a list of optional player.
(define (update-location ploc l p)
  (match ploc
    ['() '()]
    [(cons hd tl)
     (match hd
       [(Pieceloc onb inq marble)
        (if (and (= (Loc-row onb) (Loc-row l))
                 (= (Loc-col onb) (Loc-col l)))
            (cons (Pieceloc onb inq (Some p)) tl)
            (cons hd (update-location tl l p)))])]))
(check-expect (update-location pieceloc1nw (Loc 0 0) 'white) pieceloc2nw)




(: update-quad : (Listof Pieceloc) Loc Player -> (Listof (Optional Player)))
;;Updates the location and player in the quadrant,
;;and returns the list of optional players.
(define (update-quad ploc l p)
  (pieceloc->quad (update-location ploc l p)))
(check-expect (update-quad pieceloc1nw (Loc 0 0) 'white) move1white)
(check-expect (update-quad (quad->pieceloc quad4 'SE) (Loc 5 5) 'black)
              quad4black)


;; ====================SPECIFIC: TWIST HELPERS ==================;;

(: twist-counter : (Listof (Optional Player)) -> (Listof (Optional Player)))
;;Twists the given quadrant counterclockwise.
(define (twist-counter ps)
  (list (list-ref ps 2) (list-ref ps 5) (list-ref ps 8)
        (list-ref ps 1) (list-ref ps 4) (list-ref ps 7)
        (list-ref ps 0) (list-ref ps 3) (list-ref ps 6)))
(check-expect (twist-counter quad1) quad1counter)



(: twist-clock : (Listof (Optional Player)) -> (Listof (Optional Player)))
;;Twists the given quadrant clockwise.
(define (twist-clock ps)
  (reverse (twist-counter ps)))
(check-expect (twist-clock quad1) quad1clock)



;;=========== 6) Helper functions specifically for wins: Project A========;;
;;======================================================================= ;;


;;These helper functions deal specifically with searching for winning rows,
;;columns, and diagonals, and dealing with wins. 
;:They are separated because they mostly use my structures,
;;and may otherwise be unclear.


(: diag1-pieceloc : (Listof Pieceloc) Integer Integer -> (Listof Pieceloc))
;;Returns the diagonals from the top left to bottom right,
;;starting at the given row and column.
(define (diag1-pieceloc pcs r c)
  (match pcs
    ['() '()]
    [(cons hd tl)
     (match hd
       [(Pieceloc onb inq m)
        (if (and (= (Loc-col onb) c) (= (Loc-row onb) r))
            (cons hd (diag1-pieceloc tl (add1 r) (add1 c)))
            (diag1-pieceloc tl r c))])]))
(check-expect (diag1-pieceloc (ploc-board exboard3) 0 0) plocdiag1)

(: diag2-pieceloc : (Listof Pieceloc) Integer Integer -> (Listof Pieceloc))
;;Returns the diagonals from the top right to bottom left,
;;starting at the given row and column.
(define (diag2-pieceloc pcs r c)
  (match pcs
    ['() '()]
    [(cons hd tl)
     (match hd
       [(Pieceloc onb inq m)
        (if (and (= (Loc-col onb) c) (= (Loc-row onb) r))
            (cons hd (diag2-pieceloc tl (add1 r) (sub1 c)))
            (diag2-pieceloc tl r c))])]))
(check-expect (diag2-pieceloc (jumble-quads exboard3) 0 5) plocdiag2)
(check-expect (diag2-pieceloc (jumble-quads fullboard) 0 5)
              (list
               (Pieceloc (Loc 0 5) 2 (Some 'white))
               (Pieceloc (Loc 1 4) 4 (Some 'white))
               (Pieceloc (Loc 2 3) 6 (Some 'black))
               (Pieceloc (Loc 3 2) 2 (Some 'white))
               (Pieceloc (Loc 4 1) 4 (Some 'white))
               (Pieceloc (Loc 5 0) 6 (Some 'black))))
(check-expect (diag2-pieceloc (jumble-quads fullboard) 1 5)
              (list
               (Pieceloc (Loc 1 5) 5 (Some 'black))
               (Pieceloc (Loc 2 4) 7 (Some 'black))
               (Pieceloc (Loc 3 3) 0 (Some 'white))
               (Pieceloc (Loc 4 2) 5 (Some 'black))
               (Pieceloc (Loc 5 1) 7 (Some 'black))))

(: row-pieceloc : (Listof Pieceloc) Integer -> (Listof Pieceloc))
;;Returns the given row of pieceloc.
(define (row-pieceloc pcs r)
  (match pcs
    ['() '()]
    [(cons hd tl)
     (match hd
       [(Pieceloc onb inq m)
        (if (= (Loc-row onb) r) (cons hd (row-pieceloc tl r))
            (row-pieceloc tl r))])]))


(: col-pieceloc : (Listof Pieceloc) Integer -> (Listof Pieceloc))
;;Returns the given col of pieceloc.
(define (col-pieceloc pcs c)
  (match pcs
    ['() '()]
    [(cons hd tl)
     (match hd
       [(Pieceloc onb inq m)
        (if (= (Loc-col onb) c) (cons hd (col-pieceloc tl c))
            (col-pieceloc tl c))])]))  



(: 5-begin? : (Listof Pieceloc) Integer -> Boolean)
;;Checks if there are 5 pieces in a row,
;;starting at the beginning of the list.
(define (5-begin? pcs n)
  (cond
    [(>= n 5) #t]
    [else (match pcs
            ['() #t]
            [(cons hd1 tl1)
             (match tl1
               ['() #t]
               [(cons hd2 tl2)
                (local {(define p1 (return-loc hd1))
                        (define p2 (return-loc hd2))}
                  (cond
                    [(symbol=? p1 p2) (5-begin? tl1 (add1 n))]
                    [else #f]))])])]))

(: 5-in-row? : (Listof Pieceloc) -> Boolean)
;;Checks if there are 5 pieces in a row.
(define (5-in-row? pcs)
  (local {(define l (length pcs))
          (define rst (list-tail pcs 1))
          (define 5hd (5-begin? pcs 1))
          (define 5tl (5-begin? rst 1))}
    (cond
      [(= l 5) 5hd]
      [(and (= l 6) 5hd) 5hd]
      [(and (= l 6) (not 5hd)) 5tl]
      [else (error "List too short")])))
(check-expect (5-in-row? (diag1-pieceloc (ploc-board fullboard) 0 0)) #f)
(check-expect (5-in-row? (diag2-pieceloc (ploc-board exboard3) 0 5)) #t)
(check-expect (5-in-row? (diag2-pieceloc (jumble-quads fullboard) 1 5)) #f)
(check-expect (5-in-row? (diag1-pieceloc (ploc-board fullboard) 0 1)) #t)




(: who-won? : (Listof Pieceloc) -> (Listof Player))
;;Returns the winner if there are 5 in row.
(define (who-won? pcs)
  (if (5-in-row? pcs)
      (local {(define marble (Pieceloc-marble (list-ref pcs 3)))}
        (match marble
          ['none '()]
          [(Some x) (list x)]))
      '()))
(check-expect (who-won? (row-pieceloc pieces3 0)) (list 'white))
(check-expect (who-won? (diag2-pieceloc (ploc-board exboard3) 0 5)) (list 'black))
(check-expect (who-won? (list
                         (Pieceloc (Loc 0 4) 1 (Some 'black))
                         (Pieceloc (Loc 1 3) 3 (Some 'white))
                         (Pieceloc (Loc 2 2) 8 (Some 'black))
                         (Pieceloc (Loc 3 1) 1 (Some 'black))
                         (Pieceloc (Loc 4 0) 3 (Some 'white)))) '())
(check-expect (who-won? (diag1-pieceloc (ploc-board fullboard) 0 0)) '())
(check-expect (who-won? (diag1-pieceloc (ploc-board fullboard) 1 0)) '())
(check-expect (who-won? (diag1-pieceloc (ploc-board fullboard) 0 1)) (list 'black))
(check-expect (who-won? (diag2-pieceloc (jumble-quads fullboard)  0 5)) '())
(check-expect (who-won? (diag2-pieceloc (jumble-quads fullboard) 0 4)) '())
(check-expect (who-won? (diag2-pieceloc (jumble-quads fullboard)  1 5)) '())
(check-expect (who-won? (col-pieceloc (ploc-board exboardno) 0)) '())
(check-expect (who-won? (col-pieceloc (ploc-board exboardboth) 0)) (list 'white))
(check-expect (who-won? (col-pieceloc (ploc-board exboardboth) 2)) (list 'black))



(: pcs-full? : (Listof Pieceloc) -> Boolean)
;;Checks if the board (as pieces) is full.
(define (pcs-full? pcs)
  (match pcs
    ['() #t]
    [(cons (Pieceloc onb inq m) tl)
     (match m
       ['none #f]
       [(Some x) (if (empty? tl) #t (pcs-full? tl))])]))
(check-expect (pcs-full? (ploc-board fullboard)) #t)
(check-expect (pcs-full? (ploc-board exboard3)) #f)



(: board-full? : Board -> Boolean)
;;Checks if the board if full
(define (board-full? b)
  (local {(define pcs (ploc-board b))}
    (if (pcs-full? pcs) #t #f)))
(check-expect (board-full? fullboard) #t)
(check-expect (board-full? exboard3) #f)



(: list-winners : Board -> (Listof Player))
;;Lists the winners of the game, as 'black 'white, etc. 
(define (list-winners b)
  (local {(define pcs (ploc-board b))
          (define jpcs (jumble-quads b))
          (: row/col : Integer -> (Listof Player))
          (define (row/col i)
            (append (who-won? (col-pieceloc pcs i))
                    (who-won? (row-pieceloc pcs i))))}
    (append (who-won? (diag1-pieceloc pcs 0 0))
            (who-won? (diag1-pieceloc pcs 1 0))
            (who-won? (diag1-pieceloc pcs 0 1))
            (who-won? (diag2-pieceloc jpcs 0 5))
            (who-won? (diag2-pieceloc jpcs 0 4))
            (who-won? (diag2-pieceloc jpcs 1 5))
            (foldr (inst append Player) empty (build-list 6 row/col)))))
(check-expect (list-winners exboard3) (list 'black 'black))
(check-expect (list-winners fullboard) (list 'black 'black 'black))
(check-expect (list-winners new-board) '())
(check-expect (list-winners exboardno) '())
(check-expect (list-winners exboardboth) (list 'white 'black))


(: winner? : Game -> Boolean)
;;Checks if someone (anyone) won the game.
(define (winner? g)
  (local {(define wins (list-winners (Game-board g)))}
    (cond
      [(empty? wins) #f]
      [else #t])))
(check-expect (winner? (Game exboard3 'black 'twist)) #t)
(check-expect (winner? (Game fullboard 'white 'place)) #t)
(check-expect (winner? (Game exboardno 'black 'place)) #f)
(check-expect (winner? (Game exboardboth 'white 'twist)) #t)

(: one-winner? : (Listof Player) -> Boolean)
;;Checks if there is one winner of the game.
;;Assumes there is a winner 
(define (one-winner? b)
  (match b
    ['() #t]
    [(cons hd '()) #t]
    [(cons hd tl)
     (if (symbol=? hd (first tl)) (one-winner? tl)
         #f)]))
(check-expect (one-winner? (list-winners exboardboth)) #f)
(check-expect (one-winner? (list-winners exboard3)) #t)


;;=========== 7) FINAL functions (and helpers that need them)=============;;
;;======================================================================= ;;

;;This section includes all of the final functions, and any helpers
;;that require a final function.


;;;;=====================Part a: NEW GAME============================;;;;

(: new-game : Game)
;;The game starts with an empty board,
;;and white moves first by placing a marble.
(define new-game
  (Game new-board 'white 'place))

;;;;=====================Part b: BOARD REF============================;;;;


(: board-ref : Board Loc -> (Optional Player))
;;Returns the marble at the given square, or 'none.
(define (board-ref b l)
  (local {(define q (quad? l))
          (define bq (choose-quad b q))
          (define plq (quad->pieceloc bq q))}
    (quad-ref plq l)))
(check-expect (board-ref new-board (Loc 3 5)) 'none)
(check-expect (board-ref exboard1 (Loc 0 0)) 'none)
(check-expect (board-ref fullboard (Loc 3 1)) (Some 'black))


;;;;=====================Part C: PLACE MARBLE============================;;;;

(: place-marble : Game Player Loc -> Game)
;;Given a game, a player, and a location, place the marble to the game board,
;;and return the subsequent game state.
(define (place-marble g p l)
  (match g
    [(Game bd np na)
     (local {(define q (quad? l))
             (define bq (choose-quad bd q))
             (define plq (quad->pieceloc bq q))
             (define up (update-quad plq l p))
             (define plcmarble (change-quad bd q up))}
       
       (cond
         [(not (on-board? l))
          (error "Location off board")]
         [(not (loc-empty? bd l))
          (error "Move illegal : Location is full")]
         [(not (same-player? p np))
          (error "Move illegal : It's not your turn!")]
         [(not (symbol=? na 'place))
          (error "Move illegal : Next action is twist")]
         [else
          (Game plcmarble p 'twist)]))]))

(check-expect (place-marble new-game 'white (Loc 0 0))
              (Game move1board 'white 'twist))          
(check-error (place-marble new-game 'black (Loc 1 2))
             "Move illegal : It's not your turn!")
(check-error (place-marble new-game 'white (Loc 10 10))
             "Location off board")
(check-error (place-marble (Game move1board 'black 'place)
                           'black (Loc 0 0))
             "Move illegal : Location is full")
(check-error (place-marble (Game move1board 'black 'twist)
                           'black (Loc 1 2))
             "Move illegal : Next action is twist")
(check-expect (place-marble exgame1 'black (Loc 5 5))
              exgame1place)

;;;;=====================Part D: TWIST QUADRANT============================;;;




;;Twist one of the four quadrants either clockwise or counterclockwise,
;;and return the resulting game state.
;;Note, will update to higher order programming here for next part.
;;Was having trouble with higher order here.
(define (twist-quadrant g q d)
  (match g
    [(Game b np na)
     (local {(define newp (opp-player np))
             (define newa 'place)}
       (match b
         [(Board NW NE SW SE)
          (match d
            ['clockwise
             (match q
               ['NW (Game (Board (twist-clock NW) NE SW SE) newp newa)] 
               ['NE (Game (Board NW (twist-clock NE) SW SE) newp newa)]
               ['SW (Game (Board NW NE (twist-clock SW) SE) newp newa)]
               ['SE (Game (Board NW NE SW (twist-clock SE)) newp newa)])]
            ['counterclockwise
             (match q
               ['NW (Game (Board (twist-counter NW) NE SW SE) newp newa)]
               ['NE (Game (Board NW (twist-counter NE) SW SE) newp newa)]
               ['SW (Game (Board NW NE (twist-counter SW) SE) newp newa)]
               ['SE (Game (Board NW NE SW (twist-counter SE)) newp newa)])])]))]))
(check-expect (twist-quadrant exgame1twist 'NW 'counterclockwise)
              exgame1counter)
(check-expect (twist-quadrant exgame1twist 'NW 'clockwise)
              exgame1clock)


;;;;=====================Part E: GAME OVER????================;;;;

(: game-over? : Game -> Boolean)
;;Game is over either when a player has just placed a marble for five in a row
;;(horizontally, vertically, or diagonally),
;;a player has just twisted a quadrant for one or both (!) players to get five in a row,
;;or the board is full and there are no open spots for marbles.
(define (game-over? g)
  (match g
    [(Game bd np na)
     (cond
       [(and (symbol=? na 'twist) (board-full? bd)) #f]
       [(or (board-full? bd) (winner? g)) #t]
       [else #f])]))
(check-expect (game-over? (Game fullboard 'black 'twist)) #f)
(check-expect (game-over? (Game fullboard 'black 'place)) #t)
(check-expect (game-over? (Game exboard3 'white 'place)) #t)
(check-expect (game-over? (Game exboardboth 'white 'place)) #t)
(check-expect (game-over? (Game exboardno 'black 'place)) #t)
(check-expect (game-over? (Game new-board 'white 'place)) #f)
(check-expect (game-over? (Game move1board 'black 'place)) #f)


;;;;=====================Part F: OUTCOME================;;;;
;;=========== Part F: helper functions ============;;


(: tie? : Game -> Boolean)
;;Checks if the game is a tie.
(define (tie? g)
  (local {(define winlist (list-winners (Game-board g)))}
    (cond
      [(not (game-over? g)) (error "Game in progress")]
      [(and (game-over? g) (not (winner? g))) #t]
      [(and (game-over? g) (not (one-winner? winlist))) #t]
      [(and (game-over? g) (empty? winlist) #t)]
      [else #f])))
(check-expect (tie? (Game exboardboth 'white 'place)) #t)  
(check-expect (tie? (Game exboard3 'white 'place)) #f)
(check-error (tie? (Game new-board 'white 'place)) "Game in progress")

;;;;=====================Part F: OUTCOME================;;;;
;;=========== Part F: Final functions ============;;

(: outcome : Game -> Outcome)
;;Checks the outcome of the game.
(define (outcome g)
  (cond
    [(not (game-over? g)) (error "Game in progress")]
    [(tie? g) 'tie]
    [else
     (list-ref (list-winners (Game-board g)) 0)]))
(check-expect (outcome (Game exboardboth 'white 'place)) 'tie)
(check-error (outcome (Game new-board 'white 'place)) "Game in progress")
(check-expect (outcome (Game exboard3 'white 'place)) 'black)
(check-expect (outcome (Game exboardno 'black 'place)) 'tie)
(check-error (outcome (Game exboardno 'black 'twist)) "Game in progress")
(check-expect (outcome (Game fullboard 'white 'place))'black)
(check-expect (outcome (Game exboard4 'white 'place))'black)


;;================ 8) Drawing the Board/Game Project A====================;;
;;======================================================================= ;;

;;This part involves all the functions that drew the game/board
;;for Project A.
;;This involves my structure, Piece, to hold information for the drawing.


;;;;==================Helper functions: Drawing the board===================;;;


(: draw-piece : (Optional Player) -> Image) 
;;Draws a black piece or a white piece, of specific radius 5.
;;Will be scaled later.
(define (draw-piece p)
  (match p
    ['none (circle 5 "outline" (color 153 76 0 200))]
    [(Some 'white) (circle 5 "solid" (color 255 255 255 200))]
    [(Some 'black) (circle 5 "solid" (color 0 0 0 230))]))


(: row : Integer (Listof Piece) -> Image)
;;Takes in a given list of pieces and
;;produces a row of n of the pieces, side by side.
(define (row n ps)
  (local {(define subn (sub1 n))}
    (match ps
      ['() empty-image]
      [(cons hd tl)
       (match hd
         [(Piece c loc)
          (cond
            [(= subn 0)
             (draw-piece c)]
            [else    
             (beside (draw-piece c) (row subn tl))])])])))


(: row-from : Integer Integer (Listof Piece) -> Image)
;;Takes in a given list of pieces,
;;and produces a row of n of the pieces,
;;starting at the index i.
(define (row-from i n ps)
  (match ps
    ['() empty-image]
    [(cons hd tl)
     (match hd
       [(Piece c loc)
        (if (= i loc)
            (row n ps)
            (row-from i n tl))])]))




(: draw-quadrant : (Listof Piece) -> Image)
;;Draws the given quadrant as a 30 pixel by 30 pixel square.
(define (draw-quadrant ps)
  (match ps
    ['() empty-image]
    [_
     (overlay
      (above
       (row-from 0 3 ps)
       (row-from 3 3 ps)
       (row-from 6 3 ps))
      (square 30 "solid" (color 0 0 0 0)))]))

(: draw-label : Real Integer -> Image)
;;Takes in given number and makes it a label,
;;of given integer for height and width.
(define (draw-label l i)
  (if (or (<= i 0) (> i 255)) (error "Impossible font size")
      (text (number->string l) i "black")))


(: label-top : Real -> Image)
;;Takes in given string and makes it a label for the top.
(define (label-top i)
  (local {(define h (abs (/ i 6)))
          (define sq (square h "solid" "white"))
          (define fh (exact-floor h))}
    (beside
     (overlay (draw-label 0 fh) sq)
     (overlay (draw-label 1 fh) sq)
     (overlay (draw-label 2 fh) sq)
     (overlay (draw-label 3 fh) sq)
     (overlay (draw-label 4 fh) sq)
     (overlay (draw-label 5 fh) sq))))


(: label-side : Real -> Image)
;;Makes label for the side of a board
;;lists (0-5)
;;Note: tried to approach using higher order programming,
;;but had problematic syntax.
(define (label-side i)
  (local {(define h (abs (/ i 6)))
          (define sq (square h "solid" "white"))
          (define fh (exact-floor h))}
    (above
     sq
     (overlay (draw-label 0 fh) sq)
     (overlay (draw-label 1 fh) sq)
     (overlay (draw-label 2 fh) sq)
     (overlay (draw-label 3 fh) sq)
     (overlay (draw-label 4 fh) sq)
     (overlay (draw-label 5 fh) sq))))


(: bg-letter : String -> Image)
;;Draws the background letter for the given quad
;;QWAS
(define (bg-letter s)
  (overlay
   (text s 28 (color 153 0 0 100))
   (square 30 "outline" "black")
   (square 30 "solid" "tan")))



(: draw-quads : Board -> Image)
;;Draws the given board at a specific size (70 x 70) square.
;;This will be scaled later.
(define (draw-quads b) 
  (match b
    [(Board NW NE SW SE)
     (beside/align "bottom" (label-side 60)
                   (above (label-top 60)
                          (above (beside (overlay
                                          (draw-quadrant (make-pieces NW))
                                          (bg-letter "Q"))
                                         (overlay
                                          (draw-quadrant (make-pieces NE))
                                          (bg-letter "W")))
                                 (beside (overlay
                                          (draw-quadrant (make-pieces SW))
                                          (bg-letter "A"))
                                         (overlay
                                          (draw-quadrant (make-pieces SE))
                                          (bg-letter "S"))))))]))


(: draw-game : Game -> Image)
;;Draws the game at a specific size. 
;;This will be scaled later.
(define (draw-game g)
  (match g
    [(Game bd np na)
     (above/align "middle"
      (overlay
       (text "  PENTAGO!" 15 "black")
       (rectangle 85 20 "solid" "white"))
      (draw-quads bd)
      (overlay (beside
                (text "Next player:" 5 (color 0 0 0 150))
                (text (symbol->string np) 5 "red")
                (text "     Next action:" 5 (color 0 0 0 150))
                (text (symbol->string na) 5 "red"))
               (rectangle 85 15 "solid" "white")))]))



;;;;==================FINAL FUNCTIONS: Drawing the board===================;;;


(: board-image : Board Integer -> Image)
;;Draws the board at the specified width of the whole board image.
;;This simply includes the quadrants, not the whole game.
;;Note: empty marbles are outlined in red. 
(define (board-image b i)
  (if (<= i 0) empty-image
      (scale (/ (abs i) 70) (draw-quads b))))




(: game-image : Game Integer -> Image)
;;Draws the game at the specified width of the whole game image.
;;This contains all information, including a title,
;;the game board, and the next action and player.
;;Note: empty marbles are outlined in red.
(define (game-image g i)
  (if (<= i 0) empty-image
      (scale/xy
       (/ (abs i) 86) (/ (abs i) 86) (draw-game g))))




;;Guide to Project B
;;== 1) Structures/Type Definitions/ Required function first available
;;== 2) Higher-order/Polymorphic helpers for Project B
;;== 3) Drawing the board. 
;;== 4) Small helper functions
;;== 5) Creating the big-bang functions. 

;;=================== PROJECT B WORK!!!! ====================================;;
;;=================== ===================   ================================ ;;
;;=================== ===================   ================================ ;;


;;========= 1) Structures/Type Defintions/ Required FUNC Project B=========;;
;;======================================================================= ;;

;;These are the structures/type definitions for Project B,
;;including my world structure.

;;Note that in my world, the user enters a command,
;;this command is held in a list, which will always be at most length 2,
;;the place list will hold two strings that contain integers 0-5
;;and the twist list will hold a quadrant signified by QWAS keys
;;and a direction, signified by "left" and "right" arrows.

;;REQUIRED FUNCTION FIRST AVAILABLE IS ALSO LISTED HERE.

(define-struct Move
  ([loc : Loc]
   [q   : Quadrant]
   [dir : Direction]))

(define-type Human
  (U String Symbol))

(define-struct Bot
  ([name : (U String Symbol)]
   [mind : (Game -> (Optional Move))]))


(define-struct World
  ([game : Game]
   [enterplace : (Listof String)] ;;user types in desired location
   [entertwist : (Listof String)] ;;user types in desired twist
   [botloc : (Optional Loc)] ;;Bot location for place
   [botq : (Optional Quadrant)] ;;Bot quadrant for twist
   [botd : (Optional Direction)] ;;Bot direction for twist
   [player-white : (U Human Bot)]
   [player-black : (U Human Bot)]))


;;REQUIRED FUNCTION FIRST AVAILABLE;;;


(: first-available : Game -> (Optional Move)) ;;Do I want to include a check to see if its
;;the turn of the bot???
;;A very not smart Bot mind.
;;It will start at (0,0) then continue across the rows til it finds an open spot
;;and it will always twist the Northwest Quadrant 'clockwise.
(define (first-available g)
  (match g
    [(Game b np na)
     (if (board-full? b) 'none ;;inefficient 
         (local {(: check-space : Loc -> Loc)
                 (define (check-space l1)
                   (match l1
                     [(Loc r c)
                      (if (loc-empty? b l1) l1
                          (if (< c 5) (check-space (Loc r (add1 c)))
                              (check-space (Loc (add1 r) 0))))]))}
           (Some (Move (check-space (Loc 0 0)) 'NW 'clockwise))))]))
(check-expect (first-available new-game) (Some (Move (Loc 0 0) 'NW 'clockwise)))
(check-expect (first-available (Game fullboard 'white 'twist)) 'none)
(check-expect (first-available (Game move1board 'white 'place))
              (Some (Move (Loc 0 1) 'NW 'clockwise)))



;;; EXAMPLE WORLDS ;;;

(: world1 : World)
(define world1 (World
               (Game
                (Board
                 (list (Some 'white) (Some 'black) 'none 'none 'none 'none 'none 'none 'none)
                 '(none none none none none none none none none)
                 '(none none none none none none none none none)
                 '(none none none none none none none none none))
                'black
                'twist)
               '()
               '()
               (Some (Loc 0 1))
               'none
               'none
               'a
               'b))

(: world2 : World)
(define world2 (World
                (Game
                 (Board
                  (list 'none 'none (Some 'white) 'none 'none (Some 'black) 'none 'none 'none)
                  '(none none none none none none none none none)
                  '(none none none none none none none none none)
                  '(none none none none none none none none none))
                 'white
                 'place)
                '()
                '()
                'none
                (Some 'NW)
                (Some 'clockwise)
                'a
                'b))

(: world3 : World)
(define world3 (World
                (Game
                 (Board
                  (list (Some 'white) (Some 'white) 'none 'none 'none 'none 'none 'none 'none)
                  '(none none none none none none none none none)
                  '(none none none none none none none none none)
                  '(none none none none none none none none none))
                 'white
                 'twist)
                '()
                '()
                (Some (Loc 0 1))
                'none
                'none
                'a
                'b))

(: world4 : World)
(define world4 (World
                (Game
                 (Board
                  (list (Some 'white) (Some 'white) 'none 'none 'none 'none 'none 'none 'none)
                  '(none none none none none none none none none)
                  '(none none none none none none none none none)
                  '(none none none none none none none none none))
                 'white
                 'twist)
                (list "1" "2")
                (list "s" "left")
                'none
                'none
                'none
                'a
                'b))




;;============== 2) Higher-order/Polymorphic Helpers Project B============;;
;;======================================================================= ;;

;;These are basic higher/order / polymorphic
;;helper functions for Project B,
;;that I use within my other functions.



(: replace-at : All (A) Integer A (Listof A) -> (Listof A))
;;Uses index-map and replaces the element in the list at the given index
;;with the specified new value, leaving the rest of the list as-is;
;;the function has no effect, and no error,
;;if the index does not represent a valid index in the list.
(define (replace-at replace new as)
  (index-map
   (λ ([index : Integer]
       [a : A])
     (if (equal? replace index)
         new a))
   as))
(check-expect (replace-at 3 "B" (list "A" "B"))
              (list "A" "B"))
(check-expect (replace-at 2 "B" (list "A" "B" "C"))
              (list "A" "B" "B"))
(check-expect (replace-at 0 0 (list 1 2 3 4 5))
              (list 0 2 3 4 5))



(: index->int : Integer Integer -> Integer)
;;Multiplies the given integers together.
;;Used to check index-map.
(define (index->int i1 i2)
  (* i1 i2))
(check-expect (index->int 0 3) 0)
(check-expect (index->int 1 3) 3)
(check-expect (index->int 12 12) 144)



(: index->str : Integer String -> String)
;;Appends the given integer to the front of the given string
;;Used to "check" index-map
(define (index->str i s)
  (string-append (number->string i) s))
(check-expect (index->str 0 "A") "0A")
(check-expect (index->str 8 "008") "8008")
(check-expect (index->str 0 "MG") "0MG")



(: index-map : All (A B) (Integer A -> B) (Listof A) -> (Listof B))
;;maps over all elements of a list,
;;and calls the map function with both the value of the present element
;;and its index within the list (starting at zero for the first element).
(define (index-map f as)
  (local {(: h : All (A B) (Integer A -> B) (Listof A) Integer -> (Listof B))
          (define (h f as i)
            (match as
              ['() '()]
              [(cons hd tl)
               (cons (f i hd) (h f tl (add1 i)))]))}
    (h f as 0)))
(check-expect (index-map index->int (list 1 2 3))
              (list 0 2 6))
(check-expect (index-map index->str (list "A" "B" "C"))
              (list "0A" "1B" "2C"))
(check-expect (index-map index->int (list 1 1 1 1 1))
              (list 0 1 2 3 4))


;;========= 3) Drawing the highlighted board & Graphics Project B=========;;
;;======================================================================= ;;

;;In my drawing, I highlighted various parts of the board as the user
;;selected them. These functions help build up that highlighting.

;;I also including some graphics such as an arrow, which are
;;included here.



(: plain-row : Image)
(define plain-row (rectangle 60 10 "solid" (color 0 0 0 0)))

(: hilight-row : Image)
(define hilight-row (rectangle 60 10 "solid" (color 255 255 255 100)))

(: plain-col : Image)
(define plain-col (rectangle 10 60 "solid" (color 0 0 0 0)))

(: hilight-col : Image)
(define hilight-col (rectangle 10 60 "solid" (color 255 255 255 100)))

(: grid-rows : (Listof Image))
(define grid-rows (make-list 6 plain-row))

(: grid-cols : (Listof Image))
(define grid-cols (make-list 6 plain-col))

(: hilight-quad : Image)
(define hilight-quad (square 30 "solid" (color 255 153 153 100)))

(: plain-board : Image)
(define plain-board (square 60 "solid" (color 0 0 0 0)))

(: highlights-row : (Optional Integer) -> Image)
;;Highlights the given row in a grid of transparent rows and columns.
(define (highlights-row n)
  (match n
    ['none empty-image]
    [(Some x)
     (if (> x 5) empty-image
         (foldr above empty-image (replace-at x hilight-row grid-rows)))]))

(: highlights-col : (Optional Integer) -> Image)
;;Highlights the given col in a grid of transparent rows and columns.
(define (highlights-col n)
  (match n
    ['none empty-image]
    [(Some x)
     (if (> x 5) empty-image
         (foldr beside empty-image (replace-at x hilight-col grid-cols)))]))


(: highlighted-quad : (Optional Quadrant) -> Image)
;;These highlights the given quadrant in a light red color,
;;Or does not highlight a quadrant at all.
;;Used later in game, when user/bot types in quadrant.
(define (highlighted-quad q)
  (match q
    ['none empty-image]
    [(Some quad)
     (overlay/align
      (match quad
        ['NW "left"]
        ['NE "right"]
        ['SW "left"]
        ['SE "right"])
      (match quad
        ['NW "top"]
        ['NE "top"]
        ['SW "bottom"]
        ['SE "bottom"])
      hilight-quad
      plain-board)]))


(: highlighted-board :
   (Optional Integer) (Optional Integer) (Optional Quadrant) -> Image)
;;The first integer indicates whether a row should be highlighted
;;The second integer indicates whether a column should be highlighted.
;;The quadrant indicates whether a quadrant should be highlighted.
;;Used later in game, when user/bot types in quadrant.
(define (highlighted-board r c q)
  (overlay/align "right" "bottom"
                 (highlights-row r)
                 (highlights-col c)
                 (highlighted-quad q)
                 (square 70 "solid" (color 0 0 0 0))))



(: highlighted-game : (Optional Integer) (Optional Integer)
   (Optional Quadrant) -> Image)
;;Overlays a board with the highlighted row and column,
;;over the "game".
(define (highlighted-game r c q)
     (above/align "middle"
       (rectangle 86 20 "solid" (color 0 0 0 0))
      (highlighted-board r c q)
        (rectangle 86 15 "solid" (color 0 0 0 0))))


(: scale-highlight-game :
   (Optional Integer) (Optional Integer) (Optional Quadrant) Integer -> Image)
;; Scales the highlighted game to the given integer.
(define (scale-highlight-game r c q i)
  (if (<= i 0) empty-image
      (scale/xy
       (/ (abs i) 86) (/ (abs i) 86) (highlighted-game r c q))))


(: arrow : Image)
(define arrow
  (bitmap/file "arrow.png"))
;;;http://res.freestockphotos.biz/pictures/2/2891-illustration-of-a-red-right-arrow-pv.png
;;credit for stock arrow image

(: counter-arrow : (Optional Direction) -> Image)
;:Draws the counterclockwise arrow.
(define (counter-arrow d)
  (match d
    ['none arrow]
    [(Some 'counterclockwise)
     (overlay (rectangle 100 89 "solid" (color 255 153 153 100))
              arrow)]
    [_ arrow]))


(: clock-arrow : (Optional Direction) -> Image)
;;Draws the clockwise arrow.
(define (clock-arrow d)
  (match d
    ['none (flip-horizontal arrow)]
    [(Some 'clockwise)
     (overlay (rectangle 100 89 "solid" (color 255 153 153 100))
              (flip-horizontal arrow))]
    [_ (flip-horizontal arrow)]))



      
      


(: draw-highlights : World -> Image)
;;Draws the highlighted rows and columns as a user inputs them.
(define (draw-highlights w)
  (match w
    [(World g locs twists bl bq bd pw pb)
     (local {(define r (optional-row w))
             (define c (optional-col w))
             (define q (optional-quad w))}
     (underlay
      (game-image g 400)
      (scale-highlight-game r c q 400)))]))


(: outcome->string : World -> String)
;;Changes the outcome into a string.
(define (outcome->string w)
  (match w
    [(World g locs twists bl bq bd pw pb)
     (if (not (game-over? g)) (error "Game not over")
         (local {(define win (outcome g))}
            (match win
              ['white (string-append
                       (name->string pw)
                       " WINS!")]
              ['black (string-append
                       (name->string pb)
                       " WINS!")]
              ['tie "TIE!"])))]))
                      
                      

(: draw-outcome : World -> Image)
;;Draws the outcome of the game
;;The winners NAME in RED.
(define (draw-outcome w)
  (match w
    [(World g locs twists bl bq bd pw pb)
     (if (game-over? g)
         (local {(define msg (outcome->string w))}
             (text msg 80 (color 153 0 0 250)))
         empty-image)]))
         
(: instructions : Image)
(define instructions
  (above/align "middle"
   (text "~" 15 "black")
   (text "The goal is to get 5 of your marbles in a row! White goes first!" 15 "black")
   (text "When it's your turn, enter your move, then PRESS ENTER" 15 "black")
   (text "Use the numbers 0-5 to enter a ROW and then a COLUMN" 15 "black")
   (text "Then use the (Q W A S) keys to choose a quadrant" 15 "black")
   (text "Then press the left (<-) arrow to rotate counterclockwise. 
or the right (->) arrow to rotate clockwise"  15 "black")))

;;for some reason it auto-aligns this way
;;tabbing the last line messes up the text.

(: enter-move : World -> Image)
;;Draws the option where the user may enter a move.
(define (enter-move w)
  (match w
    [(World g locs twists bl bq bd pw pb)
       (beside
        (above
         (text "LOCATION (Row, Col): " 20 "darkgray")
         (beside
          (text (string-append (string-row locs) " ") 20 "red")
          (text (string-col locs) 20 "red")))
        (above
         (text "   TWIST (Quadrant, Direction): " 20 "darkgray")
         (beside
          (text (string-append (string-twistq twists) " ") 20 "red")
          (text (string-twistd twists) 20 "red"))))]))

(: player-indicator : World Player -> Image)
;;Indicates which player is which color.
(define (player-indicator w p)
  (match w
    [(World g locs twists bl bq bd pw pb)
     (match p
       ['white (text
                (string-append "WHITE MARBLE: "
                              (name->string pw)
                              "    ")
                20 (color 255 0 0 180))]
       ['black (text
                (string-append "BLACK MARBLE: "
                              (name->string pb))
                20 (color 155 0  0 180))])]))




;;============= 4) Small helper functions Project B=======================;;
;;======================================================================= ;;

;;These are smaller helper functions for Project B.
;;Some involve dealing with string lists, with will make sense later,
;;when used in the big bang.
;;These string lists represent what the user is typing.
;;This will deal with
;;i) general helpers
;;ii) helpers for typing places
;;iii) helpers for typing twists
;;iv) OTHER HELPERS


;;====== i) general helpers ======;;



(: name->string : (U Human Bot) -> String)
;;Converts the name of the Human or of the bot to a string.
(define (name->string p)
  (if (Bot? p)
      (match p
        [(Bot n _) (if (symbol? n) (symbol->string n) n)])
      (if (symbol? p) (symbol->string p) p)))
(check-expect (name->string 'Ariel) "Ariel")
(check-expect (name->string "Ariel") "Ariel")
(check-expect (name->string (Bot 'robo first-available)) "robo")
(check-expect (name->string (Bot "robo" first-available)) "robo")



;;====== ii) helpers for typing places ======;;
;;There will be a string of at most length 2,
;;with only "integer" strings, that represents the location
;;the user would like to input.
;;These functions help with that.



(: string->int : String -> Integer)
;;Turns the given string into an integer,
;;pretty much assumes the string is an integer.
;;Later, this will only be used for numbers 0-5.
(define (string->int s)
  (local {( define n (string->number s))}
    (if (boolean? n) (error "Not a number")
        (exact-floor (real-part n)))))
(check-expect (string->int "2") 2)
(check-expect (string->int "3") 3)
(check-expect (string->int "0") 0)      


(: 0-5? : String -> Boolean)
;:Checks if the string is in the range [0,5].
(define (0-5? s)
  (if (or
       (equal? s "0")
       (equal? s "1") ;;the higher order gods have foresaken me
       (equal? s "2")
       (equal? s "3")
       (equal? s "4")
       (equal? s "5")) #t #f))
(check-expect (0-5? "1") #t)
(check-expect (0-5? "6") #f)

;;====== iii) helpers for typing twists ======;;
;;There will be a string of at most length 2,
;;with a quadrant and then a
;;left or right string, that represents the twist
;;the user would like to input.
;;These functions help with that.
;;Note: quadrants are QWAS.


(: quadrant? : String -> Boolean)
;;Returns whether the given string could be a quadrant,
;;QWAS or qwas.
;;This will make sure that the only thing that is saved,
;;is the quadrant the user types in later.
(define (quadrant? s)
  (if (or (string=? s "q") (string=? s "w")
          (string=? s "a") (string=? s "s")
          (string=? s "Q") (string=? s "W")
          (string=? s "A") (string=? s "S")) #t #f))
(check-expect (quadrant? "q") #t)
(check-expect (quadrant? "A") #t)
(check-expect (quadrant? "b") #f)



(: dir? : String -> Boolean)
;;Returns whether the given string could be a direction,
;;only the left and right arrow keys can be a direction.
;;This will make sure that the only thing that is saved,
;;is the direction the user types in later.
(define (dir? s)
  (if (or (string=? s "left") (string=? s "right")) #t #f))
(check-expect (dir? "left") #t)
(check-expect (dir? "right") #t)
(check-expect (dir? "k") #f)


(: string->quad : String -> Quadrant)
;;Returns which quadrant the string represents.
;;Had difficulty with higher order here.
(define (string->quad s)
  (cond
    [(or (string=? s "q") (string=? s "Q")) 'NW]
    [(or (string=? s "w") (string=? s "W")) 'NE]
    [(or (string=? s "a") (string=? s "A")) 'SW]
    [(or (string=? s "s") (string=? s "S")) 'SE]
    [else (error "Cannot be a quadrant")]))
(check-expect (string->quad "q") 'NW)
(check-expect (string->quad "Q") 'NW)
(check-expect (string->quad "A") 'SW)
(check-error (string->quad "B") "Cannot be a quadrant")



(: string->dir : String -> Direction)
;;Returns which direction the string represents.
;;"left" is counterclockwise
;;"right" is clockwise.
(define (string->dir s)
  (cond
    [(string=? s "left") 'counterclockwise]
    [(string=? s "right") 'clockwise]
    [else (error "Cannot be a direction")]))
(check-expect (string->dir "left") 'counterclockwise)
(check-expect (string->dir "right") 'clockwise)
(check-error (string->dir "r") "Cannot be a direction")

(: string->arrow : String -> String)
(define (string->arrow s)
  (cond
    [(string=? s "left") "<-"]
    [(string=? s "right") "->"]
    [else (error "Cannot be a direction")]))
(check-expect (string->arrow "left") "<-")
(check-expect (string->arrow "right") "->")
(check-error (string->arrow "r") "Cannot be a direction")


;;;====== iv) OTHER HELPERS =======;;
;;These do various string conversions, etc.


(: string-twistq : (Listof String) -> String)
;;Takes in the given list of string, assuming it contains
;;the twist entered by the user:
;;nothing, a quadrant, or a quadrant and direction.
;:Returns the string of the quadrant, or the blank string. 
(define (string-twistq twists)
  (match twists
    ['() ""]
    [(cons hd tl)
     (string-append
                    hd
                    " ("
                    (symbol->string (string->quad hd))
                    ")")]))
(check-expect (string-twistq (list "q" "left")) "q (NW)")
(check-expect (string-twistq (list "A")) "A (SW)")
(check-expect (string-twistq '()) "")

(: string-twistd : (Listof String) -> String)
;;Takes in the given list of string, assuming it contains
;;the twist entered by the user:
;;nothing, a quadrant, or a quadrant and direction.
;:Returns the string of the direction, or the blank string.
(define (string-twistd twists)
  (match twists
    ['() ""]
    [(cons hd '()) ""]
    [(cons hd tl)
     (string-append
                    (string->arrow (first tl))
                    " ("
                    (symbol->string (string->dir (first tl)))
                    ")")]))
(check-expect (string-twistd (list "q" "left")) "<- (counterclockwise)")
(check-expect (string-twistd (list "A")) "")
(check-expect (string-twistd '()) "")



(: string-row : (Listof String) -> String)
;;Takes in the given list of string, assuming it contains
;;the location entered by the user:
;;nothing, a row, or a row and a column.
;:Returns the string of the row, or the blank string if empty.
(define (string-row locs)
  (match locs
    ['() ""]
    [(cons hd tl) hd]))
(check-expect (string-row (list "1" "2")) "1")
(check-expect (string-row (list "2")) "2")
(check-expect (string-row '()) "")

(: string-col : (Listof String) -> String)
;;Takes in the given list of string, assuming it contains
;;the location entered by the user:
;;nothing, a row, or a row and a column.
;:Returns the string of the row, or the blank string if empty.
(define (string-col locs)
  (match locs
    ['() ""]
    [(cons hd '()) ""]
    [(cons hd tl)
     (first tl)]))
(check-expect (string-col (list "1" "2")) "2")
(check-expect (string-col (list "2")) "")
(check-expect (string-col '()) "")


(: optional-row-human : (Listof String) -> (Optional Integer))
;;Takes in the strings that represent the location inputted by the user,
;;and returns this as an optional row.
;;Assumes list of length 2, since this is all user can input.
(define (optional-row-human ks)
  (if (< 2 (length ks)) (error "list should be at most length 2")
      (match ks
        ['() 'none]
        [(cons hd tl) (Some (string->int hd))])))
(check-expect (optional-row-human (list "1" "2"))
              (Some 1))
(check-expect (optional-row-human (list "2"))
              (Some 2))
(check-expect (optional-row-human '())
              'none)
(check-error (optional-row-human (list "1" "2" "3"))
              "list should be at most length 2")

(: optional-col-human : (Listof String) -> (Optional Integer))
;;Takes in the strings that represent the location inputted by the user,
;;and returns this as an optional column.
;;Assumes list of length 2, since this is all user can input.
(define (optional-col-human ks)
  (if (< 2 (length ks)) (error "list should be at most length 2")
      (match ks
        ['() 'none]
        [(cons hd '()) 'none]
        [(cons hd tl) (Some (string->int (first tl)))])))
(check-expect (optional-col-human (list "1" "2"))
              (Some 2))
(check-expect (optional-col-human (list "1"))
              'none)
(check-expect (optional-col-human '())
              'none)
(check-error (optional-col-human (list "1" "2" "3"))
              "list should be at most length 2")



(: optional-quad-human : (Listof String) -> (Optional Quadrant))
;;Takes in the strings that represent the "twist"
;;inputted by the user
;;and returns this as an optional quadrant.
;;Assumes list at most length 2,
;;sicne this is all user can input.
(define (optional-quad-human ks)
  (if (< 2 (length ks)) (error "list should be at most length 2")
      (match ks
        ['() 'none]
        [(cons hd tl) (Some (string->quad hd))])))
(check-expect (optional-quad-human (list "w" "right"))
              (Some 'NE))
(check-expect (optional-quad-human (list "w"))
              (Some 'NE))
(check-expect (optional-quad-human '())
              'none)
(check-error (optional-quad-human (list "w" "w" "w"))
              "list should be at most length 2")





(: optional-dir-human : (Listof String) -> (Optional Direction))
;;Takes in the strings that represent the "twist"
;;inputted by the user
;;and returns this as an optional direction.
;;Assumes list at most length 2,
;;since this is all user can input.
(define (optional-dir-human ks)
  (if (< 2 (length ks)) (error "list should be at most length 2")
      (match ks
        ['() 'none]
        [(cons hd '()) 'none]
        [(cons hd tl) (Some (string->dir (first tl)))])))
(check-expect (optional-dir-human (list "q" "left"))
              (Some 'counterclockwise))
(check-expect (optional-dir-human (list "w" "right"))
              (Some 'clockwise))
(check-expect (optional-dir-human (list "w"))
              'none)
(check-expect (optional-dir-human '())
              'none)
(check-error (optional-dir-human (list "w" "w" "w"))
              "list should be at most length 2")

                             
(: optional-dir : World -> (Optional Direction))
;;Considers the direction inputted
;;by either the bot or the human.
(define (optional-dir w)
  (match w
    [(World _ _ twists _ _ bd pw pb)
     (match bd
       [(Some dir) bd]
       [_ (optional-dir-human twists)])]))
(check-expect (optional-dir world3) 'none)
(check-expect (optional-dir world4) (Some 'counterclockwise))
(check-expect (optional-dir world2) (Some 'clockwise))


(: optional-quad : World -> (Optional Quadrant))
;;Considers the quadrant inputted
;;by either the bot or the human
(define (optional-quad w)
    (match w
      [(World _ _ twists _ bq _ pw pb)
       (match bq
         [(Some qd) bq]
         [_ (optional-quad-human twists)])]))
(check-expect (optional-quad world3) 'none)
(check-expect (optional-quad world4) (Some 'SE))
(check-expect (optional-quad world2) (Some 'NW))


(: optional-row : World -> (Optional Integer))
;;Considers the row inputted
;;by either the bot or the human
(define (optional-row w)
  (match w
    [(World _ locs _ bl _ _ _ _)
     (match bl
       [(Some loc) (Some (Loc-row loc))]
       [_ (optional-row-human locs)])]))
(check-expect (optional-row world3) (Some 0))
(check-expect (optional-row world2) 'none)
(check-expect (optional-row world4) (Some 1))

(: optional-col : World -> (Optional Integer))
;;Considers the row inputted
;;by either the bot or the human
(define (optional-col w)
  (match w
    [(World _ locs _ bl _ _ _ _)
     (match bl
       [(Some loc) (Some (Loc-col loc))]
       [_ (optional-col-human locs)])]))
(check-expect (optional-col world3) (Some 1))
(check-expect (optional-col world2) 'none)
(check-expect (optional-col world4) (Some 2))


;;================ 5) CREATING THE BIG BANG FUNCTIONS Project B===========;;
;;======================================================================= ;;

;;These show how I created my bigbang functions.
;;It will be
;;handle-key, then handle-tick, then stop-when, then draw.



;;================ HANDLE KEY Project B===========;;

;;These deal with how to handle the keys.
;;The user is able to backspace, and only enters their place/twist
;;when they hit enter.


(: handle-backspace : (Listof String) -> (Listof String))
;;Handles if the user enters a backspace.
;;This will be used in the handle-key function.
;;Assumes the list is at most length 2,
;;since this is what will be used in
;;handle-key.
(define (handle-backspace ks)
  (if (< 2 (length ks))
      (error "list shouldn't be longer than 2")
      (match ks
        ['() '()]
        [(cons hd '()) '()]
        [(cons hd tl) (list hd)]))) ;;list will always be length 2
(check-expect (handle-backspace (list "1" "2")) (list "1"))
(check-expect (handle-backspace (list "1")) '())
(check-expect (handle-backspace '()) '())
(check-error (handle-backspace (list "1" "2" "3"))
             "list shouldn't be longer than 2")



(: handle-twists : World String -> World)
;;Handles if the user is entering a quadrant and twist direction,
;;in that order.
;;If the turn is not "twist", it will ignore this function.
;;User is also able to backspace.
(define (handle-twists w s)
  (match w
    [(World g locs twists bl bq bd pw pb)
     (match g
       [(Game _ _ 'place) w]
       [(Game b np 'twist)
        (cond
          [(string=? "\b" s)
           (World g locs (handle-backspace twists) bl bq bd pw pb)]
          [(and (quadrant? s) (empty? twists))
           (World g locs (list s) bl bq bd pw pb)] ;;make more helpers
          [(and (dir? s) (= 1 (length twists)))
           (World g locs (append twists (list s)) bl bq bd pw pb)]
          [(and (string=? "\r" s) (= 2 (length twists))) ;;handles if you press the enter key
           (World (twist-quadrant g (string->quad (first twists))
                                  (string->dir (second twists)))
                  locs '() bl bq bd pw pb)]
          [else w])])]))
(check-expect (handle-twists
               (World exgame1twist '() (list "q" "left") 'none 'none 'none 'a 'b) "\r")
              (World exgame1counter '() '() 'none 'none 'none 'a 'b))
(check-expect (handle-twists
               (World exgame1twist '() (list "q")'none 'none 'none 'a 'b) "\r")
              (World exgame1twist '() (list "q") 'none 'none 'none 'a 'b))
(check-expect (handle-twists
               (World exgame1twist '() '() 'none 'none 'none 'a 'b) "1")
              (World exgame1twist '() '() 'none 'none 'none 'a 'b))
(check-expect (handle-twists
               (World exgame1twist '() (list "q") 'none 'none 'none 'a 'b) "left")
              (World exgame1twist '() (list "q" "left") 'none 'none 'none 'a 'b))



(: handle-locs : World String -> World)
;;Handles if the user is entering a location (two integer keys),
;;row then column, and hit enter.
;;If the turn is not "place", it will ignore this function.
;;User is also able to backspace.
(define (handle-locs w s)
  (match w
    [(World g locs twists bl bq bd pw pb)
     (match g
       [(Game _ _ 'twist) w]
       [(Game b np 'place)
        (cond
          [(string=? "\b" s)
           (World g (handle-backspace locs) twists bl bq bd pw pb)]
          [(and (0-5? s) (empty? locs))
           (World g (list s) twists bl bq bd pw pb)]
          [(and (0-5? s) (= 1 (length locs)))
           (World g (append locs (list s)) twists bl bq bd pw pb)]
          [(and (string=? "\r" s) (= 2 (length locs)))
           (local {(define place (Loc (string->int (first locs)) ;;;make more helpers
                                      (string->int (second locs))))}
             (if (and (on-board? place) (loc-empty? b place))
                 (World (place-marble g np place) '() twists bl bq bd pw pb)
                 (World g '() twists bl bq bd pw pb)))]
          [else w])])]))
(check-expect (handle-locs
               (World new-game (list "0" "0") '() 'none 'none 'none 'a 'b) "\r")
              (World (Game move1board 'white 'twist) '() '()'none 'none 'none 'a 'b))              
(check-expect (handle-locs
               (World exgame1twist '() (list "q" "left") 'none 'none 'none 'a 'b) "\r")
              (World exgame1twist '() (list "q" "left") 'none 'none 'none 'a 'b))        
(check-expect (handle-locs
               (World new-game (list "0") '() 'none 'none 'none 'a 'b) "7")
              (World new-game (list "0") '() 'none 'none 'none 'a 'b))
(check-expect (handle-locs
               (World new-game '() '() 'none 'none 'none 'a 'b) "0")
              (World new-game (list "0") '() 'none 'none 'none 'a 'b))
(check-expect (handle-locs
               (World new-game (list "0") '() 'none 'none 'none 'a 'b) "1")
              (World new-game (list "0" "1") '() 'none 'none 'none 'a 'b))
     

(: handle-key : World String -> World) 
;;Handles user input
;;for place and twist.
;;They may enter two keys for each, then press enter.
;;They may also use backspace.
(define (handle-key w s)
  (match w
    [(World g locs twists bl bq bd pw pb)
     (match g
       [(Game b np 'place)
        (handle-locs w s)]
       [(Game b np 'twist)
        (handle-twists w s)])]))
(check-expect (handle-key
               (World new-game (list "0" "0") '() 'none 'none 'none 'a 'b) "\r")
              (World (Game move1board 'white 'twist) '() '() 'none 'none 'none 'a 'b))
(check-expect (handle-key
               (World exgame1twist '() (list "q" "left") 'none 'none 'none 'a 'b) "\r")
              (World exgame1counter '() '() 'none 'none 'none 'a 'b))
(check-expect (handle-key
               (World new-game '() '() 'none 'none 'none 'a 'b) "q")
              (World new-game '() '() 'none 'none 'none 'a 'b))
(check-expect (handle-key
               (World (Game move1board 'black 'place) (list "0" "0")
                      '() 'none 'none 'none 'a 'b) "\r")
              (World (Game move1board 'black 'place) '() '() 'none 'none 'none 'a 'b))


;;================ HANDLE TICK Project B===========;;

;;I used four different handle-ticks, depending on how many bots
;;or humans there are.



(: handle-tick0 : World -> World)
;;Deals with input if both are human.
;;Turns are only made using keys.
(define (handle-tick0 w) w)
(check-expect (handle-tick0 world1)
              world1)
(check-expect (handle-tick0 world2)
              world2)
(check-expect (handle-tick0 world3)
              world3)

(: botA : Bot)
(define botA (Bot 'a first-available))

(: handle-tick1 : World -> World)
;;Deals with the input if bot is white, and human is black
(define (handle-tick1 w)  
  (match w
    [(World g ps rs bl bq bd pw pb)
     (match pw
       [(Bot name mind)
        (match (mind g)
         ['none (World g ps rs 'none 'none 'none pw pb)] ;;should this finish the game?
         [(Some (Move loc q dir))
          (match g
            [(Game _ 'white 'place)
             (World (place-marble g 'white loc) ps rs (Some loc) 'none 'none pw pb)]
            [(Game _ 'white 'twist)
             (World (twist-quadrant g q dir) ps rs 'none (Some q) (Some dir) pw pb)]
            [(Game _ _ _)
             (World g ps rs 'none 'none 'none pw pb)])])]
       [_ w])]))
(check-expect (World-game (handle-tick1
               (World
                (Game move1board 'black 'place)
                '() '() 'none 'none 'none (Bot 'a first-available) 'b)))
                (Game move1board 'black 'place))
(check-expect (World-game (handle-tick1
               (World
                (Game move1board 'white 'place)
                '() '() 'none 'none 'none (Bot 'a first-available) 'b)))
              (World-game world3))
(check-expect (World-game (handle-tick1 (World
                             (Game move1board 'black 'place)

                             '() '() 'none 'none 'none (Bot 'a first-available) 'b)))
               (Game move1board 'black 'place))
;(check-expect (World-game (tickall (World
;                                    (Game
;                                     (Board1
;                                     'white
;                                     'place)
;                                    500
;                                    15
;                                    15
;                                    (Bot 'a first-available)
;                                    ''yougotthisariel!)))              
(: handle-tick2 : World -> World)
;;Deals with the input if bot is black, and human is white.
(define (handle-tick2 w) 
  (match w
    [(World g ps rs bl bq bd pw pb)
     (match pb
       [(Bot name mind)
        (match (mind g)
         ['none (World g ps rs 'none 'none 'none pw pb)] ;;should this finish the game?
         [(Some (Move loc q dir))
          (match g
            [(Game _ 'black 'place)
             (World (place-marble g 'black loc) ps rs (Some loc) 'none 'none pw pb)]
            [(Game _ 'black 'twist)
             (World (twist-quadrant g q dir) ps rs 'none (Some q) (Some dir) pw pb)]
            [(Game _ _ _)
             (World g ps rs 'none 'none 'none pw pb)])])]
       [_ w])]))
(check-expect (World-game
               (handle-tick2
                (World
                (Game move1board 'black 'place)
                '() '() 'none 'none 'none 'a (Bot 'b first-available))))
               (World-game world1))
(check-expect (World-game
               (handle-tick2
               (World
                (Game move1board 'white 'place)
                '() '() 'none 'none 'none 'a (Bot 'a first-available))))
                (Game move1board 'white 'place))
               


(: handle-tick3 : World -> World)
;;Deals with the input if bots are both black and white.
(define (handle-tick3 w)  
  (match w
    [(World g ps rs bl bq bd pw pb)
     (match g
       [(Game _ 'black _)
        (handle-tick2 w)]
       [(Game _ 'white _)
        (handle-tick1 w)]
       [(Game _ _ _) w])]))
(check-expect (World-game
               (handle-tick3
               (World
                (Game move1board 'black 'place)
                '() '() 'none 'none 'none (Bot 'a first-available)
                (Bot 'b first-available))))
              (World-game world1))
(check-expect (World-game
               (handle-tick3
               (World
                (Game
                 (Board
                  (list
                   (Some 'white) (Some 'black)
                        'none 'none 'none 'none 'none 'none 'none)
                  '(none none none none none none none none none)
                  '(none none none none none none none none none)
                  '(none none none none none none none none none))
                 'black
                 'twist)
                '()
                '()
                (Some (Loc 0 1))
                'none
                'none
                (Bot 'a first-available)
                (Bot 'b first-available))))
               (World-game world2))
(check-expect (World-game
               (handle-tick3
               (World
                (Game move1board 'white 'place)
                '() '() 'none 'none 'none (Bot 'a first-available)
                (Bot 'b first-available))))
              (World-game world3))

;;================ STOP WHEN Project B===========;;

(: stop-game : World -> Boolean)
;;Stops the game when the game is over.
(define (stop-game w)
  (match w
    [(World g ps ts bl bq bd pw pb)
     (if (game-over? g) #t #f)]))


;;================ DRAW FUNCTION Project B===========;;

(: draw-pentago : World -> Image)
(define (draw-pentago w)
  (match w
    [(World g locs twists bl bq bd pw pb)
     (local {(define dir (optional-dir w))}
      (above/align "middle"
                   (overlay
                    (draw-outcome w)
                    (beside
                     (counter-arrow dir)
                     (draw-highlights w)
                     (clock-arrow dir)))
                   (beside (player-indicator w 'white)
                           (player-indicator w 'black))
                    instructions
                    (enter-move w)))]))






;;Guide to Project C
;;== 1) Definitions/ Structs/ Etc
;;== 2) Higher order Helpers
;;== 3) Heuristic Helpers
;;== 4) "Putting the pieces together" helpers
;;== 5) FINAL Heuristic Functions
;;== 6) FINAL "Putting the pieces together"
;;== 7) Pentago


;; ~~ NOTE: ALWAYS CALL WHITE FIRST FOR PENTAGO ~~~
;;=================== PROJECT C WORK!!!! ====================================;;
;;=================== ===================   ================================ ;;
;;=================== ===================   ================================ ;;

;;================ 1) DEFINITIONS/STRUCTS Project C ======================;;
;;========================================================================;;

;; This includes the type Heuristic and some pre-defined definitions
;; that I created for project C.

(define-type Heuristic
  (Player Board -> Integer))


(: 1st : (Optional Move))
(define 1st (Some (Move (Loc 0 0) 'NW 'clockwise)))


;;================ 2) HIGHER-ORDER HELPERS Project C =====================;;
;;========================================================================;;

;;Higher order helper functions used in part C.

(: list-max : (Listof Integer) -> Integer)
(define (list-max ns)
   (match ns
	['() (error "undefined")]
	[(cons hd '()) hd]
	[(cons hd tl)
	 (local {(define m (list-max tl))}
		(if (> hd m) hd m))]))

(: findfirst : All (A) (A -> Boolean) (Listof A) -> (Optional A))
;;Find the first item in the list that passes the test,
;;if one exists.
;;Returns the index of that item.
(define (findfirst f as)
  (local {(define l (length as))
          (: index :
             (Listof A) Integer -> (Optional A))
          ;;Finds the location of the first item that
          ;;passes the test
          (define (index acs i)
            (match acs
              ['() 'none]
              [(cons hd tl)
               (cond
                 [(= i (sub1 l)) 'none]
                 [(f hd) (Some hd)]
                 [else
                  (index tl (add1 i))])]))}
    (index as 0)))
(check-expect (findfirst even? (list 1 4 5 8 10)) (Some 4))
(check-expect (findfirst even? (list 1 3 5 7)) 'none)
(check-expect (findfirst negative? (list -1 -2 -3 0 1 2 3)) (Some -1))
                    


;;================ 3) HEURISTIC HELPERS Project C =====================;;
;;=====================================================================;;

;;These are helper functions used in the Heuristic functions
;;created later on.
;;Some of these pieceloc, which is a struct I created,
;;

(: run? : (Listof Pieceloc) Player -> Integer)
;:Checks the run for the given player in the given list
;;This list could be a row, column, diagonal, etc.
;;Only checks 5 places
(define (run? pcs p)
  (local {(: add-run : (Listof Pieceloc) Integer
             Integer -> Integer)
          ;;Counts the number of that player in the
          ;;given list.
          (define (add-run ps i runs)
            (cond
              [(>= i 5) runs]
              [else
               (match ps
                 ['() runs]
                 [(cons hd tl)
                  (local {(define p1 (return-loc hd))}
                  (cond
                    [(symbol=? p1 (opp-player p))
                     0]
                    [(symbol=? p1 p)
                      (add-run tl (add1 i) (add1 runs))]
                    [else
                      (add-run tl (add1 i) runs)]))])]))}
    (add-run pcs 0 0)))
(check-expect (run? plocdiag1 'white) 0)
(check-expect (run? plocdiag2 'black) 5)
(check-expect (run? plocdiag1 'black) 5)
(check-expect (run? plocdiag2.2 'black) 0)





(: list-runs? : (Listof Pieceloc) Player -> (Listof Integer))
;;Lists the runs for a given row/column.
(define (list-runs? pcs p)
  (local {(define l (length pcs))
          (define rst (rest pcs))
          (define rhd (run? pcs p))
          (define rtl (run? rst p))}
    (cond
      [(= l 5) (list rhd)]
      [(= l 6) (list rhd rtl)]
      [else (error "List too short")])))
(check-expect (list-runs? plocdiag2.2 'black)
              (list 0))
(check-expect (list-runs? plocdiag2 'black)
              (list 5 4))
(check-expect (list-runs? plocdiag1 'white)
              (list 0 0))




(: all-runs : Player Board -> (Listof Integer))
;;Lists all of the runs for the given player.
(define (all-runs p b)
  (local {(define pcs (ploc-board b))
          (define jpcs (jumble-quads b))
          (: row/col : Integer -> (Listof Integer))
          (define (row/col i)
            (append (list-runs? (col-pieceloc pcs i) p)
                    (list-runs? (row-pieceloc pcs i) p)))}
    (append (list-runs? (diag1-pieceloc pcs 0 0) p)
            (list-runs? (diag1-pieceloc pcs 1 0) p)
            (list-runs? (diag1-pieceloc pcs 0 1) p)
            (list-runs? (diag2-pieceloc jpcs 0 5) p)
            (list-runs? (diag2-pieceloc jpcs 0 4) p)
            (list-runs? (diag2-pieceloc jpcs 1 5) p)
            (foldr (inst append Integer) empty (build-list 6 row/col)))))
(check-expect (all-runs 'white new-board)
              (list 0 0 0 0 0 0 0 0 0 0 0 0
                    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))
(check-expect (all-runs 'black exboard1)
              (list 0 0 0 3 0 0 0 2 0 0 0 0 0
                    0 0 0 0 0 3 3 0 0 1 2 0 0 2 2 0 3 1 1))
(check-expect (all-runs 'black exboard5)
              (list 0 0 0 3 0 0 0 0 0 0 0 0 0
                    0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 5 0 0))
            

;;========= 4) "Putting the pieces together" helpers Project C ========;;
;;=====================================================================;;

;;These are helper functions used to create the
;; "putting the pieces together" functions for make-mind.

(: all-locs : Player Board -> (Listof Loc))
;:Returns the list of all open locations.
(define (all-locs p b)
  (local {(: list-locs : (Listof Loc) Integer Integer
             -> (Listof Loc))
          ;;checks if the spaces are available.
          (define (list-locs ls r c)
            (local {(define l (Loc r c))}
                  (cond
                    [(or (> r 5) (> c 5)) (append ls '())]
                    [(loc-empty? b l)
                     (if (< c 5) (list-locs (cons l ls)
                                             r (add1 c))
                         (list-locs (cons l ls)
                                     (add1 r) 0))]
                    [else
                     (if (< c 5) (list-locs ls
                                             r (add1 c))
                         (list-locs ls
                                     (add1 r) 0))])))}
    (list-locs '() 0 0)))
(check-expect (all-locs 'white fullboard) '())
(check-expect (all-locs 'black exboard7)
              (list (Loc 4 1)))
(check-expect (all-locs 'black exboard6)
              (list (Loc 5 5)))

(: place-win : Player Board -> (Optional Loc))
;;Checks if you can place a marble down and when
;;returns 'none if not.
;;Choose the place based on preference to row then column
(define (place-win p b)
  (local {(define locs (all-locs p b))}
    (findfirst
             (λ ([ x : Loc])
                  (winner? (place-marble
                                (Game b p 'place) p x))) locs)))
(check-expect (place-win 'white exboard1) (Some (Loc 1 2)))
(check-expect (place-win 'white exboard2) (Some (Loc 1 2)))
(check-expect (place-win 'black exboard2) (Some (Loc 4 5)))
(check-expect (place-win 'black fullboard) 'none)
(check-expect (place-win 'white move1board) 'none)




(: twist-win : Player Board -> (Optional Move))
;;Checks if you can place and twist into a win.
;;returns 'none if not.
(define (twist-win p b)
  (local {(define mvs (all-possible p b))}
    (findfirst
     (λ ([ x : Move])
       (match x
         [(Move loc q dir)
          (winner? (twist-quadrant (place-marble
                    (Game b p 'place) p loc) q dir))]))
     mvs)))
(check-expect (twist-win 'white exboardno) 'none)
(check-expect (twist-win 'black exboardcount)
              (Some (Move (Loc 2 0) 'NW 'counterclockwise)))
(check-expect (twist-win 'black exboardclock)
              (Some (Move (Loc 0 2) 'NW 'clockwise)))



;;============== 5) FINAL HEURISTIC FUNCTIONS Project C ===============;;
;;=====================================================================;;
;;Final Heuristic functions for Project C.



(: long-run : Heuristic)
;;Finds the longest run of the list.
(define (long-run p b)
  (list-max (all-runs p b)))
(check-expect (long-run 'black exboard3)
              5)
(check-expect (long-run 'white exboard1)
              4)
(check-expect (long-run 'white exboard3)
              0)
(check-expect (long-run 'black exboard5)
              5)
(check-expect (long-run 'white new-board)
              0)


(: sum-squares : Heuristic)
;;the sum of the squares of all runs on the board
(define (sum-squares p b)
  (foldr
   (λ ([ r1 : Integer]
       [ r2 : Integer])
     (+ (sqr r1) r2)) 0 (all-runs p b)))
(check-expect (sum-squares 'white move1board) 3)
(check-expect (sum-squares 'white exboard1) 18)
(check-expect (sum-squares 'black exboard1) 55)
(check-expect (sum-squares 'black new-board) 0)



(: long-run-difference : Heuristic)
;;compute the long run for the current player
;;minus the long run of the opponent
(define (long-run-difference p b)
  (- (long-run p b) (long-run (opp-player p) b)))
(check-expect (long-run-difference 'black new-board)
              0)
(check-expect (long-run-difference 'black exboard6)
              5)
(check-expect (long-run-difference 'black exboardno)
              0)





(: sum-squares-difference : Heuristic)
;;compute the sum-squares of the
;;current player minus the sum-squares of the opponent
(define (sum-squares-difference p b)
  (- (sum-squares p b) (long-run (opp-player p) b)))
(check-expect (sum-squares-difference 'black exboard6)
              157)
(check-expect (sum-squares-difference 'white exboard2)
              14)
(check-expect (sum-squares-difference 'white new-board)
              0)




;;========= 6) FINAL "PUTTING TOGETHER" FUNCTIONS Project C ===========;;
;;=====================================================================;;
;;Final putting stuff together functions for Project C.



(: direct-win : Player Board -> (Optional (U Loc Move)))
;;Checks if there is a directwin
(define (direct-win p b)
  (match (place-win p b)
    ['none (twist-win p b)]
    [x x]))
(check-expect (direct-win 'white exboard1) (Some (Loc 1 2)))
(check-expect (direct-win 'white exboard2) (Some (Loc 1 2)))
(check-expect (direct-win 'black exboard2) (Some (Loc 4 5)))


(: all-possible : Player Board -> (Listof Move))
;;Return the list of all possible moves from the current board.
;;The length of this list will be 8 times the number of empty spaces on the board.
(define (all-possible p b)
  (local {(: list-moves : (Listof Move) Integer Integer -> (Listof Move))
          ;;checks if the spaces are available
          ;;first argument is the list of moves,
          ;;second argument is row
          ;;third is column.
          (define (list-moves mvs r c)
            (local {(define l (Loc r c))
                    (define newmvs
                      (list
                       (Move l 'NW 'clockwise)
                       (Move l 'NW 'counterclockwise)
                       (Move l 'NE 'clockwise)
                       (Move l 'NE 'counterclockwise)
                       (Move l 'SW 'clockwise)
                       (Move l 'SW 'counterclockwise)
                       (Move l 'SE 'clockwise)
                       (Move l 'SE 'counterclockwise)))}
                  (cond
                    [(or (> r 5) (> c 5)) (append mvs '())]
                    [(loc-empty? b (Loc r c))
                     (if (< c 5) (list-moves (append mvs newmvs)
                                             r (add1 c))
                         (list-moves (append mvs newmvs)
                                     (add1 r) 0))]
                    [else
                     (if (< c 5) (list-moves mvs
                                             r (add1 c))
                         (list-moves mvs
                                     (add1 r) 0))])))}
    (list-moves '() 0 0)))
(check-expect (all-possible 'white fullboard)
              '())
(check-expect (all-possible 'black exboard6)
              (list
               (Move (Loc 5 5) 'NW 'clockwise)
               (Move (Loc 5 5) 'NW 'counterclockwise)
               (Move (Loc 5 5) 'NE 'clockwise)
               (Move (Loc 5 5) 'NE 'counterclockwise)
               (Move (Loc 5 5) 'SW 'clockwise)
               (Move (Loc 5 5) 'SW 'counterclockwise)
               (Move (Loc 5 5) 'SE 'clockwise)
               (Move (Loc 5 5) 'SE 'counterclockwise)))
(check-expect (all-possible 'white exboard7)
              (list
               (Move (Loc 4 1) 'NW 'clockwise)
               (Move (Loc 4 1) 'NW 'counterclockwise)
               (Move (Loc 4 1) 'NE 'clockwise)
               (Move (Loc 4 1) 'NE 'counterclockwise)
               (Move (Loc 4 1) 'SW 'clockwise)
               (Move (Loc 4 1) 'SW 'counterclockwise)
               (Move (Loc 4 1) 'SE 'clockwise)
               (Move (Loc 4 1) 'SE 'counterclockwise)))

             



(: make-mind : Player Heuristic -> (Game -> (Optional Move)))
;;Constructs a function that,
;;if a direct win is available, choose that,
;;otherwise, uses the given heuristic to choose one of the best possible moves
;;from all the possible moves
;;It's long but works well that way
(define (make-mind p h)
  (λ ([ g : Game])
    (match g
      [(Game bd np na)
       (if (not (symbol=? p np)) 'none
           (match (direct-win p bd)
             [(Some (Loc x y)) (Some (Move (Loc x y) 'NW 'clockwise))]
             [(Some (Move l q d)) (Some (Move l q d))]
             ['none
              (local
                {(define all (all-possible p bd))
                 (: pick-move : (Listof Move) -> (Optional Move))
                 ;;picks the best move
                 (define (pick-move mvs)
                   (match mvs
                     ['() 'none]
                     [(cons hd tl)
                      (local
                        {(define g
                           (λ ([mv : Move])
                             (match mv
                               [(Move loc q dir)
                                (twist-quadrant (place-marble
                                                 (Game bd p 'place) p loc)
                                                q dir)])))}
                        (match (pick-move tl)
                            ['none (Some hd)]
                            [(Some (Move ltl qtl dtl))
                             (if (>=
                                    (h p (Game-board (g hd)))
                                    (h p (Game-board (g
                                                      (Move ltl qtl dtl)))))
                                   (Some hd)
                                   (Some (Move ltl qtl dtl)))]))]))}
                  (pick-move all))]))])))
(check-expect ((make-mind 'black long-run) exgame1)
                 (Some (Move (Loc 1 2) 'SE 'clockwise)))
(check-expect ((make-mind 'black sum-squares-difference) exgame1)
              (Some (Move (Loc 1 2) 'SE 'clockwise)))
(check-expect ((make-mind 'white sum-squares-difference) new-game)
              (Some (Move (Loc 0 2) 'NW 'clockwise)))




;;========= 5) FINAL PENTAGO for Project C ============================;;
;;=====================================================================;;
;;WHITE IS ALWAYS CALLED FIRST

(: pentago : (U Human Bot) (U Human Bot) -> World)
;;;Intiates the game--between a human and a bot, both humans, or bots.
;;;The first input given is the "white" player.
;;;If the inputs are given in the wrong order,
;;the game will not work correctly.
;;It was difficult to structurally fix this given the constrains.
(define (pentago p1 p2)
  (big-bang (World new-game '() '() 'none 'none 'none p1 p2) : World
            [name "Pentago!"]
            [to-draw draw-pentago]
            [on-key handle-key]
            [stop-when stop-game]
            [on-tick
             (cond
               [(and (Bot? p1) (Bot? p2)) handle-tick3]
               [(Bot? p1) handle-tick1]
               [(Bot? p2) handle-tick2]
               [else handle-tick0]) 2]))
                  




(test)
