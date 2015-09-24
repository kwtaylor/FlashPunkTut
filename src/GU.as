package  
{

	public class GU
	{
		
		// calculates whether the point x,y is above (positive y) or on the line between (x1,y1) and (x2,y2)
		// yes positive y is not how flashpunk does "above", so invert your y's if you're using it like that
		static public function AboveLine(x1:Number, y1:Number,
		                                 x2:Number, y2:Number,
										 x:Number, y:Number):Boolean
		{
			var rise:Number = y2 - y1;
			var run:Number = x2 - x1;
				
			if (run > 0) {
				return run * (y - y1) >= rise * (x - x1);
			} else if (run < 0) {
				return run * (y - y1) <= rise * (x - x1);
			} else {
				return x == x1;
			}
		}
		
	}

}