extends Node2D

# Initialize module
var model = GodotRWKV.new()

func listenloop():
	while(1):
		model.listen()
				
		
var mt:Thread
# Create a thread to handle text processing so it doesnt slow down main thread
var loaded = false
# Load model when enter tree so that agents can connect on start
func _enter_tree():
	# load model file downloaded from https://huggingface.co/Hazzzardous/8-bit-rwkv-hpp
	#if(OS.get_name() == "Android"):
			#get_tree().root.content_scale_size = Vector2(3,3);
	# use full path
	if(FileAccess.file_exists("res://3b.safetensors")):
		
	
		
		model.loadModel(ProjectSettings.globalize_path("res://3b.safetensors"),8)
	
		print("Loaded Model")
		#
		## load tokenizer file downloaded from https://huggingface.co/Hazzzardous/8-bit-rwkv-hpp/blob/main/rwkv_vocab_v20230424.txt
		## use full path
		if(!FileAccess.file_exists("user://rwkv_vocab_v20230424.txt")):
			var a = DirAccess.open("res://")
			a.copy("res://rwkv_vocab_v20230424.txt","user://rwkv_vocab_v20230424.txt")
		model.loadTokenizer(ProjectSettings.globalize_path("user://rwkv_vocab_v20230424.txt"))
		
		print("Loaded Tokenizer")
		
		
		print("Started Loop")
		loaded = true
	## create threat

func startloop():
	mt = Thread.new()
	mt.start(listenloop)
# simply loop and process

func _process(delta):
	if(!loaded):
		get_tree().change_scene_to_file("res://unpack.tscn")
	else:	
		var hlp = Vector2(1.0,0.5)
		if(!$MarginContainer2/ChatBox/MarginContainer/InputFields/Input.has_focus() || OS.get_name()!="Android"):
			hlp += Vector2(0.0,0.5)
		
		$MarginContainer2.size = get_viewport_rect().size * hlp
		


func _on_button_2_button_down():
	get_tree().quit()
