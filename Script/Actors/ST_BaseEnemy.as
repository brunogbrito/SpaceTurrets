import Core.ST_Statics;
import Components.ST_HealthComponent;
import Core.ST_GameState;
import Character.ST_Ship;
import Actors.ST_EnemyProjectileBase;

enum EEnemyType
{
	STATIC,
	MOVEABLE,
	RANDOM_MOTION,
	SHIELD
};

class ASTBaseEnemy : APawn
{
	UPROPERTY(DefaultComponent, Category = "Collision")
	UCapsuleComponent CapsuleCollision;
	default CapsuleCollision.SetCollisionObjectType(ECollisionChannel::EnemyAI);
	default CapsuleCollision.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
	default CapsuleCollision.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Ignore);

	UPROPERTY(DefaultComponent, Category = "StaticMesh")
	UStaticMeshComponent EnemyMesh;

	UPROPERTY(DefaultComponent, Category = "Components")
	UFloatingPawnMovement FloatingMovementComponent;

	UPROPERTY(DefaultComponent, Category = "Components")
	USTHealthComponent HealthComponent;

	UPROPERTY(DefaultComponent)
	UArrowComponent ForwardArrow;

	UPROPERTY()
	ASTGameState GS;

	UPROPERTY()
	ASTShip PlayerShip;

	UPROPERTY()
	float EnemySpeed;

	UPROPERTY()
	float RotationInterpSpeed;

	UPROPERTY()
	FRotator CurrentActorRotation;

	UPROPERTY()
	EEnemyType EnumEnemyType = EEnemyType::STATIC;

	UPROPERTY()
	TSubclassOf<ASTEnemyProjectileBase> ProjectileClass;

	bool bIsMoving;
	bool bHomeMissile;

	/*** FUNCTION ***/

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		GS = Cast<ASTGameState>(Gameplay::GetGameState());
		PlayerShip = Cast<ASTShip>(Gameplay::GetPlayerPawn(0));
		InitializeEnemy();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if(bIsMoving)
		{
			AddMovementAndRotation();
		}
			SpawnProjectile(0.0f, ForwardArrow, true);
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
			//System::MoveComponentTo(RootComponent, PlayerShip.GetActorLocation() - GetActorLocation(), FRotator::MakeFromX(PlayerShip.GetActorLocation() - GetActorLocation()), true, true, 5.0f, true, EMoveComponentAction::Move, FLatentActionInfo());
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
		AddMovementInput(PlayerShip.GetActorLocation() - GetActorLocation(), Gameplay::GetWorldDeltaSeconds() * EnemySpeed);
		CurrentActorRotation = FMath::RInterpTo(CurrentActorRotation, FRotator::MakeFromX(PlayerShip.GetActorLocation() - GetActorLocation()), 
			Gameplay::GetWorldDeltaSeconds(), RotationInterpSpeed);
		SetActorRotation(CurrentActorRotation);
	}

	UFUNCTION()
	void SpawnProjectile(float ProjectileInitialSpeed, UArrowComponent Arrow, bool bTraceline)
	{
		if(bTraceline)
		{
			TArray<AActor> IgnoredActors;
			IgnoredActors.Add(this);

			FHitResult Hit;
			if(System::LineTraceSingle(GetActorLocation(), GetActorRotation().GetForwardVector() * 50000.0f, 
				ETraceTypeQuery::Visibility, false, IgnoredActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red, FLinearColor::Green, 1.0f))
			{
				System::DrawDebugLine(Hit.TraceStart, Hit.TraceEnd, FLinearColor::Blue, 1.0f, 2.0f);
				
				//Spawn Projectile
				if(Hit.Actor == PlayerShip)
				{
					AActor SpawnedProjectile = SpawnActor(ProjectileClass, GetActorLocation(), GetActorRotation());
				}
			}
		}
	}
}