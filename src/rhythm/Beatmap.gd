extends RefCounted
class_name Beatmap

var name: String = "Unknown"
var bpm: float = 120.0
var offset_ms: float = 0.0
var events: Array = [] # Array of dictionaries: { "beat": float, "action": String, "lane": int }

func add_event(beat: float, action: String, lane: int = 0):
	events.append({"beat": beat, "action": action, "lane": lane})
	
func sort_events():
	events.sort_custom(func(a, b): return a.beat < b.beat)

func get_events_in_range(start_beat: float, end_beat: float) -> Array:
	var result = []
	for e in events:
		if e.beat >= start_beat and e.beat <= end_beat:
			result.append(e)
	return result
	
func generate_simple_4_4_map(total_measures: int):
	for m in range(total_measures):
		for b in range(4):
			# Simple beat on every quarter note
			var beat = m * 4 + b
			var action = "light"
			var lane = b % 4 # 0, 1, 2, 3 mapped to lanes
			if b == 0:
				action = "heavy"
			add_event(beat, action, lane)
	sort_events()
