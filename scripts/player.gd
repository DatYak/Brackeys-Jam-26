class_name Player extends Node

const STARTING_SUPPLIES:int = 200
const UNIT_SUPPLY_COST:int = 2

@onready var current_supplies:int = STARTING_SUPPLIES
@onready var label:Label = $UI/Supplies

var supply_cost:int = 0

func expend_turn_supplies(game:Game) -> void:
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
