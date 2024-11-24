extends Node

func play_sfx(stream: AudioStream, bus: String, pos: Vector2):
	var instance = AudioStreamPlayer2D.new()
	instance.stream = stream
	instance.position = pos
	instance.bus = bus
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()

func play_music(stream: AudioStream):
	var children = get_children()
	for child in children:
		if child.stream == stream:
			return
			
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = "Music"
	instance.finished.connect(play_music.bind(stream))
	add_child(instance)
	instance.play()

func remove_node(instance: AudioStreamPlayer):
	instance.queue_free()

func stop(stream: AudioStream):
	var children = get_children()
	for child in children:
		if child.stream == stream:
			child.queue_free()

func pause(stream: AudioStream):
	var children = get_children()
	for child in children:
		if child.stream == stream:
			child.stream_paused = true

func resume(stream: AudioStream):
	var children = get_children()
	for child in children:
		if child.stream == stream:
			child.stream_paused = false
