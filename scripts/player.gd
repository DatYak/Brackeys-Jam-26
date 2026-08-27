class_name Player extends Node

const STARTING_SUPPLIES:int = 200
const UNIT_SUPPLY_COST:int = 2

@onready var current_supplies:int = STARTING_SUPPLIES
@onready var label:Label = $UI/Supplies

var current_favor:int = 0
var supply_cost:int = 0

var game:Game

func add_supplies(amnt:int) -> void:
	current_supplies += amnt

func add_favor(favor:int):
	current_favor += favor
	if current_favor > game.FAVOR_PER_BOON:
		current_favor -= game.FAVOR_PER_BOON
		game._on_boon_earned.emit()

func expend_turn_supplies() -> void:
	var unit_count = game.get_unit_count()
	supply_cost = unit_count * UNIT_SUPPLY_COST
	current_supplies -= supply_cost
	update_display()
	if current_supplies <= 0:
		game.on_supplies_empty();

func update_display() ->void:
	var disp_str = "Supplies: "
	disp_str += str(current_supplies)
	disp_str += " (-" + str(supply_cost) + ")" 
	label.text =  disp_str
