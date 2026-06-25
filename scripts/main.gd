extends Node2D

@export var item_scene: PackedScene = preload("res://scenes/item.tscn")

const GRID_ROWS = 9
const GRID_COLS = 7
const DESIGN_VIEWPORT := Vector2(1080, 1920)
const MIN_TILE_SIZE := 64

# 머지 화면 비율: 상단 HUD · 중앙 보드 · 하단 액션 버튼
const MARGIN_X_RATIO := 0.05
const TOP_HUD_RATIO := 0.11
const BOTTOM_ACTION_RATIO := 0.16
const BUTTON_ZONE_MIN_HEIGHT := 120.0

var tile_size: float = 90.0
var start_pos := Vector2.ZERO
var board_size := Vector2.ZERO

var grid = []

func _ready():
	for r in GRID_ROWS:
		var row = []
		for c in GRID_COLS:
			row.append(null)
		grid.append(row)

	_recalculate_layout()
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	_recalculate_layout()

func _get_viewport_size() -> Vector2:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return DESIGN_VIEWPORT
	return size

func _recalculate_layout() -> void:
	var viewport_size := _get_viewport_size()

	var margin_x := viewport_size.x * MARGIN_X_RATIO
	var margin_top := viewport_size.y * TOP_HUD_RATIO
	var button_zone := maxf(viewport_size.y * BOTTOM_ACTION_RATIO, BUTTON_ZONE_MIN_HEIGHT)
	var available_w := viewport_size.x - margin_x * 2.0
	var available_h := viewport_size.y - margin_top - button_zone

	var tile_by_width := floorf(available_w / float(GRID_COLS))
	var tile_by_height := floorf(available_h / float(GRID_ROWS))
	tile_size = minf(tile_by_width, tile_by_height)
	if GRID_ROWS * tile_size > available_h:
		tile_size = floorf(available_h / float(GRID_ROWS))
	tile_size = maxf(MIN_TILE_SIZE, tile_size)

	board_size = Vector2(GRID_COLS * tile_size, GRID_ROWS * tile_size)
	start_pos.x = (viewport_size.x - board_size.x) / 2.0 + tile_size * 0.5
	start_pos.y = margin_top + maxf(0.0, (available_h - board_size.y) / 2.0) + tile_size * 0.5

	var max_board_bottom := viewport_size.y - button_zone
	var board_bottom := start_pos.y + (GRID_ROWS - 1) * tile_size + tile_size * 0.5
	if board_bottom > max_board_bottom:
		start_pos.y -= board_bottom - max_board_bottom

	_reposition_grid_items()

func _reposition_grid_items() -> void:
	for r in GRID_ROWS:
		for c in GRID_COLS:
			var item = grid[r][c]
			if item == null:
				continue
			if item.has_method("configure_tile_size"):
				item.configure_tile_size(tile_size)
			item.global_position = get_grid_position(r, c)

func _on_button_pressed():
	var empty_slots = get_all_empty_slots()

	if empty_slots.is_empty():
		print("보드판이 가득 찼습니다!")
		return

	var random_index = randi() % empty_slots.size()
	var chosen_slot = empty_slots[random_index]

	var r = int(chosen_slot.x)
	var c = int(chosen_slot.y)

	var new_item = item_scene.instantiate()
	new_item.global_position = get_grid_position(r, c)
	new_item.grid_r = r
	new_item.grid_c = c

	add_child(new_item)
	if new_item.has_method("configure_tile_size"):
		new_item.configure_tile_size(tile_size)
	grid[r][c] = new_item
	print("그리드 [", r, ", ", c, "] 위치에 랜덤 생성!")

func get_all_empty_slots() -> Array:
	var slots = []
	for r in GRID_ROWS:
		for c in GRID_COLS:
			if grid[r][c] == null:
				slots.append(Vector2(r, c))
	return slots

func find_empty_slot():
	for r in GRID_ROWS:
		for c in GRID_COLS:
			if grid[r][c] == null:
				return Vector2(r, c)
	return null

func get_grid_index(global_pos: Vector2):
	var c = round((global_pos.x - start_pos.x) / tile_size)
	var r = round((global_pos.y - start_pos.y) / tile_size)

	if r >= 0 and r < GRID_ROWS and c >= 0 and c < GRID_COLS:
		return Vector2(r, c)
	return null

func get_grid_position(r: int, c: int) -> Vector2:
	var x = start_pos.x + (c * tile_size)
	var y = start_pos.y + (r * tile_size)
	return Vector2(x, y)

func request_move_item(item, release_global_pos: Vector2, old_r: int, old_c: int) -> bool:
	var target_index = get_grid_index(release_global_pos)

	if target_index == null:
		return false

	var new_r = int(target_index.x)
	var new_c = int(target_index.y)

	if old_r == new_r and old_c == new_c:
		item.global_position = get_grid_position(old_r, old_c)
		return true

	if grid[new_r][new_c] == null:
		grid[old_r][old_c] = null
		grid[new_r][new_c] = item

		item.grid_r = new_r
		item.grid_c = new_c
		item.global_position = get_grid_position(new_r, new_c)
		print("이동 완료: [", old_r, ",", old_c, "] -> [", new_r, ",", new_c, "]")
		return true
	else:
		var other_item = grid[new_r][new_c]

		if other_item.level == item.level and item.level < MergeItem.MAX_LEVEL:
			grid[old_r][old_c] = null

			other_item.level_up()
			item.queue_free()

			print("머지 성공! 레벨 업: [", new_r, ",", new_c, "]")
			return true
		else:
			print("이동 실패: 머지할 수 없는 칸입니다.")
			return false
