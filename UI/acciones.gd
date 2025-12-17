extends Control

func _ready() -> void:
	cerrar_menu()

func abrir_menu():
	# Cerrar el menú de todos los jugadores antes de abrir el actual
	for p in get_tree().get_nodes_in_group("Jugador"):
		if p.has_node("Acciones"):
			var acciones = p.get_node("Acciones")
			if acciones.has_method("cerrar_menu"):
				acciones.cerrar_menu()
	visible = true
	
func cerrar_menu():
	visible = false

func _on_atacar_button_down():
	cerrar_menu()
	Manager.mostrar_seleccion()
	print("Atacar")

func _on_defender_button_down() -> void:
	Manager.defender_personaje()
func _on_cancelar_button_down() -> void:
	cerrar_menu()
