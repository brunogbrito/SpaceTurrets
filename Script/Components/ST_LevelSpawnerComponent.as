import Core.ST_Statics;

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
	TArray<FLevelType> LevelStages;

	UFUNCTION()
	void SpawnActors(FString String)
	{
		Print(String, 1.0f);
	}
}