package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.Mask;
	import net.flashpunk.FP;
	
	public class VisCullEntity extends Entity
	{
		
		public function VisCullEntity(x:Number = 0, y:Number = 0, graphic:Graphic = null, mask:Mask = null) 
		{
			super(x, y, graphic, mask);
		}
		
		override public function update():void 
		{
			super.update();
			visible = onCamera;
		}
		
	}

}