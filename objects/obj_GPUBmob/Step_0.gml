/// @description speak lipsync

if (speak && is_instanceof(GPUB.scene, GPUBscene)) {
	var _sound = array_last(GPUB.scene.text).txt;
	if (_sound != undefined) {
		_sound = get_vowel_from_char(_sound);
	}	
	if (is_array(subimg[$ "speak"])) {
		subimg.speak[0] = speak;
		if (!is_undefined(_sound)) subimg.speak[3] = _sound;
	}
}