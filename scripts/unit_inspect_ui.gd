class_name UnitUI extends Control

const HEALTH_DESCRIPTIONS = ["Dead", "Inured", "Healthy"]

const UNIT_DISPOSITIONS = [
	["is gone.", "has been lashed to the mast."], ["has been confined below deck.", "is no longer fit for duty.", "has been relieved."],
	["hungers for your flesh.", "won't stop staring at you.", "has stopped speaking entirely.", "shakes uncontrollably.", "wails with manic fervor." ],
	["thirsts for your blood.", "is sowing dissent.", "is struggling to hold it together.", "looks a little worse for wear.", "grins a little too broadly."],
	["spits at your feet.", "scoffs in indignation.", "is having some doubts.", "stands at attention.", "is quite enthusiastic."],
	["whispers behind your back.", "eyes you with disdain.", "won't meet your eyes.", "salutes dutifully.",  "greets you as a true friend."],
]

@onready var stats:CharacterStats = $".."
@onready var character:Character = $"../../.."

@onready var stat_graph:StatGraph = $Background/PolyStat/StatGraph
@onready var name_label : Label = $Background/Nameplate/Label
@onready var disposition:Label = $Background/Disposition/Label
@onready var health:Label = $Background/Health
@onready var image:TextureRect = $Background/Image

# Called when the node enters the scene tree for the first time.
func display() -> void:
	var stat_array:Array = [stats.might, stats.guile, stats.favor]
	stat_graph.display_stats(stat_array)
	
	name_label.text = character.character_name
	image.texture = character.character_image
	health.text = HEALTH_DESCRIPTIONS[stats.health]
	var loyalty_bounded = floori(stats.loyalty as float / 2.0)
	disposition.text = UNIT_DISPOSITIONS[stats.sanity][loyalty_bounded]
	
