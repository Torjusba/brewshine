extends Node3D
class_name GarageGate

const ANIMATION_NAME: String = "Armature_001Action"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_open: bool = false
@onready var collision_shape_3d: CollisionShape3D = $"Armature_Skeleton3D#StaticBody3D/CollisionShape3D"
@onready var gate_material: StandardMaterial3D = preload("res://map/garage/garage_gate.tres")

func open() -> void:
	if not is_open:
		animation_player.play(ANIMATION_NAME)
		collision_shape_3d.disabled = true
		gate_material.albedo_color.a = 0.5

func close() -> void:
	if is_open:
		animation_player.play_backwards(ANIMATION_NAME)
		# don't re-enable the collision here, we do that when
		# the animation is finished

func toggle() -> void:
	if is_open:
		close()
	else:
		open()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	is_open = !is_open
	if not is_open:
		collision_shape_3d.disabled = false
		gate_material.albedo_color.a = 1.0
