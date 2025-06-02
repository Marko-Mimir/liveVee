extends Sprite2D
class_name liveCollectable

@export var defaultTexture := "res://sprites/collectable/dummycollect.png"

@export_subgroup("data")
@export_range(0, 100) var id := 0
enum types {BLUEPRINT}
@export var type :types

var data : Dictionary
var item : Dictionary
var area : Area2D;
var tooltip : LiveUi;

func _ready() -> void:
	data = {"id": self.id, "type" : self.type}
	if texture == null:
		texture = load(defaultTexture)
	if !util.validateCollectable(data):
		print("INVALID COLLECTABLE, KILLING")
		queue_free()
		return
	item = util.getCollectableData(data)
	area = get_node("Area2D")
	area.body_entered.connect(self.g)
	area.mouse_entered.connect(self.doTooltip)
	area.mouse_exited.connect(self.noTooltip)

func doTooltip()-> void:
	if !tooltip:
		tooltip = ui.get_or_add("TOOLTIP", "res://objects/UI/tooltip.tscn")
	tooltip.get_child(0).startTooltip(item["name"], item["desc"])

func noTooltip() -> void:
	tooltip.get_child(0).endTooltip()

func g(_body) -> void:
	if !player.scene:
		return
	player.scene.gamePrint("Item Get!")
	#player.collect(item)
	#TODO: Sound + Animation
	queue_free()
