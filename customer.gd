extends CharacterBody3D
class_name Customer3D

# Placeholders
var leave_position: Vector3 = Vector3.ZERO
@onready var queue_ray_cast: RayCast3D = $QueueRayCast
@onready var wants_moonshine_sprite: Sprite3D = $WantsMoonshineSprite

const SPEED = 3.0
var target_position: Vector3 = Vector3.ZERO
var currently_carrying: Node3D = null
var level_manager: LevelManager = null
var wants_moonshine: bool = false

func purchase(item: Sellable3D, price: int) -> void:
	if not level_manager:
		print("BUG: Customer purchase() without LevelManager")
	if not item:
		return
	var wanted_and_got_moonshine = wants_moonshine and item.item_name == "Moonshine"
	var wanted_and_got_coffee = not wants_moonshine and item.item_name == "Coffee"

	var got_what_they_want: bool = wanted_and_got_coffee or wanted_and_got_moonshine
	
	item.reparent($CarryingPosition, false)
	item.position = Vector3.ZERO
	currently_carrying = item
	
	level_manager.add_payment(price if got_what_they_want else 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var to_move_this_tick = delta * SPEED
	var move_vector = Vector3(target_position - position)
	if move_vector.length() > to_move_this_tick:
		move_vector = move_vector.normalized() * to_move_this_tick

	if not queue_ray_cast.is_colliding():
		position += move_vector

	if currently_carrying:
		target_position = leave_position

	if position.distance_to(target_position) <= 0.1:
		rotation_degrees.y = -90
		if wants_moonshine:
			wants_moonshine_sprite.visible = true
		
	else:
		rotation_degrees.y = 0
		wants_moonshine_sprite.visible = false

	
	if position.distance_to(leave_position) <= 1.0:
		queue_free()
