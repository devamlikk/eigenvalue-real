extends Control

func _on_vector_btn_pressed():
	GameManager.selected_weapon = "vector"
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")

func _on_divergence_btn_pressed():
	GameManager.selected_weapon = "divergence"
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")

func _on_curl_btn_pressed():
	GameManager.selected_weapon = "curl"
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")

func _on_gradient_btn_pressed():
	GameManager.selected_weapon = "gradient"
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")

func _on_eigenbeam_btn_pressed():
	GameManager.selected_weapon = "eigenbeam"
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")

func _on_nullspace_btn_pressed():
	GameManager.selected_weapon = "nullspace"
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")
