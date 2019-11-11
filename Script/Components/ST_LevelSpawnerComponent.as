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


	UFUNCTION()
	void ClearLevel()
	{
		for(int i = 0; i < SpawnedActorsArray.Num(); i++)
		{
			if(SpawnedActorsArray[i] != nullptr)
			{
				SpawnedActorsArray[i].DestroyActor();
			}
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