extends CharacterBody2D

func drop():
	var tween = create_tween()
	tween.tween_property(self, "position:y", 432.0, 0.9)
