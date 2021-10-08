; Bits de contrôle des boutons
SWITCH_1 EQU 0x40
SWITCH_2 EQU 0x80
SWITCHES EQU 0xC0

	AREA |.text|, CODE, READONLY

	IMPORT SYSCTL_BASE
	IMPORT SYSCTL_RCGC2

	IMPORT GPIO_PORTD
	IMPORT GPIO_PORTD_BASE
	IMPORT GPIO_DEN
	IMPORT GPIO_PUR

	IMPORT STR_ORR

	EXPORT SWITCH_INIT
	EXPORT SWITCH_1_PRESSED
	EXPORT SWITCH_2_PRESSED

SWITCH_INIT
	;PUSH {R0-R2, LR}
	MOV R10, LR

	; Activation du port D sur l'horloge
	LDR R0, =SYSCTL_BASE
	LDR R1, =SYSCTL_RCGC2
	LDR R2, =GPIO_PORTD
	BL STR_ORR

	; Délais d'attente après activation
	NOP
	NOP
	NOP

	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	MOV R2, #SWITCHES

	; Activer la conversion analogique numérique
	LDR R1, =GPIO_DEN
	BL STR_ORR

	; Activer la résistance de tirage (pull-up)
	LDR R1, =GPIO_PUR
	BL STR_ORR

	;POP {R0-R2, PC}
	MOV LR, R10
	BX LR

; Z = 1 si bouton pressé, 0 si bouton inactif
SWITCH_1_PRESSED
	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	; Lecture de l'état du bouton avec un masque
	LDR R1, [R0, #SWITCH_1<<2]
	CMP R1, #0

	BX LR

; Z = 1 si bouton pressé, 0 si bouton inactif
SWITCH_2_PRESSED
	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	; Lecture de l'état du bouton avec un masque
	LDR R1, [R0, #SWITCH_2<<2]
	CMP R1, #0

	BX LR

	END
