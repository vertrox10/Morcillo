extends Node2D

func _ready():
	# Si quieres inicializar al cargar la escena
	Manager.obtener_personajes()

func _on_iniciar_mundo_timeout() -> void:
	# Si usas un Timer para esperar que todo esté instanciado
	Manager.obtener_personajes()
