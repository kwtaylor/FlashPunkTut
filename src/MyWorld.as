package  
{
	import flash.geom.Point;
	import flash.display.BitmapData;
	import net.flashpunk.World; 
    import net.flashpunk.graphics.Image;
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import flash.filters.*;
	import flash.utils.ByteArray;


	public class MyWorld extends World 
	{
		[Embed(source = 'assets/player.png')] private const OMGWTF:Class;		
		[Embed(source="assets/test.oel", mimeType="application/octet-stream")] private const LevelXML:Class;
		private var level_xml:XML;
		
		private var lev_width:Number;
		private var lev_height:Number;
		private var lev_edge:Boolean = true;
		
		private var using_lev:Boolean;
		
		private var lastFrame:Image;
					
		private var bf:BlurFilter = new BlurFilter(5, 5, 1);
		
		private var ginfo:GameInfo = new GameInfo();
		
		private var cam_thresh:Number = 150;
		private var cam_k:Number = 10;
		
		private var player:MyEntity;
		
		private var grid:CollideGrid;
		
		public function MyWorld() 
		{	
			var contentfile:ByteArray = new LevelXML();
			var contentstr:String = contentfile.readUTFBytes( contentfile.length );
			level_xml =  new XML( contentstr );

			randLevel();
			using_lev = false;
			//loadLevel(level_xml);
			
			/*var img_floor:Image = new Image(OMGWTF);
			img_floor.scaleX = 400/img_floor.width;
			img_floor.scaleY = 50 / img_floor.height;
			var floor:Entity = new Entity(0, 300, img_floor, new BasicPhysBlock() );
			floor.width = 400;
			floor.height = 50;
			floor.type = "physical";
			var img_block:Image = new Image(OMGWTF);
			img_block.scaleX = 200 / img_block.width;
			img_block.scaleY = 50 / img_block.height;
			var block:Entity = new Entity(215, 131, img_block, new BasicPhysBlock(1,0.05) );
			block.width = 200;
			block.height = 50;
			block.type = "physical";
			var img_block2:Image = new Image(OMGWTF);
			img_block2.scaleX = 100 / img_block2.width;
			img_block2.scaleY = 100 / img_block2.height;
			var block2:Entity = new Entity(78, 160, img_block2, new BasicPhysBlock() );
			block2.width = 100;
			block2.height = 100;
			block2.type = "physical";
			add(floor);
			add(block);
			add(block2);*/
		}
		
		public function randLevel():void
		{
			
			var i:uint;
			var img:Image;
			var ent:VisCullEntity;
			var posx:Number, posy:Number, wid:Number, hei:Number;
			
			grid = new CollideGrid(500, 500, -5500, 5500, -5500, 5500);
			lev_width = 5500;
			lev_height = 5500;
			lev_edge = false;
			
			player = new MyEntity(ginfo, grid);
			add(player);
	
			for (i = 0; i < 50*16; i++) {
				posx = FP.rand(10000) - 5000;
				posy = FP.rand(10000) - 5000;
				wid = FP.rand(500) + 50;
				hei = FP.rand(300) + 50;
				
				img = new Image(OMGWTF);
				img.scaleX = wid / img.width;
				img.scaleY = hei / img.height;
				
				ent = new VisCullEntity(posx, posy, img, new BasicPhysBlock(1, FP.rand(100) / 100));
				ent.width = wid;
				ent.height = hei;
				ent.type = "physical";
				
				add(ent);
				grid.AddBlock(ent, posy, posy + hei, posx, posx + wid);
				
			}
			camera.x = 0;
			camera.y = 0;
		}
		
		public function loadLevel(level:XML):void
		{
			var i:uint;
			var img:Image;
			var ent:VisCullEntity;
			var posx:Number, posy:Number, wid:Number, hei:Number, fric:Number;
			
			lev_width = level.@width;
			lev_height = level.@height;
			lev_edge = true;
			
			ginfo.gravAccel = new Point(0, level.@gravAccel);
			ginfo.termVel = new Point(0, level.@termVel);
			
			grid = new CollideGrid(lev_height/100, lev_width/100, 0, lev_width, 0, lev_height);
			
			player = new MyEntity(ginfo, grid);
			player.x = level.Entities.PlayerStart.@x;
			player.y = level.Entities.PlayerStart.@y;
			add(player);
			
			for (i = 0; i < level.Collision.CollideBlock.length(); i++) {
				posx = level.Collision.CollideBlock[i].@x;
				posy = level.Collision.CollideBlock[i].@y;
				wid = level.Collision.CollideBlock[i].@width;
				hei = level.Collision.CollideBlock[i].@height;
				fric = level.Collision.CollideBlock[i].@fric;
				
				img = new Image(OMGWTF);
				img.scaleX = wid / img.width;
				img.scaleY = hei / img.height;
				
				ent = new VisCullEntity(posx, posy, img, new BasicPhysBlock(1, fric));
				ent.width = wid;
				ent.height = hei;
				ent.type = "physical";
				
				add(ent);
				grid.AddBlock(ent, posy, posy + hei, posx, posx + wid);
			}
			
			camera.x = level.camera.@x;
			camera.y = level.camera.@y;
		}
		
		override public function update():void 
		{
			if (Input.pressed(Key.SPACE))
			{
				removeAll();
				// let GC take care of some things (like collidegrid)
				if (using_lev) {
					randLevel();
					using_lev = false;
				} else {
					loadLevel(level_xml);
					using_lev = true;
				}
				return;
			}
			if (player.x - player.originX < camera.x + cam_thresh) {
				camera.x -= ((camera.x + cam_thresh) - (player.x - player.originX)) * cam_k * FP.elapsed;
			} 
			if (player.y - player.originY < camera.y + cam_thresh) {
				camera.y -= ((camera.y + cam_thresh) - (player.y - player.originY)) * cam_k * FP.elapsed;
			}
			if (player.x - player.originX + player.width > camera.x + FP.width - cam_thresh) {
				camera.x += ((player.x - player.originX + player.width) - (camera.x + FP.width - cam_thresh))
							* cam_k * FP.elapsed;
			}
			if (player.y - player.originY + player.height > camera.y + FP.height - cam_thresh) {
				camera.y += ((player.y - player.originY + player.height) - (camera.y + FP.height - cam_thresh))
							* cam_k * FP.elapsed;
			}
			
			camera.x = Math.round(camera.x);
			camera.y = Math.round(camera.y);
			
			if (lev_edge)
			{
				if (camera.x + FP.width > lev_width) { camera.x = lev_width - FP.width; }
				if (camera.x < 0) { camera.x = 0; }
				if (camera.y < 0) { camera.y = 0; }
				if (camera.y + FP.height > lev_height) { camera.y = lev_height - FP.height; }
			}
			
			super.update();
		}
		
		override public function render():void 
		{
			/*if (lastFrame) {
				var zeroPoint:Point = new Point;
				zeroPoint.x = 0;
				zeroPoint.y = 0;
				lastFrame.originX =  FP.halfWidth;
				lastFrame.originY = FP.halfHeight;
				lastFrame.angle = 2;
				lastFrame.scale = 1.01;
				lastFrame.smooth = true;
				lastFrame.render(FP.buffer, zeroPoint, zeroPoint);
				FP.buffer.applyFilter(FP.buffer, FP.buffer.rect, zeroPoint, bf);
			}*/
			
			super.render();
			
			//lastFrame = FP.screen.capture();
		}
		
	}

}