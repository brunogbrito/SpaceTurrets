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


	UFUNCTION()
	void InitializeLevelCreation(FString String)
	{
		Print(String, 1.0f);

		//Destroy spawned actors and clear array
		for(int i = 0; i < SpawnedActorsArray.Num(); i++)
		{
			SpawnedActorsArray[i].DestroyActor();
		}
		SpawnedActorsArray.Empty();

		//Spawn Actors
		TArray<FString> StringArray = String::GetCharacterArrayFromString(String);
		for(int i = 0; i < StringArray.Num(); i++)
		{
			SpawnLevelActors(StringArray[i]);
		}
	}

	UFUNCTION()
	void SpawnLevelActors(FString ActorString)
	{

	}
}