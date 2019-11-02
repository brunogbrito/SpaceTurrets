import Core.ST_Statics;

class ASTShip : APawn
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent ShipCollisionBox;
	default ShipCollisionBox.CollisionEnabled = ECollisionEnabled::QueryOnly;
	default ShipCollisionBox.CollisionObjectType = ECollisionChannel::ECC_WorldDynamic;

	UPROPERTY(DefaultComponent)
	USceneComponent ShipHullMeshes;

	UPROPERTY(DefaultComponent, Attach=ShipHullMeshes)
	USceneComponent ProjectileSpawnLocation;
	
	UPROPERTY(DefaultComponent)
	USpringArmComponent SpringArm;
	default SpringArm.TargetArmLength = 1800.0f;
	default SpringArm.bDoCollisionTest = false;
	default SpringArm.bEnableCameraLag = true;
	default SpringArm.CameraLagSpeed = 2.0f;

	UPROPERTY(DefaultComponent, Attach=SpringArm)
	UCameraComponent Camera;

	UPROPERTY(DefaultComponent)
	UFloatingPawnMovement PawnMovementComponent;

	UPROPERTY()
	float ShipSpeed = 100.0f;

    UPROPERTY(DefaultComponent, Category = "Components")
    UInputComponent PlayerInputComponent;

	float RotateXValue;
	float RotateYValue;
	float MoveForwardValue;
	float MoveRightValue;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BindInput();
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
	}

	UFUNCTION()
	void MoveForward(float AxisValue)
	{
		if(AxisValue != 0.0f)
		{
			MoveForwardValue = AxisValue;
			PawnMovementComponent.AddInputVector((FVector((AxisValue * ShipSpeed) * Gameplay::GetWorldDeltaSeconds(), 0.0f, 0.0f)));
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
	void SetShipRotation()
	{	
		if(RotateXValue != 0.0f || RotateYValue != 0.0f)
		{
			FVector AxisVector = FVector(RotateXValue,RotateYValue,0.0f);
			FRotator Rot = 	FRotator::MakeFromX(AxisVector);
			Rot = Rot + FRotator(0.0f, 90.0f, 0.0f);
			ShipHullMeshes.SetWorldRotation(FMath::RInterpTo(ShipHullMeshes.WorldRotation, Rot, Gameplay::GetWorldDeltaSeconds(), 10.0f));			
		}
		else if(MoveForwardValue != 0.0f || MoveRightValue != 0.0f)
		{
			FVector AxisVector = FVector(MoveRightValue, -MoveForwardValue,0.0f);
			FRotator Rot = 	FRotator::MakeFromX(AxisVector);
			Rot = Rot + FRotator(0.0f, 90.0f, 0.0f);
			ShipHullMeshes.SetWorldRotation(FMath::RInterpTo(ShipHullMeshes.WorldRotation, Rot, Gameplay::GetWorldDeltaSeconds(), 10.0f));	
		}
	}
}