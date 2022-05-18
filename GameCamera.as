package {
	import flash.events.*;
	import flash.ui.*;
	import flash.display.Stage;
	
	import flash.geom.Vector3D;

	public class GameCamera {

		
		private var counter: Number = 0;
		private var iterator:int = 0;

		public var position: Point3d;
		public var positionMinusZ:Point3d;
		public var rotation: Point3d;
		public var scale: Vector3;

		
		private var theStage: Stage;

		public var zNear;
		public var zFar = 10000;
		private var fieldOfView: Number = 30;

		public var aspectRatio:Number ;
		public var fovY:Number;
		

		public function GameCamera(_theStage: Stage, _position: Point3d, _rotation: Point3d) {
			// constructor code
			theStage = _theStage;
			position = _position;
			rotation = _rotation;
			scale = new Vector3(1, 1, 1);
			
			
			
			zNear = (Engine.resolutionX / 2.0) / Math.tan(EngineMath.degreesToRad(fieldOfView / 2.0));
			aspectRatio = Engine.resolutionX / Engine.resolutionY;
			
			//get the field of view from top to bottom
			var oneDivAspectRatio:Number = 1.0/aspectRatio;
			fovY = 2 * Math.atan(Math.tan(EngineMath.degreesToRad(fieldOfView) / 2.0) * oneDivAspectRatio);

			
			positionMinusZ = new Point3d(position.x, position.y, position.z-zNear);
			position.z += zNear;
			positionMinusZ.z += zNear;

		}
	
		


		public function getPosition(): Point3d {
			return positionMinusZ;//MinusZ
		}

		public function getRotation(): Point3d {
			return rotation;
		}

		private function collidingPlus(dir:Vector3, ms:Number):Boolean
		{
			var isColission:Boolean = false;
			var p:Point3d = new Point3d(positionMinusZ.x + (dir.x *ms), positionMinusZ.y + (dir.y *ms), positionMinusZ.z + (dir.z *ms)  );

			outer : for(var i:int = 0; i < Engine.gO.length; i++)
			{
				var go:GameObject = Engine.gO[i];
				var boundingBox:Object = go.boundingBox;
				if(boundingBox)
				{
					for(var k:String in boundingBox)
					{
						if(boundingBox[k] is Point3d)
						{
							var edgeVertex:Point3d = boundingBox[k];
							isColission = go.checkColission(Engine.translate(edgeVertex, p));
							if(isColission)
							{
								break outer;
							}
						}
					}
				}
			}
			return isColission;
			
		}

		private function collidingMinus(dir:Vector3, ms:Number):Boolean
		{
			var isColission:Boolean = false;
			var mpZ:Point3d = new Point3d(positionMinusZ.x - (dir.x *ms), positionMinusZ.y - (dir.y *ms), positionMinusZ.z - (dir.z *ms)  );

			outer : for(var i:int = 0; i < Engine.gO.length; i++)
			{
				var go:GameObject = Engine.gO[i];
				var boundingBox:Object = go.boundingBox;
				if(boundingBox)
				{
					for(var k:String in boundingBox)
					{
						if(boundingBox[k] is Point3d)
						{
							var edgeVertex:Point3d = boundingBox[k];
							isColission = go.checkColission(Engine.translate(edgeVertex, mpZ));
							if(isColission)
							{
								//go.setFrameColor(Math.random() * 0xffffff);
								break outer;
							}
							
						}
					}
				}
				
				
			}
			return isColission;
			
		}

		

		public function update(elapsedTime:Number): void {

			var COS: Number;
			var SIN: Number;
			
			var moveVector: Point3d;
			
		
			var ms:Number = Engine.moveSpeed * elapsedTime;
			var rs:Number = Engine.rotateSpeed * elapsedTime;
			ms /= 2;



			if (InputHandler.W) {
				
				
				
				
				/*
				var deltaX:Number = ms * (rotation.x * rotation.z + rotation.w * rotation.y);
				var deltaY:Number = ms * (rotation.y * rotation.z - rotation.w * rotation.x);
				var deltaZ:Number = (ms/2) - ms * (rotation.x * rotation.x + rotation.y * rotation.y);
				position.x += deltaX;
				position.y += deltaY;
				position.z += deltaZ;

				positionMinusZ.x += deltaX;
				positionMinusZ.y += deltaY;
				positionMinusZ.z += deltaZ;
				*/
				
				var deltaZ:Number = ms * Math.cos(rotation.y) ;
				var deltaX:Number = ms * Math.sin(rotation.y) ;
				position.x += deltaX;
				position.z += deltaZ;

				positionMinusZ.x += deltaX;
				positionMinusZ.z += deltaZ;
				

				
			}

			if (InputHandler.S) {
				/*
				var deltaX:Number = ms * (rotation.x * rotation.z + rotation.w * rotation.y);
				var deltaY:Number = ms * (rotation.y * rotation.z - rotation.w * rotation.x);
				var deltaZ:Number = (ms/2) - ms * (rotation.x * rotation.x + rotation.y * rotation.y);

				position.x -= deltaX;
				position.y -= deltaY;
				position.z -= deltaZ;

				positionMinusZ.x -= deltaX;
				positionMinusZ.y -= deltaY;
				positionMinusZ.z -= deltaZ;
				*/
				
				var deltaZ:Number = ms * Math.cos(rotation.y) ;
				var deltaX:Number = ms * Math.sin(rotation.y) ;
				position.x -= deltaX;
				position.z -= deltaZ;

				positionMinusZ.x -= deltaX;
				positionMinusZ.z -= deltaZ;
				
				
			}

			if (InputHandler.D) {
				
				var deltaZ:Number = ms * Math.sin(rotation.y) ;
				var deltaX:Number = ms * Math.cos(rotation.y) ;
				
				position.z -= deltaZ;
				position.x += deltaX;
				
				positionMinusZ.x += deltaX;
				positionMinusZ.z -= deltaZ;
				
				/*
				var deltaX:Number = (ms/2) - ms * (rotation.y * rotation.y + rotation.z * rotation.z);
				var deltaY:Number = ms * (rotation.x * rotation.y + rotation.w * rotation.z);
				var deltaZ:Number = ms * (rotation.x * rotation.z - rotation.w * rotation.y);

				position.x += deltaX;
				position.y += deltaY;
				position.z += deltaZ;

				positionMinusZ.x += deltaX;
				positionMinusZ.y += deltaY;
				positionMinusZ.z += deltaZ;
				*/
				
				
				
			}


			if (InputHandler.A) {
				
				
				var deltaZ:Number = ms * Math.sin(rotation.y) ;
				var deltaX:Number = ms * Math.cos(rotation.y) ;
				
				position.z += deltaZ;
				position.x -= deltaX;
				
				positionMinusZ.z += deltaZ;
				positionMinusZ.x -= deltaX;
				
				//strafe left
				//left vector
				/*
				var deltaX:Number = (ms/2) - ms * (rotation.y * rotation.y + rotation.z * rotation.z);
				var deltaY:Number = ms * (rotation.x * rotation.y + rotation.w * rotation.z);
				var deltaZ:Number = ms * (rotation.x * rotation.z - rotation.w * rotation.y);

				position.x -= deltaX;
				position.y -= deltaY;
				position.z -= deltaZ;

				positionMinusZ.x -= deltaX;
				positionMinusZ.y -= deltaY;
				positionMinusZ.z -= deltaZ;
				*/
				
				
				
			}

			if (InputHandler.right) {
				rotation.y += .1;
				

			}

			if (InputHandler.left) {
				rotation.y -= .1;
			}




		}

		public function lookDown(rs:Number):void
		{
			/*
			var moveVector: Point3d;
			var quat1: Quaternion;
			moveVector = new Point3d(-rs * EngineMath.MATH_DEG_TO_RAD, 0, 0);
			quat1 = EngineMath.eulerToQuat(moveVector);
			rotation = EngineMath.quatMul(rotation, quat1);
			*/
		}

		public function lookUp(rs:Number):void
		{
			/*
			var moveVector: Point3d;
			var quat1: Quaternion;
			moveVector = new Point3d(rs * EngineMath.MATH_DEG_TO_RAD, 0, 0);
			quat1 = EngineMath.eulerToQuat(moveVector);
			rotation = EngineMath.quatMul(rotation, quat1);
			*/
		}


		
		

		

		

	}

}