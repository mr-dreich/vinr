extends Control


const AboutScene = preload('res://about.tscn')

const UserOptionsPath: String = 'user://user.options'
const DefaultOptions: Dictionary = {
	'keep_settings': false,
	'valheim_directory': {'enabled': true, 'value': ""},
	'save_dir': {'enabled': false, 'value': ""},
	'instance_id': {'enabled': false, 'value': 1},
	'public': {'enabled': true, 'value': 1},
	'port': {'enabled': true, 'value': "2456"},
	'crossplay': {'enabled': true, 'value': false},
	'server_name': {'enabled': true, 'value': "My server"},
	'password': {'enabled': true, 'value': "Secret"},
	'world_name': {'enabled': false, 'value': "Dedicated"},
	'seed': {'enabled': false, 'value': ""},
	'save_interval': {'enabled': false, 'value': 1800},
	'backups': {'enabled': false, 'value': 4},
	'backup_short': {'enabled': false, 'value': 7200},
	'backup_long': {'enabled': false, 'value': 3200},
	'preset': {'enabled': false, 'value': "hard"},
	'combat': {'enabled': false, 'value': "hard"},
	'death_penalty': {'enabled': false, 'value': "hard"},
	'resources': {'enabled': false, 'value': "less"},
	'raids': {'enabled': false, 'value': "less"},
	'portals': {'enabled': false, 'value': "less"},
	'set_key': [],
}
const OptionExplainations: Dictionary[String, String] = {
	'valheim_directory': "Location of your Valheim server installation.",
	'server_name': "The name of your server that will be visible in the Server list.",
	'seed': "The string used to seed the random World generator.",
	'port': "Choose the Port which you want the server to communicate with.",
	'world_name': "A World with the name entered will be created. You may also choose an already existing World by entering its name.",
	'password': "Password required to join your server.",
	'save_dir': "Overrides the default save path where Worlds and permission-files are stored.",
	'public': "Set the visibilty of your server in the Server browser.",
	'save_interval': "Change how often the World will save in seconds.",
	'backups': "Sets how many automatic backups will be kept.",
	'backup_short': "Sets the interval between the first automatic backup in seconds.",
	'backup_long': "Sets the interval between the subsequent automatic backups in seconds.",
	'crossplay': "Runs the Server on the Crossplay backend (PlayFab), which lets users from any platform join.",
	'instance_id': "If you're hosting multiple servers with the same port from the same MAC address, give a unique ID for each server.",
	'preset': "Sets the World difficulty.",
	'combat': "Sets the Combat difficulty, seperate from World difficulty. Enemies hit harder etc...",
	'death_penalty': "You lose more/less XP upon death.",
	'resources': "Collecting resources give less or more, cutting trees, harvesting plants, picking up stones.",
	'raids': "How often Raids happen.",
	'portals': "Casual: You can portal with Metal\nHard: You cannot portal with Metal\nVery Hard: Portals are disabled.",
	'events': "",
}

var _options: Dictionary = {}


func generate_output() -> void:
	var port := str(" -port ",'"',_options.port.value,'"')
	var public := str(" -public ",_options.public.value)
	var password := str(" -password ",'"',_options.password.value,'"')
	var server_name := str(" -name ",'"',_options.server_name.value,'"')
	var instance_id := str(" -instanceid ",'"',_options.instance_id.value,'"') if _options.instance_id.enabled == true else ""
	var world := str(" -world ",'"',_options.world_name.value,'"') if _options.world_name.enabled == true else ""
	var world_seed := str(" -worldseed ",'"',_options.seed.value,'"') if _options.seed.enabled == true else ""
	var save_interval := str(" -saveinterval ",_options.save_interval.value) if _options.save_interval.enabled == true else ""
	var backupshort := str(" -backupshort ",_options.backup_short.value) if _options.backup_short.enabled == true else ""
	var backuplong := str(" -backuplong ",_options.backup_long.value) if _options.backup_long.enabled == true else ""
	var savedir := str(" -savedir ",'"',_options.save_dir.value,'"') if _options.save_dir.enabled == true else ""
	var backups := str(" -backups ",_options.backups.value) if _options.backups.enabled == true else ""
	var preset := str(" -preset ",_options.preset.value) if _options.preset.enabled == true else ""
	var combat := str(" -modifier combat ",_options.combat.value) if _options.combat.enabled == true else ""
	var raids := str(" -modifier raids ",_options.raids.value) if _options.raids.enabled == true else ""
	var death := str(" -modifier deathpenalty ",_options.death_penalty.value) if _options.death_penalty.enabled == true else ""
	var resources := str(" -modifier resources ",_options.resources.value) if _options.resources.enabled == true else ""
	var setkey := str(" -setkey ")
	for key in _options.set_key:
		setkey += str(key," ")
	setkey = setkey if not _options.set_key.is_empty() else ""
	
	var windows_output: String = str("@echo off\n\necho Starting server PRESS CTRL-C to exit\n\nvalheim_server -nographics -batchmode ",
	instance_id,port,public,server_name,password,world,world_seed,preset,combat,raids,death,resources,
	setkey,save_interval,backups,backupshort,backuplong,savedir)
	
	var mac_output: String = str("#!/bin/zsh\n\necho",' "',"Starting server PRESS CMD-C to exit",'"',"\n\n",
	'"$( dirname "$0" )"',"/valheim_server/Valheim",instance_id,port,public,server_name,password,world,world_seed,preset,
	combat,raids,death,resources,setkey,save_interval,backups,backupshort,backuplong,savedir)
	
	var file_path: String = ""
	var os_name: String = OS.get_name()
	match os_name:
		'Windows':
			file_path = str(_options.valheim_directory.value,"vinr_start_server.bat")
			if DirAccess.dir_exists_absolute(_options.valheim_directory.value):
				var file := FileAccess.open(file_path, FileAccess.WRITE)
				file.store_string(windows_output)
			
		'macOS':
			file_path = str(_options.valheim_directory.value,"vinr_start_server.command")
			if DirAccess.dir_exists_absolute(_options.valheim_directory.value):
				var file := FileAccess.open(file_path, FileAccess.WRITE)
				file.store_string(mac_output)
	
	%Windows.get_child(0).text = windows_output
	%Mac.get_child(0).text = mac_output


func setup_elements() -> void:
	for key: String in DefaultOptions.keys():
		var node = get_node_or_null(str('%',key))
		if is_instance_valid(node):
			if node is LineEdit:
				node.text = str(_options[key].value)
				node.caret_column = node.text.length()
			if node is CheckBox:
				node.set_pressed_no_signal(bool(_options[key].value))
			if node is SpinBox:
				node.set_value_no_signal(int(_options[key].value))
			if node is OptionButton:
				for i in node.get_item_count():
					if node.get_item_text(i).to_lower() == _options[key].value:
						node.selected = i
			if key == 'set_key':
				for child: CheckBox in %set_key.get_children():
					if child.name in _options.set_key:
						child.button_pressed = true
					else:
						child.button_pressed = false
		
		var toggle: CheckBox = get_node_or_null(str('%',key,'_toggle'))
		if is_instance_valid(toggle):
			toggle.button_pressed = _options[key].enabled
			if _options[key].enabled:
				toggle.tooltip_text = str("Disable ",key.to_lower().replace("_"," ").capitalize())
			else:
				toggle.tooltip_text = str("Enable ",key.to_lower().replace("_"," ").capitalize())
			_on_world_options_toggled(_options[key].enabled, toggle, key)
	
	%Settings.set_item_checked(1, _options.keep_settings)
	
	match OS.get_name():
		'Web':
			%valheim_directory.editable = false
			%ValheimPathBrowseButton.disabled = true
			%SaveDirBrowseButton.disabled = true


func reset() -> void:
	_options = DefaultOptions.duplicate(true)
	
	var home_path := OS.get_environment('USERPROFILE') if OS.has_feature('windows') else OS.get_environment('HOME')
	var os_name: String = OS.get_name()
	match os_name:
		'Windows':
			var valheim_path := str(OS.get_environment('ProgramFiles'),'/Steam/steamapps/common/Valheim dedicated server/')
			if DirAccess.dir_exists_absolute(valheim_path):
				_options.valheim_directory.value = valheim_path
			var worlds_path := str(home_path,'/AppData/LocalLow/IronGate/Valheim/worlds/')
			if DirAccess.dir_exists_absolute(worlds_path):
				_options.save_dir.value = worlds_path
			
		'macOS':
			var valheim_path := str(home_path,'/Library/Application Support/Steam/steamapps/common/Valheim dedicated server/')
			if DirAccess.dir_exists_absolute(valheim_path):
				_options.valheim_directory.value = valheim_path
			var worlds_path := str(home_path,'/Library/Application Support/IronGate/Valheim/worlds/')
			if DirAccess.dir_exists_absolute(worlds_path):
				_options.save_dir.value = worlds_path
	
	if os_name != 'Web':
		%valheim_directory.text = _options.valheim_directory.value
		%valheim_directory.caret_column = %valheim_directory.text.length()
		%save_dir.text = _options.save_dir.value
		%save_dir.caret_column = %save_dir.text.length()
	
	%Windows.get_child(0).text = ""
	%Mac.get_child(0).text = ""


func show_about_popup() -> void:
	var window := Window.new()
	add_child(window)
	window.unresizable = true
	window.maximize_disabled = true
	window.transient = false
	window.title = "About Vinr"
	window.exclusive = true
	window.add_child(AboutScene.instantiate())
	window.close_requested.connect(_on_close_about_window_requested)
	window.popup_centered_clamped(Vector2i(400, 600))
	window.name = "AboutWindow"


func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load(UserOptionsPath)
	if config.get_value('data', 'keep_settings'):
		for key in config.get_section_keys('data'):
			_options[key] = config.get_value('data', key)
	await get_tree().process_frame


func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	for _key in DefaultOptions:
		config.set_value('data', _key, _options[_key])
	config.save(UserOptionsPath)


func _ready() -> void:
	get_viewport().get_window().min_size = Vector2(860, 600)
	
	%ValheimPathBrowseButton.pressed.connect(_on_valheim_path_browse_button_pressed)
	%SaveDirBrowseButton.pressed.connect(_on_save_dir_browse_button_pressed)
	%CreateScriptButton.pressed.connect(_on_create_script_button_pressed)
	
	%Settings.id_pressed.connect(_on_settings_button_id_pressed)
	%About.get_window().about_to_popup.connect(_on_about_window_about_to_popup)
	
	%MenuBar.set_menu_hidden(1, %MenuBar.is_native_menu())
	
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
			
			var toggle: CheckBox = get_node_or_null(str('%',key,'_toggle'))
			if is_instance_valid(toggle):
				toggle.toggled.connect(_on_world_options_toggled.bind(toggle, key))
	
	for child: Control in %BasicLeftSide.get_children():
		if child.get_child_count() > 0:
			var label: Label = child.get_child(0)
			label.mouse_entered.connect(_on_option_label_mouse_entered.bind(label))
			label.mouse_exited.connect(_on_option_label_mouse_exited)
	for child: Control in %AdvancedLeftSide.get_children():
		if child.get_child_count() > 0:
			var label: Label = child.get_child(0)
			label.mouse_entered.connect(_on_option_label_mouse_entered.bind(label))
			label.mouse_exited.connect(_on_option_label_mouse_exited)
	for child: Control in %WorldOptionsLeftSide.get_children():
		if child.get_child_count() > 0:
			var label: Label = child.get_child(0)
			label.mouse_entered.connect(_on_option_label_mouse_entered.bind(label))
			label.mouse_exited.connect(_on_option_label_mouse_exited)
	
	%About.add_theme_stylebox_override('theme_override_styles/panel', StyleBoxEmpty.new())
	
	if not FileAccess.file_exists(UserOptionsPath):
		_options = DefaultOptions.duplicate(true)
		save_settings()
	
	reset()
	await load_settings()
	setup_elements()
	
	%TabContainer.current_tab = 0


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_ABOUT:
			call_deferred('show_about_popup')


func _on_close_about_window_requested() -> void:
	get_node("AboutWindow").queue_free()


func _on_option_label_mouse_entered(label: Label) -> void:
	if label.name in OptionExplainations.keys():
		%HelpLabel.show()
		%HelpLabel.text = str(OptionExplainations[label.name])
	else:
		%HelpLabel.hide()


func _on_option_label_mouse_exited() -> void:
	%HelpLabel.hide()


func _on_line_edit_changed(text: String, node: LineEdit) -> void:
	_options[node.name.to_lower().replace(' ', '_')].value = text
	if %Settings.is_item_checked(1):
		save_settings()


func _on_checkbox_toggled(toggled: bool, node: CheckBox) -> void:
	if node.get_parent().name == 'set_key':
		var node_name := node.name.replace('&','')
		if toggled:
			if not _options.set_key.has(node_name):
				_options.set_key.append(node_name)
		else:
			_options.set_key.erase(node_name)
	else:
		_options[node.name.to_lower().replace(' ', '_')].value = toggled
	if %Settings.is_item_checked(1):
		save_settings()


func _on_spinbox_value_changed(value: float, node: SpinBox) -> void:
	_options[node.name.to_lower().replace(' ', '_')].value = value
	if %Settings.is_item_checked(1):
		save_settings()


func _on_option_button_id_selected(id: int, node: OptionButton) -> void:
	_options[node.name.to_lower().replace(' ', '_')].value = node.get_item_text(id).to_lower()
	if %Settings.is_item_checked(1):
		save_settings()


func _on_world_options_toggled(toggled_on: bool, checkbox: CheckBox, key: String) -> void:
	_options[key].enabled = toggled_on
	var node: Control = get_node_or_null(str('%',key))
	if is_instance_valid(node):
		if node is LineEdit:
			node.editable = toggled_on
		if node is OptionButton:
			node.disabled = !toggled_on
		if node is SpinBox:
			node.editable = toggled_on
	if %Settings.is_item_checked(1):
		save_settings()


func _on_create_script_button_pressed() -> void:
	generate_output()


func _on_valheim_path_browse_button_pressed() -> void:
	DisplayServer.file_dialog_show("Browse for Valheim Path", _options.valheim_directory.value, "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _on_valheim_path_file_dialog_file_opened)


func _on_save_dir_browse_button_pressed() -> void:
	DisplayServer.file_dialog_show("Browse for Save Directory", _options.save_dir.value, "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _on_save_dir_file_dialog_file_opened)


func _on_valheim_path_file_dialog_file_opened(status: bool, selected_paths: PackedStringArray, selected_filter_index: int) -> void:
	if not selected_paths.is_empty():
		_options.valheim_directory = str(selected_paths[0],"/")
		%valheim_directory.text = _options.valheim_directory
		%valheim_directory.caret_column = %valheim_directory.text.length()


func _on_save_dir_file_dialog_file_opened(status: bool, selected_paths: PackedStringArray, selected_filter_index: int) -> void:
	if not selected_paths.is_empty():
		_options.save_dir = selected_paths[0]
		%save_dir.text = _options.save_dir
		%save_dir.caret_column = %save_dir.text.length()


func _on_settings_button_id_pressed(id: int) -> void:
	match %Settings.get_item_text(id):
		'Open Valheim Directory':
			if DirAccess.dir_exists_absolute(_options.valheim_directory.value):
				OS.shell_open(_options.valheim_directory.value)
			else:
				OS.shell_open(OS.get_executable_path())
		'Keep Settings':
			%Settings.set_item_checked(1, !%Settings.is_item_checked(1))
			_options.keep_settings = %Settings.is_item_checked(1)
			save_settings()
		'Reset Changes':
			reset()
			setup_elements()


func _on_about_window_about_to_popup() -> void:
	call_deferred('show_about_popup')
