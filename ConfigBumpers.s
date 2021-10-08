; Bits de contrôle des pare-chocs
BUMPER_RIGHT EQU 0x01
BUMPER_LEFT  EQU 0x02
BUMPERS      EQU 0x03

	AREA |.text|, CODE, READONLY

	IMPORT SYSCTL_BASE
	IMPORT SYSCTL_RCGC2

	IMPORT GPIO_PORTE
	IMPORT GPIO_PORTE_BASE
	IMPORT GPIO_DEN
	IMPORT GPIO_PUR

	IMPORT STR_ORR

	EXPORT BUMPER_INIT
	EXPORT BUMPER_RIGHT_PRESSED
	EXPORT BUMPER_LEFT_PRESSED

BUMPER_INIT
	;PUSH {R0-R2, LR}
	MOV R10, LR

	; Activation du port E sur l'horloge
	LDR R0, =SYSCTL_BASE
	LDR R1, =SYSCTL_RCGC2
	LDR R2, =GPIO_PORTE
	BL STR_ORR

	; Délais d'attente après activation
	NOP
	NOP
	NOP

	; Chargement de l'adresse de base du port E
	LDR R0, =GPIO_PORTE_BASE
	MOV R2, #BUMPERS

	; Activer la conversion analogique numérique
	LDR R1, =GPIO_DEN
	BL STR_ORR

	; Activer la résistance de tirage (pull-up)
	LDR R1, =GPIO_PUR
	BL STR_ORR

	;POP {R0-R2, PC}
	MOV LR, R10
	BX LR

; Z = 1 si pare-choc enfoncé, 0 si pare-choc intact
BUMPER_RIGHT_PRESSED
	; Chargement de l'adresse de base du port E
	LDR R0, =GPIO_PORTE_BASE
	; Lecture de l'état du pare-choc avec un masque
	LDR R1, [R0, #BUMPER_RIGHT<<2]
	CMP R1, #0

	BX LR

; Z = 1 si pare-choc enfoncé, 0 si pare-choc intact
BUMPER_LEFT_PRESSED
	; Chargement de l'adresse de base du port E
	LDR R0, =GPIO_PORTE_BASE
	; Lecture de l'état du pare-choc avec un masque
	LDR R1, [R0, #BUMPER_LEFT<<2]
	CMP R1, #0

	BX LR

	END
