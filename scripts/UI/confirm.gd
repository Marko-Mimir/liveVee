extends LiveUi
class_name LiveConfirmation

@export var question : RichTextLabel
@export var yes : Button
@export var no : Button

signal answer(response : bool)

func _ready() -> void:
	yes.button_down.connect(self.yeah)
	no.button_down.connect(self.neah)

func yeah():
	answer.emit(true)
	ui.remove_ui(id)

func neah():
	answer.emit(false)
	ui.remove_ui(id)

func init(q : String = "UI-CONFIRM", y: String = "UI-YES", n : String = "UI-NO") -> void:
	question.text = q
	yes.text = y
	no.text = n
