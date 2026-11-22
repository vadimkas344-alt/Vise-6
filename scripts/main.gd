extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const CAR_SCRIPT = preload("res://scripts/car.gd")

var player: CharacterBody3D
var car: CharacterBody3D
var camera: Camera3D
var hud: Label
var in_car := false

func _ready() -> void:
    _setup_input()
    _make_world()
    _make_city()
    _make_player()
    _make_car()
    _make_hud()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("interact"):
        if in_car:
            _exit_car()
        elif player.global_position.distance_to(car.global_position) < 4.0:
            _enter_car()
    hud.text = "VISE-6  |  WASD: движение  |  Мышь: обзор  |  Shift: бег  |  E: авто"
    if not in_car and player.global_position.distance_to(car.global_position) < 5.0:
        hud.text += "\nНажми E, чтобы сесть в автомобиль"

func _setup_input() -> void:
    _add_key("move_forward", KEY_W)
    _add_key("move_back", KEY_S)
    _add_key("move_left", KEY_A)
    _add_key("move_right", KEY_D)
    _add_key("interact", KEY_E)
    _add_key("run", KEY_SHIFT)
    _add_key("brake", KEY_SPACE)

func _add_key(action: String, key: Key) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventKey.new()
    event.physical_keycode = key
    InputMap.action_add_event(action, event)

func _make_world() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.sky.sky_material = ProceduralSkyMaterial.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.65, 0.75, 0.9)
    env.ambient_light_energy = 0.7
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.2
    sun.shadow_enabled = true
    add_child(sun)

    var ground_body := StaticBody3D.new()
    ground_body.position = Vector3(0, -0.35, 0)
    var ground_shape := CollisionShape3D.new()
    var ground_box := BoxShape3D.new()
    ground_box.size = Vector3(260, 0.5, 260)
    ground_shape.shape = ground_box
    ground_body.add_child(ground_shape)
    add_child(ground_body)
    add_child(_box(Vector3(0, -0.35, 0), Vector3(260, 0.5, 260), Color(0.18, 0.32, 0.25)))

func _make_city() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 17
    for i in range(-5, 6):
        add_child(_box(Vector3(i * 22.0, -0.04, 0), Vector3(8, 0.12, 260), Color(0.07, 0.08, 0.09)))
        add_child(_box(Vector3(0, -0.035, i * 22.0), Vector3(260, 0.12, 8), Color(0.07, 0.08, 0.09)))
        add_child(_box(Vector3(i * 22.0, 0.035, 0), Vector3(0.12, 0.025, 260), Color(0.88, 0.72, 0.28)))
        add_child(_box(Vector3(0, 0.04, i * 22.0), Vector3(260, 0.025, 0.12), Color(0.88, 0.72, 0.28)))

    var palette: Array[Color] = [Color(0.78, 0.65, 0.48), Color(0.68, 0.72, 0.73), Color(0.78, 0.77, 0.65), Color(0.53, 0.65, 0.68), Color(0.82, 0.58, 0.42)]
    for x in range(-4, 5):
        for z in range(-4, 5):
            if rng.randf() < 0.12:
                continue
            var px := x * 22.0 + rng.randf_range(-5.0, 5.0)
            var pz := z * 22.0 + rng.randf_range(-5.0, 5.0)
            var h := rng.randf_range(7.0, 23.0)
            var w := rng.randf_range(8.0, 13.0)
            var d := rng.randf_range(8.0, 13.0)
            add_child(_box(Vector3(px, h * 0.5, pz), Vector3(w, h, d), palette[rng.randi_range(0, palette.size() - 1)]))
            add_child(_box(Vector3(px, h + 0.18, pz), Vector3(w + 0.25, 0.35, d + 0.25), Color(0.22, 0.25, 0.28)))
            for floor_i in range(1, int(h / 3.2)):
                add_child(_box(Vector3(px, floor_i * 3.0, pz - d * 0.501), Vector3(w * 0.72, 0.85, 0.08), Color(0.18, 0.38, 0.48)))

func _make_player() -> void:
    player = CharacterBody3D.new()
    player.set_script(PLAYER_SCRIPT)
    player.position = Vector3(0, 0.05, 7)
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.38
    capsule.height = 1.9
    var collision := CollisionShape3D.new()
    collision.shape = capsule
    collision.position.y = 0.95
    player.add_child(collision)
    add_child(player)
    player.add_child(_box(Vector3(0, 0.9, 0), Vector3(0.8, 1.8, 0.45), Color(0.12, 0.22, 0.32)))
    player.add_child(_box(Vector3(0, 2.0, 0), Vector3(0.48, 0.48, 0.48), Color(0.78, 0.58, 0.42)))
    camera = Camera3D.new()
    camera.position = Vector3(0, 3.1, 5.8)
    camera.rotation_degrees.x = -16
    camera.current = true
    player.add_child(camera)
    player.set("camera", camera)

func _make_car() -> void:
    car = CharacterBody3D.new()
    car.set_script(CAR_SCRIPT)
    car.position = Vector3(4, 0.0, 7)
    var car_collision := CollisionShape3D.new()
    var car_box := BoxShape3D.new()
    car_box.size = Vector3(2.1, 0.75, 4.0)
    car_collision.shape = car_box
    car_collision.position.y = 0.48
    car.add_child(car_collision)
    add_child(car)
    car.add_child(_box(Vector3(0, 0.45, 0), Vector3(2.1, 0.65, 4.0), Color(0.72, 0.18, 0.12)))
    car.add_child(_box(Vector3(0, 1.0, -0.25), Vector3(1.65, 0.7, 1.8), Color(0.12, 0.24, 0.3)))
    for side in [-1.0, 1.0]:
        for z in [-1.25, 1.25]:
            car.add_child(_box(Vector3(side * 1.08, 0.15, z), Vector3(0.28, 0.65, 0.8), Color(0.025, 0.025, 0.03)))

func _make_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    hud = Label.new()
    hud.position = Vector2(20, 18)
    hud.add_theme_font_size_override("font_size", 18)
    hud.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(hud)

func _enter_car() -> void:
    in_car = true
    player.visible = false
    player.set_physics_process(false)
    car.set("controlled", true)
    camera.reparent(car)
    camera.position = Vector3(0, 3.2, 6.5)
    camera.rotation_degrees = Vector3(-12, 0, 0)

func _exit_car() -> void:
    in_car = false
    car.set("controlled", false)
    camera.reparent(player)
    player.global_position = car.global_position + car.global_transform.basis.x * 2.4 + Vector3.UP
    player.visible = true
    player.set_physics_process(true)
    camera.position = Vector3(0, 3.1, 5.8)
    camera.rotation_degrees = Vector3(-16, 0, 0)

func _box(pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var mesh := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = size
    mesh.mesh = box_mesh
    mesh.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.78
    mesh.material_override = mat
    return mesh
