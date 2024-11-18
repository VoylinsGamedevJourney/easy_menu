extends Node

signal _on_save_values
signal _show_data(data: PackedStringArray)
signal _on_popup_closed



func _ready() -> void:
	# Just to get rid of the warnings
	if _on_save_values.is_null() or _show_data.is_null() or _on_popup_closed.is_null():
		printerr("Signals don't exist!")

