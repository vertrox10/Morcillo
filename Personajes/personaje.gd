class_name Personaje
extends CharacterBody2D

signal ataque_finalizado   # ← declaración obligatoria

@export var data: PersonajeData
@onready var animacion: AnimatedSprite2D = $animacion
@onready var componente_salud: Node = $ComponenteSalud

var personaje_objetivo: Personaje
var atacando: bool = false
var regresar_posicion: bool = false
var posicion_inicial: Vector2
var defendiendo: bool = false
const VELOCIDAD = 600.0

func _ready():
	animacion.play("idle")
	posicion_inicial = global_position

	# Validar que data no sea null antes de usarla
	if data:
		if componente_salud:
			componente_salud.salud_actual = data.salud_maxima
			componente_salud.salud_maxima = data.salud_maxima
			componente_salud.armadura = data.armadura
			if componente_salud.has_method("actualizar_progress_bar"):
				componente_salud.actualizar_progress_bar()
		else:
			push_warning("No se encontró el nodo ComponenteSalud en el personaje")

		if data.jugador:
			add_to_group("Jugador")
			print(name, "asignado al grupo Jugador")
		else:
			add_to_group("Enemigo")
			animacion.flip_h = true
			animacion.offset.x = -30.5
			print(name, "asignado al grupo Enemigo")
			if Manager:
				Manager.connect("jugador_selecciona_enemigo", mostrar_seleccion)
				Manager.connect("ataque_iniciado", ocultar_seleccion)
	else:
		push_warning("El recurso PersonajeData no está asignado en el inspector")

	# 🔑 Refrescar Manager después de asignar grupo
	if Manager:
		Manager.obtener_personajes()

func _on_panel_gui_input(_event):
	if componente_salud.sin_salud or Manager.juego_finalizado:
		return
	
	if data and data.jugador:
		if Input.is_action_just_pressed("mouse_izquierdo") and Manager.puede_abrir_menu and Manager.turno_jugador:
			if $Acciones.has_method("abrir_menu"):
				$Acciones.abrir_menu()
			Manager.establecer_personaje(self)
	elif data and not data.jugador:
		if Input.is_action_just_pressed("mouse_izquierdo") and $Seleccionar.visible:
			Manager.establecer_objetivo(self)
			Manager.iniciar_ataque()

func _physics_process(_delta):
	if componente_salud.sin_salud or Manager.juego_finalizado:
		return

	# Movimiento hacia el objetivo
	if personaje_objetivo and not atacando:
		var distancia = global_position.distance_to(personaje_objetivo.global_position)
		if distancia > 80:
			var direccion = (personaje_objetivo.global_position - global_position).normalized()
			velocity = VELOCIDAD * direccion
			move_and_slide()
			animacion.play("move")
		else:
			atacando = true
			animacion.play("attack")

	# Regreso a la posición inicial
	elif regresar_posicion:
		var distancia = global_position.distance_to(posicion_inicial)
		if distancia > 1.0:
			var direccion = (posicion_inicial - global_position).normalized()
			velocity = VELOCIDAD * direccion
			move_and_slide()
			animacion.play("move")
		else:
			global_position = posicion_inicial
			regresar_posicion = false
			animacion.play("idle")
			Manager.cambiar_turno()
			Manager.puede_abrir_menu = true

	else:
		# 🔑 Resetear velocidad cuando no hay movimiento
		velocity = Vector2.ZERO
		move_and_slide()

func atacar_personaje(target: Personaje):
	personaje_objetivo = target

func defenderse():
	componente_salud.armadura = data.armadura * 2
	defendiendo = true
	Manager.cambiar_turno()
	Manager.puede_abrir_menu = true
	animacion.self_modulate = Color(0,169,0.762,0.298)
	
func quitar_defensa():
	componente_salud.armadura = data.armadura
	animacion.self_modulate = Color(1,1,1)

func mostrar_seleccion():
	$Seleccionar.visible = true

func ocultar_seleccion():
	$Seleccionar.visible = false

func _on_animacion_animation_finished() -> void:
	if animacion.animation == "attack":
		if personaje_objetivo and personaje_objetivo.has_node("ComponenteSalud"):
			var salud_node = personaje_objetivo.get_node("ComponenteSalud")
			if salud_node and salud_node.has_method("recibir_daño"):
				salud_node.recibir_daño(data.daño, data.probabilidad_daño, data.multiplicador_daño)
		personaje_objetivo = null
		atacando = false
		regresar_posicion = true
		emit_signal("ataque_finalizado") 
	if animacion.animation == "hurt":
		animacion.play("idle")
	if animacion.animation == "dead":
		await get_tree().create_timer(1).timeout
		queue_free()	

func _on_componente_salud_daño_recibido() -> void:
	animacion.play("hurt")
	defendiendo = false
	quitar_defensa()
	
func _on_componente_salud_salud_cero() -> void:
	animacion.play("dead")
	$Salud.visible = false
	if data.jugador:
		remove_from_group("Jugador")
	else:
		remove_from_group("Enemigo")
	
	Manager.obtener_personajes()
