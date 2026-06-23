extends Node2D

@export var item_scene: PackedScene = preload("res://item.tscn")

# 1. 그리드 설정 (예: 4행 4열 바둑판)
const GRID_ROWS = 9
const GRID_COLS = 7
const TILE_SIZE = 90 # 칸과 칸 사이의 간격 (픽셀)
const START_POS = Vector2(45, 250) # 그리드가 시작될 화면 좌측 상단 위치

# 2. 바둑판의 칸들이 비어있는지 채워져 있는지 기억할 2차원 배열
var grid = []

func _ready():
	# 게임이 시작되면 4x4 빈 바둑판 데이터를 초기화합니다. (null로 채움)
	for r in GRID_ROWS:
		var row = []
		for c in GRID_COLS:
			row.append(null)
		grid.append(row)

# 버튼이 눌렸을 때 실행되는 함수
func _on_button_pressed():
	# 1. 보드판 전체에서 "비어있는 칸들"의 좌표를 배열로 싹 긁어 모읍니다.
	var empty_slots = get_all_empty_slots()
	
	# 2. 만약 비어있는 칸이 하나도 없다면 게임 오버 처리
	if empty_slots.is_empty():
		print("보드판이 가득 찼습니다!")
		return
		
	# 3. [핵심] 빈 칸 목록(empty_slots) 중에서 무작위로 하나를 추첨합니다.
	# randi() % 배열크기 -> 배열의 랜덤 인덱스를 뽑아냅니다.
	var random_index = randi() % empty_slots.size()
	var chosen_slot = empty_slots[random_index]
	
	var r = chosen_slot.x
	var c = chosen_slot.y
	
	# 4. 행(r)과 열(c) 번호를 기반으로 화면상의 실제 좌표(X, Y) 계산
	var spawn_x = START_POS.x + (c * TILE_SIZE)
	var spawn_y = START_POS.y + (r * TILE_SIZE)
	
	# 5. 아이템 생성 및 배치
	var new_item = item_scene.instantiate()
	new_item.global_position = Vector2(spawn_x, spawn_y)
	
	# 생성된 아이템을 무대에 추가하고 그리드 데이터에 등록
	add_child(new_item)
	grid[r][c] = new_item
	print("그리드 [", r, ", ", c, "] 위치에 랜덤 생성!")


# 🛠️ 바둑판 전체를 샅샅이 뒤져서 '모든 빈 칸(null)'의 좌표를 배열로 돌려주는 함수
func get_all_empty_slots() -> Array:
	var slots = []
	for r in GRID_ROWS:
		for c in GRID_COLS:
			if grid[r][c] == null:
				# 빈 칸의 행, 열 위치를 Vector2에 담아 리스트에 추가
				slots.append(Vector2(r, c))
	return slots

# 바둑판을 뒤져서 가장 먼저 나오는 빈 칸(null)의 위치를 반환하는 함수
func find_empty_slot():
	for r in GRID_ROWS:
		for c in GRID_COLS:
			if grid[r][c] == null:
				return Vector2(r, c) # 행, 열 위치 반환
	return null # 빈 칸이 없으면 null 반환
