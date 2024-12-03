/// @description GPUB Basic usage
//show_debug_overlay(true);
GPUB.Func.Init();
//GPUB.Func.Load();
/*
variable_struct_set(global.GPUBsystem.scene, "scene0001", new GPUBscene
	(
	//element
		{
			name : "설명꾼\nABC",
			box : "GPUB_default",
			tagbox : "GPUB_nametag",
			speed : 10,
			padding : [20,40,-20,-20],
		},
	//text
		[
			"hello. how are you been?",
			["scnWait",[0.5]],
			["scnSpeed",[6]],
			"\nI'm living in Korea.",
			["scnWait",[]],
			["scnClear",[]],
			["scnSpeed",[]],
			"wait second...",
			["scnWait",[3]],
			["scnSpeed",[50]],
			"\ndone.",
			["backImg",[ "GPUB_backimg", "fadeZoomIn", 2 ]],
			["scnSpeed",[]],
			["scnWait",[]],
			"\n한국어로 말해보자.",
			["scnWait",[]],
			["cssStyle",[{color : [ #ff0000, #ff0000, #ff0000, #ff0000 ]}]],
			"\n'cssStyle' 명령어로 폰트 속성을 바꿀 수 있다.",
			["scnWait",[]],
			["cssStyle",[]],
			"\n이번에는 'select' 기능을 써보자.",
			["scnWait",[]],
			["scnClear",[]],
			"선택지를 골라보자. 무슨 색을 좋아해?",
			["scnSelect",[ "select0001" ]]
		]
	)
);

variable_struct_set(global.GPUBsystem.scene, "select0001", new GPUBselect
	(
		//element
		{
			button : ["GPUB_button"],
			css : ["GPUB_nametag"],
			row : 1,//row 
			area : "GPUB_select"
		},
		[//[text, box, css, flag, excute] 
			"빨강", 0, 0, "", ["scnGoto",[ "scene0002_red",    1, 1 ]],
			"노랑", 0, 0, "", ["scnGoto",[ "scene0002_yellow", 1, 1 ]],
			"파랑", 0, 0, "", ["scnGoto",[ "scene0002_blue",   1, 1 ]], 
			"검정", 0, 0, "", ["scnGoto",[ "scene0002_black",  1, 1 ]],
		]
	)
);

variable_struct_set(global.GPUBsystem.scene, "scene0002_black", new GPUBscene
	(
	//element
		{
			name : "설명꾼\nABC",
			box : "GPUB_default",
			tagbox : "GPUB_nametag",
			speed : 10,
			padding : [20,40,-20,-20],
		},
	//text
		[
			["flagSet", ["color", "black"]],
			["cssStyle",[{color : [ #000000,#000000,#000000,#000000 ]}]],
			"검정",
			["cssStyle",[]],
			["backColor", [ #333333, 1, "Circ_In" ]],
			"을 골랐구나?",
			["scnWait",[]],
			["scnGoto",["scene0003"]]
		]
	)
);

variable_struct_set(global.GPUBsystem.scene, "scene0002_blue", new GPUBscene
	(
	//element
		{
			name : "설명꾼\nABC",
			box : "GPUB_default",
			tagbox : "GPUB_nametag",
			speed : 10,
			padding : [20,40,-20,-20],
		},
	//text
		[
			["flagSet", ["color", "blue"]],
			["cssStyle",[{color : [ #0000ff,#0000ff,#0000ff,#0000ff ]}]],
			"파랑",
			["cssStyle",[]],
			["backColor", [ #3333ff, 1, "Circ_In" ]],
			"을 골랐구나?",
			["scnWait",[]],
			["scnGoto",["scene0003"]]			
		]
	)
);

variable_struct_set(global.GPUBsystem.scene, "scene0002_red", new GPUBscene
	(
	//element
		{
			name : "설명꾼\nABC",
			box : "GPUB_default",
			tagbox : "GPUB_nametag",
			speed : 10,
			padding : [20,40,-20,-20],
		},
	//text
		[
			["flagSet", ["color", "red"]],
			["cssStyle",[{color : [ #ff0000,#ff0000,#ff0000,#ff0000 ]}]],
			"빨강",
			["cssStyle",[]],
			["backColor", [ #ff3333,  1, "Circ_In" ]],
			"을 골랐구나?",
			["scnWait",[]],
			["scnGoto",["scene0003"]]
		]
	)
);

variable_struct_set(global.GPUBsystem.scene, "scene0002_yellow", new GPUBscene
	(
	//element
		{
			name : "설명꾼\nABC",
			box : "GPUB_default",
			tagbox : "GPUB_nametag",
			speed : 10,
			padding : [20,40,-20,-20],
		},
	//text
		[
			["flagSet", ["color", "yellow"]],
			["cssStyle",[{color : [ #ffff00,#ffff00,#ffff00,#ffff00 ]}]],
			"노랑",
			["cssStyle",[]],
			["backColor", [ #ffff33, 1, "Circ_In" ]],
			"을 골랐구나?",
			["scnWait",[]],
			["scnGoto",["scene0003"]]
		]
	)
);

variable_struct_set(global.GPUBsystem.scene, "scene0003", new GPUBscene
	(
	//element
		{
			name : "설명꾼\nABC",
			box : "GPUB_default",
			tagbox : "GPUB_nametag",
			speed : 10,
			padding : [20,40,-20,-20],
		},
	//text
		[
			["backMove", [ -30, 0, 1, 5, "Ease_InOut" ]],
			"당신이 정한 색깔로 배경 색이 바뀌었어.",
			["scnWait",[]],
			"\n꽤 괜찮지?",
			["scnWait",[]],
			["flagIf",["color", "red"]],
				["cssStyle",[{color : [ #ff0000,#ff0000,#ff0000,#ff0000 ]}]],
				"\n붉게 물든 게 암실 들어온 기분이야.",
				["cssStyle",[]],
			["flagEnd", []],
			["flagIf",["color", "black"]],
				["cssStyle",[{color : [ #000000,#000000,#000000,#000000 ]}]],
				"\n어두컴컴한 게 취향이야?",
				["cssStyle",[]],
			["flagEnd", []],
			["flagIf",["color", "blue"]],
				["cssStyle",[{color : [ #0000ff,#0000ff,#0000ff,#0000ff ]}]],
				"\n바닷 속에 들어온 기분이네.",
				["cssStyle",[]],
			["flagEnd", []],
			["flagIf",["color", "yellow"]],
				["cssStyle",[{color : [ #ffff00,#ffff00,#ffff00,#ffff00 ]}]],
				"\n왠지 더운 것 같지 않아?",
				["cssStyle",[]],
			["flagEnd", []],
			["scnWait",[]],
			["scnGoto",["scene0004"]]
		]
	)
);

variable_struct_set(global.GPUBsystem.scene, "scene0004", new GPUBscene
	(
	//element
		{
			name : "설명꾼\nABC",
			box : "GPUB_default",
			tagbox : "GPUB_nametag",
			speed : 10,
			padding : [20,40,-20,-20],
		},
	//text
		[
			["mobAdd",["GPUB_default", "speakerABC", 2, "fadeIn"]],
			["scnWait",[4]],
			"슬슬 얼굴 보고 인사하자.",
			["scnWait",[]],
			"내가 바로 설명꾼이야.",
			["mobAct",["speakerABC", 0.2, "struggle"]],
			["scnWait",[]],
			["mobDelete",["speakerABC", 2, "fadeOut"]],
			["scnWait",[]],
			["scnGoto",["scene0005"]]
		]
	)
);

GPUB.Act.Start("scene0001");
*/