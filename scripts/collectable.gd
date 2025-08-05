extends Sprite2D
class_name LiveItem

@export_subgroup("data")
@export_range(0, 100) var id := 0

var data : Dictionary;
var area : Area2D;
var tooltip : LiveUi;

func _ready() -> void:
	if texture == null:
		texture = load(util.dummyTexture)
	
	data = util.getItem(id)
	area = get_node("Area2D")
	area.body_entered.connect(self.g)
	area.mouse_entered.connect(self.doTooltip)
	area.mouse_exited.connect(self.noTooltip)
	if !tooltip:
		tooltip = ui.get_or_add("TOOLTIP", "res://objects/UI/tooltip.tscn")

func doTooltip()-> void:
	tooltip.get_child(0).startTooltip(data["name"], data["desc"])

func noTooltip() -> void:
	tooltip.get_child(0).endTooltip()

func g(_body) -> void:
	if !player.scene:
		return
	noTooltip()
	player.collect(id)
	#TODO: Sound + Animation
	queue_free()
