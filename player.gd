extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 300
var JUMP_SPEED = -500
var isAttacking = false
var isCrouching = false
var isHurt = false
var blinking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AttackArea2/Slash.flip_h=true
func _physics_process(delta):
	if !Game.isDead:
		apply_gravity(delta)
		handle_movement()
		handle_jump()
		handle_attack()
		handle_crouch()
		blinking_hurt()
	if Game.isHit:
		is_player_hitted()
	move_and_slide()
func handle_movement():
	var direction = Input.get_axis("Left","Right")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
		Game.facing_dir = -1
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false
		Game.facing_dir = 1
	if direction and !isAttacking:
		velocity.x = direction * SPEED
		if velocity.y==0:
			$AnimatedSprite2D.play("Run")
	elif !isAttacking and !isAttacking:
		velocity.x = move_toward(velocity.x,0,SPEED)
		if velocity.y==0:
			$AnimatedSprite2D.play("Idle")
		
func handle_jump():
	if Input.is_action_just_pressed("Jump") and is_on_floor() and !isAttacking and !isCrouching:
		$AnimatedSprite2D.play("Jump")
		velocity.y = JUMP_SPEED
	elif velocity.y>0 and !isAttacking:
		$AnimatedSprite2D.play("Falling")
		
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity*delta
		
func handle_attack():
	if Input.is_action_just_pressed("Attack") and !isCrouching:
		$AnimatedSprite2D.play("Attack")
		if Game.facing_dir==1:
			$AttackArea/AttackShape.disabled = false
			$AttackArea/Slash.play("Slash")
		elif Game.facing_dir==-1:
			$AttackArea2/AttackShape.disabled = false
			$AttackArea2/Slash.play("Slash")
			
		
			
		velocity.x = 0
		isAttacking=true

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Attack":
		isAttacking = false
		if not $AttackArea/AttackShape.disabled:
			$AttackArea/AttackShape.disabled = true
		elif not $AttackArea2/AttackShape.disabled:
			$AttackArea2/AttackShape.disabled = true
		
func handle_crouch():
	if Input.is_action_just_pressed("Crouch") and is_on_floor():
		isCrouching = true
	if Input.is_action_just_released("Crouch"):
		isCrouching = false
	if isCrouching:
		velocity.x = 0
		$AnimatedSprite2D.play("Crouch")
		
func is_player_hitted():
	if !isHurt:
		Game.playerHP -= 1
	if Game.playerHP > 0:
		hurt()
	else:
		isHurt = true
		death()
	Game.isHit=false
func hurt():
	isHurt = true
	#velocity.x = move_toward(0,-Game.facing_dir*200,100)
	#$AnimatedSprite2D.play("Hurt")
	#await $AnimatedSprite2D.animation_finished:		
	$HurtTimer.start()
	$BlinkingTimer.start()
func blinking_hurt():
	if isHurt:
		if blinking:
			$AnimatedSprite2D.modulate.a = 0.25
		else:
			$AnimatedSprite2D.modulate.a = 1
		
func _on_hurt_timer_timeout():
	isHurt=false
	$AnimatedSprite2D.modulate.a = 1
func _on_blinking_timer_timeout():
	if blinking:blinking=false
	else:blinking=true # Replace with function body.
		
func death():
	Game.isDead = true
	velocity.x = 0
	$AnimatedSprite2D.play("Death")
	await $AnimatedSprite2D.animation_finished
	queue_free()







