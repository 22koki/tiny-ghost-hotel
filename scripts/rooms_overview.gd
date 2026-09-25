extends Control

const CARD_SIZE := Vector2(248, 178)

@onready var coins_label: Label = $TopBar/CoinsLabel
@onready var night_label: Label = $TopBar/NightLabel
@onready var room_grid: GridContainer = $Scroll/RoomGrid
@onready var detail_panel: Panel = $DetailPanel
@onready var detail_title: Label = $DetailPanel/Title
@onready var detail_body: Label = $DetailPanel/Body
@onready var action_button: Button = $DetailPanel/ActionButton
@onready var back_button: Button = $BackButton

var selected_room_id: String = ""
var room_buttons: Dictionary = {}

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	action_button.pressed.connect(_on_action_pressed)
	_build_room_cards()
	_refresh_header()
	_select_first_room()

func _build_room_cards() -> void:
	for child in room_grid.get_children():
		child.queue_free()
	room_buttons.clear()

	for room_id in RoomCatalog.get_all_room_ids():
		var data := RoomCatalog.get_room(room_id)
		var button := Button.new()
		button.custom_minimum_size = CARD_SIZE
		button.text = _room_button_text(room_id, data)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_color_override("font_color", Color(0.94, 0.84, 0.64))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.72))
		button.add_theme_stylebox_override("normal", _make_card_style(false))
		button.add_theme_stylebox_override("hover", _make_card_style(true))
		button.pressed.connect(_on_room_selected.bind(room_id))
		room_grid.add_child(button)
		room_buttons[room_id] = button

func _make_card_style(hovered: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.055, 0.035, 0.97) if not hovered else Color(0.22, 0.10, 0.045, 0.99)
	style.border_color = Color(0.58, 0.36, 0.15, 1.0) if not hovered else Color(0.92, 0.64, 0.28, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0.01, 0.005, 0.0, 0.72)
	style.shadow_size = 8 if not hovered else 14
	return style

func _room_button_text(room_id: String, data: Dictionary) -> String:
	var unlocked := GameState.is_room_unlocked(room_id)
	var level := int(GameState.room_levels.get(room_id, 1))
	var status := "LEVEL %d" % level if unlocked else "LOCKED"
	var requirement := ""
	if not unlocked:
		requirement = "\nNight %d • %d coins" % [
			int(data.get("unlock_night", 1)),
			int(data.get("unlock_cost", 0))
		]
	return "%s  %s\n%s\n%s%s" % [
		str(data.get("icon", "✦")),
		str(data.get("short_name", "Room")),
		str(data.get("name", "Unknown Room")),
		status,
		requirement
	]

func _select_first_room() -> void:
	var ids := RoomCatalog.get_all_room_ids()
	if not ids.is_empty():
		_on_room_selected(ids[0])

func _on_room_selected(room_id: String) -> void:
	selected_room_id = room_id
	var data := RoomCatalog.get_room(room_id)
	var unlocked := GameState.is_room_unlocked(room_id)
	var level := int(GameState.room_levels.get(room_id, 1))
	var best_for: Array = data.get("best_for", [])
	var traits := ", ".join(best_for)

	detail_title.text = "%s  %s" % [str(data.get("icon", "✦")), str(data.get("name", "Room"))]
	detail_body.text = "%s\n\nBest for: %s\n\n%s" % [
		str(data.get("theme", "")),
		traits,
		"Room Level: %d" % level if unlocked else "This room is still sealed."
	]

	if unlocked:
		var costs: Array = data.get("upgrade_costs", [])
		if level - 1 < costs.size():
			var cost := int(costs[level - 1])
			action_button.text = "UPGRADE • %d COINS" % cost
			action_button.disabled = GameState.coins < cost
		else:
			action_button.text = "MAXIMUM LEVEL"
			action_button.disabled = true
	else:
		var night_required := int(data.get("unlock_night", 1))
		var cost := int(data.get("unlock_cost", 0))
		if GameState.current_night < night_required:
			action_button.text = "UNLOCKS ON NIGHT %d" % night_required
			action_button.disabled = true
		else:
			action_button.text = "UNLOCK • %d COINS" % cost
			action_button.disabled = GameState.coins < cost

func _on_action_pressed() -> void:
	if selected_room_id.is_empty():
		return

	var data := RoomCatalog.get_room(selected_room_id)
	if GameState.is_room_unlocked(selected_room_id):
		var level := int(GameState.room_levels.get(selected_room_id, 1))
		var costs: Array = data.get("upgrade_costs", [])
		if level - 1 >= costs.size():
			return
		GameState.upgrade_room(selected_room_id, int(costs[level - 1]))
	else:
		var night_required := int(data.get("unlock_night", 1))
		var cost := int(data.get("unlock_cost", 0))
		if GameState.current_night < night_required:
			return
		if GameState.spend_coins(cost):
			GameState.unlock_room(selected_room_id)

	_refresh_header()
	_refresh_cards()
	_on_room_selected(selected_room_id)

func _refresh_header() -> void:
	coins_label.text = "◉ %d COINS" % GameState.coins
	night_label.text = "NIGHT %d  •  REPUTATION %d" % [
		GameState.current_night,
		GameState.hotel_reputation
	]

func _refresh_cards() -> void:
	for room_id in room_buttons:
		var button: Button = room_buttons[room_id]
		button.text = _room_button_text(room_id, RoomCatalog.get_room(room_id))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
