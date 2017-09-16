
breed [balls ball]
breed [players player]
;;cu astea se face cercul din mijloc ..
breed[points point];;;;

globals
[
  score-blue
  score-red
  start-kick?
  start-kicker

  numberOfAttempts    ;;            ;;  tipuri de loviri
]

patches-own
[
  court?
  court-center-spot?
  court-goal?
  court-half-way
  court-inside?

  court-outside-horizontal?
  court-outside-vertical-left-upper?
  court-outside-vertical-left-bottom?
  court-outside-vertical-right-upper?
  court-outside-vertical-right-bottom?

  court-zone-bottom?
  court-zone-middle?
  court-zone-front?
  court-zone-upper?
  court-zone-penalty?

  court-zone-corner-left-bottom?
  court-zone-corner-left-upper?
  court-zone-corner-right-bottom?
  court-zone-corner-right-upper?
]

points-own[
  points-role ; "pre-shoot" or nothing
]

players-own [

  players-distance-to-ball
  players-role
  players-speed
  players-team

  ;;depistarea miscarii celorlalti roboti
  players-previous-xcor
  players-previous-ycor

  ;;players-friend-density-surrounding
  ;;players-home?
  ;;players-moving-distance
  ;;players-occupant?

  ;;players-rest?
  ;;players-rival-density-surrounding
  ;;players-rival-density-ahead
]

balls-own
[
  ball-goal?
  ;;ball-occupied?
  ball-outside-horizontal?
  ball-outside-vertical-left-bottom?
  ball-outside-vertical-left-upper?
  ball-outside-vertical-right-bottom?
  ball-outside-vertical-right-upper?
]

to setup
  ca
  ;set start-kick? true
  ;set start-kicker one-of ["left" "right"]
  setup-score
  setup-court
  setup-players
  setup-ball
  ;;display-score
  set numberOfAttempts 0
  reset-ticks
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SCOR;;;;;;;
to setup-score
  set score-blue 0
  set score-red 0
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TEREN;;;;;;
to setup-court
  ask patches
  [
    set court? true
    set court-center-spot? false
    set court-goal? false
    set court-inside? false
    set court-outside-horizontal? false
    set court-outside-vertical-left-bottom? false
    set court-outside-vertical-left-upper? false
    set court-outside-vertical-right-bottom? false
    set court-outside-vertical-right-upper? false

    set court-zone-bottom? false
    set court-zone-middle? false
    set court-zone-front? false
    set court-zone-upper? false
    set court-zone-penalty? false

    set court-zone-corner-left-bottom? false
    set court-zone-corner-left-upper? false
    set court-zone-corner-right-bottom? false
    set court-zone-corner-right-upper? false

    ifelse
    (
      (pxcor <= min-pxcor + 4 or pxcor >= max-pxcor - 4 or pycor <= min-pycor + 14 or pycor >= max-pycor - 4)
      and
      not(pycor >= min-pycor + 53 and pycor <= max-pycor - 38)
    )
    [
      ifelse(pycor <= min-pycor + 10)
      [
        set court? false
      ]
      [
        set pcolor green - 2

        ifelse
        (
          (pycor >= min-pycor + 10 and pycor <= max-pycor)
          and
          ((pxcor >= min-pxcor and pxcor <= 4) or (pxcor >= max-pxcor - 4 and pxcor <= max-pxcor))
        )
        [
          ifelse (pycor <= (min-pycor + 15) + round (.5 * ((max-pycor - 5) - (min-pycor + 15))))
          [
            ifelse (pxcor <= min-pxcor + round (.5 * (max-pycor - min-pycor )))
            [
              set court-outside-vertical-left-bottom? true
            ]
            [
              set court-outside-vertical-right-bottom? true
            ]
          ]
          [
            ifelse (pxcor <= min-pxcor + round (.5 * (max-pycor - min-pycor )))
            [
              set court-outside-vertical-left-upper? true
            ]
            [
              set court-outside-vertical-right-upper? true
            ]
          ]
        ]
        [
          set court-outside-horizontal? true
        ]
      ]
    ]
    [
      set court-inside? true

      set pcolor ifelse-value
      (
        ((pxcor = min-pxcor + 5 or pxcor = max-pxcor - 5) and pycor >= min-pycor + 15 and pycor <= max-pycor - 5) or
        ((pycor = min-pycor + 15 or pycor = max-pycor - 5) and pxcor >= min-pxcor + 5 and pxcor <= max-pxcor - 5)
      )
      [
        green + 1
      ]
      [
        green - 3
      ]

      set court-half-way ifelse-value (pxcor <= round (0.5 * (max-pxcor - min-pxcor)))
      [
        "left"
      ]
      [
        "right"
      ]

      if
      (
        (pxcor >= min-pxcor and pxcor <= min-pxcor + 5 and pycor >= min-pycor + 53 and pycor <= max-pycor - 38) or
        (pxcor >= max-pxcor - 5 and pxcor <= max-pxcor and pycor >= min-pycor + 53 and pycor <= max-pycor - 38)
      )
      [
        set court-goal? true
        set pcolor green - 4

        if (pxcor = min-pxcor or pxcor = max-pxcor or pycor = min-pycor + 53 or pycor = max-pycor - 38)
        [
          set pcolor ifelse-value (court-half-way = "left")
          [
            blue
          ]
          [
            red
          ]
        ]
      ]

      if (pxcor = round (0.5 * (max-pxcor - min-pxcor)))
      [
        set pcolor green + 1
        if (pycor = (min-pycor + 15) + round (.5 * ((max-pycor - 5) - (min-pycor + 15))))
        [
          set court-center-spot? true
        ]

      ]


    ]

  ]

  ask patches with[court-inside?]
  [
    if (pxcor = min-pxcor + 6 and pycor = min-pycor + 16)
    [
      set court-zone-corner-left-bottom? true
    ]

    if (pxcor = min-pxcor + 6 and pycor = max-pycor - 6)
    [
      set court-zone-corner-left-upper? true
    ]

    if (pxcor = max-pxcor - 6 and pycor = min-pycor + 16)
    [
      set court-zone-corner-right-bottom? true
    ]

    if (pxcor = max-pxcor - 6 and pycor = max-pycor - 6)
    [
      set court-zone-corner-right-upper? true
    ]


  ]

  ask patches with[court-inside?]
  [
    ifelse (pycor >= (min-pycor + 15) + round(.5 * ((max-pycor) - (min-pxcor + 15))))
    [
      set court-zone-upper? true
    ]
    [
      set court-zone-bottom? true
    ]

    ifelse
    (
      (pxcor >= min-pxcor and pxcor <= min-pxcor + round(.25 * (max-pxcor - min-pxcor))) or
      (pxcor >= min-pxcor + round(.75 * (max-pxcor - min-pxcor)) and pxcor <= max-pxcor)
    )
    [
      set court-zone-front? true

      if
      (
        (
          (pycor >= (min-pycor + 15) + round(.375 * ((max-pycor) - (min-pycor + 15)))) and
          (pycor <= (min-pycor + 15) + round(.625 * ((max-pycor) - (min-pycor + 15)))) and
          (pxcor <= min-pxcor + round(.125 * (max-pxcor - min-pxcor)))
        ) or
        (
          (pycor >= (min-pycor + 15) + round(.375 * ((max-pycor) - (min-pycor + 15)))) and
          (pycor <= (min-pycor + 15) + round(.625 * ((max-pycor) - (min-pycor + 15)))) and
          (pxcor >= min-pxcor + round(.875 * (max-pxcor - min-pxcor)))
        )
      )
      [
        set court-zone-penalty? true
      ]
    ]
    [
      set court-zone-middle? true
    ]

  ]

  setup-center-circle
  ;;setup-goal-net
end

to setup-center-circle

  create-ordered-points 50
  [
    ht
    move-to one-of patches with[court-center-spot?]
    set color green + 1
    set pen-size patch-size
    fd 9
    rt 90
    pd
  ]

  repeat 3
  [
    ask points
    [
      let tetha .25 * 180 / (pi * 9)
      rt .5 * tetha
      fd .25
      rt .5 * tetha
    ]
  ]

  ask points
  [
    die
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;JUCATOR;;;;;


to setup-players
  create-players 1
  [
    set shape "square"
    set size 3
    set players-team "none"
    set players-role "none"
    set players-speed 1
    ;;set players-moving-distance 0
    ;;set players-rest? false
    ;;set players-home? false
    ;;set players-friend-density-surrounding 0
    ;;set players-rival-density-surrounding 0
    ;;set players-rival-density-ahead 0
    set players-distance-to-ball 0
  ]
;;;;;;;;;;;;;;;;;;Echipele;;;;;;;;;;;;
;;
;;  foreach ["left" "right"]
;;  [
;;    let n round (.5 * count players)
;;    let team ?
;;
;;    while [n > 0]
;;    [
;;      ask one-of players with[players-team = "none"]
;;      [
;;        set players-team team
;;        set n n - 1
;;      ]
;;
;;    ]
;;
;;  ]
;;;;;;;;pentru un singur jucator:

ask players[
  set players-team "right"
  set color blue
  ]

;;;;;;;;;;;;;;;;;Roles(da..stai numa');;
;;
;;  foreach ["left" "right"]
;;  [
;;    let team ?
;;
;;    ask one-of players with[players-team = team and players-role = "none"]
;;    [
;;      set players-role "keeper"
;;      set shape "circle 2"
;;    ]
;;
;;    ask n-of 2 players with[players-team = team and players-role = "none"]
;;    [
;;      set players-role "stopper-upper"
;;    ]
;;
;;    ask n-of 2 players with[players-team = team and players-role = "none"]
;;    [
;;      set players-role "stopper-bottom"
;;    ]
;;
;;    ask n-of 2 players with[players-team = team and players-role = "none"]
;;    [
;;      set players-role "middlefielder-upper"
;;    ]
;;
;;    ask n-of 2 players with[players-team = team and players-role = "none"]
;;    [
;;      set players-role "middlefielder-bottom"
;;    ]
;;
;;    ask one-of players with[players-team = team and players-role = "none"]
;;    [
;;      set players-role "striker-upper"
;;    ]
;;
;;    ask one-of players with[players-team = team and players-role = "none"]
;;    [
;;      set players-role "striker-bottom"
;;    ]
;;  ]

;;  arrange-players

  randomize-players

  ask players
  [
    set players-previous-xcor xcor
    set players-previous-ycor ycor
  ]

end

to randomize-players
  ask players
  [
     move-to one-of patches with[(court-zone-middle? or court-zone-front?) and not court-goal?]
  ]
end

;;;;;;;;;;;;;;;;;;Cica aranjare in teren;;;;;;;;;;;;;;;;;;;
;;
;;to arrange-players
;;  ask players
;;  [
;;    let t players-team
;;    ;set players-occupant? false
;;
;;    ifelse (players-team = "right")
;;    [
;;      set heading 180 + random 181
;;      set color red
;;    ]
;;    [
;;      set heading random 181
;;      set color blue
;;    ]
;;
;;
;;    ifelse (players-role = "keeper")
;;    [
;;      move-to one-of patches with[court-half-way = t and court-zone-penalty? and not court-goal?]
;;    ]
;;    [
;;      ifelse (players-role = "stopper-upper")
;;      [
;;        move-to one-of patches with[court-half-way = t and court-zone-front? and court-zone-upper? and not court-goal?]
;;      ]
;;      [
;;        ifelse (players-role = "stopper-bottom")
;;        [
;;          move-to one-of patches with[court-half-way = t and court-zone-front? and court-zone-bottom? and not court-goal?]
;;        ]
;;        [
;;          ifelse (players-role = "middlefielder-upper")
;;          [
;;            move-to one-of patches with[court-zone-middle? and court-zone-upper?]
;;          ]
;;          [
;;            ifelse (players-role = "middlefielder-bottom")
;;            [
;;              move-to one-of patches with[court-zone-middle? and court-zone-bottom?]
;;            ]
;;            [
;;              ifelse (players-role = "striker-upper")
;;              [
;;                ifelse(t ="right")
;;                [
;;                  move-to one-of patches with[court-half-way = "left" and court-zone-front? and court-zone-upper?]
;;                ]
;;                [
;;                  move-to one-of patches with[court-half-way = "right" and court-zone-front? and court-zone-upper?]
;;                ]
;;              ]
;;              [
;;                ifelse(t ="right")
;;                [
;;                  move-to one-of patches with[court-half-way = "left" and court-zone-front? and court-zone-bottom?]
;;                ]
;;                [
;;                  move-to one-of patches with[court-half-way = "right" and court-zone-front? and court-zone-bottom?]
;;                ]
;;              ]
;;            ]
;;          ]
;;        ]
;;      ]
;;    ]
;;
;;  ]
;;
;;end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MINGE;;;;;;;

to setup-ball
  create-balls 1
  [
    set shape "circle"
    set color white
    set size 2

    set ball-goal? false
    ;;set ball-occupied? false
    set ball-outside-horizontal? false
    set ball-outside-vertical-left-bottom? false
    set ball-outside-vertical-left-upper? false
    set ball-outside-vertical-right-bottom? false
    set ball-outside-vertical-right-upper? false
  ]

;;;;Functia cu care pui minga in pozitii;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  centralize-ball
end

;;;;A se modifica pentru teste : mingea spawnata in pozitii random:;;;;;;;;;;;;;;;

to centralize-ball
  ask balls
  [
     move-to one-of patches with[court-center-spot?]

     set ball-goal? false
     ;;set ball-occupied? false
  ]
;  if[points 51 ][
     ask points
       [die]
 ; ]
end

to randomize-ball
  ask balls
  [
     move-to one-of patches with[(court-zone-middle? or court-zone-front?) and not court-goal?]

     set ball-goal? false
     ;;set ball-occupied? false
  ]
end

  ;;cod in care :
  ;;1) idetifici punctul P din "spatele mingii"
  ;;    1.1) ecuatia dreptei minge-poarta: f(x)= y = m*x + n, unde m=(Yp-Ym)/(Xp-Xm), n= Yp-m*Xp
  ;;    1.2) calculezi f(Xm-2) => pct de coordonate R1 ( Xm-2p ,  f(Xm-2)) <- tinta robotului             mama da ce am mai folosit astea...
  ;;2) trimiti robotul la punctul R1 de pe dreapta minge-poarta:
  ;;    2.1) gasit unghiul cu care trebuie rotit
  ;;    2.2) rotesti robotul
  ;;    2.2) il pui sa mearga in fata (cu viteza lui, ce o fi insemnand asta)
  ;;    2.3) mai gasesti o data unghiul (diferenta dintre unghiul de la 2.1 si arctg de panta dreptei minge-poarta
  ;;3)Avansezi minimul ala de distanta, pe care ti l-ai luat:
  ;;

to start

whereDoWeGoNow  ;;uauauauaua whereDoWeGooooo uauaua whereDoWeGoNow uauauauuu
  rollingOnTheRailroad
  hitMeWithYourBestShot

ifelse scenario = 1
[

][

ifelse scenario = 2
[

  ]
[

  ]
]

end

to whereDoWeGoNow

   create-points 1
  [
    ;hide-turtle
    set color pink

    move-to ball 51
    facexy 121 62 ;;poarta (poate ar fi trebuit sa o fac cu const dar nu stiu cum..
    back 5

    set points-role "pre-shoot"
  ]
end
;
to rollingOnTheRailroad

  let a 52 + numberOfAttempts

  ask player 50
  [face point a]
  while[ [pxcor] of player 50 != [pxcor] of point a or
         [pycor] of player 50 != [pycor] of point a ][
    ask players[
       fd 1
       ]
    tick
  ]
  ask point a [die]
  set numberOfAttempts numberOfAttempts + 1
end


to hitMeWithYourBestShot
  ask players[
    facexy 121 62
  ];
   while[ [pxcor] of player 50 != [pxcor] of ball 51 or
         [pycor] of player 50 != [pycor] of ball 51 ][
    ask players[
       fd 1
       ]
    tick
  ]
   ;;; conditie ca a ajuns in poarta plang
  ask balls[
    facexy 121 62
    while[not [court-goal?] of patch-here][
       fd 1
       ]
    ]
    tick

end



















@#$#@#$#@
GRAPHICS-WINDOW
4
14
576
540
-1
-1
4.5
1
20
1
1
1
0
0
0
1
0
124
0
109
0
0
1
ticks
30.0

BUTTON
12
495
75
528
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
76
495
189
528
Minge noua
randomize-ball\n\n\n
NIL
1
T
OBSERVER
NIL
M
NIL
NIL
1

BUTTON
191
495
288
528
Jucator nou
randomize-players
NIL
1
T
OBSERVER
NIL
J
NIL
NIL
1

TEXTBOX
580
10
877
262
Coordonate teren:\n\n	sus-stanga :  (0 ,109)\n	jos-stanga :  (0 , 11)\n	sus-dreapta: (123,109)\n	jos-dreapta: (123, 11)\n*margine 4, contur 1;\n	\ncentrele portilor:\n	stanga:  ( 3,62)\n	dreapta: ( 121,62)
17
82.0
0

CHOOSER
432
488
570
533
scenario
scenario
"1" "2" "3"
0

BUTTON
289
495
382
528
Ronaldinho
start
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
