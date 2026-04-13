extends CanvasLayer

@onready var wave_label = $WaveLabel
@onready var score_label = $ScoreLabel
@onready var hp_bar = $HPBar
@onready var charge_bar = $ChargeBar

func _ready():
	PlayerStats.hp_changed.connect(_on_hp_changed)
	PlayerStats.charge_changed.connect(_on_charge_changed)
	hp_bar.max_value = PlayerStats.max_hp
	hp_bar.value = PlayerStats.current_hp
	charge_bar.max_value = PlayerStats.max_charge
	charge_bar.value = PlayerStats.charge
	_update()

func _process(_delate):
	_update()

func _update():
	wave_label.text = "Wave " + str(GameManager.wave)
	score_label.text = "Score " + str(GameManager.score)

func _on_hp_changed(current, max_hp):
	hp_bar.max_value = max_hp
	hp_bar.value = current

func _on_charge_changed(current, maximum):
	print("Charge changed: ", current)
	charge_bar.max_value = maximum
	charge_bar.value = current
