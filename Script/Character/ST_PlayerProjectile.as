class ASTPlayerProjectile : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent CollisionBox;

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent ProjectileMesh;
	default ProjectileMesh.SetEnableGravity(false);
	default ProjectileMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent ProjectileMovementComponent;
	default ProjectileMovementComponent.InitialSpeed = 2000.0f;
	default ProjectileMovementComponent.ProjectileGravityScale = 0.0f;

	default InitialLifeSpan = 3.0f;
}