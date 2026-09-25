extends Control

@onready var title: Label = $SummaryPanel/Title
@onready var night_label: Label = $SummaryPanel/Night
@onready var result_label: Label = $SummaryPanel/Result
@onready var score_label: Label = $SummaryPanel/Score
@onready var streak_label: Label = $SummaryPanel/Streak
@onready var rank_label: Label = $SummaryPanel/Rank
@onready var coins_label: Label = $SummaryPanel/Coins
@onready var reputation_label: Label = $SummaryPanel/Reputation
@onready var continue_button: Button = $SummaryPanel/ContinueButton
@onready var rooms_button: Button = $SummaryPanel/RoomsButton
@onready var book_button: Button = $SummaryPanel/BookButton

var rank_overlay: ColorRect
var rank_title: Label
var rank_change: Label

func _ready() -> void:
	var data: Dictionary = GameState.last_night_summary
	if data.is_empty():
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		return

	var won: bool = bool(data.get("won", false))
	title.text = "THE NIGHT IS COMPLETE" if won else "THE HOTEL FALLS QUIET"
	night_label.text = "NIGHT %d LEDGER" % int(data.get("night", 1))
	result_label.text = "SHIFT COMPLETE" if won else "SHIFT ENDED EARLY"
	score_label.text = "Guests served score  •  %d" % int(data.get("score", 0))
	streak_label.text = "Best service streak  •  %d" % int(data.get("best_streak", 0))
	rank_label.text = "Hotel standing  •  %s" % str(data.get("rank", "Creaky Inn"))
	coins_label.text = "+ %d GHOST COINS" % int(data.get("coins_earned", 0))
	reputation_label.text = "+ %d REPUTATION" % int(data.get("reputation_gain", 0))

	continue_button.text = "BEGIN NIGHT %d" % GameState.current_night if won else "TRY THE NIGHT AGAIN"
	continue_button.pressed.connect(_on_continue)
	rooms_button.pressed.connect(_on_rooms)
	book_button.pressed.connect(_on_book)

	if won and bool(data.get("rank_changed", false)):
		_show_rank_up(str(data.get("previous_rank", "Creaky Inn")), str(data.get("rank", "Creaky Inn")))


func _on_continue() -> void:
	if bool(GameState.last_night_summary.get("won", false)):
		get_tree().change_scene_to_file("res://scenes/NightTransition.tscn")
	else:
		get_tree().change_scene_to_file("res://main.tscn")

func _on_rooms() -> void:
	get_tree().change_scene_to_file("res://scenes/RoomsOverview.tscn")

func _on_book() -> void:
	get_tree().change_scene_to_file("res://scenes/GhostBook.tscn")

func _show_rank_up(old_rank: String, new_rank: String) -> void:
	rank_overlay = ColorRect.new()
	rank_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rank_overlay.color = Color(0.015, 0.008, 0.018, 0.96)
	rank_overlay.modulate.a = 0.0
	rank_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(rank_overlay)

	rank_title = Label.new()
	rank_title.text = "✦  HOTEL RANK ASCENDED  ✦"
	rank_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_title.add_theme_font_size_override("font_size", 26)
	rank_title.add_theme_color_override("font_color", Color(0.95, 0.72, 0.30, 1.0))
	rank_title.position = Vector2(240, 220)
	rank_title.size = Vector2(800, 55)
	rank_overlay.add_child(rank_title)

	rank_change = Label.new()
	rank_change.text = old_rank + "\n↓\n" + new_rank
	rank_change.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_change.add_theme_font_size_override("font_size", 34)
	rank_change.add_theme_color_override("font_color", Color(1.0, 0.88, 0.62, 1.0))
	rank_change.position = Vector2(240, 300)
	rank_change.size = Vector2(800, 170)
	rank_overlay.add_child(rank_change)

	var plaque: Label = Label.new()
	plaque.text = "The old brass plaque creaks... then reshapes itself."
	plaque.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plaque.add_theme_font_size_override("font_size", 16)
	plaque.add_theme_color_override("font_color", Color(0.70, 0.66, 0.62, 1.0))
	plaque.position = Vector2(240, 500)
	plaque.size = Vector2(800, 40)
	rank_overlay.add_child(plaque)

	var tween: Tween = create_tween()
	tween.tween_property(rank_overlay, "modulate:a", 1.0, 0.55)
	tween.tween_property(rank_change, "scale", Vector2(1.08, 1.08), 0.32).set_trans(Tween.TRANS_BACK)
	tween.tween_property(rank_change, "scale", Vector2.ONE, 0.24)
	tween.tween_interval(1.65)
	tween.tween_property(rank_overlay, "modulate:a", 0.0, 0.65)
	tween.tween_callback(rank_overlay.queue_free)
