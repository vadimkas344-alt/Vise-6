extends CharacterBody3D

@export var walk_speed := 5.0
@export var run_speed := 8.0
@export var jump_velocity := 5.5
var camera: Camera3D
var yaw := 0.0
var pitch := -0.18
var gravity := 18.0

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        yaw -= event.relative.x * 0.0025
        pitch = clamp(pitch - event.relative.y * 0.002, -0.75, 0.25)
        rotation.y = yaw
        if camera:
            camera.rotation.x = pitch
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        if Input.is_key_pressed(KEY_SPACE):
            velocity.y = jump_velocity

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    var speed := run_speed if Input.is_action_pressed("run") else walk_speed
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed * 5.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, speed * 5.0 * delta)
    move_and_slide()
