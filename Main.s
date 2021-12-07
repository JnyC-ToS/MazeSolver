MODE_1_MOVE_DURATION   EQU 0x1339E0
MODE_1_ROTATE_DURATION EQU 0xA037A0
MODE_2_MOVE_DURATION   EQU 0x122870
MODE_2_ROTATE_DURATION EQU 0x9C400
BLINK_DURATION         EQU 0x40000

ACTION_NOOP         EQU 0
ACTION_MOVE_FORWARD EQU 1
ACTION_ROTATE_LEFT  EQU 2
ACTION_ROTATE_RIGHT EQU 3
ACTION_END          EQU 4

	AREA |.vars|, DATA, READWRITE

_path SPACE 200

	AREA |.text|, CODE, READONLY
	ENTRY
	EXPORT __main

;	IMPORT QEI_INIT
;	IMPORT QEI_RIGHT_STORE
;	IMPORT QEI_RIGHT_TEST
;	IMPORT QEI_LEFT_STORE
;	IMPORT QEI_LEFT_TEST

	IMPORT MOTOR_INIT
;	IMPORT MOTOR_RESET
	IMPORT MOTOR_RIGHT_ON
	IMPORT MOTOR_RIGHT_OFF
	IMPORT MOTOR_RIGHT_FORWARD
	IMPORT MOTOR_RIGHT_BACKWARD
;	IMPORT MOTOR_RIGHT_TOGGLE
	IMPORT MOTOR_LEFT_ON
	IMPORT MOTOR_LEFT_OFF
	IMPORT MOTOR_LEFT_FORWARD
	IMPORT MOTOR_LEFT_BACKWARD
;	IMPORT MOTOR_LEFT_TOGGLE

	IMPORT LED_INIT
	IMPORT LED_RIGHT_ON
	IMPORT LED_RIGHT_OFF
	IMPORT LED_RIGHT_TOGGLE
	IMPORT LED_LEFT_ON
	IMPORT LED_LEFT_OFF
	IMPORT LED_LEFT_TOGGLE
	IMPORT LED_BACK1_ON
	IMPORT LED_BACK1_OFF
;	IMPORT LED_BACK1_TOGGLE
	IMPORT LED_BACK2_ON
	IMPORT LED_BACK2_OFF
;	IMPORT LED_BACK2_TOGGLE

	IMPORT SWITCH_INIT
;	IMPORT SWITCH_1_PRESSED
	IMPORT SWITCH_1_PRESSED_ONCE
;	IMPORT SWITCH_1_RELEASED_ONCE
;	IMPORT SWITCH_1_WAIT_UNTIL_PRESSED
;	IMPORT SWITCH_2_PRESSED
	IMPORT SWITCH_2_PRESSED_ONCE
	IMPORT SWITCH_2_RELEASED_ONCE
	IMPORT SWITCH_2_WAIT_UNTIL_PRESSED
;	IMPORT SWITCH_BOTH_WAIT_UNTIL_PRESSED

	IMPORT BUMPER_INIT
;	IMPORT BUMPER_RIGHT_PRESSED
;	IMPORT BUMPER_LEFT_PRESSED
;	IMPORT BUMPER_BOTH_PRESSED
	IMPORT BUMPER_ANY_PRESSED

__main
	; Initialisation
;	BL QEI_INIT
	BL MOTOR_INIT
	BL LED_INIT
	BL SWITCH_INIT
	BL BUMPER_INIT

	LDR R10, =_path
	MOV R11, #ACTION_END
	STRB R11, [R10]

__start
	BL MOTOR_LEFT_OFF
	BL MOTOR_RIGHT_OFF
	BL LED_LEFT_OFF
	BL LED_RIGHT_OFF
	BL LED_BACK1_OFF
	BL LED_BACK2_OFF
;	BL MOTOR_RESET

__wait_for_mode
	; Boucle d'attente de sélection de mode
	BL SWITCH_2_PRESSED_ONCE
	BEQ.W __mode_2_start

	BL SWITCH_1_PRESSED_ONCE
	BNE __wait_for_mode

__mode_1_start
	; Début du mode 1
	MOV R9, #0
	BL MOTOR_LEFT_ON
	BL MOTOR_RIGHT_ON
	BL LED_LEFT_ON

__mode_1_move_start
	BL MOTOR_LEFT_FORWARD
	BL MOTOR_RIGHT_FORWARD
	BL LED_BACK1_ON
	BL LED_BACK2_ON

	; Avancer tout droit
	MOV R11, #ACTION_MOVE_FORWARD
	STRB R11, [R10, R9]
	ADD R9, #1

	LDR R4, =MODE_1_MOVE_DURATION

__mode_1_move_loop
	BL BUMPER_ANY_PRESSED
	BEQ __mode_1_rotate_start_left

	SUBS R4, #1
	BEQ __mode_1_rotate_start_right

	BL SWITCH_1_PRESSED_ONCE
	BNE __mode_1_move_loop

	; Bouton 1 pressé : Fin du parcours
	MOV R11, #ACTION_END
	STRB R11, [R10, R9]

	BL LED_RIGHT_ON
	B __path_cleanup

__mode_1_rotate_start_left
	BL MOTOR_LEFT_BACKWARD
	BL MOTOR_RIGHT_FORWARD
	BL LED_BACK1_ON
	BL LED_BACK2_OFF

	; Tourner à gauche signifie collision, donc à éviter pour le mode 2
	; Déplacement précédent forcément "Avancer" donc vérification pré-précédent
	SUBS R9, #2
	MOVMI R9, #0

	; Si c'était tourner à droite, ça veut dire qu'on retourne à gauche donc rien à faire
	LDRB R11, [R10, R9]
	CMP R11, #ACTION_ROTATE_RIGHT
	BEQ __mode_1_rotate_start

	; Sinon, il faut remplacer le précédent par une rotation gauche (sans toucher le pré-précédent)
	ADD R9, #1
	MOV R11, #ACTION_ROTATE_LEFT
	STRB R11, [R10, R9]
	ADD R9, #1

	B __mode_1_rotate_start

__mode_1_rotate_start_right
	BL MOTOR_LEFT_FORWARD
	BL MOTOR_RIGHT_BACKWARD
	BL LED_BACK1_OFF
	BL LED_BACK2_ON

	; Tourner à droite
	MOV R11, #ACTION_ROTATE_RIGHT
	STRB R11, [R10, R9]
	ADD R9, #1

	; B __mode_1_rotate_start

__mode_1_rotate_start
	LDR R4, =MODE_1_ROTATE_DURATION

__mode_1_rotate_loop
	SUBS R4, #1
	BEQ __mode_1_move_start

	B __mode_1_rotate_loop

__path_cleanup
	PUSH {R0-R12}

	MOV R0, #1 ; Indicateur de stabilité du parcours (0 = stable) : premier test s'exécute toujours

__path_cleanup_start
	CMP R0, #0
	BEQ __path_cleanup_end

	MOV R0, #0
	MOV R9, #0

__path_cleanup_next
	LDRB R11, [R10, R9]

	CMP R11, #ACTION_NOOP
	ADDEQ R9, #1
	BEQ __path_cleanup_next

	CMP R11, #ACTION_MOVE_FORWARD
	BEQ __path_cleanup_check_fllf_pattern

	CMP R11, #ACTION_ROTATE_LEFT
	MOVEQ R2, #ACTION_ROTATE_RIGHT
	BEQ __path_cleanup_check_next

	CMP R11, #ACTION_ROTATE_RIGHT
	MOVEQ R2, #ACTION_ROTATE_LEFT
	BEQ __path_cleanup_check_next

	CMP R11, #ACTION_END
	BEQ __path_cleanup_start

__path_cleanup_end
	POP {R0-R12}
	B __start

__path_cleanup_check_fllf_pattern
	MOV R1, R9

	BL __path_cleanup_get_next_not_noop

	CMP R11, #ACTION_ROTATE_LEFT
	BNE __path_cleanup_next

	MOV R2, R9

	BL __path_cleanup_get_next_not_noop

	CMP R11, #ACTION_ROTATE_LEFT
	MOVNE R9, R2
	BNE __path_cleanup_next

	MOV R2, R9

	BL __path_cleanup_get_next_not_noop

	CMP R11, #ACTION_MOVE_FORWARD
	MOVNE R9, R2
	BNE __path_cleanup_next

	B __path_cleanup_clean

__path_cleanup_check_next
	MOV R1, R9

	BL __path_cleanup_get_next_not_noop

	CMP R11, R2
	BNE __path_cleanup_next

__path_cleanup_clean
	MOV R11, #ACTION_NOOP
	STRB R11, [R10, R1]
	STRB R11, [R10, R9]

	MOV R0, #1

	ADD R9, #1
	B __path_cleanup_next

__path_cleanup_get_next_not_noop
	ADD R9, #1
	LDRB R11, [R10, R9]

	CMP R11, #ACTION_END
	BEQ __path_cleanup_start

	CMP R11, #ACTION_NOOP
	BEQ __path_cleanup_get_next_not_noop

	BX LR

__mode_2_start
	; Début du mode 2
	MOV R9, #0
	BL MOTOR_LEFT_ON
	BL MOTOR_RIGHT_ON
	BL LED_RIGHT_ON

__mode_2_loop
	LDRB R11, [R10, R9]
	ADD R9, #1

	CMP R11, #ACTION_NOOP
	BEQ __mode_2_loop

	CMP R11, #ACTION_MOVE_FORWARD
	BEQ __mode_2_move_start

	CMP R11, #ACTION_ROTATE_LEFT
	BEQ __mode_2_rotate_start_left

	CMP R11, #ACTION_ROTATE_RIGHT
	BEQ __mode_2_rotate_start_right

	; Fin du parcours : Succès
	B __mode_2_end

__mode_2_move_start
	BL MOTOR_LEFT_FORWARD
	BL MOTOR_RIGHT_FORWARD
	BL LED_BACK1_ON
	BL LED_BACK2_ON

	LDR R4, =MODE_2_MOVE_DURATION
	B __mode_2_move_loop

__mode_2_rotate_start_left
	BL MOTOR_LEFT_BACKWARD
	BL MOTOR_RIGHT_FORWARD
	BL LED_BACK1_ON
	BL LED_BACK2_OFF

	B __mode_2_start_rotate

__mode_2_rotate_start_right
	BL MOTOR_LEFT_FORWARD
	BL MOTOR_RIGHT_BACKWARD
	BL LED_BACK1_OFF
	BL LED_BACK2_ON

	; B __mode_2_start_rotate

__mode_2_start_rotate
	LDR R4, =MODE_2_ROTATE_DURATION

__mode_2_move_loop
	BL SWITCH_2_PRESSED_ONCE
	BNE __mode_2_continue

	BL MOTOR_LEFT_OFF
	BL MOTOR_RIGHT_OFF

__mode_2_pause
	; Attendre que le bouton soit relâché avant qu'il soit pressé de nouveau pour sortir de la pause
	BL SWITCH_2_RELEASED_ONCE
	BNE __mode_2_pause

__mode_2_pause_loop
	BL SWITCH_2_PRESSED_ONCE
	BNE __mode_2_pause_loop

	BL MOTOR_LEFT_ON
	BL MOTOR_RIGHT_ON

__mode_2_continue
	BL BUMPER_ANY_PRESSED
	BEQ __mode_2_failed

	SUBS R4, #1
	BEQ __mode_2_loop

	B __mode_2_move_loop

__mode_2_failed
	BL LED_LEFT_ON

__mode_2_end
	BL MOTOR_LEFT_OFF
	BL MOTOR_RIGHT_OFF
	BL LED_BACK1_OFF
	BL LED_BACK2_OFF

__mode_2_end_blink
	BL LED_LEFT_TOGGLE
	BL LED_RIGHT_TOGGLE
	LDR R4, =BLINK_DURATION

__mode_2_end_loop
	BL SWITCH_2_PRESSED_ONCE
	BEQ __start

	SUBS R4, #1
	BEQ __mode_2_end_blink

	B __mode_2_end_loop

	NOP
	END
