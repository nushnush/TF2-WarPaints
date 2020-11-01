/* Definitions
==================================================================================================== */

#define DEBUG 1
#pragma semicolon 1

#include <sourcemod>
#include <tf2items>
#include <tf2idb>

#pragma newdecls required

public const int allowedWeps[45] = { 
	37, 172, 194, 197, 199, 200, 201, 202, 
	203, 205, 206, 207, 208, 209, 210, 211,
	214, 215, 220, 221, 228, 304, 305, 308,
	312, 326, 327, 329, 351, 401, 402, 404, 
	415, 424, 425, 447, 448, 449, 740, 996, 
	997, 1104, 1151, 1153, 1178 };

public const int seeds[45] = { 
	1957982540, 1958535989, 1964361378, 1960957956, 
	1963069415, 1963368244, 1957977039, 1962436329, 
	1963702304, 1959612665, 1958807602, 1962040849, 
	1963086610, 1958691273, 1959095757, 1957891924,
	1961310405, 1963241860, 1958812134, 1962151655, 
	1960343288, 1963760387, 1961287038, 1958664176,
	1962946822, 1958049238, 1963567984, 1962049287, 
	1958366383, 1959123814, 1962588393, 1961533743, 
	1959879329, 1962714475, 1958722291, 1963568438, 
	1960464579, 1963436999, 1962081013, 1958010709, 
	1960322932, 1957933246, 1958346061, 1960011363, 1968462776 };

int mySkin[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[TF2] Warpaint Skins",
	author = "StrikeR14",
	description = "",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_setskin", SetSkin);
}

public void OnClientPutInServer(int client)
{
	mySkin[client] = 0;
}

public Action SetSkin(int client, int args)
{
	if(!client)
	{
		return Plugin_Handled;
	}

	if(args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setskin <id>");
		return Plugin_Handled;
	}

	char arg[8];
	GetCmdArg(1, arg, sizeof(arg));
	int skin = StringToInt(arg);

	if(!skin)
	{
		mySkin[client] = 0;
		ReplyToCommand(client, "[SM] Successfully deleted skin.");
		return Plugin_Handled;
	}

	char quality[16], classname[16];
	TF2IDB_GetItemQualityName(skin, quality, sizeof(quality));
	TF2IDB_GetItemClass(skin, classname, sizeof(classname));

	if(strcmp(quality, "paintkitweapon") != 0 || strcmp(classname, "tool") != 0)
	{
		ReplyToCommand(client, "[SM] Invalid skin id (%i).", skin);
		return Plugin_Handled;
	}

	mySkin[client] = StringToInt(arg[2]);
	PrintToChat(client, "[SM] Successfully applied skin. Touch resupply or change class to apply it.");
	return Plugin_Handled;
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	int i = FindInDef(iItemDefinitionIndex);

	if(!mySkin[client] || i == -1)
	{
		return Plugin_Continue;
	}

	hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	TF2Items_SetNumAttributes(hItem, 3);
	TF2Items_SetAttribute(hItem, 0, 867, 1); // is skin
	TF2Items_SetAttribute(hItem, 1, 866, seeds[i]); // skin seed for weapon
	TF2Items_SetAttribute(hItem, 2, 834, mySkin[client]); // skin id
	TF2Items_SetFlags(hItem, OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	return Plugin_Changed;
}

int FindInDef(const int def)
{
	for(int i = 0; i < 45; i++)
	{
		if(allowedWeps[i] == def)
			return i;
	}

	return -1;
}