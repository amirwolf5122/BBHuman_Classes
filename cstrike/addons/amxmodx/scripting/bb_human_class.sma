#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <basebuilder>

#if AMXX_VERSION_NUM < 183
    #define MAX_PLAYERS 32
#endif 

#define CLASSNAME "[ Human class ]"

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

new my_Class[MAX_PLAYERS + 1]

public plugin_init()
{
	register_plugin("human Class BaseBuilder", "1.2", "AmirWolf")
	register_clcmd("say /human", "Human_Menu")
	RegisterHam(Ham_Spawn, "player", "HookSpawn", 1)
}

public plugin_precache()
{
	// Precache models
	for (new i = 0; i < sizeof(g_eClass); i++) {
		new model[128]
		formatex(model, charsmax(model), "models/player/%s/%s.mdl", g_eClass[i][NameModel], g_eClass[i][NameModel])
		if (file_exists(model)) {
			precache_generic(model)
		} else {
			log_amx("Model ^"%s^" does not exists", model)
		}
	}
}

public client_putinserver(id){
	my_Class[id] = 0
}

public HookSpawn(id){
	if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT){
		set_Human(id, g_eClass[my_Class[id]][NameModel], g_eClass[my_Class[id]][Class_HP], sz_Gravity[my_Class[id]])
	}
}
public Human_Menu(id)
{
	if(!is_user_alive(id) || cs_get_user_team(id) != CS_TEAM_CT){
		client_print(id, print_chat, "%s You do not have access to the menu", CLASSNAME)
		return PLUGIN_HANDLED
	}

	new gText[128], iMenu = menu_create("\d[ \rBase Builder \d| \wHuman Classes \d]", "Class_Handler")
	for(new i = 0; i < sizeof(g_eClass); i++){
		formatex(gText, charsmax(gText), "\y%s \d| \wHP:%d JM:%d", g_eClass[i][Name_Class], g_eClass[i][Class_HP], floatround(Float:sz_Gravity[i] * 1.0))
		menu_additem(iMenu, gText)
	}
	menu_display(id, iMenu, 0)
	
	return PLUGIN_HANDLED
}

public Class_Handler(id, iMenu, iItem){
	if (iItem > MENU_MORE){
		if (access(id, g_eClass[iItem][FlagAdmin])){
			my_Class[id] = iItem
			if (bb_is_build_phase())
			{
				ExecuteHamB(Ham_CS_RoundRespawn, id)
				client_print(id, print_chat, "%s You Have Chosen The %s Human class", CLASSNAME, g_eClass[my_Class[id]][NameModel])
			}else client_print(id, print_chat, "%s Only at build time The class is accessible", CLASSNAME)
            
        }
		else client_print(id, print_chat, "%s You do not have access to this class", CLASSNAME)
	}
	menu_destroy(iMenu)
}

stock set_Human(id, const Human_Moded[], Human_Hp = 100,  Float:Human_Gravity = 800.0)
{
	if(id && !is_user_connected(id))
		return 0;
		
	cs_set_user_model(id, Human_Moded)		
	set_user_health(id, Human_Hp)
	set_user_gravity(id, Human_Gravity / 800.0)

	return 1;
}
