extends Node

var rng = RandomNumberGenerator.new()

func _init():
	rng.seed = 1

func randSpread(spread = 35):
	# Use standard deviation of 2.0 to get ~95% of results inside spread
	return rng.randfn(0.0, 1/2.0) * spread

# Pick from an array like [[1,"a"],[2,"b"]] weighted by the first column.
# In this example "b" is returned twice as often as "a".
func pickWeighted(arr):
	var total_weights = 0
	for v in arr:
		total_weights += v[0]

	var wTarget = randi() % total_weights
	var wAccumulated = 0
	for v in arr:
		wAccumulated += v[0]
		if wAccumulated > wTarget:
			return v[1]
	assert(false) # shouldn't get here!

# Pick a random element from array
func pickRandom(arr):
	return arr[randi()%arr.size()]

# Increase clamped - increase val by increment, but clamp to maxVal
func inc_clamp(var val, var increment, var maxVal):
	val += increment
	if val >= maxVal:
		return maxVal
	return val

# Decrease clamped - decrease val by decrement, but clamp to minVal
func dec_clamp(var val, var decrement, var minVal):
	val -= decrement
	if val <= minVal:
		return minVal
	return val
