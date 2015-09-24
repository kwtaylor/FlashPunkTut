package  
{
	import flash.utils.Dictionary;
	import flash.geom.Point;
	
	public class CollideGrid 
	{
		protected var grid:Array;
		protected var blocks:Dictionary;
		protected var xmin:Number, xmax:Number, ymin:Number, ymax:Number;
		protected var w_col:Number, h_row:Number;
		protected var rows:uint, cols:uint;
		
		private var arr:Array = new Array;
		private var c_left:uint, c_right:uint, r_top:uint, r_bot:uint;
		private var x:uint, y:uint;
		private var obj:Object;
		
		public function CollideGrid(_rows:int, _cols:int, _xmin:Number, _xmax:Number, _ymin:Number, _ymax:Number) 
		{
			var i:uint, j:uint;
			
			rows = _rows;
			cols = _cols;
			xmin = _xmin;
			xmax = _xmax;
			ymin = _ymin;
			ymax = _ymax;
			
			w_col = (xmax - xmin) / cols;
			h_row = (ymax - ymin) / rows;
			
			grid = new Array(cols);
			for (i = 0; i < cols; i++) {
				grid[i] = new Array(rows);
				for (j = 0; j < rows; j++) {
					grid[i][j] = new Array;
				}
			}
			
			blocks = new Dictionary;
			
		}
		
		public function GetBlocks(top:Number, bot:Number, left:Number, right:Number):Array
		{
			//var arr:Array = new Array;
			arr.splice(0, arr.length);
			//var c_left:uint, c_right:uint, r_top:uint, r_bot:uint;
			
			if (top > ymax || bot < ymin || left > xmax || right < xmin)
				return arr;
				
			c_left = Math.max(0, Math.floor((left - xmin) / w_col));
			c_right = Math.min(cols - 1, Math.floor((right - xmin) / w_col));
			r_top = Math.max(0, Math.floor((top - ymin) / h_row));
			r_bot = Math.min(rows - 1, Math.floor((bot - ymin) / h_row));
			
			//var x:uint, y:uint;
			//var obj:Object;
			
			for (x = c_left; x <= c_right; x++) {
				for (y = r_top; y <= r_bot; y++) {
					if(grid[x][y]){
						for each (obj in grid[x][y]) {
							if (arr.indexOf(obj) == -1)
								arr.push(obj);
						}
					}
				}
			}
			
			return arr;
			
		}
		
		public function AddBlock(block:Object, top:Number, bot:Number, left:Number, right:Number):void
		{
			//var c_left:uint, c_right:uint, r_top:uint, r_bot:uint;
			
			if (top > ymax || bot < ymin || left > xmax || right < xmin)
				return;
				
			if (blocks[block]) return;
			
			c_left = Math.max(0, Math.floor((left - xmin) / w_col));
			c_right = Math.min(cols - 1, Math.floor((right - xmin) / w_col));
			r_top = Math.max(0, Math.floor((top - ymin) / h_row));
			r_bot = Math.min(rows - 1, Math.floor((bot - ymin) / h_row));
			
			//var x:uint, y:uint;
			
			blocks[block] = new Array;
			
			for (x = c_left; x <= c_right; x++) {
				for (y = r_top; y <= r_bot; y++) {
					grid[x][y].push(block);
					blocks[block].push(new Point(x, y));
				}
			}
		}
		
		public function RemoveBlock(block:Object):void
		{
			if (blocks[block]) {
				var idx:uint;				
				for each (var coord:Point in blocks[block]) {
					idx = grid[coord.x][coord.y].indexOf(block);
					if(idx > -1) grid[coord.x][coord.y].splice(idx, 1);
				}
				blocks[block] = null;
			}
		}
		
		
	}

}