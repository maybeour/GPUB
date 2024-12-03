/// @description VUI Draw Test

Rect.DebugDraw(class1);
Rect.DebugDraw(class2);

//draw_rectangle_color(10,10,display_get_gui_width()-10,display_get_gui_height()-10,c_white,c_white,c_white,c_white,0);

if (keyboard_check_pressed(vk_enter)) {
	_target = (_target == class1)? class2 : class1;
}

if (mouse_wheel_down()) {
	_target.scale.x+=0.01;
	_target.scale.y+=0.01;
	_target.scale.z+=0.01;
}

if (mouse_wheel_up()) {
	_target.scale.x-=0.01;
	_target.scale.y-=0.01;
	_target.scale.z-=0.01;
}

if (keyboard_check(vk_left)) _target.position.x-=1;
if (keyboard_check(vk_right)) _target.position.x+=1;

if (keyboard_check(vk_up)) _target.position.y-=1;
if (keyboard_check(vk_down)) _target.position.y+=1;

if (keyboard_check(ord("Q"))) _target.euler.z-=1;
if (keyboard_check(ord("E"))) _target.euler.z+=1;

