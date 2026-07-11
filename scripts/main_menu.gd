extends Control


@onready var hotel_background: TextureRect = $HotelBackground
@onready var moon_glow: TextureRect = $MoonGlow
@onready var dark_overlay: ColorRect = $DarkOverlay

@onready var fog_back: TextureRect = $FogBack
@onready var fog_front: TextureRect = $FogFront

@onready var star_one: Label = $StarOne
@onready var star_two: Label = $StarTwo
@onready var star_three: Label = $StarThree
@onready var star_four: Label = $StarFour

@onready var ghost_left: Label = $GhostLeft
@onready var ghost_middle: Label = $GhostMiddle
@onready var ghost_right: Label = $GhostRight

@onready var menu_panel: Panel = $MenuPanel
@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel
@onready var footer_label: Label = $FooterLabel

@onready var enter_hotel_button: Button = $EnterHotelButton
@onready var how_to_play_button: Button = $HowToPlayButton
@onready var quit_button: Button = $QuitButton

@onready var how_to_play_overlay: ColorRect = $HowToPlayOverlay
@onready var how_to_play_panel: Panel = $HowToPlayOverlay/HowToPlayPanel
@onready var close_how_to_play_button: Button = (
	$HowToPlayOverlay/HowToPlayPanel/CloseHowToPlayButton
)

@onready var transition_overlay: ColorRect = $TransitionOverlay


var entering_hotel: bool = false
var popup_open: bool = false

var fog_back_tween: Tween
var fog_front_tween: Tween
var moon_tween: Tween

var ghost_left_tween: Tween
var ghost_middle_tween: Tween
var ghost_right_tween: Tween

var star_one_tween: Tween
var star_two_tween: Tween
var star_three_tween: Tween
var star_four_tween: Tween


func _ready() -> void:
	setup_mouse_filters()
	connect_buttons()
	setup_button_animations()

	transition_overlay.modulate.a = 0.0
	how_to_play_overlay.visible = false

	animate_menu_entrance()
	start_background_animations()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if popup_open:
			close_how_to_play()
		else:
			get_tree().quit()


func setup_mouse_filters() -> void:
	hotel_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	moon_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog_front.mouse_filter = Control.MOUSE_FILTER_IGNORE

	star_one.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_two.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_three.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_four.mouse_filter = Control.MOUSE_FILTER_IGNORE

	ghost_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost_middle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost_right.mouse_filter = Control.MOUSE_FILTER_IGNORE

	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


func connect_buttons() -> void:
	connect_button(
		enter_hotel_button,
		_on_enter_hotel_pressed
	)

	connect_button(
		how_to_play_button,
		_on_how_to_play_pressed
	)

	connect_button(
		quit_button,
		_on_quit_pressed
	)

	connect_button(
		close_how_to_play_button,
		close_how_to_play
	)


func connect_button(
	button: Button,
	callback: Callable
) -> void:
	if not button.pressed.is_connected(callback):
		button.pressed.connect(callback)


func setup_button_animations() -> void:
	var buttons: Array[Button] = [
		enter_hotel_button,
		how_to_play_button,
		quit_button,
		close_how_to_play_button
	]

	for button in buttons:
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


# =========================================================
# MENU ENTRANCE
# =========================================================

func animate_menu_entrance() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	menu_panel.modulate.a = 0.0
	footer_label.modulate.a = 0.0

	enter_hotel_button.modulate.a = 0.0
	how_to_play_button.modulate.a = 0.0
	quit_button.modulate.a = 0.0

	title_label.scale = Vector2(0.72, 0.72)
	menu_panel.scale = Vector2(0.92, 0.92)

	await get_tree().process_frame

	title_label.pivot_offset = title_label.size / 2.0
	menu_panel.pivot_offset = menu_panel.size / 2.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		title_label,
		"modulate:a",
		1.0,
		0.75
	)

	tween.tween_property(
		title_label,
		"scale",
		Vector2.ONE,
		0.75
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		subtitle_label,
		"modulate:a",
		1.0,
		0.95
	)

	tween.tween_property(
		menu_panel,
		"modulate:a",
		1.0,
		0.85
	)

	tween.tween_property(
		menu_panel,
		"scale",
		Vector2.ONE,
		0.85
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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
		1.15
	)

	tween.tween_property(
		quit_button,
		"modulate:a",
		1.0,
		1.3
	)

	tween.tween_property(
		footer_label,
		"modulate:a",
		1.0,
		1.4
	)


# =========================================================
# BACKGROUND ANIMATIONS
# =========================================================

func start_background_animations() -> void:
	start_fog_animation()
	start_moon_animation()

	animate_floating_ghost(
		ghost_left,
		18.0,
		1.8,
		-5.0
	)

	animate_floating_ghost(
		ghost_middle,
		13.0,
		1.45,
		4.0
	)

	animate_floating_ghost(
		ghost_right,
		21.0,
		2.1,
		-4.0
	)

	start_star_animations()


func start_fog_animation() -> void:
	if fog_back_tween:
		fog_back_tween.kill()

	if fog_front_tween:
		fog_front_tween.kill()

	var fog_back_start_x := fog_back.position.x
	var fog_front_start_x := fog_front.position.x

	fog_back_tween = create_tween()
	fog_back_tween.set_loops()

	fog_back_tween.tween_property(
		fog_back,
		"position:x",
		fog_back_start_x + 150.0,
		8.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	fog_back_tween.tween_property(
		fog_back,
		"position:x",
		fog_back_start_x,
		8.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	fog_front_tween = create_tween()
	fog_front_tween.set_loops()

	fog_front_tween.tween_property(
		fog_front,
		"position:x",
		fog_front_start_x - 190.0,
		6.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	fog_front_tween.tween_property(
		fog_front,
		"position:x",
		fog_front_start_x,
		6.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func start_moon_animation() -> void:
	await get_tree().process_frame

	moon_glow.pivot_offset = moon_glow.size / 2.0

	moon_tween = create_tween()
	moon_tween.set_loops()

	moon_tween.tween_property(
		moon_glow,
		"scale",
		Vector2(1.08, 1.08),
		2.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	moon_tween.parallel().tween_property(
		moon_glow,
		"modulate:a",
		0.92,
		2.2
	)

	moon_tween.tween_property(
		moon_glow,
		"scale",
		Vector2.ONE,
		2.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	moon_tween.parallel().tween_property(
		moon_glow,
		"modulate:a",
		0.58,
		2.2
	)


func animate_floating_ghost(
	ghost: Label,
	distance: float,
	duration: float,
	rotation_degrees: float
) -> void:
	await get_tree().process_frame

	ghost.pivot_offset = ghost.size / 2.0
	var starting_y := ghost.position.y

	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		ghost,
		"position:y",
		starting_y - distance,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(
		ghost,
		"rotation",
		deg_to_rad(rotation_degrees),
		duration
	)

	tween.parallel().tween_property(
		ghost,
		"modulate:a",
		0.88,
		duration
	)

	tween.tween_property(
		ghost,
		"position:y",
		starting_y + distance,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(
		ghost,
		"rotation",
		deg_to_rad(-rotation_degrees),
		duration
	)

	tween.parallel().tween_property(
		ghost,
		"modulate:a",
		0.45,
		duration
	)

	if ghost == ghost_left:
		ghost_left_tween = tween
	elif ghost == ghost_middle:
		ghost_middle_tween = tween
	elif ghost == ghost_right:
		ghost_right_tween = tween


func start_star_animations() -> void:
	star_one_tween = animate_star(
		star_one,
		0.55,
		1.25
	)

	star_two_tween = animate_star(
		star_two,
		0.3,
		1.65
	)

	star_three_tween = animate_star(
		star_three,
		0.5,
		1.1
	)

	star_four_tween = animate_star(
		star_four,
		0.25,
		1.8
	)


func animate_star(
	star: Label,
	minimum_alpha: float,
	duration: float
) -> Tween:
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		star,
		"modulate:a",
		minimum_alpha,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		star,
		"modulate:a",
		1.0,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	return tween


func stop_background_animations() -> void:
	var tweens: Array[Tween] = [
		fog_back_tween,
		fog_front_tween,
		moon_tween,
		ghost_left_tween,
		ghost_middle_tween,
		ghost_right_tween,
		star_one_tween,
		star_two_tween,
		star_three_tween,
		star_four_tween
	]

	for tween in tweens:
		if tween:
			tween.kill()


# =========================================================
# BUTTON ANIMATIONS
# =========================================================

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
		Vector2(1.075, 1.075),
		0.14
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		button,
		"modulate",
		Color(1.12, 1.08, 1.16, 1),
		0.14
	)


func _on_button_mouse_exited(button: Button) -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		button,
		"scale",
		Vector2.ONE,
		0.14
	)

	tween.tween_property(
		button,
		"modulate",
		Color.WHITE,
		0.14
	)


func animate_button_press(button: Button) -> void:
	await get_tree().process_frame
	button.pivot_offset = button.size / 2.0

	var tween := create_tween()

	tween.tween_property(
		button,
		"scale",
		Vector2(0.94, 0.94),
		0.07
	)

	tween.tween_property(
		button,
		"scale",
		Vector2.ONE,
		0.1
	)


# =========================================================
# HOW TO PLAY
# =========================================================

func _on_how_to_play_pressed() -> void:
	if entering_hotel:
		return

	animate_button_press(how_to_play_button)
	open_how_to_play()


func open_how_to_play() -> void:
	popup_open = true
	how_to_play_overlay.visible = true
	how_to_play_overlay.modulate.a = 0.0

	how_to_play_panel.scale = Vector2(0.75, 0.75)

	await get_tree().process_frame
	how_to_play_panel.pivot_offset = (
		how_to_play_panel.size / 2.0
	)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		how_to_play_overlay,
		"modulate:a",
		1.0,
		0.25
	)

	tween.tween_property(
		how_to_play_panel,
		"scale",
		Vector2.ONE,
		0.35
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close_how_to_play() -> void:
	if not popup_open:
		return

	popup_open = false

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		how_to_play_overlay,
		"modulate:a",
		0.0,
		0.2
	)

	tween.tween_property(
		how_to_play_panel,
		"scale",
		Vector2(0.82, 0.82),
		0.2
	)

	await tween.finished

	how_to_play_overlay.visible = false
	how_to_play_panel.scale = Vector2.ONE


# =========================================================
# ENTER HOTEL TRANSITION
# =========================================================

func _on_enter_hotel_pressed() -> void:
	if entering_hotel:
		return

	if popup_open:
		return

	entering_hotel = true
	animate_button_press(enter_hotel_button)

	await play_enter_hotel_transition()

	get_tree().change_scene_to_file(
		"res://main.tscn"
	)


func play_enter_hotel_transition() -> void:
	enter_hotel_button.disabled = true
	how_to_play_button.disabled = true
	quit_button.disabled = true

	stop_background_animations()

	var fade_menu := create_tween()
	fade_menu.set_parallel(true)

	var menu_items: Array[CanvasItem] = [
		title_label,
		subtitle_label,
		menu_panel,
		enter_hotel_button,
		how_to_play_button,
		quit_button,
		footer_label,
		star_one,
		star_two,
		star_three,
		star_four
	]

	for item in menu_items:
		fade_menu.tween_property(
			item,
			"modulate:a",
			0.0,
			0.4
		)

	fade_menu.tween_property(
		ghost_left,
		"position:x",
		ghost_left.position.x - 180.0,
		0.55
	)

	fade_menu.tween_property(
		ghost_middle,
		"position:y",
		ghost_middle.position.y - 180.0,
		0.55
	)

	fade_menu.tween_property(
		ghost_right,
		"position:x",
		ghost_right.position.x + 180.0,
		0.55
	)

	fade_menu.tween_property(
		ghost_left,
		"modulate:a",
		0.0,
		0.45
	)

	fade_menu.tween_property(
		ghost_middle,
		"modulate:a",
		0.0,
		0.45
	)

	fade_menu.tween_property(
		ghost_right,
		"modulate:a",
		0.0,
		0.45
	)

	await fade_menu.finished

	var fog_tween := create_tween()
	fog_tween.set_parallel(true)

	fog_tween.tween_property(
		fog_back,
		"modulate:a",
		0.8,
		0.55
	)

	fog_tween.tween_property(
		fog_front,
		"modulate:a",
		0.95,
		0.55
	)

	fog_tween.tween_property(
		fog_front,
		"position:y",
		fog_front.position.y - 70.0,
		0.65
	)

	await fog_tween.finished

	await get_tree().process_frame

	hotel_background.pivot_offset = (
		hotel_background.size / 2.0
	)

	dark_overlay.pivot_offset = (
		dark_overlay.size / 2.0
	)

	var zoom_tween := create_tween()
	zoom_tween.set_parallel(true)

	zoom_tween.tween_property(
		hotel_background,
		"scale",
		Vector2(1.75, 1.75),
		1.55
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	zoom_tween.tween_property(
		hotel_background,
		"position",
		Vector2(-285.0, -135.0),
		1.55
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	zoom_tween.tween_property(
		moon_glow,
		"modulate:a",
		0.0,
		1.0
	)

	zoom_tween.tween_property(
		fog_back,
		"modulate:a",
		0.0,
		1.1
	)

	zoom_tween.tween_property(
		fog_front,
		"modulate:a",
		0.0,
		1.1
	)

	zoom_tween.tween_property(
		dark_overlay,
		"color",
		Color(0.025, 0.005, 0.045, 0.58),
		1.3
	)

	await zoom_tween.finished

	transition_overlay.modulate.a = 0.0

	var black_tween := create_tween()

	black_tween.tween_property(
		transition_overlay,
		"modulate:a",
		1.0,
		0.6
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await black_tween.finished


func _on_quit_pressed() -> void:
	if entering_hotel:
		return

	get_tree().quit()