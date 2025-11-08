extends Node3D

@onready var front_desk: Node3D = $"."
@onready var player_service_area: Area3D = $PlayerServiceArea
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

var front_desk_original_material: Material = Material.new() # placeholder
var highlight_material: Material = Material.new() # placeholder

var active_player: Node3D = null
var active_customer: Node3D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Front desk running")
	front_desk_original_material = mesh_instance_3d.get_active_material(0).duplicate()
	highlight_material = front_desk_original_material.duplicate()
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(1, 1, 0.4)

func _looks_at_desk(body: Node3D) -> bool:
	var pos_vec = (front_desk.global_position - body.global_position).normalized()
	var direction = (-body.global_transform.basis.z) # Global forward direction
	return pos_vec.dot(direction) > 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player_interacting = active_player and _looks_at_desk(active_player)
	if player_interacting:
		mesh_instance_3d.set_surface_override_material(0, highlight_material)
	else:
		mesh_instance_3d.set_surface_override_material(0, front_desk_original_material)

	var player_action = Input.get_action_strength("player1_action")
	if player_action > 0.5 and player_interacting:
		if active_customer != null:
			if active_customer.name != "Customer":
				print("BUG: active_customer is not Customer")
			if active_player.currently_carrying:
				print("Handing ", active_player.currently_carrying, " to customer")
				active_customer.purchase(active_player.currently_carrying)


func _on_player_service_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		active_player = body
		print("Player entered desk")


func _on_player_service_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		active_player = null
		print("Player left desk")


func _on_customer_area_body_entered(body: Node3D) -> void:
	if body.name == "Customer":
		print("Customer present")
		active_customer = body

func _on_customer_area_body_exited(body: Node3D) -> void:
	if body.name == "Customer":
		print("Customer left")
		active_customer = null
