/// @description VUI Test Object setting
// 이 에디터에 코드를 작성할 수 있습니다

class1 = new Rect({
	anchor : [0.2 ,0.5],
	areaUV : [-0.1,-0.4,0.7,0.4],
	color : c_white,
	}
	);
	
class2 = new Rect({
	anchor : [0 ,0],
	areaUV : [0,0,0,0],
	areaPX : [0,-30,80,30],
	color : c_aqua,
	},
	class1
	);
	
_target = class1;