#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>

#if AMXX_VERSION_NUM < 183
    #define MAX_PLAYERS 32
#endif 

#define MAX_CLASS 7

enum _:Classes
{
    Name_Class[32],
    NameModel[32],
	Class_HP,
    FlagAdmin
}

new const Float:sz_Gravity[MAX_CLASS] = 
{
	750.0, //Naruto
	700.0, //Sasuke
	650.0,  //Gaara
	600.0, //Kisame
	550.0, //MyIchigo
	500.0, //Terminator
	450.0  //Goku
}

new const g_eClass[MAX_CLASS][Classes] =
{	//Name_Class //model  //Class_HP //flag
	{ "Naruto", "Naruto", 100, ADMIN_ALL},
	{ "Sasuke", "Sasuke", 130, ADMIN_ALL},
	{ "Gaara", "Gaara", 160, ADMIN_ALL},
	{ "Kisame", "Kisame", 220, ADMIN_ALL},
	{ "MyIchigo \r[VIP]", "MyIchigo", 250, ADMIN_VOTE},
	{ "Terminator \r[ADMIN]", "Terminator", 280, ADMIN_KICK},
	{ "Goku \r[ADMIN]", "Goku", 300, ADMIN_KICK}
}

new bool:use_menu[MAX_PLAYERS + 1]
new my_Class[MAX_PLAYERS + 1]

public plugin_init()
{
	register_plugin("human Class BaseBuilder", "1.0", "AmirWolf")
	register_clcmd("say /human", "Human_Menu")
	RegisterHam(Ham_Spawn, "player", "HookSpawn", 1)
}

public plugin_precache()
{
	for(new i; i < sizeof(g_eClass); i++)
	{
		new model[128]
		formatex(model, charsmax(model), "models/player/%s/%s.mdl", g_eClass[i][NameModel], g_eClass[i][NameModel])
		
		if(file_exists(model))
		{
			precache_generic(model)
		}
		else
		{
			log_amx("Model ^"%s^" does not exists", model)
		}
	}
}

public client_putinserver(id){
	my_Class[id] = 0
	use_menu[id] = false
}

public client_disconnect(id){
	use_menu[id] = false
}

public HookSpawn(id){
    if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT){
		cs_set_user_model(id, g_eClass[my_Class[id]][NameModel])
		set_user_health(id, g_eClass[my_Class[id]][Class_HP])
		set_user_gravity(id, sz_Gravity[my_Class[id]] / 800.0)
		use_menu[id] = false
	}
}
public Human_Menu(id)
{
	if(!is_user_alive(id) || cs_get_user_team(id) != CS_TEAM_CT || use_menu[id])
		client_print(id, print_chat, "You do not have access to the menu")
	else
	{
		new gText[128],iMenu = menu_create("\d[ \rBase Builder \d| \wHuman Classes \d]", "Class_Handler")
		for(new i; i < sizeof(g_eClass); i++){
			formatex(gText, charsmax(gText), "\y%s \d| \wHP:%d JM:%d", g_eClass[i][Name_Class], g_eClass[i][Class_HP], floatround(Float:sz_Gravity[i] * 1.0))
			menu_additem(iMenu, gText)
		}
		menu_display(id, iMenu, 0)
	}
	return PLUGIN_HANDLED
}

public Class_Handler(id, iMenu, iItem){
	if (iItem > MENU_MORE){
		if (access(id, g_eClass[iItem][FlagAdmin])){
			my_Class[id] = iItem
			cs_set_user_model(id, g_eClass[my_Class[id]][NameModel])
			set_user_health(id, g_eClass[my_Class[id]][Class_HP])
			set_user_gravity(id, sz_Gravity[my_Class[id]] / 800.0)
			use_menu[id] = true
			client_print(id, print_chat, "[ Human class ] You Have Chosen The %s Human class", g_eClass[my_Class[id]][NameModel])
            
        }
		else client_print(id, print_chat, "[ Human class ] You do not have access to this class")
	}
	menu_destroy(iMenu)
} 