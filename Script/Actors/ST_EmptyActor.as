import Core.ST_GameState;

class ASTEmptyActor : AActor
{
	UPROPERTY()
	ASTGameState GS;
	
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		GS = Cast<ASTGameState>(Gameplay::GetGameState());
		GS.OnEndGameSignature.AddUFunction(this, n"RemoveActor");
	}

	UFUNCTION()
	void RemoveActor()
	{
		DestroyActor();
	}
}