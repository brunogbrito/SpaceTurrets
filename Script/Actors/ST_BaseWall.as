import Components.ST_HealthComponent;

enum EBlockType{
	CUBE,
	HORWALL,
	VERTWALL
};

class ASTBaseWall : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent BoxCollision;
	default BoxCollision.CollisionObjectType = ECollisionChannel::ECC_WorldStatic;
	default BoxCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
	default BoxCollision.SetCollisionResponseToChannel(ECollisionChannel::ShipProjectile, ECollisionResponse::ECR_Overlap);
	default BoxCollision.GenerateOverlapEvents = true;

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent BlockMesh;
	default BlockMesh.CollisionEnabled = ECollisionEnabled::NoCollision;

	UPROPERTY(DefaultComponent)
	USTHealthComponent HPComponent;

	UPROPERTY()
	EBlockType EnumBlockType;

	UPROPERTY()
	float WallHP = 3.0f;

	UPROPERTY()
	FVector BoxExtension = FVector(100.0f, 100.0f, 100.0f);

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		BoxCollision.BoxExtent = BoxExtension;
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
}