package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	public class Main extends Engine 
	{
		
		private var testginfo:GameInfo = new GameInfo();
		private var testentit:MobEntity;
		private var testing2:Entity;
		
		public function Main():void 
		{
			super(600, 600, 60, false);
			FP.world = new MyWorld;
			if(CONFIG::debug) FP.console.enable();
			
			testentit = new MobEntity(testginfo);
			testing2 = new Entity();
			testing2.mask = new BasicPhysBlock();

		}
		
		override public function init():void 
		{ 
			1 + 1;
			trace("FlashPunk has started successfully!"); 

			
		}

	}
	
}