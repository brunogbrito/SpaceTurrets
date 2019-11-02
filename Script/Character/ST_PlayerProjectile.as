class ASTPlayerProjectile : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent CollisionBox;
	default CollisionBox.CollisionObjectType = ECollisionChannel::ShipProjectile;
	default CollisionBox.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
	default CollisionBox.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Ignore);

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent ProjectileMesh;
	default ProjectileMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent ProjectileMovementComponent;
	default ProjectileMovementComponent.InitialSpeed = 2000.0f;
	default ProjectileMovementComponent.ProjectileGravityScale = 0.0f;

	default InitialLifeSpan = 3.0f;
}