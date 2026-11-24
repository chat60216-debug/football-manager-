extends Control
var current := 60
var potential := 75
var age := 22

func setup(rating: int, ceiling: int, player_age: int) -> void:
	current = rating
	potential = ceiling
	age = player_age
	custom_minimum_size = Vector2(0, 116)
	queue_redraw()

func _draw() -> void:
	var left := 22.0
	var bottom := size.y - 22.0
	var chart_w := maxf(1.0,size.x - 44.0)
	var chart_h := maxf(1.0,size.y - 40.0)
	for i in range(5):
		var y := bottom - chart_h * float(i) / 4.0
		draw_line(Vector2(left,y),Vector2(left+chart_w,y),Color("#35506b"),1)
	var points := PackedVector2Array()
	var span := maxi(1,potential-current)
	for i in range(6):
		var projected := mini(potential,current + int(float(span) * float(i) / 5.0))
		var x := left + chart_w * float(i) / 5.0
		var y := bottom - chart_h * float(projected) / 100.0
		points.append(Vector2(x,y))
	for i in range(points.size()-1):
		draw_line(points[i],points[i+1],Color("#67e6f4"),3)
	for p in points:
		draw_circle(p,3.5,Color("#ffd36a"))
	draw_string(ThemeDB.fallback_font,Vector2(left,bottom+16),"ORA",HORIZONTAL_ALIGNMENT_LEFT,50,10,Color("#9db5ce"))
	draw_string(ThemeDB.fallback_font,Vector2(left+chart_w-40,bottom+16),"POT.",HORIZONTAL_ALIGNMENT_RIGHT,40,10,Color("#9db5ce"))
