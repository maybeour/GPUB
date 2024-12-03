var __x = x + subTransform.position.x;
var __y = y + subTransform.position.y;
//var __z = subTransform.position.z;
var __sx = image_xscale * subTransform.scale.x;
var __sy = image_yscale * subTransform.scale.x;
var __r = image_angle + subTransform.euler.z;
var __a = image_alpha * subTransform.alpha;
var __c = subTransform.color[0];

//draw self
draw_sprite_ext(sprite_index, 0, __x, __y, __sx, __sy, __r, __c, __a);

//draw subimg
if (is_struct(subimg)) {
	var _sn = struct_get_names(subimg);
	var _sc = struct_names_count(subimg);
	
	for (var _i=0; _i<_sc; _i++) {
		if (is_array(subimg[$ _sn[_i]])) {
			if (_sn[_i] == "speak") continue;
			if (subimg[$ _sn[_i]][0]) {
				if (++subimg[$ _sn[_i]][3] > subimg[$ _sn[_i]][2] || subimg[$ _sn[_i]][3] < subimg[$ _sn[_i]][1]) {
					subimg[$ _sn[_i]][3] = subimg[$ _sn[_i]][1];
				}
				draw_sprite_ext(sprite_index, subimg[$ _sn[_i]][3], __x, __y, __sx, __sy, __r, __c, __a);
			}
		}
	}
	//subimg = [visible, start index, end index, current index]
}
