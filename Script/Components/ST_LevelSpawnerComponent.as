import Core.ST_Statics;
import Core.ST_LevelAssets;

struct FSpawnActor
{
	UPROPERTY()
	FString Character;

	UPROPERTY()
	AActor Actor;
};

struct FLevelType
{
	UPROPERTY()
	float MapSize;

	UPROPERTY()
	FString SpawnLevelString;
};

class USTLevelSpawnerComponent : UActorComponent
{
	UPROPERTY()
	ST_LevelAssets LevelDataAssets;

	UPROPERTY()
	TArray<FLevelType> LevelStages;

	UPROPERTY()
	TArray<AActor> SpawnedActorsArray;

	UPROPERTY()
	TMap<FString, AActor> LevelAssetMap;


	// UFUNCTION()
	// void InitializeLevelCreation(FString String)
	// {


	// 	//Spawn Actors
	// 	TArray<FString> StringArray = String::GetCharacterArrayFromString(String);
	// 	for(int i = 0; i < StringArray.Num(); i++)
	// 	{
	// 		SpawnLevelActors(StringArray[i]);
	// 	}
	// }

	UFUNCTION()
	void ClearLevel()
	{
		for(int i = 0; i < SpawnedActorsArray.Num(); i++)
		{
			SpawnedActorsArray[i].DestroyActor();
		}
		SpawnedActorsArray.Empty();
	}

	UFUNCTION()
	void SpawnLevelActors(TSubclassOf<AActor> LevelActorAsset, FVector RelativeLocation)
	{
		//Destroy spawned actors and clear array
		AActor MySpawnedActor = SpawnActor(LevelActorAsset, RelativeLocation, FRotator::ZeroRotator);
		SpawnedActorsArray.Add(MySpawnedActor);
	}
}