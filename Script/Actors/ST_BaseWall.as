import Components.ST_HealthComponent;
import Core.ST_GameState;
import Character.ST_Ship;

enum EBlockType{
	CUBE,
	HORWALL,
	VERTWALL
};

class ASTBaseWall : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
	
	UPROPERTY(DefaultComponent)
	UBoxComponent BoxCollision;
	default BoxCollision.CollisionObjectType = ECollisionChannel::ECC_WorldStatic;
	default BoxCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
	default BoxCollision.SetCollisionResponseToChannel(ECollisionChannel::ShipProjectile, ECollisionResponse::ECR_Overlap);
	default BoxCollision.GenerateOverlapEvents = true;

	UPROPERTY(DefaultComponent)
	UBoxComponent PlayerOverlapCollision;
	default PlayerOverlapCollision.BoxExtent = FVector(80.0f);

	UPROPERTY(DefaultComponent, Attach = BoxCollision)
	UStaticMeshComponent BlockMesh;
	default BlockMesh.CollisionEnabled = ECollisionEnabled::NoCollision;

	UPROPERTY(DefaultComponent)
	USTHealthComponent HPComponent;

	UPROPERTY()
	EBlockType EnumBlockType;

	UPROPERTY()
	float WallHP = 3.0f;

	UPROPERTY()
	FVector BoxExtension = FVector(100.0f, 100.0f, 100.0f);;

	default Tags.Add(n"Wall");
	

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		BoxCollision.BoxExtent = BoxExtension;
		PlayerOverlapCollision.BoxExtent = BoxExtension - FVector(20.0f);

		switch(EnumBlockType)
		{
			case EBlockType::CUBE:
			if(HPComponent != nullptr)
			{
				HPComponent.DestroyComponent(HPComponent);
			}
			break;

			case EBlockType::HORWALL:
			HPComponent.MaxHealth = WallHP;
			Tags.Add(n"enemy");
			break;

			case EBlockType::VERTWALL:
			HPComponent.MaxHealth = WallHP;
			Tags.Add(n"enemy");
			break;
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ASTGameState GS = Cast<ASTGameState>(Gameplay::GetGameState());
		GS.OnEndGameSignature.AddUFunction(this, n"RemoveActor");

		PlayIntroAnimation();
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		ASTShip ShipActor = Cast<ASTShip>(OtherActor);
		if(ShipActor != nullptr && PlayerOverlapCollision.IsOverlappingActor(ShipActor))
		{
			ShipActor.ResetShipLocation();
		}
	}

	UFUNCTION(BlueprintEvent)
	void PlayIntroAnimation()
	{
		//Trigger Blueprint timeline animation 
		return;
	}

	UFUNCTION(BlueprintEvent)
	void PlayVisualEffect()
	{
		//Trigger Blueprint timeline animation 
		return;
	}

	UFUNCTION()
	void RemoveActor()
	{
		DestroyActor();
	}
}