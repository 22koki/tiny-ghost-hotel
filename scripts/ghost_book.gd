extends Control

@onready var collection_label: Label = $HeaderPanel/CollectionLabel
@onready var ghost_grid: GridContainer = $Scroll/GhostGrid
@onready var portrait_label: Label = $DetailPanel/Portrait
@onready var name_label: Label = $DetailPanel/Name
@onready var rarity_label: Label = $DetailPanel/Rarity
@onready var details_label: Label = $DetailPanel/Details
@onready var lore_label: Label = $DetailPanel/Lore
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_build_collection()
	_update_collection_label()

func _build_collection() -> void:
	for child in ghost_grid.get_children():
		child.queue_free()

	for ghost_id in GhostCatalog.get_all_ids():
		var discovered: bool = ghost_id in GameState.discovered_ghosts
		var data: Dictionary = GhostCatalog.get_ghost(ghost_id)
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(205, 145)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 16)
		button.add_theme_color_override("font_color", Color(0.91, 0.82, 0.68))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.72))
		button.add_theme_stylebox_override("normal", _make_card_style(false, discovered))
		button.add_theme_stylebox_override("hover", _make_card_style(true, discovered))

		if discovered:
			button.text = "%s\n%s\n%s" % [
				str(data.get("icon", "👻")),
				str(data.get("name", "Unknown")),
				str(data.get("rarity", "Unknown"))
			]
		else:
			button.text = "❔\nUNKNOWN GUEST\nUndiscovered"

		button.pressed.connect(_show_ghost.bind(ghost_id))
		ghost_grid.add_child(button)

func _make_card_style(hovered: bool, discovered: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if discovered:
		style.bg_color = Color(0.12, 0.055, 0.035, 0.97) if not hovered else Color(0.23, 0.10, 0.045, 0.99)
		style.border_color = Color(0.58, 0.36, 0.15, 1.0) if not hovered else Color(0.92, 0.64, 0.28, 1.0)
	else:
		style.bg_color = Color(0.055, 0.05, 0.06, 0.95)
		style.border_color = Color(0.24, 0.22, 0.24, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0, 0, 0, 0.65)
	style.shadow_size = 8 if not hovered else 13
	return style

func _show_ghost(ghost_id: String) -> void:
	if ghost_id not in GameState.discovered_ghosts:
		portrait_label.text = "❔"
		name_label.text = "UNKNOWN GUEST"
		rarity_label.text = "Undiscovered"
		details_label.text = "Encounter this spirit during a night shift to reveal its preferences and personality."
		lore_label.text = "The page is blank except for a faint smell of candle smoke."
		return

	var data := GhostCatalog.get_ghost(ghost_id)
	portrait_label.text = str(data.get("icon", "👻"))
	name_label.text = str(data.get("name", "Unknown"))
	rarity_label.text = "%s Spirit" % str(data.get("rarity", "Unknown"))
	details_label.text = "Personality: %s\nMood: %s\nPrefers: %s\nAvoids: %s" % [
		str(data.get("personality", "Unknown")),
		str(data.get("mood", "Unknown")),
		str(data.get("preference", "Unknown")),
		str(data.get("dislikes", "Unknown"))
	]
	lore_label.text = str(data.get("lore", ""))

func _update_collection_label() -> void:
	collection_label.text = "%d / %d SPIRITS DISCOVERED" % [
		GameState.discovered_ghosts.size(),
		GhostCatalog.get_all_ids().size()
	]

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
