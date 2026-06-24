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
var tile_size: float = 90.0

@onready var label: Label = $Label
@onready var main_node = get_node("/root/Main")

func configure_tile_size(size: float) -> void:
	tile_size = size
	var half := size / 2.0
	$ColorRect.set_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	$ColorRect.offset_left = -half
	$ColorRect.offset_top = -half
	$ColorRect.offset_right = half
	$ColorRect.offset_bottom = half
	$Label.set_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	$Label.offset_left = -half
	$Label.offset_top = -half
	$Label.offset_right = half
	$Label.offset_bottom = half
	var shape := $CollisionShape2D.shape as RectangleShape2D
	shape.size = Vector2(size, size)

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
