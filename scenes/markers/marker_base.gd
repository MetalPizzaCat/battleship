extends Node3D
class_name HitMarker


enum MarkerType {
	NONE,
	MISS,
	NEAR_MISS,
	HIT
}

@onready var label: Label3D = $Label3D

var _marker_type: MarkerType
var marker_type: MarkerType:
	get:
		return _marker_type
	set(value):
		_marker_type = value
		match value:
			MarkerType.MISS:
				label.text = "Miss"
			MarkerType.NEAR_MISS:
					label.text = "Near"
			MarkerType.HIT:
				label.text = "Hit"
