extends Control
var seed_value := 1
var player_name := "Player"

func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var skin: Color = [Color("#f2c7a5"),Color("#d9a078"),Color("#b97850"),Color("#8d573d"),Color("#f0d0b0")][rng.randi_range(0,4)]
	var hair: Color = [Color("#241a18"),Color("#493126"),Color("#17191f"),Color("#a97842")][rng.randi_range(0,3)]
	var kit: Color = [Color("#7d2be0"),Color("#168acb"),Color("#d8324b"),Color("#16865c"),Color("#e39b20")][rng.randi_range(0,4)]
	draw_rect(Rect2(Vector2.ZERO,size),Color("#14253b"),true)
	draw_rect(Rect2(Vector2(0,size.y*0.76),Vector2(size.x,size.y*0.24)),Color("#203d5b"),true)
	draw_colored_polygon(PackedVector2Array([Vector2(size.x*0.08,size.y),Vector2(size.x*0.18,size.y*0.76),Vector2(size.x*0.38,size.y*0.68),Vector2(size.x*0.62,size.y*0.68),Vector2(size.x*0.82,size.y*0.76),Vector2(size.x*0.92,size.y)]),kit)
	draw_rect(Rect2(Vector2(size.x*0.43,size.y*0.58),Vector2(size.x*0.14,size.y*0.16)),skin,true)
	draw_circle(Vector2(size.x*0.5,size.y*0.38),minf(size.x,size.y)*0.235,skin)
	draw_circle(Vector2(size.x*0.5,size.y*0.28),minf(size.x,size.y)*0.235,hair)
	draw_rect(Rect2(Vector2(size.x*0.265,size.y*0.30),Vector2(size.x*0.47,size.y*0.09)),hair,true)
	draw_circle(Vector2(size.x*0.415,size.y*0.40),size.x*0.018,Color("#20212a"))
	draw_circle(Vector2(size.x*0.585,size.y*0.40),size.x*0.018,Color("#20212a"))
	draw_line(Vector2(size.x*0.46,size.y*0.49),Vector2(size.x*0.54,size.y*0.49),Color("#854f43"),2)
