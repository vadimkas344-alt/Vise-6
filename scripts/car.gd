extends CharacterBody3D

@export var acceleration := 18.0
@export var max_speed := 28.0
@export var reverse_speed := 10.0
@export var turn_speed := 1.5
var controlled := false
var speed := 0.0
var gravity := 18.0

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0
    if controlled:
        var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
        var steering := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
        var limit := max_speed if throttle >= 0.0 else reverse_speed
        speed = move_toward(speed, throttle * limit, acceleration * delta)
        if Input.is_action_pressed("brake"):
            speed = move_toward(speed, 0.0, acceleration * 2.5 * delta)
        rotation.y -= steering * turn_speed * delta * clamp(abs(speed) / 8.0, 0.0, 1.0) * sign(speed)
        var forward := -global_transform.basis.z
        velocity.x = forward.x * speed
        velocity.z = forward.z * speed
    else:
        speed = move_toward(speed, 0.0, acceleration * delta)
        velocity.x = 0.0
        velocity.z = 0.0
    move_and_slide()
