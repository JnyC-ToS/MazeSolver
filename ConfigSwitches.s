; Bits de contrôle des boutons
SWITCH_1 EQU 0x40
SWITCH_2 EQU 0x80
SWITCHES EQU 0xC0

	AREA |.vars|, DATA, READWRITE

_switch_1_previous_state SPACE 1
_switch_2_previous_state SPACE 1

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
	EXPORT SWITCH_1_PRESSED_ONCE
	EXPORT SWITCH_1_RELEASED_ONCE
	EXPORT SWITCH_1_WAIT_UNTIL_PRESSED
	EXPORT SWITCH_2_PRESSED
	EXPORT SWITCH_2_PRESSED_ONCE
	EXPORT SWITCH_2_RELEASED_ONCE
	EXPORT SWITCH_2_WAIT_UNTIL_PRESSED
	EXPORT SWITCH_BOTH_WAIT_UNTIL_PRESSED

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

	; Initialisation des états précédents
	LDR R0, =_switch_1_previous_state
	MOV R1, #SWITCH_1
	STR R1, [R0]
	LDR R0, =_switch_2_previous_state
	MOV R1, #SWITCH_2
	STR R1, [R0]

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

; Z = 1 si bouton pressé à l'instant, 0 si bouton inactif ou déjà pressé
SWITCH_1_PRESSED_ONCE
	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	; Lecture de l'état du bouton avec un masque
	LDR R1, [R0, #SWITCH_1<<2]

	; Récupération de l'état précédent du bouton
	LDR R2, =_switch_1_previous_state
	LDRB R3, [R2]

	CMP R1, R3
	BNE __SWITCH_1_PRESSED_ONCE_modified_state

	; Toujours différent, Z = 0
	CMP R0, #0
	BX LR

__SWITCH_1_PRESSED_ONCE_modified_state
	; Mémorisation de l'état actuel
	STRB R1, [R2]
	; Vérification de l'état actuel
	CMP R1, #0

	BX LR

; Z = 1 si bouton relâché à l'instant, 0 si bouton inactif ou déjà relâché
SWITCH_1_RELEASED_ONCE
	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	; Lecture de l'état du bouton avec un masque
	LDR R1, [R0, #SWITCH_1<<2]

	; Récupération de l'état précédent du bouton
	LDR R2, =_switch_1_previous_state
	LDRB R3, [R2]

	CMP R1, R3
	BNE __SWITCH_1_RELEASED_ONCE_modified_state

	; Toujours différent, Z = 0
	CMP R0, #0
	BX LR

__SWITCH_1_RELEASED_ONCE_modified_state
	; Mémorisation de l'état actuel
	STRB R1, [R2]
	; Vérification de l'état précédent
	CMP R3, #0

	BX LR

SWITCH_1_WAIT_UNTIL_PRESSED
	;PUSH {LR}
	MOV R10, LR

__SWITCH_1_WAIT_UNTIL_PRESSED_loop
	; Boucle tant que bouton inactif
	BL SWITCH_1_PRESSED
	BNE __SWITCH_1_WAIT_UNTIL_PRESSED_loop

	;POP {PC}
	MOV LR, R10
	BX LR

; Z = 1 si bouton pressé, 0 si bouton inactif
SWITCH_2_PRESSED
	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	; Lecture de l'état du bouton avec un masque
	LDR R1, [R0, #SWITCH_2<<2]
	CMP R1, #0

	BX LR

; Z = 1 si bouton pressé à l'instant, 0 si bouton inactif ou déjà pressé
SWITCH_2_PRESSED_ONCE
	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	; Lecture de l'état du bouton avec un masque
	LDR R1, [R0, #SWITCH_2<<2]

	; Récupération de l'état précédent du bouton
	LDR R2, =_switch_2_previous_state
	LDRB R3, [R2]

	CMP R1, R3
	BNE __SWITCH_2_PRESSED_ONCE_modified_state

	; Toujours différent, Z = 0
	CMP R0, #0
	BX LR

__SWITCH_2_PRESSED_ONCE_modified_state
	; Mémorisation de l'état actuel
	STRB R1, [R2]
	; Vérification de l'état actuel
	CMP R1, #0

	BX LR

; Z = 1 si bouton relâché à l'instant, 0 si bouton inactif ou déjà relâché
SWITCH_2_RELEASED_ONCE
	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	; Lecture de l'état du bouton avec un masque
	LDR R1, [R0, #SWITCH_2<<2]

	; Récupération de l'état précédent du bouton
	LDR R2, =_switch_2_previous_state
	LDRB R3, [R2]

	CMP R1, R3
	BNE __SWITCH_2_RELEASED_ONCE_modified_state

	; Toujours différent, Z = 0
	CMP R0, #0
	BX LR

__SWITCH_2_RELEASED_ONCE_modified_state
	; Mémorisation de l'état actuel
	STRB R1, [R2]
	; Vérification de l'état précédent
	CMP R3, #0

	BX LR

SWITCH_2_WAIT_UNTIL_PRESSED
	;PUSH {LR}
	MOV R10, LR

__SWITCH_2_WAIT_UNTIL_PRESSED_loop
	; Boucle tant que bouton inactif
	BL SWITCH_2_PRESSED
	BNE __SWITCH_2_WAIT_UNTIL_PRESSED_loop

	;POP {PC}
	MOV LR, R10
	BX LR

SWITCH_BOTH_WAIT_UNTIL_PRESSED
	;PUSH {LR}
	MOV R10, LR

__SWITCH_BOTH_WAIT_UNTIL_PRESSED_loop
	; Boucle tant que boutons inactifs
	BL SWITCH_1_PRESSED
	BNE __SWITCH_BOTH_WAIT_UNTIL_PRESSED_loop
	BL SWITCH_2_PRESSED
	BNE __SWITCH_BOTH_WAIT_UNTIL_PRESSED_loop

	;POP {PC}
	MOV LR, R10
	BX LR

	END
