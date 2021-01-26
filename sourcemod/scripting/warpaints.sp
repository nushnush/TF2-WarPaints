/* Definitions
==================================================================================================== */

#pragma semicolon 1
#include <sourcemod>
#include <tf2items>
#pragma newdecls required

public const int allowedWeps[45] = { 
	37, 172, 194, 197, 199, 200, 201, 202, 
	203, 205, 206, 207, 208, 209, 210, 211,
	214, 215, 220, 221, 228, 304, 305, 308,
	312, 326, 327, 329, 351, 401, 402, 404, 
	415, 424, 425, 447, 448, 449, 740, 996, 
	997, 1104, 1151, 1153, 1178 };

int g_iMySkin[MAXPLAYERS + 1];
ConVar g_cvWear;

public Plugin myinfo =
{
	name = "[TF2] Warpaint Skins",
	author = "StrikeR14",
	description = "Apply warpaint skins!",
	version = "1.1.1",
	url = "https://steamcommunity.com/id/kenmaskimmeod/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_skin", SetSkin);
	RegConsoleCmd("sm_setskin", SetSkin);

	g_cvWear = CreateConVar("sm_warpaint_wear", "0.0", "Skin wear value", _, true, 0.0, true, 1.0); 
}

public void OnClientPutInServer(int client)
{
	g_iMySkin[client] = 0;
}

public Action SetSkin(int client, int args)
{
	if(!client)
	{
		return Plugin_Handled;
	}

	if(args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setskin <id>");
		return Plugin_Handled;
	}

	char arg[8];
	GetCmdArg(1, arg, sizeof(arg));
	int skin = StringToInt(arg);

	if(!skin)
	{
		g_iMySkin[client] = 0;
		ReplyToCommand(client, "[SM] Successfully deleted skin.");
		return Plugin_Handled;
	}

	if(!IsValidWarpaint(skin))
	{
		PrintToChat(client, "[SM] Unavailable skin id (%i).", skin);
		PrintToChat(client, "[SM] Available values: 102, 104-106, 109, 112-114, 112, 130, 139, 143, 144, 151, 160, 161, 163,");
		PrintToChat(client, "[SM] Available values: 200-215, 217, 218, 220, 221, 223-226, 228, 230, 232, 234-273, 300-310.");
		return Plugin_Handled;
	}

	g_iMySkin[client] = StringToInt(arg);
	PrintToChat(client, "[SM] Successfully applied skin. Respawn to apply it.");
	return Plugin_Handled;
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if(!g_iMySkin[client] || !FindInDef(iItemDefinitionIndex))
	{
		return Plugin_Continue;
	}

	hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	TF2Items_SetNumAttributes(hItem, 2);
	TF2Items_SetAttribute(hItem, 0, 834, view_as<float>(g_iMySkin[client]));
	TF2Items_SetAttribute(hItem, 1, 725, g_cvWear.FloatValue);	 // Factory new, minimal wear...
	TF2Items_SetFlags(hItem, OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	return Plugin_Changed;
}

bool FindInDef(const int def)
{
	for(int i = 0; i < sizeof(allowedWeps); i++)
	{
		if(allowedWeps[i] == def)
			return true;
	}

	return false;
}

bool IsValidWarpaint(const int war)
{
	return (102 <= war <= 114 && war != 103 && war != 107 && war != 108 && war != 110 && war != 111) 
	|| war == 122 || war == 130 || war == 139 || war == 143 || war == 144 || war == 151 || war == 160 || war == 161 || war == 163
	|| (200 <= war <= 283 && war != 216 && war != 219 && war != 222 && war != 227 && war != 229 && war != 231 && war != 233 && war != 274)
	|| (300 <= war <= 310);
}