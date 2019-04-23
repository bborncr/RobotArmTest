extends Control


func _on_FileDialog_file_selected(path):
	print("Selected", path)


func _on_Button_pressed():
	$FileDialog.show()


func _on_Button2_pressed():
	$FileDialog2.show()


func _on_FileDialog2_file_selected(path):
	print("Selected", path)
