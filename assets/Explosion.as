package assets
{

	public class Explosion {

		var dist:int = 0;

		public function Explosion(_positon: Point3d) {
			// constructor code
			for(var i:int = 0; i < 30; i++)
			{
				var y:Number = Math.sin(Math.random() * (Math.PI * 2));
				var x:Number = Math.cos(Math.random() * (Math.PI * 2));
				var z:Number = Math.tan(Math.random() * (Math.PI * 2));
				var quat:Quaternion = EngineMath.eulerToQuat(new Point3d(x,y,z));
				var bullet: Shrapnel = new Shrapnel(
					new Point3d(_positon.x + ( (Math.random() * 10) - 5 ),_positon.y+ ( (Math.random() * 10) - 5 ),_positon.z+ ( (Math.random() * 10) - 5 )), 
					quat, 
					new Point3d(Math.random() * 0.1,Math.random() * 0.1,Math.random() * 0.1), 
					null, ( Math.random() * 100) - 50 
				);
				bullet.destructable = false;
				Engine.gO.push(bullet);
			}
		}
	}
}