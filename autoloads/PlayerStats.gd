extends Node

var max_hp: float = 100.0
var current_hp: float = 100.0
var speed: float = 225.0
var damage_multiplier: float = 1.0
var attack_speed_multiplier: float = 1.0
var pickup_range: float = 50.0
var armor: float = 0.0
var charge: float = 0.0
var max_charge: float = 100.0

signal charge_changed(current, maximum)
signal hp_changed(current, maximum)

func reset():
	current_hp = max_hp
