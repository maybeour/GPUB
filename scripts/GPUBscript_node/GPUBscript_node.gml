GPUB.Node = {
	/**
	* Function CSS class object constructor
	* @param {struct} [__hash]={} element list struct
	* @param {String} [__txt]="" overrideable Text
	* @returns {struct} Description
	*/
	Css : function(__hash = {}, __parent = undefined, __txt = "") : Rect(__hash, __parent) constructor {
		font = -1;
		txt = "";
		align = { h : fa_left, v : fa_bottom };
		line = 0; //(%)
		sep = 0.5;
		pass = false;//skip from scene
		
		//font
		switch (typeof(__hash[$ "font"])) {
			case "string" : {
				var _fnt = asset_get_index(__hash.font);
				if (font_exists(_fnt)) self.font = _fnt;
				else self.font = GPUB.Resource.font(__hash.font);
				break;
			}
			case "number" : 
			case "ref" : {
				if (font_exists(__hash.font)) self.font = __hash.font;
				break;
			}
		}
		
		//txt
		if (is_string(__hash[$ "txt"])) self.txt = __hash.txt;
		if (is_string(__txt)) self.txt = __txt;
		
		//align
		if (is_array(__hash[$ "align"]) && array_length(__hash.align) == 2) {
			switch (__hash.align[0]) {
				case fa_left     : {self.align.h = fa_left; break;} 
				case fa_center   : {self.align.h = fa_center; break;}
				case fa_right    : {self.align.h = fa_right; break;}
				
				case "fa_left"   : {self.align.h = fa_left; break;} 
				case "fa_center" : {self.align.h = fa_center; break;}
				case "fa_right"  : {self.align.h = fa_right; break;}
				
				default          : {self.align.h = fa_left; break;} 
			}
			switch (__hash.align[1]) {
				case fa_top      : {self.align.v = fa_top; break;} 
				case fa_middle   : {self.align.v = fa_middle; break;}
				case fa_bottom   : {self.align.v = fa_bottom; break;}
				
				case "fa_top"    : {self.align.v = fa_top; break;} 
				case "fa_middle" : {self.align.v = fa_middle; break;}
				case "fa_bottom" : {self.align.v = fa_bottom; break;}
				
				default          : {self.align.v = fa_bottom; break;} 
			}
		}
		else if (is_struct(__hash[$ "align"]) && struct_names_count(__hash.align) == 2) {
			switch (__hash.align.h) {
				case fa_left     : {self.align.h = fa_left; break;} 
				case fa_center   : {self.align.h = fa_center; break;}
				case fa_right    : {self.align.h = fa_right; break;}
				
				case "fa_left"   : {self.align.h = fa_left; break;} 
				case "fa_center" : {self.align.h = fa_center; break;}
				case "fa_right"  : {self.align.h = fa_right; break;}
				
				default          : {self.align.h = fa_left; break;} 
			}
			switch (__hash.align.v) {
				case fa_top      : {self.align.v = fa_top; break;} 
				case fa_middle   : {self.align.v = fa_middle; break;}
				case fa_bottom   : {self.align.v = fa_bottom; break;}
				
				case "fa_top"    : {self.align.v = fa_top; break;} 
				case "fa_middle" : {self.align.v = fa_middle; break;}
				case "fa_bottom" : {self.align.v = fa_bottom; break;}
				
				default          : {self.align.v = fa_bottom; break;} 
			}
		}
		
		//sep
		if (is_real(__hash[$ "sep"])) self.sep = __hash.sep;
		
		//animation
		animAwake = ["",0,undefined];
		if (is_array(__hash[$ "animAwake"]) && array_length(__hash.animAwake) >= 2) {
			animAwake[0] = (is_string(__hash.animAwake[0]))? __hash.animAwake[0] : "";
			animAwake[1] = (is_real(__hash.animAwake[1]))? __hash.animAwake[1] : 0;
			animAwake[2] = undefined;
		}
		animStep = ["",0,undefined];
		if (is_array(__hash[$ "animStep"]) && array_length(__hash.animStep) >= 2) {
			animStep[0] = (is_string(__hash.animStep[0]))? __hash.animStep[0] : "";
			animStep[1] = (is_real(__hash.animStep[1]))? __hash.animStep[1] : 0;
			animStep[2] = undefined;
		}
			
		//animation control
		self.AnimStart = function() {			
			if (struct_exists(GPUBease.node, animAwake[0])) {
				if (is_array(animAwake[2])){
					for(var _a=0; _a<array_length(animAwake[2]); _a++) {
						GPUBease.Skip(animAwake[2][_a]);
					}
				}
				animAwake[2] = GPUBease.node[$ animAwake[0]](self, animAwake[1], "oneshot", );
			}
			if (struct_exists(GPUBease.node, animStep[0])) {
				if (is_array(animStep[2])){
					for(var _a=0; _a<array_length(animStep[2]); _a++) {
						GPUBease.Skip(animStep[2][_a]);
					}
				}
				animStep[2] = GPUBease.node[$ animStep[0]](self, animStep[1], "repeat");
			}
		}
		self.AnimStop = function() {
			for(var _a=0; _a<array_length(animAwake[2]); _a++) {
				GPUBease.Skip(animAwake[2][_a]);
			}
			animAwake[2] = undefined;
			for(var _a=0; _a<array_length(animStep[2]); _a++) {
				GPUBease.Skip(animStep[2][_a]);
			}
			animStep[2] = undefined;
		}
		
		//drawing self function
		self.Draw = function(__x=0, __y=0) {
			var _stack = Rect.Absolute(self);
			var _focus = Rect.IsFocus(_stack[1], _stack[2], device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
			
			//matrix apply
			matrix_set(matrix_world, _stack[1]);
			
			//draw
			draw_set_font(self.font);
			draw_set_halign(self.align.h);
			draw_set_valign(self.align.v);
			
			var _tw = string_width(self.txt);
			var _th = string_height(self.txt);
			
			draw_text_ext_color(
				_stack[2].cx+__x,
				_stack[2].cy+__y,
				self.txt, _th*self.sep, _tw,
				self.color[0], self.color[1], self.color[2], self.color[3],
				_stack[2].a
			);
			//draw_rectangle_color(_stack[2].x, _stack[2].y, _stack[2].x+_stack[2].w, _stack[2].y+_stack[2].h, self.color[0], self.color[1], self.color[2], self.color[3], 1);
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			draw_set_font(fnt_GPUBdefault);
			
			matrix_set(matrix_world, matrix_build_identity());
			
			return _stack;
		}
	},

	/**
	* Function Box class object constructor
	* @param {struct} [__hash]={} element list struct
	* @returns {struct} Description
	*/
	Box : function(__hash = {}, __parent = undefined) : Rect(__hash, __parent) constructor {
		
		self.img = -1;
		
		//img
		switch (typeof(__hash[$ "img"])) {
			case "string" : {
				var _spr = asset_get_index(__hash.img);
				if (sprite_exists(_spr)) self.img = _spr;
				else GPUB.Resource.img(__hash.img);
				break;
			}
			case "number" : 
			case "ref" : {
				if (sprite_exists(__hash.img)) self.img = __hash.img;
				break;
			}
		}
		
		//animation
		animAwake = ["a",0,undefined];
		if (is_array(__hash[$ "animAwake"]) && array_length(__hash.animAwake) >= 2) {
			animAwake[0] = is_string(__hash.animAwake[0])? __hash.animAwake[0] : "a";
			animAwake[1] = is_real(__hash.animAwake[1])? __hash.animAwake[1] : 0;
			animAwake[2] = undefined;
		}
		animStep = ["a",0,undefined];
		if (is_array(__hash[$ "animStep"]) && array_length(__hash.animStep) >= 2) {
			animStep[0] = is_string(__hash.animStep[0])? __hash.animStep[0] : "a";
			animStep[1] = is_real(__hash.animStep[1])? __hash.animStep[1] : 0;
			animStep[2] = undefined;
		}
		animSleep = ["a",0,undefined];
		if (is_array(__hash[$ "animSleep"]) && array_length(__hash.animSleep) >= 2) {
			animSleep[0] = is_string(__hash.animSleep[0])? __hash.animSleep[0] : "a";
			animSleep[1] = is_real(__hash.animSleep[1])? __hash.animSleep[1] : 0;
			animSleep[2] = undefined;
		}
		
		//animation control
		self.AnimAwake = function(__time, __delay, __key=[]) {			
			if (struct_exists(GPUBease.node, animAwake[0])) {
				if (is_array(animAwake[2])){
					for(var _a=0; _a<array_length(animAwake[2]); _a++) {
					GPUBease.Skip(animAwake[2][_a]);
					}
				}
				animAwake[2] = GPUBease.node[$ animAwake[0]](self, animAwake[1], "oneshot", __key, __delay);
			}
			if (struct_exists(GPUBease.node, animStep[0])) {
				if (is_array(animStep[2])){
					for(var _a=0; _a<array_length(animStep[2]); _a++) {
					GPUBease.Skip(animStep[2][_a]);
					}
				}
				animStep[2] = GPUBease.node[$ animStep[0]](self, animStep[1], "repeat", [], __delay);
			}
		}
		
		self.AnimSleep = function(__time, __delay, __key=[]) {
			for(var _a=0; _a<array_length(animStep[2]); _a++) {
				GPUBease.Skip(animAwake[2][_a]);
			}
			animAwake[2] = undefined;
			for(var _a=0; _a<array_length(animStep[2]); _a++) {
				GPUBease.Skip(animStep[2][_a]);
			}
			animStep[2] = undefined;
			//sleep anim
			if (struct_exists(GPUBease.node, animSleep[0])) {
				if (is_array(animSleep[2])){
					for(var _a=0; _a<array_length(animSleep[2]); _a++) {
					GPUBease.Skip(animSleep[2][_a]);
					}
				}
				animSleep[2] = GPUBease.node[$ animSleep[0]](self, animSleep[1], "oneshot", __key, __delay);
			}
		}
		
		//drawing self function
		self.Draw = function(__x=0, __y=0) {		
			var _stack = Rect.Absolute(self);
			var _focus = Rect.IsFocus(_stack[1], _stack[2], device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
			
			if (sprite_exists(self.img)) {
				//matrix apply
				matrix_set(matrix_world, _stack[1]);
			
				//draw_sprite and outline
				draw_sprite_stretched_ext(self.img, -1, _stack[2].x+__x, _stack[2].y+__y, _stack[2].w, _stack[2].h, self.color[0], _stack[2].a);			
				//draw_rectangle_color(_stack[2].x, _stack[2].y, _stack[2].x+_stack[2].w, _stack[2].y+_stack[2].h, self.color[0], self.color[1], self.color[2], self.color[3], true);
			
				matrix_set(matrix_world, matrix_build_identity());
			}
			
			return _stack;
		}
	},

	/**
	* Function image class object constructor
	* @param {struct} [__hash]={} element list struct
	* @returns {struct} Description
	*/
	Img : function(__hash = {} , __parent = undefined) constructor {
		
		self.img = -1;
		//img
		switch (typeof(__hash[$ "img"])) {
			case "string" : {
				var _spr = asset_get_index(__hash.img);
				if (sprite_exists(_spr)) self.img = _spr;
				else GPUB.Resource.img(__hash.img);
				break;
			}
			case "number" :
			case "ref" : {
				if (sprite_exists(__hash.img)) self.img = __hash.img;
				break;
			}
		}
	},
	
	/**
	 * Function mob struct. index 0 is base, 1~ is subimgs
	 * @param {struct} [__hash]={} Section of subimg
	 */
	Mob : function(__hash = {}) constructor {
		
		self.img = -1;
		self.subimg = {};
		
		//img
		switch (typeof(__hash[$ "img"])) {
			case "string" : {
				var _spr = asset_get_index(__hash.img);
				if (sprite_exists(_spr)) self.img = _spr;
				else GPUB.Resource.img(__hash.img);
				break;
			}
			case "number" :
			case "ref" : {
				if (sprite_exists(__hash.img)) self.img = __hash.img;
			}
		}
			
		//subimg = [visible, start index, end index]
		if (is_struct(__hash[$ "subimg"])) {
			var _sn = struct_get_names(__hash.subimg);
			var _sc = struct_names_count(__hash.subimg);
			for (var _i=0; _i<_sc; _i++) {
				if (is_array(__hash.subimg[$ _sn[_i]]) && array_length(__hash.subimg[$ _sn[_i]])>=3) {
					struct_set(self.subimg, _sn[_i], __hash.subimg[$ _sn[_i]]);
					self.subimg[$ _sn[_i]][3] = 0;
				}
			}
		}		
	},
}