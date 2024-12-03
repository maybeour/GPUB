/*constructors*/
/*GPUB - GPUB 시스템의 최상위 관리 구조체*/
function GPUB(__hash = {}) constructor {
	
	//GPUB resource ref librery
	self.img = {
		GPUB_default : new GPUB.Node.Img(),
		GPUB_backimg : new GPUB.Node.Img({
			img : "spr_GPUBbackimg_0001",
			anchor : [0.5, 0.5],
			}),
	};
	self.mob = {
		GPUB_default : new GPUB.Node.Mob({
			img : "spr_GPUBimg_mob",
			subimg : {
				speak : [false, 00, 20, 0],//it's almost fixed range.
				blink : [false, 21, 25, 0],
				angry : [false, 26, 26, 0],
				happy : [false, 27, 27, 0],
				sad   : [false, 28, 28, 0],
				fear  : [false, 29, 29, 0],
			},//speak,blink,angry,happy,sad,fear,etc....(naming whatever you want)
		}),
	};
	self.audio = {
		GPUB_default : undefined,
	};
	self.shader = {
		GPUB_default : sh_GPUBdefault,
	};
	self.css = {
		GPUB_default : new GPUB.Node.Css({
			anchor : [0,0],
			areaUV : [0,0,0,0],
			areaPX : [0,0,0,0],
			font : "fnt_GPUBdefault",
			animAwake : ["expand",0.1, ],
		}),
		GPUB_nametag : new GPUB.Node.Css({
			align : ["fa_center","fa_middle"],
			anchor : [0.5,0.5],
			center : [0.5,0.5],
			areaUV : [-0.5,-0.5,0.5,0.5],
			areaPX : [10,10,-10,-10],
			font : "fnt_GPUBdefault"
		})
	};
	self.box = {
		GPUB_default : new GPUB.Node.Box({
			img : "spr_VUI_DefaultFrame",
			anchor : [0.5,1],
			areaUV : [-0.45,-0.36,0.45,0],
			areaPX : [10,0,-10,-10],
			color : #ffffff,
			animAwake : ["fadeIn", 1],
			animSleep : ["fadeOut", 1]
		}),
		GPUB_nametag : new GPUB.Node.Box({
			img : "spr_GPUBimg_nametag",
			anchor : [0,0],
			areaUV : [0,0,0,0],
			areaPX : [10,-30,200,30],
			color : #ffffff,
			animAwake : ["fadeIn", 1],
			animSleep : ["fadeOut", 1]
		}),
		GPUB_select : new GPUB.Node.Box({
			img : "spr_GPUBimg_default",
			anchor : [0.5,0.4],
			areaUV : [0,0,0,0],
			areaPX : [-200,-100,200,100],
			color : #ffffff,
			alpha : 1,
			animAwake : ["fadeIn", 1],
			animSleep : ["fadeOut", 1]
		}),
		GPUB_button : new GPUB.Node.Box({
			img : "spr_GPUBimg_button",
			anchor : [0.5,0.5],
			areaUV : [0,0,0,0],
			areaPX : [-100,-20,100,20],
			color : #ffffff,
			alpha : 1,
			animAwake : ["fadeIn", 1],
			animSleep : ["fadeOut", 1]
		}),
	};
	self.fx = {
		
	}
	self.chapter = [];
	
	//identity
	self.id = "GPUB_undefined";//GPUB 파일 고유 식별자	
	self.title = "GPUB TITLE";//GPUB 파일 제목
	self.author = {};//GPUB 제작 공여 개인 또는 단체명
	self.scene = {};//GPUB 챕터 구성 씬 목록
	self.sceneQueue = ds_priority_create();//GPUB 챕터 구성 씬 드로잉 우선도 목록
	self.flag = {};//GPUB 파일 변수 목록
	
	//layers
	//1.mobLayer
	self.mobLayer = layer_get_id("GPUBlayer_mob");
	layer_set_visible(self.mobLayer, true);
	self.mobElement = ds_map_create();
	
	//2.back
	self.backimg = {
		prev : layer_get_id("GPUBlayer_back_prev"),
		current : layer_get_id("GPUBlayer_back_now"),
		img : -1,
	};
	
	//mini struct animator list
	self.ease = ds_list_create();

	//static
	static fname = "";
	static outdir = working_directory;
	static timeflow = 10; // text speed default
	static debug = 0; //debug switch
	static tic = delta_time / 1000000;
	static scene = undefined;	
}

GPUB.Func = {
	//Init algorithm 
	Init : function(__hash = {}, __userid = "test") {
		if (!variable_global_exists("GPUBsystem") || !is_instanceof(global.GPUBsystem, GPUB)) {
			global.GPUBsystem = new GPUB(__hash);
			
			if (!layer_exists("GPUB_system")) layer_create(0, "GPUB_system");
			return global.GPUBsystem;
			
		} else return global.GPUBsystem;
	},
	
	//file save
	Save : function(__file = "") {
		
	},
	
	//file load
	Load : function(__hash = undefined) {
		
		if (is_undefined(__hash)) __hash = GPUB.Web.localOpen();
		
		//img
		if (is_struct(__hash[$ "img"])) {
			var _imglist = struct_get_names(__hash.img);
			for (var _a=0; _a<array_length(_imglist); _a++) {
				if (is_struct(__hash.img[$ _imglist[_a]])) {
					variable_struct_set(global.GPUBsystem.img, _imglist[_a], new GPUB.Node.Img(__hash.img[$ _imglist[_a]]));
				}
			}
			show_debug_message($"{ptr(global.GPUBsystem)} : IMG resource call finished \n {global.GPUBsystem.img}");
		}
		//mob
		if (is_struct(__hash[$ "mob"])) {
			var _moblist = struct_get_names(__hash.mob);
			for (var _a=0; _a<array_length(_moblist); _a++) {
				if (is_struct(__hash.mob[$ _moblist[_a]])) {
					variable_struct_set(global.GPUBsystem.mob, _moblist[_a], new GPUB.Node.Mob(__hash.mob[$ _moblist[_a]]));
				}
			}
			show_debug_message($"{ptr(global.GPUBsystem)} : MOB resource call finished \n {global.GPUBsystem.mob}");
		}
		//shader
		if (is_struct(__hash[$ "shader"])) {
			var _shlist = struct_get_names(__hash.shader);
			for (var _a=0; _a<array_length(_shlist); _a++) {
				if (asset_get_type(__hash.shader[$ _shlist[_a]]) == asset_shader) {
					variable_struct_set(global.GPUBsystem.shader, _shlist[_a], asset_get_index(__hash.shader[$ _shlist[_a]]));
				} else {
					variable_struct_set(global.GPUBsystem.shader, _shlist[_a], sh_GPUBdefault);
				}
			}
			show_debug_message($"{ptr(global.GPUBsystem)} : SHADER resource call finished. \n {global.GPUBsystem.shader}");
		}
		//css
		if (is_struct(__hash[$ "css"])) {
			var _csslist = struct_get_names(__hash.css);
			for (var _a=0; _a<array_length(_csslist); _a++) {
				if (is_struct(__hash.css[$ _csslist[_a]])) {
					variable_struct_set(global.GPUBsystem.css, _csslist[_a], new GPUB.Node.Css(__hash.css[$ _csslist[_a]]));
				}
			}
			show_debug_message($"{ptr(global.GPUBsystem)} : CSS resource call finished. \n {global.GPUBsystem.css}");
		}
		//box
		if (is_struct(__hash[$ "box"])) {
			var _boxlist = struct_get_names(__hash.box);
			for (var _a=0; _a<array_length(_boxlist); _a++) {
				if (is_struct(__hash.box[$ _boxlist[_a]])) {
					variable_struct_set(global.GPUBsystem.box, _boxlist[_a], new GPUB.Node.Box(__hash.box[$ _boxlist[_a]]));
				}
			}
			show_debug_message($"{ptr(global.GPUBsystem)} : BOX resource call finished. \n {global.GPUBsystem.box}");
		}
		//fx
		if (is_struct(__hash[$ "fx"])) {
			var _fxlist = struct_get_names(__hash.fx);
			for (var _a=0; _a<array_length(_fxlist); _a++) {
				if (is_struct(__hash.fx[$ _fxlist[_a]])) {
					variable_struct_set(global.GPUBsystem.fx, _fxlist[_a], new GPUB.Node.Fx(__hash.fx[$ _fxlist[_a]]));
				}
			}
			show_debug_message($"{ptr(global.GPUBsystem)} : FX resource call finished. \n {global.GPUBsystem.fx}");		
		}
		//chapter
		if (is_array(__hash[$ "chapter"])) {
			global.GPUBsystem.chapter = __hash.chapter;
		}
		
		global.GPUBsystem.id = is_string(__hash[$ "id"])? __hash[$ "id"] : "GPUB_undefined";//GPUB 파일 고유 식별자	
		global.GPUBsystem.title = is_string(__hash[$ "title"])? __hash[$ "title"] : "GPUB TITLE";//GPUB 파일 제목
		global.GPUBsystem.author = is_struct(__hash[$ "author"])? __hash[$ "author"] : {};//GPUB 제작 공여 개인 또는 단체명
		global.GPUBsystem.flag = is_struct(__hash[$ "flag"])? __hash[$ "flag"] : {};//GPUB 파일 변수 목록
	},
	
	//GPUB Reset
	Reset : function() {
		delete global.GPUBsystem.scene; global.GPUBsystem.scene = {};
		ds_map_destroy(global.GPUBsystem.mobElement);
		ds_list_destroy(global.GPUBsystem.ease);
		ds_priority_destroy(global.GPUBsystem.sceneQueue);
		gc_collect();
	},
	
	//GPUB Chapter set
	Chapter : function(__index) {
		if (array_length(global.GPUBsystem.chapter) <= __index) {
			show_debug_message($"{ptr(global.GPUBsystem)} : chapter loadding failed - index is outbound array.");
		}
		var _scnFile = file_text_open_read(global.GPUBsystem.Chapter[__index]);
		var _scnStr = file_text_read_string(_scnFile);
		file_text_close(_scnFile);
		
		delete global.GPUBsystem.scene;
		global.GPUBsystem.scene = json_parse(_scnStr);
	},
}

/*GPUBScene 전역 이벤트*/
GPUB.Act = {

	Start : function(__scene = "") {
		if (is_struct(global.GPUBsystem[$ "scene"])) {
			if (is_instanceof(global.GPUBsystem.scene[$ __scene], GPUBscene)) {
				global.GPUBsystem.scene[$ __scene].Awake(0);
			}
		}
	},
	
	Routine : function() {
		GPUB.tic = delta_time / 1000000;
		//ease update
		var _ease1 = ds_list_size(global.GPUBsystem.ease);
		for (var _e=0; _e<_ease1; _e++) {
			GPUBease.Update(global.GPUBsystem.ease[| _e]);
		}
		//scene
		if (is_struct(global.GPUBsystem[$ "scene"])) {
			var _allscene = struct_get_names(global.GPUBsystem.scene);
			var _allcount = struct_names_count(global.GPUBsystem.scene);
			for (var _i=0; _i<_allcount; _i++) {
				global.GPUBsystem.scene[$ _allscene[@ _i]].Routine();
			}	
		}
	},
	
	Draw : function() {
		//scene draw
		if (is_struct(global.GPUBsystem[$ "scene"]) && ds_exists(global.GPUBsystem[$ "sceneQueue"], ds_type_priority)) {
			var _allscene = struct_get_names(global.GPUBsystem.scene);
			var _allcount = struct_names_count(global.GPUBsystem.scene);
			for (var _i=0; _i<array_length(_allscene); _i++) {
				var _targetScene = global.GPUBsystem.scene[$ _allscene[@ _i]];
				ds_priority_add(global.GPUBsystem.sceneQueue, _targetScene, _targetScene.depth);
			}	
			//draw by Queue
			while (!ds_priority_empty(global.GPUBsystem.sceneQueue)) {
				var _qdraw = ds_priority_find_max(global.GPUBsystem.sceneQueue);
				_qdraw.Draw();
				ds_priority_delete_value(global.GPUBsystem.sceneQueue, _qdraw);
			}
		}
	},
	
	Trigger : function() {
		//ease update
		var _ease1 = ds_list_size(global.GPUBsystem.ease);
		for (var _e=0; _e<_ease1; _e++) {
			GPUBease.Skip(global.GPUBsystem.ease[| _e]);
		}
		//scene
		if (is_struct(global.GPUBsystem[$ "scene"]) && ds_exists(global.GPUBsystem[$ "sceneQueue"], ds_type_priority)) {
			var _allscene = struct_get_names(global.GPUBsystem.scene);
			var _allcount = struct_names_count(global.GPUBsystem.scene);
			for (var _i=0; _i<array_length(_allscene); _i++) {
				var _targetScene = global.GPUBsystem.scene[$ _allscene[@ _i]];
				ds_priority_add(global.GPUBsystem.sceneQueue, _targetScene, _targetScene.depth);
			}	
			//trigger by Queue
			while (!ds_priority_empty(global.GPUBsystem.sceneQueue)) {
				var _qdraw = ds_priority_find_min(global.GPUBsystem.sceneQueue);
				var _isactivate = _qdraw.Trigger();
				if (_isactivate) {
					ds_priority_clear(global.GPUBsystem.sceneQueue);
					break;
				}else ds_priority_delete_value(global.GPUBsystem.sceneQueue, _qdraw);
			}
		}
	}
}

/*GPUBScene 웹통신 이벤트*/
GPUB.Web = {
	id : "GPUBTest",
	server : "https://127.0.0.1/",
	download : function (__url, __dir) {
		if (!file_exists(__dir)) http_get_file(__url,__dir);
	},
	//file load
	localOpen : function() {
		var _dir = get_open_filename("GPUB file|*.gpub", "");
		if (! file_exists(_dir)) {
			show_debug_message($"{ptr(self)} : GPUB file loading failed - non exist file.");
			return;
		}
		GPUB.fname = filename_name(_dir);
		GPUB.outdir = working_directory + GPUB.Web.id + "/" + GPUB.fname + "/";
		var _output = zip_unzip(_dir, GPUB.outdir);
		if (_output < 0) {
			show_debug_message($"{ptr(self)} : GPUB file loading failed.");
			return;
		}
		var _json = file_text_open_read(GPUB.outdir + "/master.json");
		if (_json == -1) {
			return;
		}
		return json_parse(_json);
	},
}

GPUB.Resource = {
	img : function(__dir) {
		//check
		if (!file_exists(__dir)) return;
		
		//read Info
		var _infotext = file_text_open_read(__dir + ".info");
		if (is_undefined(_infotext)) {
			show_debug_message($"{ptr(self)} : Sprite loading faild - {__dir} has no infomation file.");
			return;
		}
		var _info = json_parse(file_text_read_string(_infotext));
		file_text_close(_infotext);
		
		//image load
		var _loadImg = sprite_add(__dir, _info.num_subimages, _info.transparent, _info.smooth, _info.xoffset, _info.yoffset);
		if (_info.type == 0) {
			if (struct_exists( _info, "nineslice")) sprite_set_nineslice(_loadImg, _info.nineslice);
			sprite_set_bbox(_loadImg, _info.bbox_left, _info.bbox_top, _info.bbox_right, _info.bbox_bottom);
		} 
		show_debug_message($"{ptr(global.GPUBsystem)} : Sprite loaded - {sprite_get_name(_loadImg)}.");
		asset_add_tags(_loadImg, ["GPUBpack", global.GPUBsystem.id], asset_sprite);
		delete _info;
		return _loadImg;
		
	},
	audio : function(__dir) {
		//check
		if (!file_exists(__dir)) return;
		
		//audio load
		var _loadSnd = audio_create_stream(__dir);
		show_debug_message($"{ptr(global.GPUBsystem)} : Audio loaded - {font_get_name(_loadSnd)}.");
		asset_add_tags(_loadSnd, ["GPUBpack", global.GPUBsystem.id], asset_sound);
		return _loadSnd;
	},
	font : function(__dir) {
		if (!file_exists(__dir)) return;
		
		//read Info
		var _infotext = file_text_open_read(__dir + ".info");
		if (is_undefined(_infotext)) {
			show_debug_message($"{ptr(self)} : Sprite loading faild - {__dir} has no infomation file.");
			return;
		}
		var _info = json_parse(file_text_read_string(_infotext));
		file_text_close(_infotext);
		
		//font loading
		var _loadFnt = font_add(__dif, _info.size, _info.bold, _info.italic, 32, 128);
		show_debug_message($"{ptr(global.GPUBsystem)} : Font loaded - {font_get_name(_loadFnt)}.");
		asset_add_tags(_loadFnt, ["GPUBpack", global.GPUBsystem.id], asset_font);
		delete _info;
		return _loadFnt;
	},
}