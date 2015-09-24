package  
{
	import flash.geom.Point;

	public class GameInfo 
	{
		
		public function GameInfo() 
		{
			
		}
		
		// used by MobEntity, see that class for more info
		// todo: document these properly
		// should gravity be global like this, or based on a function (ie, position, like everybodyedits)
		public var collideMax:int = 10;
		public var termVel:Point = new Point(0, 1000); // i'm making this up. tweak.
		public var gravAccel:Point = new Point(0, 3000); // ditto
		
	}

}