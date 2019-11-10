import Character.ST_PlayerProjectile;
import Components.ST_HealthComponent;
import Actors.ST_MapDirector;
import Core.ST_GameState;
import Core.ST_Statics;

class ASTShip : APawn
{
	UPROPERTY(DefaultComponent, RootComponent, Category = "Components")
	UBoxComponent ShipCollisionBox;
	default ShipCollisionBox.CollisionEnabled = ECollisionEnabled::QueryOnly;
	default ShipCollisionBox.CollisionObjectType = ECollisionChannel::ECC_WorldDynamic;
	default ShipCollisionBox.SetCollisionResponseToChannel(ECollisionChannel::ECC_WorldStatic, ECollisionResponse::ECR_Block);

	UPROPERTY(DefaultComponent, Category = "Components")
	USceneComponent ShipHullMeshes;

	UPROPERTY(DefaultComponent, Attach=ShipHullMeshes, Category = "Components")
	USceneComponent ProjectileSpawnLocation;
	
	UPROPERTY(DefaultComponent, Category = "Components")
	USpringArmComponent SpringArm;
	default SpringArm.TargetArmLength = 1800.0f;
	default SpringArm.bDoCollisionTest = false;
	default SpringArm.bEnableCameraLag = true;
	default SpringArm.CameraLagSpeed = 2.0f;

	UPROPERTY(DefaultComponent, Attach=SpringArm, Category = "Components")
	UCameraComponent Camera;

	UPROPERTY(DefaultComponent, Category = "Components")
	UFloatingPawnMovement PawnMovementComponent;

    UPROPERTY(DefaultComponent, Category = "Components")
    UInputComponent PlayerInputComponent;

	UPROPERTY(DefaultComponent)
	USTHealthComponent HealthComponent;
	default HealthComponent.MaxHealth = 3.0f;

	UPROPERTY(Category = "Ship Movement")
	float ShipSpeed = 100.0f;

	UPROPERTY(Category = "Ship Movement")
	float ShipRotationInterpSpeed = 10.0f;

	UPROPERTY(Category = "Projectile")
	TSubclassOf<ASTPlayerProjectile> ProjectileClass;

	UPROPERTY(Category = "Projectile")
    FTimerHandle TimeHandle_EachProjectileTimer;

	UPROPERTY(Category = "Projectile")
	float ProjectileRPM = 370.0f;

	UPROPERTY(Category = "Projectile")
	USoundBase SShipShot;

	UPROPERTY(Category = "PickUps")
	bool bBonusShot;

	UPROPERTY(Category = "PickUps")
	bool bBonusSlowMotion;

	UPROPERTY(Category = "PickUps")
	bool bBonusProjectileBounce;

	UPROPERTY(Category = "PickUps")
	bool bBonusInvencible;

	//Movement Local Variables
	float RotateXValue;
	float RotateYValue;
	float MoveForwardValue;
	float MoveRightValue;

	//Projectile Trigger Local Variables
	float LastProjectileShot;
    float TimeBetweenShots;

	ASTMapDirector MapDirector;
	ASTGameState GS;

	default Tags.Add(n"ship");


	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		GS = Cast<ASTGameState>(Gameplay::GetGameState());
		
		BindInput();
		InitializeDefaultValues();

		HealthComponent.OnDeath.AddUFunction(this, n"ResetShip");
		GS.OnStartGameSignature.AddUFunction(this, n"ResetShip");
	}

	UFUNCTION()
	void InitializeDefaultValues()
	{
		TimeBetweenShots = 60 / ProjectileRPM;
        LastProjectileShot = -1.0f;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		SetShipRotation();
	}

	UFUNCTION()
	void BindInput()
	{
		PlayerInputComponent.BindAxis(n"MoveForward", FInputAxisHandlerDynamicSignature(this, n"MoveForward"));
		PlayerInputComponent.BindAxis(n"MoveRight", FInputAxisHandlerDynamicSignature(this, n"MoveRight"));

		PlayerInputComponent.BindAxis(n"RotateX", FInputAxisHandlerDynamicSignature(this, n"RotateX"));
		PlayerInputComponent.BindAxis(n"RotateY", FInputAxisHandlerDynamicSignature(this, n"RotateY"));

		PlayerInputComponent.BindAction(n"Shoot", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"StartShooting"));
		PlayerInputComponent.BindAction(n"Shoot", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"StopShooting"));
	}

	UFUNCTION()
	void MoveForward(float AxisValue)
	{
		if(AxisValue != 0.0f)
		{
			MoveForwardValue = AxisValue;
			PawnMovementComponent.AddInputVector((FVector((AxisValue * ShipSpeed) * Gameplay::GetWorldDeltaSeconds(), 0.0f, 0.0f)));
		}
		else
		{
			MoveForwardValue = 0.0f;
		}
	}

	UFUNCTION()
	void MoveRight(float AxisValue)
	{
		if(AxisValue != 0.0f)
		{
			MoveRightValue = AxisValue;
			PawnMovementComponent.AddInputVector((FVector(0.0f, (AxisValue * ShipSpeed) * Gameplay::GetWorldDeltaSeconds(), 0.0f)));
		}
		else
		{
			MoveRightValue = 0.0f;
		}
	}

	UFUNCTION()
	void RotateX(float AxisValue)
	{
		RotateXValue = AxisValue;
	}

	UFUNCTION()
	void RotateY(float AxisValue)
	{
		RotateYValue = AxisValue;
	}

	UFUNCTION()
	void StartShooting(FKey Key)
	{
		if(Gameplay::GetTimeSeconds() > LastProjectileShot + TimeBetweenShots)
		{
			SpawnProjectile();
		}
		float InitialDelay = FMath::Max(LastProjectileShot + TimeBetweenShots - Gameplay::GetTimeSeconds(), 0.0f);
		TimeHandle_EachProjectileTimer = System::SetTimer(this, n"SpawnProjectile", TimeBetweenShots, true, InitialDelay);
	}

	UFUNCTION()
	void StopShooting(FKey Key)
	{
		System::ClearAndInvalidateTimerHandle(TimeHandle_EachProjectileTimer);
	}

	UFUNCTION()
	void SpawnProjectile()
	{
		
		AActor MyProjectile = SpawnActor(ProjectileClass, ProjectileSpawnLocation.GetWorldLocation(), ProjectileSpawnLocation.GetWorldRotation());

		if(bBonusShot)
		{
			//TODO Multiple Projectiles
		}
		
		if(SShipShot != nullptr)
		{
			Gameplay::PlaySound2D(SShipShot);
		}
	}

	UFUNCTION()
	void SetShipRotation()
	{	
		FVector AxisVector;
		if(RotateXValue != 0.0f || RotateYValue != 0.0f)
		{
			AxisVector = FVector(RotateXValue,RotateYValue,0.0f);
		}
		else if(MoveForwardValue != 0.0f || MoveRightValue != 0.0f)
		{
			AxisVector = FVector(MoveRightValue, -MoveForwardValue,0.0f);
		}
		else
		{
			return;
		}		
		FRotator TargetRotation = FRotator::MakeFromX(AxisVector) + FRotator(0.0f, 90.0f, 0.0f);
		ShipHullMeshes.SetWorldRotation(FMath::RInterpTo(ShipHullMeshes.WorldRotation, TargetRotation, Gameplay::GetWorldDeltaSeconds(), ShipRotationInterpSpeed));
	}

	UFUNCTION(BlueprintEvent)
	void ResetShip()
	{
		GS.FinishGame();
		HealthComponent.InitializeComponent();
	}
}