class_name CharacterStats extends Node

const MAX_HEALTH = 10
const MAX_SANITY = 10

# Variables
var health = 10
var sanity = 10

# Events
signal took_damage(amount)
signal received_healing(amount)
signal health_updated(old_health, new_health)
signal died

signal lost_sanity(amount)
signal restored_sanity(amount)
signal sanity_updated(old_sanity, new_sanity)
signal lost_all_sanity

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
	took_damage.emit(_sanity_lost)
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
