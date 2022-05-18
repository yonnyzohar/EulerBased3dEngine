package assets
{
	import flash.display.BitmapData;

	public class Pyramid extends GameObject {

		public function Pyramid(_positon: Point3d, _rotation: Point3d, _scale: Point3d, _bd: BitmapData) {
			// constructor code
			position = _positon; //
			rotation = _rotation; //;

			//rotation.y = Math.random();
			scale = _scale;
			bd = _bd;
	
			polygons = [

				new Polygon(
					new Point3d(50  * scale.x, 1 * scale.y, 90.00002 * scale.z, 0, 0), 
					new Point3d(-50 * scale.x, -200 * scale.y, 0 * scale.z, 0, 0), 
					new Point3d(50  * scale.x, -1 * scale.y, -110 * scale.z, 0, 0), 
				bd),
				new Polygon(
					new Point3d(-120 * scale.x, 1 * scale.y, 90.00002 * scale.z, 0, 0), 
					new Point3d(-50  * scale.x, -200 * scale.y, 0 * scale.z, 0, 0), 
					new Point3d(50   * scale.x, 1 * scale.y, 90.00002 * scale.z, 0, 0), 
				bd),
				new Polygon(
					new Point3d(50   * scale.x, -1 * scale.y, -110 * scale.z, 0, 0), 
					new Point3d(-50  * scale.x, -200 * scale.y, 0 * scale.z, 0, 0), 
					new Point3d(-120 * scale.x, -1 * scale.y, -110 * scale.z, 0, 0), 
				bd),
				new Polygon(
					new Point3d(-50  * scale.x, -200 * scale.y, 0 * scale.z, 0, 0), 
					new Point3d(-120 * scale.x, 1 * scale.y, 90.00002 * scale.z, 0, 0), 
					new Point3d(-120 * scale.x, -1 * scale.y, -110 * scale.z, 0, 0), 
				bd),
				new Polygon(
					new Point3d(-120 * scale.x, 1 * scale.y, 90.00002 * scale.z, 0, 0), 
					new Point3d(50   * scale.x, -1 * scale.y, -110 * scale.z, 0, 0), 
					new Point3d(-120 * scale.x, -1 * scale.y, -110 * scale.z, 0, 0), 
				bd),
				new Polygon(
					new Point3d(-120 * scale.x, 1 * scale.y, 90.00002 * scale.z, 0, 0), 
					new Point3d(50   * scale.x, 1 * scale.y, 90.00002 * scale.z, 0, 0), 
					new Point3d(50   * scale.x, -1 * scale.y, -110 * scale.z, 0, 0), 
				bd)
			];
			super();
		}

		




	}

}