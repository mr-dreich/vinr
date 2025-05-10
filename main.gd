extends Control


const UserOptionsPath: String = 'user://user.options'
const DefaultOptions: Dictionary = {
	'valheim_directory': "",
	'save_dir': "",
	'instance_id': 1,
	'public': 1,
	'port': "2456",
	'crossplay': false,
	'server_name': "My server",
	'password': "Secret",
	'world': "Dedicated",
	'seed': "",
	'save_interval': 1800,
	'backups': 4,
	'backup_short': 7200,
	'backup_long': 43200,
	'preset': "hard",
	'combat': "hard",
	'death_penalty': "hard",
	'resources': "less",
	'raids': "less",
	'portals': "hard",
	'set_key': ["playerevents"],
}

var _user_options: Dictionary = {}


func create_script() -> void:
	var port :=  str(" -port ",'"',_user_options.port,'"')
	var instance_id :=  str(" -instanceid ",'"',_user_options.instance_id,'"')
	var public := str(" -public ",_user_options.public)
	var server_name := str(" -name ",'"',_user_options.server_name,'"')
	var password := str(" -password ",'"',_user_options.password,'"')
	var world := str(" -world ",'"',_user_options.world,'"')
	var world_seed := str(" -worldseed ",'"',_user_options.seed,'"')
	var preset := str(" -preset ",_user_options.preset)
	var combat := str(" -modifier combat ",_user_options.combat)
	var raids := str(" -modifier raids ",_user_options.raids)
	var death := str(" -modifier deathpenalty ",_user_options.death_penalty)
	var resources := str(" -modifier resources ",_user_options.resources)
	var save_interval := str(" -saveinterval ",_user_options.save_interval)
	var backups := str(" -backups ",_user_options.backups)
	var backupshort := str(" -backupshort ",_user_options.backup_short)
	var backuplong := str(" -backuplong ",_user_options.backup_long)
	var savedir := str(" -savedir ",'"',_user_options.save_dir,'"')
	var setkey := str(" -setkey ")
	for key in _user_options.set_key:
		setkey += str(key," ")
	
	var start: String = ""
	var output: String = ""
	var file_path: String = ""
	var os_name: String = OS.get_name()
	match os_name:
		'Windows':
			start = str("valheim_server -nographics -batchmode")
			
			output = str("@echo off\n\necho Starting server PRESS CTRL-C to exit\n\n",
			start,instance_id,port,public,server_name,password,world,world_seed,preset,combat,raids,death,resources,
			setkey,save_interval,backups,backupshort,backuplong,savedir)
			file_path = str(_user_options.valheim_directory,"vinr_start_server.bat")
			
		'macOS':
			start = str('"$( dirname "$0" )"',"/valheim_server/Valheim")
			
			output = str("#!/bin/zsh\n\necho",' "',"Starting server PRESS CMD-C to exit",'"',"\n\n",
			start,instance_id,port,public,server_name,password,world,world_seed,preset,combat,raids,death,resources,
			setkey,save_interval,backups,backupshort,backuplong,savedir)
			file_path = str(_user_options.valheim_directory,"vinr_start_server.command")
	
	if os_name != 'Web':
		var file := FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(output)
	%OutputLog.text = output


func setup_elements() -> void:
	for key in DefaultOptions.keys():
		var node = get_node_or_null(str('%',key))
		if is_instance_valid(node):
			if node is LineEdit:
				node.text = str(_user_options[key])
				node.caret_column = node.text.length()
			if node is CheckBox:
				node.set_pressed_no_signal(bool(_user_options[key]))
			if node is SpinBox:
				node.set_value_no_signal(int(_user_options[key]))
			if node is OptionButton:
				for i in node.get_item_count():
					if node.get_item_text(i).to_lower() == _user_options[key]:
						node.selected = i
			if key == 'set_key':
				for child: CheckBox in %set_key.get_children():
					if child.name in _user_options.set_key:
						child.button_pressed = true
					else:
						child.button_pressed = false
	
	match OS.get_name():
		'Web':
			%valheim_directory.get_parent().hide()
			%save_dir.get_parent().hide()
			%OpenValheimDirButton.hide()


func reset() -> void:
	_user_options = DefaultOptions.duplicate(true)
	var home_path := OS.get_environment('USERPROFILE') if OS.has_feature('windows') else OS.get_environment('HOME')
	var os_name: String = OS.get_name()
	match os_name:
		'Windows':
			var valheim_path := str(OS.get_environment('ProgramFiles'),'/Steam/steamapps/common/Valheim dedicated server/')
			if DirAccess.dir_exists_absolute(valheim_path):
				_user_options.valheim_directory = valheim_path
			var worlds_path := str(home_path,'/AppData/LocalLow/IronGate/Valheim/worlds/')
			if DirAccess.dir_exists_absolute(worlds_path):
				_user_options.save_dir = worlds_path
			
		'macOS':
			var valheim_path := str(home_path,'/Library/Application Support/Steam/steamapps/common/Valheim dedicated server/')
			if DirAccess.dir_exists_absolute(valheim_path):
				_user_options.valheim_directory = valheim_path
			var worlds_path := str(home_path,'/Library/Application Support/IronGate/Valheim/worlds/')
			if DirAccess.dir_exists_absolute(worlds_path):
				_user_options.save_dir = worlds_path
	
	if os_name != 'Web':
		%valheim_directory.text = _user_options.valheim_directory
		%valheim_directory.caret_column = %valheim_directory.text.length()
		%save_dir.text = _user_options.save_dir
		%save_dir.caret_column = %save_dir.text.length()
	%OutputLog.text = ""


func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load(UserOptionsPath)
	for key in config.get_section_keys('data'):
		_user_options[key] = config.get_value('data', key)
	await get_tree().process_frame


func save_settings() -> void:
	var config := ConfigFile.new()
	for key in DefaultOptions:
		config.set_value('data', key, _user_options[key])
	config.save(UserOptionsPath)


func _ready() -> void:
	get_viewport().get_window().min_size = Vector2(860, 600)
	
	$%DefaultsButton.pressed.connect(_on_defaults_button_pressed)
	%CreateScriptButton.pressed.connect(_on_create_script_button_pressed)
	%ValheimPathBrowseButton.pressed.connect(_on_valheim_path_browse_button_pressed)
	%ValheimPathBrowseButtonAlt.pressed.connect(_on_valheim_path_browse_button_alt_pressed)
	%SaveDirBrowseButton.pressed.connect(_on_save_dir_browse_button_pressed)
	%CopyOutputButton.pressed.connect(_on_copy_output_button_pressed)
	%ClearOutputButton.pressed.connect(_on_clear_output_button_pressed)
	%OpenValheimDirButton.pressed.connect(_on_open_valheim_dir_pressed)
	
	for key in DefaultOptions:
		var node = get_node_or_null(str('%',key))
		if is_instance_valid(node):
			if node is LineEdit:
				node.text_changed.connect(_on_line_edit_changed.bind(node))
			if node is CheckBox:
				node.toggled.connect(_on_checkbox_toggled.bind(node))
			if node is SpinBox:
				node.value_changed.connect(_on_spinbox_value_changed.bind(node))
			if node is OptionButton:
				node.get_popup().id_pressed.connect(_on_option_button_id_selected.bind(node))
			if key == 'set_key':
				for child: CheckBox in %set_key.get_children():
					child.toggled.connect(_on_checkbox_toggled.bind(child))
	
	reset()
	await load_settings()
	setup_elements()
	
	%TabContainer.current_tab = 0


func _on_line_edit_changed(text: String, node: LineEdit) -> void:
	_user_options[node.name.to_lower().replace(' ', '_')] = text
	save_settings()


func _on_checkbox_toggled(toggled: bool, node: CheckBox) -> void:
	if node.get_parent().name == 'set_key':
		var node_name := node.name.replace('&','')
		if toggled:
			if not _user_options.set_key.has(node_name):
				_user_options.set_key.append(node_name)
		else:
			_user_options.set_key.erase(node_name)
	else:
		_user_options[node.name.to_lower().replace(' ', '_')] = toggled
	save_settings()


func _on_spinbox_value_changed(value: float, node: SpinBox) -> void:
	_user_options[node.name.to_lower().replace(' ', '_')] = value
	save_settings()


func _on_option_button_id_selected(id: int, node: OptionButton) -> void:
	_user_options[node.name.to_lower().replace(' ', '_')] = node.get_item_text(id).to_lower()
	save_settings()


func _on_defaults_button_pressed() -> void:
	reset()
	setup_elements()


func _on_create_script_button_pressed() -> void:
	create_script()


func _on_valheim_path_browse_button_pressed() -> void:
	DisplayServer.file_dialog_show("Browse for Valheim Path", _user_options.valheim_directory, "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _on_valheim_path_file_dialog_file_opened)


func _on_valheim_path_browse_button_alt_pressed() -> void:
	DisplayServer.file_dialog_show("Browse for Valheim Path", _user_options.valheim_directory, "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _on_valheim_path_alt_file_dialog_file_opened)


func _on_save_dir_browse_button_pressed() -> void:
	DisplayServer.file_dialog_show("Browse for Save Directory", _user_options.save_dir, "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _on_save_dir_file_dialog_file_opened)


func _on_copy_output_button_pressed() -> void:
	DisplayServer.clipboard_set(%OutputLog.text)
	%CopiedLabel.show()
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(func(): timer.queue_free(); %CopiedLabel.hide())
	timer.start()


func _on_clear_output_button_pressed() -> void:
	%OutputLog.text = ""
	DisplayServer.clipboard_set("")


func _on_open_valheim_dir_pressed() -> void:
	OS.shell_open(_user_options.valheim_directory)


func _on_valheim_path_file_dialog_file_opened(status: bool, selected_paths: PackedStringArray, selected_filter_index: int) -> void:
	if not selected_paths.is_empty():
		_user_options.valheim_directory = str(selected_paths[0],"/")
		%valheim_directory.text = _user_options.valheim_directory
		%valheim_directory.caret_column = %valheim_directory.text.length()
		save_settings()


func _on_save_dir_file_dialog_file_opened(status: bool, selected_paths: PackedStringArray, selected_filter_index: int) -> void:
	if not selected_paths.is_empty():
		_user_options.save_dir = selected_paths[0]
		%save_dir.text = _user_options.save_dir
		%save_dir.caret_column = %save_dir.text.length()
		save_settings()


func _on_valheim_path_alt_file_dialog_file_opened(status: bool, selected_paths: PackedStringArray, selected_filter_index: int) -> void:
	if not selected_paths.is_empty():
		_user_options.valheim_directory = selected_paths[0]
		%valheim_directory_alt.text = _user_options.valheim_directory
		%valheim_directory_alt.caret_column = %valheim_directory_alt.text.length()
		save_settings()
