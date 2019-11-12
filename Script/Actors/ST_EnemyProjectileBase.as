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
	
	UPROPERTY()
	bool bCanCollideWithProjectiles;

	UPROPERTY()
	FRotator CurrentActorRotation;

	UPROPERTY()
	float HommingProjectileSpeed = 20.0f;

	UPROPERTY()
	float RotationInterpSpeed = 50.0f;


	/*** LOCAL TYPES ***/

	ASTShip PlayerShip;
	bool bFollowPlayer;


	/*** DEFAULTS ***/

	default ProjectileMovementComponent.InitialSpeed = 750.0f;
	default Tags.Add(n"EnemyProjectile");
	default Tags.Add(n"enemy");


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
		//Set Homing Missile target in Blueprints
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
				if(OtherActor.ActorHasTag(n"Wall"))
				{
					DestroyActor();	
				}
				return;
			}
			else
			{
				DestroyActor();			
			}
		}
		if(OtherActor.ActorHasTag(n"enemy") && OtherActor.ActorHasTag(n"Wall"))
		{
			DestroyActor();
		}
	}
}