extends MarginContainer


func _ready() -> void:
	for child: RichTextLabel in %Credits.get_children():
		child.meta_clicked.connect(_on_credits_text_meta_clicked)
	%VersionLabel.text = str(ProjectSettings.get('application/config/version'))


func _on_credits_text_meta_clicked(meta) -> void:
	OS.shell_open(meta)
