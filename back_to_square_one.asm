; Back to square one
; 128 bytes intro for Lovebyte 2022

; F#READY, 2022
; Thanks to IvoP for some optimisations

; Was: draw line hacked OS
; v6.1 128 bytes
; - changed colors and sound
; - saved 2 bytes, 119 bytes now :)
; v6 : 121 bytes
; - optimisations by IvoP, thank you! :)
; v5 : 127 bytes
; - removed open_mode glitch, added bleep
; v4 : 128 bytes
; - brrr hack to switch colors for restart
; - generate all coordinates in $80, move code out of zeropage
; v3 : 112 bytes
; - moved to zeropage, optimised, 112 bytes 
; - changed hack, removed run address, 120 bytes
; v2 : 122 bytes
; - removed dead code, few optimisations, 122 bytes
; v1 : 129 bytes
; - working!

NR_OF_SQUARES   = 12     ; max. 15

ICAX1Z      = $2a       ; set to $20 to skip clear screen

SKIP_SIZE   = 8
MAX_XPOS    = 87+8

ROWCRS		= $54		; byte
y_position	= ROWCRS	; alias

COLCRS		= $55		; word
x_position	= COLCRS	; alias

OLDROW  	= $5a		; byte
y_start		= OLDROW	; alias

OLDCOL  	= $5b		; word
x_start		= OLDCOL	; alias

open_mode	= $ef9c		; A=mode
clear_scr	= $f420		; zero screen memory
plot_pixel	= $f1d8

COUNTR      = $7e
FILFLG		= $2b7
FILDAT		= $2fd

ATACHR		= $2fb		; drawing color
draw_color	= ATACHR	; alias

real_draw   = $f9c2

draw_hack   = $49c2     ;$f9c2     ; $f9bf (stx FILFLG)
ssp7_hack   = $4a4d     ;$fa4d

jmp_my_hack = $4afe

			org $0600

main			
            lda #7
            jsr open_mode
            inc draw_color

restart
            ldx #0
make_hack            
            lda real_draw,x
            sta draw_hack,x
            lda real_draw+$100,x
            sta draw_hack+$100,x
            inx
            bne make_hack

            lda #<my_hack
            sta jmp_my_hack+1
            lda #>my_hack
            sta jmp_my_hack+2
            sta 710
;restart
;            ldx #0 

repeat
            lda xy_tab+6,x
            sta x_start

;            sta $d201

            lda xy_tab+7,x
            sta y_start
draw_square        
            stx line_number
;            txa
;            pha

            lda xy_tab,x
            sta x_position
            lda xy_tab+1,x
            sta y_position

            jsr draw_hack
;            sta $d201

            lda line_number
            adc #2
            tax
            and #7
;            sta $d201
            bne draw_square

            cpx #NR_OF_SQUARES*8
            bne repeat

            ;lda #$20
            ;sta ICAX1Z
            jsr trythis
            sta 708           	
            bne restart

my_hack
; dithering
;            lda draw_color
;            eor #2
;            sta draw_color
;            inc draw_color
            
            lda COUNTR
SKIP_SIZE_CMP   = *+1       
            cmp #SKIP_SIZE
            bne skip_special
;            ora #$a0
;            sta 710

trythis
            inc draw_color
            inc draw_color

            ldx line_number
            lda x_position            
            sta xy_tab+8,x
;            sta $d203,x
            lda y_position
            sta xy_tab+9,x
            
            sbc 19
            lsr
            sta $d201,x
            
skip_special
;            lsr
;            sta $d201

            jmp ssp7_hack

; pairs of x,y
; 20 5f 80 5f 80 00 20 00

            org $80
line_number = $ff

xy_tab      
            dta 32,95
            dta 128,95
            dta 128,0
            dta 32  ;,0      
