import Components.ST_HealthComponent;

class ASTBaseEnemy : APawn
{
	UPROPERTY(DefaultComponent)
	UCapsuleComponent CapsuleCollision;
	default CapsuleCollision.SetCollisionObjectType(ECollisionChannel::EnemyAI);
	default CapsuleCollision.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
	default CapsuleCollision.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Ignore);

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent EnemyMesh;

	UPROPERTY(DefaultComponent)
	USTHealthComponent HealthComponent;
}