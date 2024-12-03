/** 
 * @class Vec2
 * @classdesc Represents a 2D Vector.
 * @param {Real} __x - The x-coordinate of the vector.
 * @param {Real} __y - The y-coordinate of the vector.
 */
function Vec2(__x, __y) constructor {
    
    ///@property {Real} x - The x-coordinate of the vector.
    self.x = __x; // x 좌표

    ///@property {Real} y - The y-coordinate of the vector.
    self.y = __y; // y 좌표
  
    /**
	 * @function add
     * @memberof Vec2
	 * @desc Adds the given values to the current vector and returns a new vector.
     * @param {Real} __ax - The value to add to the x-coordinate.
     * @param {Real} __ay - The value to add to the y-coordinate.
     * @returns {Vec2} A new vector with the added values.
	 */
    self.add = function(__ax=0, __ay=0) {
        return new Vec2(self.x + __ax, self.y + __ay);
    };
	/**
     *@function product
     * @memberof Vec2
	 * @desc Calculates the dot product of the current vector with another vector.
     * @param {Vec2} __vec - The vector to calculate the dot product with.
     * @returns {Real} The dot product of the two vectors.
     */
	self.product = function(__vec) {
        return dot_product(self.x, self.y, __vec.x, __vec.y);
    };

    /**
     * @function length
     * @memberof Vec2
	 * @desc Calculates the distance between the current vector and the given coordinates.
     * @param {Real} __x - The x-coordinate to calculate the distance from.
     * @param {Real} __y - The y-coordinate to calculate the distance from.
     * @returns {Real} The distance between the current vector and the given coordinates.
     */
    self.length = function(__x=0, __y=0) {
        return point_distance(__x, __y, self.x, self.y);
    };

    /**
     * @function normal
     * @memberof Vec2
	 * @desc Calculates the unit vector (normalized) from the given coordinates to the current vector.
     * @param {Real} __x - The x-coordinate to calculate the direction from.
     * @param {Real} __y - The y-coordinate to calculate the direction from.
     * @returns {Vec2} A new normalized vector pointing in the direction of the current vector.
     */
    self.normal = function(__x=0, __y=0) {
        var _len = point_distance(__x, __y, self.x, self.y),
            _dir = point_direction(__x, __y, self.x, self.y);
        var _new = [0, 0];
        if (_len != 0) {
            _new[0] = __x + lengthdir_x(1, _dir);
            _new[1] = __y + lengthdir_y(1, _dir);
        }
        return new Vec2(_new[0], _new[1]);
    };

    /**
     * @function serialize
     * @memberof Vec2
	 * @desc Serializes a vector into an array representation.
     * @static
     * @param {Vec2} __vec - The vector to serialize.
     * @returns {Array<Real>} An array representation of the vector [x, y].
     */
    static serialize = function(__vec) {
		if (is_instanceof(__vec, Vec2)) 
		{
			return [__vec.x, __vec.y];
		} else {
			return [0, 0];
		};
    };

	/**
	 * Converts Vec2 to a 4x4 transformation matrix.
	 * @param {Vec2} vec The vector to be converted.
	 * @param {Real} type The type of vector ("position", "direction", "scale").
	 * @returns {Array<Real>} A 4x4 transformation matrix.
	 */
	static ToMatrix = function(vec, type) {
	    if (is_instanceof(vec, Vec2)) {
	        switch (type) {
	            case Const.POSITION:
	                return [
	                    1, 0, 0, vec.x,
	                    0, 1, 0, vec.y,
	                    0, 0, 1, 0,
	                    0, 0, 0, 1
	                ];
	            case Const.DIRECTION:
	                return [
	                    1, 0, 0, 0,
	                    0, 1, 0, 0,
	                    0, 0, 1, 0,
	                    vec.x, vec.y, 0, 0
	                ];
	            case Const.PROJECTION:
	                return [
	                    1, 0, 0, vec.x,
	                    0, 1, 0, vec.y,
	                    0, 0, 1, 0,
	                    0, 0, 0, 1
	                ];
	            case Const.SCALE:
	                return [
	                    vec.x, 0, 0, 0,
	                    0, vec.y, 0, 0,
	                    0, 0, 0, 0,
	                    0, 0, 0, 1
	                ];
	            case Const.DEFAULT://general
	                return [
	                    vec.x, vec.x, vec.x, vec.x,
	                    vec.y, vec.y, vec.y, vec.y,
	                    0, 0, 0, 0,
	                    1, 1, 1, 1
	                ];
	        }
	    } else {
	        return matrix_build_identity();
	    }
	};

    return self;
}

/**
 * @class Vec3
 * @classdesc Represents a 3D Vector, extending Vec2.
 * @extends Vec2
 * @param {Real} __x - The x-coordinate of the vector.
 * @param {Real} __y - The y-coordinate of the vector.
 * @param {Real} __z - The z-coordinate of the vector.
 */
function Vec3(__x, __y, __z) : Vec2(__x, __y) constructor {
    
    self.z = __z; // z 좌표

    self.add = function(__ax=0, __ay=0, __az=0) {
        return new Vec3(self.x + __ax, self.y + __ay, self.z + __az);
    };

    self.product = function(__vec) {
        return dot_product_3d(self.x, self.y, self.z, __vec.x, __vec.y, __vec.z);
    };

    self.length = function(__x=0, __y=0, __z=0) {
        return point_distance_3d(__x, __y, __z, self.x, self.y, self.z);
    };

    self.normal = function(__x=0, __y=0, __z=0) {
        var _len = point_distance_3d(__x, __y, __z, self.x, self.y, self.z),
            _new = [0, 0, 0];
        if (_len != 0) {
            _new[0] = __x + self.x / _len;
            _new[1] = __y + self.y / _len;
            _new[2] = __z + self.z / _len;
        }
        return new Vec3(_new[0], _new[1], _new[2]);
    };


    static serialize = function(__vec) {
        return [__vec.x, __vec.y, __vec.z];
    };

	static ToMatrix = function(vec, type) {
	    if (is_instanceof(vec, Vec3)) {
	        switch (type) {
	            case Const.POSITION:
	                return [
	                    1, 0, 0, vec.x,
	                    0, 1, 0, vec.y,
	                    0, 0, 1, vec.z,
	                    0, 0, 0, 1
	                ];
	            case Const.DIRECTION:
	                return [
	                    1, 0, 0, 0,
	                    0, 1, 0, 0,
	                    0, 0, 1, 0,
	                    vec.x, vec.y, vec.z, 0
	                ];
	            case Const.PROJECTION:
	                return [
	                    1, 0, 0, vec.x,
	                    0, 1, 0, vec.y,
	                    0, 0, 1, vec.z,
	                    0, 0, 0, 1
	                ];
	            case Const.SCALE:
	                return [
	                    vec.x, 0, 0, 0,
	                    0, vec.y, 0, 0,
	                    0, 0, vec.z, 0,
	                    0, 0, 0, 1
	                ];
	            case Const.DEFAULT://general
	                return [
	                    vec.x, vec.x, vec.x, vec.x,
	                    vec.y, vec.y, vec.y, vec.y,
	                    vec.z, vec.z, vec.z, vec.z,
	                    1, 1, 1, 1
	                ];
	        }
	    } else {
	        return matrix_build_identity();
	    }
	};

    return self;
}

/**
 * @class Vec4
 * @classdesc Represents a 4D Vector, extending Vec3.
 * @extends Vec3
 * @param {Real} __x - The w-coordinate of the vector.
 * @param {Real} __y - The x-coordinate of the vector.
 * @param {Real} __z - The y-coordinate of the vector.
 * @param {Real} __w - The z-coordinate of the vector.
 */
function Vec4(__x, __y, __z, __w) : Vec3(__x, __y, __z) constructor {
    
    /**
     * @property {Real} w - The w-coordinate of the vector.
     */
    self.w = __w; // w 좌표


    static serialize = function(__vec4) {
        return [__vec4.x, __vec4.y, __vec4.z, __vec4.w];
    };


	static ToMatrix = function(vec, type) {
	    if (is_instanceof(vec, Vec4)) {
	        switch (type) {
	            case Const.POSITION:
	                return [
	                    1, 0, 0, vec.x,
	                    0, 1, 0, vec.y,
	                    0, 0, 1, vec.z,
	                    0, 0, 0, 1
	                ];
	            case Const.DIRECTION:
	                return [
	                    1, 0, 0, 0,
	                    0, 1, 0, 0,
	                    0, 0, 1, 0,
	                    vec.x, vec.y, vec.z, 0
	                ];
	            case Const.PROJECTION:
	                return [
	                    1, 0, 0, vec.x,
	                    0, 1, 0, vec.y,
	                    0, 0, 1, vec.z,
	                    0, 0, 0, 1
	                ];
	            case Const.SCALE:
	                return [
	                    vec.x, 0, 0, 0,
	                    0, vec.y, 0, 0,
	                    0, 0, vec.z, 0,
	                    0, 0, 0, vec.w
	                ];
	            case Const.DEFAULT://general
	                return [
	                    vec.x, vec.x, vec.x, vec.x,
	                    vec.y, vec.y, vec.y, vec.y,
	                    vec.z, vec.z, vec.z, vec.z,
	                    vec.w, vec.w, vec.w, vec.w
	                ];
	        }
	    } else {
	        return matrix_build_identity();
	    }
	};
	
    return self;
}

/**
 * @class Transform
 * @classdesc Represents a transformation in 3D space, including position, scale, and rotation.
 * @param {Struct} __hash - A hash object containing transformation properties.
 * The hash object can contain the following properties:
 * - **position** (`Vec3`): The position of the transformation.
 * - **scale** (`Vec3`): The scale of the transformation.
 * - **euler** (`Vec3`): The rotation (Euler angles) of the transformation.
 * - **px** (`Real`): The x-coordinate of the position.
 * - **py** (`Real`): The y-coordinate of the position.
 * - **pz** (`Real`): The z-coordinate of the position.
 * - **sx** (`Real`): The x-axis scale.
 * - **sy** (`Real`): The y-axis scale.
 * - **sz** (`Real`): The z-axis scale.
 * - **rx** (`Real`): The rotation around the x-axis.
 * - **ry** (`Real`): The rotation around the y-axis.
 * - **rz** (`Real`): The rotation around the z-axis.
 * - **color** (`Array<Real>`): The color of the panel, either as a single color or an array of four colors for each corner.
 * - **alpha** (`Real`): The alpha transparency value of the panel.
 * - **matrix** (`Array`): A transformation matrix to directly set the transformation properties.
 */
function Transform(__hash = {}) constructor {
	/**
     * Sets the transformation properties from a given matrix.
     * @function SetFromMatrix
     * @memberof Transform
     * @param {Array} matrix - The transformation matrix to set the properties from.
     */
    self.SetFromMatrix = function(__matrix) {
        self.position.x = __matrix[12];
        self.position.y = __matrix[13];
        self.position.z = __matrix[14];
        
        self.scale.x = sqrt(__matrix[0] * __matrix[0] + __matrix[1] * __matrix[1] + __matrix[2] * __matrix[2]);
        self.scale.y = sqrt(__matrix[4] * __matrix[4] + __matrix[5] * __matrix[5] + __matrix[6] * __matrix[6]);
        self.scale.z = sqrt(__matrix[8] * __matrix[8] + __matrix[9] * __matrix[9] + __matrix[10] * __matrix[10]);

        self.euler.x = radtodeg(arctan2(__matrix[6], __matrix[10]));
        self.euler.y = radtodeg(arctan2(-__matrix[2], sqrt(__matrix[0] * __matrix[0] + __matrix[1] * __matrix[1])));
        self.euler.z = radtodeg(arctan2(__matrix[1], __matrix[0]));
    };
	if (is_array(__hash[$ "matrix"]) && (array_length(__hash.matrix) == 16)) SetFromMatrix(__hash.matrix);
	
	///@property {Vec3} position - The position of the transformation.
    self.position = new Vec3(0, 0, 0); // 위치 초기화
	if (is_array(__hash[$ "position"]) && (array_length(__hash.position) == 3)) {
		self.position.x = __hash.position[0];
		self.position.y = __hash.position[1];
		self.position.z = __hash.position[2];
	}
	if (is_instanceof(__hash[$ "position"], Vec3)) {
		self.position.x = __hash.position.x;
		self.position.y = __hash.position.y;
		self.position.z = __hash.position.z;
	}
	if (is_real(__hash[$ "px"])) self.position.x = __hash.px;
	if (is_real(__hash[$ "py"])) self.position.y = __hash.py;
	if (is_real(__hash[$ "pz"])) self.position.z = __hash.pz;

    ///@property {Vec3} scale - The scale of the transformation.
    self.scale = new Vec3(1, 1, 1); // 스케일 초기화
	if (is_array(__hash[$ "scale"]) && (array_length(__hash.scale) == 3)) {
		self.scale.x = __hash.scale[0];
		self.scale.y = __hash.scale[1];
		self.scale.z = __hash.scale[2];
	}
	if (is_instanceof(__hash[$ "scale"], Vec3)) {
		self.scale.x = __hash.scale.x;
		self.scale.y = __hash.scale.y;
		self.scale.z = __hash.scale.z;
	}
	if (is_real(__hash[$ "sx"])) self.scale.x = __hash.sx;
	if (is_real(__hash[$ "sy"])) self.scale.y = __hash.sy;
	if (is_real(__hash[$ "sz"])) self.scale.z = __hash.sz;

    ///@property {Vec3} euler - The rotation (Euler angles) of the transformation.
    self.euler = new Vec3(0, 0, 0); // 회전 초기화
	if (is_array(__hash[$ "rotate"]) && (array_length(__hash.rotate) == 3)) {
		self.euler.x = __hash.rotate[0];
		self.euler.y = __hash.rotate[1];
		self.euler.z = __hash.rotate[2];
	}
	if (is_instanceof(__hash[$ "rotate"], Vec3)) {
		self.euler.x = __hash.rotate.x;
		self.euler.y = __hash.rotate.y;
		self.euler.z = __hash.rotate.z;
	}
	if (is_real(__hash[$ "rx"])) self.euler.x = __hash.rx;
	if (is_real(__hash[$ "ry"])) self.euler.y = __hash.ry;
	if (is_real(__hash[$ "rz"])) self.euler.z = __hash.rz;
	
	///@property {Array<Any>} color - color corners of Rect.
    self.color = [ #ffffff, #ffffff, #ffffff, #ffffff ];  
	if (is_real(__hash[$ "color"])) {
		self.color = [ __hash.color, __hash.color, __hash.color, __hash.color];
	} else if (is_array(__hash[$ "color"]) && (array_length(__hash.color) == 4)) {
		self.color = [__hash.color[0], __hash.color[1], __hash.color[2], __hash.color[3]];
	}
	
	///@property {Real} alpha - transparent of Rect.
	self.alpha = 1;	
	if (is_string(__hash[$ "alpha"])) self.alpha = real(__hash.alpha);
	if (is_real(__hash[$ "alpha"])) self.alpha = __hash.alpha;
    
	/**
     * Builds and returns the transformation matrix based on position, rotation, and scale.
     * @function GetMatrix
	 * @static
     * @memberof Transform
     * @returns {Array<Real>} A transformation matrix representing the current position, rotation, and scale.
     */
    static GetMatrix = function(__std) {
        return matrix_build(__std.position.x, __std.position.y, __std.position.z, __std.euler.x, __std.euler.y, __std.euler.z, __std.scale.x, __std.scale.y, __std.scale.z);
    }
	
    return self;
}

/**
 * @class Rect
 * @classdesc A panel designed to handle flexible resizing, positioning, and animation effects.
 * @param {Object} __hash - A configuration object containing panel properties.
 * The configuration object can contain the following properties:
 * - **anchor** (`Array<Real>`): An array containing the x and y anchor positions in normalized coordinates (0 to 1).
 * - **anchor_x** (`Real`): The x-coordinate of the anchor position.
 * - **anchor_y** (`Real`): The y-coordinate of the anchor position.
 * - **areaUV** (`Array<Real>`): An array containing the UV area boundaries [x1, y1, x2, y2] in normalized coordinates.
 * - **top** (`Real`): The top boundary of the UV area.
 * - **bottom** (`Real`): The bottom boundary of the UV area.
 * - **left** (`Real`): The left boundary of the UV area.
 * - **right** (`Real`): The right boundary of the UV area.
 * - **areaPX** (`Array<Real>`): An array containing the pixel area boundaries [x1, y1, x2, y2].
 * - **offset_top** (`Real`): The top offset in pixels.
 * - **offset_bottom** (`Real`): The bottom offset in pixels.
 * - **offset_left** (`Real`): The left offset in pixels.
 * - **offset_right** (`Real`): The right offset in pixels.
 */
function Rect(__hash = {}, __parent = undefined) : Transform(__hash) constructor {

    // Initialize panel-specific properties
	
	///@property {Vec2} anchor - anchor(u,v) of the transformation.
    self.anchor = new Vec2(0.5, 0.5);
	///@property {Vec2} center - visual anchor(u,v) of the transformation.
	self.center = new Vec2(0.5, 0.5);
    ///@property {Struct} areaUV - UVSquere of the Rect.
	self.areaUV = {x1 : 0, y1 : 0, x2 : 1, y2 :1};
	///@property {Struct} areaPX - Squere offset of the Rect.
	self.areaPX = {x1 : 0, y1 : 0, x2 : 0, y2 :0};
	///@property {id.instance} parent - inhierit Rect.
    self.parent = __parent; 

	
	//anchor read
    if (is_array(__hash[$ "anchor"]) && (array_length(__hash.anchor) == 2)) {
		self.anchor.x = __hash.anchor[0];
		self.anchor.y = __hash.anchor[1];
	} else if (is_instanceof(__hash[$ "anchor"], Vec2)) {
		self.anchor.x = __hash.anchor.x;
		self.anchor.y = __hash.anchor.y;
	}
	if (is_real(__hash[$ "anchor_x"])) self.anchor.x = __hash.anchor_x;
	if (is_real(__hash[$ "anchor_y"])) self.anchor.y = __hash.anchor_y;
	
	//center(%)
	if (is_array(__hash[$ "center"]) && (array_length(__hash.center) == 2)) {
		self.center.x = __hash.center[0];
		self.center.y = __hash.center[1];
	}else if (is_instanceof(__hash[$ "center"], Vec2)) {
		self.center.x = __hash.center.x;
		self.center.y = __hash.center.y;
	}
	if (is_real(__hash[$ "center_x"])) self.center.x = __hash.center_x;
	if (is_real(__hash[$ "center_y"])) self.center.y = __hash.center_y;
	
	//area(%)
    if (is_array(__hash[$ "areaUV"]) && (array_length(__hash.areaUV) == 4)) {
		self.areaUV.x1 = __hash.areaUV[0];
		self.areaUV.y1 = __hash.areaUV[1];
		self.areaUV.x2 = __hash.areaUV[2];
		self.areaUV.y2 = __hash.areaUV[3];
	} else if (is_struct(__hash[$ "areaUV"]) && struct_names_count(__hash.areaUV)==4) {
		self.areaUV.x1 = __hash.areaUV.x1;
		self.areaUV.y1 = __hash.areaUV.y1;
		self.areaUV.x2 = __hash.areaUV.x2;
		self.areaUV.y2 = __hash.areaUV.y2;
	}
	if (is_real(__hash[$ "top"])) self.areaUV.y1 = __hash.top;
	if (is_real(__hash[$ "bottom"])) self.areaUV.y2 = __hash.bottom;
	if (is_real(__hash[$ "left"])) self.areaUV.x1 = __hash.left;
	if (is_real(__hash[$ "right"])) self.areaUV.x2 = __hash.right;
	
	//area(px)
    if (is_array(__hash[$ "areaPX"]) && (array_length(__hash.areaPX) == 4)) {
		self.areaPX.x1 = __hash.areaPX[0];
		self.areaPX.y1 = __hash.areaPX[1];
		self.areaPX.x2 = __hash.areaPX[2];
		self.areaPX.y2 = __hash.areaPX[3];
	} else if (is_struct(__hash[$ "areaPX"]) && struct_names_count(__hash.areaPX)==4) {
		self.areaPX.x1 = __hash.areaPX.x1;
		self.areaPX.y1 = __hash.areaPX.y1;
		self.areaPX.x2 = __hash.areaPX.x2;
		self.areaPX.y2 = __hash.areaPX.y2;
	}
	if (is_real(__hash[$ "offset_top"])) self.areaPX.y1 = __hash.offset_top;
	if (is_real(__hash[$ "offset_bottom"])) self.areaPX.y2 = __hash.offset_bottom;
	if (is_real(__hash[$ "offset_left"])) self.areaPX.x1 = __hash.offset_left;
	if (is_real(__hash[$ "offest_right"])) self.areaPX.x2 = __hash.offset_right;
	
	/**
	 * Function Deep Copy parameters reference Rect to destiny Rect
	 * @param {struct} __ref reference Rect
	 * @param {struct} __dest destiny Rect
	 */
	static Copy = function(__ref, __dest) {
		if (!is_instanceof(__ref,Rect) || !is_instanceof(__dest,Rect)) return;
		
		var _refvars = struct_get_names(__ref);
		
		for (var _v=struct_names_count(__ref)-1; _v>0; _v--){
			if (struct_exists(__dest, _refvars[_v])) {
				__dest[$ _refvars[_v]] = __ref[$ _refvars[_v]];
			}
		}
		
		return;
	}
	
	/**
	 * Function Description
	 * @param {struct} __rect Description
	 * @param {any} [__mtrx]=matrix_build_identity() Description
	 * @param {struct} [__sq]={a : 0, cx : 0, cy : 0, u : 0, v : 0, x : 0, y : 0, w : display_get_gui_width(), h : display_get_gui_height(), r : 0} Description
	 */
	static Absolute = function(__rect, __mtrx = matrix_build_identity(), __sq = {a : 1, u : 0, v : 0, x : 0, y : 0, w : display_get_gui_width(), h : display_get_gui_height()}) {
		
		//check
		if (! is_instanceof(__rect, Rect)) {
			show_debug_message($"{ptr(self)} : no Rect!");
			return [__rect, __mtrx, __sq];		
		}
		
		if (is_instanceof(__rect.parent, Rect)) {
			var _parentSQ = Rect.Absolute(__rect.parent, __mtrx, __sq);
			__mtrx = _parentSQ[1];
			__sq   = _parentSQ[2];
		}
		
		//calculate
		//[x1,x2][y1,y2]
		var _parentArea = [
			[__sq.x, __sq.x+__sq.w],
			[__sq.y, __sq.y+__sq.h]
		];
		// Calculate child anchor point
		var _childAnchor = [//x,y
			lerp(_parentArea[0][0], _parentArea[0][1], __rect.anchor.x),
			lerp(_parentArea[1][0], _parentArea[1][1], __rect.anchor.y),
		];
		// Calculate child area in UV space
		var _childAreaUV = [//x1,y1,x2,y2
			lerp(_parentArea[0][0], _parentArea[0][1], __rect.anchor.x + __rect.areaUV.x1),
			lerp(_parentArea[1][0], _parentArea[1][1], __rect.anchor.y + __rect.areaUV.y1),
			lerp(_parentArea[0][0], _parentArea[0][1], __rect.anchor.x + __rect.areaUV.x2),
			lerp(_parentArea[1][0], _parentArea[1][1], __rect.anchor.y + __rect.areaUV.y2),
		];
		// Calculate child center
		var _childCenter = [//x,y
			lerp(_childAreaUV[0], _childAreaUV[2], __rect.center.x),
			lerp(_childAreaUV[1], _childAreaUV[3], __rect.center.y)
		];			

		// child area based on the scale property of the rect
		_childAnchor[0] -= _childCenter[0];
		_childAnchor[1] -= _childCenter[1];
	    _childAreaUV[0] -= _childCenter[0];
	    _childAreaUV[1] -= _childCenter[1];
	    _childAreaUV[2] -= _childCenter[0];
	    _childAreaUV[3] -= _childCenter[1];
		
		var _myMatrix = matrix_build(
			__rect.position.x+_childCenter[0], __rect.position.y+_childCenter[1], __rect.position.z,
			__rect.euler.x, __rect.euler.y, __rect.euler.z,
			__rect.scale.x, __rect.scale.y, __rect.scale.z
		);
		__mtrx = matrix_multiply(_myMatrix, __mtrx);
		
		__sq.u = _childAnchor[0];
		__sq.v = _childAnchor[1];
		__sq.x = _childAreaUV[0] + __rect.areaPX.x1;
		__sq.y = _childAreaUV[1] + __rect.areaPX.y1;
		__sq.w = _childAreaUV[2] + __rect.areaPX.x2 - __sq.x;
		__sq.h = _childAreaUV[3] + __rect.areaPX.y2 - __sq.y;
		__sq.cx = lerp(__sq.x, __sq.x+__sq.w, __rect.center.x);
		__sq.cy = lerp(__sq.y, __sq.y+__sq.h, __rect.center.y);
		__sq.a *= __rect.alpha;
		
		return [__rect, __mtrx, __sq];
	}
	
	static IsFocus = function(__matrix, __area, __x, __y, __dw=display_get_gui_width(), __dh=display_get_gui_height()) {
		
		var _newv4 = new Vec4(__x, __y, 0, 1); //show_message(Vec4.serialize(_newv4));//no problem check
		var _invmtrx = matrix_inverse(__matrix); //show_debug_message(_invmtrx);//no problem check
		
		var _f = matrix_transform_vertex(_invmtrx, __x, __y, 0, 1); //show_debug_message(Vec4.serialize(_f));//no Problem
	
		return point_in_rectangle(_f[0], _f[1], __area.x, __area.y, __area.x+__area.w, __area.y+__area.h);	
	}
	
	/**
     * @function DebugDraw
     * @memberof Rect
     * @static
     * @param {Rect} __rect - Rect for global.
     */
	static DebugDraw = function(__rect) {
		//check
		if (is_instanceof(__rect, Rect)) {	
			var _stack = Rect.Absolute(__rect);
			var _focus = Rect.IsFocus(_stack[1], _stack[2], device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
			
			//matrix apply
			matrix_stack_push(_stack[1]);
			matrix_set(matrix_world, matrix_stack_top());
			
			//draw_sprite and outline
			draw_rectangle_color(_stack[2].x, _stack[2].y, _stack[2].x+_stack[2].w, _stack[2].y+_stack[2].h, __rect.color[0], __rect.color[1], __rect.color[2], __rect.color[3], 1);
			
			// anchor point
			debug_crosshair(_stack[2].u, _stack[2].v, 10);

			//draw_mouse
			//draw_circle_color(mouse_x, mouse_y, 5, c_green, c_green, 0);
			
			//matrix pop
			matrix_stack_pop();
			matrix_set(matrix_world, matrix_build_identity());
			draw_set_alpha(1)
			
			//draw mouse raw position
			//draw_circle_color(mouse_x, mouse_y, 5, c_yellow, c_yellow, 0);
		}
	}
    return self;
}

