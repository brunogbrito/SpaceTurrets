import Core.ST_Statics;
import Actors.ST_MapDirector;

class USTLevelCreator : UUserWidget
{
	UPROPERTY()
	FString LevelString;

	UPROPERTY()
	ASTMapDirector MapDirector;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		TArray<ASTMapDirector> MapDirectorArray;
		ASTMapDirector::GetAll(MapDirectorArray);

		MapDirector = MapDirectorArray[0];
	}

	UFUNCTION()
	FString OnStringUpdate(FString String)
	{
		FString MyString = String.ToLower();
		if(MapDirector != nullptr)
		{
			MapDirector.StartLevelString(MyString);
		}
		return MyString;
	}
}