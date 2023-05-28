// Original plugin by : [SG-10]Cpt.Moore, Richard Helgeby, Kyle Sanderson, Franc1sco franug, Doshik
// Fully rebuild with code clean up, and second semi-automatic mod of glock & famas fixed

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <zombiereloaded>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

bool g_bInfAmmo[MAXPLAYERS + 1] = { false, ... };
bool g_bInfAmmoEnabled = true;

public Plugin myinfo = {
	name = "[ZR] Infinite Ammo",
	author = "BotoX + Obus + maxime1907, .Rushaway",
	description = "Give infinite ammo",
	version = "3.0",
	url = ""
};

public void OnPluginStart() {
	RegAdminCmd("sm_infammo", Command_InfAmmo, ADMFLAG_CONFIG, "sm_infammo <value>");

	HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
}

public void OnClientPutInServer(int client) {
	g_bInfAmmo[client] = false;
}

public void OnClientDisconnect(int client) {
	g_bInfAmmo[client] = false;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid", 0));

	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
		g_bInfAmmo[client] = true;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	g_bInfAmmo[client] = false;
	return Plugin_Continue;
}

public Action Command_InfAmmo(int client, int argc) {
	if (argc < 1) {
		CReplyToCommand(client, "{green}[SM] {default}Usage: sm_infammo {olive}<value>");
		return Plugin_Handled;
	}

	char sArgs[2];
	int value = -1;
	bool bValue;

	GetCmdArg(1, sArgs, sizeof(sArgs));

	bValue = sArgs[0] == '1' ? true : false;

	if (StringToIntEx(sArgs, value) == 0) {
		CReplyToCommand(client, "{green}[SM]{default} Invalid Value.");
		return Plugin_Handled;
	}

	if (bValue)
		g_bInfAmmoEnabled = true;
	else
		g_bInfAmmoEnabled = false;

	CReplyToCommand(client, "{green}[SM] {default}Succesfully %s {default}Infinite Ammo for the map.", g_bInfAmmoEnabled ? "{green}Enabled" : "{red}Disabled");
	CShowActivity2(client, "{green}[SM] {olive}", "%s {default}Infinite Ammo for the map.", g_bInfAmmoEnabled ? "{green}Enabled" : "{red}Disabled");
	LogAction(client, -1, "\"%L\" %s Infinite Ammo for the map.", client, g_bInfAmmoEnabled ? "Enabled" : "Disabled");

	return Plugin_Handled;
}

public void Event_WeaponFire(Handle hEvent, char[] name, bool dontBroadcast) {
	if (!g_bInfAmmoEnabled)
		return;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (ZR_IsClientZombie(client) || !IsPlayerAlive(client))
		return;

	if (!g_bInfAmmo[client])
		return;

	int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", 0);
	if (IsValidEntity(weapon)) {
		if (weapon == GetPlayerWeaponSlot(client, 0) || weapon == GetPlayerWeaponSlot(client, 1)) {
			if (GetEntProp(weapon, Prop_Send, "m_iState", 4, 0) == 2 && GetEntProp(weapon, Prop_Send, "m_iClip1", 4, 0)) {
				int  toAdd = 1;
				char weaponClassname[128];
				GetEntityClassname(weapon, weaponClassname, sizeof(weaponClassname));

				if (StrEqual(weaponClassname, "weapon_glock", true) || StrEqual(weaponClassname, "weapon_famas", true)) {
					if (GetEntProp(weapon, Prop_Send, "m_bBurstMode")) {
						switch (GetEntProp(weapon, Prop_Send, "m_iClip1")) {
							case 1: {
								toAdd = 1;
							} case 2: {
								toAdd = 2;
							} default: {
								toAdd = 3;
							}
						}
					}
				}

				SetEntProp(weapon, Prop_Send, "m_iClip1", GetEntProp(weapon, Prop_Send, "m_iClip1", 4, 0) + toAdd, 4, 0);
			}
		}
	}

	return;
}
