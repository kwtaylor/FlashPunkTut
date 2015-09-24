package
{
	
	import flash.geom.Point;
	import net.flashpunk.Mask;
	
	// defines some basic physical shapes for collision
	// based on a rectangle block and some possible configurations of the collision inside it
	public class BasicPhysBlock extends PhysMask
	{
		public static const NONE:uint = 0;
		public static const FULL:uint = 1;
		public static const RAMP_UP_BOT:uint = 2;
		public static const RAMP_DN_BOT:uint = 3;
		public static const RAMP_UP_TOP:uint = 4;
		public static const RAMP_DN_TOP:uint = 5;
		public static const OW_D2U:uint = 6;
		public static const OW_U2D:uint = 7;
		public static const OW_L2R:uint = 8;
		public static const OW_R2L:uint = 9;
		public static const RAMP_UP_OW_D2U:uint = 10;
		public static const RAMP_UP_OW_U2D:uint = 11;
		public static const RAMP_DN_OW_D2U:uint = 12;
		public static const RAMP_DN_OW_U2D:uint = 13;
		
		public var type:uint;
		public var fric:Number;
		public var move:Point;
		
		public var fudge:Number = 1.0; // fudge factor to avoid rounding errors
		                               // causing collision false negatives, in pixels.
		public var nudge:Number = 0.001 // distance to push away from edge to avoid multiple collide
			
		private var hitTop:Boolean = false;
		private var hitBot:Boolean = false;
		private var hitLeft:Boolean = false;
		private var hitRight:Boolean = false;
		
		private var bot:Number;
		private var top:Number;
		private var left:Number;
		private var right:Number;
		private var newbot:Number;
		private var newtop:Number;
		private var newleft:Number;
		private var newright:Number;
		private var oldbot:Number;
		private var oldtop:Number;
		private var oldleft:Number;
		private var oldright:Number;
		
		private var otherMob:MobEntity = null;
		
		public function BasicPhysBlock(type:uint = 1, fric:Number = 1.0) 
		{
			this.type = type;
			this.fric = fric;
			this.move = new Point(0, 0);
		}
		
		private function checkHitTop( top:Number, left:Number, right:Number,
									  mob_old_bot:Number, mob_old_left:Number, mob_old_right:Number,
									  mob_new_bot:Number, mob_new_left:Number, mob_new_right:Number):Boolean {

			if (mob_old_bot <= top + fudge && mob_new_bot >= top) {
				// hit = 
				//    block.topleft is to the left of path of mob.botright
				//    AND
				//    block.topright is to the right of path of mob.botleft
				
				// degenerate horizontal case
				if (mob_old_bot == mob_new_bot) return true;
						
				return !GU.AboveLine(mob_old_bot, mob_old_right,
									 mob_new_bot, mob_new_right,
									 top, left )
					 && GU.AboveLine(mob_old_bot, mob_old_left,
									 mob_new_bot, mob_new_left,
									 top, right );
			}
			
			return false;
		}
		
		override public function collideCheck(other:Mask):Boolean {
			
			otherMob = null;
			
			hitTop = false;
			hitBot = false;
			hitLeft = false;
			hitRight = false;
			
			if (other.parent) {
				otherMob = other.parent as MobEntity;
			}
			
			switch(type) { 
				case FULL:
					// ok we're just a rectangle. This can't be hard.
					if (!otherMob && other.parent) {
						return other.parent.collideRect(other.parent.x, other.parent.y, 
						                                parent.x - parent.originX, parent.y - parent.originY, 
														parent.width, parent.height);
					} else if (otherMob) {					
						top = parent.y - parent.originY + fudge/2;
						bot = top + parent.height - fudge;
						left = parent.x - parent.originX + fudge/2;
						right = left + parent.width - fudge;
						newtop = otherMob.y - otherMob.originY;
						newbot = newtop + otherMob.height;
						newleft = otherMob.x - otherMob.originX;
						newright = newleft + otherMob.width;
						oldtop = newtop - otherMob.upd_effMove.y;
						oldbot = oldtop + otherMob.height;
						oldleft = newleft - otherMob.upd_effMove.x;
						oldright = oldleft + otherMob.width;
						
						// where the mob could collide is based on its old position
						
						hitTop = checkHitTop( top, left, right,
						                      oldbot, oldleft, oldright,
											  newbot, newleft, newright );
						
						if (hitTop) return true;
						
						hitLeft = checkHitTop( left, top, bot,
						                       oldright, oldtop, oldbot,
											   newright, newtop, newbot );
						
						if (hitLeft) return true;
						
						hitRight = checkHitTop( -right, top, bot,
						                        -oldleft, oldtop, oldbot,
												-newleft, newtop, newbot );
						
						if (hitRight) return true;
						
						hitBot = checkHitTop( -bot, left, right,
											  -oldtop, oldleft, oldright,
											  -newtop, newleft, newright );
						
						return hitBot;
						
					} else {
						return false;
					}
					break;
				default: 
					return false;
					break;
				}
		}
		
		override public function collidePush(mob:MobEntity):void {
			// figure slope of surface being collided through
			// figure normal to push mob back to surface
			switch(type) { 
				case FULL:
					if (hitTop) {
						mob.upd_effMove.y -= newbot - top + nudge;
						mob.upd_blockBot = this;
					} else if (hitLeft) {
						mob.upd_effMove.x -= newright - left + nudge;
						mob.upd_blockRight = this;
					} else if (hitRight) {
						mob.upd_effMove.x += right - newleft + nudge;
						mob.upd_blockLeft = this;
					} else if (hitBot) {
						mob.upd_effMove.y += bot - newtop + nudge;
						mob.upd_blockTop = this;
					}
				break;
			}
		}
		
	}
}
