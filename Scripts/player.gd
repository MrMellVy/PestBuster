extends CharacterBody2D

@export var PlayerSprite: AnimatedSprite2D
@export var PlayerCollider: CollisionShape2D

# Horizontal Movement
@export_category("Movement")
@export_range(50, 500) var maxSpeed: float = 200.0
@export_range(0, 4) var timeToMaxSpeed: float = 0.2
@export_range(0, 4) var timeToZeroSpeed: float = 0.2
@export var directionalSnap: bool = false
@export var runningModifier: bool = false

# Jumping
@export_category("Jumping and Gravity")
@export_range(0, 20) var jumpHeight: float = 2.0
@export_range(0, 4) var jumps: int = 1
@export_range(0, 100) var gravityScale: float = 20.0
@export_range(0, 1000) var terminalVelocity: float = 500.0
@export_range(0.5, 3) var descendingGravityFactor: float = 1.3
@export var VariableJumpHeight: bool = true
@export_range(1, 10) var jumpVariable: float = 2
@export_range(0, 0.5) var coyoteTime: float = 0.2
@export_range(0, 0.5) var jumpBuffering: float = 0.2

# Extra Mech
@export_category("Wall Jumping")
@export var wallJump: bool = false
@export_range(0, 0.5) var inputPauseAfterWallJump: float = 0.1
@export_range(0, 90) var wallKickAngle: float = 60.0
@export_range(1, 20) var wallSliding: float = 1.0
@export var wallLatching: bool = false
@export var wallLatchingModifer: bool = false

# Dashing
@export_category("Dashing")
@export_enum("None", "Horizontal", "Vertical", "Four Way") var dashType: int
@export_range(0, 10) var dashes: int = 1
@export var dashCancel: bool = true
@export_range(1.5, 4) var dashLength: float = 2.5

# Animation
@export_category("Animations")
@export var run: bool
@export var jump: bool
@export var idle: bool
@export var walk: bool
@export var slide: bool
@export var latch: bool
@export var falling: bool

#Attack
@onready var deal_damage_zone = $DealDamageZone

# Dev Variable and const
var appliedGravity: float
var maxSpeedLock: float
var appliedTerminalVelocity: float

var friction: float
var acceleration: float
var deceleration: float
var instantAccel: bool = false
var instantStop: bool = false

var jumpMagnitude: float = 500.0
var jumpCount: int = 0
var jumpWasPressed: bool = false
var coyoteActive: bool = false
var dashMagnitude: float
var gravityActive: bool = true
var dashing: bool = false
var dashCount: int
const MAX_JUMPS: int = 2

var twoWayDashHorizontal
var twoWayDashVertical

var wasMovingR: bool
var wasPressingR: bool
var movementInputMonitoring: Vector2 = Vector2(true, true)

var gdelta: float = 1

var dset = false

var colliderScaleLockY
var colliderPosLockY

var latched
var wasLatched

var attack_type: String
var current_attack: bool

var anim
var col
var animScaleLock : Vector2

# Input Variable
var leftHold
var leftTap
var leftRelease
var rightHold
var rightTap
var rightRelease
var jumpTap
var jumpRelease
var runHold
var latchHold
var dashTap

func _ready() -> void:
	Global.playerBody = self
	current_attack = false
	wasMovingR = true
	anim = PlayerSprite
	col = PlayerCollider
	
	_updateData()
	
func _updateData():
	acceleration = maxSpeed / timeToMaxSpeed
	deceleration = -maxSpeed / timeToZeroSpeed
	
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps
	
	dashMagnitude = maxSpeed * dashLength
	dashCount = dashes
	
	maxSpeedLock = maxSpeed
	
	animScaleLock = abs(anim.scale)
	colliderScaleLockY = col.scale.y
	colliderPosLockY = col.position.y
	
	if timeToMaxSpeed == 0:
		instantAccel = true
		timeToMaxSpeed = 1
	elif timeToMaxSpeed < 0:
		timeToMaxSpeed = abs(timeToMaxSpeed)
		instantAccel = false
	else :
		instantAccel = false
		
	if timeToZeroSpeed == 0:
		instantStop = true
		timeToZeroSpeed = 1
	elif timeToZeroSpeed < 0:
		timeToZeroSpeed = abs(timeToZeroSpeed)
		instantStop = false
	else :
		instantStop = false
		
	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0
		
	coyoteTime = abs(coyoteTime)
	jumpBuffering = abs(jumpBuffering)
	
	if directionalSnap:
		instantAccel = true
		instantStop = true
		
	twoWayDashHorizontal = false
	twoWayDashVertical = false
	if dashType == 0:
		pass
	if dashType == 1:
		twoWayDashHorizontal = true
	elif dashType == 2:
		twoWayDashVertical = true
	elif dashType == 3:
		twoWayDashHorizontal = true
		twoWayDashVertical = true
		
func _process(_delta) -> void:
	# Direction
	if is_on_wall() and !is_on_floor() and latch and wallLatching and ((wallLatchingModifer and latchHold) or !wallLatchingModifer):
		latched = true
	else :
		latched = false
		wasLatched = true
		_setLatch(0.2, false)
		
	if rightHold and !latched:
		anim.scale.x = animScaleLock.x
	if leftHold and !latched:
		anim.scale.x = animScaleLock.x * -1
		
	# Run
	if !current_attack:
		if run and idle and !dashing:
			if abs(velocity.x) > 0.1 and is_on_floor() and !is_on_wall():
				anim.speed_scale = abs(velocity.x / 150)
				anim.play("run")
			elif abs(velocity.x) < 0.1 and is_on_floor():
				anim.speed_scale = 1
				anim.play("idle")
	
	# Jump
	if !current_attack:
		if velocity.y < 0 and jump and !dashing:
			anim.speed_scale = 1
			anim.play("jump")
			
		if velocity.y > 40 and falling and !dashing:
			anim.speed_scale = 1
			anim.play("falling")
		
	if latch and slide:
		# Wall slide & latch
		if latched and !wasLatched:
			anim.speed_scale = 1
			anim.play("latch")
		if is_on_wall() and velocity.y > 0 and slide and anim.animation != "slide" and wallSliding != 1:
			anim.speed_scale = 1
			anim.play("slide")
	
	# Dashing
	if dashing:
			anim.speed_scale = 1
			anim.play("dash")

func _physics_process(delta) -> void:
	if !dset:
		gdelta = delta
		dset = true
	if !current_attack:
			if Input.is_action_just_pressed("attack"):
				current_attack = true
				attack_type = "single" if is_on_floor() else "air"
				handle_attack_animation(attack_type)
			elif Input.is_action_just_pressed("double"):
				current_attack = true
				attack_type = "double" if is_on_floor() else "air"
				handle_attack_animation(attack_type)
	# Input Detection
	leftHold = Input.is_action_pressed("left")
	rightHold = Input.is_action_pressed("right")
	leftTap = Input.is_action_just_pressed("left")
	rightTap = Input.is_action_just_pressed("right")
	leftRelease = Input.is_action_just_released("left")
	rightRelease = Input.is_action_just_released("right")
	jumpTap = Input.is_action_just_pressed("jump")
	jumpRelease = Input.is_action_just_released("jump")
	latchHold = Input.is_action_pressed("latch")
	dashTap = Input.is_action_just_pressed("dash")
	
	# L/R Movement
	if rightHold and leftHold and movementInputMonitoring:
		if !instantStop:
			_decelerate(delta, false)
		else:
			velocity.x = -0.1
	elif rightHold and movementInputMonitoring.x:
		if velocity.x > maxSpeed or instantAccel:
			velocity.x = maxSpeed
		else:
			velocity.x += acceleration * delta
		if velocity.x < 0:
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = -1
	elif leftHold and movementInputMonitoring.y:
		if velocity.x < -maxSpeed or instantAccel:
			velocity.x = -maxSpeed
		else:
			velocity.x -= acceleration * delta
		if velocity.x > 0:
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = 0.1
				
	if velocity.x > 0:
		wasMovingR = true
	elif velocity.x < 0:
		wasMovingR = false
		
	if rightTap:
		wasPressingR = true
	if leftTap:
		wasPressingR = false
		
	if runningModifier:
		maxSpeed = maxSpeedLock / 2
	elif is_on_floor(): 
		maxSpeed = maxSpeedLock
		
	if !(leftHold or rightHold):
		if !instantStop:
			_decelerate(delta, false)
		else:
			velocity.x = 0
			
	#Double Jump
	if is_on_floor():
		jumpCount = 0
	else:
		if jumpCount == 0:
			jumpCount += 1
			
	# Jump and Gravity
	if velocity.y > 0:
		appliedGravity = gravityScale * descendingGravityFactor
	else:
		appliedGravity = gravityScale
		
	if is_on_wall():
		appliedTerminalVelocity = terminalVelocity / wallSliding
		if wallLatching and ((wallLatchingModifer and latchHold) or !wallLatchingModifer):
			appliedGravity = 0
			
			if velocity.y < 0:
				velocity.y += 50
			if velocity.y > 0:
				velocity.y = 0
				
			if wallLatchingModifer and latchHold and movementInputMonitoring == Vector2(true, true):
				velocity.x = 0
				
		elif wallSliding != 1 and velocity.y > 0:
			appliedGravity = appliedGravity / wallSliding
	elif !is_on_wall():
		appliedTerminalVelocity = terminalVelocity
		
	if gravityActive:
		if velocity.y < appliedTerminalVelocity:
			velocity.y += appliedGravity
		elif velocity.y > appliedTerminalVelocity:
				velocity.y = appliedTerminalVelocity
				
	if VariableJumpHeight and jumpRelease and velocity.y < 0:
		velocity.y = velocity.y / jumpVariable
		
	if jumps == 1:
		if !is_on_floor() and !is_on_wall():
			if coyoteTime > 0:
				coyoteActive = true
				_coyoteTime()
				
		if jumpTap and !is_on_wall():
			if coyoteActive:
				coyoteActive = false
				_jump()
			if jumpBuffering > 0:
				jumpWasPressed = true
				_bufferJump()
			elif jumpBuffering == 0 and coyoteTime == 0 and is_on_floor():
				_jump()
		elif jumpTap and is_on_wall() and !is_on_floor():
			if wallJump and !latched:
				_wallJump()
			elif wallJump and latched:
				_wallJump()
		elif jumpTap and is_on_floor():
			_jump()
			
		if is_on_floor():
			jumpCount = jumps
			if coyoteTime > 0:
				coyoteActive = true
			else:
				coyoteActive = false
			if jumpWasPressed:
				_jump()
				

		
	# Dashing
	if is_on_floor():
		dashCount = dashes
	if twoWayDashHorizontal and dashTap and dashCount > 0:
		var dTime = 0.0625 * dashLength
		if wasPressingR:
			velocity.y = 0
			velocity.x = dashMagnitude
			_pauseGravity(dTime)
			_dashingTime(dTime)
			dashCount += -1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
		else:
			velocity.y = 0
			velocity.x = -dashMagnitude
			_pauseGravity(dTime)
			_dashingTime(dTime)
			dashCount += -1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
			
	if dashing and velocity.x > 0 and leftTap and dashCancel:
		velocity.x = 0
	if dashing and velocity.x < 0 and rightTap and dashCancel:
		velocity.x = 0
		
	move_and_slide()
	
func _bufferJump():
	await get_tree().create_timer(jumpBuffering).timeout
	jumpWasPressed = false
	
func _coyoteTime():
	await get_tree().create_timer(coyoteTime).timeout
	coyoteActive = false
	jumpCount += -1
	
func _jump():
	if jumpCount > 0:
		velocity.y = -jumpMagnitude
		jumpCount += -1
		jumpWasPressed = false
		
func _wallJump():
	var horizontalWallKick = abs(jumpMagnitude * cos(wallKickAngle * (PI / 180)))
	var verticalWallKick = abs(jumpMagnitude * sin(wallKickAngle * (PI / 180)))
	velocity.y = -verticalWallKick
	var dir = 1
	if wallLatchingModifer and latchHold:
		dir = -1
	if wasMovingR:
		velocity.x = -horizontalWallKick  * dir
	else:
		velocity.x = horizontalWallKick * dir
	if inputPauseAfterWallJump != 0:
		movementInputMonitoring = Vector2(false, false)
		_inputPauseReset(inputPauseAfterWallJump)
		
func _setLatch(delay, setBool):
	await get_tree().create_timer(delay).timeout
	wasLatched = setBool
			
func _inputPauseReset(time):
	await get_tree().create_timer(time).timeout
	movementInputMonitoring = Vector2(true, true)
	
func _decelerate(delta, vertical):
	if !vertical:
		if (abs(velocity.x) > 0) and (abs(velocity.x) <= abs(deceleration * delta)):
			velocity.x = 0 
		elif velocity.x > 0:
			velocity.x += deceleration * delta
		elif velocity.x < 0:
			velocity.x -= deceleration * delta
	elif vertical and velocity.y > 0:
		velocity.y += deceleration * delta
		
func _pauseGravity(time):
	gravityActive = false
	await get_tree().create_timer(time).timeout
	gravityActive = true

func _dashingTime(time):
	dashing = true
	await get_tree().create_timer(time).timeout
	dashing = false
	if !is_on_floor():
		velocity.y = -gravityScale * 10


#Attack 
func handle_attack_animation(attack_type):
	if current_attack:
		var random_vari = randi_range(1, 3)
		var animation = str(attack_type, "_attack_", random_vari)
		PlayerSprite.play(animation)


#func set_damage(attack_type):
	#var current_damage_to_deal: int
	#if attack_type == "single":
		#current_damage_to_deal = 8
	#elif attack_type == "double":
		#current_damage_to_deal = 16
	#elif attack_type == "air":
		#current_damage_to_deal = 20
		#Global.playerDamageAmount = current_damage_to_deal


func _on_animated_sprite_2d_animation_finished() -> void:
	if current_attack and ("_attack_" in PlayerSprite.animation):
		current_attack = false
