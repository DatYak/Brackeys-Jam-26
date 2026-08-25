class_name CharacterStats extends Node

enum SkillType {
	MIGHT,
	GUILE,
	FAVOR
}

const MAX_HEALTH = 2
const MAX_SANITY = 4
const MAX_LOYALTY = 10

# Variables
@export var health = MAX_HEALTH
@export var sanity = MAX_SANITY
@export var loyalty = MAX_LOYALTY

@export var might = 0
@export var guile = 0
@export var favor = 0

# Events
signal took_damage(amount)
signal received_healing(amount)
signal health_updated(old_health, new_health)
signal died

signal lost_sanity(amount)
signal restored_sanity(amount)
signal sanity_updated(old_sanity, new_sanity)
signal lost_all_sanity

signal lost_loyalty(amount)
signal gained_loyalty(amount)
signal loyalty_updated(old_loyalty, new_loyalty)
signal lost_all_loyalty

func set_stats(_might, _guile, _favor, _loyalty):
	might = _might
	guile = _guile
	favor = _favor
	loyalty = _loyalty

func get_skill(skillType : SkillType):
	match skillType:
		SkillType.MIGHT:
			return might
		SkillType.GUILE:
			return guile
		SkillType.FAVOR:
			return loyalty

# Health Functions
func take_damage(_damage: int) -> void:
	took_damage.emit(_damage)
	_set_health(health - _damage)

func receive_healing(_heal: int) -> void:
	received_healing.emit(_heal)
	_set_health(health + _heal)

func _set_health(_new_health: int) -> void:
	if (_new_health > MAX_HEALTH):
		_new_health = MAX_HEALTH
	
	health_updated.emit(health, _new_health)
	health = _new_health
	
	if health <= 0:
		died.emit()


# Sanity Functions
# I decided to just copy paste for easy bespoke events, but I would compartmentalize if it wasn't a game jam

func lose_sanity(_sanity_lost: int) -> void:
	lost_sanity.emit(_sanity_lost)
	_set_sanity(sanity - _sanity_lost)

func restore_sanity(_restoration: int) -> void:
	restored_sanity.emit(_restoration)
	_set_sanity(sanity + _restoration)

func _set_sanity(_new_sanity: int) -> void:
	if (_new_sanity > MAX_SANITY):
		_new_sanity = MAX_SANITY
	
	sanity_updated.emit(sanity, _new_sanity)
	sanity = _new_sanity
	
	if sanity <= 0:
		lost_all_sanity.emit()


# Loyalty Functions
# I decided to just copy paste for easy bespoke events, but I would compartmentalize if it wasn't a game jam

func lose_loyalty(_loyalty_lost: int) -> void:
	lost_loyalty.emit(_loyalty_lost)
	_set_loyalty(loyalty - _loyalty_lost)

func gain_loyalty(_loyalty_gained: int) -> void:
	gained_loyalty.emit(_loyalty_gained)
	_set_loyalty(loyalty + _loyalty_gained)

func _set_loyalty(_new_loyalty: int) -> void:
	if (_new_loyalty > MAX_LOYALTY):
		_new_loyalty = MAX_LOYALTY
	
	loyalty_updated.emit(loyalty, _new_loyalty)
	loyalty = _new_loyalty
	
	if loyalty <= 0:
		lost_all_loyalty.emit()
