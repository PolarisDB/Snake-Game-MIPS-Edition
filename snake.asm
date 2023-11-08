#==========================================================================================
# Integrantes:
#	Clement Torres
#	Victor Viveros
#======================================= Snake Game =======================================
#======================================	MIPS Edition ======================================
#
# Status:
#	0 => Empty,
#	1 => Head,
#	2 => Body,
#	3 => Tail,
#	4 => Food
#
# Direction:
#	0 => Still,
#	1 => Up,
#	2 => Down,
#	3 => Left,
#	4 => Right
#
# Snake:   
#	  [ Status 4 bit | Direction 4 bit | PosY 8 bit | PosX 8 bit | RGB 8 bit ]
#
#==========================================================================================

Start:
	addi $sp, $zero, 0x10012000	# Pila
	addi $s0, $zero, 0x10010000	# Cabeza
	addi $s2, $zero, 0x10011000	# Posicion de memoria donde va el dato a borrar
	addi $s2, $s2, -4
	addi $s1, $zero, 1		# Longitud de la serpiente
	
	jal SpawnSnake
	jal SpawnFood

Main:
	Move:
		lw $t9, 0($s0)		# Guardar dato actual
		jal Displacement	# Renueva los datos de 0x10010000
		add $a0, $zero, $t9
		jal Snake2Food
	
	DataTransfer:
		add $a0, $zero, $t9
		jal CopyData
	
	GameOver:
		add $a0, $zero, $v0
		add $a1, $zero, $s2
		jal DeleteShadow
		jal Delay
		jal Collision
		beq $s1, 1023, EXIT1	# Condicion de ganar
		beq $v0, 1, EXIT2	# Condicion de perder
	
	j Main

#END
EXIT1:
	lw $t0, 0($s0)
	srl $t0, $t0, 8
	sll $t0, $t0, 8
	add $t0, $t0, 0xE0
	sw $t0, 0($s0)
	j EXIT
EXIT2:
	lw $t0, 0($s0)
	srl $t0, $t0, 8
	sll $t0, $t0, 8
	add $t0, $t0, 0x03
	sw $t0, 0($s0)
	j EXIT

EXIT:
	j EXIT

#==========================================================================================
#                                        FUNCTIONS                                         
#==========================================================================================

SpawnSnake:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	
	addi $t0, $zero, 0x100F0FF0	# Se configura el estado inicial de la cabeza
	sw $t0, 0($s0)			# Se actualiza el registro
	
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8
	jr $ra

#==========================================================================================

SpawnFood:
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)	
	
	GenerateRandomNumber:
		add $t0, $zero, $zero	# Contador
		add $t1, $zero, $s0	# Posicion de la cabeza
		
		jal PseudoRandomNumberGenerator
		add $t2, $zero, $v0	# Coordenada Y'
		add $t3, $zero, $v1	# Coordenada X'
		
		CheckOverlap:
			lw $a0, 0($t1)		# Carga el dato de puntero actual
			jal GetPosition
			add $t4, $zero, $v0	# Y
			add $t5, $zero, $v1	# X
			sub $t4, $t4, $t2	# Y-Y'
			sub $t5, $t5, $t3	# X-X'
			or $t4, $t4, $t5
			beq $t4, 0, GenerateRandomNumber
			addi $t1, $t1, 4
			addi $t0, $t0, 1
			beq $t0, $s1, GenerateFood
			j CheckOverlap
	
	GenerateFood:
		add $t5, $zero, 0x40	# Status, Direction
		sll $t5, $t5, 8
		add $t5, $t5, $t2	# PosY
		sll $t5, $t5, 8
		add $t5, $t5, $t3	# PosX
		sll $t5, $t5, 8
		add $t5, $t5, 0xFC	# RGB
		sw $t5, 0($t1)
	
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

#==========================================================================================

PseudoRandomNumberGenerator:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	
	lw $t0, 0xFFFF0008		# SystemClock (Hardware)
	andi $t0, $t0, 0x0000FFFF
	or $t1, $zero, $t0
	or $t2, $zero, $t0
	andi $t1, $t1, 0x00000FF0
	andi $t2, $t2, 0x0000F00F
	
	srl $v1, $t1, 4
	andi $v1, $v1, 0x0000001F	# Valor aleatorio de X de 0 a 31	
	
	srl $t3, $t2, 8
	or $v0, $t3, $t2
	andi $v0, $v0, 0x0000001F	# Valor aleatorio de Y de 0 a 31
	
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

#==========================================================================================

GetPosition:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $a0, 12($sp)
	
	add $t0, $zero, $a0
	add $t1, $zero, $a0
	
	sll $t0, $t0, 8
	sll $t1, $t1, 16
	srl $t0, $t0, 24
	srl $t1, $t1, 24
	
	add $v0, $zero, $t0	# Coordenada Y
	add $v1, $zero, $t1	# Coordenada X
	
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $a0, 12($sp)
	addi $sp, $sp, 16
	jr $ra

#==========================================================================================

Displacement:
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $a0, 24($sp)
	
	lw $a0, 0($s0)
	jal GetPosition
	add $t0, $zero, $v0	# Y
	add $t1, $zero, $v1	# X
	jal GetLastDirection
	add $t3, $zero, $v0	# Direccion anterior
	beq $t3, 0, FirstMove
	j NotFirstMove
	
	FirstMove:
		jal GetDirection
		add $t4, $zero, $v0	# Direccion obtenida de los botones
		beq $t4, 1, Up
		beq $t4, 2, Down
		beq $t4, 3, Left
		beq $t4, 4, Right
		j FirstMove
	
	NotFirstMove:
		jal GetDirection
		add $t4, $zero, $v0
		beq $t4, 0, NoDirection
		beq $t3, 1, UpDown
		beq $t3, 2, UpDown
		beq $t3, 3, LeftRight
		beq $t3, 4, LeftRight
		
		UpDown:
			beq $t4, 3, Left
			beq $t4, 4, Right
			j NoDirection
		
		LeftRight:
			beq $t4, 1, Up
			beq $t4, 2, Down
			j NoDirection
		
		NoDirection:
			beq $t3, 1, Up
			beq $t3, 2, Down
			beq $t3, 3, Left
			beq $t3, 4, Right
			j NotFirstMove
		
	Up:	
		addi $t0, $t0, -1
		beq $t0, -1, UpReset
		ContinueUp:
		addi $t2, $zero, 0x11
		j ExitDirection
		UpReset:
			addi $t0, $zero, 31
			j ContinueUp
	Down:
		addi $t0, $t0, 1
		beq $t0, 32, DownReset
		ContinueDown:
		addi $t2, $zero, 0x12
		j ExitDirection
		DownReset:
			add $t0, $zero, $zero
			j ContinueDown
	Left:
		addi $t1, $t1, -1
		beq $t1, -1, LeftReset
		ContinueLeft:
		addi $t2, $zero, 0x13
		j ExitDirection
		LeftReset:
			addi $t1, $zero, 31 
			j ContinueLeft
	Right:
		addi $t1, $t1, 1
		beq $t1, 32, RightReset
		ContinueRight:
		addi $t2, $zero, 0x14
		j ExitDirection
		RightReset:
			add $t1, $zero, $zero
			j ContinueRight
		
	ExitDirection:
		sll $t2, $t2, 8
		add $t2, $t2, $t0	# PosY
		sll $t2, $t2, 8
		add $t2, $t2, $t1	# PosX
		sll $t2, $t2, 8
		addi $t2, $t2, 0xF0	# RGB
		sw $t2, 0($s0)
		
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $a0, 24($sp)
	addi $sp, $sp, 28
	jr $ra

#==========================================================================================

GetLastDirection:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $a0, 8($sp)
	
	add $t0, $zero, $a0
	sll $t0, $t0, 4
	srl $t0, $t0, 28
	add $v0, $zero, $t0	# Direction
	
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 12
	jr $ra

#==========================================================================================

GetDirection:
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $ra, 4($sp)
	
	lw $t0, 0xFFFF0000	# IODirection (Hardware)
	add $v0, $zero, $t0
	
	lw $t0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

#==========================================================================================

Snake2Food:
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $t6, 28($sp)
	
	add $t6, $zero, $a0 # Dato anterior
	add $t0, $zero, $zero
	add $t1, $zero, $s0

	LoopS2F:
		beq $t0, $s1, ExitLoopS2F
		addi $t0, $t0, 1
		addi $t1, $t1, 4
		j LoopS2F
		
	ExitLoopS2F:
		lw $a0, 0($t1)
		jal GetPosition
		add $t2, $zero, $v0	# Y Comida
		add $t3, $zero, $v1	# X Comida
		lw $a0, 0($s0)
		jal GetPosition
		add $t4, $zero, $v0	# Y Cabeza
		add $t5, $zero, $v1	# X Cabeza
		sub $t2, $t2, $t4
		sub $t3, $t3, $t5
		or $t2, $t2, $t3
		beq $t2, 0, Time2Eat
		j ExitS2F

	Time2Eat:
		andi $t6, $t6, 0x0FFFFFFF
		addi $t6, $t6, 0x20000000
		sw $t6, 0($t1)
		addi $s1, $s1, 1
		jal SpawnFood

		
	ExitS2F:
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	lw $t6, 28($sp)
	addi $sp, $sp, 32
	jr $ra
		
#==========================================================================================

CopyData:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)

	add $t0, $zero, $zero		# Contador
	add $t1, $zero, $s0		# Dato de cabeza
	add $t2, $a0, $zero		# Dato anterior de cabeza
	CopyLoop:
		addi $t0, $t0, 1
		addi $t1, $t1, 4
		beq $t0, $s1, ExitCopy
		lw $t3, 0($t1)
		sll $t2, $t2, 4
		srl $t2, $t2, 4
		addi $t2, $t2, 0x20000000
		sw $t2, 0($t1)
		add $t2, $t3, $zero
		j CopyLoop
	
	ExitCopy:
		add $v0, $zero, $t2
		
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)	
	addi $sp, $sp, 20
	jr $ra
	
#==========================================================================================

DeleteShadow:
	addi $sp, $sp,-24 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $a0, 12($sp)
	sw $a1, 16($sp)
	sw $ra, 20($sp)
	
	jal GetPosition
	lw $a1, 16($sp)
	add $t0, $zero, $v0	# Y
	add $t1, $zero, $v1	# X
	
	add $t2, $zero, $zero	# Status, Direction
	add $t2, $zero, $t0	# PosY
	sll $t2, $t2, 8
	add $t2, $t2, $t1	# PosX
	sll $t2, $t2, 8
	addi $t2, $t2, 0x00	# RGB
	sw $t2, 0($a1)		# Se actualiza la casilla
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $a0, 12($sp)
	lw $a1, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	jr $ra

#==========================================================================================

Delay:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	
	add $t0, $zero, $zero
	lw $t1, 0xFFFF0004		# IOSpeed (Hardware)
	sll $t1, $t1, 16
	add $t1, $t1, 0x000F0000	# Retardo minimo
	
	LoopDelay:
		addi $t0, $t0, 1
		beq $t0, $t1, ExitDelay
		j LoopDelay
	
	ExitDelay:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra 

#==========================================================================================

Collision:
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	
	add $t0, $zero, $s0
	add $t1, $zero, $zero
	lw $a0, 0($t0)
	jal GetPosition
	add $t2, $zero, $v0		# Y Cabeza
	add $t3, $zero, $v1		# X Cabeza
	
	CollisionLoop:
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		add $v0, $zero, $zero
		beq $t1, $s1, ExitCollision
		lw $a0, 0($t0)
		jal GetPosition
		add $t4, $v0, $zero	# Y Cuerpo
		add $t5, $v1, $zero	# X Cuerpo
		sub $t4, $t2, $t4
		sub $t5, $t3, $t5
		or $t4, $t4, $t5
		beq $t4, 0, CollisionDetected
		j CollisionLoop

	CollisionDetected:
		addi $v0, $zero, 1
		
	ExitCollision:
		lw $ra, 0($sp)
		lw $t0, 4($sp)
		lw $t1, 8($sp)
		lw $t2, 12($sp)
		lw $t3, 16($sp)
		lw $t4, 20($sp)
		lw $t5, 24($sp)
		addi $sp, $sp, 28
		jr $ra

#==========================================================================================