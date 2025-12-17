extends Node

signal jugador_selecciona_enemigo()
signal ataque_iniciado()

var turno_jugador: bool = true
var puede_abrir_menu: bool = true
var personaje_seleccionado
var personaje_objetivo
var enemigos: Array = []
var jugadores: Array = []
var turno_enemigo: int = 0
var juego_finalizado: bool = false

func _ready():
	# Espera un poco más para que los Personajes terminen su _ready()
	await get_tree().create_timer(0.1).timeout
	obtener_personajes()

func obtener_personajes():
	enemigos = get_tree().get_nodes_in_group("Enemigo")
	jugadores = get_tree().get_nodes_in_group("Jugador")
	
	print("Detectados -> Enemigos:", enemigos.size(), " | Jugadores:", jugadores.size())
	# ❌ Ya no evaluamos victoria/derrota aquí
	# Solo actualizamos las listas

func verificar_victoria():
	# ✅ Evaluar victoria/derrota solo cuando realmente hay personajes en escena
	if enemigos.size() == 0 and jugadores.size() > 0:
		print("El jugador ganó")
		juego_finalizado = true
		# 🔑 cambiar a la siguiente escena (ajusta la ruta a tu nivel real)
		get_tree().change_scene_to_file("res://creditod.tscn")
	elif jugadores.size() == 0 and enemigos.size() > 0:
		print("El enemigo ganó")
		juego_finalizado = true
		# 🔑 volver al menú o pantalla de derrota
		get_tree().change_scene_to_file("res://creditod.tscn")

func cambiar_turno():
	turno_jugador = !turno_jugador
	if not turno_jugador:
		await get_tree().create_timer(1).timeout
		if juego_finalizado:
			return 
		iniciar_turno_enemigo()
	else:
		puede_abrir_menu = true   # habilitar menú solo en turno jugador
		for j in jugadores:
			j.quitar_defensa()
		# ✅ verificar victoria al inicio del turno jugador
		verificar_victoria()

func mostrar_seleccion():
	puede_abrir_menu = false
	emit_signal("jugador_selecciona_enemigo")

func establecer_personaje(personaje):
	personaje_seleccionado = personaje

func establecer_objetivo(personaje):
	personaje_objetivo = personaje    

func iniciar_ataque():
	if personaje_seleccionado and personaje_objetivo:
		emit_signal("ataque_iniciado")
		personaje_seleccionado.atacar_personaje(personaje_objetivo)
	else:
		push_warning("No se pudo iniciar ataque: faltan personaje u objetivo")

func iniciar_turno_enemigo():
	# 🔑 Si ya no hay enemigos, verificar victoria y salir
	if enemigos.is_empty():
		verificar_victoria()
		return
	
	if turno_enemigo >= enemigos.size():
		turno_enemigo = 0
	
	var enemigo_actual = enemigos[turno_enemigo % enemigos.size()]
	
	if randf_range(0,100) < 60:	
		establecer_personaje(enemigo_actual)
		establecer_objetivo(jugadores.pick_random())
		iniciar_ataque()
	else:
		establecer_personaje(enemigo_actual)
		defender_personaje()
	
	turno_enemigo += 1
	# ✅ verificar victoria al final del turno enemigo
	verificar_victoria()

func defender_personaje():
	personaje_seleccionado.defenderse()

func on_ataque_finalizado(emisor: Personaje):
	if emisor.is_in_group("Jugador"):
		# Jugador terminó su ataque → toca enemigo
		iniciar_turno_enemigo()
	elif emisor.is_in_group("Enemigo"):
		# Enemigo terminó su ataque → vuelve al jugador
		cambiar_turno()
