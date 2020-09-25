/**
 * ExileServer_system_trading_network_purchaseVehicleSkinRequest
 *
 * Exile Mod
 * www.exilemod.com
 * © 2015 Exile Mod Team
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
 
private ["_sessionID", "_parameters", "_vehicleNetID", "_skinTextures", "_playerObject", "_vehicleObject", "_bypass", "_salesPrice", "_vehicleCustomsMaster", "_availableSkinTexture", "_vehicleParentClass", "_skinVariations", "_playerMoney", "_skinMaterials", "_skinClassName", "_vehicleID", "_logging", "_traderLog", "_responseCode"];
_sessionID = _this select 0;
_parameters = _this select 1;
_vehicleNetID = _parameters select 0;
_skinTextures = _parameters select 1;
try 
{
	_playerObject = _sessionID call ExileServer_system_session_getPlayerObject;
	if (isNull _playerObject) then
	{
		throw 1;
	};
	if !(alive _playerObject) then
	{
		throw 2;
	};
	if(_playerObject getVariable ["ExileMutex",false]) then
	{
		throw 12;
	};
	_playerObject setVariable ["ExileMutex",true];
	_vehicleObject = objectFromNetId _vehicleNetID;
	if (isNull _vehicleObject) then
	{
		throw 6;
	};
	_bypass = false;
	_salesPrice = -1;
	_vehicleCustomsMaster = getArray(missionConfigFile >> "CfgVehicleCustomsMaster" >> "skins");
	diag_log format["ExileServer_system_trading_network_purchaseVehicleSkinRequest _skinTextures %1",_skinTextures];
	{
		_availableSkinTexture = _x select 2;
		diag_log format["ExileServer_system_trading_network_purchaseVehicleSkinRequest _availableSkinTexture %1",_availableSkinTexture];
		diag_log format["ExileServer_system_trading_network_purchaseVehicleSkinRequest (_availableSkinTexture select 0) %1 (_skinTextures select 0) %2",(_availableSkinTexture select 0),(_skinTextures select 0)];
		if ((toLower(_availableSkinTexture select 0)) isEqualTo (toLower(_skinTextures select 0))) exitWith
		{
			_bypass = true;
			_salesPrice = _x select 0;
			diag_log format["ExileServer_system_trading_network_purchaseVehicleSkinRequest _bypass %1 _salesPrice %2",_bypass,_salesPrice];
		};
	} forEach _vehicleCustomsMaster;
	_vehicleParentClass = configName (inheritsFrom (configFile >> "CfgVehicles" >> (typeOf _vehicleObject)));
	if (!(isClass (missionConfigFile >> "CfgVehicleCustoms" >> _vehicleParentClass)) && !_bypass) then
	{
		throw 7;
	};
	_skinVariations = getArray(missionConfigFile >> "CfgVehicleCustoms" >> _vehicleParentClass >> "skins");
	{
		_availableSkinTexture = _x select 3;
		if (_availableSkinTexture isEqualTo _skinTextures) exitWith
		{
			_salesPrice = _x select 1;
		};
	}
	forEach _skinVariations;
	if (_salesPrice <= 0) then
	{
		throw 4;
	};
	_playerMoney = _playerObject getVariable ["ExileMoney", 0];
	if (_playerMoney < _salesPrice) then
	{
		throw 5;
	};
	_skinMaterials = getArray(configFile >> "CfgVehicles" >> _skinClassName >> "hiddenSelectionsMaterials");
	{
		_vehicleObject setObjectTextureGlobal [_forEachIndex, _skinTextures select _forEachIndex];
	}
	forEach _skinTextures;
	{
		_vehicleObject setObjectMaterial [_forEachIndex, _x];
	}
	forEach _skinMaterials;
	_vehicleID = _vehicleObject getVariable ["ExileDatabaseID", -1];
	format["updateVehicleSkin:%1:%2", _skinTextures, _vehicleID] call ExileServer_system_database_query_fireAndForget;
	_playerMoney = _playerMoney - _salesPrice;
	_playerObject setVariable ["ExileMoney", _playerMoney, true];
	format["setPlayerMoney:%1:%2", _playerMoney, _playerObject getVariable ["ExileDatabaseID", 0]] call ExileServer_system_database_query_fireAndForget;
	[_sessionID, "purchaseVehicleSkinResponse", [0, _salesPrice]] call ExileServer_system_network_send_to;
	_logging = getNumber(configFile >> "CfgSettings" >> "Logging" >> "traderLogging");
	if (_logging isEqualTo 1) then
	{
		_traderLog = format ["PLAYER: ( %1 ) %2 PURCHASED VEHICLE SKIN %3 (%4) FOR %5 POPTABS | PLAYER TOTAL MONEY: %6",getPlayerUID _playerObject,_playerObject,_skinTextures,_vehicleParentClass,_salesPrice,_playerMoney];
		"extDB3" callExtension format["1:TRADING:%1",_traderLog];
	};
}
catch 
{
	_responseCode = _exception;
	[_sessionID, "purchaseVehicleSkinResponse", [_responseCode, 0]] call ExileServer_system_network_send_to;
};
if !(isNull _playerObject) then 
{
	_playerObject setVariable ["ExileMutex", false];
};
true