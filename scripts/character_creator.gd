extends Control

# Screens
@onready var main_screen = $MainScreen
@onready var asset_selection_screen = $AssetSelectionScreen
@onready var gallery_view = $GalleryView

# Current state
var current_screen = "main"
var current_category = ""
var current_asset_index = 0
var current_color_index = 0

# Asset colors (6 colors for palette)
var asset_colors = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.YELLOW,
	Color.CYAN,
	Color.MAGENTA
]

# Asset data structure
var assets = {
	"body": ["body1", "body2", "body3"],
	"head": ["head1", "head2", "head3"],
	"clothes": ["shirt1", "shirt2", "dress1"],
	"extra": ["hat1", "hat2", "accessory1"]
}

func _ready():
	# Hide all screens except MainScreen
	show_screen("main")
	
	# Connect category buttons
	connect_category_buttons()
	
	# Connect navigation buttons
	connect_navigation_buttons()
	
	# Connect color palette buttons
	connect_color_palette_buttons()

# ==================== SCREEN MANAGEMENT ====================

func show_screen(screen_name: String):
	current_screen = screen_name
	
	# Hide all screens
	main_screen.visible = false
	asset_selection_screen.visible = false
	gallery_view.visible = false
	
	# Show selected screen
	match screen_name:
		"main":
			main_screen.visible = true
		"asset_selection":
			asset_selection_screen.visible = true
			update_asset_preview()
		"gallery":
			gallery_view.visible = true
			update_gallery_preview()

# ==================== CATEGORY BUTTONS ====================

func connect_category_buttons():
	# Connect buttons from MainScreen RightPanel
	if main_screen.has_node("RightPanel/BodyCatButton"):
		main_screen.get_node("RightPanel/BodyCatButton").pressed.connect(_on_category_pressed.bindv(["body"]))
	if main_screen.has_node("RightPanel/HeadCatButton"):
		main_screen.get_node("RightPanel/HeadCatButton").pressed.connect(_on_category_pressed.bindv(["head"]))
	if main_screen.has_node("RightPanel/ClothesCatButton"):
		main_screen.get_node("RightPanel/ClothesCatButton").pressed.connect(_on_category_pressed.bindv(["clothes"]))
	if main_screen.has_node("RightPanel/ExtraCatButton"):
		main_screen.get_node("RightPanel/ExtraCatButton").pressed.connect(_on_category_pressed.bindv(["extra"]))

func _on_category_pressed(category: String):
	current_category = category
	current_asset_index = 0
	current_color_index = 0
	show_screen("asset_selection")

# ==================== NAVIGATION BUTTONS ====================

func connect_navigation_buttons():
	# AssetSelectionScreen navigation
	if asset_selection_screen.has_node("LeftButton"):
		asset_selection_screen.get_node("LeftButton").pressed.connect(_on_asset_prev)
	if asset_selection_screen.has_node("RightButton"):
		asset_selection_screen.get_node("RightButton").pressed.connect(_on_asset_next)
	if asset_selection_screen.has_node("CloseButton"):
		asset_selection_screen.get_node("CloseButton").pressed.connect(_on_asset_close)
	
	# GalleryView navigation
	if gallery_view.has_node("LeftButton"):
		gallery_view.get_node("LeftButton").pressed.connect(_on_gallery_prev)
	if gallery_view.has_node("RightButton"):
		gallery_view.get_node("RightButton").pressed.connect(_on_gallery_next)
	if gallery_view.has_node("BackButton"):
		gallery_view.get_node("BackButton").pressed.connect(_on_gallery_back)
	if gallery_view.has_node("SelectButton"):
		gallery_view.get_node("SelectButton").pressed.connect(_on_gallery_select)

func _on_asset_prev():
	current_asset_index = max(0, current_asset_index - 1)
	update_asset_preview()

func _on_asset_next():
	var max_index = assets[current_category].size() - 1
	current_asset_index = min(max_index, current_asset_index + 1)
	update_asset_preview()

func _on_asset_close():
	show_screen("main")

func _on_gallery_prev():
	current_color_index = max(0, current_color_index - 1)
	update_gallery_preview()

func _on_gallery_next():
	current_color_index = min(asset_colors.size() - 1, current_color_index + 1)
	update_gallery_preview()

func _on_gallery_back():
	show_screen("asset_selection")

func _on_gallery_select():
	# Apply selected asset and color to character
	apply_asset_to_character()
	show_screen("main")

# ==================== COLOR PALETTE ====================

func connect_color_palette_buttons():
	# Connect color buttons in AssetSelectionScreen
	for i in range(asset_colors.size()):
		var color_button_path = "ColorPalette/Color" + str(i)
		if asset_selection_screen.has_node(color_button_path):
			var button = asset_selection_screen.get_node(color_button_path)
			button.pressed.connect(_on_color_selected.bindv([i]))

func _on_color_selected(color_index: int):
	current_color_index = color_index
	update_asset_preview()

# ==================== PREVIEW UPDATES ====================

func update_asset_preview():
	# Update the preview in AssetSelectionScreen
	var current_asset = assets[current_category][current_asset_index]
	var current_color = asset_colors[current_color_index]
	
	# Find and update the preview node
	if asset_selection_screen.has_node("AssetPreview"):
		var preview = asset_selection_screen.get_node("AssetPreview")
		preview.modulate = current_color
		# Update texture/sprite based on current_asset
		print("Preview: ", current_asset, " Color: ", current_color)

func update_gallery_preview():
	# Update the preview in GalleryView
	var current_asset = assets[current_category][current_asset_index]
	var current_color = asset_colors[current_color_index]
	
	if gallery_view.has_node("GalleryPreview"):
		var preview = gallery_view.get_node("GalleryPreview")
		preview.modulate = current_color
		print("Gallery: ", current_asset, " Color: ", current_color)

# ==================== ASSET APPLICATION ====================

func apply_asset_to_character():
	var current_asset = assets[current_category][current_asset_index]
	var current_color = asset_colors[current_color_index]
	
	# Update the character model with selected asset and color
	print("Applying: ", current_asset, " with color: ", current_color, " to ", current_category)
	
	# TODO: Update the actual character model/sprite in MainScreen

# ==================== ASSET CLICK HANDLER ====================

func _on_asset_clicked(asset_index: int):
	current_asset_index = asset_index
	show_screen("gallery")
