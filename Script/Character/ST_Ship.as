import Core.ST_Statics;

class ASTShip : APawn
{
	UPROPERTY(DefaultComponent, RootComponent, Category = "Components")
	UBoxComponent ShipCollisionBox;
	default ShipCollisionBox.CollisionEnabled = ECollisionEnabled::QueryOnly;
	default ShipCollisionBox.CollisionObjectType = ECollisionChannel::ECC_WorldDynamic;

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

	UPROPERTY()
	float ShipSpeed = 100.0f;

	UPROPERTY()
	float ShipRotationInterpSpeed = 10.0f;

	UPROPERTY()
    FTimerHandle TimeHandle_EachProjectileTimer;

	UPROPERTY()
	float ProjectileRPM = 450.0f;

	//Movement Local Variables
	float RotateXValue;
	float RotateYValue;
	float MoveForwardValue;
	float MoveRightValue;

	//Projectile Trigger Local Variables
	float LastProjectileShot;
    float TimeBetweenShots;
	

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BindInput();
		InitializeDefaultValues();
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
		P();
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

}