// Notas al margen
#import "@preview/drafting:0.2.2"
#drafting.set-page-properties()
#drafting.set-margin-note-defaults(stroke: none)

#let notalmarr(body) = drafting.margin-note([#set text(size: 8pt)
 #body], side: right)

#let notalmarl(body) = drafting.margin-note([#set text(size: 8pt)
 #body], side: left)