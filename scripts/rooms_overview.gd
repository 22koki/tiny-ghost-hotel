extends Control

const MAP_POSITIONS := {
	"cold_room": Vector2(65, 350),
	"dark_room": Vector2(265, 350),
	"music_room": Vector2(465, 350),
	"library_room": Vector2(65, 220),
	"garden_room": Vector2(265, 220),
	"potion_room": Vector2(465, 220),
	"art_room": Vector2(65, 90),
	"moonlight_suite": Vector2(265, 90),
	"seance_room": Vector2(465, 90),
	"clockwork_room": Vector2(665, 220),
	"vip_room": Vector2(665, 90),
	"mirror_room": Vector2(665, 350)
}

@onready var coins_label: Label = $TopBar/CoinsLabel
@onready var night_label: Label = $TopBar/NightLabel
@onready var hotel_map: Control = $HotelMap
@onready var detail_title: Label = $DetailPanel/Title
@onready var detail_body: Label = $DetailPanel/Body
@onready var action_button: Button = $DetailPanel/ActionButton
@onready var back_button: Button = $BackButton
@onready var occupancy_label: Label = $DetailPanel/Occupancy
@onready var floor_label: Label = $HotelMap/FloorLabel

var selected_room_id: String = ""
var room_buttons: Dictionary = {}

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	action_button.pressed.connect(_on_action_pressed)
	_build_hotel_map()
	_refresh_header()
	_select_first_room()

func _build_hotel_map() -> void:
	for room_id in RoomCatalog.get_all_room_ids():
		var data := RoomCatalog.get_room(room_id)
		var button := Button.new()
		button.position = MAP_POSITIONS.get(room_id, Vector2.ZERO)
		button.size = Vector2(175, 105)
		button.text = _room_button_text(room_id, data)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", Color(0.93, 0.82, 0.65))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.76))
		button.add_theme_stylebox_override("normal", _make_room_style(false, GameState.is_room_unlocked(room_id)))
		button.add_theme_stylebox_override("hover", _make_room_style(true, GameState.is_room_unlocked(room_id)))
		button.pressed.connect(_on_room_selected.bind(room_id))
		hotel_map.add_child(button)
		room_buttons[room_id] = button

func _make_room_style(hovered: bool, unlocked: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if unlocked:
		style.bg_color = Color(0.16, 0.075, 0.035, 0.98) if not hovered else Color(0.28, 0.13, 0.05, 1.0)
		style.border_color = Color(0.69, 0.44, 0.18, 1.0) if not hovered else Color(1.0, 0.72, 0.30, 1.0)
	else:
		style.bg_color = Color(0.055, 0.045, 0.045, 0.96)
		style.border_color = Color(0.22, 0.19, 0.17, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0, 0, 0, 0.72)
	style.shadow_size = 8 if not hovered else 14
	return style

func _room_button_text(room_id: String, data: Dictionary) -> String:
	var unlocked := GameState.is_room_unlocked(room_id)
	var level := int(GameState.room_levels.get(room_id, 1))
	if unlocked:
		var occupant := GameState.get_room_occupant(room_id)
		if not occupant.is_empty():
			return "%s  %s\n%s %s\n● OCCUPIED" % [
				str(data.get("icon", "✦")),
				str(data.get("short_name", "Room")),
				str(occupant.get("icon", "👻")),
				str(occupant.get("name", "Guest"))
			]
		return "%s  %s\nLEVEL %d\n● READY" % [
			str(data.get("icon", "✦")),
			str(data.get("short_name", "Room")),
			level
		]
	return "🔒  %s\nNIGHT %d\n%d COINS" % [
		str(data.get("short_name", "Room")),
		int(data.get("unlock_night", 1)),
		int(data.get("unlock_cost", 0))
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

	detail_title.text = "%s  %s" % [str(data.get("icon", "✦")), str(data.get("name", "Room"))]
	if unlocked:
		var occupant := GameState.get_room_occupant(room_id)
		occupancy_label.text = (
			"STATUS: OCCUPIED • %s %s" % [
				str(occupant.get("icon", "👻")),
				str(occupant.get("name", "Guest"))
			]
			if not occupant.is_empty()
			else "STATUS: READY FOR GUESTS"
		)
	else:
		occupancy_label.text = "STATUS: SEALED"
	detail_body.text = "%s\n\nBest for: %s\n\n%s" % [
		str(data.get("theme", "")),
		", ".join(best_for),
		"Room Level: %d\nUpgrades improve comfort and future earnings." % level if unlocked else "This room is still sealed behind an old brass lock."
	]

	if unlocked:
		var costs: Array = data.get("upgrade_costs", [])
		if level - 1 < costs.size():
			var cost := int(costs[level - 1])
			action_button.text = "UPGRADE ROOM • %d COINS" % cost
			action_button.disabled = GameState.coins < cost
		else:
			action_button.text = "MAXIMUM LEVEL"
			action_button.disabled = true
	else:
		var night_required := int(data.get("unlock_night", 1))
		var cost := int(data.get("unlock_cost", 0))
		if GameState.current_night < night_required:
			action_button.text = "SEALED UNTIL NIGHT %d" % night_required
			action_button.disabled = true
		else:
			action_button.text = "UNLOCK DOOR • %d COINS" % cost
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
	_refresh_map()
	_on_room_selected(selected_room_id)

func _refresh_header() -> void:
	coins_label.text = "◉ %d GHOST COINS" % GameState.coins
	night_label.text = "NIGHT %d  •  REPUTATION %d" % [
		GameState.current_night,
		GameState.hotel_reputation
	]
	floor_label.text = "THE OLD HOTEL  •  %d / %d ROOMS OPEN" % [
		GameState.unlocked_rooms.size(),
		RoomCatalog.get_all_room_ids().size()
	]

func _refresh_map() -> void:
	for room_id in room_buttons:
		var button: Button = room_buttons[room_id]
		button.text = _room_button_text(room_id, RoomCatalog.get_room(room_id))
		button.add_theme_stylebox_override("normal", _make_room_style(false, GameState.is_room_unlocked(room_id)))
		button.add_theme_stylebox_override("hover", _make_room_style(true, GameState.is_room_unlocked(room_id)))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
