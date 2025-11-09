extends CharacterBody3D
class_name Customer3D

# Placeholders
var leave_position: Vector3 = Vector3.ZERO
@onready var queue_ray_cast: RayCast3D = $QueueRayCast
@onready var status_sprite: Sprite3D = $StatusSprite
@onready var animation_player: AnimationPlayer = $base_character/AnimationPlayer

var camera: Camera3D = null
const WORLDSPACE_Y_OFFSET = 1.7
const CAMERASPACE_Y_OFFSET = 0.5

const SPEED = 2.0
var target_position: Vector3 = Vector3.ZERO
var currently_carrying: Node3D = null
var level_manager: LevelManager = null
var wants_moonshine: bool = false
var is_unhappy: bool = false
const UNHAPPY_WAIT_TIME: float = 1.5

func purchase(item: Item3D, price: int) -> void:
	if not level_manager:
		print("BUG: Customer purchase() without LevelManager")
	if not item:
		return
	var wanted_and_got_moonshine = wants_moonshine and item.item_name == "Moonshine"
	var wanted_and_got_coffee = not wants_moonshine and item.item_name == "Coffee"

	var got_what_they_want: bool = wanted_and_got_coffee or wanted_and_got_moonshine
	
	if not got_what_they_want:
		is_unhappy = true
	
	item.reparent($CarryingPosition, false)
	item.position = Vector3.ZERO
	currently_carrying = item
	
	level_manager.add_payment(price if got_what_they_want else 1)
	if got_what_they_want:
		_on_wait_after_purchase_timer_timeout()
	else:
		$WaitAfterPurchaseTimer.start(UNHAPPY_WAIT_TIME)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

var current_animation_name: String = "Idle"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var to_move_this_tick = delta * SPEED
	var move_vector = Vector3(target_position - position)
	if move_vector.length() > to_move_this_tick:
		move_vector = move_vector.normalized() * to_move_this_tick

	if queue_ray_cast.is_colliding():
		move_vector = Vector3.ZERO
		
	if move_vector.is_zero_approx():
		if is_unhappy:
			current_animation_name = "ShakeHead"
		else:
			current_animation_name = "Idle"
	else:
		current_animation_name = "WalkCycle"
		position += move_vector

	animation_player.play(current_animation_name)

	if (camera):
		var cam_up = camera.global_basis.y.normalized()
		status_sprite.global_position = self.global_position + Vector3.UP * WORLDSPACE_Y_OFFSET + cam_up * CAMERASPACE_Y_OFFSET

	if position.distance_to(target_position) <= 0.1:
		rotation_degrees.y = -90
		if wants_moonshine:
			status_sprite.visible = true
		
	else:
		rotation_degrees.y = 0
		status_sprite.visible = false

	
	if position.distance_to(leave_position) <= 1.0:
		queue_free()


func _on_wait_after_purchase_timer_timeout() -> void:
	target_position = leave_position
