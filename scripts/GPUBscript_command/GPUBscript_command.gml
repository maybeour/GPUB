/*
GPUBscene 명령어 모음
*/
GPUBscene.Command = {

/*Css control command*/	
	//css element change
	cssStyle : function(__hash = {}) {
		//elements call
		var _elements = struct_get_names(__hash);		
		//no elements is reset
		if (array_length(_elements) == 0) {
			var _p = css.now.parent;
			delete css.now;
			css.now = new GPUB.Node.Css(css.base, _p);
		} else {
			for(var _i=0; _i<array_length(_elements); _i++) {
				if (!is_undefined(css.now[$ _elements[_i]])) {
					if (typeof(css.now[$ _elements[_i]]) == typeof(__hash[$ _elements[_i]])) {
						css.now[$ _elements[_i]] = __hash[$ _elements[_i]];
					}
				}
			}
		}		
	},

/*Scene control command*/
	scnShow : function(__switch) {
		if (self.pause) return;
		self.Show(__switch);
	},

	//clear text mass(length from last char)
	scnClear : function(__len = -1) {
		if (self.pause) return;
		step.start = step.current.tic;
		var _txs = array_length(text);
		if (__len < 0) __len = _txs;
		array_delete(text, _txs - __len, _txs);	
	},
	
	//change scene tag name
	scnName : function(__name) {
		self.name = __name;
		self.tagcss.txt = __name;
	},
	
	//scene Tag show control
	scnTag : function(__enable) {
		//pause check
		if (self.pause) return;	
		
		self.showTag = __enable;
	},
	
	//skip step(warning)
	scnSkip : function() {
		//pause check
		if (self.pause) return;
		self.skip = true;
		var __readpos = step.current.tic;
		//go fast until meet "wait"
		while(__readpos < step.last) {
			if (is_array(content[@ __readpos])) {
				var _targetfunc = method_get_index(content[@ __readpos][0]);
				if (_targetfunc == method_get_index(GPUBscene.Command.scnWait) || _targetfunc == method_get_index(GPUBscene.Command.scnClear)) break;
			}
			__readpos++;
		}
		step.current.now = __readpos;
	},
	
	//scene Box animation at once
	scnAct : function(__time=1, __effect="idle", __playback="oneshot") {
		if (self.pause) return;
		
		//animation set
		GPUBease.node[$ __effect](self, __time, __playback);
		return;
	},
	
	//text speed set(warning) speed can't set negative value
	scnSpeed: function(__sec) {		
		//pause check
		if (self.pause) return;
		step.speed.now = (is_real(__sec))? max(0 , __sec) : step.speed.base;
	},
	
	//routine pause(warning)
	scnWait : function(__time = -1) {
		if (!self.pause && !step.wait.on) {
			step.wait.on = true
			step.wait.time = __time;
		}
	},
	
	//scene jump
	scnGoto : function(__dest = "", __awakeT=0, __sleepT=0) {
		var _targetscene = global.GPUBsystem.scene[$ __dest];
		if (is_instanceof(_targetscene, GPUBscene)) {
			self.Sleep(__sleepT, 0);
			_targetscene.Awake(__awakeT, __sleepT);
		}
	},
	
	//select [text,scene]
	scnSelect : function(__dest = "", __time=0, __delay=0) {
		if (self.pause) return;
		var _targetselect = global.GPUBsystem.scene[$ __dest];
		if (is_instanceof(_targetselect, GPUBselect)) _targetselect.Awake(self, __time, __delay);
		self.Pause();
	},
	
/*flag control command*/		
	//flag set[flag name]
	flagSet : function(__flag, __var) {
		if (self.pause) return;
		if (is_string(__flag)) {
			struct_set(global.GPUBsystem.flag, __flag, __var);
		}
	},
	
	//flag check is match
	flagIf : function(__flag, __var) {
		//pause check
		if (self.pause) return;
		if (struct_exists(global.GPUBsystem.flag, __flag)) {
			var _flget = struct_get(global.GPUBsystem.flag, __flag);
			if (_flget != __var) {
				//go fast until meet "flagEnd"
				var __readpos = step.current.tic+1;
				while(__readpos < step.last) {
					if (is_array(content[@ __readpos])) {
						var _targetfunc = method_get_index(content[@ __readpos][@ 0]);
						if (_targetfunc == method_get_index(GPUBscene.Command.flagEnd)) break;
						else content[@ __readpos][@ 2] = true;
					} else {
						content[@ __readpos].pass = true;
					}
					__readpos++;
				}
				step.current.now = __readpos;
			} 
		}
	},
	
	//just close marker for "flagIf" command
	flagEnd : function() {},

/*background control command*/		
	//background img control string
	backImg : function(__img, __time=0, __effect="fadeIn") {
		if (self.pause) return;
		if (!is_string(__img) || !is_instanceof(global.GPUBsystem.img[$ __img], GPUB.Node.Img)) return;
		show_debug_message($"{nameof(backImg)} : <backImg> excute command - {global.GPUBsystem.img[$ __img].img}");	
		global.GPUBsystem.backimg.img = global.GPUBsystem.img[$ __img].img;
		
		if (__time > 0) {
			GPUBease.back[$ __effect](__time);
		}else {
			backSeq_sprite();
		}
	},
	
	//background flowing 
	backFlow : function(__hspeed, __vspeed, __time=0, __ease="Linear") {
		if (self.pause) return;
		var _target = global.GPUBsystem.backimg.current;
		var _start = [layer_get_hspeed(_target), layer_get_vspeed(_target)];
		if (__time > 0) {
			var __trackmtd_h = function(__var, __result) {
				layer_hspeed(__var, __result);
			};
			var __trackmtd_v = function(__var, __result) {
				layer_vspeed(__var, __result);
			};
			new GPUBease(__trackmtd_h, _target, _start[0], __hspeed, __time, __ease);
			new GPUBease(__trackmtd_v, _target, _start[1], __hspeed, __time, __ease);
		} else {
			layer_hspeed(_target, __hspeed);
			layer_vspeed(_target, __vspeed);
		}
	},
	
	//background moveto
	backMove : function(__x, __y, __relative=false, __time=0, __ease="Linear") {
		if (self.pause) return;
		var _target = global.GPUBsystem.backimg.current;
		var _start = [layer_get_x(_target), layer_get_y(_target)];
		if (__time > 0) {
			var __trackmtd_x = function(__var, __result) {
				layer_x(__var, __result);
			};
			var __trackmtd_y = function(__var, __result) {
				layer_y(__var, __result);
			};
			new GPUBease(__trackmtd_x, _target, _start[0], (__relative)? _start[0]+__x : __x, __time, __ease);
			new GPUBease(__trackmtd_y, _target, _start[1], (__relative)? _start[1]+__y : __y, __time, __ease);
		} else {
			layer_x(_target, (__relative)? _start[0]+__x : __x);
			layer_y(_target, (__relative)? _start[1]+__y : __y);
		}			
	},
	
	//background animation index speed set
	backAnimSpeed : function(__speed, __time=0, __ease="Linear") {
		if (self.pause) return;
		var _target = layer_background_get_id(global.GPUBsystem.backimg.current);
		var _start = layer_background_get_speed(_target);
		if (__time > 0) {
			var __trackmtd_s = function(__var, __result) {
				layer_background_speed(__var, __result);
			};
			new GPUBease(__trackmtd_s, _target, _start, __speed, __time, __ease);
		} else {
			layer_background_speed(_target, __speed);
		}	
	},
	
	//background moveto
	backScale : function(__sx, __sy, __time=0, __ease="Linear") {
		if (self.pause) return;
		var _target = layer_background_get_id(global.GPUBsystem.backimg.current);
		var _start = [layer_background_get_xscale(_target), layer_background_get_yscale(_target)];
		if (__time > 0) {
			var __trackmtd_x = function(__var, __result) {
				layer_background_xscale(__var, __result);
			};
			var __trackmtd_y = function(__var, __result) {
				layer_background_yscale(__var, __result);
			};
			new GPUBease(__trackmtd_x, _target, _start[0], __sx, __time, __ease);
			new GPUBease(__trackmtd_y, _target, _start[1], __sy, __time, __ease);
		} else {
			layer_background_xscale(_target, __sx);
			layer_background_yscale(_target, __sy);
		}
	},
	
	//background color blend
	backColor : function(__col, __time=0, __ease="Linear") {
		if (self.pause) return;
		var _target = layer_get_fx(global.GPUBsystem.backimg.current);
		var _start = fx_get_parameter(_target, "g_TintCol");
		var _dest = [color_get_red(__col)/255, color_get_green(__col)/255, color_get_blue(__col)/255];
		if (__time > 0) {
			var __trackmtd_col = function(__var, __result) {
				fx_set_parameter(__var, "g_TintCol", __result);
			};
			new GPUBease(__trackmtd_col, _target, _start, _dest, __time, __ease);
		} else {
			fx_set_parameter( _target, "g_TintCol", _dest);
		}
	},
	
	//background transparent
	backAlpha : function(__alpha, __time=0, __ease="Linear") {
		if (self.pause) return;
		var _target = layer_background_get_id(global.GPUBsystem.backimg.current);
		var _start = layer_background_get_alpha(_target);
		if (__time > 0) {
			var __trackmtd_a = function(__var, __result) {
				layer_background_alpha(__var, __result);
			};
			new GPUBease(__trackmtd_a, _target, _start, __alpha, __time, __ease);
		} else {
			layer_background_alpha(_target, __alpha);
		}
	},

/*mob control command*/
	//mob instance create to room
	mobAdd : function(__ref, __id, __time=1, __effect="fadeIn", __x=room_width*0.5, __y=room_height*0.5) {
		//check
		if (!is_string(__ref)) {
			show_debug_message($"{ptr(self)} : GPUBmob create failed - wrong string name.");
			return;
		}
		if (!is_string(__id)) {
			show_debug_message($"{ptr(self)} : GPUBmob create failed - wrong figured id.");
			return;
		}
		if (ds_map_exists(global.GPUBsystem.mobElement, __id)) {
			show_debug_message($"{ptr(self)} : GPUBmob create failed - wrong reference name.");
			return;
		}
		if (!struct_exists(global.GPUBsystem.mob, __ref)) {
			show_debug_message($"{ptr(self)} : GPUBmob create failed - prefab no exist.");
			return;
		}
		if (!is_instanceof(global.GPUBsystem.mob[$ __ref], GPUB.Node.Mob)) {
			show_debug_message($"{ptr(self)} : GPUBmob create failed - no defined name.");
			return;
		}
		if (!sprite_exists(global.GPUBsystem.mob[$ __ref].img)) {
			show_debug_message($"{ptr(self)} : GPUBmob create failed - mob image not set.");
			return;
		}
		if (!layer_exists("GPUBlayer_mob")) {
			show_debug_message($"{ptr(self)} : GPUBmob create failed - no room layer for mob exist.");
			return;
		}
			
		//new mob instance
		var _newmob = instance_create_layer(__x, __y, "GPUBlayer_mob", obj_GPUBmob, {
			name : __id,
			sprite_index : global.GPUBsystem.mob[$ __ref].img,
			image_index : 0,
			image_speed : 0,
			subimg : variable_clone(global.GPUBsystem.mob[$ __ref].subimg)
		});
			
		//add new mob to map
		ds_map_add(global.GPUBsystem.mobElement, __id, _newmob);
			
		//animation set
		if (__time > 0) {
			GPUBease.node[$ __effect](_newmob.subTransform, __time);
		}
		return;
	},
	
	//mob acting sequence create
	mobAct : function(__id, __time=1, __effect="idle", __playback="oneshot") {
		//check
		if (!is_string(__id)) return;
		if (!ds_map_exists(global.GPUBsystem.mobElement, __id)) return;
		var _target = global.GPUBsystem.mobElement[? __id];
		if (_target.object_index != obj_GPUBmob) return;

		//animation set
		GPUBease.node[$ __effect](_target.subTransform, __time, __playback);
		return;
	},

	//mob delete from layer and remove from asset
	mobDelete : function(__id, __time=1, __effect="fadeOut") {
		//check
		if (!is_string(__id)) return;
		if (!ds_map_exists(global.GPUBsystem.mobElement, __id)) return;
		var _target = global.GPUBsystem.mobElement[? __id];
		ds_map_delete(global.GPUBsystem.mobElement, __id);
		if (_target.object_index != obj_GPUBmob) return;

		//animation set
		if (__time > 0) {
			GPUBease.node[$ __effect](_target.subTransform, __time, "destroy");
		} else instance_destroy(_target);
		return;
	},
	
	//mob's subimg on/off
	mobExp : function(__id, __expression, __value) {
		//check
		if (!is_string(__id)) return;
		if (!ds_map_exists(global.GPUBsystem.mobElement, __id)) return;
		var _target = global.GPUBsystem.mobElement[? __id];
		if (_target.object_index != obj_GPUBmob) return;
		
		if (struct_exists(_target.subimg, __expression)) {
			_target.subimg[$ __expression][0] = __value;
		}
	},

	//mob will acting speaking sync active scene
	mobLipsync : function(__id="", __value=true) {
		//check
		if (!is_string(__id)) return;
		if (!ds_map_exists(global.GPUBsystem.mobElement, __id)) return;
		var _target = global.GPUBsystem.mobElement[? __id];
		ds_map_delete(global.GPUBsystem.mobElement, __id);
		if (_target.object_index != obj_GPUBmob) return;		
		_target.speak = __value;
	},
	
	//mob moving
	mobMove : function(__id, __x, __y, __relative=false, __time=1, __ease="Linear") {
		//check
		if (!is_string(__id)) return;
		if (!ds_map_exists(global.GPUBsystem.mobElement, __id)) return;
		var _target = global.GPUBsystem.mobElement[? __id];
		if (_target.object_index != obj_GPUBmob) return;

		var _start = [_target.x, _target.y];
		if (__time > 0) {
			new GPUBease(_target, "x", _start[0], (__relative)? _start[0]+__x : __x, __time, __ease);
			new GPUBease(_target, "y", _start[1], (__relative)? _start[1]+__y : __y, __time, __ease);
		} else {
			_target.x = (__relative)? _start[0]+__x : __x;
			_target.y = (__relative)? _start[1]+__y : __y;
		}		
	},
/*fx control command*/
};



