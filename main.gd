extends Node2D

@export var item_scene: PackedScene = preload("res://item.tscn")

# 1. 그리드 설정 (예: 4행 4열 바둑판)
const GRID_ROWS = 4
const GRID_COLS = 4
const TILE_SIZE = 100 # 칸과 칸 사이의 간격 (픽셀)
const START_POS = Vector2(200, 200) # 그리드가 시작될 화면 좌측 상단 위치

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
	# 빈 칸 찾기
	var empty_slot = find_empty_slot()
	
	if empty_slot == null:
		print("보드판이 가득 찼습니다!")
		return
		
	var r = empty_slot.x
	var c = empty_slot.y
	
	# 아이템 생성 및 배치
	var new_item = item_scene.instantiate()
	
	# 행(r)과 열(c) 번호를 기반으로 화면상의 실제 좌표(X, Y) 계산
	var spawn_x = START_POS.x + (c * TILE_SIZE)
	var spawn_y = START_POS.y + (r * TILE_SIZE)
	new_item.global_position = Vector2(spawn_x, spawn_y)
	
	# 생성된 아이템을 무대에 추가하고 그리드 데이터에 등록
	add_child(new_item)
	grid[r][c] = new_item
	print("그리드 [", r, ", ", c, "] 위치에 아이템 생성!")

# 바둑판을 뒤져서 가장 먼저 나오는 빈 칸(null)의 위치를 반환하는 함수
func find_empty_slot():
	for r in GRID_ROWS:
		for c in GRID_COLS:
			if grid[r][c] == null:
				return Vector2(r, c) # 행, 열 위치 반환
	return null # 빈 칸이 없으면 null 반환
