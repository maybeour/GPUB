/**
 * Function Description
 * @param {struct OR Id.Instance OR method} __obj Description
 * @param {any} __var Description
 * @param {any} __start Description
 * @param {any} __dest Description
 * @param {real} [__length]=1 Description
 * @param {string} [__ease]="Linear" Description
 * @param {string} [__playback]="oneshot" Description
 * @param {array} [__keyframe]=[] Description
 */
function GPUBease(__obj, __var, __start, __dest, __length=1, __ease="Linear", __playback="oneshot", __keyframe=[], __delay=0) constructor {

	//basic
	time = -abs(__delay);
	length = abs(__length);
	playback = __playback;
	headdir = 1;
	pause = false;
	speedscale = 1;
	skip = false;
	
	//keyframes
	var _key_count = array_length(__keyframe);
	for (var _m=0; _m<_key_count; _m++) {
		if !(is_array(__keyframe[_m]) &&
			array_length(__keyframe[_m])==2 &&
			is_method(__keyframe[_m][0]) &&
			is_real(__keyframe[_m][1]) &&
			median(0, 1, __keyframe[_m][1])==__keyframe[_m][1]
			) {
			show_debug_message($"{ptr(self)} : GPUBease create failed - keyframe moment array is not figured.");
			GPUBease.Destroy(self);
			return;
		}
	}
	keys = __keyframe;

	//object define
	objtype = typeof(__obj);
	switch (objtype) {
		case "struct" : {
			obj = weak_ref_create(__obj); 
			if (!is_string(__var)) {
				show_debug_message($"{ptr(self)} : GPUBease create failed - struct target must with string var parameter.");
				GPUBease.Destroy(self);
			} else if (!struct_exists(__obj, __var)){
				show_debug_message($"{ptr(self)} : GPUBease create failed - struct target have no parameter for it.");
				GPUBease.Destroy(self);
			} else if (typeof(__start) != typeof(__obj[$ __var])) {
				show_debug_message($"{ptr(self)} : GPUBease create failed - struct target type is not matched animate value type.");
				GPUBease.Destroy(self);
			} else {
				if (is_array(__start) && is_array(__dest) && is_array(__obj[$ __var])) {
					var _al = [
						array_length(__start),
						array_length(__dest),
						array_length(__obj[$ __var])
						];
					if (! _al[0]==_al[1] && _al[1]==_al[2]) {
						show_debug_message($"{ptr(self)} : GPUBease create failed - struct target array size is not metched between animate array size.");
						GPUBease.Destroy(self);
					}
				}
			}
			vartype = typeof(__obj[$ __var]);
			break;
		}
		case "ref"    : {
			obj = __obj;
			if (!is_string(__var)) {
				show_debug_message($"{ptr(self)} : GPUBease create failed - instance target must with string var parameter.");
				GPUBease.Destroy(self);
			}
			vartype = typeof(__obj[$ __var]);
			break;
		}
		case "method" : {
			obj = __obj;
			vartype = typeof(__var);
			break;
		}
		default : {
			show_debug_message($"{ptr(self)} : GPUBease create failed - targeting wrong 'instance / method / struct'.");
			GPUBease.Destroy(self);
			return;
		}
	}
	objvar = __var;	
	
	if (typeof(__start) != typeof(__dest)) {
		show_debug_message($"{ptr(self)} : GPUBease create failed - start,destination value type not match.");
		GPUBease.Destroy(self);
	}
	
	var _animcurve = animcurve_get(asset_get_index(string_concat("anim_GPUB_", __ease)));
	if (!is_struct(_animcurve)) {
		show_debug_message($"{ptr(self)} : GPUBease create failed - animcurve is not exist");
		GPUBease.Destroy(self);
		return;
	}
	
	anim = {
		start : __start,
		dest : __dest,
		ease : _animcurve.channels,
	}

	switch (playback) {
		case "destroy" :
		case "repeat" :
		case "oneshot" : 
		case "pingpong" : break;
		default : {
			show_debug_message($"{ptr(self)} : GPUBease create failed - undefined playback type.");
			GPUBease.Destroy(self);
			return;
		}
	}
	
	GPUBease.Update(self);//2nd parameter is relation to skip time function
	ds_list_add(global.GPUBsystem.ease, self);
	show_debug_message($"{ptr(self)} : GPUBease set : \n type : {objtype} \n var : {vartype} \n length : {length}");
	
	//destroy
	static Destroy = function(__ref) {
		if (!is_instanceof(__ref, GPUBease)) return;
		show_debug_message($"{ptr(__ref)} : GPUBease struct destroyed.");
		if (is_struct(__ref.obj)) delete __ref.obj;
		ds_list_delete(global.GPUBsystem.ease, ds_list_find_index(global.GPUBsystem.ease, __ref));
		delete __ref;
		return;
	} 
	
	//speedscale
	static SpeedScale = function(__ref, __speed) {
		if (!is_instanceof(__ref, GPUBease)) return;
		__ref.speedscale = __speed;
	}
	
	//update
	static Update = function(__ref) {
		//is GPUBease?
		if (!is_instanceof(__ref, GPUBease)) return;
		
		//is end?
		if (__ref.time >= __ref.length) {
			switch (__ref.playback) {
				case "pingpong" : __ref.headdir = -1; break;
				case "repeat" : __ref.time = 0; break;
				case "destroy" : 
				case "oneshot" :
				default : {	GPUBease.Destroy(__ref); break; }
			}
			return;
		} else if (__ref.playback == "pingpong" && __ref.headdir == -1 && __ref.time < 0) __ref.headdir = 1;

		//pause check
		if (!__ref.pause) {
			
			//time advence
			var _timelerp = [0,0];
			_timelerp[0] = __ref.time / __ref.length;// before porgress time
			
			if (__ref.skip) {
				__ref.time = __ref.length;
				__ref.skip = false;
			}
			
			__ref.time += GPUB.tic * __ref.speedscale * __ref.headdir;
			
			_timelerp[1] =  __ref.time / __ref.length;// after progress time
					
			//ger lerp and convert to eased lerp
			var _easetime = animcurve_channel_evaluate(__ref.anim.ease[0], _timelerp[1]);
			var _result = __ref.anim.start;
			switch (typeof(_result)) {						
				case "number" : {
					_result = lerp(__ref.anim.start, __ref.anim.dest, _easetime);
					break;
					}
				case "array" : {
					var _count = min(array_length(__ref.anim.start), array_length(__ref.anim.dest));
					for (var _s=0; _s<_count; _s++){
						_result[_s] = lerp(__ref.anim.start[_s], __ref.anim.dest[_s], _easetime);
					}
					break;
				}
				case "ref" : {
					_result = (_easetime >= __ref.index)? __ref.anim.start : __ref.anim.dest;
					break;
				}
			}
			
			//check method keyframe
			var _key_count = array_length(__ref.keys);
			for (var _m=0; _m<_key_count; _m++) {
				if ((min(_timelerp[0], _timelerp[1]) <= __ref.keys[_m][1]) && (max(_timelerp[0], _timelerp[1]) > __ref.keys[_m][1])) {
					method_call(__ref.keys[_m][0], [__ref.objvar, _result, _timelerp, __ref.anim.start, __ref.anim.dest]);
				}
			}
			//do something for obj with result
			_timelerp[1] = median(0, 1, _timelerp[1]);
			switch (__ref.objtype) { //
				case "struct" : {
					if (!weak_ref_alive(__ref.obj)) {
						GPUBease.Destroy(__ref); 
						return;
					}
					__ref.obj.ref[$ __ref.objvar] = _result
					break;
				}
				case "method" : {
					if (!is_method(__ref.obj)) {
						GPUBease.Destroy(__ref); 
						return;
					}
					method_call(__ref.obj, [__ref.objvar, _result, _timelerp, __ref.anim.start, __ref.anim.dest]); 
					break;
				}
				case "ref" : {
					if (!instance_exists(__ref.obj)) {
						GPUBease.Destroy(__ref); 
						return;
					}
					__ref.obj[$ __ref.objvar] = _result;
				}
			}
		}
		return;
	}
	
	//skip
	static Skip = function(__ref) {
		if (!is_instanceof(__ref, GPUBease)) return;
		switch(__ref.playback) {
			case "repeat" :
			case "pingpong" : {GPUBease.Destroy(__ref); break;}
			case "oneshot" :
			case "destroy" : {__ref.skip = true; break;}
			default : break;
		}
		return;
	}
}

//animation preset
GPUBease.back = {
	flashIn : function (__sec, __playback="oneshot", __delay=0) {
		var _stepEvent =  method(undefined, function(__var, __result) {
			var _backid = layer_background_get_id(__var);
			layer_background_blend(_backid, __result);
		});
		//keyframes
		var _keyframes = [
			[method(undefined, backSeq_sprite
			), 0],//timing(0~1)	
		];
		return [new GPUBease(_stepEvent, global.GPUBsystem.backimg.current, #ffffff, #000000, __sec, "Linear_R",  __playback, _keyframes, __delay)];
	}, 
	darkIn : function (__sec, __playback="oneshot", __delay=0) {
		var _stepEvent =  method(undefined, function(__var, __result) {
			var _backid = layer_background_get_id(__var);
			layer_background_blend(_backid, __result);
		});
		//keyframes
		var _keyframes = [
			[method(undefined, backSeq_sprite
			), 0],//timing(0~1)	
		];
		return [new GPUBease(_stepEvent, global.GPUBsystem.backimg.current, #ffffff, #000000, __sec, "Linear_R",  __playback, _keyframes, __delay)];
	},
	fadeIn : function (__sec, __playback="oneshot", __delay=0) {
		//step event function
		var _stepEvent =  method(undefined, function(__var, __result) {
			var _backid = layer_background_get_id(__var);
			layer_background_alpha(_backid, __result);
		});
		//keyframes
		var _keyframes = [
			[method(undefined, backSeq_sprite
			), 0],//timing(0~1)	
		];
		return [new GPUBease(_stepEvent, global.GPUBsystem.backimg.current, 0, 1, __sec, "Linear",  __playback, _keyframes, __delay)];
	},
	fadeZoomIn : function(__sec, __playback="oneshot", __delay=0) {
		//step event function
		var _stepEvent =  method(undefined, function(__var, __result) {
			var _backid = layer_background_get_id(__var);
			var _img = layer_background_get_sprite(_backid);
			
			layer_background_alpha(_backid, __result[2]);
			
			if (sprite_exists(_img)) {
				var _viewport = [camera_get_view_width(camera_get_active())*0.5, camera_get_view_height(camera_get_active())*0.5];
				var _imginfo = sprite_get_info(_img);
				var _scale = max(room_width/_imginfo.width, room_height/_imginfo.height);

				var _offset = [
					_viewport[0] - _imginfo.xoffset * _scale * __result[0],
					_viewport[1] - _imginfo.yoffset * _scale * __result[1],
				]
				layer_x(global.GPUBsystem.backimg.current, _offset[0]);
				layer_y(global.GPUBsystem.backimg.current, _offset[1]);
				layer_background_xscale(_backid, __result[0] * _scale);
				layer_background_yscale(_backid, __result[1] * _scale);
			}
		});
		//keyframes
		var _keyframes = [
			[method(undefined, backSeq_sprite
			), 0],//timing(0~1)	
		];
		return [new GPUBease(_stepEvent, global.GPUBsystem.backimg.current, [2,2,0], [1,1,1], __sec, "Ease_Out", __playback, _keyframes, __delay)];
	},
}
GPUBease.node = {
	fadeIn : function (__node, __sec, __playback="oneshot", __key=[], __delay=0) {
		return [new GPUBease(__node, "alpha", 0, 1, __sec, "Linear", __playback, __key, __delay)];
	},
	fadeOut : function (__node, __sec, __playback="oneshot", __key=[], __delay=0) {
		return [new GPUBease(__node, "alpha", 1, 0, __sec, "Linear", __playback, __key, __delay)];
	},
	expand : function (__node, __sec, __playback="oneshot", __key=[], __delay=0) {
		return [
			new GPUBease(__node.scale, "x", 0, 1, __sec, "Back_Out", __playback, [], __delay),
			new GPUBease(__node.scale, "y", 0, 1, __sec, "Back_Out", __playback, __key, __delay)
		];
	},
	shrink : function (__node, __sec, __playback="oneshot", __key=[], __delay=0) {
		//step event function
		var _stepEvent =  method(__node, function(__var, __result) {
			scale.x = __result;
			scale.y = __result;
		});
		return [
			new GPUBease(_stepEvent, 0, 1, 0, __sec, "Back_In", __playback, __delay),
		];
	},
	popUp_vertical : function (__node, __sec, __playback="oneshot", __key=[], __delay=0) {
		return [new GPUBease(__node.euler, "y", 90, 0, __sec, "Elastic_In", __playback, __key, __delay)];
	},
	popUp_horizon : function (__node, __sec, __playback="oneshot", __key=[], __delay=0) {
		return [new GPUBease(__node.euler, "x", 90, 0, __sec, "Elastic_In", __playback, __key, __delay)];
	},
	greet : function (__node, __sec, __playback="oneshot", __key=[], __delay=0) {
		return [new GPUBease(__node.position, "y", 0, 50, __sec, "Linear_R", __playback, __delay)];
	},
	struggle: function (__node, __sec, __playback="oneshot", __key=[], __delay=0) {
		//step event function
		var _stepEvent =  method(__node, function(__var, __result) {
			position.x = random_range(-__result, __result);
			position.y = random_range(-__result, __result);
		});
		return [
			new GPUBease(_stepEvent, 0, 0, 50, __sec, "Linear_R", __playback, __delay),
		];
	},
}
