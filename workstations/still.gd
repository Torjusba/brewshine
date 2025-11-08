extends Node3D
class_name Still

@onready var player_service_area: Area3D = $PlayerServiceArea
@onready var making_moonshine_timer: Timer = $MakingMoonshineTimer
@onready var still_floor: MeshInstance3D = $StillFloor

const MoonshineScene = preload("res://ingredients/moonshine.tscn")

var original_material: Material = Material.new() # placeholder
var highlight_material: Material = Material.new() # placeholder

var active_player: Node3D = null
var moonshine: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_material = still_floor.get_active_material(0).duplicate()
	highlight_material = original_material.duplicate()
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(1, 1, 0.4)
	making_moonshine_timer.start()  # TODO require an action with water and coffee beans

func _looks_at_desk(body: Node3D) -> bool:
	var pos_vec = (self.global_position - body.global_position).normalized()
	var direction = (-body.global_transform.basis.z) # Global forward direction
	return pos_vec.dot(direction) > 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player_interacting = active_player and _looks_at_desk(active_player)
	if player_interacting:
		still_floor.set_surface_override_material(0, highlight_material)
	else:
		still_floor.set_surface_override_material(0, original_material)

	var player_action = Input.get_action_strength("player1_action")
	if player_action > 0.5 and player_interacting:
		if moonshine and not active_player.currently_carrying:
			active_player.pickup(moonshine)
			print("Still hands cup to player")
			making_moonshine_timer.start()  # TODO require an action with water and coffee beans
			moonshine = null

func _on_player_service_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		active_player = body


func _on_player_service_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		active_player = null


func _on_making_moonshine_timer_timeout() -> void:
	if moonshine:
		return  # already have a cup
	moonshine = MoonshineScene.instantiate()
	add_child(moonshine)
	moonshine.global_position = $MoonshinePosition.global_position
	print("Made a cup of moonshine: ", moonshine)
