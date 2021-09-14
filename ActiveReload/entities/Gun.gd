extends Spatial

export(int) var default_mag_size
export(float) var reload_time
onready var bullet_count : int = default_mag_size
var mag_removed := false

var reload_names := ["normal_reload", "quick_reload", "active_reload"]
onready var animation_player := get_node("AnimationPlayer")
onready var animation_tree := get_node("AnimationTree")
onready var animation_state = animation_tree.get("parameters/playback")
onready var ammo_count_label := get_parent().get_parent().get_node("Control/AmmoCount") # Super lazy and just bad lmao

onready var reload_ui_ref = get_node("ActiveReload")

func _ready():
	ammo_count_label.text = str(bullet_count) + " / 30"

func _process(_delta):
	_get_input()

func _get_input():
	if !mag_removed:
		if Input.is_action_just_pressed("reload") && bullet_count != default_mag_size:
			_reload()
		if Input.is_action_just_pressed("fire"):
			animation_state.travel("fire")
		elif Input.is_action_just_released("fire") && animation_state.get_current_node() == "fire":
			animation_state.travel("default")
	else:
		if Input.is_action_just_pressed("reload"):
			reload_ui_ref.pin_triggered = true

func _fire():
	bullet_count -= 1
	ammo_count_label.text = str(bullet_count) + " / 30"

# Called in "fire" animation
func _check_bullet_count():
	if !mag_removed:
		if bullet_count == 0:
			_reload()
		if bullet_count < 5:
			_dry_fire_sound()

func _reload():
	reload_ui_ref.visible = true
	animation_state.travel("drop_mag")
	mag_removed = true

func _set_reload_animation(animation_number):
	animation_state.travel(reload_names[animation_number])

# This method is called at the end of the reload animation
func _fill_mag():
	bullet_count = default_mag_size
	mag_removed = false
	ammo_count_label.text = str(bullet_count) + " / 30"
	
# Called from any of the reload animations which destroys the active reload animation
func _reset_interface():
	reload_ui_ref._reset_interface()

func _bullet_sound():
	$ShootingSound.play()

func _reloading_sound():
	$LoadingSound.play()
	
func _unloading_sound():
	$UnloadingSound.play()

func _dry_fire_sound():
	$DryFireSound.play()
