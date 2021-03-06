; Contrôle du système
SYSCTL_BASE EQU 0x400FE000

; Décalages d'adresses des horloges du système (pour activer les ports et modules)
SYSCTL_RCGC0 EQU 0x100
SYSCTL_RCGC1 EQU 0x104
SYSCTL_RCGC2 EQU 0x108

; Valeurs binaires des ports
GPIO_PORTA EQU 0x001
GPIO_PORTB EQU 0x002
GPIO_PORTC EQU 0x004
GPIO_PORTD EQU 0x008
GPIO_PORTE EQU 0x010
GPIO_PORTF EQU 0x020
GPIO_PORTG EQU 0x040
GPIO_PORTH EQU 0x080
GPIO_PORTJ EQU 0x100

; Adresses de base des ports
GPIO_PORTA_BASE EQU 0x40004000
GPIO_PORTB_BASE EQU 0x40005000
GPIO_PORTC_BASE EQU 0x40006000
GPIO_PORTD_BASE EQU 0x40007000
GPIO_PORTE_BASE EQU 0x40024000
GPIO_PORTF_BASE EQU 0x40025000
GPIO_PORTG_BASE EQU 0x40026000
GPIO_PORTH_BASE EQU 0x40027000
GPIO_PORTJ_BASE EQU 0x4003D000

; Décalages d'adresses des registres GPIO
GPIO_DIR   EQU 0x400
GPIO_IS    EQU 0x404
GPIO_IBE   EQU 0x408
GPIO_IEV   EQU 0x40C
GPIO_IM    EQU 0x410
GPIO_RIS   EQU 0x414
GPIO_MIS   EQU 0x418
GPIO_ICR   EQU 0x41C
GPIO_AFSEL EQU 0x420
GPIO_DR2R  EQU 0x500
GPIO_DR4R  EQU 0x504
GPIO_DR8R  EQU 0x508
GPIO_ODR   EQU 0x50C
GPIO_PUR   EQU 0x510
GPIO_PDR   EQU 0x514
GPIO_SLR   EQU 0x518
GPIO_DEN   EQU 0x51C
GPIO_LOCK  EQU 0x520
GPIO_CR    EQU 0x524
GPIO_AMSEL EQU 0x528
GPIO_PCTL  EQU 0x52C

; Adresses de base des modulateurs de fréquence (Pulse Width Modulator)
PWM_BASE  EQU 0x40028000
PWM0_BASE EQU 0x40028040
PWM1_BASE EQU 0x40028080
PWM2_BASE EQU 0x400280C0
PWM3_BASE EQU 0x40028100

; Décalages d'adresses des registres PWM
PWM_ENABLE EQU 0x008
PWM_CTL    EQU 0x000
PWM_LOAD   EQU 0x010
PWM_CMPA   EQU 0x018
PWM_CMPB   EQU 0x01C
PWM_GENA   EQU 0x020
PWM_GENB   EQU 0x024

; Adresses de base des Quadrature Encoder Interfaces
QEI0_BASE EQU 0x4002C000
QEI1_BASE EQU 0x4002D000

; Décalages d'adresses des registres QEI
QEI_CTL    EQU 0x000
QEI_POS    EQU 0x008
QEI_MAXPOS EQU 0x00C

	AREA |.text|, CODE, READONLY

	; Export des constantes

	EXPORT SYSCTL_BASE

	EXPORT SYSCTL_RCGC0
	EXPORT SYSCTL_RCGC1
	EXPORT SYSCTL_RCGC2

	EXPORT GPIO_PORTA
	EXPORT GPIO_PORTB
	EXPORT GPIO_PORTC
	EXPORT GPIO_PORTD
	EXPORT GPIO_PORTE
	EXPORT GPIO_PORTF
	EXPORT GPIO_PORTG
	EXPORT GPIO_PORTH
	EXPORT GPIO_PORTJ

	EXPORT GPIO_PORTA_BASE
	EXPORT GPIO_PORTB_BASE
	EXPORT GPIO_PORTC_BASE
	EXPORT GPIO_PORTD_BASE
	EXPORT GPIO_PORTE_BASE
	EXPORT GPIO_PORTF_BASE
	EXPORT GPIO_PORTG_BASE
	EXPORT GPIO_PORTH_BASE
	EXPORT GPIO_PORTJ_BASE

	EXPORT GPIO_DIR
	EXPORT GPIO_IS
	EXPORT GPIO_IBE
	EXPORT GPIO_IEV
	EXPORT GPIO_IM
	EXPORT GPIO_RIS
	EXPORT GPIO_MIS
	EXPORT GPIO_ICR
	EXPORT GPIO_AFSEL
	EXPORT GPIO_DR2R
	EXPORT GPIO_DR4R
	EXPORT GPIO_DR8R
	EXPORT GPIO_ODR
	EXPORT GPIO_PUR
	EXPORT GPIO_PDR
	EXPORT GPIO_SLR
	EXPORT GPIO_DEN
	EXPORT GPIO_LOCK
	EXPORT GPIO_CR
	EXPORT GPIO_AMSEL
	EXPORT GPIO_PCTL

	EXPORT PWM_BASE
	EXPORT PWM0_BASE
	EXPORT PWM1_BASE
	EXPORT PWM2_BASE
	EXPORT PWM3_BASE

	EXPORT PWM_ENABLE
	EXPORT PWM_CTL
	EXPORT PWM_LOAD
	EXPORT PWM_CMPA
	EXPORT PWM_CMPB
	EXPORT PWM_GENA
	EXPORT PWM_GENB

	EXPORT QEI0_BASE
	EXPORT QEI1_BASE

	EXPORT QEI_CTL
	EXPORT QEI_POS
	EXPORT QEI_MAXPOS

	; Export des fonctions utilitaires

	EXPORT STR_ORR
	EXPORT STR_AND
	EXPORT STR_EOR

; R0 = Adresse de base, R1 = Décalage, R2 = Valeur
STR_ORR
	LDR R3, [R0, R1]
	ORR R3, R2
	STR R3, [R0, R1]

	BX LR

; R0 = Adresse de base, R1 = Décalage, R2 = Valeur
STR_AND
	LDR R3, [R0, R1]
	AND R3, R2
	STR R3, [R0, R1]

	BX LR

; R0 = Adresse de base, R1 = Décalage, R2 = Valeur
STR_EOR
	LDR R3, [R0, R1]
	EOR R3, R2
	STR R3, [R0, R1]

	BX LR

	END
