extends Sprite
class_name HDSprite

onready var sprite = Sprite.new()
onready var container = get_tree().get_nodes_in_group("HDContainer")[0]

func _ready():
	sprite.texture = self.texture
	if container:
		container.add_child(sprite)
		hide()

func _process(_delta):
	if container:
		sprite.position = global_position
		sprite.rotation = global_rotation

func _exit_tree():
	container.remove_child(sprite)
