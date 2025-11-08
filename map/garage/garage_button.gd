extends Node3D

@export var garage_gate: GarageGate
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

var original_material: Material = Material.new() # placeholder
var highlight_material: Material = Material.new() # placeholder

var active_player: Player = null
var coffee_cup: Item3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_material = mesh_instance_3d.get_active_material(0).duplicate()
	highlight_material = original_material.duplicate()
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(1, 1, 0.4)

func _looks_at_this(body: Node3D) -> bool:
	var pos_vec = (self.global_position - body.global_position).normalized()
	var direction = (-body.global_transform.basis.z) # Global forward direction
	return pos_vec.dot(direction) > 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# TODO tune _looks_at_this, didn't work well for this small button
	var player_interacting = active_player #  and _looks_at_this(active_player)
	if player_interacting:
		mesh_instance_3d.set_surface_override_material(0, highlight_material)
	else:
		mesh_instance_3d.set_surface_override_material(0, original_material)
	if player_interacting and active_player.is_attempting_action:
		if garage_gate:
			garage_gate.toggle()
		else:
			print("BUG: tried to toggle null garage gate")

func _on_player_service_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print("player in front of door")
		active_player = body

func _on_player_service_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		print("player left the door")
		active_player = null
