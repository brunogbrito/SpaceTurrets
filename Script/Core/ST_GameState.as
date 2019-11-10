event void FCustomEndGame();
event void FBeginStage(int NextStage);
event void FStartGame();

class ASTGameState : AGameStateBase
{	
	UPROPERTY()
	float Score;

	UPROPERTY()
	int Stage;

	UPROPERTY()
	int ActiveEnemies;

	UPROPERTY()
	FCustomEndGame OnEndGameSignature;

	UPROPERTY()
	FBeginStage OnBeginStageSignature;

	UPROPERTY()
	FStartGame OnStartGameSignature;

	UFUNCTION()
	void StartGame()
	{
		InitializeGame();
		OnStartGameSignature.Broadcast();
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
	void AddActiveEnemy()
	{
		ActiveEnemies++;
	}

	UFUNCTION()
	void EnemyDestroyed()
	{
		ActiveEnemies = FMath::Clamp(ActiveEnemies - 1, 0 , 100);
		if(ActiveEnemies == 0)
		{
			NextStage(Stage);
		}
		Print("ActiveEnemies" + ActiveEnemies, 1.0f);
	}

	UFUNCTION()
	void NextStage(int NextStage)
	{
		//Broadcast to MapDirector
		OnBeginStageSignature.Broadcast(Stage);
		Stage++;
	}

	UFUNCTION()
	void FinishGame()
	{
		OnEndGameSignature.Broadcast();
	}
}