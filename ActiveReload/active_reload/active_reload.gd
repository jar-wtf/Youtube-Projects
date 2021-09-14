# Made by 'jar' on YouTube 
# Feel free to use this and modify it in anyway you wish
# https://github.com/jar-yt

extends Node2D

onready var pin := get_node("Pin")
onready var feedback_pin := get_node("FeedbackPin")
onready var pin_start := get_node("PinStart")
onready var pin_end := get_node("PinEnd")
onready var condition_label := get_node("Control/Label")

var stop_pin := false
var pin_triggered := false
var passed_sweet_spot := false
var passed_outer_area := false
var condition_found := false

var pin_sweet_hit := false
var pin_outer_hit := false

# Gun will always be the parent
onready var gun_reload_time : float = get_parent().reload_time 

signal reload(value)


func _ready():
	pin.transform.origin = pin_start.transform.origin # This is done as a precaution, but not needed really...
# warning-ignore:return_value_discarded
	connect("reload", get_parent(), "_set_reload_animation")

func _physics_process(delta): # Updating with physics because it was less consistent and accurate
	_call_pin(gun_reload_time, delta)

# Data: ["normal_reload", "quick_reload", "active_reload"]
func _call_pin(reload_time, delta):
	if pin_triggered && !condition_found:
		if pin_sweet_hit:
			stop_pin = true
			emit_signal("reload", 2)
			condition_label.text = "PERFECT!"
		elif !pin_sweet_hit && pin_outer_hit:
			stop_pin = true
			emit_signal("reload", 1)
			condition_label.text = "GOOD ENOUGH!"
		elif !pin_sweet_hit && !pin_outer_hit && !passed_sweet_spot && !passed_outer_area:
			emit_signal("reload", 0)
			condition_label.text = "SUCKS TO SUCK!"
			stop_pin = false
			feedback_pin.transform.origin = pin.transform.origin
			feedback_pin.visible = true
		else:
			return
			
		condition_found = true
		condition_label.visible = true
	
	if !stop_pin && self.visible && pin.transform.origin < pin_end.transform.origin: # This took to damn long to place in the right location... -_-. Was a call issue
		pin.transform.origin.x += ((pin_end.transform.origin.x - pin_start.transform.origin.x) / reload_time) * delta

func _lol():
	if !pin_sweet_hit && !pin_outer_hit && passed_sweet_spot && passed_outer_area && !condition_found:
		condition_label.text = "lol"
		condition_label.visible = true
		stop_pin = false
		condition_found = true

func _reset_interface():
	stop_pin = false
	pin_triggered = false
	condition_found = false
	condition_label.visible = false
	feedback_pin.visible = false
	passed_outer_area = false
	passed_sweet_spot = false
	pin.transform.origin = pin_start.transform.origin
	self.visible = false

# ===== SIGNALS =====

func _on_Pin_area_entered(area):
	if area.is_in_group("Sweet"):
		pin_sweet_hit = true
	elif area.is_in_group("Outer"):
		pin_outer_hit = true

func _on_Pin_area_exited(area):
	if area.is_in_group("Sweet"):
		pin_sweet_hit = false
		passed_sweet_spot = true
	elif area.is_in_group("Outer"):
		pin_outer_hit = false
		passed_outer_area = true
		
	_lol()
