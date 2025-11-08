extends Node3D

@onready var front_desk: Node3D = $"."
@onready var player_service_area: Area3D = $PlayerServiceArea
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var making_coffee_timer: Timer = $MakingCoffeeTimer
@onready var brewing_particles: CPUParticles3D = $BrewingParticles

var needs_water: bool = true
var needs_coffee_beans: bool = false
@onready var needs_water_sprite: Sprite3D = $NeedsWaterSprite
@onready var needs_coffee_beans_sprite: Sprite3D = $NeedsCoffeeSprite

const CoffeeCupScene = preload("res://ingredients/coffee_cup.tscn")

var original_material: Material = Material.new() # placeholder
var highlight_material: Material = Material.new() # placeholder

var active_player: Player = null
var coffee_cup: Item3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Coffee maker running")
	original_material = mesh_instance_3d.get_active_material(0).duplicate()
	highlight_material = original_material.duplicate()
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(1, 1, 0.4)
	making_coffee_timer.start()  # TODO require an action with water and coffee beans

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
		mesh_instance_3d.set_surface_override_material(0, original_material)

	if player_interacting and active_player.is_attempting_action:
		if active_player.currently_carrying:
			if active_player.currently_carrying.item_name == "Water":
				needs_water = false
				active_player.currently_carrying.queue_free()
				active_player.currently_carrying = null
			elif active_player.currently_carrying.item_name == "CoffeeBeans":
				needs_coffee_beans = false
				active_player.currently_carrying.queue_free()
				active_player.currently_carrying = null
			else:
				print("Player tried to hand the coffee maker a ", active_player.currently_carrying.item_name, " but it was rejected")
		elif coffee_cup:
			active_player.pickup(coffee_cup)
			print("CoffeeMaker hands cup to player")
			coffee_cup = null

	needs_coffee_beans_sprite.visible = needs_coffee_beans
	needs_water_sprite.visible = needs_water

	var can_make_coffee = not (needs_coffee_beans or needs_water)
	if can_make_coffee and making_coffee_timer.is_stopped():
		print("DEBUG: starting coffee timer")
		making_coffee_timer.start()  # TODO require an action with water and coffee beans
		brewing_particles.emitting = true

func _on_player_service_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		active_player = body


func _on_player_service_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		active_player = null


func _on_making_coffee_timer_timeout() -> void:
	if coffee_cup:
		return  # already have a cup
	coffee_cup = CoffeeCupScene.instantiate()
	add_child(coffee_cup)
	coffee_cup.global_position = $CoffeeCupPosition.global_position
	print("Made a cup of coffee: ", coffee_cup)
	needs_coffee_beans = true
	needs_water = true
	brewing_particles.emitting = false
