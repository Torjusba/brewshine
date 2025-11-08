extends Customer3D
class_name Policeman3D

const YELLOW_WARNING = preload("uid://ckgrg3n8lle36")
const RED_WARNING = preload("uid://vjnpla1w37up")

const KINDA_SUSPICIOUS_DISTANCE = 10.0
const KINDA_SUSPICIOUSNESS_PER_SECOND = 10
const SUPER_SUSPICIOUS_DISTANCE = 5.0
const SUPER_SUSPICIOUSNESS_PER_SECOND = 20
const DEFAULT_SUSPICIOUSNESS_PER_SECOND = -10

@onready var warning_sprite: Sprite3D = $WarningSprite

var garage_gate: GarageGate = null
var suspiciousness_pct: float = 0.0


func purchase(item: Item3D, price: int) -> void:
	if item.item_name == "Moonshine":
		level_manager.lose("You sold moonshine to a cop")
	super.purchase(item, price)

func _process(delta: float) -> void:
	super._process(delta)
	var delta_suspiciousness = DEFAULT_SUSPICIOUSNESS_PER_SECOND
	assert(garage_gate != null)
	if garage_gate.is_open:
		var distance_to_target_position = self.position.distance_to(target_position)
		if distance_to_target_position <= SUPER_SUSPICIOUS_DISTANCE:
			delta_suspiciousness = SUPER_SUSPICIOUSNESS_PER_SECOND
		elif distance_to_target_position <= KINDA_SUSPICIOUS_DISTANCE:
			delta_suspiciousness = KINDA_SUSPICIOUSNESS_PER_SECOND
	
	suspiciousness_pct += delta_suspiciousness * delta
	if suspiciousness_pct < 0:
		suspiciousness_pct = 0
	
	if suspiciousness_pct >= 100:
		level_manager.lose("You failed to hide your moonshine from the cops")
		
	if suspiciousness_pct >= 50:
		warning_sprite.visible = true
		warning_sprite.texture = RED_WARNING
	elif suspiciousness_pct >= 10:
		warning_sprite.visible = true
		warning_sprite.texture = YELLOW_WARNING
	else:
		warning_sprite.visible = false
		
