enum Const
{
POSITION = 0,
DIRECTION = 1,
SCALE = 2,
PROJECTION = 3,
DEFAULT = 4,

X = 0,
Y = 1,
Z = 2,
W = 3,

MX = 3,
MY = 7,
MZ = 11,
MW = 15,

X1 = 0,
Y1 = 1,
X2 = 2,
Y2 = 3,
};

/**
 * Function Description
 * @param {any} m Description
 * @return {Array<Real>} Description
 */
function matrix_inverse(m = matrix_build_identity()) {
	if (is_array(m) && array_length(m) == 16) {
		var inv = [
			 m[5] * m[10] * m[15] - m[5] * m[11] * m[14] - m[9] * m[6] * m[15] + m[9] * m[7] * m[14] + m[13] * m[6] * m[11] - m[13] * m[7] * m[10],
			-m[1] * m[10] * m[15] + m[1] * m[11] * m[14] + m[9] * m[2] * m[15] - m[9] * m[3] * m[14] - m[13] * m[2] * m[11] + m[13] * m[3] * m[10],
			 m[1] * m[ 6] * m[15] - m[1] * m[ 7] * m[14] - m[5] * m[2] * m[15] + m[5] * m[3] * m[14] + m[13] * m[2] * m[ 7] - m[13] * m[3] * m[ 6],
			-m[1] * m[ 6] * m[11] + m[1] * m[ 7] * m[10] + m[5] * m[2] * m[11] - m[5] * m[3] * m[10] - m[ 9] * m[2] * m[ 7] + m[ 9] * m[3] * m[ 6],
			-m[4] * m[10] * m[15] + m[4] * m[11] * m[14] + m[8] * m[6] * m[15] - m[8] * m[7] * m[14] - m[12] * m[6] * m[11] + m[12] * m[7] * m[10],
			 m[0] * m[10] * m[15] - m[0] * m[11] * m[14] - m[8] * m[2] * m[15] + m[8] * m[3] * m[14] + m[12] * m[2] * m[11] - m[12] * m[3] * m[10],
			-m[0] * m[ 6] * m[15] + m[0] * m[ 7] * m[14] + m[4] * m[2] * m[15] - m[4] * m[3] * m[14] - m[12] * m[2] * m[ 7] + m[12] * m[3] * m[ 6],
			 m[0] * m[ 6] * m[11] - m[0] * m[ 7] * m[10] - m[4] * m[2] * m[11] + m[4] * m[3] * m[10] + m[ 8] * m[2] * m[ 7] - m[ 8] * m[3] * m[ 6],
			 m[4] * m[ 9] * m[15] - m[4] * m[11] * m[13] - m[8] * m[5] * m[15] + m[8] * m[7] * m[13] + m[12] * m[5] * m[11] - m[12] * m[7] * m[ 9],
			-m[0] * m[ 9] * m[15] + m[0] * m[11] * m[13] + m[8] * m[1] * m[15] - m[8] * m[3] * m[13] - m[12] * m[1] * m[11] + m[12] * m[3] * m[ 9],
			 m[0] * m[ 5] * m[15] - m[0] * m[ 7] * m[13] - m[4] * m[1] * m[15] + m[4] * m[3] * m[13] + m[12] * m[1] * m[ 7] - m[12] * m[3] * m[ 5],
			-m[0] * m[ 5] * m[11] + m[0] * m[ 7] * m[ 9] + m[4] * m[1] * m[11] - m[4] * m[3] * m[ 9] - m[ 8] * m[1] * m[ 7] + m[ 8] * m[3] * m[ 5],
			-m[4] * m[ 9] * m[14] + m[4] * m[10] * m[13] + m[8] * m[5] * m[14] - m[8] * m[6] * m[13] - m[12] * m[5] * m[10] + m[12] * m[6] * m[ 9],
			 m[0] * m[ 9] * m[14] - m[0] * m[10] * m[13] - m[8] * m[1] * m[14] + m[8] * m[2] * m[13] + m[12] * m[1] * m[10] - m[12] * m[2] * m[ 9],
			-m[0] * m[ 5] * m[14] + m[0] * m[ 6] * m[13] + m[4] * m[1] * m[14] - m[4] * m[2] * m[13] - m[12] * m[1] * m[ 6] + m[12] * m[2] * m[ 5],
			 m[0] * m[ 5] * m[10] - m[0] * m[ 6] * m[ 9] - m[4] * m[1] * m[10] + m[4] * m[2] * m[ 9] + m[ 8] * m[1] * m[ 6] - m[ 8] * m[2] * m[ 5]
		];
		
		var det = m[0] * inv[0] + m[1] * inv[4] + m[2] * inv[8] + m[3] * inv[12];
		
		if (det == 0) {
			show_debug_message($"{id} : no veiled inverse!");
			return m;
			}
		
		var epsilon = 0.000001; // 행렬식이 너무 작을 경우를 위한 임계값
        if (abs(det) < epsilon) {
            show_debug_message($"{id} : Matrix is singular or near singular, cannot invert!");
            return m;
        }
		
		det = 1.0 / det;
		
		for (var _a=0; _a<16; _a++) {
			inv[_a] = inv[_a] * det;
		}
		
		return inv;

	} else {
		show_debug_message($"{id} : wrong matrix input!");
		return m;
		};
}

/**
 * Converts screen x, y coordinates to 3D coordinates on the z-plane.
 * @param {Real} __x The x-coordinate on the screen.
 * @param {Real} __y The y-coordinate on the screen.
 * @param {Camera} __vid The camera to use for the conversion.
 * @returns {Vec3} A 3D coordinate [x, y, z] on the z-plane.
 */
function convertPoint2Dto3D (__x, __y, __vid = matrix_build_identity(), __area = [display_get_gui_width(), display_get_gui_height()]) {
    
	var _invMtrx = matrix_inverse(__vid);

	// Normalized Device Coordinates (_ndc)
    var _ndc = [
		(2 * __x) / __area[Const.X] - 1,
        (2 * __y) / __area[Const.Y] - 1
	];
	
    // Calculate the near and far points in world space
	var _vecNear = new Vec4(_ndc[Const.X], _ndc[Const.Y], 0, 1);
	var _vecFar = new Vec4(_ndc[Const.X], _ndc[Const.Y], 1, 1);
    var rayNear = matrix_multiply(_invMtrx, Vec4.ToMatrix(_vecNear,Const.DEFAULT));
    var rayFar = matrix_multiply(_invMtrx, Vec4.ToMatrix(_vecFar,Const.DEFAULT));

	///matrix to array3
    rayNear = (rayNear[Const.MW] != 0) ? [rayNear[Const.MX] / rayNear[Const.MW], rayNear[Const.MY] / rayNear[Const.MW], rayNear[Const.MZ] / rayNear[Const.MW]] : [rayNear[Const.MX], rayNear[Const.MY], rayNear[Const.MZ]];
    rayFar =  (rayFar[Const.MW] != 0) ? [ rayFar[Const.MY] /  rayFar[Const.MW], rayFar[Const.MY] /  rayFar[Const.MW],  rayFar[Const.MZ] /  rayFar[Const.MW]]  : [rayFar[Const.MX],  rayFar[Const.MY],  rayFar[Const.MZ]];

	//aspect
    var aspect = rayFar[Const.Z] - rayNear[Const.Z];
    if (aspect != 0) {
		aspect = (-rayNear[Const.Z]) / aspect;
		}

    var worldPos = new Vec3(
        lerp(rayNear[Const.X], rayFar[Const.X], aspect),
        lerp(rayNear[Const.Y], rayFar[Const.Y], aspect),
        lerp(rayNear[Const.Z], rayFar[Const.Z], aspect)
    );

    return worldPos;
};


function debug_crosshair (__x, __y, __size, __color = c_white) {
	draw_line_color(__x, __y-__size, __x, __y+__size, __color, __color); 
	draw_line_color(__x-__size, __y,  __x+__size, __y, __color, __color); 
}