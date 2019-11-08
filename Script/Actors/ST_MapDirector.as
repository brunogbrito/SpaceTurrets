import Components.ST_LevelSpawnerComponent;

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

	UPROPERTY(DefaultComponent)
	USTLevelSpawnerComponent LevelSpawnerComponent;

	UPROPERTY()
	bool bDevMode = false;

	UPROPERTY()
	bool bLevelCreator = false;

	UPROPERTY()
	float MapSize = 1000.0f;

	UPROPERTY()
	float CellDistance = 200.0f;

	UPROPERTY()
	TArray<USceneComponent> SlotsLocation;

	UPROPERTY()
	bool bShowCellsNumbers = true;

	float MapScaleDivision = 15.0f;
	int IndexMultiplier = 1;


	/*** FUNCTIONS ***/

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		InitializeMapBorders(MapSize);
		InitializeGrid();
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if(!bDevMode)
		{
			bShowCellsNumbers = false;
		}
		if(bLevelCreator)
		{
			InitializeLevelCreatorWidget();
		}
	}

	UFUNCTION(BlueprintEvent)
	void InitializeLevelCreatorWidget()
	{
		//This widget is being initialized in the blueprint class
		return;
	}

	UFUNCTION()
	void InitializeMapBorders(float NewMapSize)
	{
		TopCollision.RelativeLocation = FVector(0.0f, NewMapSize, 0.0f);
		TopCollision.RelativeScale3D = FVector(NewMapSize/MapScaleDivision, 1.0f, 3.0f);

		BottomCollision.RelativeLocation = FVector(0.0f, -NewMapSize, 0.0f);
		BottomCollision.RelativeScale3D = FVector(NewMapSize/MapScaleDivision, 1.0f, 3.0f);

		RightCollision.RelativeLocation = FVector(NewMapSize, 0.0f, 0.0f);
		RightCollision.RelativeScale3D = FVector(1.0f, NewMapSize/MapScaleDivision, 3.0f);

		LeftCollision.RelativeLocation = FVector(-NewMapSize, 0.0f, 0.0f);
		LeftCollision.RelativeScale3D = FVector(1.0f, NewMapSize/MapScaleDivision, 3.0f);
	}

	UFUNCTION()
	void InitializeGrid()
	{
		IndexMultiplier = 1;

		for(int i = 0; i < SlotsLocation.Num(); i++)
		{
			if(SlotsLocation[i] != nullptr)
			{
				SlotsLocation[i].DestroyComponent(SlotsLocation[i]);
			}			
		}
		SlotsLocation.Empty();

		for(int i = 0; i <= FMath::Square(GetNumberOfRows()); i++)
		{
			if(i == 0)
			{}
			else if(i <= GetNumberOfRows()*IndexMultiplier)
			{
				AddCustomSceneComponent(GetSceneComponentRelativeLocation(i, IndexMultiplier), i);
			}
			else
			{
				IndexMultiplier++;
				AddCustomSceneComponent(GetSceneComponentRelativeLocation(i, IndexMultiplier), i);
			}
		}
	}

	UFUNCTION()
	void AddCustomSceneComponent(FVector RelativeLocation, int CellIndex)
	{
		USceneComponent MySceneComponent = USceneComponent::Create(this);
		MySceneComponent.SetRelativeLocation(RelativeLocation);
		SlotsLocation.Add(MySceneComponent);
		if(bShowCellsNumbers)
		{
			AddTextRender(RelativeLocation, CellIndex);
		}
	}

	UFUNCTION()
	void StartLevelString()
	{
		// LevelSpawnerComponent.SpawnActors(F);
	}


	/*** Math and Debug Functions ***/

	UFUNCTION()
	int GetNumberOfRows()
	{
		return (MapSize-200.0f)/(CellDistance/2.0f);
	}

	UFUNCTION()
	FVector GetSceneComponentRelativeLocation(int LoopIndex, int CellMultiplierIndex)
	{
		FVector MyVector = FVector((MapSize-100.0f)-(CellDistance*CellMultiplierIndex), ((LoopIndex+1)*CellDistance)-((GetNumberOfRows()*CellMultiplierIndex)*CellDistance)+(MapSize-500.0f), 100.0f);
		return MyVector;
	}

	UFUNCTION(BlueprintEvent)
	void AddTextRender(FVector RelativeLocation, int CellIndex)
	{
		return;
	}

}