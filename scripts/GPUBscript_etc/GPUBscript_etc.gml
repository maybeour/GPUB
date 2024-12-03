
//backgroud animation function(no use)
function backSeq_sprite() {
	show_debug_message($"GPUB background change func");
	var _backid = layer_background_get_id(global.GPUBsystem.backimg.current);
	var _backfx = layer_get_fx(global.GPUBsystem.backimg.current);
	
	var _img = global.GPUBsystem.backimg.img;
	var _backprev = layer_background_get_id(global.GPUBsystem.backimg.prev);
	var _previmg = layer_background_get_sprite(_backid);
	var _prevfx = layer_get_fx(global.GPUBsystem.backimg.prev);

	layer_background_change(_backprev, _previmg);
	layer_background_change(_backid, _img);
	
	var _viewport = [room_width*0.5, room_height*0.5];
	if (sprite_exists(_previmg)) {
		var _imginfo = sprite_get_info(_previmg);
		var _scale = max(room_width/_imginfo.width, room_height/_imginfo.height);

		var _offset = [
			_viewport[0] - _imginfo.xoffset * _scale,
			_viewport[1] - _imginfo.yoffset * _scale,
		]
		layer_x(global.GPUBsystem.backimg.prev, layer_get_x(global.GPUBsystem.backimg.current));
		layer_y(global.GPUBsystem.backimg.prev, layer_get_y(global.GPUBsystem.backimg.current));
		layer_background_xscale(_backprev, layer_background_get_xscale(_backid));
		layer_background_yscale(_backprev, layer_background_get_yscale(_backid));
	}
	if (sprite_exists(_img)) {
		var _imginfo = sprite_get_info(_img);
		var _scale = max(room_width/_imginfo.width, room_height/_imginfo.height);

		var _offset = [
			_viewport[0] - _imginfo.xoffset * _scale,
			_viewport[1] - _imginfo.yoffset * _scale,
		]
		layer_x(global.GPUBsystem.backimg.current, _offset[0]);
		layer_y(global.GPUBsystem.backimg.current, _offset[1]);
		layer_background_xscale(_backid, _scale);
		layer_background_yscale(_backid, _scale);
	}
	
	var _col = fx_get_parameter(_backfx, "g_TintCol");
	fx_set_parameter(_prevfx, "g_TintCol", _col);
	fx_set_parameter(_backfx, "g_TintCol", 1,1,1,1);

	layer_background_alpha(_backprev, layer_background_get_alpha(_backid));
}

//check the one single char is english
function is_english_char(code) {
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122); // 'A-Z' 또는 'a-z'
}

//check the one single char is korean
function is_korean_char(code) {
	var base = 0xAC00;
    return (code >= base || code <= 0xD7A3);
}

//get vowel from one single korean char
function get_vowel_from_char(char) {
    // 한글 유니코드 시작 값
    var base = 0xAC00;
	var unicode = ord(char);
	
	if (is_korean_char(unicode)) {
	    // 입력 문자의 유니코드 값
	    

	    // 유니코드 계산
	    var index = (unicode - base) % 588 / 28; // 중성(모음) 계산

	    // 모음 테이블
	    /*var vowels = [
	        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", 
	        "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", 
	        "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"
	    ];
		var vowels = [
	        "a", "ae", "ya", "yae", "eo", "e", "yeo", "yea", 
	        "o", "wa", "wae", "oe", "yo", "u", "woe", "wea", 
	        "ui", "yu", "ee", "eei", "i"
	    ];*/

	    // 모음 반환
	    return index;
	}else if (is_english_char(unicode)) {
		switch (char) {
			case "a" : return 0;
			case "i" : return 20;
			case "u" : return 13;
			case "e" : return 5;
			case "o" : return 8;
			default : return -1;
		}
	} else return -1;
}

