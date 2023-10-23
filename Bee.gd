extends CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = -1
var playerDetected = false
var SPEED = 50
var RUN_SPEED = 400
var chase = false
var isRunning=false
var HP = 2
var isDead = false
var isHurt = false
var player
var player_position
var isReturning = false
var initial_position
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	initial_position = position
	$FlyTimer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !isHurt:
		handle_movement()
		handle_attack()
		move_and_slide()
		print(" is Bee chasing ", chase)
		print(" bee position y",position.y)
	
func handle_movement():
	if !chase:
		if direction == 1:
			$AnimatedSprite2D.flip_h=true 
			$PlayerDetection/FacingLeft.disabled = true
			$PlayerDetection/FacingRight.disabled = false
		else:
			$AnimatedSprite2D.flip_h=false
			$PlayerDetection/FacingLeft.disabled = false
			$PlayerDetection/FacingRight.disabled = true
			
		velocity.x = direction*SPEED
		$AnimatedSprite2D.play("Fly")

func handle_attack():
	if chase:
		velocity=Vector2(move_toward(0,player_position.x,direction*300),move_toward(0,player_position.y,300))
		#velocity = Vector2(move_toward(0,player.velocity.x,100),move_toward(0,player.velocity.y,100))
		$AnimatedSprite2D.play("Attack")
		$AnimatedSprite2D.play("Attack2")
		if position.y >= player_position.y:
			chase=false
			isReturning = true
			velocity= Vector2(move_toward(0,player_position.x,-direction*100),move_toward(0,-player_position.y,100))
	if position.y <= initial_position.y and isReturning:
		velocity.y = 0
		isReturning = false
func _on_player_detection_body_entered(body):
	if body.name == "Player" and !isReturning:
		chase=true
		player_position = player.position
		
func _on_fly_timer_timeout():
	if !chase:
		if direction == 1: direction = -1
		else:direction = 1
func _on_damage_area_body_entered(body):
	if body.name == "Player":
		Game.foe_dir = direction
		Game.isHit = true


func _on_damage_area_area_entered(area):
	if area.is_in_group("Attack"):
		HP -= 1
		if HP <=0:
			isHurt=true
			death()
		else: 
			hurt()   
			
func hurt():
	isHurt = true
	#velocity.x = move_toward(0,Game.facing_dir*200,100)
	$AnimatedSprite2D.play("Death")
	await $AnimatedSprite2D.animation_finished
	isHurt = false
		
func death():
	velocity.x = 0
	chase = false
	isDead = true
	$AnimatedSprite2D.play("Death")
	await $AnimatedSprite2D.animation_finished
	queue_free()

