/**
 * GPUB 구조체. 각 씬은 서로 비선형적으로 오갈 수 있다.
 * @param {struct} [__hash]={} element list
 * @param {Array<any>} [__txt]=[] text
 */
function GPUBdata(__hash = {}) constructor {
	pause = is_real(__hash[$ "pause"])? __hash.pause : true;
	skip = false;
	visible = is_real(__hash[$ "visible"])? __hash.visible : false;
	depth = is_real(__hash[$ "depth"])? __hash.depth : 100;
}
 
function GPUBscene(__hash = {}, __txt = [])  : GPUBdata(__hash) constructor {	
	
	depth = is_real(__hash[$ "draw"])? __hash.depth : 100;
	
	//padding
	padding = (is_array(__hash[$ "padding"]) && array_length(__hash.padding) == 4)? __hash.padding : [10,40,-10,-10];
	
	//box - from prefab
	var _mybox = is_string(__hash[$ "box"])? new GPUB.Node.Box(global.GPUBsystem.box[$ __hash.box]) : new GPUB.Node.Box(global.GPUBsystem.box.GPUB_default);
	box = {
		now : _mybox,
		base : variable_clone(_mybox),
	}
	//css - default from prefab
	var _mycss = is_string(__hash[$ "css"])? new GPUB.Node.Css(global.GPUBsystem.css[$ __hash.css]) : new GPUB.Node.Css(global.GPUBsystem.css.GPUB_default);
	css = {
		now : _mycss,
		base : variable_clone(_mycss),
	}
	
	//tagname - default from prefab
	showTag = is_bool(__hash[$ "showTag"])? __hash.showTag : false;
	name = is_string(__hash[$ "name"])? __hash.name : "< name >";
	//tagbox - from prefab
	var _tbox = is_string(__hash[$ "tagbox"])? new GPUB.Node.Box(global.GPUBsystem.box[$ __hash.tagbox], box.now) : new GPUB.Node.Box(global.GPUBsystem.box.GPUB_nametag, box.now);
	tagbox = {
		now : _tbox,
		base : variable_clone(_tbox),
	}
	var _tcss = is_string(__hash[$ "tagcss"])? new GPUB.Node.Css(global.GPUBsystem.css[$ __hash.tagcss], tagbox.now, name) : new GPUB.Node.Css(global.GPUBsystem.css.GPUB_nametag, tagbox.now, name);
	tagcss = {
		now : _tcss,
		base : variable_clone(_tcss),
	}
		
	/*content parsing
	content expected structure
	["a", "b", "c", {func:- , arg:-}, "d", "/n" ...]
	*/
	//new array for trimed char
	var _strParse = function(__txt) {
		if (!is_array(__txt)) return;
		if (array_length(__txt) == 0) return;
		var _newarray = [];
		for (var _s=0; _s<array_length(__txt); _s++) {
			switch (typeof(__txt[_s])) {
				//string line
				case "string" : {
					var _interf = 1;
					while (_interf <= string_length(__txt[_s])) {
						var _slicedtxt = new GPUB.Node.Css(css.now, self.box.now, string_char_at(__txt[_s], _interf++));
						array_push(_newarray, _slicedtxt);
					}
					break;
				}
				//function array to struct package
				case "array" : {
					var _scrtp = struct_get(GPUBscene.Command, __txt[_s][0]);
					var _param = __txt[@ _s][1];
					var _comm = method(self, _scrtp);
					if (is_callable(_scrtp) && _scrtp == GPUBscene.Command.cssStyle) {
						method_call(_comm,_param);						
					} else {
						var _method = [_comm, _param, false];//last var is pass
						array_push(_newarray, _method);
					}
					break;
				}
				//abandon
				default : {
					break;
				}
			}
		}
		return _newarray;
	}
	
	content = _strParse(__txt);//loaded text
	text = [];//actually showed text
	
	//pregress sequence
	var _speed = is_real(__hash[$ "speed"])? __hash[$ "speed"] : GPUB.timeflow;
	step = {
		start : 0,
		current : {tic : 0, now : 0},
		last : array_length(content)-1,
		wait : {on : false, time : 0},
		speed : {base : _speed, now : _speed},
	};
	
	//awake
	Awake = function(__time=-1, __delay=0) {
		show_debug_message($"{ptr(self)} : scene awake");
		if (__time == 0 || !struct_exists(GPUBease.node, self.box.now.animAwake[0])) {
			self.pause = false;
			GPUB.scene = self;
		} else {
			var _keyframes = [
				[method(self, function(){GPUB.scene=self;}), 0],
				[method(self, function(){pause = false}), 1]//timing(0~1)	
			];
			self.box.now.AnimAwake(__time, __delay, _keyframes);
		}
	}
	
	//sleep
	Sleep = function(__time=-1, __delay=0) {
		show_debug_message($"{ptr(self)} : scene sleep");
		if (__time == 0 || !struct_exists(GPUBease.node, self.box.now.animSleep[0])) {
			self.pause = true;
			self.visible = false;
		} else {
			self.pause = true;
			var _keyframes = [
				[method(self, function() {visible = false}), 1]//timing(0~1)	
			];
			self.box.now.AnimSleep(__time, __delay, _keyframes);
		}
	}
	
	//switch Show
	Show = function(__switch, __time=-1, __delay=0) {
		show_debug_message($"{ptr(self)} : scene show setting - {__switch}");
		if (__time == 0 || !struct_exists(GPUBease.node, self.box.now.animAwake[0])) {
			self.visible = __switch;
		} else {
			if (__switch) {
				var _keyframes = [
					[method(self, function(){visible = true;}), 0],
				];
				self.box.now.AnimAwake(__time, __delay, _keyframes);
			}
			else {
				var _keyframes = [
					[method(self, function(){visible = false;}), 1],
				];
				self.box.now.AnimSleep(__time, __delay, _keyframes);
			}
		}		
	}
	
	//pause
	Pause = function() {
		show_debug_message($"{ptr(self)} : scene pause");
		self.pause = true;
		self.visible = true;
	}
	
	//trigger by area touch
	Trigger = function() {
		if (self.pause) return false;
		if (step.wait.on) {
			show_debug_message($"{ptr(self)} : GPUBscene wait break.");
			step.wait.on = false;
			step.wait.time = 0;
		}else{
			show_debug_message($"{ptr(self)} : GPUBscene skipped until 'wait commant.'");
			method_call(method(self, GPUBscene.Command.scnSkip), []);
		}
		return true;
	}
		
	//routine
	Routine = function() {
		if (self.pause) return;
		//current go toward
		if (step.current.now < step.last) {
			if (!step.wait.on) step.current.now += GPUB.tic * step.speed.now;
			step.current.now = min(step.current.now, step.last);//blocking overflow
		} else { //when last
			step.current.now = step.last;
		}
			
		//step trigger
		while ((step.current.tic <= floor(step.current.now) && !step.wait.on)) {	
			var _ticc = content[step.current.tic];
			switch (typeof(_ticc)) {
				//string add
				case "struct" : {
					if (!_ticc.pass) {
						array_push(text, _ticc);
						if (!skip) _ticc.AnimStart();
					}
					break;
				}
				//method excute
				case "array" : {
					if (!_ticc[2]) {
						method_call(_ticc[@ 0], _ticc[@ 1]);
					}
					break;	
				}
				default : break;
			}
			step.current.tic++;//finally tic will approach "step.current.now + 1"
		}
		skip = false;
			
		//wait sequence
		if (step.wait.on && step.wait.time > 0) {
			step.wait.time = max(step.wait.time - GPUB.tic, 0);
			if (step.wait.time == 0) step.wait.on = false;
		}
	}
	
	//replay scene
	Rewind = function() {
		step.start = 0;
		step.current.now = 0;
		step.current.tic = 0;
		step.speed.now = step.speed.base;
		
		text = [];
		
		var _st = 0, _cl = array_length(content);
		while (_st < _cl) {
			var _ticc = content[_st];
			switch (typeof(_ticc)) {
				//string add
				case "struct" : {
					_ticc.pass = true;
					break;
				}
				//method excute
				case "array" : {
					_ticc[2] = true;
					break;	
				}
				default : break;
			}
			_st++;//finally tic will approach "step.current.now + 1"
		}
	}
	
	//draw
	Draw = function() {
		if (!self.visible) return;
			
		//box.draw
		var _scene_area = box.now.Draw();
		
		//tagbox draw
		if (showTag) {
			tagbox.now.Draw();
			tagcss.now.Draw();
		}
		
		//padding apply
		_scene_area[2].x += padding[0];
		_scene_area[2].y += padding[1];
		_scene_area[2].w += padding[0] + padding[2];
		_scene_area[2].h += padding[1] + padding[3];
		
		//draw letters
		var _cursor = {x : _scene_area[2].x, y : _scene_area[2].y};
		var _line = 0;
		var _sep = 0;
		var _seplog = [];
		var _text_length = array_length(text);
		
		//devide line - flexidle area feedback
		for (var _l=step.start; _l<step.current.tic; _l++) {			
			
			var _cont = content[_l];
			
			//skip command
			if (is_array(_cont)) {
				if (_l == step.last) {
					_cursor.y += _sep;
					_seplog[_line++] = _cursor.y;
					_sep = 0;
				}
				continue;
			}
			
			if (_cont.pass) continue;
			
			//newline
			if ((_cont.txt == "\n") || (_cursor.x >= _scene_area[2].w)) {
				_cursor.x = _scene_area[2].x;
				_cursor.y += _sep;
				_seplog[_line++] = _cursor.y;
				_sep = 0;
			}
			
			// or line progress
			draw_set_font(_cont.font);
			var _tw = string_width(_cont.txt);
			var _th = string_height("Lorem Ipsum");
			_cont.line = _line;
			_cont.anchor.x = _cursor.x;
			_cursor.x += _tw;
			_sep = max(_sep, _th);	
			
			
		}
		//end of content
		_cursor.y += _sep;
		_seplog[_line] = _cursor.y;
		_sep = 0;
		
		//line sep setting
		for (var _l=step.start; _l<step.current.tic; _l++) {
			var _cont = content[_l];
			//skip command
			if (is_array(_cont)) continue;
			else _cont.anchor.y = _seplog[_cont.line];
		}
		
		//actual draw
		matrix_set(matrix_world, _scene_area[1]);
		for (var _t=0; _t<_text_length; _t++) {
			var _text = text[_t];
			draw_set_font(_text.font);
			var _tw = string_width(_text.txt);
			var _th = string_height(_text.txt);
			draw_text_ext_transformed_color(
				_text.anchor.x + _text.position.x,
				_text.anchor.y + _text.position.y,
				_text.txt, _th, _tw,
				_text.scale.x, _text.scale.y, _text.euler.z,
				_text.color[0], _text.color[1], _text.color[2], _text.color[3],
				_text.alpha * _scene_area[2].a
			);
		}
		matrix_set(matrix_world, matrix_build_identity());	
	}
}

function GPUBselect(__hash = {}, __scr = []) : GPUBdata(__hash) constructor {
	
	depth = is_real(__hash[$ "dpeth"])? __hash.depth : 10;
	base = undefined;
	
	//area
	if (is_string(__hash[$ "box"]) && is_instanceof(global.GPUBsystem.box[$ __hash.area], GPUB.Node.Box)) {
		box = new GPUB.Node.Box(global.GPUBsystem.box[$ __hash.box]);
	} else box = new GPUB.Node.Box(global.GPUBsystem.box.GPUB_select);
	
	//rect ref array
	if (is_array(__hash[$ "button"])) {
		for (var _r=0; _r<array_length(__hash.button); _r++) {
			if (is_string(__hash.button[_r]) && is_instanceof(global.GPUBsystem.box[$ __hash.button[_r]], GPUB.Node.Box)) {
				button[_r] = global.GPUBsystem.box[$ __hash.button[_r]];
			} else button[_r] = global.GPUBsystem.box.GPUB_button;
		}
	}else button[0] = global.GPUBsystem.box.GPUB_button;
	
	//css ref array
	if (is_array(__hash[$ "css"])) {
		for (var _r=0; _r<array_length(__hash.css); _r++) {
			if (is_string(__hash.css[_r]) && is_instanceof(global.GPUBsystem.css[$ __hash.css[_r]], GPUB.Node.Css)) {
				css[_r] = global.GPUBsystem.css[$ __hash.css[_r]];
			} else css[_r] = global.GPUBsystem.css.GPUB_nametag;
		}
	}else css[0] = global.GPUBsystem.css.GPUB_nametag;

	//button
	var _SetButton = function(__txt, __boxnum, __cssnum, __flag, __func) {
		
		//Rect reference define
		if (__boxnum >= array_length(self.button) || __boxnum < 0) {
			show_debug_message("select button ref array - out of index");
			__boxnum = 0;
		}
		var _boxref = new GPUB.Node.Box(self.button[__boxnum], self.box);
		
		//Css reference define
		if (__cssnum >= array_length(self.css) || __cssnum < 0) {
			show_debug_message("select button ref array - out of index");
			__cssnum = 0;
		}
		var _cssref = new GPUB.Node.Css(self.css[__cssnum], _boxref, __txt);
		
		//flag check
		if (!is_string(__flag) || !struct_exists(global.GPUBsystem.flag,  __flag)) __flag = undefined;
		
		//func bake to method
		var _funcref, _funcparam;
		if (is_array(__func) && (array_length(__func) == 2)) {
			if (is_string(__func[0]) && struct_exists(GPUBscene.Command, __func[0])) {
				_funcref = method(self, GPUBscene.Command[$ __func[0]]);
			}
			if (is_array(__func[1])) _funcparam = __func[1];
		}
		var _mtodpack = [_funcref, _funcparam];
		
		//result struct
		var _result = {
			flag : __flag,
			pause : true,
			box : _boxref,
			css : _cssref,
			func : _mtodpack,
		};		
		return _result;
	}
	
	var _btnpack = array_length(__scr);
	button_std = [];//button list
	for (var _s=0; _s<_btnpack; _s+=5) {
		//[text, box, css, flag, excute] 
		var __mtrd = _SetButton(__scr[_s], __scr[_s+1], __scr[_s+2], __scr[_s+3], __scr[_s+4]);
		array_push(self.button_std, __mtrd);
		
	}
	
	//button place area
	area = (is_array(__hash[$ "area"]) && array_length(__hash.area)==4)? __hash.area : [0.5, 0.5, display_get_gui_width(), display_get_gui_height()];
	row = (is_real(__hash[$ "row"]))? max(1, floor(__hash.row)) : 1;
	
	//awake
	Awake = function (__base=undefined, __time=1, __delay=0) {
		show_debug_message($"{ptr(self)} : select awake");
		self.base = __base;
		if (__time <= 0 || !struct_exists(GPUBease.node, self.box.animAwake[0])) {
			self.visible = true;
			self.pause = false;
		} else {
			var _keyframes = [
				[method(self, function(){visible = true}), 0],
				[method(self, function(){pause = false}), 1]//timing(0~1)	
			];
			self.box.AnimAwake(__time, __delay, _keyframes);
		}	
		var _btnlist = array_length(self.button_std);
		for (var _b=0; _b<_btnlist; _b++) {
			self.button_std[_b].box.AnimAwake(__time, __delay);
		}	
	}
	
	//sleep
	Sleep = function (__time=1, __delay=0) {
		if (__time <= 0 || !struct_exists(GPUBease.node, self.box.animSleep[0])) {
			self.pause = true;
			self.visible = false;
		} else {
			self.pause = true;
			var _keyframes = [
				[method(self, function(){visible = false;}), 1]//timing(0~1)	
			];
			self.box.AnimSleep(__time, __delay, _keyframes);
			var _btnlist = array_length(self.button_std);
			for (var _b=0; _b<_btnlist; _b++) {
				self.button_std[_b].box.AnimSleep(__time, __delay);
			}	
		}
		
		if (is_instanceof(self.base, GPUBdata)) self.base.Sleep(__time, 0);
	}
	
	//pause
	Pause = function () {
		show_debug_message($"{ptr(self)} : select pause");
		self.pause = true;
		self.visible = true;
	}

	//trigger by area touch
	Trigger = function() {
		if (self.pause) return false;
		show_debug_message($"{ptr(self)} : select triggered");
		//click check
		var _isactivate = false;
		var _btnlist = array_length(self.button_std);
		for (var _b=0; _b<_btnlist; _b++) {
			if (!self.button_std[_b].pause) {				
				var _stack = Rect.Absolute(self.button_std[_b].box);
				var _focus = Rect.IsFocus(_stack[1], _stack[2], device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
				if (_focus) {
					show_debug_message($"{ptr(self)} : select clicked");
					_isactivate = true;
					method_call(self.button_std[_b].func[0], self.button_std[_b].func[1]);
					return _isactivate;
				}
			}
		}
		return _isactivate;
	}

	//Routine
	Routine = function() {
		//return if not pause
		if (self.pause) return;
				
		var _btnlist = array_length(self.button_std);
		
		//button condition check
		for (var _b=0; _b<_btnlist; _b++) {
			if (is_undefined(self.button_std[_b].flag)) {
				self.button_std[_b].pause = false;
			} else {
				self.button_std[_b].pause = self.button_std[_b].flag;
			} 
		}	
	}
	
	//Draw
	Draw = function() {
		//return if not pause
		if (!self.visible) return;
		var _btnlist = array_length(self.button_std);
		
		//background;
		draw_set_alpha(0.6);
		draw_rectangle_color(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, false);
		draw_set_alpha(1);
					
		//address arrange
		var _cellsize = [
			1 / self.row,//w
			1 / ceil(_btnlist / self.row)//h
		];
		
		for (var _a=0; _a<_btnlist; _a++) {
			var _column = _a mod self.row;
			var _rowidx = _a div self.row;
			
			var _ix = (_column * _cellsize[0]) + (_cellsize[0] * 0.5);
			var _iy = (_rowidx * _cellsize[1]) + (_cellsize[1] * 0.5);
			self.button_std[_a].box.anchor.x = _ix;
			self.button_std[_a].box.anchor.y = _iy;
		}

		//buttons;
		global.GPUBsystem.box.GPUB_select.Draw();
		
		for (var _b=0; _b<_btnlist; _b++) {
			self.button_std[_b].box.Draw();
			self.button_std[_b].css.Draw();
		}		
	}	
}
	
function GPUBscroll(__hash = {}, __txt = []) : GPUBdata(__hash) constructor {

} 