#if defined _TF2_COMP_FIXES_FIX_GHOST_CROSSBOW_BOLTS
#endinput
#endif
#define _TF2_COMP_FIXES_FIX_GHOST_CROSSBOW_BOLTS

#include "common.sp"
#include <dhooks>
#include <sdktools>

void FixGhostCrossbowBolts_Setup(Handle game_config) {
    if (g_hook_CBaseProjectile_CanCollideWithTeammates == INVALID_HANDLE) {
        g_hook_CBaseProjectile_CanCollideWithTeammates =
            CheckedDHookCreateFromConf(game_config, "CBaseProjectile::CanCollideWithTeammates");
    }

    CreateBoolConVar("sm_fix_ghost_crossbow_bolts", OnConVarChange);
}

static void OnConVarChange(ConVar cvar, const char[] before, const char[] after) {
    if (cvar.BoolValue == TruthyConVar(before)) {
        return;
    }

    DHookToggleEntityListener(ListenType_Created, OnEntityCreated, cvar.BoolValue);
}

static void OnEntityCreated(int entity, const char[] classname) {
    if (StrEqual(classname, "tf_projectile_healing_bolt")) {
        if (INVALID_HOOK_ID == DHookEntity(g_hook_CBaseProjectile_CanCollideWithTeammates, HOOK_PRE,
                                           entity, _,
                                           Hook_CBaseProjectile_CanCollideWithTeammates)) {
            SetFailState("Failed to hook CBaseProjectile::CanCollideWithTeammates");
        }
    }
}

static MRESReturn Hook_CBaseProjectile_CanCollideWithTeammates(int self, Handle ret) {
    DHookSetReturn(ret, true);
    return MRES_Supercede;
}