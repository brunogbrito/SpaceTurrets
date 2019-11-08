class ST_LevelAssets : UPrimaryDataAsset
{
	UPROPERTY()
	TMap<FString, TSubclassOf<AActor>> ActorsList;
}