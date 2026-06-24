extends Node2D

@export var item_scene: PackedScene = preload("res://scenes/item.tscn")

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

	# _on_button_pressed 함수 내부 맨 아래 변수 심는 부분 수정
	add_child(new_item)
	grid[r][c] = new_item
	
	# 생성된 아이템에게 자기가 몇 행 몇 열에 배치되었는지 변수로 알려줍니다.
	new_item.grid_r = r
	new_item.grid_c = c
	
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


# 🎯 [수정] 50% 이상만 겹쳐도 해당 칸으로 인정해주는 Threshold 보정 버전
func get_grid_index(global_pos: Vector2):
	# 타일의 중심점을 기준으로 반올림(round)을 하여 
	# 유저가 대충 절반 이상 걸치게 놓으면 그 칸으로 가독성 있게 매칭해줍니다.
	var c = round((global_pos.x - START_POS.x) / TILE_SIZE)
	var r = round((global_pos.y - START_POS.y) / TILE_SIZE)
	
	# 계산된 인덱스가 7x9 보드판 내부라면 Vector2(행, 열)로 반환
	if r >= 0 and r < GRID_ROWS and c >= 0 and c < GRID_COLS:
		return Vector2(r, c)
	return null

# 2. 행(r), 열(c) 인덱스를 넣으면 그 칸의 정확한 화면 중심 좌표를 돌려주는 함수
func get_grid_position(r: int, c: int) -> Vector2:
	var x = START_POS.x + (c * TILE_SIZE)
	var y = START_POS.y + (r * TILE_SIZE)
	return Vector2(x, y)

# [수정] 아이템이 드래그를 마쳤을 때 호출할 통합 제어 함수 (이동 및 머지 판단)
func request_move_item(item, release_global_pos: Vector2, old_r: int, old_c: int) -> bool:
	var target_index = get_grid_index(release_global_pos)
	
	# 조건 A: 판 바깥에 떨어뜨렸다면 무조건 복귀
	if target_index == null:
		return false
		
	var new_r = target_index.x
	var new_c = target_index.y
	
	# 조건 B: 원래 자리에 고대로 놓은 경우 (제자리 스냅 성공 처리)
	if old_r == new_r and old_c == new_c:
		item.global_position = get_grid_position(old_r, old_c)
		return true
		
	# 조건 C: 이동할 자리가 완벽히 비어있는(null) 경우 -> 부드럽게 이동
	if grid[new_r][new_c] == null:
		grid[old_r][old_c] = null # 이전 자리는 비우고
		grid[new_r][new_c] = item # 새 자리에 아이템 등록
		
		# 아이템의 정보 및 화면 위치 갱신
		item.grid_r = new_r
		item.grid_c = new_c
		item.global_position = get_grid_position(new_r, new_c)
		print("이동 완료: [", old_r, ",", old_c, "] -> [", new_r, ",", new_c, "]")
		return true
		
	# 💡 조건 D: [핵심] 이동할 자리에 이미 다른 아이템이 있는 경우!
	else:
		var other_item = grid[new_r][new_c]
		
		# 1. 두 아이템의 레벨이 같다면 머지(합치기) 진행!
		if other_item.level == item.level:
			grid[old_r][old_c] = null # 내가 있던 자리는 빈칸으로 만듦
			
			other_item.level_up() # 상대방 아이템 레벨 업 (+ 비주얼 갱신)
			item.queue_free() # 나 자신은 무대에서 삭제
			
			print("머지 성공! 레벨 업: [", new_r, ",", new_c, "]")
			return true # 머지도 성공 처리를 하여 원래 자리로 튕겨 나가지 않게 함
			
		# 2. 레벨이 다르다면? 자리 차지가 불가능하므로 실패 처리 (원래 자리로 복귀)
		else:
			print("이동 실패: 레벨이 다른 아이템이 선점하고 있습니다.")
			return false
