#include "p16f887.inc"

; CONFIG1
; __config 0x3FFF
 __CONFIG _CONFIG1, _FOSC_EXTRC_CLKOUT & _WDTE_ON & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;========================================
; VARIABLES
;========================================

        CBLOCK  0x20

        CONTADOR
        SECUENCIA
        RET1
        RET2

        ENDC


;========================================
; VECTOR DE RESET
;========================================

        ORG     0x00
        GOTO    INICIO


;========================================
; INICIALIZACIÓN
;========================================

INICIO:

        ; PORTD como salida
        BANKSEL TRISD
        CLRF    TRISD

        ; RC0 como entrada
        BANKSEL TRISC
        BSF     TRISC, 0

        ; PORTD en cero
        BANKSEL PORTD
        CLRF    PORTD

        ; Inicializar contador
        CLRF    CONTADOR

        ; Inicializar secuencia
        MOVLW   b'00000001'
        MOVWF   SECUENCIA


;========================================
; PROGRAMA PRINCIPAL
;========================================

PRINCIPAL:

        CALL    SELECCIONAR_MODO

        GOTO    PRINCIPAL


;========================================
; SELECCIONAR MODO
;
; RC0 = 0 ? CONTADOR
; RC0 = 1 ? BARRIDO
;========================================

SELECCIONAR_MODO:

        BTFSS   PORTC, 0
        GOTO    MODO_CONTADOR

        GOTO    MODO_BARRIDO


;========================================
; MODO CONTADOR
;========================================

MODO_CONTADOR:

        MOVF    CONTADOR, W
        MOVWF   PORTD

        CALL    DELAY

        INCF    CONTADOR, F

        RETURN


;========================================
; MODO BARRIDO
;========================================

MODO_BARRIDO:

        MOVF    SECUENCIA, W
        MOVWF   PORTD

        CALL    DELAY

        ; ¿Llegamos al último LED?
        MOVF    SECUENCIA, W
        XORLW   b'10000000'

        BTFSC   STATUS, Z
        GOTO    REINICIAR_BARRIDO

        ; Pasar al siguiente LED
        BCF     STATUS, C
        RLF     SECUENCIA, F

        RETURN


;========================================
; REINICIAR BARRIDO
;========================================

REINICIAR_BARRIDO:

        MOVLW   b'00000001'
        MOVWF   SECUENCIA

        RETURN


;========================================
; DELAY
;========================================

DELAY:

        MOVLW   d'97'
        MOVWF   RET1

D1:

        MOVLW   d'250'
        MOVWF   RET2

D2:

        DECFSZ  RET2, F
        GOTO    D2

        DECFSZ  RET1, F
        GOTO    D1

        RETURN


        END