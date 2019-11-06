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

	UPROPERTY()
	bool bScanForPlayer;

	UPROPERTY()
	FTimerHandle TimeHandle_Shooting;

	UPROPERTY()
	float TimeBetweenShots = 0.75f;


	bool bIsMoving;
	bool bHomeMissile;

	default Tags.Add(n"enemy");

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
		AddRotation();
		if(bIsMoving)
		{
			AddMovement();
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
			//System::MoveComponentTo(RootComponent, PlayerShip.GetActorLocation() - GetActorLocation(), FRotator::MakeFromX(PlayerShip.GetActorLocation() - GetActorLocation()), true, true, 5.0f, true, EMoveComponentAction::Move, FLatentActionInfo());
			break;

			case EEnemyType::RANDOM_MOTION:
			bIsMoving = FMath::RandBool();
			break;

			case EEnemyType::SHIELD:
			bIsMoving = true;
			break;
		}
		InitializeShooterTimer();
	}

	UFUNCTION()
	void AddMovement()
	{
		AddMovementInput(FVector(PlayerShip.GetActorLocation().X, PlayerShip.GetActorLocation().Y, ActorLocation.Z) - GetActorLocation(), Gameplay::GetWorldDeltaSeconds() * EnemySpeed);
	}

	UFUNCTION()
	void AddRotation()
	{
		CurrentActorRotation = FMath::RInterpTo(CurrentActorRotation, FRotator::MakeFromX(PlayerShip.GetActorLocation() - GetActorLocation()), 
			Gameplay::GetWorldDeltaSeconds(), RotationInterpSpeed);
		SetActorRotation(CurrentActorRotation);
	}

	UFUNCTION()
	void InitializeShooterTimer()
	{
		TimeHandle_Shooting = System::SetTimer(this, n"ShootRoutine", TimeBetweenShots, true, 0.0f, 0.0f);
	}

	UFUNCTION()
	void ShootRoutine()
	{
		if(bScanForPlayer)
		{
			TArray<AActor> IgnoredActors;
			IgnoredActors.Add(this);

			FHitResult Hit;
			if(System::LineTraceSingle(GetActorLocation(), GetActorRotation().GetForwardVector() * 50000.0f, 
				ETraceTypeQuery::Enemy, false, IgnoredActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red, FLinearColor::Green, 1.0f))
			{
				// System::DrawDebugLine(Hit.TraceStart, Hit.TraceEnd, FLinearColor::Blue, 1.0f, 2.0f);
				
				//Spawn Projectile
				if(Hit.Actor == PlayerShip)
				{
					SpawnProjectile();
				}
			}
		}
		else
		{
			SpawnProjectile();
		}
	}

	UFUNCTION()
	void SpawnProjectile()
	{
		AActor SpawnedProjectile = SpawnActor(ProjectileClass, GetActorLocation(), FRotator(0.0f, ActorRotation.Yaw, 0.0f));
	}
}