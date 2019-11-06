class ASTEnemyProjectileBase : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent CollisionBox;

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent ProjectileMesh;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent ProjectileMovementComponent;


}