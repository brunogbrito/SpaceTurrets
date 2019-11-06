import Character.ST_PlayerProjectile;

class ASTEnemyProjectileBase : ASTPlayerProjectile
{
	default ProjectileMovementComponent.InitialSpeed = 750.0f;

	default Tags.Add(n"enemy");
	
	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if(OtherActor != nullptr && !OtherActor.ActorHasTag(n"enemy"))
		{
			OtherActor.AnyDamage(ProjectileDamage, DamageType, GetInstigatorController(), this);
			DestroyActor();
		}
	}
}