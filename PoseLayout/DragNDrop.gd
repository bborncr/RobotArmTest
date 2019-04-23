extends Button

func can_drop_data(position, data):
    return typeof(data) == TYPE_INT

func drop_data(position, data):
	var new_pos = data
	print(data)
	print(self.text)
	print(get_parent().get_child(0))
#	self.text = str(data)
	
func get_drag_data(position):
	var dp = Button.new()
	dp.text = self.text
	dp.rect_size = Vector2(50,50)
	set_drag_preview(dp)
	return int(self.text)