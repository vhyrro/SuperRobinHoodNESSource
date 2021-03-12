absolutely = 1
title = 1
hiscore = 1
musicon = 1

testpause = 0
startlevel = 5
master = 1
showcoins = 0

y_displace = 12

; These two variables are used to keep track of how much memory has been occupied
; in terms of variables. Think of these two as a pointer to the last free position
; in memory for these variables. They are used by the two macros defined below,
; which do the error checking at assemble-time.

zero_page_index = $0
current_variable_index = $0

; define_zeropage_var, as the name suggests, makes adding a new zeropage variable trivial
.macro define_zeropage_var length
	zero_page_index = zero_page_index + length
	.if zero_page_index > $FF
		.error "Unable to allocate more space for another zeropage variable"
	.endif
.endmacro

; define_zeropage_var's brother, define_var, allocates a certain amount of space for a variable
.macro define_var length
	current_variable_index = current_variable_index + length
	.if current_variable_index > $743
		.error "Unable to allocate more space for another variable"
	.endif
.endmacro
