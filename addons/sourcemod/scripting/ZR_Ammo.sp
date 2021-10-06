#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <regex>
#include <zombiereloaded>

#pragma semicolon 1
#pragma newdecls required

// Handle CTrie;
// int CTeamColors[1][3];
// bool infiniteammo[MAXPLAYERS+1];

bool CSkipList[MAXPLAYERS+1] = { false, ... };

int activeOffset = -1;

int clip1Offset = -1;
int clip2Offset = -1;
int secAmmoTypeOffset = -1;
int priAmmoTypeOffset = -1;

char sWeapon[32];

public Plugin myinfo =
{
	name = "[ZR] Infinite Ammo",
	author = "[SG-10]Cpt.Moore, Richard Helgeby, Kyle Sanderson, Franc1sco franug, Doshik",
	description = "Sets 200 bullets to the active weapon at a certain interval",
	version = "2.5",
	url = "http://jupiter.swissquake.ch/zombie/page"
};

public void OnPluginStart()
{
	HookEvent("player_connect_client", Event_PlayerConnect, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("weapon_fire", EventWeaponFire, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);

	activeOffset = FindSendPropInfo("CAI_BaseNPC", "m_hActiveWeapon");
	clip1Offset = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	clip2Offset = FindSendPropInfo("CBaseCombatWeapon", "m_iClip2");
	priAmmoTypeOffset = FindSendPropInfo("CBaseCombatWeapon", "m_iPrimaryAmmoCount");
	secAmmoTypeOffset = FindSendPropInfo("CBaseCombatWeapon", "m_iSecondaryAmmoCount");
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid", 0));
	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
	{
		CSkipList[client] = false;
	}
}

public Action EventWeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) || ZR_IsClientZombie(client))
	{
		CSkipList[client] = false;
	}
	else
	{
		GetClientWeapon(client, sWeapon, 32);
		if (StrContains(sWeapon, "knife", true) != -1)
		{
			CSkipList[client] = false;
		}
		CSkipList[client] = true;
	}
	if (CSkipList[client])
	{
		Client_ResetAmmo(client);
	}
	return Plugin_Continue;
}

public Action Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CSkipList[client] = false;
	return Plugin_Continue;
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CSkipList[client] = false;
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CSkipList[client] = false;
	return Plugin_Continue;
}

stock void Client_ResetAmmo(int client)
{
	int zomg = GetEntDataEnt2(client, activeOffset);
	if (clip1Offset != -1 && zomg != -1)
	{
		SetEntData(zomg, clip1Offset, GetEntData(zomg, clip1Offset, 4) + 1, 4, true);
	}
	if (clip2Offset != -1 && zomg != -1)
	{
		SetEntData(zomg, clip2Offset, GetEntData(zomg, clip2Offset, 4) + 1, 4, true);
	}
	if (priAmmoTypeOffset != -1 && zomg != -1)
	{
		SetEntData(zomg, priAmmoTypeOffset, GetEntData(zomg, priAmmoTypeOffset, 4) + 1, 4, true);
	}
	if (secAmmoTypeOffset != -1 && zomg != -1)
	{
		SetEntData(zomg, secAmmoTypeOffset, GetEntData(zomg, secAmmoTypeOffset, 4) + 1, 4, true);
	}
}
