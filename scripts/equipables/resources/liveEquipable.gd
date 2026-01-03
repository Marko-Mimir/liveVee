extends Resource
class_name LiveEquipable

@export var name : String
@export var sprite : CompressedTexture2D
@export var frames : Vector2 = Vector2(1,1)
@export var logic : Script
@export var animations : Array[LiveAnimation]
