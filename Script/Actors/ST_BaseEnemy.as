import Core.ST_Statics;
import Components.ST_HealthComponent;
import Core.ST_GameState;
import Character.ST_Ship;
import Actors.ST_EnemyProjectileBase;
import Actors.ST_MapDirector;

enum EEnemyMovementType
{
	STATIC,
	MOVEABLE,
	RANDOM_MOTION
};

enum EEnemyShootingType
{
	NONE,
	REGULAR,
	SPIRAL,
	CROSS
};

class ASTBaseEnemy : APawn
{
	UPROPERTY(DefaultComponent, Category = "Collision")
	UCapsuleComponent CapsuleCollision;
	default CapsuleCollision.SetCollisionObjectType(ECollisionChannel::EnemyAI);
	default CapsuleCollision.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
	default CapsuleCollision.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Ignore);

	UPROPERTY(DefaultComponent, Category ="Projectie")
	USceneComponent ProjectileSpawnLocation;

	UPROPERTY(DefaultComponent, Category ="Projectie")
	USceneComponent ProjectileRotator;

	UPROPERTY(DefaultComponent, Category = "StaticMesh")
	UStaticMeshComponent EnemyMesh;

	UPROPERTY(Category = "StaticMesh")
	UMaterialInstanceDynamic EnemyDynamicMaterialInstance;

	UPROPERTY(Category = "StaticMesh")
	FLinearColor InitialColor;

	UPROPERTY(DefaultComponent, Category = "Components")
	UFloatingPawnMovement FloatingMovementComponent;

	UPROPERTY(DefaultComponent, Category = "Components")
	USTHealthComponent HealthComponent;

	UPROPERTY(DefaultComponent, Category = "Components")
	UArrowComponent ForwardArrow;

	UPROPERTY()
	float EnemySpeed;

	UPROPERTY()
	float RotationInterpSpeed;

	UPROPERTY()
	EEnemyMovementType EnumEnemyMovement = EEnemyMovementType::STATIC;

	UPROPERTY()
	EEnemyShootingType EnumEnemyShooting = EEnemyShootingType::REGULAR;

	UPROPERTY()
	float ProjectileRotationSpeed = 100.0f;

	UPROPERTY()
	TSubclassOf<ASTEnemyProjectileBase> PrimaryProjectileClass;

	UPROPERTY()
	TSubclassOf<ASTEnemyProjectileBase> SecondaryProjectileClass;

	UPROPERTY()
	bool bAlternateProjectiles;

	UPROPERTY()
	bool bScanForPlayer;

	UPROPERTY()
	bool bNoRotation;

	UPROPERTY()
	float TimeBetweenShots = 0.75f;

	UPROPERTY()
	float ScoringPoints = 25.0f;


	/*** LOCAL TYPES ***/

	ASTGameState GS;
	ASTShip PlayerShip;
	ASTMapDirector MapDirector;

	bool bIsMoving;
	bool bHomeMissile;
	bool bIsAlternateProjectile;

	FRotator CurrentActorRotation;
	TArray<AActor> IgnoredActors;
	FTimerHandle TimeHandle_Shooting;


	/*** DEFAULTS ***/

	default AutoPossessAI = EAutoPossessAI::PlacedInWorldOrSpawned;
	default Tags.Add(n"enemy");


	/*** FUNCTIONS ***/

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		GS = Cast<ASTGameState>(Gameplay::GetGameState());
		PlayerShip = Cast<ASTShip>(Gameplay::GetPlayerPawn(0));

		TArray<ASTMapDirector> MapDirectorArray;
		ASTMapDirector::GetAll(MapDirectorArray);
		MapDirector = MapDirectorArray[0];

		HealthComponent.OnDeath.AddUFunction(this, n"ScorePoint");
		HealthComponent.OnTakeDamageSignature.AddUFunction(this, n"PlayVisualFeedback");

		EnemyDynamicMaterialInstance =  EnemyMesh.CreateDynamicMaterialInstance(0, EnemyMesh.GetMaterial(0));
		InitialColor = EnemyDynamicMaterialInstance.GetVectorParameterValue(n"Color");
		EnemyMesh.SetMaterial(0, EnemyDynamicMaterialInstance);

		GS.OnEndGameSignature.AddUFunction(this, n"RemoveActor");

		InitializeEnemy();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if(!bNoRotation)
		{
			AddRotation();
		}
		if(bIsMoving)
		{
			AddMovement();
		}
	}

	UFUNCTION()
	void InitializeEnemy()
	{
		IgnoredActors.Add(this);
		
		if(MapDirector.bDevMode)
		{
			return;		//Do not initialize in DevMode
		}

		switch(EnumEnemyMovement)
		{
			case EEnemyMovementType::STATIC:
			bIsMoving = false;
			break;
			
			case EEnemyMovementType::MOVEABLE:
			bIsMoving = true;
			break;

			case EEnemyMovementType::RANDOM_MOTION:
			bIsMoving = FMath::RandBool();
			break;
		}
		bIsAlternateProjectile = false;
		InitializeShooterTimer();
		AddActiveEnemy();
	}

	UFUNCTION()
	void AddMovement()
	{
		AddMovementInput(FVector(PlayerShip.GetActorLocation().X, PlayerShip.GetActorLocation().Y, ActorLocation.Z) - GetActorLocation(),
			Gameplay::GetWorldDeltaSeconds() * EnemySpeed);
	}

	UFUNCTION()
	void AddRotation()
	{
		if(PlayerShip != nullptr)
		{
			CurrentActorRotation = FMath::RInterpTo(CurrentActorRotation, FRotator::MakeFromX(PlayerShip.GetActorLocation() - GetActorLocation()), 
				Gameplay::GetWorldDeltaSeconds(), RotationInterpSpeed);
			SetActorRotation(CurrentActorRotation);
		}
		if(ProjectileRotationSpeed != 0)
		{
			ProjectileRotator.AddWorldRotation(FRotator(0.0f, Gameplay::GetWorldDeltaSeconds() * ProjectileRotationSpeed, 0.0f));
		}
	}

	UFUNCTION()
	void InitializeShooterTimer()
	{
		TimeHandle_Shooting = System::SetTimer(this, n"ShootRoutine", TimeBetweenShots, true, 0.0f, 0.0f);
	}

	UFUNCTION()
	void ShootRoutine()
	{
		switch(EnumEnemyShooting)
		{
			case EEnemyShootingType::NONE:
				System::ClearAndInvalidateTimerHandle(TimeHandle_Shooting);
				break;

			case EEnemyShootingType::REGULAR:
				if(bScanForPlayer)
				{
					FHitResult Hit;
					if(System::LineTraceSingle(GetActorLocation(), GetActorRotation().GetForwardVector() * 50000.0f, 
						ETraceTypeQuery::Enemy, false, IgnoredActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red, FLinearColor::Green, 1.0f))
					{
						//Spawn Projectile
						if(Hit.Actor == PlayerShip)
						{
							SpawnProjectile(ProjectileSpawnLocation.GetWorldLocation(), FRotator(0.0f, ActorRotation.Yaw, 0.0f));
						}
					}
				}
				else
				{
					SpawnProjectile(ProjectileSpawnLocation.GetWorldLocation(), FRotator(0.0f, ActorRotation.Yaw, 0.0f));
				}
				break;
			
			case EEnemyShootingType::SPIRAL:
				SpawnProjectile(GetActorLocation(), FRotator(0.0f, ProjectileRotator.RelativeRotation.Yaw, 0.0f));
				SpawnProjectile(GetActorLocation(), FRotator(0.0f, ProjectileRotator.RelativeRotation.Yaw + 180.0f, 0.0f));
				break;
			
			case EEnemyShootingType::CROSS:
				SpawnProjectile(GetActorLocation(), FRotator(0.0f, ProjectileRotator.RelativeRotation.Yaw, 0.0f));
				SpawnProjectile(GetActorLocation(), FRotator(0.0f, ProjectileRotator.RelativeRotation.Yaw + 90.0f, 0.0f));
				SpawnProjectile(GetActorLocation(), FRotator(0.0f, ProjectileRotator.RelativeRotation.Yaw + 180.0f, 0.0f));
				SpawnProjectile(GetActorLocation(), FRotator(0.0f, ProjectileRotator.RelativeRotation.Yaw + 270.0f, 0.0f));
				break;
		}
	}

	UFUNCTION()
	void SpawnProjectile(FVector SpawnLocation, FRotator ProjectileRotation)
	{
		if(bAlternateProjectiles)
		{
			if(!bIsAlternateProjectile)
			{
				if(PrimaryProjectileClass.IsValid())
				{
					AActor SpawnedProjectile = SpawnActor(PrimaryProjectileClass, SpawnLocation, ProjectileRotation);
					bIsAlternateProjectile = true;
				}
				else
				{
					Print("Primary Projectile Class is NULL. Please assign a projectile class", 5.0f);
				}
			}
			else
			{
				if(SecondaryProjectileClass.IsValid())
				{
					AActor SpawnedProjectile = SpawnActor(SecondaryProjectileClass, SpawnLocation, ProjectileRotation);
					bIsAlternateProjectile = false;
				}
				else
				{
					Print("Primary Projectile Class is NULL. Please assign a projectile class", 5.0f);
				}
			}
		}
		else
		{
			if(PrimaryProjectileClass.IsValid())
			{
				AActor SpawnedProjectile = SpawnActor(PrimaryProjectileClass, SpawnLocation, ProjectileRotation);
			}
			else
			{
				Print("Primary Projectile Class is NULL", 5.0f);
			}
		}
	}

	UFUNCTION(BlueprintEvent)
	void PlayVisualFeedback()
	{
		//Trigger Blueprint timeline animation 
		return;
	}

	UFUNCTION()
	void ScorePoint()
	{
		GS.AddScore(ScoringPoints);
	}

	UFUNCTION()
	void RemoveActor()
	{
		DestroyActor();
	}

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		if(MapDirector != nullptr && !MapDirector.bDevMode)
		{
			GS.EnemyDestroyed();
		}
	}

	UFUNCTION(BlueprintEvent)
	void AddActiveEnemy()
	{
		GS.AddActiveEnemy();
	}
}