extends Area2D
class_name MergeItem

# 아이템의 레벨 속성 (1부터 시작)
@export var level: int = 1

# [추가] 내가 현재 그리드 상에서 몇 행 몇 열에 안착해 있는지 기억할 명찰 변수
var grid_r: int = 0
var grid_c: int = 0

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO

@onready var label: Label = $Label # 레벨을 눈으로 확인하기 위한 텍스트
@onready var main_node = get_node("/root/Main") # [추가] Main 스크립트 함수를 호출하기 위한 경로

func _ready():
	start_position = global_position
	update_visual()
	# 마우스 입력 이벤트를 감지하기 위해 연결
	input_event.connect(_on_input_event)

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

# 드래그 앤 드롭 입력 처리
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 드래그 시작
			is_dragging = true
			# [수정] 튕겨 돌아갈 기준점을 '드래그를 막 시작한 현재 위치'로 고정
			start_position = global_position 
			drag_offset = get_global_mouse_position() - global_position
			z_index = 10 # 드래그 중인 아이템이 다른 아이템들 위로 보이도록 레이어 업
			
		elif !event.pressed and is_dragging:
			# 드래그 끝 (마우스를 뗌)
			is_dragging = false
			z_index = 0 # 레이어 원상 복구
			
			# [수정] 기존 check_merge_target 대신 Main에게 빈칸 체크 및 이동 요청을 보냅니다.
			# 마우스를 뗀 현재 global_position과 자신이 원래 있던 행/열(grid_r, grid_c)을 같이 던집니다.
			var success = main_node.request_move_item(self, global_position, grid_r, grid_c)
			
			# Main이 "그 자리는 이미 찬 칸이거나 판 밖이라 이동 불가(false)"라고 하면 원래 자리로 롤백
			if not success:
				global_position = start_position

# 레벨업 시 실행되는 함수
func level_up():
	level += 1
	update_visual()
	print("아이템 레벨업! 현재 레벨: ", level)

# 화면에 레벨 숫자를 갱신해주는 함수
func update_visual():
	if has_node("Label"):
		$Label.text = str(level)