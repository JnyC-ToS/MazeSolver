; Bits de contrôle des LEDs
LED_BACK1 EQU 0x04
LED_BACK2 EQU 0x08
LED_RIGHT EQU 0x10
LED_LEFT  EQU 0x20
LEDS      EQU 0x3C

	AREA |.text|, CODE, READONLY

	IMPORT SYSCTL_BASE
	IMPORT SYSCTL_RCGC2

	IMPORT GPIO_PORTF
	IMPORT GPIO_PORTF_BASE
	IMPORT GPIO_DIR
	IMPORT GPIO_DEN
	IMPORT GPIO_DR2R

	IMPORT STR_ORR
	IMPORT STR_EOR

	EXPORT LED_INIT
	EXPORT LED_RIGHT_ON
	EXPORT LED_RIGHT_OFF
	EXPORT LED_RIGHT_TOGGLE
	EXPORT LED_LEFT_ON
	EXPORT LED_LEFT_OFF
	EXPORT LED_LEFT_TOGGLE
	EXPORT LED_BACK1_ON
	EXPORT LED_BACK1_OFF
	EXPORT LED_BACK1_TOGGLE
	EXPORT LED_BACK2_ON
	EXPORT LED_BACK2_OFF
	EXPORT LED_BACK2_TOGGLE

LED_INIT
	PUSH {R0-R2, LR}

	; Activation du port F sur l'horloge
	LDR R0, =SYSCTL_BASE
	LDR R1, =SYSCTL_RCGC2
	LDR R2, =GPIO_PORTF
	BL STR_ORR

	; Délais d'attente après activation
	NOP
	NOP
	NOP

	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R2, #LEDS

	; Configurer les LEDs en sortie
	LDR R1, =GPIO_DIR
	BL STR_ORR

	; Activer la conversion analogique numérique
	LDR R1, =GPIO_DEN
	BL STR_ORR

	; Paramétrage de l'intensité de sortie (2mA)
	LDR R1, =GPIO_DR2R
	BL STR_ORR

	POP {R0-R2, PC}

LED_RIGHT_ON
	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #LED_RIGHT
	; Stockage de l'état de la LED avec un masque
	STR R1, [R0, #LED_RIGHT<<2]

	BX LR

LED_RIGHT_OFF
	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #0
	; Stockage de l'état de la LED avec un masque
	STR R1, [R0, #LED_RIGHT<<2]

	BX LR

LED_RIGHT_TOGGLE
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #LED_RIGHT<<2
	MOV R2, #LED_RIGHT
	; Stockage de l'état de la LED avec un masque
	BL STR_EOR

	POP {R0-R2, PC}

LED_LEFT_ON
	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #LED_LEFT
	; Stockage de l'état de la LED avec un masque
	STR R1, [R0, #LED_LEFT<<2]

	BX LR

LED_LEFT_OFF
	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #0
	; Stockage de l'état de la LED avec un masque
	STR R1, [R0, #LED_LEFT<<2]

	BX LR

LED_LEFT_TOGGLE
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #LED_LEFT<<2
	MOV R2, #LED_LEFT
	; Stockage de l'état de la LED avec un masque
	BL STR_EOR

	POP {R0-R2, PC}

LED_BACK1_ON
	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #0
	; Stockage de l'état de la LED avec un masque
	STR R1, [R0, #LED_BACK1<<2]

	BX LR

LED_BACK1_OFF
	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #LED_BACK1
	; Stockage de l'état de la LED avec un masque
	STR R1, [R0, #LED_BACK1<<2]

	BX LR

LED_BACK1_TOGGLE
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #LED_BACK1<<2
	MOV R2, #LED_BACK1
	; Stockage de l'état de la LED avec un masque
	BL STR_EOR

	POP {R0-R2, PC}

LED_BACK2_ON
	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #0
	; Stockage de l'état de la LED avec un masque
	STR R1, [R0, #LED_BACK2<<2]

	BX LR

LED_BACK2_OFF
	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #LED_BACK2
	; Stockage de l'état de la LED avec un masque
	STR R1, [R0, #LED_BACK2<<2]

	BX LR

LED_BACK2_TOGGLE
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du port F
	LDR R0, =GPIO_PORTF_BASE
	MOV R1, #LED_BACK2<<2
	MOV R2, #LED_BACK2
	; Stockage de l'état de la LED avec un masque
	BL STR_EOR

	POP {R0-R2, PC}

	END
