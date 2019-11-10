import Actors.ST_MapDirector;
import Core.ST_GameState;

class ASTCheckpoint : AActor
{
	UPROPERTY(DefaultComponent)
	USphereComponent Collision; 

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent Mesh;
	default Mesh.CollisionEnabled = ECollisionEnabled::NoCollision;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if(OtherActor.ActorHasTag(n"ship"))
		{	
		}
	}
}