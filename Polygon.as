package {
	import flash.display.BitmapData;

	public class Polygon {


		public var localPositions: Array; //model - > the poins in local space according to 0,0
		private var worldPositions: Array; //world - > the points in the world space according to world 0,0
		private var cameraPositions: Array; //view -> the points in relation to the camera position
		private var screenPositions: Array; //projection - > the 3d points projected to a 2d x,y screen

		private var p1: Point3d;
		private var p2: Point3d;
		private var p3: Point3d;
		private var bd: BitmapData;
		public var averageZ: Number;
		public var normalZ: Number;
		private var wireFrameColor:uint;

		public function Polygon(_p1: Point3d, _p2: Point3d, _p3: Point3d, _bd: BitmapData, _wireFrameColor:uint = 0xffffff) 
		{
			p1 = _p1;
			p2 = _p2;
			p3 = _p3;
			localPositions = [p1, p2, p3];
			worldPositions = [p1, p2, p3];
			screenPositions = [p1, p2, p3];
			cameraPositions = [p1, p2, p3];
			bd = _bd;
			wireFrameColor = _wireFrameColor;
		}

		public function setFrameColor(color:uint):void
		{
			wireFrameColor = color;
		}

		public function getLocalPositions(): Array {
			return localPositions;
		}

		public function getWorldPositions(): Array {
			return worldPositions;
		}

		public function getCameraPositions(): Array {
			return cameraPositions;
		}

		public function getScreenPositions(): Array {
			return screenPositions;
		}

		public function calculateWorldPos(_rotation: Point3d, _position: Point3d): void {


			worldPositions[0] = getWorldTranslation(p1, _rotation, _position);
			worldPositions[1] = getWorldTranslation(p2, _rotation, _position);
			worldPositions[2] = getWorldTranslation(p3, _rotation, _position);

		}

		public function calculateCameraView(camera: GameCamera) {

			var i: int = 0;


			// Translate
			var cameraPos: Point3d = camera.getPosition();
			var translateBy: Point3d = new Point3d(-cameraPos.x, -cameraPos.y, -cameraPos.z);
			for (i = 0; i < 3; i++) {
				cameraPositions[i] = Engine.translate(worldPositions[i], translateBy);
			}


			// Rotate
			var cameraRot: Point3d = camera.getRotation();
			var rotateBy: Point3d = new Point3d(-cameraRot.x, -cameraRot.y, -cameraRot.z);
			for (i = 0; i < 3; i++) {
				var camPos: Point3d = new Point3d(cameraPositions[i].x, cameraPositions[i].y, cameraPositions[i].z, cameraPositions[i].u, cameraPositions[i].v);
				camPos.w = cameraPositions[i].w;

				cameraPositions[i] = Engine.rotate(cameraPositions[i], rotateBy);
				cameraPositions[i].u = camPos.u;
				cameraPositions[i].v = camPos.v;
				cameraPositions[i].w = camPos.w;
			}


			// Average Z (for sorting triangles)
			averageZ = (cameraPositions[0].z + cameraPositions[1].z + cameraPositions[2].z) / 3.0;
			//trace("inner " + averageZ);
		}

		public function calculateScreenPos(): void {
			screenPositions[0] = getScreenTranslation(cameraPositions[0]);
			screenPositions[1] = getScreenTranslation(cameraPositions[1]);
			screenPositions[2] = getScreenTranslation(cameraPositions[2]);

			//normal z - is the triangle facing us or the other way
			normalZ = (screenPositions[1].x - screenPositions[0].x) *
				(screenPositions[2].y - screenPositions[0].y) - (screenPositions[1].y - screenPositions[0].y) *
				(screenPositions[2].x - screenPositions[0].x);


		}

		private function getScreenTranslation(p: Point3d): Point3d {
			//perspective
			p = Engine.applyPerspective(p);
			//center on screen
			p = Engine.centerScreen(p);
			return p;
		}

		private function getWorldTranslation(p: Point3d, _rotation: Point3d, _position: Point3d): Point3d {

			var tempPos: Point3d = new Point3d(p.x, p.y, p.z, p.u, p.v);
			tempPos.w = p.w;
			//rotation
			var p: Point3d = Engine.rotate(p, _rotation);
			p.u = tempPos.u;
			p.v = tempPos.v;
			p.w = tempPos.w;

			// translate
			p = Engine.translate(p, _position);


			return p;
		}


		public function draw(zBuffer: Array): void {

			//in order to fill the polygon triangle, we first need to sort the points from top to bottom.
			//we are going to go over the points and fill in the shape, line by line from left to right
			sortPoints();

			//fillTriangle(zBuffer);
			drawWireFrame();

		}

		private function drawWireFrame(): void {
			for (var j: int = 0; j < screenPositions.length; j++) {
				var p: Point3d = screenPositions[j];
				var nextP: Point3d = screenPositions[j + 1];
				if (!nextP) {
					nextP = screenPositions[0];
				}

				var distanceH: Number = EngineMath.getDistance(p, nextP);
				var distanceX: Number = nextP.x - p.x;
				var distanceY: Number = nextP.y - p.y;

				var cos: Number = distanceX / distanceH;
				var sin: Number = distanceY / distanceH;

				var startX: Number = p.x;
				var startY: Number = p.y;

				for (var i: int = 0; i < distanceH; i++) {
					Engine.bd.setPixel(startX, startY, wireFrameColor);
					startX += cos;
					startY += sin;
				}

			}
		}

		private function fillTriangle(zBuffer: Array): void {
			var p0: Point3d = screenPositions[0];
			var p1: Point3d = screenPositions[1];
			var p2: Point3d = screenPositions[2];
			var texW: Number = bd.width;
			var texH: Number = bd.height;


			var p0x: Number = p0.x;
			var p0y: Number = p0.y;
			var p0u: Number = p0.u;
			var p0v: Number = p0.v;
			var p0w: Number = p0.w;
			var p0z: Number = p0.z;

			var p1x: Number = p1.x;
			var p1y: Number = p1.y;
			var p1u: Number = p1.u;
			var p1v: Number = p1.v;
			var p1w: Number = p1.w;
			var p1z: Number = p1.z;

			var p2x: Number = p2.x;
			var p2y: Number = p2.y;
			var p2u: Number = p2.u;
			var p2v: Number = p2.v;
			var p2w: Number = p2.w;
			var p2z: Number = p2.z;


			//each triangle is split in 2 to make calculations easier.
			//first we do the top part, then the bottom part
			if (p0y < p1y) {

				var leftYDiff: Number = (p1y - p0y)
				//slope from top to first side
				var slope1: Number = (p1x - p0x) / leftYDiff;
				//slope from top to second side
				var slope2: Number = (p2x - p0x) / (p2y - p0y);
				var triangleHeight: Number = p1y - p0y;
				for (var i: int = 0; i <= triangleHeight; i++) {
					var startX: int = p0x + i * slope1;
					var endX: int = p0x + i * slope2;
					var _y: int = p0y + i;

					//u start and v start
					var us: Number = p0u + (_y - p0y) / leftYDiff * (p1u - p0u);
					var vs: Number = p0v + (_y - p0y) / leftYDiff * (p1v - p0v);
					var ws: Number = p0w + (_y - p0y) / leftYDiff * (p1w - p0w);

					//u end and v end
					var ue: Number = p0u + (_y - p0y) / (p2y - p0y) * (p2u - p0u);
					var ve: Number = p0v + (_y - p0y) / (p2y - p0y) * (p2v - p0v);
					var we: Number = p0w + (_y - p0y) / (p2y - p0y) * (p2w - p0w);

					//z buffer start and end
					var zs: Number = p0z + (_y - p0y) / leftYDiff * (p1z - p0z);
					var ze: Number = p0z + (_y - p0y) / (p2y - p0y) * (p2z - p0z);


					//if start is greater than and, swap the,
					if (startX > endX) {
						var aux: Number = startX;
						startX = endX;
						endX = aux;

						//and also swap uv
						aux = us;
						us = ue;
						ue = aux;
						aux = vs;
						vs = ve;
						ve = aux;

						//swap w
						aux = ws;
						ws = we;
						we = aux;

						//swap z
						aux = zs;
						zs = ze;
						ze = aux;

					}

					if (endX > startX) {
						var triangleCurrWidth: Number = endX - startX;
						var u: Number = us * texW;
						var ustep: Number = (ue - us) / triangleCurrWidth * texW;
						var v: Number = vs * texH;
						var vstep: Number = (ve - vs) / triangleCurrWidth * texH;
						var w: Number = ws;
						var wstep: Number = (we - ws) / triangleCurrWidth;
						var z: Number = zs;
						var zstep: Number = (ze - zs) / (triangleCurrWidth);


						for (var j: int = 0; j <= triangleCurrWidth; j++) {
							var _x: int = startX + j;
							u += ustep;
							v += vstep;
							w += wstep;
							z += zstep;

							if (zBuffer[Engine.resolutionX * _y + _x] == 0 || zBuffer[Engine.resolutionX * _y + _x] > z) {

								var pixel: uint = bd.getPixel(u / w, v / w); //Engine.getPixelFromTexture(bd, u/w, v/w);

								Engine.bd.setPixel(_x, _y, pixel);
								zBuffer[Engine.resolutionX * _y + _x] = z;
							}

						}
					}
				}
			}

			////
			//bottom part of the triangle
			if (p1y < p2y) {
				//slope from top to first side
				var slope1: Number = (p2x - p1x) / (p2y - p1y);
				//slope from top to second side
				var slope2: Number = (p2x - p0x) / (p2y - p0y);
				var sx: Number = p2x - (p2y - p1y) * slope2;

				var triangleHeight: Number = p2y - p1y;

				for (var i: int = 0; i <= triangleHeight; i++) {
					var startX: int = p1x + i * slope1;
					var endX: int = sx + i * slope2;
					var _y: int = p1y + i;

					//u start and v start
					var us: Number = p1u + (_y - p1y) / (p2y - p1y) * (p2u - p1u);
					var vs: Number = p1v + (_y - p1y) / (p2y - p1y) * (p2v - p1v);

					var ws: Number = p1w + (_y - p1y) / (p2y - p1y) * (p2w - p1w);

					//u nd and v end
					var ue: Number = p0u + (_y - p0y) / (p2y - p0y) * (p2u - p0u);
					var ve: Number = p0v + (_y - p0y) / (p2y - p0y) * (p2v - p0v);

					var we: Number = p0w + (_y - p0y) / (p2y - p0y) * (p2w - p0w);

					//z buffer start and end
					var zs: Number = p1z + (_y - p1y) / (p2y - p1y) * (p2z - p1z);
					var ze: Number = p0z + (_y - p0y) / (p2y - p0y) * (p2z - p0z);

					if (startX > endX) {
						var aux: Number = startX;
						startX = endX;
						endX = aux;

						//and also swap uv
						aux = us;
						us = ue;
						ue = aux;
						aux = vs;
						vs = ve;
						ve = aux;

						//swap w
						aux = ws;
						ws = we;
						we = aux;

						//swap z
						aux = zs;
						zs = ze;
						ze = aux;
					}

					if (endX > startX) {
						var triangleCurrWidth: Number = endX - startX;

						var u: Number = us * texW;
						var ustep: Number = (ue - us) / triangleCurrWidth * texW;
						var v: Number = vs * texH;
						var vstep: Number = (ve - vs) / triangleCurrWidth * texH;

						var w: Number = ws;
						var wstep: Number = (we - ws) / triangleCurrWidth;

						var z: Number = zs;
						var zstep: Number = (ze - zs) / (triangleCurrWidth);

						for (var j: int = 0; j <= triangleCurrWidth; j++) {
							var _x: int = j + startX;
							u += ustep;
							v += vstep;
							w += wstep;
							z += zstep;

							if (zBuffer[Engine.resolutionX * _y + _x] == 0 || zBuffer[Engine.resolutionX * _y + _x] > z) {
								var pixel: uint = bd.getPixel(u / w, v / w); //Engine.getPixelFromTexture(bd, u/w, v/w);
								Engine.bd.setPixel(_x, _y, pixel);
								zBuffer[Engine.resolutionX * _y + _x] = z;
							}

						}
					}
				}

			}
		}

		private function sortPoints(): void {
			var aux: Point3d;
			//if point 0 is lower than point 1, then point 1 needs to be 0
			if (screenPositions[0].y > screenPositions[1].y) {
				aux = screenPositions[0];
				screenPositions[0] = screenPositions[1];
				screenPositions[1] = aux;
			}
			//if point 0 is lower than point 2, then point 2 needs to be 0
			if (screenPositions[0].y > screenPositions[2].y) {
				aux = screenPositions[0];
				screenPositions[0] = screenPositions[2];
				screenPositions[2] = aux;
			}
			//if point 1 is lower than point 2, then point 2 needs to be 1
			if (screenPositions[1].y > screenPositions[2].y) {
				aux = screenPositions[1];
				screenPositions[1] = screenPositions[2];
				screenPositions[2] = aux;
			}
		}


		//after translating the polygons to screen coords, we check which of them have a point outside the bounds of the screen. In case we find cases like this,
		//we need to clip whatever is outside + create new polygons of the remaining are of the polygon that is inside the screen.
		//we do this for the 4 sides of the screen
		//a seperate function will handle polygons that are "behind us"
		public function getClippedTriangles(): Array {
			var toReturn: Array = [];
			toReturn.push(new Polygon(screenPositions[0], screenPositions[1], screenPositions[2], bd, wireFrameColor));

			var noTriangles: int;
			var insidePoints: Array = []; // array of points3d
			var outsidePoints: Array = []; // array of points3d

			// LEFT
			noTriangles = toReturn.length;
			for (var i: int = 0; i < noTriangles; i++) {

				var currentTriangle: Polygon = toReturn.shift(); //reference to first element in list

				insidePoints.splice(0);
				outsidePoints.splice(0);
				for (var j: int = 0; j < 3; j++) {
					if (currentTriangle.getScreenPositions()[j].x < 0) {
						outsidePoints.push(currentTriangle.getScreenPositions()[j]);
					} else {
						insidePoints.push(currentTriangle.getScreenPositions()[j]);
					}
				}
				//if there are no points outside the screen, return the original triangle bank in
				if (outsidePoints.length == 0) {
					
					toReturn.push(new Polygon(screenPositions[0], screenPositions[1], screenPositions[2], bd, wireFrameColor));

				} //if one point is outside the screen, make up 2 new triangles from the remaining area - > study this code!
				//what this code does it get the point that is to the left of the screen and sets it x as 0.
				//then it needs to find the corresponding y. y is just the distance from x to the left edge of the screen * the slope!! (y/x)
				//only the y is really imporant for creating the new polygon. the u & v are for texturing correctly
				else if (outsidePoints.length == 1) {
					
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = 0;
					var ySlopefromPoint0ToOffScreenPoint: Number = (insidePoints[0].y - outsidePoints[0].y) / (insidePoints[0].x - outsidePoints[0].x);


					extraPoint1.y = outsidePoints[0].y + (0 - outsidePoints[0].x) * ySlopefromPoint0ToOffScreenPoint;
					//extraPoint1.z = outsidePoints[0].z + (0 - outsidePoints[0].x) * (insidePoints[0].z - outsidePoints[0].z) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.u = outsidePoints[0].u + (0 - outsidePoints[0].x) * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.v = outsidePoints[0].v + (0 - outsidePoints[0].x) * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.w = outsidePoints[0].w + (0 - outsidePoints[0].x) * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].x - outsidePoints[0].x);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = 0;
					var ySlopefromPoint1ToOffScreenPoint: Number = (insidePoints[1].y - outsidePoints[0].y) / (insidePoints[1].x - outsidePoints[0].x);

					extraPoint2.y = outsidePoints[0].y + (0 - outsidePoints[0].x) * ySlopefromPoint1ToOffScreenPoint;
					//extraPoint2.z = outsidePoints[0].z + (0 - outsidePoints[0].x) * (insidePoints[1].z - outsidePoints[0].z) / (insidePoints[1].x - outsidePoints[0].x);

					extraPoint2.u = outsidePoints[0].u + (0 - outsidePoints[0].x) * (insidePoints[1].u - outsidePoints[0].u) / (insidePoints[1].x - outsidePoints[0].x);
					extraPoint2.v = outsidePoints[0].v + (0 - outsidePoints[0].x) * (insidePoints[1].v - outsidePoints[0].v) / (insidePoints[1].x - outsidePoints[0].x);
					extraPoint2.w = outsidePoints[0].w + (0 - outsidePoints[0].x) * (insidePoints[1].w - outsidePoints[0].w) / (insidePoints[1].x - outsidePoints[0].x);

					toReturn.push(new Polygon(extraPoint1, insidePoints[0], insidePoints[1], bd,wireFrameColor));

					toReturn.push(new Polygon(extraPoint2, extraPoint1, insidePoints[1], bd,wireFrameColor));

				} //if there are 2 points outside the screen, make up 2 new triangles from the remaining area - > study this code!
				else if (outsidePoints.length == 2) {
					
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = 0;
					var ySlopefromPoint0ToOffScreenPoint:Number = (insidePoints[0].y - outsidePoints[0].y) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.y = outsidePoints[0].y + (0 - outsidePoints[0].x) * ySlopefromPoint0ToOffScreenPoint;

					//extraPoint1.z = outsidePoints[0].z + (0 - outsidePoints[0].x) * (insidePoints[0].z - outsidePoints[0].z) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.u = outsidePoints[0].u + (0 - outsidePoints[0].x) * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.v = outsidePoints[0].v + (0 - outsidePoints[0].x) * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.w = outsidePoints[0].w + (0 - outsidePoints[0].x) * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].x - outsidePoints[0].x);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = 0;
					var ySlopefromPoint1ToOffScreenPoint:Number = (insidePoints[0].y - outsidePoints[1].y) / (insidePoints[0].x - outsidePoints[1].x);
					extraPoint2.y = outsidePoints[1].y + (0 - outsidePoints[1].x) * ySlopefromPoint1ToOffScreenPoint;

					//extraPoint2.z = outsidePoints[1].z + (0 - outsidePoints[1].x) * (insidePoints[0].z - outsidePoints[1].z) / (insidePoints[0].x - outsidePoints[1].x);
					extraPoint2.u = outsidePoints[1].u + (0 - outsidePoints[1].x) * (insidePoints[0].u - outsidePoints[1].u) / (insidePoints[0].x - outsidePoints[1].x);
					extraPoint2.v = outsidePoints[1].v + (0 - outsidePoints[1].x) * (insidePoints[0].v - outsidePoints[1].v) / (insidePoints[0].x - outsidePoints[1].x);
					extraPoint2.w = outsidePoints[1].w + (0 - outsidePoints[1].x) * (insidePoints[0].w - outsidePoints[1].w) / (insidePoints[0].x - outsidePoints[1].x);

					toReturn.push(new Polygon(extraPoint1, extraPoint2, insidePoints[0], bd,wireFrameColor));
				}
			}

			// RIGHT
			noTriangles = toReturn.length;
			for (var i: int = 0; i < noTriangles; i++) {

				var currentTriangle: Polygon = toReturn.shift(); //reference to first element in list

				insidePoints.splice(0);
				outsidePoints.splice(0);
				for (var j: int = 0; j < 3; j++) {
					var _x:int = currentTriangle.getScreenPositions()[j].x;
					//trace(_x, Engine.resolutionX);
					if (_x >= Engine.resolutionX) {
						outsidePoints.push(currentTriangle.getScreenPositions()[j]);
					} else {
						insidePoints.push(currentTriangle.getScreenPositions()[j]);
					}
				}
				if (outsidePoints.length == 0) {
					toReturn.push(new Polygon(insidePoints[0], insidePoints[1], insidePoints[2], bd,wireFrameColor));
				} else if (outsidePoints.length == 1) {
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = Engine.resolutionX - 1;
					extraPoint1.y = outsidePoints[0].y + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].y - outsidePoints[0].y) / (insidePoints[0].x - outsidePoints[0].x);

					//extraPoint1.z = outsidePoints[0].z + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].z - outsidePoints[0].z) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.u = outsidePoints[0].u + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.v = outsidePoints[0].v + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.w = outsidePoints[0].w + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].x - outsidePoints[0].x);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = Engine.resolutionX - 1;
					extraPoint2.y = outsidePoints[0].y + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[1].y - outsidePoints[0].y) / (insidePoints[1].x - outsidePoints[0].x);

					//extraPoint2.z = outsidePoints[0].z + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[1].z - outsidePoints[0].z) / (insidePoints[1].x - outsidePoints[0].x);
					extraPoint2.u = outsidePoints[0].u + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[1].u - outsidePoints[0].u) / (insidePoints[1].x - outsidePoints[0].x);
					extraPoint2.v = outsidePoints[0].v + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[1].v - outsidePoints[0].v) / (insidePoints[1].x - outsidePoints[0].x);
					extraPoint2.w = outsidePoints[0].w + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[1].w - outsidePoints[0].w) / (insidePoints[1].x - outsidePoints[0].x);

					toReturn.push(new Polygon(extraPoint1, insidePoints[0], insidePoints[1], bd,wireFrameColor));

					toReturn.push(new Polygon(extraPoint2, extraPoint1, insidePoints[1], bd,wireFrameColor));

				} else if (outsidePoints.length == 2) {
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = Engine.resolutionX - 1;
					extraPoint1.y = outsidePoints[0].y + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].y - outsidePoints[0].y) / (insidePoints[0].x - outsidePoints[0].x);

					//extraPoint1.z = outsidePoints[0].z + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].z - outsidePoints[0].z) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.u = outsidePoints[0].u + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.v = outsidePoints[0].v + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].x - outsidePoints[0].x);
					extraPoint1.w = outsidePoints[0].w + (Engine.resolutionX - 1 - outsidePoints[0].x) * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].x - outsidePoints[0].x);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = Engine.resolutionX - 1;
					extraPoint2.y = outsidePoints[1].y + (Engine.resolutionX - 1 - outsidePoints[1].x) * (insidePoints[0].y - outsidePoints[1].y) / (insidePoints[0].x - outsidePoints[1].x);

					//extraPoint2.z = outsidePoints[1].z + (Engine.resolutionX - 1 - outsidePoints[1].x) * (insidePoints[0].z - outsidePoints[1].z) / (insidePoints[0].x - outsidePoints[1].x);
					extraPoint2.u = outsidePoints[1].u + (Engine.resolutionX - 1 - outsidePoints[1].x) * (insidePoints[0].u - outsidePoints[1].u) / (insidePoints[0].x - outsidePoints[1].x);
					extraPoint2.v = outsidePoints[1].v + (Engine.resolutionX - 1 - outsidePoints[1].x) * (insidePoints[0].v - outsidePoints[1].v) / (insidePoints[0].x - outsidePoints[1].x);
					extraPoint2.w = outsidePoints[1].w + (Engine.resolutionX - 1 - outsidePoints[1].x) * (insidePoints[0].w - outsidePoints[1].w) / (insidePoints[0].x - outsidePoints[1].x);

					toReturn.push(new Polygon(extraPoint1, extraPoint2, insidePoints[0], bd,wireFrameColor));
				}
			}

			// TOP
			noTriangles = toReturn.length;
			for (i = 0; i < noTriangles; i++) {

				var currentTriangle: Polygon = toReturn.shift(); //reference to first element in list


				insidePoints.splice(0);
				outsidePoints.splice(0);
				for (var j: int = 0; j < 3; j++) {
					if (currentTriangle.getScreenPositions()[j].y < 0) {
						outsidePoints.push(currentTriangle.getScreenPositions()[j]);
					} else {
						insidePoints.push(currentTriangle.getScreenPositions()[j]);
					}

				}


				if (outsidePoints.length == 0) {
					toReturn.push(new Polygon(insidePoints[0], insidePoints[1], insidePoints[2], bd,wireFrameColor));
				} else if (outsidePoints.length == 1) {
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = outsidePoints[0].x - outsidePoints[0].y * (insidePoints[0].x - outsidePoints[0].x) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.y = 0;

					//extraPoint1.z = outsidePoints[0].z - outsidePoints[0].y * (insidePoints[0].z - outsidePoints[0].z) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.u = outsidePoints[0].u - outsidePoints[0].y * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.v = outsidePoints[0].v - outsidePoints[0].y * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.w = outsidePoints[0].w - outsidePoints[0].y * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].y - outsidePoints[0].y);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = outsidePoints[0].x - outsidePoints[0].y * (insidePoints[1].x - outsidePoints[0].x) / (insidePoints[1].y - outsidePoints[0].y);
					extraPoint2.y = 0;

					//extraPoint2.z = outsidePoints[0].z - outsidePoints[0].y * (insidePoints[1].z - outsidePoints[0].z) / (insidePoints[1].y - outsidePoints[0].y);
					extraPoint2.u = outsidePoints[0].u - outsidePoints[0].y * (insidePoints[1].u - outsidePoints[0].u) / (insidePoints[1].y - outsidePoints[0].y);
					extraPoint2.v = outsidePoints[0].v - outsidePoints[0].y * (insidePoints[1].v - outsidePoints[0].v) / (insidePoints[1].y - outsidePoints[0].y);
					extraPoint2.w = outsidePoints[0].w - outsidePoints[0].y * (insidePoints[1].w - outsidePoints[0].w) / (insidePoints[1].y - outsidePoints[0].y);

					toReturn.push(new Polygon(extraPoint1, insidePoints[0], insidePoints[1], bd,wireFrameColor));

					toReturn.push(new Polygon(extraPoint2, extraPoint1, insidePoints[1], bd,wireFrameColor));

				} else if (outsidePoints.length == 2) {
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = outsidePoints[0].x - outsidePoints[0].y * (insidePoints[0].x - outsidePoints[0].x) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.y = 0;

					//extraPoint1.z = outsidePoints[0].z - outsidePoints[0].y * (insidePoints[0].z - outsidePoints[0].z) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.u = outsidePoints[0].u - outsidePoints[0].y * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.v = outsidePoints[0].v - outsidePoints[0].y * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.w = outsidePoints[0].w - outsidePoints[0].y * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].y - outsidePoints[0].y);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = outsidePoints[1].x - outsidePoints[1].y * (insidePoints[0].x - outsidePoints[1].x) / (insidePoints[0].y - outsidePoints[1].y);
					extraPoint2.y = 0;

					//extraPoint2.z = outsidePoints[1].z - outsidePoints[1].y * (insidePoints[0].z - outsidePoints[1].z) / (insidePoints[0].y - outsidePoints[1].y);
					extraPoint2.u = outsidePoints[1].u - outsidePoints[1].y * (insidePoints[0].u - outsidePoints[1].u) / (insidePoints[0].y - outsidePoints[1].y);
					extraPoint2.v = outsidePoints[1].v - outsidePoints[1].y * (insidePoints[0].v - outsidePoints[1].v) / (insidePoints[0].y - outsidePoints[1].y);
					extraPoint2.w = outsidePoints[1].w - outsidePoints[1].y * (insidePoints[0].w - outsidePoints[1].w) / (insidePoints[0].y - outsidePoints[1].y);

					toReturn.push(new Polygon(extraPoint1, extraPoint2, insidePoints[0], bd,wireFrameColor));
				}
			}

			// BOTTOM
			noTriangles = toReturn.length;
			for (i = 0; i < noTriangles; i++) {

				var currentTriangle: Polygon = toReturn.shift(); //reference to first element in list


				insidePoints.splice(0);
				outsidePoints.splice(0);
				for (var j: int = 0; j < 3; j++) {
					if (currentTriangle.getScreenPositions()[j].y >= Engine.resolutionY) {
						outsidePoints.push(currentTriangle.getScreenPositions()[j]);
					} else {
						insidePoints.push(currentTriangle.getScreenPositions()[j]);
					}

				}

				if (outsidePoints.length == 0) {
					toReturn.push(new Polygon(insidePoints[0], insidePoints[1], insidePoints[2], bd,wireFrameColor));
				} else if (outsidePoints.length == 1) {
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = outsidePoints[0].x + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].x - outsidePoints[0].x) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.y = Engine.resolutionY - 1;

					//extraPoint1.z = outsidePoints[0].z + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].z - outsidePoints[0].z) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.u = outsidePoints[0].u + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.v = outsidePoints[0].v + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.w = outsidePoints[0].w + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].y - outsidePoints[0].y);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = outsidePoints[0].x + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[1].x - outsidePoints[0].x) / (insidePoints[1].y - outsidePoints[0].y);
					extraPoint2.y = Engine.resolutionY - 1;

					//extraPoint2.z = outsidePoints[0].z + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[1].z - outsidePoints[0].z) / (insidePoints[1].y - outsidePoints[0].y);
					extraPoint2.u = outsidePoints[0].u + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[1].u - outsidePoints[0].u) / (insidePoints[1].y - outsidePoints[0].y);
					extraPoint2.v = outsidePoints[0].v + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[1].v - outsidePoints[0].v) / (insidePoints[1].y - outsidePoints[0].y);
					extraPoint2.w = outsidePoints[0].w + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[1].w - outsidePoints[0].w) / (insidePoints[1].y - outsidePoints[0].y);

					toReturn.push(new Polygon(extraPoint1, insidePoints[0], insidePoints[1], bd,wireFrameColor));
					toReturn.push(new Polygon(extraPoint2, extraPoint1, insidePoints[1], bd,wireFrameColor));

				} else if (outsidePoints.length == 2) {

					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = outsidePoints[0].x + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].x - outsidePoints[0].x) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.y = Engine.resolutionY - 1;

					//extraPoint1.z = outsidePoints[0].z + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].z - outsidePoints[0].z) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.u = outsidePoints[0].u + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.v = outsidePoints[0].v + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].y - outsidePoints[0].y);
					extraPoint1.w = outsidePoints[0].w + (Engine.resolutionY - 1 - outsidePoints[0].y) * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].y - outsidePoints[0].y);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = outsidePoints[1].x + (Engine.resolutionY - 1 - outsidePoints[1].y) * (insidePoints[0].x - outsidePoints[1].x) / (insidePoints[0].y - outsidePoints[1].y);
					extraPoint2.y = Engine.resolutionY - 1;

					//extraPoint2.z = outsidePoints[1].z + (Engine.resolutionY - 1 - outsidePoints[1].y) * (insidePoints[0].z - outsidePoints[1].z) / (insidePoints[0].y - outsidePoints[1].y);
					extraPoint2.u = outsidePoints[1].u + (Engine.resolutionY - 1 - outsidePoints[1].y) * (insidePoints[0].u - outsidePoints[1].u) / (insidePoints[0].y - outsidePoints[1].y);
					extraPoint2.v = outsidePoints[1].v + (Engine.resolutionY - 1 - outsidePoints[1].y) * (insidePoints[0].v - outsidePoints[1].v) / (insidePoints[0].y - outsidePoints[1].y);
					extraPoint2.w = outsidePoints[1].w + (Engine.resolutionY - 1 - outsidePoints[1].y) * (insidePoints[0].w - outsidePoints[1].w) / (insidePoints[0].y - outsidePoints[1].y);

					toReturn.push(new Polygon(extraPoint1, extraPoint2, insidePoints[0], bd,wireFrameColor));
				}
			}


			return toReturn;
		}

		//checks if triangles are partially inside the frusom or if they are behind me. in that case we need to clip them (dont need to render what is behind me)
		public function getZClippedTriangles(): Array {
			var toReturn: Array = [];
			toReturn.push(new Polygon(cameraPositions[0], cameraPositions[1], cameraPositions[2], bd,wireFrameColor));

			var noTriangles: int;
			var insidePoints: Array = []; // array of points3d
			var outsidePoints: Array = []; // array of points3d

			// Z
			noTriangles = toReturn.length;
			for (var i: int = 0; i < noTriangles; i++) {

				var currentTriangle: Polygon = toReturn.shift(); //reference to first element in list

				insidePoints.splice(0);
				outsidePoints.splice(0);

				var pointsAreOutside: Array = [];
				for (var j: int = 0; j < 3; j++) {
					pointsAreOutside[j] = currentTriangle.getCameraPositions()[j].z <0;//0(-Engine.activeCamera.zNear * 0.1)
					if (pointsAreOutside[j]) {

						outsidePoints.push(currentTriangle.getCameraPositions()[j]);
					} else {
						insidePoints.push(currentTriangle.getCameraPositions()[j]);
					}

				}

				if (outsidePoints.length == 0) {
					toReturn.push(new Polygon(insidePoints[0], insidePoints[1], insidePoints[2], bd,wireFrameColor));
				} else if (outsidePoints.length == 1) {
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = outsidePoints[0].x + (0 - outsidePoints[0].z) * (insidePoints[0].x - outsidePoints[0].x) / (insidePoints[0].z - outsidePoints[0].z);
					extraPoint1.y = outsidePoints[0].y + (0 - outsidePoints[0].z) * (insidePoints[0].y - outsidePoints[0].y) / (insidePoints[0].z - outsidePoints[0].z);
					extraPoint1.z = 0;
					extraPoint1.u = outsidePoints[0].u + (0 - outsidePoints[0].z) * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].z - outsidePoints[0].z);
					extraPoint1.v = outsidePoints[0].v + (0 - outsidePoints[0].z) * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].z - outsidePoints[0].z);
					extraPoint1.w = outsidePoints[0].w + (0 - outsidePoints[0].z) * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].z - outsidePoints[0].z);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = outsidePoints[0].x + (0 - outsidePoints[0].z) * (insidePoints[1].x - outsidePoints[0].x) / (insidePoints[1].z - outsidePoints[0].z);
					extraPoint2.y = outsidePoints[0].y + (0 - outsidePoints[0].z) * (insidePoints[1].y - outsidePoints[0].y) / (insidePoints[1].z - outsidePoints[0].z);
					extraPoint2.z = 0;
					extraPoint2.u = outsidePoints[0].u + (0 - outsidePoints[0].z) * (insidePoints[1].u - outsidePoints[0].u) / (insidePoints[1].z - outsidePoints[0].z);
					extraPoint2.v = outsidePoints[0].v + (0 - outsidePoints[0].z) * (insidePoints[1].v - outsidePoints[0].v) / (insidePoints[1].z - outsidePoints[0].z);
					extraPoint2.w = outsidePoints[0].w + (0 - outsidePoints[0].z) * (insidePoints[1].w - outsidePoints[0].w) / (insidePoints[1].z - outsidePoints[0].z);

					if (pointsAreOutside[0]) {
						toReturn.push(new Polygon(extraPoint1, insidePoints[0], insidePoints[1], bd,wireFrameColor));
						toReturn.push(new Polygon(extraPoint2, extraPoint1, insidePoints[1], bd,wireFrameColor));
					} else if (pointsAreOutside[1]) {
						toReturn.push(new Polygon(extraPoint1, insidePoints[1], insidePoints[0], bd,wireFrameColor));
						toReturn.push(new Polygon(extraPoint2, extraPoint1, insidePoints[0], bd,wireFrameColor));
					} else if (pointsAreOutside[2]) {
						toReturn.push(new Polygon(extraPoint1, insidePoints[0], insidePoints[1], bd,wireFrameColor));
						toReturn.push(new Polygon(extraPoint2, extraPoint1, insidePoints[1], bd,wireFrameColor));
					}
				} else if (outsidePoints.length == 2) {
					var extraPoint1: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint1.x = outsidePoints[0].x + (0 - outsidePoints[0].z) * (insidePoints[0].x - outsidePoints[0].x) / (insidePoints[0].z - outsidePoints[0].z);
					extraPoint1.y = outsidePoints[0].y + (0 - outsidePoints[0].z) * (insidePoints[0].y - outsidePoints[0].y) / (insidePoints[0].z - outsidePoints[0].z);
					extraPoint1.z = 0;
					extraPoint1.u = outsidePoints[0].u + (0 - outsidePoints[0].z) * (insidePoints[0].u - outsidePoints[0].u) / (insidePoints[0].z - outsidePoints[0].z);
					extraPoint1.v = outsidePoints[0].v + (0 - outsidePoints[0].z) * (insidePoints[0].v - outsidePoints[0].v) / (insidePoints[0].z - outsidePoints[0].z);
					extraPoint1.w = outsidePoints[0].w + (0 - outsidePoints[0].z) * (insidePoints[0].w - outsidePoints[0].w) / (insidePoints[0].z - outsidePoints[0].z);

					var extraPoint2: Point3d = new Point3d(0, 0, 0, 0, 0);
					extraPoint2.x = outsidePoints[1].x + (0 - outsidePoints[1].z) * (insidePoints[0].x - outsidePoints[1].x) / (insidePoints[0].z - outsidePoints[1].z);
					extraPoint2.y = outsidePoints[1].y + (0 - outsidePoints[1].z) * (insidePoints[0].y - outsidePoints[1].y) / (insidePoints[0].z - outsidePoints[1].z);
					extraPoint2.z = 0;
					extraPoint2.u = outsidePoints[1].u + (0 - outsidePoints[1].z) * (insidePoints[0].u - outsidePoints[1].u) / (insidePoints[0].z - outsidePoints[1].z);
					extraPoint2.v = outsidePoints[1].v + (0 - outsidePoints[1].z) * (insidePoints[0].v - outsidePoints[1].v) / (insidePoints[0].z - outsidePoints[1].z);
					extraPoint2.w = outsidePoints[1].w + (0 - outsidePoints[1].z) * (insidePoints[0].w - outsidePoints[1].w) / (insidePoints[0].z - outsidePoints[1].z);

					if (!pointsAreOutside[0]) {
						toReturn.push(new Polygon(extraPoint2, insidePoints[0], extraPoint1, bd,wireFrameColor));
					} else if (!pointsAreOutside[1]) {
						toReturn.push(new Polygon(extraPoint1, insidePoints[0], extraPoint2, bd,wireFrameColor));
					} else if (!pointsAreOutside[2]) {
						toReturn.push(new Polygon(extraPoint2, insidePoints[0], extraPoint1, bd,wireFrameColor));
					}

				}
			}

			return toReturn;
		}

	}

}