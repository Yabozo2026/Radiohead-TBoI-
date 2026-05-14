Abraha = RegisterMod("Abraha",1)
local mod = Abraha

function mod:onCache(player, cacheFlag)
    if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Abraha", false) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * 1.4
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay * 1.15
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.onCache)

include("script_abraha.Abraha")