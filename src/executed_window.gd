extends Control


@onready var command_log: RichTextLabel = %CommandLog


func _ready() -> void:
	Global._show_data.connect(_show_data)


func _show_data(a_data: PackedStringArray) -> void:
	command_log.text = ""

	for l_line: String in a_data:
		command_log.text += l_line
		if command_log.text.length() != 0:
			command_log.text += "\n"	


func _on_close_button_pressed() -> void:
	Global._on_popup_closed.emit()
	queue_free()


func _on_save_close_button_pressed() -> void:
	Global._on_save_values.emit()
	Global._on_popup_closed.emit()
	queue_free()

