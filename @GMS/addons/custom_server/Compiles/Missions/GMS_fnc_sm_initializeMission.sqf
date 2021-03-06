/*
	by Ghostrider [GRG]

	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/	
*/
#include "\q\addons\custom_server\Configs\blck_defines.hpp";
params["_mission"];
// Spawn landscape
// params["_objects"];
if (isNil "_markerColor") then {_markerColor = "ColorBlack"};
if (isNil "_markerType") then {_markerType = ["mil_box",[]]};
if (isNil "_missionLandscape") then {_missionLandscape = []};
if (isNil "_garrisonedBuilding_ASLsystem") then {
	//diag_log "_fnc_sm_initializeMission: _garrisonedBuilding_ASLsystem set to []";
	_garrisonedBuilding_ASLsystem = [];
	};
if (isNil "_garrisonedBuildings_BuildingPosnSystem") then {
	//diag_log "_fnc_sm_initializeMission: _garrisonedBuildings_BuildingPosnSystem set to []";
	_garrisonedBuildings_BuildingPosnSystem = [];
	};
if (isNil "_airPatrols") then {_airPatrols = []};
if (isNil "_aiGroupParameters") then {_aiGroupParameters = []};
if (isNil "_missionEmplacedWeapons") then {_missionEmplacedWeapons = []};
if (isNil "_vehiclePatrolParameters") then {_vehiclePatrolParameters = []};
if (isNil "_missionLootVehicles") then {_missionLootVehicles = []};
if (isNil "_crateMoney") then {_crateMoney = 0};
_markerClass = format["static%1",floor(random(1000000))];
_blck_localMissionMarker = [_markerClass,_missionCenter,"","",_markerColor,_markerType];
if (blck_labelMapMarkers select 0) then
{
	_blck_localMissionMarker set [2, _markerMissionName];
};
if !(blck_preciseMapMarkers) then
{
	_blck_localMissionMarker set [1,[_missionCenter,75] call blck_fnc_randomPosition];
};
_blck_localMissionMarker set [3,blck_labelMapMarkers select 1];  // Use an arrow labeled with the mission name?
[_blck_localMissionMarker] call blck_fnc_spawnMarker;

[_missionLandscape] call blck_fnc_sm_spawnObjects;
{
	[blck_sm_Aircraft,_x] call blck_fnc_sm_AddGroupToArray; 
	
}forEach _airPatrols;
//uiSleep 1;

{
	[blck_sm_Infantry,_x] call blck_fnc_sm_AddGroupToArray;
}forEach _aiGroupParameters;

{
	[blck_sm_Emplaced,_x] call blck_fnc_sm_AddGroupToArray;
}forEach _missionEmplacedWeapons;

{
	[blck_sm_Vehicles,_x] call blck_fnc_sm_AddGroupToArray;
}forEach _vehiclePatrolParameters;

uiSleep 30;
// spawn loot chests
[_missionLootBoxes,_missionCenter,_crateMoney] call blck_fnc_sm_spawnLootContainers;
[_missionLootVehicles,_missionCenter,_crateMoney] call blck_fnc_sm_spawnLootContainers;
[format["Static Mission Spawner: Mission %1 spawned",_mission]] call blck_fnc_log;

