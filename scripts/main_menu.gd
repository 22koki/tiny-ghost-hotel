extends Control


@onready var hotel_background: TextureRect = $HotelBackground
@onready var dark_overlay: ColorRect = $DarkOverlay
@onready var menu_panel: Panel = $MenuPanel

@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel

@onready var enter_hotel_button: Button = $EnterHotelButton
@onready var how_to_play_button: Button = $HowToPlayButton
@onready var quit_button: Button = $QuitButton


var entering_hotel := false


func _ready() -> void:
	hotel_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	connect_button(enter_hotel_button, _on_enter_hotel_pressed)
	connect_button(how_to_play_button, _on_how_to_play_pressed)
	connect_button(quit_button, _on_quit_pressed)

	setup_button_animation(enter_hotel_button)
	setup_button_animation(how_to_play_button)
	setup_button_animation(quit_button)

	animate_menu_entrance()


func connect_button(button: Button, callback: Callable) -> void:
	if not button.pressed.is_connected(callback):
		button.pressed.connect(callback)


func setup_button_animation(button: Button) -> void:
	if not button.mouse_entered.is_connected(
		_on_button_mouse_entered.bind(button)
	):
		button.mouse_entered.connect(
			_on_button_mouse_entered.bind(button)
		)

	if not button.mouse_exited.is_connected(
		_on_button_mouse_exited.bind(button)
	):
		button.mouse_exited.connect(
			_on_button_mouse_exited.bind(button)
		)


func animate_menu_entrance() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	menu_panel.modulate.a = 0.0

	enter_hotel_button.modulate.a = 0.0
	how_to_play_button.modulate.a = 0.0
	quit_button.modulate.a = 0.0

	title_label.scale = Vector2(0.75, 0.75)

	await get_tree().process_frame
	title_label.pivot_offset = title_label.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		title_label,
		"modulate:a",
		1.0,
		0.7
	)

	tween.tween_property(
		title_label,
		"scale",
		Vector2.ONE,
		0.7
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		subtitle_label,
		"modulate:a",
		1.0,
		0.9
	)

	tween.tween_property(
		menu_panel,
		"modulate:a",
		1.0,
		0.9
	)

	tween.tween_property(
		enter_hotel_button,
		"modulate:a",
		1.0,
		1.0
	)

	tween.tween_property(
		how_to_play_button,
		"modulate:a",
		1.0,
		1.1
	)

	tween.tween_property(
		quit_button,
		"modulate:a",
		1.0,
		1.2
	)


func _on_button_mouse_entered(button: Button) -> void:
	if button.disabled:
		return

	await get_tree().process_frame
	button.pivot_offset = button.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		button,
		"scale",
		Vector2(1.06, 1.06),
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		button,
		"modulate",
		Color(1.1, 1.1, 1.1, 1.0),
		0.12
	)


func _on_button_mouse_exited(button: Button) -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		button,
		"scale",
		Vector2.ONE,
		0.12
	)

	tween.tween_property(
		button,
		"modulate",
		Color.WHITE,
		0.12
	)


func _on_enter_hotel_pressed() -> void:
	if entering_hotel:
		return

	entering_hotel = true

	await play_enter_hotel_transition()

	get_tree().change_scene_to_file("res://main.tscn")


func play_enter_hotel_transition() -> void:
	enter_hotel_button.disabled = true
	how_to_play_button.disabled = true
	quit_button.disabled = true

	var fade_tween := create_tween()
	fade_tween.set_parallel(true)

	fade_tween.tween_property(
		title_label,
		"modulate:a",
		0.0,
		0.35
	)

	fade_tween.tween_property(
		subtitle_label,
		"modulate:a",
		0.0,
		0.35
	)

	fade_tween.tween_property(
		menu_panel,
		"modulate:a",
		0.0,
		0.35
	)

	fade_tween.tween_property(
		enter_hotel_button,
		"modulate:a",
		0.0,
		0.35
	)

	fade_tween.tween_property(
		how_to_play_button,
		"modulate:a",
		0.0,
		0.35
	)

	fade_tween.tween_property(
		quit_button,
		"modulate:a",
		0.0,
		0.35
	)

	await fade_tween.finished

	await get_tree().process_frame
	hotel_background.pivot_offset = hotel_background.size / 2.0

	var zoom_tween := create_tween()
	zoom_tween.set_parallel(true)

	zoom_tween.tween_property(
		hotel_background,
		"scale",
		Vector2(1.45, 1.45),
		1.45
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	zoom_tween.tween_property(
		dark_overlay,
		"color",
		Color(0.0, 0.0, 0.0, 1.0),
		1.45
	)

	await zoom_tween.finished


func _on_how_to_play_pressed() -> void:
	subtitle_label.text = (
		"Read each guest's request and choose the correct room.\n"
		+ "Wrong choices cost one life."
	)


func _on_quit_pressed() -> void:
	get_tree().quit()