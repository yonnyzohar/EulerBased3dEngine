package assets
{
	import flash.display.BitmapData;

	public class Plane extends GameObject{

		public function Plane(_positon:Point3d, _rotation:Point3d, _scale:Point3d, _bd:BitmapData) {
			// constructor code
			position = _positon;//
			rotation = _rotation;//;
			scale = _scale;
			bd = _bd;
			
		
			polygons = [
				new Polygon(
					new Point3d(-50     * scale.x, 0 * scale.y, 0 * scale.z, 0, 1), 
					new Point3d(50      * scale.x, 0 * scale.y, 0 * scale.z, 1, 0), 
					new Point3d(50      * scale.x, 0 * scale.y, 100 * scale.z, 0, 0), 
				bd),
			
				new Polygon(
					new Point3d(-50 * scale.x, 0 * scale.y, 0   * scale.z, 0, 1), 
					new Point3d(50    * scale.x, 0 * scale.y, 100 * scale.z, 1, 0), 
					new Point3d( -50 * scale.x, 0 * scale.y, 100 * scale.z, 0, 0), 
				bd)
				// bottom
			];
			
		

			//the makeup of the polygons is important. they need to be clockwise!
			super();
		}




	}

}