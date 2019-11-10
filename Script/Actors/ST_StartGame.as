import Actors.ST_BaseEnemy;

class ASTStartGame : ASTBaseEnemy
{
	default HealthComponent.MaxHealth = 100.0f;

	UPROPERTY()
	FTimerHandle TimeHandle_ProgressBar;

	float ProgressBar;

	//This function is triggered in Blueprints
	UFUNCTION()
	void InitializeProgressBarSystem()
	{
		TimeHandle_ProgressBar = System::SetTimer(this, n"IncreaseProgressBar", 0.1f, true);
		HealthComponent.OnTakeDamageSignature.AddUFunction(this, n"OnTakeDamage");
	}

	UFUNCTION()
	void IncreaseProgressBar()
	{
		ProgressBar = FMath::Clamp(ProgressBar - 1.0f, 0.0f, 100.0f);
	}

	UFUNCTION()
	void OnTakeDamage()
	{
		ProgressBar = FMath::Clamp(ProgressBar + 8.0f, 0.0f, 100.0f);	
		if(ProgressBar >= 100.0f)
		{
			GS.StartGame();
			DestroyActor();
		}
	}

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		return;
	}

	UFUNCTION(BlueprintOverride)
	void AddActiveEnemy()
	{
		return;
	}
}