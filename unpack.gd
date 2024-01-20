extends Node2D

var loaded = false

func load():
	var a = DirAccess.open("res://")
	a.copy("res://model.safetensors","user://model.safetensors")
	loaded = true
	
var appx = 0;
var th:Thread
# Called when the node enters the scene tree for the first time.
func _ready():
	th =  Thread.new()
	th.start(load)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	appx+=0.01
	if(appx>100):
		$TextEdit.text = "this is taking a while... sorry for the delay, do you have enough space?"
	else:
		$TextEdit.text = str(appx).substr(0,2)+"%"
	if(loaded):
		get_tree().change_scene_to_file("res://examplehost.tscn")
