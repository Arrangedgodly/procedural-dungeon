extends Node

var active_sounds: Dictionary = {}  # stream path -> array of active instances
var sound_cooldowns: Dictionary = {}  # stream path -> last played timestamp

const MAX_INSTANCES_PER_SOUND = 5  # Maximum concurrent instances of the same sound
const DEFAULT_MIN_TIME = 0.05  # Default minimum time if we can't determine stream length
const CLEANUP_INTERVAL = 2.0  # How often to clean up finished sounds
const RAPID_EVENT_THRESHOLD = 5  # Number of requests within MIN_TIME_BETWEEN_SOUNDS to trigger scaling
const VOLUME_SCALE_FACTOR = 1.2  # Volume increase for rapid events
const MAX_VOLUME_SCALE = 2.0  # Maximum volume scaling
const LENGTH_MULTIPLIER = 0.1  # What fraction of the stream length to use as minimum time

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = CLEANUP_INTERVAL
	timer.timeout.connect(cleanup_finished_sounds)
	add_child(timer)
	timer.start()

func get_min_time_for_stream(stream: AudioStream) -> float:
	if stream and stream.get_length() > 0:
		return stream.get_length() * LENGTH_MULTIPLIER
	return DEFAULT_MIN_TIME

func play_sfx(stream: AudioStream, bus: String, pos: Vector2) -> void:
	if not stream:
		return
		
	var stream_path = stream.resource_path
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if not active_sounds.has(stream_path):
		active_sounds[stream_path] = []
	if not sound_cooldowns.has(stream_path):
		sound_cooldowns[stream_path] = 0.0
	
	var recent_requests = 0
	for instance in active_sounds[stream_path]:
		if is_instance_valid(instance) and instance.playing:
			recent_requests += 1
	
	if recent_requests >= MAX_INSTANCES_PER_SOUND:
		var oldest_instance = find_oldest_instance(active_sounds[stream_path])
		if oldest_instance:
			oldest_instance.queue_free()
			active_sounds[stream_path].erase(oldest_instance)
	
	var time_since_last = current_time - sound_cooldowns[stream_path]
	var min_time = get_min_time_for_stream(stream)
	
	var volume_scale = 1.0
	if recent_requests >= RAPID_EVENT_THRESHOLD:
		volume_scale = min(VOLUME_SCALE_FACTOR * (recent_requests / RAPID_EVENT_THRESHOLD), 
						 MAX_VOLUME_SCALE)
	
	if time_since_last >= min_time or recent_requests == 0:
		var instance = AudioStreamPlayer2D.new()
		instance.stream = stream
		instance.position = pos
		instance.bus = bus
		instance.volume_db = linear_to_db(volume_scale)
		instance.finished.connect(remove_sound_instance.bind(instance, stream_path))
		add_child(instance)
		active_sounds[stream_path].append(instance)
		instance.play()
		sound_cooldowns[stream_path] = current_time

func find_oldest_instance(instances: Array) -> AudioStreamPlayer2D:
	var oldest_instance: AudioStreamPlayer2D = null
	var oldest_time = INF
	
	for instance in instances:
		if is_instance_valid(instance) and instance.playing:
			var current_playback_pos = instance.get_playback_position()
			if current_playback_pos > oldest_time:
				oldest_time = current_playback_pos
				oldest_instance = instance
	
	return oldest_instance

func remove_sound_instance(instance: Node, stream_path: String) -> void:
	if active_sounds.has(stream_path):
		active_sounds[stream_path].erase(instance)
	instance.queue_free()

func cleanup_finished_sounds() -> void:
	for stream_path in active_sounds.keys():
		var instances = active_sounds[stream_path]
		var i = instances.size() - 1
		while i >= 0:
			var instance = instances[i]
			if not is_instance_valid(instance) or not instance.playing:
				instances.remove_at(i)
			i -= 1

func play_music(stream: AudioStream) -> void:
	if not stream:
		return
		
	for child in get_children():
		if child is AudioStreamPlayer and child.stream == stream:
			return
	
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = "Music"
	instance.finished.connect(play_music.bind(stream))
	add_child(instance)
	instance.play()

func stop(stream: AudioStream):
	var children = get_children()
	for child in children:
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
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
