extends Node2D

signal tile_generated(tile)

export(float) var heightHarshness
export(int) var minHeight
export(int) var maxHeight

var Dirt = preload("tile/dirt/Dirt.tscn")
var Grass = preload("tile/grass/Grass.tscn")

var constants
var state

var terrain

var x:int setget x_set, x_get	# TODO? replace with get_index()
var height:int
var tiles = {}

func x_set(value):
	x = value
	transform.origin.x = constants.tile_size * value
func x_get():
	return x

func gen():
	var nz = state.noise.perlin_noise2d(heightHarshness * x, state.seed_hash)
	height = floor(minHeight + (maxHeight - minHeight) * (nz + 1) / 2)
	for y in range(height):
		# replace dirt that's exposed to air to grass after next stack's generation
		var type = Dirt
		var tile = type.instance()
		add_child(tile)
		tiles[y] = tile
		# after _ready (add_child)
		tile.y = y
		emit_signal("tile_generated", tile)
		
	# listen in order to turn	dirt -> grass
	terrain.connect("stack_generated", self, "on_Terrain_stack_generated")

func _ready():
	constants = get_node("/root/Constants")
	state = get_node("/root/State")
	
	terrain = get_parent()
	
func on_Terrain_stack_generated(stack):
	if stack.x == x + 1 or stack.x == x - 1:
		# It is the stack to the left or right.
		# We can conclude that all stacks around it are generated, right?
		# Now we can calculate if the tile is exposed to air or not
		# if exposed to air, replace with a grass tile 
		# 	(we can't do this in tile for ovious reasons).
		
		for y in range(height):
			var existing_tile = get_child(y)
			if terrain.is_tile_exposed(x, y):
				var new_tile = Grass.instance()
				# replace `existing_tile` with `new_tile`
				add_child_below_node(existing_tile, new_tile)
				new_tile.y = y
				remove_child(existing_tile)

func get_tile(y):
	# if y < 0, error should be called, and I hope
	# querying a key that does not exist will raise an error
	# so don't do anything
	if y >= height:
		return null		# air
	
	return tiles[y]