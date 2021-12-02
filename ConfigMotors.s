; Contrôle général des moteurs
PWM_MODULE  EQU 0x00100000
GPIO_PINS_D EQU 0x27
GPIO_PINS_H EQU 0x03
MOTOR_SPEED EQU 0x1A2

	AREA |.text|, CODE, READONLY

	IMPORT SYSCTL_BASE
	IMPORT SYSCTL_RCGC0
	IMPORT SYSCTL_RCGC2

	IMPORT GPIO_PORTD
	IMPORT GPIO_PORTH
	IMPORT GPIO_PORTD_BASE
	IMPORT GPIO_PORTH_BASE
	IMPORT GPIO_DIR
	IMPORT GPIO_DEN
	IMPORT GPIO_DR2R
	IMPORT GPIO_AFSEL
	IMPORT GPIO_PCTL

	IMPORT PWM_BASE
	IMPORT PWM0_BASE
	IMPORT PWM1_BASE
	IMPORT PWM_ENABLE
	IMPORT PWM_CTL
	IMPORT PWM_LOAD
	IMPORT PWM_CMPA
	IMPORT PWM_CMPB
	IMPORT PWM_GENA
	IMPORT PWM_GENB

;	IMPORT QEI_RIGHT_STORE
;	IMPORT QEI_RIGHT_TEST
;	IMPORT QEI_LEFT_STORE
;	IMPORT QEI_LEFT_TEST

	IMPORT STR_ORR
	IMPORT STR_AND
	IMPORT STR_EOR

	EXPORT MOTOR_INIT
;	EXPORT MOTOR_RESET
	EXPORT MOTOR_RIGHT_ON
	EXPORT MOTOR_RIGHT_OFF
	EXPORT MOTOR_RIGHT_FORWARD
	EXPORT MOTOR_RIGHT_BACKWARD
	EXPORT MOTOR_RIGHT_TOGGLE
	EXPORT MOTOR_LEFT_ON
	EXPORT MOTOR_LEFT_OFF
	EXPORT MOTOR_LEFT_FORWARD
	EXPORT MOTOR_LEFT_BACKWARD
	EXPORT MOTOR_LEFT_TOGGLE

MOTOR_INIT
	PUSH {R0-R2, LR}

	; Activation du module PWM sur l'horloge
	LDR R0, =SYSCTL_BASE
	LDR R1, =SYSCTL_RCGC0
	MOV R2, #PWM_MODULE
	BL STR_ORR

	; Activation du port D sur l'horloge
	LDR R1, =SYSCTL_RCGC2
	LDR R2, =GPIO_PORTD
	BL STR_ORR

	; Activation du port H sur l'horloge
	LDR R2, =GPIO_PORTH
	BL STR_ORR

	; Délais d'attente après activation
	NOP
	NOP
	NOP

	; Paramétrage de la fonction alternative sur port D
	LDR R0, =GPIO_PORTD_BASE
	LDR R1, =GPIO_PCTL
	MOV R2, #0x1
	STR R2, [R0, R1]

	LDR R1, =GPIO_AFSEL
	MOV R2, #0x1
	BL STR_ORR

	; Paramétrage de la fonction alternative sur port H
	LDR R0, =GPIO_PORTH_BASE
	LDR R1, =GPIO_PCTL
	MOV R2, #0x2
	STR R2, [R0, R1]

	LDR R1, =GPIO_AFSEL
	MOV R2, #0x1
	BL STR_ORR

	; Paramétrage du modulateur de fréquence n°0 (moteur 1)
	LDR R0, =PWM0_BASE
	BL PWM_INIT

	; Paramétrage du modulateur de fréquence n°1 (moteur 2)
	LDR R0, =PWM1_BASE
	BL PWM_INIT

	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	MOV R2, #GPIO_PINS_D

	; Configurer les moteurs en sortie
	LDR R1, =GPIO_DIR
	BL STR_ORR

	; Activer la conversion analogique numérique
	LDR R1, =GPIO_DEN
	BL STR_ORR

	; Paramétrage de l'intensité de sortie (2mA)
	LDR R1, =GPIO_DR2R
	BL STR_ORR

	; Réglage final
	MOV R2, #0x24
	STR R2, [R0, #GPIO_PINS_D<<2]

	; Chargement de l'adresse de base du port H
	LDR R0, =GPIO_PORTH_BASE
	MOV R2, #GPIO_PINS_H

	; Configurer les moteurs en sortie
	LDR R1, =GPIO_DIR
	STR R2, [R0, R1]

	; Activer la conversion analogique numérique
	LDR R1, =GPIO_DEN
	STR R2, [R0, R1]

	; Paramétrage de l'intensité de sortie (2mA)
	LDR R1, =GPIO_DR2R
	STR R2, [R0, R1]

	; Réglage final
	MOV R2, #0x2
	STR R2, [R0, #0x2<<2]

	POP {R0-R2, PC}

; R0 = Adresse de base du modulateur à initialiser
PWM_INIT
	PUSH {R1-R2, LR}

	; Contrôle du mode : compteur
	LDR R1, =PWM_CTL
	MOV R2, #0x2
	STR R2, [R0, R1]

	; Contrôle du générateur A
	LDR R1, =PWM_GENA
	MOV R2, #0x0B0
	STR R2, [R0, R1]

	; Contrôle du générateur B
	LDR R1, =PWM_GENB
	MOV R2, #0x0B00
	STR R2, [R0, R1]

	; Contrôle de la période
	LDR R1, =PWM_LOAD
	MOV R2, #0x1F4
	STR R2, [R0, R1]

	; Contrôle du rapport cyclique pour la vitesse
	LDR R1, =PWM_CMPA
	MOV R2, #MOTOR_SPEED
	STR R2, [R0, R1]

	; Contrôle du rapport cyclique pour la vitesse
	LDR R1, =PWM_CMPB
	MOV R2, #0x1F4
	STR R2, [R0, R1]

	; Contrôle du mode : débug, compteur et activé
	LDR R1, =PWM_CTL
	MOV R2, #0x07
	BL STR_ORR

	POP {R1-R2, PC}

; Le module de QEI doit avoir été initialisé avant !
;MOTOR_RESET
;	PUSH {LR}
;
;	; Reset moteur droit
;	BL QEI_RIGHT_STORE
;	BL MOTOR_RIGHT_ON
;	BL MOTOR_RIGHT_FORWARD
;
;	MOV R0, #1
;__MOTOR_RESET_wait_right
;	BL QEI_RIGHT_TEST
;	; Boucle tant que roue non alignée
;	BNE __MOTOR_RESET_wait_right
;
;	BL MOTOR_RIGHT_OFF
;
;	; Reset moteur gauche
;	BL QEI_LEFT_STORE
;	BL MOTOR_LEFT_ON
;	BL MOTOR_LEFT_FORWARD
;
;	MOV R0, #1
;__MOTOR_RESET_wait_left
;	BL QEI_LEFT_TEST
;	; Boucle tant que roue non alignée
;	BNE __MOTOR_RESET_wait_left
;
;	BL MOTOR_LEFT_OFF
;
;	POP {PC}

MOTOR_RIGHT_ON
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du modulateur
	LDR R0, =PWM_BASE
	LDR R1, =PWM_ENABLE
	; Stockage de l'état du moteur
	MOV R2, #0x01
	BL STR_ORR

	POP {R0-R2, PC}

MOTOR_RIGHT_OFF
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du modulateur
	LDR R0, =PWM_BASE
	LDR R1, =PWM_ENABLE
	; Stockage de l'état du moteur
	MOV R2, #0x0E
	BL STR_AND

	POP {R0-R2, PC}

MOTOR_LEFT_ON
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du modulateur
	LDR R0, =PWM_BASE
	LDR R1, =PWM_ENABLE
	; Stockage de l'état du moteur
	MOV R2, #0x04
	BL STR_ORR

	POP {R0-R2, PC}

MOTOR_LEFT_OFF
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du modulateur
	LDR R0, =PWM_BASE
	LDR R1, =PWM_ENABLE
	; Stockage de l'état du moteur
	MOV R2, #0x0B
	BL STR_AND

	POP {R0-R2, PC}

MOTOR_RIGHT_BACKWARD
	PUSH {R0-R1}

	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	MOV R1, #0
	; Stockage de l'état du moteur avec un masque
	STR R1, [R0, #0x2<<2]

	POP {R0-R1}
	BX LR

MOTOR_RIGHT_FORWARD
	PUSH {R0-R1}

	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	MOV R1, #2
	; Stockage de l'état du moteur avec un masque
	STR R1, [R0, #0x2<<2]

	POP {R0-R1}
	BX LR

MOTOR_LEFT_BACKWARD
	PUSH {R0-R1}

	; Chargement de l'adresse de base du port H
	LDR R0, =GPIO_PORTH_BASE
	MOV R1, #2
	; Stockage de l'état du moteur avec un masque
	STR R1, [R0, #0x2<<2]

	POP {R0-R1}
	BX LR

MOTOR_LEFT_FORWARD
	PUSH {R0-R1}

	; Chargement de l'adresse de base du port H
	LDR R0, =GPIO_PORTH_BASE
	MOV R1, #0
	; Stockage de l'état du moteur avec un masque
	STR R1, [R0, #0x2<<2]

	POP {R0-R1}
	BX LR

MOTOR_RIGHT_TOGGLE
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du port D
	LDR R0, =GPIO_PORTD_BASE
	MOV R1, #0x2<<2
	MOV R2, #2
	; Stockage de l'état du moteur avec un masque
	BL STR_EOR

	POP {R0-R2, PC}

MOTOR_LEFT_TOGGLE
	PUSH {R0-R2, LR}

	; Chargement de l'adresse de base du port H
	LDR R0, =GPIO_PORTH_BASE
	MOV R1, #0x2<<2
	MOV R2, #2
	; Stockage de l'état du moteur avec un masque
	BL STR_EOR

	POP {R0-R2, PC}

	END
