import Components.ST_HealthComponent;
import Core.ST_GameState;
import Character.ST_Ship;

enum EEnemyType
{
	STATIC,
	MOVEABLE,
	RANDOM_MOTION,
	SHIELD
};

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

	UPROPERTY()
	ASTGameState GS;

	UPROPERTY()
	ASTShip PlayerShip;

	UPROPERTY()
	float EnemySpeed;

	UPROPERTY()
	FRotator ActorRotation;

	UPROPERTY()
	EEnemyType EnumEnemyType = EEnemyType::STATIC;

	bool bIsMoving;
	bool bHomeMissile;

	/*** FUNCTION ***/

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		GS = Cast<ASTGameState>(Gameplay::GetGameState());
		PlayerShip = Cast<ASTShip>(Gameplay::GetPlayerPawn(0));
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if(bIsMoving)
		{
			AddMovementAndRotation();
		}
	}

	UFUNCTION()
	void InitializeEnemy()
	{
		switch(EnumEnemyType)
		{
			case EEnemyType::STATIC:
			bIsMoving = false;
			break;
			
			case EEnemyType::MOVEABLE:
			bIsMoving = true;
			break;

			case EEnemyType::RANDOM_MOTION:
			bIsMoving = FMath::RandBool();
			break;

			case EEnemyType::SHIELD:
			bIsMoving = true;
			break;
		}
	}

	UFUNCTION()
	void AddMovementAndRotation()
	{
		AddMovementInput(PlayerShip.GetActorLocation()-GetActorLocation(), Gameplay::GetWorldDeltaSeconds()*EnemySpeed);
	}
}