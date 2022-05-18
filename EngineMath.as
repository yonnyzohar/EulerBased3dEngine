/*
 * Copyright 2011-2016 Branimir Karadzic. All rights reserved.
 * License: https://github.com/bkaradzic/bx#license-bsd-2-clause
 */



package {

	public class EngineMath {
		
		private static var LEFT_HANDEDNESS:int = 0;
		private static var RIGHT_HANDEDNESS:int = 1;
		
		public static var RIGHT: Vector3 = new Vector3(1, 0, 0);
		public static var LEFT: Vector3 = new Vector3(-1, 0, 0);
		public static var UP: Vector3 = new Vector3(0, 1, 0);
		public static var DOWN: Vector3 = new Vector3(0, -1, 0);
		public static var FORWARD: Vector3 = new Vector3(0, 0, 1);
		public static var BACK: Vector3 = new Vector3(0, 0, -1);
		public static var MATH_DEG_TO_RAD: Number = 0.0174532925;

		
		public static function getAngleEuler(from: Vector3, to: Vector3): Number {
			var angle: Number = Math.atan2(to.x - from.x, to.z - from.z);
			return angle;
		}


		public static function vec3Sub(_a: Vector3, _b: Vector3) {
			return new Vector3(_a.x - _b.x, _a.y - _b.y, _a.z - _b.z);

		}

		

		public static function vec3Norm(_a: Vector3) {
			var _result: Vector3 = new Vector3(0, 0, 0);
			var len: Number = vec3Length(_a);
			var invLen: Number = 1.0 / len;
			_result.x = _a.x * invLen;
			_result.y = _a.y * invLen;
			_result.z = _a.z * invLen;
			return _result;
		}

		public static function vec3Length(_a: Vector3): Number {
			return Math.sqrt(vec3Dot(_a, _a));
		}

		public static function vec3Dot(_a: Vector3, _b: Vector3): Number {
			return (_a.x * _b.x) + (_a.y * _b.y) + (_a.z * _b.z);
		}

		public static function vec3Cross(_a: Vector3, _b: Vector3): Vector3 {
			var _result: Vector3 = new Vector3(0, 0, 0);
			_result.x = (_a.y * _b.z) - (_a.z * _b.y);
			_result.y = (_a.z * _b.x) - (_a.x * _b.z);
			_result.z = (_a.x * _b.y) - (_a.y * _b.x);
			return _result;

		}

		public static function radToDegrees(rads: Number): Number {
			return rads * 180.0 / Math.PI;
		}

		public static function degreesToRad(degs: Number): Number {
			return degs * Math.PI / 180.0;
		}

		public static function getDistance(p1: Vector3, p2: Vector3): Number {

			var dX: Number = p1.x - p2.x;
			var dY: Number = p1.y - p2.y;
			var dZ: Number = p1.z - p2.z;
			var dist: Number = Math.sqrt((dX * dX) + (dY * dY) + (dZ * dZ));
			return dist;
		}



		
	}

}

	
/*
public static function float4x4_mul_scalar(float4x4_t* __restrict _result, const float4x4_t* __restrict _a, float scalar)
		{
			simd128_t b = simd_splat(scalar);
			_result->col[0] = simd_mul(_a->col[0], b);
			_result->col[1] = simd_mul(_a->col[1], b);
			_result->col[2] = simd_mul(_a->col[2], b);
			_result->col[3] = simd_mul(_a->col[3], b);
		}


public static function vec2PointMulMtx(float* __restrict _result, const float* __restrict _vec, const float* __restrict _mat)
		{
			_result[0] = _vec[0] * _mat[ 0] + _vec[1] * _mat[ 2];
			_result[1] = _vec[0] * _mat[ 4] + _vec[1] * _mat[ 6] + _vec[2] * _mat[5];
			
			
		}

namespace bx
{
	static const float pi     = 3.14159265358979323846f;
	static const float invPi  = 1.0f/3.14159265358979323846f;
	static const float piHalf = 1.57079632679489661923f;
	static const float sqrt2  = 1.41421356237309504880f;

	struct Handness
	{
		enum Enum
		{
			Left,
			Right,
		};
	};

	struct NearFar
	{
		enum Enum
		{
			Default,
			Reverse,
		};
	};

	inline void quatLookAt(float* __restrict _result, float* __restrict forward, float* __restrict up)
    {
        //normalize F
        float f_normalized[3];
        bx::vec3Norm(f_normalized, forward); //lookAt
        
        float right[3];
        bx::vec3Cross(right, up, f_normalized );
        
        //normalize R
        float r_normalized[3];
        bx::vec3Norm(r_normalized, right);
        
        float u_normalized[3];
        bx::vec3Cross(u_normalized, f_normalized, r_normalized );
        
        float rX = r_normalized[0];//x
        float rY = r_normalized[1];//y
        float rZ = r_normalized[2];//z
        
        float uX = u_normalized[0];//x
        float uY = u_normalized[1];//y
        float uZ = u_normalized[2];//x
        
        float fX = f_normalized[0];//x
        float fY = f_normalized[1];//y
        float fZ = f_normalized[2];//z
        
        
        ////
        float num8 = (rX + uY) + fZ;
        if (num8 > 0.0f)
        {
            float num = (float)sqrt(num8 + 1.0f);
            _result[3] = num * 0.5f;
            num = 0.5f / num;
            _result[0] = (uZ - fY) * num;
            _result[1] = (fX - rZ) * num;
            _result[2] = (rY - uX) * num;
        }
        else if ((rX >= uY) && (rX >= fZ))
        {
            float num7 = (float)sqrt(((1.0f + rX) - uY) - fZ);
            float num4 = 0.5f / num7;
            _result[0] = 0.5f * num7;
            _result[1] = (rY + uX) * num4;
            _result[2] = (rZ + fX) * num4;
            _result[3] = (uZ - fY) * num4;
        }
        else if (uY > fZ)
        {
            float num6 = (float)sqrt(((1.0f + uY) - rX) - fZ);
            float num3 = 0.5f / num6;
            _result[0] = (uX + rY) * num3;
            _result[1] = 0.5f * num6;
            _result[2] = (fY + uZ) * num3;
            _result[3] = (fX - rZ) * num3;
        }
        else
        {
            float num5 = (float)sqrt(((1.0f + fZ) - rX) - uY);
            float num2 = 0.5f / num5;
            _result[0] = (fX + rZ) * num2;
            _result[1] = (fY + uZ) * num2;
            _result[2] = 0.5f * num5;
            _result[3] = (rY - uX) * num2;
        }
    }

	inline float toRad(float _deg)
	{
		return _deg * pi / 180.0f;
	}

	inline float toDeg(float _rad)
	{
		return _rad * 180.0f / pi;
	}

	inline float ffloor(float _f)
	{
		return floorf(_f);
	}

	inline float fceil(float _f)
	{
		return ceilf(_f);
	}

	inline float fround(float _f)
	{
		return ffloor(_f + 0.5f);
	}

	inline float fmin(float _a, float _b)
	{
		return _a < _b ? _a : _b;
	}

	inline float fmax(float _a, float _b)
	{
		return _a > _b ? _a : _b;
	}

	inline float fmin3(float _a, float _b, float _c)
	{
		return fmin(_a, fmin(_b, _c) );
	}

	inline float fmax3(float _a, float _b, float _c)
	{
		return fmax(_a, fmax(_b, _c) );
	}

	inline float fclamp(float _a, float _min, float _max)
	{
		return fmin(fmax(_a, _min), _max);
	}

	inline float fsaturate(float _a)
	{
		return fclamp(_a, 0.0f, 1.0f);
	}

	inline float flerp(float _a, float _b, float _t)
	{
		return _a + (_b - _a) * _t;
	}

	inline float fsign(float _a)
	{
		return _a < 0.0f ? -1.0f : 1.0f;
	}

	inline float fstep(float _edge, float _a)
	{
		return _a < _edge ? 0.0f : 1.0f;
	}

	inline float fpulse(float _a, float _start, float _end)
	{
		return fstep(_a, _start) - fstep(_a, _end);
	}

	inline float fabsolute(float _a)
	{
		return fabsf(_a);
	}

	inline float fsq(float _a)
	{
		return _a * _a;
	}

	inline float fsin(float _a)
	{
		return sinf(_a);
	}

	inline float fcos(float _a)
	{
		return cosf(_a);
	}

	inline float fpow(float _a, float _b)
	{
		return powf(_a, _b);
	}

	inline float fexp2(float _a)
	{
		return fpow(2.0f, _a);
	}

	inline float flog(float _a)
	{
		return logf(_a);
	}

	inline float flog2(float _a)
	{
		return flog(_a) * 1.442695041f;
	}

	inline float fsqrt(float _a)
	{
		return sqrtf(_a);
	}

	inline float frsqrt(float _a)
	{
		return 1.0f/fsqrt(_a);
	}

	inline float ffract(float _a)
	{
		return _a - floorf(_a);
	}

	inline float fmod(float _a, float _b)
	{
		return fmodf(_a, _b);
	}

	inline bool fequal(float _a, float _b, float _epsilon)
	{
		// http://realtimecollisiondetection.net/blog/?p=89
		const float lhs = fabsolute(_a - _b);
		const float rhs = _epsilon * fmax3(1.0f, fabsolute(_a), fabsolute(_b) );
		return lhs <= rhs;
	}

	inline bool fequal(const float* __restrict _a, const float* __restrict _b, uint32_t _num, float _epsilon)
	{
		bool equal = fequal(_a[0], _b[0], _epsilon);
		for (uint32_t ii = 1; equal && ii < _num; ++ii)
		{
			equal = fequal(_a[ii], _b[ii], _epsilon);
		}
		return equal;
	}

	inline float fwrap(float _a, float _wrap)
	{
		const float mod    = fmod(_a, _wrap);
		const float result = mod < 0.0f ? _wrap + mod : mod;
		return result;
	}

	// References:
	//  - Bias And Gain Are Your Friend
	//    http://blog.demofox.org/2012/09/24/bias-and-gain-are-your-friend/
	//  - http://demofox.org/biasgain.html
	inline float fbias(float _time, float _bias)
	{
		return _time / ( ( (1.0f/_bias - 2.0f)*(1.0f - _time) ) + 1.0f);
	}

	inline float fgain(float _time, float _gain)
	{
		if (_time < 0.5f)
		{
			return fbias(_time * 2.0f, _gain) * 0.5f;
		}

		return fbias(_time * 2.0f - 1.0f, 1.0f - _gain) * 0.5f + 0.5f;
	}

	inline void vec3Move(float* __restrict _result, const float* __restrict _a)
	{
		_result[0] = _a[0];
		_result[1] = _a[1];
		_result[2] = _a[2];
	}

	inline void vec3Abs(float* __restrict _result, const float* __restrict _a)
	{
		_result[0] = fabsolute(_a[0]);
		_result[1] = fabsolute(_a[1]);
		_result[2] = fabsolute(_a[2]);
	}

	inline void vec3Neg(float* __restrict _result, const float* __restrict _a)
	{
		_result[0] = -_a[0];
		_result[1] = -_a[1];
		_result[2] = -_a[2];
	}

	inline void vec3Add(float* __restrict _result, const float* __restrict _a, const float* __restrict _b)
	{
		_result[0] = _a[0] + _b[0];
		_result[1] = _a[1] + _b[1];
		_result[2] = _a[2] + _b[2];
	}

	inline void vec3Add(float* __restrict _result, const float* __restrict _a, float _b)
	{
		_result[0] = _a[0] + _b;
		_result[1] = _a[1] + _b;
		_result[2] = _a[2] + _b;
	}

	

	inline void vec3Sub(float* __restrict _result, const float* __restrict _a, float _b)
	{
		_result[0] = _a[0] - _b;
		_result[1] = _a[1] - _b;
		_result[2] = _a[2] - _b;
	}

	inline void vec3Mul(float* __restrict _result, const float* __restrict _a, const float* __restrict _b)
	{
		_result[0] = _a[0] * _b[0];
		_result[1] = _a[1] * _b[1];
		_result[2] = _a[2] * _b[2];
	}

	inline void vec3Mul(float* __restrict _result, const float* __restrict _a, float _b)
	{
		_result[0] = _a[0] * _b;
		_result[1] = _a[1] * _b;
		_result[2] = _a[2] * _b;
	}

	

	

	

	inline void vec3Lerp(float* __restrict _result, const float* __restrict _a, const float* __restrict _b, float _t)
	{
		_result[0] = flerp(_a[0], _b[0], _t);
		_result[1] = flerp(_a[1], _b[1], _t);
		_result[2] = flerp(_a[2], _b[2], _t);
	}

	inline void vec3Lerp(float* __restrict _result, const float* __restrict _a, const float* __restrict _b, const float* __restrict _c)
	{
		_result[0] = flerp(_a[0], _b[0], _c[0]);
		_result[1] = flerp(_a[1], _b[1], _c[1]);
		_result[2] = flerp(_a[2], _b[2], _c[2]);
	}

	

	inline void vec3Min(float* __restrict _result, const float* __restrict _a, const float* __restrict _b)
	{
		_result[0] = fmin(_a[0], _b[0]);
		_result[1] = fmin(_a[1], _b[1]);
		_result[2] = fmin(_a[2], _b[2]);
	}

	inline void vec3Max(float* __restrict _result, const float* __restrict _a, const float* __restrict _b)
	{
		_result[0] = fmax(_a[0], _b[0]);
		_result[1] = fmax(_a[1], _b[1]);
		_result[2] = fmax(_a[2], _b[2]);
	}

	inline void vec3Rcp(float* __restrict _result, const float* __restrict _a)
	{
		_result[0] = 1.0f / _a[0];
		_result[1] = 1.0f / _a[1];
		_result[2] = 1.0f / _a[2];
	}

	inline void vec3TangentFrame(const float* __restrict _n, float* __restrict _t, float* __restrict _b)
	{
		const float nx = _n[0];
		const float ny = _n[1];
		const float nz = _n[2];

		if (bx::fabsolute(nx) > bx::fabsolute(nz) )
		{
			float invLen = 1.0f / bx::fsqrt(nx*nx + nz*nz);
			_t[0] = -nz * invLen;
			_t[1] =  0.0f;
			_t[2] =  nx * invLen;
		}
		else
		{
			float invLen = 1.0f / bx::fsqrt(ny*ny + nz*nz);
			_t[0] =  0.0f;
			_t[1] =  nz * invLen;
			_t[2] = -ny * invLen;
		}

		bx::vec3Cross(_b, _n, _t);
	}
    
    /// Vector4
    
    inline void vec4add(float* __restrict _result, const float* __restrict _a, float _b)
    {
        _result[0] = _a[0] + _b;
        _result[1] = _a[1] + _b;
        _result[2] = _a[2] + _b;
        _result[3] = _a[3] + _b;
    }
    
    inline void vec4Add(float* __restrict _result, const float* __restrict _a, const float* __restrict _b)
    {
        _result[0] = _a[0] + _b[0];
        _result[1] = _a[1] + _b[1];
        _result[2] = _a[2] + _b[2];
        _result[2] = _a[3] + _b[3];
    }
    
    inline void vec4Sub(float* __restrict _result, const float* __restrict _a, const float* __restrict _b)
    {
        _result[0] = _a[0] - _b[0];
        _result[1] = _a[1] - _b[1];
        _result[2] = _a[2] - _b[2];
        _result[3] = _a[3] - _b[3];
    }
    
    inline void vec4Sub(float* __restrict _result, const float* __restrict _a, float _b)
    {
        _result[0] = _a[0] - _b;
        _result[1] = _a[1] - _b;
        _result[2] = _a[2] - _b;
        _result[3] = _a[3] - _b;
    }
    
    inline void vec4Mul(float* __restrict _result, const float* __restrict _a, const float* __restrict _b)
    {
        _result[0] = _a[0] * _b[0];
        _result[1] = _a[1] * _b[1];
        _result[2] = _a[2] * _b[2];
        _result[3] = _a[3] * _b[3];
    }
    
    inline void vec4Mul(float* __restrict _result, const float* __restrict _a, float _b)
    {
        _result[0] = _a[0] * _b;
        _result[1] = _a[1] * _b;
        _result[2] = _a[2] * _b;
        _result[3] = _a[3] * _b;
    }
    
    inline float vec4Dot(const float* __restrict _a, const float* __restrict _b)
    {
        return _a[0]*_b[0] + _a[1]*_b[1] + _a[2]*_b[2] + _a[3]*_b[3];
    }
    
    
    
    inline float vec4Length(const float* _a)
    {
        return fsqrt(vec4Dot(_a, _a) );
    }
    
    inline float vec4Norm(float* __restrict _result, const float* __restrict _a)
    {
        const float len = vec4Length(_a);
        const float invLen = 1.0f/len;
        _result[0] = _a[0] * invLen;
        _result[1] = _a[1] * invLen;
        _result[2] = _a[2] * invLen;
        _result[3] = _a[3] * invLen;
        return len;
    }
    
    inline void vec4Lerp(float* __restrict _result, const float* __restrict _a, const float* __restrict _b, float _t)
    {
        _result[0] = flerp(_a[0], _b[0], _t);
        _result[1] = flerp(_a[1], _b[1], _t);
        _result[2] = flerp(_a[2], _b[2], _t);
        _result[3] = flerp(_a[3], _b[3], _t);
    }


	inline void quatIdentity(float* _result)
	{
		_result[0] = 0.0f;
		_result[1] = 0.0f;
		_result[2] = 0.0f;
		_result[3] = 1.0f;
	}
    
    //start quat, dest quat, result quat
    inline void quatSlerp(float q1x, float q1y, float q1z, float q1w, float q2x, float q2y, float q2z, float q2w, float t, float* dstx, float* dsty, float* dstz, float* dstw)
    {
        // Fast slerp implementation by kwhatmough:
        // It contains no division operations, no trig, no inverse trig
        // and no sqrt. Not only does this code tolerate small constraint
        // errors in the input quaternions, it actually corrects for them.
        GP_ASSERT(dstx && dsty && dstz && dstw);
        GP_ASSERT(!(t < 0.0f || t > 1.0f));

        if (t == 0.0f)
        {
            *dstx = q1x;
            *dsty = q1y;
            *dstz = q1z;
            *dstw = q1w;
            return;
        }
        else if (t == 1.0f)
        {
            *dstx = q2x;
            *dsty = q2y;
            *dstz = q2z;
            *dstw = q2w;
            return;
        }

        if (q1x == q2x && q1y == q2y && q1z == q2z && q1w == q2w)
        {
            *dstx = q1x;
            *dsty = q1y;
            *dstz = q1z;
            *dstw = q1w;
            return;
        }

        float halfY, alpha, beta;
        float u, f1, f2a, f2b;
        float ratio1, ratio2;
        float halfSecHalfTheta, versHalfTheta;
        float sqNotU, sqU;

        float cosTheta = q1w * q2w + q1x * q2x + q1y * q2y + q1z * q2z;

        // As usual in all slerp implementations, we fold theta.
        alpha = cosTheta >= 0 ? 1.0f : -1.0f;
        halfY = 1.0f + alpha * cosTheta;

        // Here we bisect the interval, so we need to fold t as well.
        f2b = t - 0.5f;
        u = f2b >= 0 ? f2b : -f2b;
        f2a = u - f2b;
        f2b += u;
        u += u;
        f1 = 1.0f - u;

        // One iteration of Newton to get 1-cos(theta / 2) to good accuracy.
        halfSecHalfTheta = 1.09f - (0.476537f - 0.0903321f * halfY) * halfY;
        halfSecHalfTheta *= 1.5f - halfY * halfSecHalfTheta * halfSecHalfTheta;
        versHalfTheta = 1.0f - halfY * halfSecHalfTheta;

        // Evaluate series expansions of the coefficients.
        sqNotU = f1 * f1;
        ratio2 = 0.0000440917108f * versHalfTheta;
        ratio1 = -0.00158730159f + (sqNotU - 16.0f) * ratio2;
        ratio1 = 0.0333333333f + ratio1 * (sqNotU - 9.0f) * versHalfTheta;
        ratio1 = -0.333333333f + ratio1 * (sqNotU - 4.0f) * versHalfTheta;
        ratio1 = 1.0f + ratio1 * (sqNotU - 1.0f) * versHalfTheta;

        sqU = u * u;
        ratio2 = -0.00158730159f + (sqU - 16.0f) * ratio2;
        ratio2 = 0.0333333333f + ratio2 * (sqU - 9.0f) * versHalfTheta;
        ratio2 = -0.333333333f + ratio2 * (sqU - 4.0f) * versHalfTheta;
        ratio2 = 1.0f + ratio2 * (sqU - 1.0f) * versHalfTheta;

        // Perform the bisection and resolve the folding done earlier.
        f1 *= ratio1 * halfSecHalfTheta;
        f2a *= ratio2;
        f2b *= ratio2;
        alpha *= f1 + f2a;
        beta = f1 + f2b;

        // Apply final coefficients to a and b as usual.
        float w = alpha * q1w + beta * q2w;
        float x = alpha * q1x + beta * q2x;
        float y = alpha * q1y + beta * q2y;
        float z = alpha * q1z + beta * q2z;

        // This final adjustment to the quaternion's length corrects for
        // any small constraint error in the inputs q1 and q2 But as you
        // can see, it comes at the cost of 9 additional multiplication
        // operations. If this error-correcting feature is not required,
        // the following code may be removed.
        f1 = 1.5f - 0.5f * (w * w + x * x + y * y + z * z);
        *dstw = w * f1;
        *dstx = x * f1;
        *dsty = y * f1;
        *dstz = z * f1;
    }


	inline void quatMove(float* __restrict _result, const float* __restrict _a)
	{
		_result[0] = _a[0];
		_result[1] = _a[1];
		_result[2] = _a[2];
		_result[3] = _a[3];
	}

	inline void quatMulXYZ(float* __restrict _result, const float* __restrict _qa, const float* __restrict _qb)
	{
		const float ax = _qa[0];
		const float ay = _qa[1];
		const float az = _qa[2];
		const float aw = _qa[3];

		const float bx = _qb[0];
		const float by = _qb[1];
		const float bz = _qb[2];
		const float bw = _qb[3];

		_result[0] = aw * bx + ax * bw + ay * bz - az * by;
		_result[1] = aw * by - ax * bz + ay * bw + az * bx;
		_result[2] = aw * bz + ax * by - ay * bx + az * bw;
	}

	inline void quatMul(float* __restrict _result, const float* __restrict _qa, const float* __restrict _qb)
	{
		const float ax = _qa[0];
		const float ay = _qa[1];
		const float az = _qa[2];
		const float aw = _qa[3];

		const float bx = _qb[0];
		const float by = _qb[1];
		const float bz = _qb[2];
		const float bw = _qb[3];

		_result[0] = aw * bx + ax * bw + ay * bz - az * by;
		_result[1] = aw * by - ax * bz + ay * bw + az * bx;
		_result[2] = aw * bz + ax * by - ay * bx + az * bw;
		_result[3] = aw * bw - ax * bx - ay * by - az * bz;
	}

	inline void quatConjugate(float* __restrict _result, const float* __restrict _quat)
	{
		_result[0] = -_quat[0];
		_result[1] = -_quat[1];
		_result[2] = -_quat[2];
		_result[3] =  _quat[3];
	}

	inline float quatDot(const float* __restrict _a, const float* __restrict _b)
	{
		return _a[0]*_b[0]
			 + _a[1]*_b[1]
			 + _a[2]*_b[2]
			 + _a[3]*_b[3]
			 ;
	}

	inline void quatNorm(float* __restrict _result, const float* __restrict _quat)
	{
		const float norm = quatDot(_quat, _quat);
		if (0.0f < norm)
		{
			const float invNorm = 1.0f / fsqrt(norm);
			_result[0] = _quat[0] * invNorm;
			_result[1] = _quat[1] * invNorm;
			_result[2] = _quat[2] * invNorm;
			_result[3] = _quat[3] * invNorm;
		}
		else
		{
			quatIdentity(_result);
		}
	}
    
    inline void quatNLerp(float* __restrict _result, const float* __restrict _a, const float* __restrict _b, float _t)
    {
        _result[0] = flerp(_a[0], _b[0], _t);
        _result[1] = flerp(_a[1], _b[1], _t);
        _result[2] = flerp(_a[2], _b[2], _t);
        _result[3] = flerp(_a[3], _b[3], _t);
        
        quatNorm(_result, _result);
    }

	inline void quatToEuler(float* __restrict _result, const float* __restrict _quat)
	{
		const float x = _quat[0];
		const float y = _quat[1];
		const float z = _quat[2];
		const float w = _quat[3];

		const float yy = y * y;
		const float zz = z * z;

		const float xx = x * x;
		_result[0] = atan2f(2.0f * (x * w - y * z), 1.0f - 2.0f * (xx + zz) );
		_result[1] = atan2f(2.0f * (y * w + x * z), 1.0f - 2.0f * (yy + zz) );
		_result[2] = asinf (2.0f * (x * y + z * w) );
	}
    
    
	
    
    inline void quatToAxisAngle(float*  _axis, float* _angle, const float* __restrict quat)
    {
        
        float qn[4];
        quatNorm(qn, quat);
        
        float cos_a = qn[3];
        float angle = acos( cos_a ) * 2;
        float sin_a = fsqrt( 1.0 - cos_a * cos_a );
        if ( fabs( sin_a ) < 0.0005 ) sin_a = 1;
        _axis[0] = qn[0] / sin_a;
        _axis[1] = qn[1] / sin_a;
        _axis[2] = qn[2] / sin_a;
        *_angle = angle;
    }
    
    


	inline void quatRotateX(float* _result, float _ax)
	{
		const float hx = _ax * 0.5f;
		const float cx = fcos(hx);
		const float sx = fsin(hx);
		_result[0] = sx;
		_result[1] = 0.0f;
		_result[2] = 0.0f;
		_result[3] = cx;
	}

	inline void quatRotateY(float* _result, float _ay)
	{
		const float hy = _ay * 0.5f;
		const float cy = fcos(hy);
		const float sy = fsin(hy);
		_result[0] = 0.0f;
		_result[1] = sy;
		_result[2] = 0.0f;
		_result[3] = cy;
	}

	inline void quatRotateZ(float* _result, float _az)
	{
		const float hz = _az * 0.5f;
		const float cz = fcos(hz);
		const float sz = fsin(hz);
		_result[0] = 0.0f;
		_result[1] = 0.0f;
		_result[2] = sz;
		_result[3] = cz;
	}
    
            
    

	inline void vec3MulQuat(float* __restrict _result, const float* __restrict _vec, const float* __restrict _quat)
	{
		float tmp0[4];
		quatConjugate(tmp0, _quat);

		float qv[4];
		qv[0] = _vec[0];
		qv[1] = _vec[1];
		qv[2] = _vec[2];
		qv[3] = 0.0f;

		float tmp1[4];
		quatMul(tmp1, tmp0, qv);

		quatMulXYZ(_result, tmp1, _quat);
	}

	inline void mtxIdentity(float* _result)
	{
		memset(_result, 0, sizeof(float)*16);
		_result[0] = _result[5] = _result[10] = _result[15] = 1.0f;
	}

    // create a translation matrix
	inline void mtxTranslate(float* _result, float _tx, float _ty, float _tz)
	{
		mtxIdentity(_result);
		_result[12] = _tx;
		_result[13] = _ty;
		_result[14] = _tz;
	}
    
    // set the translation component of the given matrix
    inline void mtxSetTranslate(float* _mat, float _tx, float _ty, float _tz)
    {
        _mat[12] = _tx;
        _mat[13] = _ty;
        _mat[14] = _tz;
    }

	inline void mtxScale(float* _result, float _sx, float _sy, float _sz)
	{
		memset(_result, 0, sizeof(float) * 16);
		_result[0]  = _sx;
		_result[5]  = _sy;
		_result[10] = _sz;
		_result[15] = 1.0f;
	}

	inline void mtxScale(float* _result, float _scale)
	{
		mtxScale(_result, _scale, _scale, _scale);
	}

	inline void mtxFromNormal(float* __restrict _result, const float* __restrict _normal, float _scale, const float* __restrict _pos)
	{
		float tangent[3];
		float bitangent[3];
		vec3TangentFrame(_normal, tangent, bitangent);

		vec3Mul(&_result[ 0], bitangent, _scale);
		vec3Mul(&_result[ 4], _normal,   _scale);
		vec3Mul(&_result[ 8], tangent,   _scale);

		_result[ 3] = 0.0f;
		_result[ 7] = 0.0f;
		_result[11] = 0.0f;
		_result[12] = _pos[0];
		_result[13] = _pos[1];
		_result[14] = _pos[2];
		_result[15] = 1.0f;
	}

	inline void mtxQuat(float* __restrict _result, const float* __restrict _quat)
	{
		const float x = _quat[0];
		const float y = _quat[1];
		const float z = _quat[2];
		const float w = _quat[3];

		const float x2  =  x + x;
		const float y2  =  y + y;
		const float z2  =  z + z;
		const float x2x = x2 * x;
		const float x2y = x2 * y;
		const float x2z = x2 * z;
		const float x2w = x2 * w;
		const float y2y = y2 * y;
		const float y2z = y2 * z;
		const float y2w = y2 * w;
		const float z2z = z2 * z;
		const float z2w = z2 * w;

		_result[ 0] = 1.0f - (y2y + z2z);
		_result[ 1] =         x2y - z2w;
		_result[ 2] =         x2z + y2w;
		_result[ 3] = 0.0f;

		_result[ 4] =         x2y + z2w;
		_result[ 5] = 1.0f - (x2x + z2z);
		_result[ 6] =         y2z - x2w;
		_result[ 7] = 0.0f;

		_result[ 8] =         x2z - y2w;
		_result[ 9] =         y2z + x2w;
		_result[10] = 1.0f - (x2x + y2y);
		_result[11] = 0.0f;

		_result[12] = 0.0f;
		_result[13] = 0.0f;
		_result[14] = 0.0f;
		_result[15] = 1.0f;
	}

	inline void mtxQuatTranslation(float* __restrict _result, const float* __restrict _quat, const float* __restrict _translation)
	{
		mtxQuat(_result, _quat);
		_result[12] = -(_result[0]*_translation[0] + _result[4]*_translation[1] + _result[ 8]*_translation[2]);
		_result[13] = -(_result[1]*_translation[0] + _result[5]*_translation[1] + _result[ 9]*_translation[2]);
		_result[14] = -(_result[2]*_translation[0] + _result[6]*_translation[1] + _result[10]*_translation[2]);
	}

	inline void mtxQuatTranslationHMD(float* __restrict _result, const float* __restrict _quat, const float* __restrict _translation)
	{
		float quat[4];
		quat[0] = -_quat[0];
		quat[1] = -_quat[1];
		quat[2] =  _quat[2];
		quat[3] =  _quat[3];
		mtxQuatTranslation(_result, quat, _translation);
	}

	inline void mtxLookAt_Impl(float* __restrict _result, const float* __restrict _eye, const float* __restrict _view, const float* __restrict _up = NULL)
	{
		float up[3] = { 0.0f, 1.0f, 0.0f };
		if (NULL != _up)
		{
			up[0] = _up[0];
			up[1] = _up[1];
			up[2] = _up[2];
		}

		float tmp[4];
		vec3Cross(tmp, up, _view);

		float right[4];
		vec3Norm(right, tmp);

		vec3Cross(up, _view, right);

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = right[0];
		_result[ 1] = up[0];
		_result[ 2] = _view[0];

		_result[ 4] = right[1];
		_result[ 5] = up[1];
		_result[ 6] = _view[1];

		_result[ 8] = right[2];
		_result[ 9] = up[2];
		_result[10] = _view[2];

		_result[12] = -vec3Dot(right, _eye);
		_result[13] = -vec3Dot(up, _eye);
		_result[14] = -vec3Dot(_view, _eye);
		_result[15] = 1.0f;
	}

	inline void mtxLookAtLh(float* __restrict _result, const float* __restrict _eye, const float* __restrict _at, const float* __restrict _up = NULL)
	{
		float tmp[4];
		vec3Sub(tmp, _at, _eye);

		float view[4];
		vec3Norm(view, tmp);

		mtxLookAt_Impl(_result, _eye, view, _up);
	}

	inline void mtxLookAtRh(float* __restrict _result, const float* __restrict _eye, const float* __restrict _at, const float* __restrict _up = NULL)
	{
		float tmp[4];
		vec3Sub(tmp, _eye, _at);

		float view[4];
		vec3Norm(view, tmp);

		mtxLookAt_Impl(_result, _eye, view, _up);
	}

	inline void mtxLookAt(float* __restrict _result, const float* __restrict _eye, const float* __restrict _at, const float* __restrict _up = NULL)
	{
		mtxLookAtLh(_result, _eye, _at, _up);
	}

	

	template <Handness::Enum HandnessT>
	inline void mtxProj_impl(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, float _far, bool _oglNdc = false)
	{
		const float invDiffRl = 1.0f/(_rt - _lt);
		const float invDiffUd = 1.0f/(_ut - _dt);
		const float width  =  2.0f*_near * invDiffRl;
		const float height =  2.0f*_near * invDiffUd;
		const float xx     = (_rt + _lt) * invDiffRl;
		const float yy     = (_ut + _dt) * invDiffUd;
		mtxProjXYWH<HandnessT>(_result, xx, yy, width, height, _near, _far, _oglNdc);
	}

	template <Handness::Enum HandnessT>
	inline void mtxProj_impl(float* _result, const float _fov[4], float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<HandnessT>(_result, _fov[0], _fov[1], _fov[2], _fov[3], _near, _far, _oglNdc);
	}

	

	inline void mtxProj(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<Handness::Left>(_result, _ut, _dt, _lt, _rt, _near, _far, _oglNdc);
	}

	inline void mtxProj(float* _result, const float _fov[4], float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<Handness::Left>(_result, _fov, _near, _far, _oglNdc);
	}

	inline void mtxProj(float* _result, float _fovy, float _aspect, float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<Handness::Left>(_result, _fovy, _aspect, _near, _far, _oglNdc);
	}

	inline void mtxProjLh(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<Handness::Left>(_result, _ut, _dt, _lt, _rt, _near, _far, _oglNdc);
	}

	inline void mtxProjLh(float* _result, const float _fov[4], float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<Handness::Left>(_result, _fov, _near, _far, _oglNdc);
	}

	

	inline void mtxProjRh(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<Handness::Right>(_result, _ut, _dt, _lt, _rt, _near, _far, _oglNdc);
	}

	inline void mtxProjRh(float* _result, const float _fov[4], float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<Handness::Right>(_result, _fov, _near, _far, _oglNdc);
	}

	inline void mtxProjRh(float* _result, float _fovy, float _aspect, float _near, float _far, bool _oglNdc = false)
	{
		mtxProj_impl<Handness::Right>(_result, _fovy, _aspect, _near, _far, _oglNdc);
	}

	template <NearFar::Enum NearFarT, Handness::Enum HandnessT>
	inline void mtxProjInfXYWH(float* _result, float _x, float _y, float _width, float _height, float _near, bool _oglNdc = false)
	{
		float aa;
		float bb;
		if (BX_ENABLED(NearFar::Reverse == NearFarT) )
		{
			aa = _oglNdc ?       -1.0f :   0.0f;
			bb = _oglNdc ? -2.0f*_near : -_near;
		}
		else
		{
			aa = 1.0f;
			bb = _oglNdc ? 2.0f*_near : _near;
		}

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = _width;
		_result[ 5] = _height;
		_result[ 8] = (Handness::Right == HandnessT) ?    _x :  -_x;
		_result[ 9] = (Handness::Right == HandnessT) ?    _y :  -_y;
		_result[10] = (Handness::Right == HandnessT) ?   -aa :   aa;
		_result[11] = (Handness::Right == HandnessT) ? -1.0f : 1.0f;
		_result[14] = -bb;
	}

	template <NearFar::Enum NearFarT, Handness::Enum HandnessT>
	inline void mtxProjInf_impl(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, bool _oglNdc = false)
	{
		const float invDiffRl = 1.0f/(_rt - _lt);
		const float invDiffUd = 1.0f/(_ut - _dt);
		const float width  =  2.0f*_near * invDiffRl;
		const float height =  2.0f*_near * invDiffUd;
		const float xx     = (_rt + _lt) * invDiffRl;
		const float yy     = (_ut + _dt) * invDiffUd;
		mtxProjInfXYWH<NearFarT,HandnessT>(_result, xx, yy, width, height, _near, _oglNdc);
	}

	template <NearFar::Enum NearFarT, Handness::Enum HandnessT>
	inline void mtxProjInf_impl(float* _result, const float _fov[4], float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFarT,HandnessT>(_result, _fov[0], _fov[1], _fov[2], _fov[3], _near, _oglNdc);
	}

	template <NearFar::Enum NearFarT, Handness::Enum HandnessT>
	inline void mtxProjInf_impl(float* _result, float _fovy, float _aspect, float _near, bool _oglNdc = false)
	{
		const float height = 1.0f/tanf(toRad(_fovy)*0.5f);
		const float width  = height * 1.0f/_aspect;
		mtxProjInfXYWH<NearFarT,HandnessT>(_result, 0.0f, 0.0f, width, height, _near, _oglNdc);
	}

	inline void mtxProjInf(float* _result, const float _fov[4], float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Left>(_result, _fov, _near, _oglNdc);
	}

	inline void mtxProjInf(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Left>(_result, _ut, _dt, _lt, _rt, _near, _oglNdc);
	}

	inline void mtxProjInf(float* _result, float _fovy, float _aspect, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Left>(_result, _fovy, _aspect, _near, _oglNdc);
	}

	inline void mtxProjInfLh(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Left>(_result, _ut, _dt, _lt, _rt, _near, _oglNdc);
	}

	inline void mtxProjInfLh(float* _result, const float _fov[4], float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Left>(_result, _fov, _near, _oglNdc);
	}

	inline void mtxProjInfLh(float* _result, float _fovy, float _aspect, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Left>(_result, _fovy, _aspect, _near, _oglNdc);
	}

	inline void mtxProjInfRh(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Right>(_result, _ut, _dt, _lt, _rt, _near, _oglNdc);
	}

	inline void mtxProjInfRh(float* _result, const float _fov[4], float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Right>(_result, _fov, _near, _oglNdc);
	}

	inline void mtxProjInfRh(float* _result, float _fovy, float _aspect, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Default,Handness::Right>(_result, _fovy, _aspect, _near, _oglNdc);
	}

	inline void mtxProjRevInfLh(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Reverse,Handness::Left>(_result, _ut, _dt, _lt, _rt, _near, _oglNdc);
	}

	inline void mtxProjRevInfLh(float* _result, const float _fov[4], float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Reverse,Handness::Left>(_result, _fov, _near, _oglNdc);
	}

	inline void mtxProjRevInfLh(float* _result, float _fovy, float _aspect, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Reverse,Handness::Left>(_result, _fovy, _aspect, _near, _oglNdc);
	}

	inline void mtxProjRevInfRh(float* _result, float _ut, float _dt, float _lt, float _rt, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Reverse,Handness::Right>(_result, _ut, _dt, _lt, _rt, _near, _oglNdc);
	}

	inline void mtxProjRevInfRh(float* _result, const float _fov[4], float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Reverse,Handness::Right>(_result, _fov, _near, _oglNdc);
	}

	inline void mtxProjRevInfRh(float* _result, float _fovy, float _aspect, float _near, bool _oglNdc = false)
	{
		mtxProjInf_impl<NearFar::Reverse,Handness::Right>(_result, _fovy, _aspect, _near, _oglNdc);
	}

	template <Handness::Enum HandnessT>
	inline void mtxOrtho_impl(float* _result, float _left, float _right, float _bottom, float _top, float _near, float _far, float _offset = 0.0f, bool _oglNdc = false)
	{
		const float aa = 2.0f/(_right - _left);
		const float bb = 2.0f/(_top - _bottom);
		const float cc = (_oglNdc ? 2.0f : 1.0f) / (_far - _near);
		const float dd = (_left + _right)/(_left - _right);
		const float ee = (_top + _bottom)/(_bottom - _top);
		const float ff = _oglNdc ? (_near + _far)/(_near - _far) : _near/(_near - _far);

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = aa;
		_result[ 5] = bb;
		_result[10] = (Handness::Right == HandnessT) ? -cc : cc;
		_result[12] = dd + _offset;
		_result[13] = ee;
		_result[14] = ff;
		_result[15] = 1.0f;
	}

	inline void mtxOrtho(float* _result, float _left, float _right, float _bottom, float _top, float _near, float _far, float _offset = 0.0f, bool _oglNdc = false)
	{
		mtxOrtho_impl<Handness::Left>(_result, _left, _right, _bottom, _top, _near, _far, _offset, _oglNdc);
	}

	inline void mtxOrthoLh(float* _result, float _left, float _right, float _bottom, float _top, float _near, float _far, float _offset = 0.0f, bool _oglNdc = false)
	{
		mtxOrtho_impl<Handness::Left>(_result, _left, _right, _bottom, _top, _near, _far, _offset, _oglNdc);
	}

	inline void mtxOrthoRh(float* _result, float _left, float _right, float _bottom, float _top, float _near, float _far, float _offset = 0.0f, bool _oglNdc = false)
	{
		mtxOrtho_impl<Handness::Right>(_result, _left, _right, _bottom, _top, _near, _far, _offset, _oglNdc);
	}

	inline void mtxRotateX(float* _result, float _ax)
	{
		const float sx = fsin(_ax);
		const float cx = fcos(_ax);

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = 1.0f;
		_result[ 5] = cx;
		_result[ 6] = -sx;
		_result[ 9] = sx;
		_result[10] = cx;
		_result[15] = 1.0f;
	}
    
    inline void mtxRotateXScale(float* _result, float _ax, float scale)
    {
        const float sx = fsin(_ax) * scale;
        const float cx = fcos(_ax) * scale;
        
        memset(_result, 0, sizeof(float)*16);
        _result[ 0] = scale;
        _result[ 5] = cx;
        _result[ 6] = -sx;
        _result[ 9] = sx;
        _result[10] = cx;
        _result[15] = 1.0f;
    }


	inline void mtxRotateY(float* _result, float _ay)
	{
		const float sy = fsin(_ay);
		const float cy = fcos(_ay);

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = cy;
		_result[ 2] = sy;
		_result[ 5] = 1.0f;
		_result[ 8] = -sy;
		_result[10] = cy;
		_result[15] = 1.0f;
	}
    
    inline void mtxRotateYScale(float* _result, float _ay, float scale)
    {
        const float sy = fsin(_ay) * scale;
        const float cy = fcos(_ay) * scale;
        
        memset(_result, 0, sizeof(float)*16);
        _result[ 0] = cy;
        _result[ 2] = sy;
        _result[ 5] = scale;
        _result[ 8] = -sy;
        _result[10] = cy;
        _result[15] = 1.0f;
    }

	inline void mtxRotateZ(float* _result, float _az)
	{
		const float sz = fsin(_az);
		const float cz = fcos(_az);

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = cz;
		_result[ 1] = -sz;
		_result[ 4] = sz;
		_result[ 5] = cz;
		_result[10] = 1.0f;
		_result[15] = 1.0f;
	}

	inline void mtxRotateXY(float* _result, float _ax, float _ay)
	{
		const float sx = fsin(_ax);
		const float cx = fcos(_ax);
		const float sy = fsin(_ay);
		const float cy = fcos(_ay);

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = cy;
		_result[ 2] = sy;
		_result[ 4] = sx*sy;
		_result[ 5] = cx;
		_result[ 6] = -sx*cy;
		_result[ 8] = -cx*sy;
		_result[ 9] = sx;
		_result[10] = cx*cy;
		_result[15] = 1.0f;
	}
    
    inline void mtxRotateXYScale(float* _result, float _ax, float _ay, float scale)
    {
        const float sx = fsin(_ax);
        const float cx = fcos(_ax);
        const float sy = fsin(_ay);
        const float cy = fcos(_ay);
        
        memset(_result, 0, sizeof(float)*16);
        _result[ 0] = cy * scale;
        _result[ 2] = sy * scale;
        _result[ 4] = sx*sy * scale;
        _result[ 5] = cx * scale;
        _result[ 6] = -sx*cy * scale;
        _result[ 8] = -cx*sy * scale;
        _result[ 9] = sx * scale;
        _result[10] = cx*cy * scale;
        _result[15] = 1.0f;
    }

	inline void mtxRotateXYZ(float* _result, float _ax, float _ay, float _az)
	{
		const float sx = fsin(_ax);
		const float cx = fcos(_ax);
		const float sy = fsin(_ay);
		const float cy = fcos(_ay);
		const float sz = fsin(_az);
		const float cz = fcos(_az);

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = cy*cz;
		_result[ 1] = -cy*sz;
		_result[ 2] = sy;
		_result[ 4] = cz*sx*sy + cx*sz;
		_result[ 5] = cx*cz - sx*sy*sz;
		_result[ 6] = -cy*sx;
		_result[ 8] = -cx*cz*sy + sx*sz;
		_result[ 9] = cz*sx + cx*sy*sz;
		_result[10] = cx*cy;
		_result[15] = 1.0f;
	}

	inline void mtxRotateZYX(float* _result, float _ax, float _ay, float _az)
	{
		const float sx = fsin(_ax);
		const float cx = fcos(_ax);
		const float sy = fsin(_ay);
		const float cy = fcos(_ay);
		const float sz = fsin(_az);
		const float cz = fcos(_az);

		memset(_result, 0, sizeof(float)*16);
		_result[ 0] = cy*cz;
		_result[ 1] = cz*sx*sy-cx*sz;
		_result[ 2] = cx*cz*sy+sx*sz;
		_result[ 4] = cy*sz;
		_result[ 5] = cx*cz + sx*sy*sz;
		_result[ 6] = -cz*sx + cx*sy*sz;
		_result[ 8] = -sy;
		_result[ 9] = cy*sx;
		_result[10] = cx*cy;
		_result[15] = 1.0f;
	};

	inline void mtxSRT(float* _result, float _sx, float _sy, float _sz, float _ax, float _ay, float _az, float _tx, float _ty, float _tz)
	{
		const float sx = fsin(_ax);
		const float cx = fcos(_ax);
		const float sy = fsin(_ay);
		const float cy = fcos(_ay);
		const float sz = fsin(_az);
		const float cz = fcos(_az);

		const float sxsz = sx*sz;
		const float cycz = cy*cz;

		_result[ 0] = _sx * (cycz - sxsz*sy);
		_result[ 1] = _sx * -cx*sz;
		_result[ 2] = _sx * (cz*sy + cy*sxsz);
		_result[ 3] = 0.0f;

		_result[ 4] = _sy * (cz*sx*sy + cy*sz);
		_result[ 5] = _sy * cx*cz;
		_result[ 6] = _sy * (sy*sz -cycz*sx);
		_result[ 7] = 0.0f;

		_result[ 8] = _sz * -cx*sy;
		_result[ 9] = _sz * sx;
		_result[10] = _sz * cx*cy;
		_result[11] = 0.0f;

		_result[12] = _tx;
		_result[13] = _ty;
		_result[14] = _tz;
		_result[15] = 1.0f;
	}

	inline void vec3MulMtx(float* __restrict _result, const float* __restrict _vec, const float* __restrict _mat)
	{
		_result[0] = _vec[0] * _mat[ 0] + _vec[1] * _mat[4] + _vec[2] * _mat[ 8] + _mat[12];
		_result[1] = _vec[0] * _mat[ 1] + _vec[1] * _mat[5] + _vec[2] * _mat[ 9] + _mat[13];
		_result[2] = _vec[0] * _mat[ 2] + _vec[1] * _mat[6] + _vec[2] * _mat[10] + _mat[14];
	}
    
    

	inline void vec3MulMtxH(float* __restrict _result, const float* __restrict _vec, const float* __restrict _mat)
	{
		float xx = _vec[0] * _mat[ 0] + _vec[1] * _mat[4] + _vec[2] * _mat[ 8] + _mat[12];
		float yy = _vec[0] * _mat[ 1] + _vec[1] * _mat[5] + _vec[2] * _mat[ 9] + _mat[13];
		float zz = _vec[0] * _mat[ 2] + _vec[1] * _mat[6] + _vec[2] * _mat[10] + _mat[14];
		float ww = _vec[0] * _mat[ 3] + _vec[1] * _mat[7] + _vec[2] * _mat[11] + _mat[15];
		float invW = fsign(ww)/ww;
		_result[0] = xx*invW;
		_result[1] = yy*invW;
		_result[2] = zz*invW;
	}

	

	inline void mtxMul(float* __restrict _result, const float* __restrict _a, const float* __restrict _b)
	{
		vec4MulMtx(&_result[ 0], &_a[ 0], _b);
		vec4MulMtx(&_result[ 4], &_a[ 4], _b);
		vec4MulMtx(&_result[ 8], &_a[ 8], _b);
		vec4MulMtx(&_result[12], &_a[12], _b);
	}

	inline void mtxTranspose(float* __restrict _result, const float* __restrict _a)
	{
		_result[ 0] = _a[ 0];
		_result[ 4] = _a[ 1];
		_result[ 8] = _a[ 2];
		_result[12] = _a[ 3];
		_result[ 1] = _a[ 4];
		_result[ 5] = _a[ 5];
		_result[ 9] = _a[ 6];
		_result[13] = _a[ 7];
		_result[ 2] = _a[ 8];
		_result[ 6] = _a[ 9];
		_result[10] = _a[10];
		_result[14] = _a[11];
		_result[ 3] = _a[12];
		_result[ 7] = _a[13];
		_result[11] = _a[14];
		_result[15] = _a[15];
	}

	inline void mtx3Inverse(float* __restrict _result, const float* __restrict _a)
	{
		float xx = _a[0];
		float xy = _a[1];
		float xz = _a[2];
		float yx = _a[3];
		float yy = _a[4];
		float yz = _a[5];
		float zx = _a[6];
		float zy = _a[7];
		float zz = _a[8];

		float det = 0.0f;
		det += xx * (yy*zz - yz*zy);
		det -= xy * (yx*zz - yz*zx);
		det += xz * (yx*zy - yy*zx);

		float invDet = 1.0f/det;

		_result[0] = +(yy*zz - yz*zy) * invDet;
		_result[1] = -(xy*zz - xz*zy) * invDet;
		_result[2] = +(xy*yz - xz*yy) * invDet;

		_result[3] = -(yx*zz - yz*zx) * invDet;
		_result[4] = +(xx*zz - xz*zx) * invDet;
		_result[5] = -(xx*yz - xz*yx) * invDet;

		_result[6] = +(yx*zy - yy*zx) * invDet;
		_result[7] = -(xx*zy - xy*zx) * invDet;
		_result[8] = +(xx*yy - xy*yx) * invDet;
	}

	

	/// Convert LH to RH projection matrix and vice versa.
	inline void mtxProjFlipHandedness(float* __restrict _dst, const float* __restrict _src)
	{
		_dst[ 0] = -_src[ 0];
		_dst[ 1] = -_src[ 1];
		_dst[ 2] = -_src[ 2];
		_dst[ 3] = -_src[ 3];
		_dst[ 4] =  _src[ 4];
		_dst[ 5] =  _src[ 5];
		_dst[ 6] =  _src[ 6];
		_dst[ 7] =  _src[ 7];
		_dst[ 8] = -_src[ 8];
		_dst[ 9] = -_src[ 9];
		_dst[10] = -_src[10];
		_dst[11] = -_src[11];
		_dst[12] =  _src[12];
		_dst[13] =  _src[13];
		_dst[14] =  _src[14];
		_dst[15] =  _src[15];
	}

	/// Convert LH to RH view matrix and vice versa.
	inline void mtxViewFlipHandedness(float* __restrict _dst, const float* __restrict _src)
	{
		_dst[ 0] = -_src[ 0];
		_dst[ 1] =  _src[ 1];
		_dst[ 2] = -_src[ 2];
		_dst[ 3] =  _src[ 3];
		_dst[ 4] = -_src[ 4];
		_dst[ 5] =  _src[ 5];
		_dst[ 6] = -_src[ 6];
		_dst[ 7] =  _src[ 7];
		_dst[ 8] = -_src[ 8];
		_dst[ 9] =  _src[ 9];
		_dst[10] = -_src[10];
		_dst[11] =  _src[11];
		_dst[12] = -_src[12];
		_dst[13] =  _src[13];
		_dst[14] = -_src[14];
		_dst[15] =  _src[15];
	}

	inline void calcNormal(float _result[3], float _va[3], float _vb[3], float _vc[3])
	{
		float ba[3];
		vec3Sub(ba, _vb, _va);

		float ca[3];
		vec3Sub(ca, _vc, _va);

		float baxca[3];
		vec3Cross(baxca, ba, ca);

		vec3Norm(_result, baxca);
	}

	inline void calcPlane(float _result[4], float _va[3], float _vb[3], float _vc[3])
	{
		float normal[3];
		calcNormal(normal, _va, _vb, _vc);

		_result[0] = normal[0];
		_result[1] = normal[1];
		_result[2] = normal[2];
		_result[3] = -vec3Dot(normal, _va);
	}

	inline void calcLinearFit2D(float _result[2], const void* _points, uint32_t _stride, uint32_t _numPoints)
	{
		float sumX  = 0.0f;
		float sumY  = 0.0f;
		float sumXX = 0.0f;
		float sumXY = 0.0f;

		const uint8_t* ptr = (const uint8_t*)_points;
		for (uint32_t ii = 0; ii < _numPoints; ++ii, ptr += _stride)
		{
			const float* point = (const float*)ptr;
			float xx = point[0];
			float yy = point[1];
			sumX  += xx;
			sumY  += yy;
			sumXX += xx*xx;
			sumXY += xx*yy;
		}

		// [ sum(x^2) sum(x)    ] [ A ] = [ sum(x*y) ]
		// [ sum(x)   numPoints ] [ B ]   [ sum(y)   ]

		float det = (sumXX*_numPoints - sumX*sumX);
		float invDet = 1.0f/det;

		_result[0] = (-sumX * sumY + _numPoints * sumXY) * invDet;
		_result[1] = (sumXX * sumY - sumX       * sumXY) * invDet;
	}

	inline void calcLinearFit3D(float _result[3], const void* _points, uint32_t _stride, uint32_t _numPoints)
	{
		float sumX  = 0.0f;
		float sumY  = 0.0f;
		float sumZ  = 0.0f;
		float sumXX = 0.0f;
		float sumXY = 0.0f;
		float sumXZ = 0.0f;
		float sumYY = 0.0f;
		float sumYZ = 0.0f;

		const uint8_t* ptr = (const uint8_t*)_points;
		for (uint32_t ii = 0; ii < _numPoints; ++ii, ptr += _stride)
		{
			const float* point = (const float*)ptr;
			float xx = point[0];
			float yy = point[1];
			float zz = point[2];

			sumX  += xx;
			sumY  += yy;
			sumZ  += zz;
			sumXX += xx*xx;
			sumXY += xx*yy;
			sumXZ += xx*zz;
			sumYY += yy*yy;
			sumYZ += yy*zz;
		}

		// [ sum(x^2) sum(x*y) sum(x)    ] [ A ]   [ sum(x*z) ]
		// [ sum(x*y) sum(y^2) sum(y)    ] [ B ] = [ sum(y*z) ]
		// [ sum(x)   sum(y)   numPoints ] [ C ]   [ sum(z)   ]

		float mtx[9] =
		{
			sumXX, sumXY, sumX,
			sumXY, sumYY, sumY,
			sumX,  sumY,  float(_numPoints),
		};
		float invMtx[9];
		mtx3Inverse(invMtx, mtx);

		_result[0] = invMtx[0]*sumXZ + invMtx[1]*sumYZ + invMtx[2]*sumZ;
		_result[1] = invMtx[3]*sumXZ + invMtx[4]*sumYZ + invMtx[5]*sumZ;
		_result[2] = invMtx[6]*sumXZ + invMtx[7]*sumYZ + invMtx[8]*sumZ;
	}

	inline void rgbToHsv(float _hsv[3], const float _rgb[3])
	{
		const float rr = _rgb[0];
		const float gg = _rgb[1];
		const float bb = _rgb[2];

		const float s0 = fstep(bb, gg);

		const float px = flerp(bb,        gg,         s0);
		const float py = flerp(gg,        bb,         s0);
		const float pz = flerp(-1.0f,     0.0f,       s0);
		const float pw = flerp(2.0f/3.0f, -1.0f/3.0f, s0);

		const float s1 = fstep(px, rr);

		const float qx = flerp(px, rr, s1);
		const float qy = py;
		const float qz = flerp(pw, pz, s1);
		const float qw = flerp(rr, px, s1);

		const float dd = qx - fmin(qw, qy);
		const float ee = 1.0e-10f;

		_hsv[0] = fabsolute(qz + (qw - qy) / (6.0f * dd + ee) );
		_hsv[1] = dd / (qx + ee);
		_hsv[2] = qx;
	}

	inline void hsvToRgb(float _rgb[3], const float _hsv[3])
	{
		const float hh = _hsv[0];
		const float ss = _hsv[1];
		const float vv = _hsv[2];

		const float px = fabsolute(ffract(hh + 1.0f     ) * 6.0f - 3.0f);
		const float py = fabsolute(ffract(hh + 2.0f/3.0f) * 6.0f - 3.0f);
		const float pz = fabsolute(ffract(hh + 1.0f/3.0f) * 6.0f - 3.0f);

		_rgb[0] = vv * flerp(1.0f, fsaturate(px - 1.0f), ss);
		_rgb[1] = vv * flerp(1.0f, fsaturate(py - 1.0f), ss);
		_rgb[2] = vv * flerp(1.0f, fsaturate(pz - 1.0f), ss);
	}

} // namespace bx

#endif // BX_FPU_MATH_H_HEADER_GUARD



#ifndef BX_FLOAT4X4_H_HEADER_GUARD
#define BX_FLOAT4X4_H_HEADER_GUARD

#include "simd_t.h"

namespace bx
{
	BX_ALIGN_DECL_16(struct) float4x4_t
	{
		simd128_t col[4];
	};

	BX_SIMD_FORCE_INLINE simd128_t simd_mul_xyz1(simd128_t _a, const float4x4_t* _b)
	{
		const simd128_t xxxx   = simd_swiz_xxxx(_a);
		const simd128_t yyyy   = simd_swiz_yyyy(_a);
		const simd128_t zzzz   = simd_swiz_zzzz(_a);
		const simd128_t col0   = simd_mul(_b->col[0], xxxx);
		const simd128_t col1   = simd_mul(_b->col[1], yyyy);
		const simd128_t col2   = simd_madd(_b->col[2], zzzz, col0);
		const simd128_t col3   = simd_add(_b->col[3], col1);
		const simd128_t result = simd_add(col2, col3);

		return result;
	}

	BX_SIMD_FORCE_INLINE simd128_t simd_mul(simd128_t _a, const float4x4_t* _b)
	{
		const simd128_t xxxx   = simd_swiz_xxxx(_a);
		const simd128_t yyyy   = simd_swiz_yyyy(_a);
		const simd128_t zzzz   = simd_swiz_zzzz(_a);
		const simd128_t wwww   = simd_swiz_wwww(_a);
		const simd128_t col0   = simd_mul(_b->col[0], xxxx);
		const simd128_t col1   = simd_mul(_b->col[1], yyyy);
		const simd128_t col2   = simd_madd(_b->col[2], zzzz, col0);
		const simd128_t col3   = simd_madd(_b->col[3], wwww, col1);
		const simd128_t result = simd_add(col2, col3);

		return result;
	}

	BX_SIMD_INLINE void float4x4_mul_scalar(float4x4_t* __restrict _result, const float4x4_t* __restrict _a, float scalar)
	{
		simd128_t b = simd_splat(scalar);
		_result->col[0] = simd_mul(_a->col[0], b);
		_result->col[1] = simd_mul(_a->col[1], b);
		_result->col[2] = simd_mul(_a->col[2], b);
		_result->col[3] = simd_mul(_a->col[3], b);
	}

	BX_SIMD_INLINE void float4x4_mul(float4x4_t* __restrict _result, const float4x4_t* __restrict _a, const float4x4_t* __restrict _b)
	{
		_result->col[0] = simd_mul(_a->col[0], _b);
		_result->col[1] = simd_mul(_a->col[1], _b);
		_result->col[2] = simd_mul(_a->col[2], _b);
		_result->col[3] = simd_mul(_a->col[3], _b);
	}

	BX_SIMD_INLINE void float4x4_add(float4x4_t* __restrict _result, const float4x4_t* __restrict _a, const float4x4_t* __restrict _b)
	{
		_result->col[0] = simd_add(_a->col[0], _b->col[0]);
		_result->col[1] = simd_add(_a->col[1], _b->col[1]);
		_result->col[2] = simd_add(_a->col[2], _b->col[2]);
		_result->col[3] = simd_add(_a->col[3], _b->col[3]);
	}

	BX_SIMD_FORCE_INLINE void float4x4_transpose(float4x4_t* __restrict _result, const float4x4_t* __restrict _mtx)
	{
		const simd128_t aibj = simd_shuf_xAyB(_mtx->col[0], _mtx->col[2]); // aibj
		const simd128_t emfn = simd_shuf_xAyB(_mtx->col[1], _mtx->col[3]); // emfn
		const simd128_t ckdl = simd_shuf_zCwD(_mtx->col[0], _mtx->col[2]); // ckdl
		const simd128_t gohp = simd_shuf_zCwD(_mtx->col[1], _mtx->col[3]); // gohp
		_result->col[0] = simd_shuf_xAyB(aibj, emfn); // aeim
		_result->col[1] = simd_shuf_zCwD(aibj, emfn); // bfjn
		_result->col[2] = simd_shuf_xAyB(ckdl, gohp); // cgko
		_result->col[3] = simd_shuf_zCwD(ckdl, gohp); // dhlp
	}

	BX_SIMD_INLINE void float4x4_inverse(float4x4_t* __restrict _result, const float4x4_t* __restrict _a)
	{
		const simd128_t tmp0 = simd_shuf_xAzC(_a->col[0], _a->col[1]);
		const simd128_t tmp1 = simd_shuf_xAzC(_a->col[2], _a->col[3]);
		const simd128_t tmp2 = simd_shuf_yBwD(_a->col[0], _a->col[1]);
		const simd128_t tmp3 = simd_shuf_yBwD(_a->col[2], _a->col[3]);
		const simd128_t t0   = simd_shuf_xyAB(tmp0, tmp1);
		const simd128_t t1   = simd_shuf_xyAB(tmp3, tmp2);
		const simd128_t t2   = simd_shuf_zwCD(tmp0, tmp1);
		const simd128_t t3   = simd_shuf_zwCD(tmp3, tmp2);

		const simd128_t t23 = simd_mul(t2, t3);
		const simd128_t t23_yxwz = simd_swiz_yxwz(t23);
		const simd128_t t23_wzyx = simd_swiz_wzyx(t23);

		simd128_t cof0, cof1, cof2, cof3;

		const simd128_t zero = simd_zero();
		cof0 = simd_nmsub(t1, t23_yxwz, zero);
		cof0 = simd_madd(t1, t23_wzyx, cof0);

		cof1 = simd_nmsub(t0, t23_yxwz, zero);
		cof1 = simd_madd(t0, t23_wzyx, cof1);
		cof1 = simd_swiz_zwxy(cof1);

		const simd128_t t12 = simd_mul(t1, t2);
		const simd128_t t12_yxwz = simd_swiz_yxwz(t12);
		const simd128_t t12_wzyx = simd_swiz_wzyx(t12);

		cof0 = simd_madd(t3, t12_yxwz, cof0);
		cof0 = simd_nmsub(t3, t12_wzyx, cof0);

		cof3 = simd_mul(t0, t12_yxwz);
		cof3 = simd_nmsub(t0, t12_wzyx, cof3);
		cof3 = simd_swiz_zwxy(cof3);

		const simd128_t t1_zwxy = simd_swiz_zwxy(t1);
		const simd128_t t2_zwxy = simd_swiz_zwxy(t2);

		const simd128_t t13 = simd_mul(t1_zwxy, t3);
		const simd128_t t13_yxwz = simd_swiz_yxwz(t13);
		const simd128_t t13_wzyx = simd_swiz_wzyx(t13);

		cof0 = simd_madd(t2_zwxy, t13_yxwz, cof0);
		cof0 = simd_nmsub(t2_zwxy, t13_wzyx, cof0);

		cof2 = simd_mul(t0, t13_yxwz);
		cof2 = simd_nmsub(t0, t13_wzyx, cof2);
		cof2 = simd_swiz_zwxy(cof2);

		const simd128_t t01 = simd_mul(t0, t1);
		const simd128_t t01_yxwz = simd_swiz_yxwz(t01);
		const simd128_t t01_wzyx = simd_swiz_wzyx(t01);

		cof2 = simd_nmsub(t3, t01_yxwz, cof2);
		cof2 = simd_madd(t3, t01_wzyx, cof2);

		cof3 = simd_madd(t2_zwxy, t01_yxwz, cof3);
		cof3 = simd_nmsub(t2_zwxy, t01_wzyx, cof3);

		const simd128_t t03 = simd_mul(t0, t3);
		const simd128_t t03_yxwz = simd_swiz_yxwz(t03);
		const simd128_t t03_wzyx = simd_swiz_wzyx(t03);

		cof1 = simd_nmsub(t2_zwxy, t03_yxwz, cof1);
		cof1 = simd_madd(t2_zwxy, t03_wzyx, cof1);

		cof2 = simd_madd(t1, t03_yxwz, cof2);
		cof2 = simd_nmsub(t1, t03_wzyx, cof2);

		const simd128_t t02 = simd_mul(t0, t2_zwxy);
		const simd128_t t02_yxwz = simd_swiz_yxwz(t02);
		const simd128_t t02_wzyx = simd_swiz_wzyx(t02);

		cof1 = simd_madd(t3, t02_yxwz, cof1);
		cof1 = simd_nmsub(t3, t02_wzyx, cof1);

		cof3 = simd_nmsub(t1, t02_yxwz, cof3);
		cof3 = simd_madd(t1, t02_wzyx, cof3);

		const simd128_t det    = simd_dot(t0, cof0);
		const simd128_t invdet = simd_rcp(det);

		_result->col[0] = simd_mul(cof0, invdet);
		_result->col[1] = simd_mul(cof1, invdet);
		_result->col[2] = simd_mul(cof2, invdet);
		_result->col[3] = simd_mul(cof3, invdet);
	}

} // namespace bx

#endif // BX_FLOAT4X4_H_HEADER_GUARD


*/