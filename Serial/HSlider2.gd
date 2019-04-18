extends HSlider

signal update_servo(value)

onready var tween = $Tween

func _on_HSlider_value_changed(value):
	tween.interpolate_property(self, 'value', get_value(), value, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	
func _on_Tween_tween_completed(object, key):
	emit_signal("update_servo", get_value())
