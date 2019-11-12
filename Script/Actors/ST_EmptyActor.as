import Core.ST_GameState;

class ASTEmptyActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ASTGameState GS = Cast<ASTGameState>(Gameplay::GetGameState());
		GS.OnEndGameSignature.AddUFunction(this, n"RemoveActor");
	}

	UFUNCTION()
	void RemoveActor()
	{
		DestroyActor();
	}
}