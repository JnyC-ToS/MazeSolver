; Bits de contrôle des modules QEIs
QEI_RIGHT    EQU 0x100
QEI_LEFT     EQU 0x200
QEIS         EQU 0x300
QEI_CFG      EQU 0x32001
QEI_POS_BASE EQU 0x0FFF
QEI_POS_MAX  EQU 0xFFFF

INFRA_LED EQU 0x40
PHA_PINS  EQU 0x0C
PHA_PCTL  EQU 0x00003400
PHB0_PIN  EQU 0x07
PHB0_PCTL EQU 0x20000000
PHB1_PIN  EQU 0x07
PHB1_PCTL EQU 0x10000000

	AREA |.vars|, DATA, READWRITE

_qei_right_store SPACE 2
_qei_left_store SPACE 2

	AREA |.text|, CODE, READONLY

	IMPORT SYSCTL_BASE
	IMPORT SYSCTL_RCGC1
	IMPORT SYSCTL_RCGC2

	IMPORT GPIO_PORTC
	IMPORT GPIO_PORTE
	IMPORT GPIO_PORTG
	IMPORT GPIO_PORTE_BASE
	IMPORT GPIO_PORTC_BASE
	IMPORT GPIO_PORTG_BASE
	IMPORT GPIO_DIR
	IMPORT GPIO_DEN
	IMPORT GPIO_DR2R
	IMPORT GPIO_AFSEL
	IMPORT GPIO_PCTL

	IMPORT QEI0_BASE
	IMPORT QEI1_BASE
	IMPORT QEI_CTL
	IMPORT QEI_POS
	IMPORT QEI_MAXPOS

	IMPORT STR_ORR

	EXPORT QEI_INIT
	EXPORT QEI_RIGHT_STORE
	EXPORT QEI_RIGHT_TEST
	EXPORT QEI_LEFT_STORE
	EXPORT QEI_LEFT_TEST

QEI_INIT
	PUSH {R0-R2, LR}

	; Activation des modules QEI sur l'horloge
	LDR R0, =SYSCTL_BASE
	LDR R1, =SYSCTL_RCGC1
	LDR R2, =QEIS
	BL STR_ORR

	; Délais d'attente après activation
	NOP
	NOP
	NOP

	; Activation du port C sur l'horloge
	LDR R1, =SYSCTL_RCGC2
	LDR R2, =GPIO_PORTC
	BL STR_ORR

	; Délais d'attente après activation
	NOP
	NOP
	NOP

	; Activation du port E sur l'horloge
	LDR R1, =SYSCTL_RCGC2
	LDR R2, =GPIO_PORTE
	BL STR_ORR

	; Délais d'attente après activation
	NOP
	NOP
	NOP

	; Activation du port G sur l'horloge
	LDR R1, =SYSCTL_RCGC2
	LDR R2, =GPIO_PORTG
	BL STR_ORR

	; Délais d'attente après activation
	NOP
	NOP
	NOP

	; Allumage des LEDs infrarouges

	; Chargement de l'adresse de base du port E
	LDR R0, =GPIO_PORTE_BASE
	MOV R2, #INFRA_LED

	; Configurer les LEDs infrarouges en sortie
	LDR R1, =GPIO_DIR
	BL STR_ORR

	; Activer la conversion analogique numérique
	LDR R1, =GPIO_DEN
	BL STR_ORR

	; Paramétrage de l'intensité de sortie (2mA)
	LDR R1, =GPIO_DR2R
	BL STR_ORR

	; Stockage de l'état des LEDs avec un masque
	MOV R2, #0
	STR R2, [R0, #INFRA_LED<<2]

	; Paramétrages des entrées des capteurs infrarouges

	; Activation de fonction alternative sur les deux phases A
	LDR R1, =GPIO_AFSEL
	MOV R2, #PHA_PINS
	BL STR_ORR

	; Choix de la fonction alternative sur les deux phases A
	LDR R1, =GPIO_PCTL
	LDR R2, =PHA_PCTL
	BL STR_ORR

	; Activation de fonction alternative sur la phase B0
	LDR R0, =GPIO_PORTC_BASE
	LDR R1, =GPIO_AFSEL
	MOV R2, #PHB0_PIN
	BL STR_ORR

	; Choix de la fonction alternative sur la phase B0
	LDR R1, =GPIO_PCTL
	LDR R2, =PHB0_PCTL
	BL STR_ORR

	; Activation de fonction alternative sur la phase B1
	LDR R0, =GPIO_PORTG_BASE
	LDR R1, =GPIO_AFSEL
	MOV R2, #PHB1_PIN
	BL STR_ORR

	; Choix de la fonction alternative sur la phase B1
	LDR R1, =GPIO_PCTL
	LDR R2, =PHB1_PCTL
	BL STR_ORR

	; Configuration des QEIs
	LDR R0, =QEI0_BASE
	BL QEI_CONFIG

	LDR R0, =QEI1_BASE
	BL QEI_CONFIG

	POP {R0-R2, PC}

; R0 = Adresse de base du QEI à configurer
QEI_CONFIG
	; Paramètres de contrôle
	LDR R1, =QEI_CTL
	LDR R2, =QEI_CFG
	STR R2, [R0, R1]

	; Valeur maximale avant reset
	LDR R1, =QEI_MAXPOS
	LDR R2, =QEI_POS_MAX
	STR R2, [R0, R1]

	; Valeur de départ (moitié du max)
	LDR R1, =QEI_POS
	LDR R2, =QEI_POS_BASE
	STR R2, [R0, R1]

	BX LR

QEI_RIGHT_STORE
	PUSH {R0-R3}

	; Chargement de l'adresse et offset pour QEI0_POS
	LDR R0, =QEI0_BASE
	LDR R1, =QEI_POS
	; Lecture du registre
	LDR R2, [R0, R1]

	; Sauvegarde dans notre variable
	LDR R3, =_qei_right_store
	STRH R2, [R3]

	POP {R0-R3}
	BX LR

; R0 = Valeur de test, Z = 1 si test positif, Z = 0 sinon
QEI_RIGHT_TEST
	PUSH {R1-R5}

	; Chargement de l'adresse et offset pour QEI0_POS
	LDR R1, =QEI0_BASE
	LDR R2, =QEI_POS
	; Lecture du registre
	LDR R3, [R1, R2]

	; Lecture de notre variable
	LDR R4, =_qei_right_store
	LDRH R5, [R4]

	; Soustraction de la valeur
	SUBS R3, R5
	; Valeur absolue (complément à 2 si résultat négatif)
	MVNLO R3, R3

	; Comparaison avec la valeur de test
	CMP R3, R0

	POP {R1-R5}
	BX LR

QEI_LEFT_STORE
	PUSH {R0-R3}

	; Chargement de l'adresse et offset pour QEI1_POS
	LDR R0, =QEI1_BASE
	LDR R1, =QEI_POS
	; Lecture du registre
	LDR R2, [R0, R1]

	; Sauvegarde dans notre variable
	LDR R3, =_qei_left_store
	STRH R2, [R3]

	POP {R0-R3}
	BX LR

; R0 = Valeur de test, Z = 1 si test positif, Z = 0 sinon
QEI_LEFT_TEST
	PUSH {R1-R5}

	; Chargement de l'adresse et offset pour QEI1_POS
	LDR R1, =QEI1_BASE
	LDR R2, =QEI_POS
	; Lecture du registre
	LDR R3, [R1, R2]

	; Lecture de notre variable
	LDR R4, =_qei_left_store
	LDRH R5, [R4]

	; Soustraction de la valeur
	SUBS R3, R5
	; Valeur absolue (complément à 2 si résultat négatif)
	MVNLO R3, R3

	; Comparaison avec la valeur de test
	CMP R3, R0

	POP {R1-R5}
	BX LR

	END
