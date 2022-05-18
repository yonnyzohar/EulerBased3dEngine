package {
	import flash.geom.Point;
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	/*
	take note:
	z is left (columns)
	x is forwards (rows)

	*/


	public class Engine extends MovieClip {


		public static var resolutionX: Number;
		public static var resolutionY: Number;
		public static var wireFrameColor:uint = 0xffffff;


		public static var moveSpeed: Number = 2;
		public static var rotateSpeed: Number = .1;

		protected var gameObjects: Array = [];
		private var currTime: Number;
		private var prevTime: Number;
		

		private var bmp: Bitmap;
		public static var bd: BitmapData;
		private var zBuffer: Array = [];
		
		public static var gO:Array ;

		public static var activeCamera:GameCamera;
		private var inputHandler:InputHandler;


		public function Engine() {
			// constructor code
			//stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			resolutionX = stage.stageWidth;
			resolutionY = stage.stageHeight;

			currTime = getTimer();
			prevTime = getTimer();


			bd = new BitmapData(resolutionX, resolutionY, false);
			bmp = new Bitmap(bd);
			stage.addChild(bmp);

			//var arr: Array = [new Img0(), new Img1(), new Img2(), new Img3(), new Img4, new Img5()];

			
			
			Engine.gO = gameObjects;
			initGameObjects();
			initCamera();

			stage.addEventListener(Event.ENTER_FRAME, update);
			inputHandler = new InputHandler(stage);


		}



		public static function removeEntity(entity:GameObject):void
		{
			var index:int = Engine.gO.indexOf(entity);
			Engine.gO.splice(index,1);
		}


		protected function initGameObjects():void
		{

		}

		protected function initCamera():void
		{
			
		}

		private function update(e: Event): void {

			currTime = getTimer();
			
			var elapsedTime: Number = currTime - prevTime;

			if(elapsedTime < .1)
			{
				elapsedTime = .1;
			}


			Engine.bd.lock();
			var i: int = 0;
			for (i = 0; i < resolutionX * resolutionY; i++) {
				zBuffer[i] = 0;
			}
			
			Engine.bd.fillRect(new Rectangle(0, 0, resolutionX, resolutionY), 0x000000);
			activeCamera.update(elapsedTime);

			var totalPolygonsPreClip: Array = [];
			for (i = 0; i < gameObjects.length; i++) {
				var go: GameObject = gameObjects[i];
				//this is for updating position, rotation and scale
				go.update(elapsedTime);
				go.rendered = false;
				//if(go.isObjectInView(activeCamera))
				{
					go.rendered = true;
					//now we need to get all polygons from all game objects and sort them by average z
					var polygons: Array = go.polygons;
					for (var j: int = 0; j < polygons.length; j++) {
						polygons[j].calculateWorldPos(go.rotation, go.position);
						polygons[j].calculateCameraView(activeCamera);
						totalPolygonsPreClip.push(polygons[j]);

					}
				}
				

				
			}
		

			//sorting by average z will solve most z index issues but not all
			//totalPolygonsPreClip.sortOn("averageZ", Array.NUMERIC | Array.DESCENDING);//, 

			var totalPolygons: Array = [];
			for (var j: int = 0; j < totalPolygonsPreClip.length; j++) {
				var polygon: Polygon = totalPolygonsPreClip[j];
				
				var clippedTriangles: Array = polygon.getZClippedTriangles();

				for (var h: int = 0; h < clippedTriangles.length; h++) {
					totalPolygons.push(clippedTriangles[h]);
				}
			}
			

			//we still need to render only the polygons facing us
			//we created the polygon indices in clockwise order sow we can check who is facing us and who is not
			//once we have that we can call draw only on those who face us
			for (i = 0; i < totalPolygons.length; i++) {
				var polygon: Polygon = totalPolygons[i];
				polygon.calculateScreenPos();
				/**/
				//if z is negative that means the polygon is facing us
				if (polygon.normalZ < 0) //
				{
					var clippedPolygons: Array = polygon.getClippedTriangles();
					for (var j: int = 0; j < clippedPolygons.length; j++) {
						clippedPolygons[j].draw(zBuffer);
					}

				}
			}

			

			lateUpdate();

			Engine.bd.unlock();
			prevTime = currTime;
			//stage.removeEventListener(Event.ENTER_FRAME, update);

		}

		public function lateUpdate():void
		{
			
		}

		public static function translate(orig: Point3d, translation: Point3d): Point3d {
			var newPoint: Point3d = new Point3d(orig.x + translation.x, orig.y + translation.y, orig.z + translation.z, orig.u, orig.v);
			newPoint.w = orig.w;
			return newPoint
		}

		

		/**/
		

		
		//old euler based rotation
		public static function rotate(original: Point3d, rotation: Point3d): Point3d {
			var cos = Math.cos;
			var sin = Math.sin;


			var returnX: Number = original.x * (cos(rotation.z) * cos(rotation.y)) + original.y * (cos(rotation.z) * sin(rotation.y) * sin(rotation.x) - sin(rotation.z) * cos(rotation.x)) + original.z * (cos(rotation.z) * sin(rotation.y) * cos(rotation.x) + sin(rotation.z) * sin(rotation.x));
			var returnY: Number = original.x * (sin(rotation.z) * cos(rotation.y)) + original.y * (sin(rotation.z) * sin(rotation.y) * sin(rotation.x) + cos(rotation.z) * cos(rotation.x)) + original.z * (sin(rotation.z) * sin(rotation.y) * cos(rotation.x) - cos(rotation.z) * sin(rotation.x));
			var returnZ: Number = original.x * (-sin(rotation.y)) + original.y * (cos(rotation.y) * sin(rotation.x)) + original.z * (cos(rotation.y) * cos(rotation.x));

			var newPoint: Point3d = new Point3d(returnX, returnY, returnZ, original.u, original.v);
			newPoint.w = original.w;

			return newPoint;

		}
		




		////////////////////////////////////////////////

		public static function applyPerspective(orig: Point3d): Point3d {
			var zNear: Number = Engine.activeCamera.zNear;
			var scale:Number = (zNear / (zNear + orig.z));

			var returnX: Number = orig.x * scale;
			var returnY: Number = orig.y * scale;
			var returnZ: Number = orig.z;

			//this is to fix texture warping
			var returnU: Number = orig.u * scale;
			var returnV: Number = orig.v * scale;
			var returnW: Number = orig.w * scale;

			var newPoint: Point3d = new Point3d(returnX, returnY, returnZ, returnU, returnV);
			newPoint.w = returnW;

			return newPoint;
		}

		public static function centerScreen(orig: Point3d): Point3d {
			var returnX: Number = orig.x + resolutionX / 2;
			var returnY: Number = orig.y + resolutionY / 2;
			var returnZ: Number = orig.z;

			var newPoint: Point3d = new Point3d(returnX, returnY, returnZ, orig.u, orig.v);
			newPoint.w = orig.w;
			return newPoint;

		}



		/////////////////-------------------------/////////////////////////////////


	}

}