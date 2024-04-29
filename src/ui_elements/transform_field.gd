# An editor to be tied to a transform list attribute.
extends HBoxContainer

signal focused
var attribute: AttributeTransform

const TransformPopup = preload("res://src/ui_elements/transform_popup.tscn")

@onready var line_edit: BetterLineEdit = $LineEdit
@onready var popup_button: Button = $Button

func set_value(new_value: String, update_type := Utils.UpdateType.REGULAR) -> void:
	sync(attribute.autoformat(new_value))
	if attribute.get_value() != new_value or update_type == Utils.UpdateType.FINAL:
		match update_type:
			Utils.UpdateType.INTERMEDIATE:
				attribute.set_value(new_value, Attribute.SyncMode.INTERMEDIATE)
			Utils.UpdateType.FINAL:
				attribute.set_value(new_value, Attribute.SyncMode.FINAL)
			_:
				attribute.set_value(new_value)


func _ready() -> void:
	set_value(attribute.get_value())
	attribute.value_changed.connect(set_value)
	line_edit.tooltip_text = attribute.name
	line_edit.text_submitted.connect(set_value)

func _on_focus_entered() -> void:
	focused.emit()

func sync(new_value: String) -> void:
	line_edit.text = new_value

func _on_button_pressed() -> void:
	var transform_popup := TransformPopup.instantiate()
	transform_popup.attribute_ref = attribute
	HandlerGUI.popup_under_rect(transform_popup, line_edit.get_global_rect(), get_viewport())


func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and\
	event.is_pressed():
		accept_event()
		Utils.throw_mouse_motion_event(get_viewport())
	else:
		popup_button.mouse_filter = Utils.mouse_filter_pass_non_drag_events(event)
