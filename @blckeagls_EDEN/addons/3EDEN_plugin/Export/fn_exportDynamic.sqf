/*
	blckeagls 3EDEN Editor Plugin
	by Ghostrider-GRG-
	Copyright 2020
	
*/
#define oddsOfGarrison 0.67
#define maxGarrisonUnits 4

objectAtMissionCenter = getText(configFile >> "CfgBlck3DEN"  >> "configs" >> "objectAtMissionCenter");
blck_minAI = getNumber(configFile >> "CfgBlck3DEN"  >> "configs" >> "minAI");
blck_maxAI = getNumber(configFile >> "CfgBlck3DEN"  >> "configs" >> "maxAI");
minPatrolRadius = getNumber(configFile >> "CfgBlck3DEN"  >> "configs" >> "minPatroRadius");
maxPatrolRadius = getNumber(configFile >> "CfgBlck3DEN"  >> "configs" >> "maxPatrolRadius");
maxVehiclePatrolRadius = getNumber(configFile >> "CfgBlck3DEN"  >> "configs" >> "maxVehiclePatrolRadius");
aircraftPatrolRadius = getNumber(configFile >> "CfgBlck3DEN"  >> "configs" >> "aircraftPatrolRadius");
garisonMarkerObject = "Sign_Sphere100cm_F";
oddsOfGarison = getNumber(configFile >> "CfgBlck3DEN"  >> "configs" >> "oddsOfGarison");
maxGarrisonStatics = getNumber(configFile >> "CfgBlck3DEN"  >> "configs" >> "maxGarrisonStatics");
typesGarrisonStatics = getArray(configFile >> "CfgBlck3DEN"  >> "configs" >> "typesGarrisonStatics");
blck_MissionDifficulty = missionNamespace getVariable["blck_difficulty",getText(configFile >> "CfgBlck3DEN"  >> "configs" >> "defaultMissionDifficulty")];
lootVehicleVariableName = getText(configFile >> "CfgBlck3DEN"  >> "configs" >> "lootVehicleVariableName");
buildingPosGarrisonVariableName = getText(configFile >> "CfgBlck3DEN"  >> "configs" >> "buildingPosGarrisonVariableName");
buildingATLGarrisionVariableName = getText(configFile >> "CfgBlck3DEN"  >> "configs" >> "buildingATLGarrisionVariableName");

/*
{
	diag_log format["param %1 = %2",_forEachIndex,_x];
} forEach [
	objectAtMissionCenter,
	blck_minAI,
	blck_maxAI,
	minPatrolRadius,
	maxPatrolRadius,
	maxVehiclePatrolRadius,
	aircraftPatrolRadius,
	oddsOfGarison,
	maxGarrisonStatics,
	typesGarrisonStatics,
	blck_MissionDifficulty,
	lootVehicleVariableName,
	buildingPosGarrisonVariableName,
	buildingATLGarrisionVariableName	
];*/

CENTER = [0,0,0];

diag_log format["Dynamic Export called at %1",diag_tickTime];
diag_log format["With blck_MissionDifficulty = %1",blck_MissionDifficulty];

/*
	Set Default Values Where not Defined using Menu Commands
*/
if (isNil "blck_dynamicStartMessage") then 
{
	blck_dynamicStartMessage = "TODO: Change approiately";
};
if (isNil "blck_dynamicEndMessage") then 
{
	blck_dynamicEndMessage = "TODO: Change Appropriately";
};
if (isNil "blck_dynamicCrateLoot") then 
{
	blck_dynamicCrateLoot = format["_crateLoot = blck_BoxLoot_%1;",blck_MissionDifficulty];
};
if (isNil "blck_dynamicCrateLootCounts") then {
	blck_dynamicCrateLootCounts = format["_lootCounts = blck_lootCounts%1;",blck_MissionDifficulty];
};
if (isNil "blck_dynamicmarkerMissionName") then 
{
	blck_dynamicmarkerMissionName = "TODO: Update appropriately";
};
if (isNil "blck_spawnCratesTiming") then 
{
	blck_spawnCratesTiming = missionNamespace getVariable["blck_lootTiming","atMissionStartGround"];
}; 
if (isNil "blck_loadCratesTiming") then 
{
	 blck_loadCratesTiming = missionNamespace getVariable["blck_loadTiming","atMissionStart"];
};
if (isNil "blck_missionEndCondition") then 
{
	blck_missionEndCondition = missionNamespace getVariable["blck_endState","allUnitsKilled"];
};

/*
	Look for an object defined in CfgBlck3DEN \ configs \ that marks the center of the mission 
	and set the coords of the center if such an object is found 
*/

private _centerMarkers = allMissionObjects objectAtMissionCenter;
diag_log format["_centerMarkers = %1",_centerMarkers];
if !(_centerMarkers isEqualTo []) then 
{
	CENTER = getPosATL (_centerMarkers select 0);
	diag_log format["CENTER defined by object %1 typeOf %2",_centerMarker,typeOf (_centerMarkers select 0)];
} else {
	diag_log format["<WARNING> No object marking the center of the mission was found: using a flashing road cone or flag is recommended",getText(configFile >> "CfgVehicles" >> objectAtMissionCenter >> "displayName")];
	diag_log format["Place such an object or a marker to ensure the mission is accurately stored and spawned"];
};

all3DENEntities params ["_objects","_groups","_triggers","_systems","_waypoints","_markers","_layers","_comments"];
private _units = []; 
{
	{
		if (vehicle _x isEqualTo _x) then {_units pushBack _x};
	} forEach (units _x);
} forEach _groups;

private["_m1","_markerPos","_markerType","_markerShape","_markerColor","_markerText","_markerBrush","_markerSize","_markerAlpha"];
/*
	pull info on the first marker found 
*/
if !(_markers isEqualTo []) then 
{
	_m1 = _markers select 0;
	_markerType = (_m1 get3DENAttribute "itemClass") select 0;
	_markerShape = (_m1 get3DENAttribute "markerType") select 0;
	_markerColor = (_m1 get3DENAttribute "baseColor") select 0;
	_markerText = (_m1 get3DENAttribute "text") select 0;
	if !(_markerText isEqualTo "") then {blck_dynamicmarkerMissionName = _markerText};
	_markerBrush = (_m1 get3DENAttribute "markerBrush") select 0;
	_markerPos = (_m1 get3DENAttribute "position") select 0;
	_markerSize = (_m1 get3DENAttribute "size2") select 0;
	_markerText = (_m1 get3DENAttribute "text") select 0;

	/*
		use the coordinates of that marker as mission center of no object demarkating the center is found 
	*/
	if ((isNil "CENTER") || (CENTER isEqualTo [0,0,0])) then {
		CENTER = _markerPos;
		diag_log format["Position of marker %1 used for position of CENTER = %2",_m1,CENTER];
	};
	if (count _markers > 1) then 
	{
		diag_log format["<WARNING> More than one marker was found; only the first marker was processed"];
	};
} else {
	_markerType = "mil_square";
	_markerShape = "null";
	_markerSize = "[0,0]";
	_markerColor = "COLORRED";
	_markerBrush = "null";
	if !(_objects isEqualTo []) then 
	{
		CENTER = getPosATL (_objects select 0);
	} else {
		CENTER = getPos (_objects select 0);
	};
	diag_log format["<WARNING> No marker was found, using default values and position for mission center position"];
};
diag_log format["_m1 = %1 | _type = %2 | _shape = %3 | _size = %4 | _color = %5 | _brush = %6 | _text = %7",_m1,_markerType,_markerShape,_markerSize,_markerColor,_markerBrush,_markerText];

if (CENTER isEqualTo [0,0,0]) then 
{
	CENTER = getPosATL (_staticObjects select 0);
};
diag_log format["CENTER = %1",CENTER];

private _garisonedBuildings = [];
private _garisonedStatics = [];
private _garisonedUnits = [];

private _landscape =  _objects select{
    !(isSimpleObject _x) && 
    ((typeOf _x) isKindOf "Static" || ( (typeOf _x) isKindOf "ThingX")) && 
	!((typeOf _x) isKindOf "ReammoBox_F") && 
	!(_x getVariable["isLootContainer",false]) && 
	!((typeOf _x) isKindOf "Helper_Base_F")
};

private _garisonedPos = [];
private _helpers = _objects select {((typeOf _x) isEqualTo garisonMarkerObject)};

{
	if (_x getVariable["garrisoned",false]) then
	{
		_garisonedBuildings pushbackunique _building;		
		//  data structure ["building Classname",[/*building pos*/],/*building dir*/,/*odds of garrison*/, /*Max Statics*/,/*types statics*/,/*max units*/],
													// 1				2								3			4	  5			6			7					8						9
		_garisonedPos pushBack format['     ["     %1",%2,%3,%4,%5,%6,%7,%8,%9]',typeOf _building,(getPosATL _building) vectorDiff CENTER,getDir _building, 'true','true',oddsOfGarrison,maxGarrisonStatics,typesGarrisonStatics,maxGarrisonUnits];
	};
} forEach _landscape;
//diag_log format["CENTER = %1 | _landscape = %2",CENTER,_landscape];
private _garrisonATL = [];
{
	_atl = [_x,CENTER] call blck3DEN_fnc_configureGarrisonATL;

	// format["_fnc_exportDynamic: _building = %1 | _atl = %2",_x,_atl];
	//diag_log format["_fnc_exportDynamic: typeName _atl = %1",typeName _atl];
	if (typeName _atl isEqualTo "STRING") then {diag_log format["_fnc_exportDynamic: length _atl = %1 | _atl = '' is %2",count _atl, _atl isEqualTo ""]};
	if !(_atl isEqualTo []) then {
		if !((_atl select 0) isEqualTo []) then 
		{
			_garrisonATL pushBack (format["     %1",_atl select 0]);
			_garisonedBuildings pushBack _x;
			_garisonedStatics append (_atl select 1);
			_garisonedUnits append (_atl select 2)
			//diag_log format["_fnc_exportDynamic: garrisoned building added: %1",_atl];
		};
	};
} forEach _landscape;
diag_log format["_garrisonATL = %1",_garrisonATL];

private _missionLandscape = [];
{
	if !(_x in _garisonedBuildings) then 
	{
		_missionLandscape pushBack format['     ["%1",%2,%3,%4,%5]',typeOf _x,(getPosATL _x) vectorDiff CENTER,getDir _x, 'true','true'];
	};
}forEach _landscape;

private _simpleObjects = _objects select {isSimpleObject _x};
diag_log format["_simpleObjects = %1",_simpleObjects];
private _missionSimpleObjects = [];
{
	_missionSimpleObjects pushBack format['     ["%1",%2,%3,%4,%5]',typeOf _x,(getPosATL _x) vectorDiff CENTER,getDir _x, 'true','true'];
} forEach _simpleObjects;

private _missionLootVehicles = [];
private _lootVehicles = _objects select {
	((typeOf _x) isKindOf "AllVehicles") && 
	!((typeOf _x) isKindOf "Man") &&	
	(_x getVariable["lootvehicle",false])
};
diag_log format["_lootVehicles = %1",_lootVehicles];
{
	_missionLootVehicles pushBack format['     ["%1",%2,%3,%4,%5]',typeOf _x,(getPosATL _x) vectorDiff CENTER, '_crateLoot','_lootCounts',getDir _x];
} forEach _lootVehicles;

_missionPatrolVehicles = [];
private _patrolVehicles = _objects select {
	(((typeOf _x) isKindOf "Car") || ((typeOf _x) isKindOf "Tank") || ((typeOf _x) isKindOf "Ship")) && 
	!((typeOf _x) isKindOf "SDV_01_base_F") && 
	!(_x in _lootVehicles)
};
diag_log format["_patrolVehicles = %1",_patrolVehicles];
{
	_missionPatrolVehicles pushBack format['     ["%1",%2,%3,%4,%5]',typeOf _x,(getPosATL _x) vectorDiff CENTER,getDir _x,maxVehiclePatrolRadius,maxVehiclePatrolRadius];
}forEach _patrolVehicles;

private _subPatrols = [];
private _subs = _objects select {
	((typeOf _x) isKindOf "SDV_01_base_F") && 
	!(_x in _lootVehicles)
};
diag_log format["_subs = %1",_subs];
{
	_subPatrols pushBack format['     ["%1",%2,%3,%4,%5]',typeOf _x,(getPosATL _x) vectorDiff CENTER,getDir _x,maxVehiclePatrolRadius,maxVehiclePatrolRadius];
} forEach _subs;

private _airPatrols = [];
private _airVehicles = _objects select {
	((typeOf _x) isKindOf "Air")
};
diag_log format["_airVehicles = %1",_airvehicles];
{
	_airPatrols pushBack format['     ["%1",%2,%3,%4,%5]',typeOf _x,(getPosATL _x) vectorDiff CENTER,getDir _x,aircraftPatrolRadius,aircraftPatrolRadius];
} forEach _airVehicles;


private _staticWeapons = [];
private _statics = _objects select {
	((typeOf _x) isKindOf "StaticWeapon") && 
	!(_x in _garisonedStatics)
};
diag_log format["_statics = %1",_statics];
{
	_staticWeapons pushBack format['     ["%1",%2,%3]',typeOf _x,(getPosATL _x) vectorDiff CENTER,getDir _x];
} forEach _statics;

private _infantry = _units select {
	!(surfaceIsWater (getPos _x)) && 
	!(_x in _garisonedUnits)
};
diag_log format["_garisonedUnits = %1",_garisonedUnits];
diag_log format["_infantry = %1",_infantry];
_infantryGroups = [];
{
	_infantryGroups pushBack format['     [%1,%2,%3,"%4",%5,%6]',(getPosATL _x) vectorDiff CENTER,blck_minAI,blck_maxAI,blck_MissionDifficulty,minPatrolRadius,maxPatrolRadius];
} forEach  _units;

private _scuba = _units select {
	(surfaceIsWater (getPos _x)) && 
	!([_x] call blck3DEN_fnc_isInside)	
	// checck _x get3EDENAtribute "name" != "garrison";	
};
diag_log format["_scuba = %1",_scuba];
private _scubaGroups = [];
{
	_scubaGroups pushBack format['     [%1,%2,%3,"%4",%5,%6]',(getPosATL _x) vectorDiff CENTER,blck_minAI,blck_maxAI,blck_MissionDifficulty,minPatrolRadius,maxPatrolRadius];
} forEach _scuba;

private _lootContainers = [];
private _ammoBoxes = _objects select {  //  "ReammoBox_F"
	(((typeOf _x) isKindOf "ReammoBox") || ((typeOf _x) isKindOf "ReammoBox_F"))
};
diag_log format["_ammoBoxes = %1",_ammoboxes];
{
	_lootContainers pushBack format['     ["%1",%2,%3,%4,%5]',typeOf _x,(getPosATL _x) vectorDiff CENTER, '_crateLoot','_lootCounts',getDir _x];
}forEach _ammoBoxes;
private _missionCoords = [];
if (toLower(missionNamespace getVariable["blck_missionLocations","random"]) isEqualTo "fixed") then
{
	_missionCoords pushBack CENTER;
};
private _lines = [];
private _lineBreak = toString [10];

_lines pushBack "/*";
_lines pushBack "	Dynamic Mission Generated";
_lines pushBack "	Using 3DEN Plugin for blckeagls";
_lines pushBack format["	%1",['dynamic'] call blck3DEN_fnc_versionInfo];
_lines pushBack "	By Ghostrider-GRG-";
_lines pushBack "*/";
_lines pushBack "";
_lines pushBack '#include "\q\addons\custom_server\Configs\blck_defines.hpp";';
_lines pushBack '#include "\q\addons\custom_server\Missions\privateVars.sqf";';
_lines pushBack "";
_lines pushBack format["_defaultMissionLocations = %1;",_missionCoords];
_lines pushBack format["_markerType = %1",format['["%1",%2,"%3"];',_markerType,_markerSize,_markerBrush]];
_lines pushBack format['_markerColor = "%1";',_markerColor];
_lines pushBack format['_startMsg = "%1";',blck_dynamicStartMessage];
_lines pushBack format['_endMsg = "%1";',blck_dynamicEndMessage];
_lines pushBack format['_markerMissionName = "%1";',blck_dynamicmarkerMissionName];
_lines pushBack format['_crateLoot = blck_BoxLoot_%1;',blck_MissionDifficulty];
_lines pushBack format['_lootCounts = blck_lootCounts%1;',blck_MissionDifficulty];
_lines pushBack "";
_lines pushBack "_garrisonedBuildings_BuildingPosnSystem = [";
_lines pushBack (_garisonedPos joinString (format[",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_garrisonedBuilding_ATLsystem = [";
_lines pushBack (_garrisonATL joinString (format[",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_missionLandscape = [";
_lines pushback (_missionLandscape joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_simpleObjects = [";
_lines pushback (_simpleObjects joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_missionLootVehicles = [";
_lines pushBack (_missionLootVehicles joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack  "_missionPatrolVehicles = [";
_lines pushback (_missionPatrolVehicles joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_submarinePatrolParameters = [";
_lines pushback (_subPatrols joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_airPatrols = [";
_lines pushback (_airPatrols joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_missionEmplacedWeapons = [";
_lines pushback (_staticWeapons joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_missionGroups = [";
_lines pushback (_infantryGroups joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_scubaGroupParameters = [";
_lines pushback (_scubaGroups joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "_missionLootBoxes = [";
_lines pushback (_lootContainers joinString (format [",%1", _lineBreak]));
_lines pushBack "];";
_lines pushBack "";
_lines pushBack "/*";
_lines pushBack "	Use the parameters below to customize your mission - see the template or blck_configs.sqf for details about each them";
_lines pushBack "*/";
_lines pushBack format["_chanceHeliPatrol = blck_chanceHeliPatrol%1;",blck_MissionDifficulty];  
_lines pushBack format["_noChoppers = blck_noPatrolHelis%1;",blck_MissionDifficulty];
_lines pushBack format["_missionHelis = blck_patrolHelis%1;",blck_MissionDifficulty];
_lines pushBack format["_chancePara = blck_chancePara%1;",blck_MissionDifficulty]; 
_lines pushBack format["_noPara = blck_noPara%1;",blck_MissionDifficulty];  
_lines pushBack format["_paraTriggerDistance = 400;"]; 				
_lines pushBack format["_paraSkill = '%1';",blck_MissionDifficulty];  
_lines pushBack format["_chanceLoot = 0.0;"]; 
_lines pushBack format["_paraLoot = blck_BoxLoot_%1;",blck_MissionDifficulty];
_lines pushBack format["_paraLootCounts = blck_lootCounts%1;",blck_MissionDifficulty];  
_lines pushBack format['_missionLandscapeMode = "precise";'];
_linse pushBack "_useMines = blck_useMines;";  
_lines pushBack "_uniforms = blck_SkinList;";  
_lines pushBack "_headgear = blck_headgear;";  
_lines pushBack "_vests = blck_vests;";
_lines pushBack "_backpacks = blck_backpacks;";
_lines pushBack "_sideArms = blck_Pistols;";
_lines pushBack format['_spawnCratesTiming = "%1";',blck_spawnCratesTiming];
_lines pushBack format['_loadCratesTiming = "%1";',blck_loadCratesTiming];
_lines pushBack format['_endCondition = "%1";',blck_missionEndCondition];
_lines pushBack format["_minNoAI = blck_MinAI_%1;",blck_MissionDifficulty];
_lines pushBack format["_maxNoAI = blck_MaxAI_%1;",blck_MissionDifficulty];
_lines pushBack format["_noAIGroups = blck_AIGrps_%1;",blck_MissionDifficulty];
_lines pushBack format["_noVehiclePatrols = blck_SpawnVeh_%1;",blck_MissionDifficulty];
_lines pushBack format["_noEmplacedWeapons = blck_SpawnEmplaced_%1;",blck_MissionDifficulty];
_lines pushBack format["_minNoAI = blck_MinAI_%1;",blck_MissionDifficulty];  
_lines pushBack format["_maxNoAI = blck_MaxAI_%1;",blck_MissionDifficulty]; 
_lines pushBack format["_noAIGroups = blck_AIGrps_%1;",blck_MissionDifficulty];  
_lines pushBack format["_noVehiclePatrols = blck_SpawnVeh_%1;",blck_MissionDifficulty];  
_lines pushBack format["_noEmplacedWeapons = blck_SpawnEmplaced_%1;",blck_MissionDifficulty];
_lines pushBack "";
_lines pushBack '#include "\q\addons\custom_server\Compiles\Missions\GMS_fnc_missionSpawner.sqf";';

diag_log ["dynamic"] call blck3EDEN_fnc_versionInfo;
uiNameSpace setVariable ["Display3DENCopy_data", ["dynamicMission.sqf", _lines joinString _lineBreak]];
(findDisplay 313) createdisplay "Display3DENCopy";
