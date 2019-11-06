import Character.ST_PlayerProjectile;
import Character.ST_Ship;

enum EProjectileType
{
	NORMAL,
	FULLDAMAGE,
	HOMING
}

class ASTEnemyProjectileBase : ASTPlayerProjectile
{
	UPROPERTY()
	EProjectileType EnumProjectileType;
	
	default ProjectileMovementComponent.InitialSpeed = 750.0f;

	default Tags.Add(n"enemy");

	UPROPERTY()
	bool bCanCollideWithProjectiles;

	UPROPERTY()
	ASTShip PlayerShip;

	UPROPERTY()
	FRotator CurrentActorRotation;

	UPROPERTY()
	float HommingProjectileSpeed;

	UPROPERTY()
	float RotationInterpSpeed = 50.0f;

	bool bFollowPlayer;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		switch(EnumProjectileType)
		{
			case EProjectileType::NORMAL:
				bCanCollideWithProjectiles = true;
				break;

			case EProjectileType::FULLDAMAGE:
				bCanCollideWithProjectiles = false;
				bFollowPlayer = true;
				break;

			case EProjectileType::HOMING:
				ProjectileMovementComponent.SetActive(false);
				bCanCollideWithProjectiles = true;
				break;
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		PlayerShip = Cast<ASTShip>(Gameplay::GetPlayerPawn(0));
	}
	
	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if(OtherActor != nullptr && !OtherActor.ActorHasTag(n"enemy"))
		{
			OtherActor.AnyDamage(ProjectileDamage, DamageType, GetInstigatorController(), this);
			if(bCanCollideWithProjectiles != true && !OtherActor.ActorHasTag(n"ship"))
			{
				return;
			}
			else
			{
				DestroyActor();
			}
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if(bFollowPlayer)
		{
			if(PlayerShip != nullptr)
			{
				CurrentActorRotation = FMath::RInterpTo(CurrentActorRotation, FRotator::MakeFromX(PlayerShip.GetActorLocation() - GetActorLocation()), 
					Gameplay::GetWorldDeltaSeconds(), RotationInterpSpeed);
				SetActorRotation(CurrentActorRotation);

				AddMovementInput(FVector(PlayerShip.GetActorLocation().X, PlayerShip.GetActorLocation().Y, ActorLocation.Z) - GetActorLocation(), Gameplay::GetWorldDeltaSeconds() * HommingProjectileSpeed);
			}
		}
	}
}