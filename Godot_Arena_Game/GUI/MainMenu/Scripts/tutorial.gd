# tutorial.gd
# Presents a multi-page tutorial (or prologue) to explain the game controls and mechanics.

extends Panel

# Array of text pages for the tutorial.
var pages = [
	"This is a tutorial for the controls of the game",
	"- [Esc] cancels menus or opens the inventory menu. \n- [Enter] or [E] is used to interact/accept/use objects",
	"- Use [WASD] or [↑ ↓ → ←] to move the player and move within menus. \n- You can also use your mouse in the menus",
	"- [J] is the key for a melee attack. \n- [K] is for dash. \n- [L] is for ranged attack.",
	"Some of these abilities cannot be used at the start of the game, but you can either find them or buy them in the game.",
	"Now you are ready to begin the game, press [Start Game] when ready"
]

var current_page = 0

signal new_game_started

@onready var text_label : RichTextLabel = $VBoxContainer/PrologueTextPanel/MarginContainer/PrologueText
@onready var page_indicator : Label = $VBoxContainer/PrologueTextPanel/PageIndicator
@onready var next_button : Button = $VBoxContainer/HBoxContainer/NextButton
@onready var skip_button : Button = $VBoxContainer/HBoxContainer/SkipButton
@onready var back_button : Button = $VBoxContainer/HBoxContainer/BackButton

const FIRST_LEVEL = "res://Levels/Maps/Area01/01_Dungeon.tscn"

func _ready() -> void:
	# Ensure node references are valid before proceeding.
	if text_label and page_indicator and next_button and skip_button:
		# Display the first tutorial page.
		text_label.text = pages[current_page]
		update_page_indicator()
		# Connect button signals for navigation.
		next_button.pressed.connect(_on_next_pressed)
		skip_button.pressed.connect(_on_skip_pressed)
		back_button.pressed.connect(_on_back_pressed)
		next_button.grab_focus()
	else:
		push_error("Prologue node references not found. Check scene structure.")

func _on_next_pressed() -> void:
	# Go to the next page.
	current_page += 1
	pages_changed()

func _on_back_pressed() -> void:
	# Go back a page if possible.
	if current_page > 0:
		current_page -= 1
		pages_changed()

func pages_changed() -> void:
	# If the end of the tutorial is reached, emit the new_game_started signal.
	if current_page >= pages.size():
		new_game_started.emit()
	else:
		# Update the text and page indicator.
		text_label.text = pages[current_page]
		update_page_indicator()
		# Change button text on the last page.
		if current_page == pages.size() - 1:
			next_button.text = "Start Game"
		elif current_page != pages.size() - 1 and next_button.text == "Start Game":
			next_button.text = "Next"

func _on_skip_pressed() -> void:
	# Skip the tutorial immediately.
	new_game_started.emit()

func update_page_indicator() -> void:
	# Update the page indicator label.
	page_indicator.text = "Page " + str(current_page + 1) + "/" + str(pages.size())
