extends Area2D
class_name LiveEntrance

@export var doConfirm : bool 
@export var scene : PackedScene
@export var logic : Node
@export_category("Confirm Text")
@export var question : String = "UI-CONFIRM"
@export var yes : String = "UI-YES"
@export var no : String = "UI-NO"

var conf : LiveConfirmation

func _ready() -> void:
	body_entered.connect(self.Enter)
	body_exited.connect(self.Leave)
	monitorable = false
	collision_layer = 0
	collision_mask = 0b10
	

func Enter(_area : Node2D):
	conf = util.confirm(question, yes, no)
	conf.answer.connect(self.process)

func Leave(_area : Node2D):
	if conf:
		ui.remove_ui(conf.id)
		conf = null

func process(res : bool):
	if !res:
		return
	if scene:
		util.switchScene(scene)
		return
	if logic and logic.has_method("process"):
		logic.process()
		return
	player.scene.gamePrint("&cError with door object, no scene set, or logic \ndoesnt have the method process.")
