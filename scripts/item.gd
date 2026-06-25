extends Area2D
class_name MergeItem

const MAX_LEVEL := 3

const ITEM_TEXTURES := {
	1: preload("res://assets/sprites/magic_item_tier_1.png"),
	2: preload("res://assets/sprites/magic_item_tier_2.png"),
	3: preload("res://assets/sprites/magic_item_tier_3.png"),
}

@export var level: int = 1

var grid_r: int = 0
var grid_c: int = 0

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var tile_size: float = 90.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var main_node = get_node("/root/Main")

func configure_tile_size(size: float) -> void:
	tile_size = size
	var shape := $CollisionShape2D.shape as RectangleShape2D
	shape.size = Vector2(size, size)
	if is_node_ready():
		_update_sprite_scale()

func _ready():
	start_position = global_position
	update_visual()
	input_event.connect(_on_input_event)

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_drag_press(event.pressed)
	elif event is InputEventScreenTouch:
		_handle_drag_press(event.pressed)

func _handle_drag_press(pressed: bool) -> void:
	if pressed:
		is_dragging = true
		start_position = global_position
		drag_offset = get_global_mouse_position() - global_position
		z_index = 10
	elif is_dragging:
		is_dragging = false
		z_index = 0

		var success = main_node.request_move_item(self, global_position, grid_r, grid_c)
		if not success:
			global_position = start_position

func level_up():
	if level >= MAX_LEVEL:
		return
	level += 1
	update_visual()
	print("아이템 레벨업! 현재 레벨: ", level)

func update_visual():
	if sprite == null:
		return

	var current_lvl := clampi(level, 1, MAX_LEVEL)
	sprite.texture = ITEM_TEXTURES[current_lvl]
	_update_sprite_scale()

func _update_sprite_scale() -> void:
	if sprite == null or sprite.texture == null:
		return
	var tex_size := sprite.texture.get_size()
	var max_dim := maxf(tex_size.x, tex_size.y)
	var scale_factor := tile_size / max_dim
	sprite.scale = Vector2(scale_factor, scale_factor)
