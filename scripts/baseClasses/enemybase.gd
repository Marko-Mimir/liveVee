extends Node2D
class_name LiveEnemy

@export var animations : AnimationPlayer
@export var hurtbox : Area2D
@export var shake : ShakeComponent
@export var health : Health
@export var hitEffect : GPUParticles2D
@export var deathParticles : Array[GPUParticles2D] = []

var isDying := false

func _ready() -> void:
	hurtbox.area_entered.connect(self.onHurt)
	health.dead.connect(self.kys)

func onHurt(_area : Area2D) -> void:
	if util.playerRight(self):
		if animations and animations.has_animation("hurtRight"):
			animations.play("hurtRight")
	elif animations and animations.has_animation("hurtLeft"):
			animations.play("hurtLeft")
	if hitEffect:
		if hitEffect.emitting:
			hitEffect.restart()
		hitEffect.emitting = true
	if shake:
		shake.shake()
	health.editHealth(-2)

func _process(_delta: float) -> void:
	if isDying:
		modulate.a = lerpf(modulate.a, 0, .5)

func kys():
	health.visible = false
	if animations and animations.has_animation("dead"):
			animations.play("dead")
	if shake:
		shake.shake()
	for particle in deathParticles:
		particle.emitting = true
	await get_tree().create_timer(1).timeout
	isDying = true
	await get_tree().create_timer(1).timeout
	queue_free()
