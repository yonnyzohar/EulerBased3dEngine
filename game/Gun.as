package game{
	import flash.display.Stage;
	import assets.Bullet;

	public class Gun {
		public function Gun()
		{

		}
		public function fire(position:Point3d, rotation:Point3d, parent:GameObject)
		{
			var po:Point3d = position;
			var bullet: Bullet = new Bullet(
				new Point3d(po.x,po.y,po.z), 
				new Point3d(rotation.x, rotation.y, rotation.z), 
				new Point3d(0.05,0.05,0.05), 
				null, parent);
			Engine.gO.push(bullet);
			bullet.destructable = false;
			bullet.setFrameColor( 0xff00ff);
		}
	}

}