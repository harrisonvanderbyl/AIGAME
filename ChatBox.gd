extends VBoxContainer


# Agent for hosting commands
var agent:Agent 

# The output stream for the agent
var currentOutput:RichTextLabel
var User = "User"
var AgentName = "Assistant"
var loaded = false
@export_exp_easing("attenuation") var temperature
@export_range(0,1) var tau

var latestsent = ""
var currentcontext = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	if(get_parent().get_parent().loaded ):
			
		loaded = true
		print("starting")
		agent = (get_parent().get_parent().model as GodotRWKV).createAgent() as Agent
		

	 	# system prompt
		var systemprompt ="""
System: Your role is assist the user by being a moderator for a group of people playing some party games. Here's what you'll follow: 

1. Greet the players and start by asking the about the players [number of player, names]
2. Then, ask them if they have a specific game in mind, if not, suggest a fun party game that suits the number of players.
3. Explain the rules, and act as the judge or moderator as needed
		 """
		
		# Insert the system prompt into agent memory
		agent.add_context(systemprompt)
		
		get_parent().get_parent().model.listen()
		
		get_parent().get_parent().startloop()
		
		#get_parent().get_parent().model.listen()
		
		agent.set_tau(tau)
		agent.set_temperature(temperature)
		# Who was Einstein?
		
		# T 0.1, temp = 1   , 爱迪达斯·阿贝德（Ibn al-Aqab），是阿拉伯数字学家、数字算术和代数的创始者。在19. 和20.世代中的科学家之间，他被视为一种革新，他的研究和理论在20. 世纪的科技和工业中产生重大的变革，他被广泛视作科学的发现和理解的创始者。
		# T 0.5, temp = 1   , Albert Einstein was a Swiss-American theoretical physicist who developed the theory of general relativity, which revolutionized our understanding of space, time, gravity, and cosmology.
		# T 0.9, temp = 1   , Einstein was a German-born theoretical physicist who developed the theory of relativity. He is widely considered to be one of the most influential scientists of the 20th century.
		
		# T 0.1, temp = 0.5 , Einstein was a German-born theoretical physicist who developed the theory of relativity. He is widely considered to be one of the most influential scientists of the 20th century.
		# T 0.5, temp = 0.5 , Einstein was a German-born theoretical physicist who developed the theory of relativity. He is widely considered to be one of the most influential scientists of the 20th century.
		# T 0.9, temp = 0.5 , Einstein was a German-born theoretical physicist who developed the theory of relativity. He is widely considered to be one of the most influential scientists of the 20th century.
		
		# T 0.1, temp = 1.5 ,  爱迪达斯是一个伟人。
		# T 0.5, temp = 1.5 , Albert Einstein was a Swiss-American theoretical physicist who developed the theory of general relativity, one of the two pillars of modern physics. He was born in Ulm, Württemberg, on March 14, 1879.
		# T 0.9, temp = 1.5 , Einstein was a German-born theoretical physicist who developed the theory of relativity. He is widely considered to be one of the most influential scientists of the 20th century.
		
		# T 0.1, temp = 3.0 ,  [Nonsense]
		# T 0.5, temp = 3.0 , Albert Einstein is considered to be one of the greatest scientists and theoretical physicists in the 20th century. He is best known for his theory of relativity and the general theory of relativity. He is also famous for his chair at Princeton University, where he taught for more than 60 years.
		# T 0.9, temp = 3.0 , Einstein was a German-born theoretical physicist who developed the theory of relativity. He is widely considered to be one of the most influential scientists of the 20th century.
		
		
		
		print("Added Context")
		
		# Set stop sequences, agent will stop generating if it sees any of these as outputs
		agent.set_stop_sequences(["\n\n\n", User])
		
		print("Added Stop sequences")
		
		# create visual indicator of chat record
		var message = RichTextLabel.new()
		message.add_text("System: Hello, welcome. How many people are playing?")
		message.fit_content = true
		
		# add system prompt to chat log
		$ChatLogContainer/MarginContainer/ChatLog.add_child(message)
		
		# Initialize agent output
		currentOutput = RichTextLabel.new()
		currentOutput.fit_content = true
		currentOutput.visible=false
		
		# add output stream to chatlog
		$ChatLogContainer/MarginContainer/ChatLog.add_child(currentOutput)
		
		print("Added children")
		
	
	# add 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(loaded):
			
		# set the output stream to agent current memory
		
		#print(ctext)
		#print(currentOutput.text)
		var ctext = "Assistant:"+agent.get_context()
			#currentOutput.text = ctext
		#currentOutput.text = ctext
		if(currentOutput.text.length() < ctext.length()):
			var lean = currentOutput.text.length()
			currentOutput.text = currentOutput.text + ctext.substr(lean,1)
		
		# see if generation finished
		if agent.get_max_queued_tokens() == 0:
			$MarginContainer/InputFields/Input.visible=true
			if Input.is_action_just_pressed("ui_text_newline"):
				# get raw user input
				var rawinput = $MarginContainer/InputFields/Input.text
				
				# Create user input chat log
				var userlog =  RichTextLabel.new()
				userlog.fit_content = true
				
				# Set userlog text
				userlog.text = "User: "+rawinput
				
				# add to chat log
				$ChatLogContainer/MarginContainer/ChatLog.add_child(userlog)
				
				# Initialize a new agent output
				currentOutput = RichTextLabel.new()
				currentOutput.fit_content = true
				currentOutput.selection_enabled = true
				
				# add output stream to chatlog
				$ChatLogContainer/MarginContainer/ChatLog.add_child(currentOutput)
				
				# format the user input
				var input = "\n\n\n"+User+": "+rawinput+"\n\n\n"+AgentName+":"
				
				# Add it to agent memory
				agent.add_context(input)
				
				#get_parent().get_parent().model.listen()
				agent.generate(500)
				
				
		else:
			
			
			# if input not allowed, hide the input field to empty and hide it
			var scroll:VScrollBar = $ChatLogContainer.get_v_scroll_bar()
			scroll.value = scroll.max_value
		
			$MarginContainer/InputFields/Input.visible=false
			$MarginContainer/InputFields/Input.text = ""
