extends Node
signal  salud_cero()
signal daño_recibido()
@export var progress_bar: ProgressBar
var salud_maxima:float
var salud_actual: float
var sin_salud:bool=false
var armadura:float=1

func recibir_daño(cantidad: float, prob:float,aum:float):
	if sin_salud:
		return
	salud_actual -= calcular_daño(cantidad,prob , aum)
	print("Daño recibido:",cantidad)
	actualizar_progress_bar()
	if (salud_actual <=0):
		emit_signal("salud_cero")
		sin_salud=true
	else: 
		emit_signal("daño_recibido")
func calcular_daño(cantidad: float, prob:float,aum:float)->float:
	var resultado:float
	if (randf_range(0,1))>=prob:
		resultado = cantidad *  aum
	
	resultado=resultado/armadura	
	return resultado
func actualizar_progress_bar():
	if progress_bar:
		progress_bar.value= salud_actual/salud_maxima
