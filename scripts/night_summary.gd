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

func _ready() -> void:
	var data := GameState.last_night_summary
	if data.is_empty():
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		return

	var won := bool(data.get("won", false))
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

func _on_continue() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _on_rooms() -> void:
	get_tree().change_scene_to_file("res://scenes/RoomsOverview.tscn")

func _on_book() -> void:
	get_tree().change_scene_to_file("res://scenes/GhostBook.tscn")
