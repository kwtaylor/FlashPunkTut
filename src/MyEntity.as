package  
{

	import net.flashpunk.Entity; 
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.FP;
	
	public class MyEntity extends MobEntity
	{
		[Embed(source = 'assets/playeranim.png')]
		private const PLAYER:Class;
		
		private var dubJump:Boolean;
		
		private var fric:Number;
		
		public function MyEntity(ginfo:GameInfo, grid:CollideGrid = null) 
		{
			super(ginfo, grid);
			var gimage:Spritemap = new Spritemap(PLAYER,50,100);
			width = 50;
			height = 100;
			gimage.add("idle", [0]);
			gimage.add("run", [6, 7, 8], 10);
			gimage.play("idle");
			graphic = gimage;
			dubJump = false;
		}
		
		override public function update():void {
			
			
			if (m_ginfo.termVel.y > 0) {
				fric = upd_blockBot ? upd_blockBot.fric : 0;
			} else {
				fric = upd_blockTop ? upd_blockTop.fric : 0;
			}
			
			set_intVel.x = 0;
			set_intVel.y = 0;
			set_maxAccel.x = 2500;
			set_maxAccel.y = 0;
			
			if ( fric > 0 ) {
				set_maxAccel.x *= fric;
				dubJump = false;
			}
			else
				set_maxAccel.x *= .01;
			
			if (Input.check(Key.LEFT))
			{
				set_intVel.x = -500;
				if (rd_effVel.x > 0 && fric > 0) set_maxAccel.x *= 2;
				if (fric == 0) set_maxAccel.x = set_maxAccel.x * .75 / .01;
			}
			if (Input.check(Key.RIGHT)) 
			{ 
				set_intVel.x = 500;
				if (rd_effVel.x < 0 && fric > 0) set_maxAccel.x *= 2;
				if (fric == 0) set_maxAccel.x = set_maxAccel.x * .75 / .01;
			} 
			if (Input.pressed(Key.UP) && (fric > 0 || !dubJump)) 
			{ 
				rd_effVel.y = -1000 * FP.sign(m_ginfo.termVel.y);
				//rd_effVel.x -= (rd_effVel.x-set_intVel.x)/2;
				if(fric == 0) dubJump = true;
			} 
			if (!Input.check(Key.UP) && rd_effVel.y*FP.sign(m_ginfo.termVel.y) < 0)	{
				set_intVel.y = 1000*FP.sign(m_ginfo.termVel.y);
				set_maxAccel.y = 10000;
			}
			if (Input.pressed(Key.DOWN)) 
			{ 
				m_ginfo.termVel.y *= -1;
				(graphic as Spritemap).scaleY *= -1
				if ((graphic as Spritemap).scaleY < 0)
					(graphic as Spritemap).originY = height;
				else 
					(graphic as Spritemap).originY = 0;
					
			}
			
			if (fric > 0 && set_intVel.x != 0)
			{
				(graphic as Spritemap).play("run");
			}
			else 
				(graphic as Spritemap).play("idle");

			if (set_intVel.x < 0)
			{
				(graphic as Spritemap).scaleX = -1;
				(graphic as Spritemap).originX = width;
			}
			else if(set_intVel.x > 0)
			{
				(graphic as Spritemap).scaleX = 1;
				(graphic as Spritemap).originX = 0;
			}
			
			collideMove(FP.elapsed);

		} 
		
	}

}