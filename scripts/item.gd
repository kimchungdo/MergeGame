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

# 🎨 프로토타입용 1~10단계 바닷속 마법 아이템 이름 및 색상 테이블
const ITEM_DATA = {
	1: {"name": "초록 해초", "color": Color("2ecc71")},       # 연초록
	2: {"name": "분홍 조개", "color": Color("ff7979")},       # 분홍
	3: {"name": "심해 조개", "color": Color("0984e3")},       # 파랑
	4: {"name": "빛나는 조개", "color": Color("00cec9")},     # 청록
	5: {"name": "자그만 백진주", "color": Color("dfe6e9")},   # 밝은 회백색
	6: {"name": "은은한 흑진주", "color": Color("2d3436")},   # 짙은 흑색
	7: {"name": "황금 진주", "color": Color("fdcb6e")},       # 황금색
	8: {"name": "심해 룬 진주", "color": Color("6c5ce7")},    # 보라색
	9: {"name": "산호 왕관", "color": Color("e84393")},       # 진분홍
	10: {"name": "포세이돈의 핵", "color": Color("ffeaa7")}   # 번쩍이는 연황금
}

# 레벨 숫자에 맞춰 사각형 색상과 텍스트를 자동으로 갈아끼우는 함수
func update_visual():
	# 1. 안전하게 하위 노드들이 로드되었는지 확인
	if not has_node("ColorRect") or not has_node("Label"):
		return
		
	# 2. 현재 레벨이 데이터 테이블에 있는지 체크 (최대 10단계 예외처리)
	var current_lvl = level
	if current_lvl > 10: 
		current_lvl = 10
		
	var data = ITEM_DATA[current_lvl]
	
	# 3. [핵심] 기존의 심심한 회색 박스 색상을 마법 아이템 톤으로 강제 변경!
	$ColorRect.color = data["color"]
	
	# 4. 글자판에 [레벨]과 [아이템 이름]을 동시에 뿌려 가독성을 높입니다.
	$Label.text = "Lv." + str(level) + "\n" + data["name"]
	
	# 글자가 박스 밖으로 삐져나가지 않게 라벨 세팅 보정 (프로토타입용)
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
