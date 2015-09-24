package  
{

	import net.flashpunk.*;
	import flash.geom.Point;
	
	// a "mobile" entity that can't pass through "physical" entities
	// and moves via an intended velocity/gravity/moving platforms.
	public class MobEntity extends Entity
	{
		// set_ = set by user code before update
		// rd_ = set by internal class code, plz read only
		// upd_ = set by internal code, modifyable by other classes during collision step
		
		public var set_intVel:Point = new Point(0, 0); // intended movement velocity (pixels/sec)
		public var rd_effVel:Point = new Point(0, 0); // actual velocity (pixels/sec)
		public var upd_effMove:Point = new Point(0, 0); // actual movement for this frame (pixels)
		public var set_collidePush:Boolean = true; // should collision checks push us around?
		public var set_gravitate:Boolean = true; 
		public var set_slopeSlip:Number = 1.0; // the maximum slope we won't slip down (rise/run)
		                                       // TODO: have mobentity subclass decide what to do
											   //       about this when it adjusts effVel on a slope,
											   //       not the physical it's colliding with.
											   // TODO: should this be modulated by surface friction? Or just use some kind of static friction thing?
											   // well friction is handled by the descendant entity's logic anyway, so they can update it.
		public var set_rider:Boolean = true; // should we ride on moving platforms

		public var upd_blockLeft:BasicPhysBlock;
		public var upd_blockRight:BasicPhysBlock;
		public var upd_blockBot:BasicPhysBlock;
		public var upd_blockTop:BasicPhysBlock;

		public var set_maxAccel:Point = new Point(0, 0); // max intended acceleration in pixels/sec/sec
		
		// collision update process:
		// 1) intVel/maxAccel set according to input or AI script before collideMove() 
		//    protip: use frictions from last collide check to determine state & acceleration abilities
		//            also set animations from state from this info
		// 2) effVel is modified by update from IntVel according to maxAccel, gravitate, and gravity
		// 4) effVel translated into pixels and stored in effMove
		// 5) Collision step is run, each physical collider adjusting effMove to avoid collision
		// 6) physical colliders set frictions (0 if no collision, (0,1] friction coefficient if yes) & slope
		// 7) Resulting effMove translated back into effVel
		// 8) In new position with new velocity.
		
		// slopeSlip notes:
		//  when colliding with a slope, if the slope is less than slopeSlip,
		//  the slope should only counteract the non-gravity component of the movement
		//  with the slope normal. gravity should be counteracted directly.
		//  However if it's greater than slopeSlip, the entire effMove should be
		//  counteracted with the slope normal.
		protected var m_ginfo:GameInfo;
		
		protected var m_grid:CollideGrid;
		
		private var i:int = 0;
		private var gridi:uint = 0;
		private var gridEnt:Array = null;
		private var colEnt:Entity;
		private var collided:Boolean;
		
		public function MobEntity(ginfo:GameInfo, grid:CollideGrid = null, x:Number = 0, y:Number = 0, graphic:Graphic = null, mask:Mask = null)
		{
			m_ginfo = ginfo;
			m_grid = grid;
		
			super(x, y, graphic, mask);
		}
		
		// move the mobile along its intended velocity, adjusting for collisions
		// should work with fixed or variable timestep. Just set "elapsed" properly
		public function collideMove(elapsed:Number):void {
			
			if (elapsed <= 0) return;
			
			// add gravity to effVel, up to termVel
			if (set_gravitate) {
				// note: doing it this way leads to the strange situation where the sign of termVel
				//       gives the direction of gravity, and gravAccel needs to be positive always.
				//       also going faster than termvel, you'll return to termvel at gravAccel.
				//       that will probably be fine (unless we really want separate accelerations for
				//       normal gravity and air friction?)
				rd_effVel.y = FP.approach(rd_effVel.y, m_ginfo.termVel.y, m_ginfo.gravAccel.y * elapsed);
				// TODO UNDO THIS IT'S JUST FOR BRANDON -- no terminal velocity
				//rd_effVel.y += m_ginfo.gravAccel.y * elapsed * FP.sign(m_ginfo.termVel.y);
				rd_effVel.x = FP.approach(rd_effVel.x, m_ginfo.termVel.x, m_ginfo.gravAccel.x * elapsed);
			}
					
			// adjust effVel toward intVel at maxAccel rate
			rd_effVel.x = FP.approach(rd_effVel.x, set_intVel.x, set_maxAccel.x * elapsed);
			rd_effVel.y = FP.approach(rd_effVel.y, set_intVel.y, set_maxAccel.y * elapsed);
			
			// scale effVel into effMove based on elapsed time this frame
			upd_effMove.x = rd_effVel.x * elapsed;
			upd_effMove.y = rd_effVel.y * elapsed;
			
			// do collisions with physical objects up to collideMax (so no infinite loop)
			// these objects might change the upd_ values, based on collidePush
			// (can be interesting: eg moving platforms can pull you along)
			i = 0;
			gridi = 0;
			gridEnt = null;
			//var colEnt:Entity;
			//var collided:Boolean;
			
			upd_blockLeft = null;
			upd_blockRight = null;
			upd_blockBot = null;
			upd_blockTop = null;
			
			if (m_grid) { // fudge version
					gridEnt = m_grid.GetBlocks(Math.min(y - originY, y - originY + upd_effMove.y) - height * 2,
											   Math.max(y - originY, y - originY + upd_effMove.y) + height * 3,
											   Math.min(x - originX, x - originX + upd_effMove.x) - width * 2,
											   Math.max(x - originX, x - originX + upd_effMove.x) + width * 3);
											   
			}
			
			while( i < m_ginfo.collideMax) {
				
				//if (m_grid) {
				//	gridEnt = m_grid.GetBlocks(Math.min(y - originY, y - originY + upd_effMove.y),
				//							   Math.max(y - originY + height, y - originY + upd_effMove.y + height),
				//							   Math.min(x - originX, x - originX + upd_effMove.x),
				//							   Math.max(x - originX + width, x - originX + upd_effMove.x + width));
				//}
				
				if (gridEnt) {
					gridi = 0;
					colEnt = gridi >= gridEnt.length ? null : gridEnt[gridi];
				}
				else
					colEnt = world ? world.typeFirst("physical"): null;
					
				collided = false;
				// TODO "sweep" collisions for movements that are too far apart (based on entity box)
				// things possibly wrong with this algorithm:
				// 1) the "first" collider is not the first one in the path,
				//    so it might deflect things the wrong way
				// 2) if the level is large, maybe a "grid" type thing should be used
				//    to speed up colission culling (did this)
				while (colEnt) {
					if (collideWith(colEnt, x + upd_effMove.x, y + upd_effMove.y) ) {
						i++;
						collided = true;
					}
					
					if (gridEnt) {
						gridi++;
						colEnt = gridi >= gridEnt.length ? null : gridEnt[gridi];
					}
					else
						colEnt = world.typeNext(colEnt);
				}
				
				if (!collided) break;
			}
			
			// do the actual move (should we clamp to integers? todo)
			x = x + upd_effMove.x;
			y = y + upd_effMove.y;
			
			// scale effMove back to effVel based on elapsed time, for use next update
			rd_effVel.x = upd_effMove.x / elapsed;
			rd_effVel.y = upd_effMove.y / elapsed;
		} 
		
	}

}