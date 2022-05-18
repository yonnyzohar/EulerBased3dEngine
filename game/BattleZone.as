package game{
	import flash.geom.Point;
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Rectangle;
	import assets.*;


	public class BattleZone extends Engine {

		protected var player: Player;
		private var tileSize:Number = 200;
		private var map:Array = [
			[1,1,0,1,0,1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0],
			[1,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
			[3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
			[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			[1,0,1,0,1,0,1,0,0,1,0,1,0,1,0,1,1,0,1,0,0,1,0,0,1,0]
		];

		private var initialCamPosX:Number;
		private var initialCamPosZ:Number;
		private var initialCamPosY:Number;
		private var showStats:Boolean = false;

		override protected function initGameObjects():void
		{
			wireFrameColor = 0x00ff00;

			var arr: Array = [new Img0(), new Img1(), new Img2(), new Img3(), new Img4, new Img5()];

			for(var row:int = map.length-1; row >= 0; row--)
			{
				for(var col:int = 0; col < map[row].length; col++)
				{
					var _tRow:int = (map.length-1) - row;
					var _z:Number = _tRow * tileSize;
					var _x:Number = col * tileSize;
					var position: Point3d = new Point3d(_x, 200, _z);
					var rotation: Point3d = new Point3d(0, 0, 0);
					var scale: Point3d = new Point3d(1, 1, 1);
					if(row % 4 == 0 && col % 4 == 0)
					{
						var f: Plane = new Plane(position, rotation, scale, arr[0]);
						f.setFrameColor( 0x666666);
						gameObjects.push(f);
						f.destructable = false;
						f.collideable = false;
					}

					if(map[row][col] == 1)
					{	
						position = new Point3d(_x, 0, _z);
						rotation = new Point3d(0, 0, 0);
						scale = new Point3d( 1, 1, 1);
						var p: Pyramid = new Pyramid(position, rotation, scale, arr[0]);
						p.setFrameColor(0xffffff * Math.random());
						gameObjects.push(p);
						p.destructable = false;
					}
					if(map[row][col] == 2)
					{
						initialCamPosZ = _z;
						initialCamPosX = _x;
						initialCamPosY = 50;
					}
					
					if(map[row][col] == 4)
					{
						position = new Point3d(_x, 50, _z);
						rotation = new Point3d(0, 0, 0, 1);
						scale = new Point3d(1, 1, 1);
						var c: Tank = new Tank(position, rotation, scale, arr[0]);
						c.setFrameColor(0xffffff);
						gameObjects.push(c);
					}
					
				}
			}
		}

		override protected function initCamera():void
		{
			var camPos: Point3d = new Point3d(initialCamPosX, initialCamPosY, initialCamPosZ);
			var camRot: Point3d = new Point3d(0, 0, 0, 1);

			player = new Player(stage, camPos, camRot);
			activeCamera = player as GameCamera;
		}

		private function drawLine(start:Vector3, end:Vector3, color:uint = 0xffffff):void
		{
			var distanceH: Number = EngineMath.getDistance(start, end);
			var distanceX: Number = end.x - start.x;
			var distanceY: Number = end.y - start.y;

			var cos: Number = distanceX / distanceH;
			var sin: Number = distanceY / distanceH;

			var startX: Number = start.x;
			var startY: Number = start.y;

			for (var i: int = 0; i < distanceH; i++) {
				Engine.bd.setPixel(startX, startY, color);
				startX += cos;
				startY += sin;
			}
		}

		private function drawRotation(rotationY:Number, startX:Number, startY:Number):void
		{
			
				for(var j:int = 1; j < 10; j++)
				{
					//in 2d, the 0 degree faces left. in 3d the 0 degree faces towards the positive z!!
					//so when converting we need to subtract a quarter circle
					var newX:Number = Math.cos(rotationY - Math.PI/2) * j;
					var newY:Number = Math.sin(rotationY - Math.PI/2) * j;
					//newY = mapH - newY;
					Engine.bd.setPixel(startX+newX, startY+newY, 0xff0000);
				}
		}


		override public function lateUpdate():void
		{
			if(showStats)
			{
				return;
				var inverse:Boolean = false;
				//2d works by have 0,0 at top left corner. y grows as you move down
				//3d works by placing 0,0,0 of the world center world, and z grows as you move forward
				//to translate this we need to inverse y, since it needs to grow as you move north, not as in 2d, 
				//where it grows as you move south
				var shrinkScale:Number = 0.02;
				var mapH:Number = (map[0].length * tileSize * shrinkScale )+ 100;
				var camPos:Point3d = activeCamera.getPosition();
				var camPosX:Number = Number(camPos.x*shrinkScale);
				var camPosY:Number = Number(camPos.z*shrinkScale);

				if(inverse)camPosY = mapH - camPosY - (mapH/2);

				//var rot:Point3d = EngineMath.quatToEuler(activeCamera.rotation);
				drawRotation(rot.y , camPosX, camPosY);
				

				Engine.bd.setPixel(camPosX, camPosY, 0xffff00);


				for(var i:int = 0; i < gameObjects.length; i++)
				{
					if(!gameObjects[i].rendered)
					{
						continue;
					}

					var boundingBox:Object = gameObjects[i].boundingBox;
					var position:Point3d = gameObjects[i].position;
					if(boundingBox)
					{
						var minZ:Number = (position.z + boundingBox.frontBtmLeft.z)*shrinkScale;
						var maxZ:Number = (position.z + boundingBox.backBtmLeft.z)*shrinkScale;

						if(inverse)minZ = mapH - minZ - (mapH/2);
						if(inverse)maxZ = mapH - maxZ - (mapH/2);

						var minX:Number = (position.x + boundingBox.frontBtmLeft.x)*shrinkScale;
						var maxX:Number = (position.x + boundingBox.backBtmRight.x)*shrinkScale;
						

						drawLine( new Vector3(minX,minZ,0), new Vector3(minX,maxZ,0));
						drawLine( new Vector3(minX,maxZ,0), new Vector3(maxX,maxZ,0));
						drawLine( new Vector3(maxX,maxZ,0), new Vector3(maxX,minZ,0));
						drawLine( new Vector3(maxX,minZ,0), new Vector3(minX,minZ,0));
					}

					if(gameObjects[i].destructable)
					{
						var rot:Point3d = EngineMath.quatToEuler(gameObjects[i].rotation);
						var entX:Number = Number(position.x*shrinkScale);
						var entY:Number = Number(position.z*shrinkScale);
						if(inverse)
						{
							entY = mapH - entY - (mapH/2);
							rot.y *= -1;
						}


						drawRotation(rot.y * -1, entX, entY);
						Engine.bd.setPixel(entX, entY, 0xffff00);
					}
				}
			}

			var color:uint = 0xffff00;
			if(InputHandler.SPACE)
			{
				color = 0xff0000;
			}

			var cX:int = resolutionX/2;
			var cY:int = resolutionY/2;
			var h:int = 20;

			for(var g:int = -2; g < 3; g++)
			{
				drawLine( new Vector3(cX-h,cY+g,0),   new Vector3(cX-(h/2),cY+g,0),color);
				drawLine( new Vector3(cX+(h/2),cY+g,0), new Vector3(cX+h,cY+g,0),color);

				drawLine( new Vector3(cX+g,cY-h,0), new Vector3(cX+g,cY -(h/2),0),color);
				drawLine( new Vector3(cX+g,cY+h/2,0), new Vector3(cX+g,cY +h,0),color);

			}

			
			
			//draw floor line
			/*
			for(var i:int = 0; i < Engine.bd.width; i++)
			{
				Engine.bd.setPixel(i, Engine.bd.height/2, wireFrameColor);
			}*/

		}
	}
}