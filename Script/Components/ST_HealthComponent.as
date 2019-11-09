import Core.ST_Statics;

event void FOnTakeDamage();
event void FOnResetComponent();
event void FOnDeath();

class USTHealthComponent : UActorComponent
{
	UPROPERTY()
	float Health;

	UPROPERTY()
	float MaxHealth = 1.0f;

	UPROPERTY()
	bool bIsInvencible;

	UPROPERTY()
	FOnTakeDamage OnTakeDamageSignature;

	UPROPERTY()
	FOnResetComponent OnResetComponent;

	UPROPERTY()
	FOnDeath OnDeath; 


	/*** FUNCTIONS ***/

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Health = MaxHealth;
	}

	UFUNCTION()
	void ApplyDamage(AActor DamagedActor, float Damage, const UDamageType DamageType, AController InstigatedBy, AActor DamageCauser)
	{
		
		if(DamagedActor == DamageCauser)
		{
			return;
		}

		if(!bIsInvencible)
		{
			Health = FMath::Clamp(Health - Damage, 0.0f, MaxHealth);
		}

		OnTakeDamageSignature.Broadcast();

		if(Health <= 0.0f)
		{
			OnDeath.Broadcast();
			GetOwner().DestroyActor();
		}
	}
}