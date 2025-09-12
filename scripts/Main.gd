extends Control

@onready var button = $VBoxContainer/Button

func _ready():
	button.pressed.connect(_on_button_pressed)
	print("CCABN Software initialized")

func _on_button_pressed():
	print("Application started!")
	# Add your application logic here