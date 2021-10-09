	AREA |.text|, CODE, READONLY
	ENTRY
	EXPORT __main

;	IMPORT MOTOR_INIT
;
;	IMPORT MOTOR_RIGHT_ON
;	IMPORT MOTOR_RIGHT_OFF
;	IMPORT MOTOR_RIGHT_FORWARD
;	IMPORT MOTOR_RIGHT_BACKWARD
;	IMPORT MOTOR_RIGHT_TOGGLE
;
;	IMPORT MOTOR_LEFT_ON
;	IMPORT MOTOR_LEFT_OFF
;	IMPORT MOTOR_LEFT_FORWARD
;	IMPORT MOTOR_LEFT_BACKWARD
;	IMPORT MOTOR_LEFT_TOGGLE

	IMPORT LED_INIT
;	IMPORT LED_RIGHT_ON
	IMPORT LED_RIGHT_OFF
	IMPORT LED_RIGHT_TOGGLE
;	IMPORT LED_LEFT_ON
	IMPORT LED_LEFT_OFF
	IMPORT LED_LEFT_TOGGLE

	IMPORT SWITCH_INIT
;	IMPORT SWITCH_1_PRESSED
	IMPORT SWITCH_1_PRESSED_ONCE
;	IMPORT SWITCH_2_PRESSED
	IMPORT SWITCH_2_PRESSED_ONCE

;	IMPORT BUMPER_INIT
;	IMPORT BUMPER_RIGHT_PRESSED
;	IMPORT BUMPER_LEFT_PRESSED

__main
	; Initialisation
;	BL MOTOR_INIT
	BL LED_INIT
	BL SWITCH_INIT
;	BL BUMPER_INIT

	BL LED_RIGHT_OFF
	BL LED_LEFT_OFF

__loop
	BL SWITCH_1_PRESSED_ONCE
	BNE __right_skip
	BL LED_RIGHT_TOGGLE

__right_skip

	BL SWITCH_2_PRESSED_ONCE
	BNE __left_skip
	BL LED_LEFT_TOGGLE

__left_skip

	B __loop

	NOP
	END