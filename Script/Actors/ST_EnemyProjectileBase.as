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
	float HommingProjectileSpeed = 20.0f;

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
				break;

			case EProjectileType::HOMING:
				bFollowPlayer = true;
				bCanCollideWithProjectiles = true;
				break;
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if(bFollowPlayer)
		{
			PlayerShip = Cast<ASTShip>(Gameplay::GetPlayerPawn(0));
			SetHomingTarget(PlayerShip.RootComponent);
			ProjectileMovementComponent.SetbIsHomingProjectile(true);
		}
	}

	UFUNCTION(BlueprintEvent)
	void SetHomingTarget(USceneComponent HomingTarget)
	{
		return;
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

	}
}