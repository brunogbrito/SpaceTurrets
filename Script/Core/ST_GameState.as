event void FCustomEndGame();
event void FBeginStage(int NextStage);
event void FStartGame();
event void FUpdateScore(int CurrentScore);

class ASTGameState : AGameStateBase
{	
	UPROPERTY()
	int Score;

	UPROPERTY()
	int Stage;

	UPROPERTY()
	int ActiveEnemies;

	UPROPERTY()
	bool bGameStarted;

	UPROPERTY()
	FCustomEndGame OnEndGameSignature;

	UPROPERTY()
	FBeginStage OnBeginStageSignature;

	UPROPERTY()
	FStartGame OnStartGameSignature;

	UPROPERTY()
	FUpdateScore OnUpdateScoreSignature;


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
		bGameStarted = true;
	}

	UFUNCTION()
	void AddScore(int ScoreValue)
	{
		Score = Score + ScoreValue;
		OnUpdateScoreSignature.Broadcast(Score); 	//Broadcast to MapDirector
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
		if(ActiveEnemies == 0 && bGameStarted)
		{
			NextStage(Stage);
		}
	}

	UFUNCTION()
	void NextStage(int NextStage)
	{
		OnBeginStageSignature.Broadcast(Stage);		//Broadcast to MapDirector
		Stage++;
	}

	UFUNCTION()
	void FinishGame()
	{
		bGameStarted = false;
		OnEndGameSignature.Broadcast();		//Broadcast to BaseEnemy
	}
}