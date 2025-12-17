extends Control

func volumen(bus_index,value):
	AudioServer.set_bus_volume_db(bus_index,value)
	
func _on_resolucion_pressed() -> void:
	pass 

func _on_regresar_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/menu.tscn")

func _onHSlider_value_changed(value):
	volumen(0,value)
