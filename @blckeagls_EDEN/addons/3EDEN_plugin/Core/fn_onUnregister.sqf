
params["_object"];
if !(_object getvariable["marker",""] isEqualTo "") then 
{
	[_object] call blck3DEN_fnc_removeMarker;
	_object setVariable ["marker",nil];
	//_object setVariable ["lootVehicle",nil];
	//_object setVariable ["garrisoned",nil];
};