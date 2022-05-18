package game{
	import flash.display.Stage;
	import assets.Bullet;

	public class Player extends GameCamera {
		private var coolDown:int = 10;
		private var c:int = 0;
		private var gun:Gun;

		public function Player(_theStage: Stage, _position: Point3d, _rotation: Point3d) {
			gun = new Gun();
			super(_theStage, _position, _rotation);
		}

		override public function lookDown(rs:Number):void{}

		override public function lookUp(rs:Number):void{}


		override public function update(elapsedTime:Number): void 
		{
			if(c != 0)
			{
				c--;
			}
			if(InputHandler.SPACE)
			{
				if(c == 0)
				{
					gun.fire(getPosition(), rotation, null);
					
					c = coolDown;
				}
				
			}
			super.update(elapsedTime);
			
		}
	}
}