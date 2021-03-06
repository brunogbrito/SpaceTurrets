import Components.ST_LevelSpawnerComponent;
import Core.ST_GameState;
import Actors.ST_EmptyActor;

struct FLevelAssets
{
	UPROPERTY()
	TSubclassOf<AActor> LevelAssetActor;
};

struct FGameStages
{
	UPROPERTY()
	float MapSize;

	UPROPERTY()
	FString LevelString;
};

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

	UPROPERTY(DefaultComponent, Category = "Component")
	USTLevelSpawnerComponent LevelSpawnerComponent;

	UPROPERTY(Category = "GameplaySettings")
	TSubclassOf<AActor> StartGameActor;

	UPROPERTY(Category = "GameplaySettings")
	TSubclassOf<AActor> EndGameActor;

	UPROPERTY(Category = "GameplaySettings")
	TSubclassOf<AActor> EmptyActor;

	UPROPERTY(Category = "DevelopmentSettings")
	bool bDevMode = false;

	UPROPERTY(Category = "DevelopmentSettings")
	int StartAtStage = 0;

	UPROPERTY(Category = "DevelopmentSettings")
	bool bLevelCreator = false;

	UPROPERTY(Category = "DevelopmentSettings")
	float MapSize = 1000.0f;

	UPROPERTY(Category = "DevelopmentSettings")
	bool bShowCellsNumbers = true;

	UPROPERTY(Category = "GameplaySettings")
	TMap<FString, FLevelAssets> LevelAssetsMap;

	UPROPERTY(Category = "GameplaySettings")
	TArray<FGameStages> GameStages;


	/*** Local Variables ***/

	float MapScaleDivision = 15.0f;
	float CellDistance = 200.0f;
	int IndexMultiplier = 1;
	int DrawDebuggerIndex = 0;

	AActor MyEndGameActor;
	ASTGameState GS;

	UPROPERTY()
	TArray<USceneComponent> SlotsLocation;
	FTimerHandle TimeHandle_ResetGame;


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
			SpawnStartGameActor();
		}
		if(bLevelCreator)
		{
			InitializeLevelCreatorWidget();
		}

		InitializeLevelAssets();
		BindGameStateEvents();
		InitializeWorldHUD();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if(bDevMode)
		{
			DrawGridLocationReference();
		}
	}

	UFUNCTION()
	void BindGameStateEvents()
	{
		GS = Cast<ASTGameState>(Gameplay::GetGameState());
		GS.OnBeginStageSignature.AddUFunction(this, n"InitializeStage");
		GS.OnEndGameSignature.AddUFunction(this,n"ResetMapSize");
		GS.OnUpdateScoreSignature.AddUFunction(this, n"UpdateHUDScore");
		GS.OnStartGameSignature.AddUFunction(this, n"StartHUDAnimation");
	}

	UFUNCTION()
	void SpawnStartGameActor()
	{
		if(StartGameActor.IsValid())
		{
			AActor MyStartActor = SpawnActor(StartGameActor, FVector(0.0f, 0.0f, 100.0f), FRotator(270.0f, 0.0f, -180.0f));
		}
		else
		{
			Print("StartGameActor class is null, assign on MapDirector class", 1.0f);
		}
	}

	//FIX for TMaps being reset after Hot reload
	UFUNCTION(BlueprintEvent)
	void InitializeLevelAssets()
	{
		//Trigger Timeline and Spawning logic in blueprints
		return;
	}

	//This function is being triggered in Blueprints due the previus fix
	UFUNCTION()
	void LoadLevelAssetsMap(TMap<FString, FLevelAssets> TMap)
	{
		LevelAssetsMap = TMap;
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

	//This function is triggered via Blueprint class
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

	UFUNCTION(BlueprintEvent)
	void InitializeWorldHUD()
	{
		//Add World HUDWidget in blueprint class
		return;
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

	//Broadcasted from GS
	UFUNCTION()
	void InitializeStage(int NextStage)
	{
		if(NextStage + StartAtStage < GameStages.Num())
		{
			SetNextLevel(GameStages[NextStage+StartAtStage].MapSize, NextStage+StartAtStage);
			UpdateHUDStage(NextStage+StartAtStage);
		}
		else
		{
			LevelSpawnerComponent.ClearLevel();
			MyEndGameActor = SpawnActor(EndGameActor, FVector::ZeroVector, FRotator::ZeroRotator);
			TimeHandle_ResetGame = System::SetTimer(this, n"ResetGame", 5.0f, false);
		}
	}

	//Trigger Blueprint timeline animation
	UFUNCTION(BlueprintEvent)
	void SetNextLevel(float NewMapSize, int Stage)
	{
		return;
	}

	UFUNCTION()
	void SpawnLevelActors(int Stage)
	{
		StartLevelString(GameStages[Stage].LevelString);
	}

	UFUNCTION()
	void StartLevelString(FString LevelString)
	{
		////Destroy spawned actors and clear array
		LevelSpawnerComponent.ClearLevel();

		//Spawn Actors
		TArray<FString> StringArray = String::GetCharacterArrayFromString(LevelString);
		for(int i = 0; i < StringArray.Num(); i++)
		{
			if(LevelAssetsMap.Contains(StringArray[i]))
			{
				LevelSpawnerComponent.SpawnLevelActors(LevelAssetsMap.FindOrAdd(StringArray[i]).LevelAssetActor, SlotsLocation[i].GetWorldLocation());
			}
			else
			{
				LevelSpawnerComponent.SpawnLevelActors(EmptyActor, SlotsLocation[i].GetWorldLocation());
			}
			DrawDebuggerIndex = i;
		}
	}

	UFUNCTION(BlueprintEvent)
	void ResetMapSize()
	{
		//Play Blueprint animation
		return;
	}

	UFUNCTION()
	void RestartGame()
	{
		SpawnStartGameActor();
	}


	/*** World HUD Functions ***/

	UFUNCTION(BlueprintEvent)
	void UpdateHUDScore(int NewScore)
	{
		return;
	}

	UFUNCTION(BlueprintEvent)
	void UpdateHUDStage(int NewStage)
	{
		return;
	}

	UFUNCTION(BlueprintEvent)
	void StartHUDAnimation()
	{
		return;
	}

	UFUNCTION()
	void ResetGame()
	{	
		MyEndGameActor.DestroyActor();
		System::ClearAndInvalidateTimerHandle(TimeHandle_ResetGame);
		GS.FinishGame();
	}


	/*** Math and Debug Functions ***/

	UFUNCTION(BlueprintEvent)
	void InitializeLevelCreatorWidget()
	{
		//This widget is being initialized in the blueprint class
		return;
	}

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

	UFUNCTION()
	void DrawGridLocationReference()
	{
		System::DrawDebugBox(SlotsLocation[DrawDebuggerIndex].GetWorldLocation(), FVector(100.0f), FLinearColor::Green, FRotator::ZeroRotator, 0.1f, 50.0f);
	}
}