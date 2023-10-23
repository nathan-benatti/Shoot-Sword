extends CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = -1
var playerDetected = false
var WALK_SPEED = 50
var RUN_SPEED = 400
var chase = false
var isRunning=false
var HP = 3
var isDead = false
var isHurt = false

func _ready():
	$Walk_Timer.start()
func _physics_process(delta):
	if !isHurt or (!isHurt and !isDead):
		apply_gravity(delta)
		handle_walk()
		handle_run()
	move_and_slide()
	
func apply_gravity(delta):
	velocity.y = gravity*delta
	
func handle_walk():
	if !chase:
		if direction == -1:
			$AnimatedSprite2D.flip_h = false
			$PlayerDetection/FacingLeft.disabled = false
			$PlayerDetection/FacingRight.disabled = true
		elif direction == 1:
			$AnimatedSprite2D.flip_h = true
			$PlayerDetection/FacingLeft.disabled = true
			$PlayerDetection/FacingRight.disabled = false
		velocity.x = direction * WALK_SPEED
		$AnimatedSprite2D.play("Walk")
				
func _on_timer_timeout():
	if !chase:
		if direction == 1:
			direction = -1
		else: direction = 1
func handle_run():
	if chase:
		if !isRunning:
			velocity.x = 0
			$AnimatedSprite2D.play("Staring")
		await $AnimatedSprite2D.animation_finished
		if !isRunning:
			boar_run_timer()
		velocity.x = direction * RUN_SPEED
		$AnimatedSprite2D.play("Run")
func boar_run_timer():
		$Run_Timer.start()
		isRunning = true
				
func _on_run_timer_timeout():
	chase = false
	isRunning = false
	
func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true
	
func _on_damage_area_body_entered(body):
	if body.name =="Player":
		Game.foe_dir = direction
		Game.isHit = true

func _on_boar_body_area_entered(area):
	if area.is_in_group("Attack"):
		HP -= 1
		if HP <=0:
			isHurt=true
			death()
		else: 
			hurt()                                                                                                   
func hurt():
	isHurt = true
	velocity.x = move_toward(0,Game.facing_dir*200,100)
	$AnimatedSprite2D.play("Hit-Vanish")
	await $AnimatedSprite2D.animation_finished
	isHurt = false
	isRunning = false
	
	
func death():
	velocity.x = 0
	chase = false
	isDead = true
	$AnimatedSprite2D.play("Hit-Vanish")
	await $AnimatedSprite2D.animation_finished
	queue_free()


