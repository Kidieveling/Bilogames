/// @description Invisible GuidedIntro waypoints; marker_id assigned from rm_tutorial placement coords.

visible = false;

#region Marker Id By Position

if (x == 160 && y == 240) {
	marker_id = "intro_gate";
} else if (x == 128 && y == 160) {
	marker_id = "intro_trainers";
} else if (x == 352 && y == 96) {
	marker_id = "intro_workyard";
} else if (x == 240 && y == 208) {
	marker_id = "intro_trial";
} else {
	marker_id = "unset";
}

#endregion
