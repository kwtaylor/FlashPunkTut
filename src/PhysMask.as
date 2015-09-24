package  
{

	import net.flashpunk.Mask;
	
	// mask that can push mobs around when they try to collide.
	// can only do normal hit detection with default "Masks" assigned to entities.
	// won't work with Hitboxes, Pixelmasks etc. 
	public class PhysMask extends Mask
	{
		private var p_collide:Boolean;
		private var otherMob:MobEntity;
		
		public function PhysMask() 
		{
			_check[Mask] = collideMask;
		}
		
		// so what happens is the MobEntity does a collideWith all "physical" objects nearby,
		// which causes its Entity to call _mask.collide on the physical object, which 
		// then calls _check[Mask], which is collideMask! The entity initiating the call ends up
		// with its mask (usually just the default HITBOX) being "other"
		
		private function collideMask(other:Mask):Boolean
		{
			p_collide = collideCheck(other);
			otherMob = other.parent as MobEntity;
			
			if (p_collide && otherMob) {
				if (otherMob.set_collidePush) collidePush(otherMob);
			}
			
			return p_collide;
		}
		
		// this class doesn't provide default collision mechanics (ie, against non-hitboxes).
		// subclasses should provide something in case other.parent isn't a MobEntity (basic rectangle check ie)
		// TODO somehow put the default checking here? 
		public function collideCheck(other:Mask):Boolean {
			return false;
		}
		
		public function collidePush(mob:MobEntity):void {
		}
		
	}

}