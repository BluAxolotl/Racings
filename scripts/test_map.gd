extends Spatial

var TEST = 0

func _init():
	Globals.setCurrScene(self)

func _ready():
	Globals.tween(self, "TRANS_QUINT", 0, "TEST", 0, 100, 10)
