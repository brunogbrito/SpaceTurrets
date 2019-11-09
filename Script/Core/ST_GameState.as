event void FEndGame();
event void FBeginStage(int NextStage);

class ASTGameState : AGameStateBase
{	
	UPROPERTY()
	float Score;

	UPROPERTY()
	int Stage;

	UPROPERTY()
	FEndGame OnEndGameSignature;

	UPROPERTY()
	FBeginStage OnBeginStageSignature;

	UFUNCTION()
	void StartGame()
	{
		InitializeGame();
		NextStage(Stage);
	}

	UFUNCTION()
	void InitializeGame()
	{
		Score = 0.0f;
		Stage = 0;
	}

	UFUNCTION()
	void AddScore(float ScoreValue)
	{
		Score = Score + ScoreValue;
	}

	UFUNCTION()
	void NextStage(int NextStage)
	{
		OnBeginStageSignature.Broadcast(Stage);
		Stage++;
	}

	UFUNCTION()
	void FinishGame()
	{
		OnEndGameSignature.Broadcast();
	}
}