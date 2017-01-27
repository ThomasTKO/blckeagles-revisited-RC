/*
	Author: Ghostrider-DbD-
	Inspiration: WAI / A3EAI / VEMF / IgiLoad / SDROP
	License: Attribution-NonCommercial-ShareAlike 4.0 International
	call with
	[
		_pos,
		_numAI,
		_skillAI,
		_chanceLoot,
		_loogCounts,
		_weapons,
		_uniforms,
		_headgear,
		_patrol
	] call blck_spawnReinforcements
	
	Last Modified 1/23/17
*/

params["_pos","_numAI","_skillAI","_chanceLoot","_lootCounts","_weapons","_uniforms","_headgear","_patrol"]; 

diag_log format["_fnc_callInReinforcements:: Called with parameters _pos %1 _numAI %2 _skillAI %3 _chanceLoot %4",_pos,_numAI,_skillAI,_chanceLoot];

private["_chopperType","_chopperTypeArmed","_spawnPos","_spawnVector","_spawnDistance"];


// spawn an unarmed heli

_chopperType = selectRandom blck_AIHelis; //  ["B_Heli_Transport_03_unarmed_EPOCH","O_Heli_Light_02_unarmed_EPOCH","I_Heli_Transport_02_EPOCH"];

diag_log format["_fnc_callInReinforcements:: _chopperType selected = %1",_chopperType];

_spawnVector = round(random(360));
_spawnDistance = 20; //00; // + floor(random(1500)); // We need the heli to be on-site quickly to minimize the chance that a small mission has been completed before the paratroops are deployed and added to the list of live AI for the mission
_dropLoot = (random(1) < _chanceLoot);

// Use the new functionality of getPos
//  https://community.bistudio.com/wiki/getPos
_spawnPos = _pos; // getPos [_spawnDistance,_spawnVector];

diag_log format["_fnc_callInReinforcements:: vector was %1 with distance %2 yielding a spawn position of %3 at distance from _pos of %4",_spawnVector,_spawnDistance,_spawnPos, (_pos distance2d _spawnPos)];

private["_supplyHeli"];
//create helicopter and spawn it
_supplyHeli = createVehicle [_chopperType, _spawnPos, [], 90, "FLY"];
_supplyHeli setDir (_spawnVector -180);
_supplyHeli setFuel 1;
_supplyHeli engineOn true;
_supplyHeli flyInHeight 250;
_supplyHeli setVehicleLock "LOCKEDPLAYER";
_supplyHeli addEventHandler ["GetOut",{(_this select 0) setFuel 0;(_this select 0) setDamage 1;}];
_supplyHeli addEventHandler ["GetIn",{(_this select 0) setFuel 0;(_this select 0) setDamage 1;}];

[_supplyHeli] call blck_fnc_protectVehicle;
//[_supplyHeli] call blck_fnc_emptyObject;
//[_supplyHeli] call EPOCH_server_setVToken;;

private["_grpPilot","_unitPilot"];
// add pilot to helicopter	//add pilot (single group) to supply helicopter
_grpPilot = createGroup blck_AI_Side;
_grpPilot setBehaviour "CARELESS";
_grpPilot setCombatMode "RED";
_grpPilot setSpeedMode "FULL";
_grpPilot allowFleeing 0;
_grpPilot setVariable ["parameters",[_supplyHeli,_numAI,_skillAI,_weapons,_uniforms,_headgear,_dropLoot,_lootCounts,_patrol]];

// create a group for our paratroops
private["_paraGroup"];
_paraGroup = createGroup blck_AI_Side;  // ;  Group changed for Exile for which player is RESISTANCE.	
_supplyHeli setVariable["paraGroup",_paraGroup];
_paraGroup setcombatmode blck_combatMode;
_paraGroup allowfleeing 0;
_paraGroup setspeedmode "FULL";
_paraGroup setFormation blck_groupFormation; 
_paraGroup setVariable ["blck_group",true,true];

_unitPilot = _grpPilot createUnit ["I_helipilot_F", getPos _supplyHeli, [], 0, "FORM"];
_unitPilot setSkill 1;
_unitPilot assignAsDriver _supplyHeli;
_unitPilot moveInDriver _supplyHeli;
_grpPilot selectLeader _unitPilot;
_grpPilot setVariable["paraGroup",_paraGroup];

_statementSendHeliHome = "(group this) spawn blck_fnc_sendHeliHome; diag_log 'sending heli home';";
_statementDropParatroops = "(group this) spawn blck_fnc_spawnParaUnits; diag_log 'spawning para units';";
_statementDropLootCrate = "(group this) spawn blck_fnc_spawnParaCrate; diag_log 'spawning para crate';";

//set waypoint for helicopter
private["_wpDestination"];
[_grpPilot, 0] setWPPos _pos; 
[_grpPilot, 0] setWaypointType "MOVE";
[_grpPilot, 0] setWaypointSpeed "FULL";
[_grpPilot, 0] setWaypointBehaviour "CARELESS";
[_grpPilot, 0] setWaypointCompletionRadius 100;
//[_grpPilot, 0] setWaypointStatements ["true",_statementDropParatroops];
[_grpPilot,0] setWaypointTimeout [0.5,0.5,0.5];
_grpPilot setCurrentWaypoint [_grpPilot,0];

_waypoint = _grpPilot addWaypoint [_pos,0];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointTimeout [3,6,9];
_waypoint setWaypointCompletionRadius 150;
//_waypoint setWaypointStatements ["true",_statementDropLootCrate];
_waypoint setWaypointCombatMode _combatMode;
_waypoint setWaypointBehaviour _behavior;
_waypoint setWaypointSpeed "LIMITED";

_waypoint = _grpPilot addWaypoint [_pos,0];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointTimeout [3,6,9];
_waypoint setWaypointCompletionRadius 150;
//_waypoint setWaypointStatements ["true",_statementSendHeliHome];
_waypoint setWaypointCombatMode _combatMode;
_waypoint setWaypointBehaviour _behavior;
_waypoint setWaypointSpeed "LIMITED";

//Announce reinforcements are inbound to nearby players
private["_message"];
_message = "A Helicopter Carrying Reinforcements was Spotted Near You!";
[["reinforcements",_message,_pos]] call blck_fnc_messageplayers;

diag_log "_fnc_callInReinforcements:: helispawned and inbound, message sent";
_grpPilot spawn blck_fnc_spawnParaUnits;
_grpPilot spawn blck_fnc_spawnParaCrate;
uisleep 10;
_grpPilot spawn blck_fnc_sendHeliHome;
_supplyHeli setVariable["blck_DeleteAt", (diag_tickTime + 300)];
blck_missionVehicles pushback _supplyHeli;

_supplyHeli