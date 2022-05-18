package {

	import flash.display.BitmapData;
	public class GameObject {
		public var polygons: Array;
		public var position: Point3d;
		public var rotation: Point3d;
		public var scale: Point3d;
		public var bd: BitmapData;
		public var boundingBox: Object;
		public var destructable: Boolean = true;
		public var _collideable: Boolean = true;
		public var rendered: Boolean;

		public function GameObject(_c: Boolean = true) {
			_collideable = _c;
			if (_collideable) {
				getBoundingBox(polygons);
				centerMesh(polygons);
				getBoundingBox(polygons);
			}
		}

		public function get collideable(): Boolean {
			return _collideable;
		}

		public function set collideable(val: Boolean): void {
			_collideable = val;
			if (val == false) {
				boundingBox = null;
			}
		}

		public function setFrameColor(color: uint): void {

			for (var i: int = 0; i < polygons.length; i++) {
				var polygon: Polygon = polygons[i];
				polygon.setFrameColor(color);
			}
		}

		function centerMesh(_polygons: Array): void {
			var bb = boundingBox;
			for (var i: int = 0; i < _polygons.length; i++) {
				var polygon: Polygon = _polygons[i];
				for (var j: int = 0; j < 3; j++) {
					var p: Point3d = polygon.localPositions[j];

					p.x -= bb.minX;
					p.x -= (bb.xDist / 2);

					p.y -= bb.minY;
					//p.y -= (bb.yDist/2);

					p.z -= bb.minZ;
					p.z -= (bb.zDist / 2);
				}
			}

		}

		function getBoundingBox(_polygons: Array): void {
			var minX: Number = Number.MAX_VALUE;
			var maxX: Number = Number.MIN_VALUE;;
			var minY: Number = Number.MAX_VALUE;
			var maxY: Number = Number.MIN_VALUE;
			var minZ: Number = Number.MAX_VALUE;
			var maxZ: Number = Number.MIN_VALUE;

			for (var i: int = 0; i < _polygons.length; i++) {
				var polygon: Polygon = _polygons[i];
				for (var j: int = 0; j < 3; j++) {
					var p: Point3d = polygon.localPositions[j];
					if (p.x < minX) {
						minX = p.x;
					}
					if (p.x > maxX) {
						maxX = p.x;
					}

					if (p.y < minY) {
						minY = p.y;
					}
					if (p.y > maxY) {
						maxY = p.y;
					}

					if (p.z < minZ) {
						minZ = p.z;
					}
					if (p.z > maxZ) {
						maxZ = p.z;
					}
				}

			}

			boundingBox = {
				"frontBtmLeft": new Point3d(minX, minY, minZ),
				"frontTopLeft": new Point3d(minX, maxY, minZ),
				"backBtmLeft": new Point3d(minX, minY, maxZ),
				"backTopLeft": new Point3d(minX, maxY, maxZ),

				"frontBtmRight": new Point3d(maxX, minY, minZ),
				"frontTopRight": new Point3d(maxX, maxY, minZ),
				"backTopRight": new Point3d(maxX, maxY, maxZ),
				"backBtmRight": new Point3d(maxX, minY, maxZ),
				"minX": minX,
				"maxX": maxX,
				"xDist": maxX - minX,
				"minY": minY,
				"maxY": maxY,
				"yDist": maxY - minY,
				"minZ": minZ,
				"maxZ": maxZ,
				"zDist": maxZ - minZ
			};
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



		public function checkColission(targetPos: Point3d): Boolean {
			var bb = boundingBox;
			if (bb == null) {
				return false;
			}
			var frontBtmLeft: Point3d = new Point3d(position.x + bb.frontBtmLeft.x, position.y + bb.frontBtmLeft.y, position.z + bb.frontBtmLeft.z);
			var frontTopLeft: Point3d = new Point3d(position.x + bb.frontTopLeft.x, position.y + bb.frontTopLeft.y, position.z + bb.frontTopLeft.z);
			var backBtmLeft: Point3d = new Point3d(position.x + bb.backBtmLeft.x, position.y + bb.backBtmLeft.y, position.z + bb.backBtmLeft.z);
			var backTopLeft: Point3d = new Point3d(position.x + bb.backTopLeft.x, position.y + bb.backTopLeft.y, position.z + bb.backTopLeft.z);
			var frontBtmRight: Point3d = new Point3d(position.x + bb.frontBtmRight.x, position.y + bb.frontBtmRight.y, position.z + bb.frontBtmRight.z);
			var frontTopRight: Point3d = new Point3d(position.x + bb.frontTopRight.x, position.y + bb.frontTopRight.y, position.z + bb.frontTopRight.z);
			var backTopRight: Point3d = new Point3d(position.x + bb.backTopRight.x, position.y + bb.backTopRight.y, position.z + bb.backTopRight.z);
			var backBtmRight: Point3d = new Point3d(position.x + bb.backBtmRight.x, position.y + bb.backBtmRight.y, position.z + bb.backBtmRight.z);


			if (targetPos.x >= frontBtmLeft.x &&
				targetPos.x <= backTopRight.x &&
				targetPos.y <= frontTopLeft.y &&
				targetPos.y >= frontBtmLeft.y &&
				targetPos.z >= frontBtmRight.z &&
				targetPos.z <= backBtmLeft.z

			) {
				return true;
			}
			return false;

		}


		public function update(elapsedTime: Number): void {




		}




	}
}