extends Control


const SAVE_PATH: String = "user://data"
const END_KEY: String = "[ END ]"


@onready var entries: VBoxContainer = %Entries
@onready var busy_panel: Panel = $BusyPanel
@onready var no_file_panel: Panel = %NoFile

var directory: String = ""

var data: Dictionary = {}
var args: Dictionary = {}



func _ready() -> void:
	if Global._on_save_values.connect(_save_values):
		printerr("Something went wrong connecting to _save_values")

	get_window().unresizable = false
	busy_panel.visible = false
	no_file_panel.visible = false

	# Search for easy_menu.conf, we take the first one we find to continue
	var l_dir: DirAccess = DirAccess.open("")

	for l_file: String in l_dir.get_files():
		if l_file == "easy_menu.conf":
			directory = l_dir.get_current_dir()
			_load_values()
			_open_file(FileAccess.open(directory + "/" + l_file, FileAccess.READ))
			return

	no_file_panel.visible = true
	printerr("No file found with name 'easy_menu.conf'!")

	
func _open_file(a_file: FileAccess) -> void:
	var l_lines: PackedStringArray = []

	while !a_file.eof_reached():
		var l_line: String = a_file.get_line()

		if l_line != "":
			l_lines.append(l_line)

	l_lines.append(END_KEY)

	for l_line: String in l_lines:
		if l_line[0] == "#": continue # Comment
		elif l_line[0] == "[":
			if !data.is_empty():
				if data["type"] == "settings":
					_set_settings()
				else:
					call("_create_" + data["type"])

			if l_line == END_KEY:
				return

			data.clear()
			data["type"] = _get_type(l_line)
		else:
			data[_trim_edges(l_line.split('=')[0]).to_lower()] = _trim_edges(l_line.trim_prefix(l_line.split('=')[0] + "="), '"')


func _trim_edges(a_text: String, a_char: String = "") -> String:
	return a_text.strip_edges().trim_prefix(a_char).trim_suffix(a_char).strip_edges()


func _set_settings() -> void:
	const TITLE: String = "EasyMenu - %s"
	var window: Window = get_window()

	if data.has("window_title"):
		window.set_title(TITLE % data["window_title"])
	if data.has("window_width"): 
		window.size.x = int(data["window_width"])
	if data.has("window_height"):
		window.size.y = int(data["window_height"])


func _check_keys(a_required_keys: PackedStringArray, a_possible_keys: PackedStringArray) -> bool:
	var l_return: bool = true

	for l_key: String in a_required_keys:
		if !data.has(l_key):
			printerr("%s is missing key: %s" % [data["type"], l_key])
			l_return = false

	a_possible_keys.append_array(a_required_keys)
	a_possible_keys.append("type")

	for l_key: String in data:
		if !a_possible_keys.has(l_key):
			print("%s does not use key: %s" % [data["type"], l_key])

	return l_return


func _get_type(a_line: String) -> String:
	a_line = _trim_edges(a_line, "[")
	a_line = _trim_edges(a_line, "]")
	return a_line.to_lower()


func _get_array(a_line: String) -> Array:
	var l_array: Array = []
	
	for l_item: String in _trim_edges(_trim_edges(a_line, "["), "]").split(','):
		l_array.append(_trim_edges(l_item, '"'))

	return l_array


func _create_title() -> void:
	if !_check_keys(["title"], ["title", "tooltip"]): return

	var l_label: Label = Label.new()

	l_label.text = data["title"]
	l_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	entries.add_child(l_label)
	_create_hseparator()


func _create_hseparator() -> void:
	var l_separator: HSeparator = HSeparator.new()
	entries.add_child(l_separator)

	
func _create_spinbox() -> void:
	if !_check_keys(["title", "key"], ["tooltip", "arg", "min_value", "max_value", "value"]): return

	var l_spinbox: SpinBox = SpinBox.new()

	if data.has("min_value"):
		l_spinbox.min_value = int(data["min_value"])
	if data.has("max_value"):
		l_spinbox.max_value = int(data["max_value"])

	_add_entry(data["title"], l_spinbox)

	if args[data["key"]].has("value"):
		l_spinbox.value = int(args[data["key"]]["value"])
	elif data.has("value"):
		l_spinbox.value = int(data["value"])
		_on_value_changed(l_spinbox.value, data["key"])

	l_spinbox.value_changed.connect(_on_value_changed.bind(data["key"]))


func _create_lineedit() -> void:
	if !_check_keys(["title", "key"], ["tooltip", "arg", "default"]): return

	var l_line_edit: LineEdit = LineEdit.new()

	_add_entry(data["title"], l_line_edit)
	
	if args[data["key"]].has("value"):
		l_line_edit.text = args[data["key"]]["value"]
	elif data.has("default"):
		l_line_edit.text = data["default"]
		_on_value_changed(data["default"], data["key"])

	l_line_edit.text_changed.connect(_on_value_changed.bind(data["key"]))


func _create_optionbutton() -> void:
	if !_check_keys(["title", "key", "options"], ["tooltip", "arg", "default", "values"]): return

	var l_option_button: OptionButton = OptionButton.new()

	for l_item: String in _get_array(data["options"]):
		l_option_button.add_item(l_item)
	
	_add_entry(data["title"], l_option_button)

	if data.has("values"):
		l_option_button.item_selected.connect(_on_option_button_value_changed.bind(_get_array(data["values"]), data["key"]))

		if args[data["key"]].has("value"):
			l_option_button.selected = _get_array(data["values"]).find(args[data["key"]]["value"])
	else:
		l_option_button.item_selected.connect(_on_option_button_value_changed.bind(_get_array(data["options"]), data["key"]))

		if args[data["key"]].has("value"):
			l_option_button.selected = _get_array(data["options"]).find(args[data["key"]]["value"])
		
	if !args[data["key"]].has("value") and data.has("default"):
		l_option_button.selected = int(data["default"])

		if data.has("values"):
			_on_option_button_value_changed(int(data["default"]), _get_array(data["values"]), data["key"])
		else:
			_on_option_button_value_changed(int(data["default"]), _get_array(data["options"]), data["key"])
	elif data.has("values"):
		_on_option_button_value_changed(0, _get_array(data["values"]), data["key"])
	else:
		_on_option_button_value_changed(0, _get_array(data["options"]), data["key"])


func _on_option_button_value_changed(a_id: int, a_values: Array, a_key: String) -> void:
	_on_value_changed(a_values[a_id], a_key)


func _create_checkbutton() -> void:
	if !_check_keys(["title", "key", "on_true", "on_false"], ["tooltip", "arg", "on_true", "on_false"]): return

	var l_check_button: CheckButton = CheckButton.new()

	_add_entry(data["title"], l_check_button)

	if args[data["key"]].has("value"):
		l_check_button.button_pressed = data["on_true"] == args[data["key"]]["value"]
	_on_check_button_toggled(l_check_button.button_pressed, data["on_true"], data["on_false"], data["key"])

	l_check_button.toggled.connect(_on_check_button_toggled.bind(data["on_true"], data["on_false"], data["key"]))


func _on_check_button_toggled(a_value: bool, a_true: String, a_false: String, a_key: String) -> void:
	_on_value_changed(a_true if a_value else a_false, a_key)


func _create_button() -> void:
	var l_button: Button = Button.new()

	if !data.has("title"):
		printerr("Can't create button because no title was given!")
		return
	elif !data.has("cmd"):
		printerr("Can't create button because no command was given!")
		return

	l_button.text = data["title"]
	l_button.pressed.connect(_execute.bind(data["cmd"]))
	entries.add_child(l_button)


func _add_entry(a_title: String, a_entry: Control) -> void:
	var l_hbox: HBoxContainer = HBoxContainer.new()
	var l_label: Label = Label.new()

	l_label.text = a_title
	l_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	a_entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if !data.has("key"):
		return

	if !args.has(data["key"]):
		args[data["key"]] = {}

	if !data.has("arg"):
		args[data["key"]]["arg"] = "{value}"
	else:
		args[data["key"]]["arg"] = data["arg"]

	if data.has("key") and !args[data["key"]].has("value"):
		args[data["key"]]["value"] = ""

	if data.has("tooltip"):
		l_hbox.tooltip_text = data["tooltip"]

	l_hbox.add_child(l_label)
	l_hbox.add_child(a_entry)
	entries.add_child(l_hbox)
	

func _execute(a_command: String) -> void:
	busy_panel.visible = true
	await RenderingServer.frame_post_draw
	release_focus()

	for l_key: String in args.keys():
		a_command = a_command.replace("{%s}" % l_key, args[l_key]["arg"].replace("{value}", str(args[l_key]["value"])))
	
	var l_args: PackedStringArray = a_command.split(' ')
	var l_main: String = l_args[0]
	var l_output: Array = []

	l_args.remove_at(0)
	OS.execute(l_main, l_args, l_output, true)
	
	var l_popup: Control = preload("res://executed_window.tscn").instantiate()
	add_child(l_popup)
	Global._show_data.emit(l_output)

	await Global._on_popup_closed
	busy_panel.visible = false


func _on_value_changed(a_value: Variant, a_key: String) -> void:
	args[a_key]["value"] = a_value


func _save_values() -> void:
	var l_file: FileAccess
	var l_file_data: Dictionary = {}

	if FileAccess.file_exists(SAVE_PATH):
		l_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		l_file_data = str_to_var(l_file.get_as_text())
		l_file.close()
	
	l_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	l_file_data[directory] = args
	l_file.store_string(var_to_str(l_file_data))


func _load_values() -> void:
	if !FileAccess.file_exists(SAVE_PATH):
		return

	var l_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var l_file_data: Dictionary = str_to_var(l_file.get_as_text())

	if l_file_data.has(directory):
		args = l_file_data[directory]

