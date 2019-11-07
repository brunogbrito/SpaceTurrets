class ASTMapDirector : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Category="Collision")
	UBoxComponent TopCollision;
	default TopCollision.CollisionObjectType = ECollisionChannel::ECC_WorldStatic;
	default TopCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
	default TopCollision.BoxExtent = FVector(32.0f, 32.0f, 500.0f);

	UPROPERTY(DefaultComponent, Attach = TopCollision)
	UStaticMeshComponent TopMesh;
	default TopMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default TopMesh.RelativeScale3D = FVector(0.25f);

	UPROPERTY(DefaultComponent, Category="Collision")
	UBoxComponent BottomCollision;
	default BottomCollision.CollisionObjectType = ECollisionChannel::ECC_WorldStatic;
	default BottomCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
	default BottomCollision.BoxExtent = FVector(32.0f, 32.0f, 500.0f);

	UPROPERTY(DefaultComponent, Attach = BottomCollision)
	UStaticMeshComponent BottomMesh;
	default BottomMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default BottomMesh.RelativeScale3D = FVector(0.25f);

	UPROPERTY(DefaultComponent, Category="Collision")
	UBoxComponent RightCollision;
	default RightCollision.CollisionObjectType = ECollisionChannel::ECC_WorldStatic;
	default RightCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
	default RightCollision.BoxExtent = FVector(32.0f, 32.0f, 500.0f);

	UPROPERTY(DefaultComponent, Attach = RightCollision)
	UStaticMeshComponent RightMesh;
	default RightMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default RightMesh.RelativeScale3D = FVector(0.25f);

	UPROPERTY(DefaultComponent, Category="Collision")
	UBoxComponent LeftCollision;
	default LeftCollision.CollisionObjectType = ECollisionChannel::ECC_WorldStatic;
	default LeftCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
	default LeftCollision.BoxExtent = FVector(32.0f, 32.0f, 500.0f);

	UPROPERTY(DefaultComponent, Attach = LeftCollision)
	UStaticMeshComponent LeftMesh;
	default LeftMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default LeftMesh.RelativeScale3D = FVector(0.25f);

	UPROPERTY()
	bool bDevMode = false;

	UPROPERTY()
	float MapSize = 1000.0f;

	UPROPERTY()
	float CellDistance = 200.0f;

	UPROPERTY()
	float CellArea = 25.0f;

	UPROPERTY(BlueprintReadWrite)
	int IndexMultiplier = 1;

	UPROPERTY()
	TArray<USceneComponent> SlotsLocation;

	UPROPERTY()
	bool bShowCellsNumbers = true;

	float MapScaleDivision = 15.0f;


	/*** FUNCTIONS ***/

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		TopCollision.RelativeLocation = FVector(0.0f, MapSize, 0.0f);
		TopCollision.RelativeScale3D = FVector(MapSize/MapScaleDivision, 1.0f, 3.0f);

		BottomCollision.RelativeLocation = FVector(0.0f, -MapSize, 0.0f);
		BottomCollision.RelativeScale3D = FVector(MapSize/MapScaleDivision, 1.0f, 3.0f);

		RightCollision.RelativeLocation = FVector(MapSize, 0.0f, 0.0f);
		RightCollision.RelativeScale3D = FVector(1.0f, MapSize/MapScaleDivision, 3.0f);

		LeftCollision.RelativeLocation = FVector(-MapSize, 0.0f, 0.0f);
		LeftCollision.RelativeScale3D = FVector(1.0f, MapSize/MapScaleDivision, 3.0f);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if(!bDevMode)
		{
			bShowCellsNumbers = false;
		}
	}
}