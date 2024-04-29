# A popup for picking a color.
extends PanelContainer

const GoodColorPickerType = preload("res://src/ui_elements/good_color_picker.gd")
const ColorSwatchType = preload("res://src/ui_elements/color_swatch.gd")

const ColorSwatch = preload("res://src/ui_elements/color_swatch.tscn")

signal color_picked(new_color: String, final: bool)
var current_value: String

var palette_mode := true

@onready var palettes_content: ScrollContainer = %Content/Palettes
@onready var palettes_content_container: VBoxContainer = %PalettesContent
@onready var search_field: BetterLineEdit = %SearchBox/SearchField
@onready var color_picker_content: VBoxContainer = %Content/ColorPicker
@onready var color_picker: GoodColorPickerType = %Content/ColorPicker
@onready var switch_mode_button: Button = $MainContainer/SwitchMode

var swatches_list: Array[ColorSwatchType] = []  # Updated manually.

func _ready() -> void:
	# Setup the switch mode button.
	for theme_type in ["normal", "hover", "pressed"]:
		var sb: StyleBoxFlat = switch_mode_button.get_theme_stylebox(theme_type,
				"TranslucentButton").duplicate()
		sb.corner_radius_top_left = 0
		sb.corner_radius_top_right = 0
		sb.corner_radius_bottom_left = 4
		sb.corner_radius_bottom_right = 4
		sb.content_margin_bottom = 3
		sb.content_margin_top = 3
		switch_mode_button.add_theme_stylebox_override(theme_type, sb)
	# Setup the rest.
	update_palettes()
	update_color_picker()
	search_field.text_changed.connect(update_palettes)
	search_field.text_change_canceled.connect(update_palettes)

func update_palettes(search_text := "") -> void:
	for child in palettes_content_container.get_children():
		child.queue_free()
	search_field.placeholder_text = tr("Search color")
	var reserved_color_palette := ColorPalette.new("")
	reserved_color_palette.add_color()  # Add the "none" color.
	# TODO Gradients should be added here.
	var displayed_palettes: Array[ColorPalette] = [reserved_color_palette]
	displayed_palettes += GlobalSettings.palettes
	for palette in displayed_palettes:
		var indices_to_show: Array[int] = []
		for i in palette.colors.size():
			if search_text.is_empty() or\
			search_text.is_subsequence_ofn(palette.color_names[i]):
				indices_to_show.append(i)
		
		if indices_to_show.is_empty():
			continue
		
		var palette_container := VBoxContainer.new()
		# Only the reserved palette should have an empty name.
		if not palette.title.is_empty():
			var palette_label := Label.new()
			palette_label.text = palette.title
			palette_label.add_theme_font_size_override("font_size", 15)
			palette_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			palette_container.add_child(palette_label)
		
		var swatch_container := HFlowContainer.new()
		swatch_container.add_theme_constant_override("h_separation", 3)
		for i in indices_to_show:
			var swatch := ColorSwatch.instantiate()
			var color_to_show := palette.colors[i]
			swatch.color_palette = palette
			swatch.idx = i
			swatch.pressed.connect(pick_palette_color.bind(color_to_show))
			swatch_container.add_child(swatch)
			swatches_list.append(swatch)
			if ColorParser.are_colors_same(ColorParser.add_hash_if_hex(color_to_show),
			current_value):
				swatch.disabled = true
				swatch.mouse_default_cursor_shape = Control.CURSOR_ARROW
		palette_container.add_child(swatch_container)
		palettes_content_container.add_child(palette_container)

func update_color_picker() -> void:
	color_picker.setup_color(current_value)

func pick_palette_color(color: String) -> void:
	current_value = color
	queue_free()

func pick_color(color: String) -> void:
	current_value = color
	update_palettes(search_field.text)
	color_picked.emit(color, false)


# Switching between palette mode and color picker mode.
func _on_switch_mode_pressed() -> void:
	palette_mode = not palette_mode
	switch_mode_button.text = tr("Palettes") if palette_mode else tr("Color Picker")
	color_picker_content.visible = not palette_mode
	palettes_content.visible = palette_mode

func _on_tree_exited() -> void:
	color_picked.emit(current_value, true)
