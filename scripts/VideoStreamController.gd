extends Control

@onready var video_stream_receiver: VideoStreamReceiver = $"../VideoStreamReceiver"
@onready var ip_input: LineEdit = $VBoxContainer/ConnectionControls/IPControls/IPInput
@onready var port_input: SpinBox = $VBoxContainer/ConnectionControls/PortControls/PortInput
@onready var connect_button: Button = $VBoxContainer/ConnectionControls/ConnectButton
@onready var status_label: Label = $VBoxContainer/StatusDisplay/StatusLabel
@onready var brightness_label: Label = $VBoxContainer/StatusDisplay/BrightnessLabel
@onready var brightness_bar: ProgressBar = $VBoxContainer/StatusDisplay/BrightnessBar

var update_timer: Timer

func _ready():
	setup_ui()
	setup_timer()
	update_display()

func setup_ui():
	# Set initial values from VideoStreamReceiver
	if video_stream_receiver:
		ip_input.text = video_stream_receiver.get_ip_address()
		port_input.value = video_stream_receiver.get_port()
	
	# Connect signals
	ip_input.text_changed.connect(_on_ip_changed)
	port_input.value_changed.connect(_on_port_changed)
	connect_button.pressed.connect(_on_connect_pressed)

func setup_timer():
	update_timer = Timer.new()
	update_timer.wait_time = 0.1  # Update 10 times per second
	update_timer.timeout.connect(update_display)
	add_child(update_timer)
	update_timer.start()

func _on_ip_changed(new_text: String):
	if video_stream_receiver:
		video_stream_receiver.set_ip_address(new_text)

func _on_port_changed(value: float):
	if video_stream_receiver:
		video_stream_receiver.set_port(int(value))

func _on_connect_pressed():
	if video_stream_receiver:
		video_stream_receiver.start_stream_manual()

func update_display():
	if not video_stream_receiver:
		return
	
	# Update status
	var status = video_stream_receiver.get_connection_status()
	status_label.text = "Status: " + status
	
	# Update status label color based on connection state
	match status:
		"Connected":
			status_label.modulate = Color.GREEN
		"Connecting":
			status_label.modulate = Color.YELLOW
		"No Address":
			status_label.modulate = Color.GRAY
		_:
			status_label.modulate = Color.RED
	
	# Update brightness display
	var brightness = video_stream_receiver.get_brightness_level()
	brightness_label.text = "Brightness: %.2f" % brightness
	
	# Update brightness bar (convert -1 to 1 range to 0 to 100)
	var brightness_percent = (brightness + 1.0) * 50.0
	brightness_bar.value = brightness_percent
	
	# Color brightness bar based on level
	if brightness < -0.3:
		brightness_bar.modulate = Color.BLUE  # Too dark
	elif brightness > 0.3:
		brightness_bar.modulate = Color.RED   # Too bright
	else:
		brightness_bar.modulate = Color.GREEN # Good level