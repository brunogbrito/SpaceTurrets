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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BindInput();
	}

	UFUNCTION()
	void BindInput()
	{
		PlayerInputComponent.BindAxis(n"MoveForward", FInputAxisHandlerDynamicSignature(this, n"GoForward"));
		PlayerInputComponent.BindAxis(n"MoveRight", FInputAxisHandlerDynamicSignature(this, n"GoRight"));
	}

	UFUNCTION()
	void GoForward(float AxisValue)
	{
		PawnMovementComponent.AddInputVector((FVector((AxisValue * ShipSpeed) * Gameplay::GetWorldDeltaSeconds(), 0.0f, 0.0f)));
	}

	UFUNCTION()
	void GoRight(float AxisValue)
	{
		PawnMovementComponent.AddInputVector((FVector(0.0f, (AxisValue * ShipSpeed) * Gameplay::GetWorldDeltaSeconds(), 0.0f)));
	}

}