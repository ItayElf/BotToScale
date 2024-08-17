extends HSlider
@export var busname : String
var busindex : int
func _ready():
	busindex = AudioServer.get_bus_index(busname)


func _on_value_changed(value):
	AudioServer.set_bus_volume_db(
		busindex,
		linear_to_db(value)
	)
