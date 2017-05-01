
/*
	calculate a reward player for AI Kills in crypto.
	Code fragment adapted from VEMF
	call as [_unit,_killer] call blck_fnc_rewardKiller;
	Last modified 1/22/17
	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/
*/
#include "\q\addons\custom_server\Configs\blck_defines.hpp";

params["_unit","_killer","_kills"];
//diag_log format["rewardKiller::  _unit = %1 and _killer %2",_unit,_killer];

private["_modType","_reward","_maxReward","_dist","_killstreakReward","_distanceBonus","_newKillerScore","_newKillerFrags","_money"];
_modType = call blck_fnc_getModType;

//diag_log format["[blckeagles] rewardKiller:: - _modType = %1",_modType];

if (_modType isEqualTo "Epoch") then
{
	//diag_log "calculating reward for Epoch";
	
	if ( (vehicle _killer) in blck_forbidenVehicles || (currentWeapon _killer) in blck_forbidenVehicleGuns ) then 
	{
		_reward = 0;
	}
	else
	{
	// Give the player money for killing an AI
		_maxReward = 50;
		_dist = _unit distance _killer;
		_reward = 0;

		if (_dist < 50) then { _reward = _maxReward - (_maxReward / 1.25); _reward };
		if (_dist < 100) then { _reward = _maxReward - (_maxReward / 1.5); _reward };
		if (_dist < 800) then { _reward = _maxReward - (_maxReward / 2); _reward };
		if (_dist > 800) then { _reward = _maxReward - (_maxReward / 4); _reward };
		
		private _killstreakReward=+(_kills*2);
		//diag_log format["fnd_rewardKiller:: _bonus returned will be %1",_reward];
		if (blck_addAIMoney) then
		{
			[_killer,_reward + _killstreakReward] call blck_fnc_giveTakeCrypto;
		};
		if (blck_useKillScoreMessage) then
		{
			[["showScore",[_reward,"",_kills],""],[_killer]] call blck_fnc_messageplayers;
		};
	};
};

if (_modType isEqualTo "Exile") then
{
	private["_distanceBonus","_overallRespectChange","_newKillerScore","_newKillerFrags","_maxReward","_money","_message"];
	_distanceBonus = floor((_unit distance _killer)/100);

	_overallRespectChange = 50 + _distanceBonus;
	_newKillerScore = _killer getVariable ["ExileScore", 0];
	_newKillerScore = _newKillerScore + (_overallRespectChange/2);
	_killer setVariable ["ExileScore", _newKillerScore];
	format["setAccountScore:%1:%2", _newKillerScore,getPlayerUID _killer] call ExileServer_system_database_query_fireAndForget;
	_newKillerFrags = _killer getVariable ["ExileKills", 0];
	_newKillerFrags = _newKillerFrags + 1;
	_killer setVariable ["ExileKills", _newKillerFrags];
	format["addAccountKill:%1", getPlayerUID _killer] call ExileServer_system_database_query_fireAndForget;
	if (blck_addAIMoney) then
	{
		_money = _killer getVariable ["ExileMoney", 0];
		_money = _money + (_overallRespectChange/2) + (_kills * 2);
		_killer setVariable ["ExileMoney", _money];
		format["setAccountMoney:%1:%2", _money, (getPlayerUID _killer)] call ExileServer_system_database_query_fireAndForget;
	};
	//_message = ["showFragRequest",_overallRespectChange];
	_killer call ExileServer_object_player_sendStatsUpdate;
	if (blck_useKillScoreMessage) then
	{
		[["showScore",[50,_distanceBonus,_kills]], [_killer]] call blck_fnc_messageplayers;
	};
};

