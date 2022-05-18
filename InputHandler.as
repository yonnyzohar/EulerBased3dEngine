package {
	import flash.events.*;
	import flash.ui.*;
	import flash.display.Stage;

	public class InputHandler  {

		public static var up   :Boolean = false;
		public static var down :Boolean = false;
		public static var left :Boolean = false;
		public static var right:Boolean = false;
		public static var W    :Boolean = false;
		public static var S    :Boolean = false;
		public static var A    :Boolean = false;
		public static var D    :Boolean = false;
		public static var E    :Boolean = false;
		public static var Q    :Boolean = false;
		public static var SPACE:Boolean = false;
		private var theStage: Stage;
		private var lastMouseX:Number = 0;
		private var lastMouseY:Number = 0;
		private var mouseIsDown:Boolean = false;

		public function InputHandler(_theStage: Stage) {

			theStage = _theStage;
			_theStage.addEventListener(KeyboardEvent.KEY_DOWN, myKeyDown);
			_theStage.addEventListener(KeyboardEvent.KEY_UP, myKeyUp);
			_theStage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_theStage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}

		private function mouseDown(e:MouseEvent):void{
			mouseIsDown = true;
		}
		
		private function mouseUp(e:MouseEvent):void{
			mouseIsDown = false;
		}

		private function myKeyDown(e: KeyboardEvent): void {

			if (e.keyCode == Keyboard.UP) {
				up = true;
				down = false;
			}
			if (e.keyCode == Keyboard.DOWN) {

				down = true;
				up = false;
			}
			if (e.keyCode == Keyboard.LEFT) {

				left = true;
				right = false;
			}
			if (e.keyCode == Keyboard.RIGHT) {

				right = true;
				left = false;
			}
			if(e.keyCode == Keyboard.SPACE)
			{
				SPACE = true;
			}


			if (e.keyCode == Keyboard.W) {
				W = true;
			}
			if (e.keyCode == Keyboard.A) {
				A = true;
			}

			if (e.keyCode == Keyboard.S) {
				S = true;
			}

			if (e.keyCode == Keyboard.D) {
				D = true;
			}
			if (e.keyCode == Keyboard.E) {
				E = true;
			}
			if (e.keyCode == Keyboard.Q) {
				Q = true;
			}

		}
		

		private function myKeyUp(e: KeyboardEvent): void {

			if (e.keyCode == Keyboard.UP) {
				up = false;
			}
			if (e.keyCode == Keyboard.DOWN) {

				down = false;
			}
			if (e.keyCode == Keyboard.LEFT) {

				left = false;
			}
			if (e.keyCode == Keyboard.RIGHT) {

				right = false;
			}

			if(e.keyCode == Keyboard.SPACE)
			{
				SPACE = false;
			}


			if (e.keyCode == Keyboard.W) {
				W = false;
			}
			if (e.keyCode == Keyboard.A) {
				A = false;
			}

			if (e.keyCode == Keyboard.S) {
				S = false;
			}

			if (e.keyCode == Keyboard.D) {
				D = false;
			}
			if (e.keyCode == Keyboard.E) {
				E = false;
			}
			if (e.keyCode == Keyboard.Q) {
				Q = false;
			}

		}

		
	}
}