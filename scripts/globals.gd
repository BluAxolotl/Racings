extends Node

var current_scene

func tween(node, type, eases, property, start, end, time):
	var tween = Tween.new()
	node.add_child(tween)
	tween.interpolate_property(node, property,
			start, end, time,
			Tween[type], eases)
	tween.start()


func setCurrScene(scene):
	current_scene = scene
	print("Added Scene!")
