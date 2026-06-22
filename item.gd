extends Area2D
class_name MergeItem

# 아이템의 레벨 속성 (1부터 시작)
@export var level: int = 1

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO

@onready var label: Label = $Label # 레벨을 눈으로 확인하기 위한 텍스트

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
			start_position = global_position
			drag_offset = get_global_mouse_position() - global_position
		elif !event.pressed and is_dragging:
			# 드래그 끝 (마우스를 뗌)
			is_dragging = false
			check_merge_target()

# 마우스를 놓았을 때 주변에 합칠 수 있는 다른 아이템이 있는지 검사
func check_merge_target():
	var overlapping_areas = get_overlapping_areas()
	var merged: bool = false
	
	for area in overlapping_areas:
		if area is MergeItem and area != self:
			# 다른 아이템을 찾았고, 레벨이 같다면 머지 시작!
			if area.level == self.level:
				area.level_up() # 상대방 레벨업
				self.queue_free() # 나 자신은 흡수되어 삭제
				merged = true
				break
				
	if not merged:
		# 합치기 실패 시 원래 자리로 튕겨서 돌아감
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
