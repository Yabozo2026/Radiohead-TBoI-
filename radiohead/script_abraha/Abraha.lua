local mod = Abraha
local game = Game()
local Abraha = {}

local chud = Isaac.GetPlayerTypeByName("Abraha", false)
local CDBurner = Isaac.GetItemIdByName("CD Burner")
local Fweedom = Isaac.GetItemIdByName("Freedom")
local add2Curse = {
    {itemID = CollectibleType.COLLECTIBLE_BRIMSTONE, Weight = 0.1},
}
local add2Tre = {
    {itemID = CollectibleType.COLLECTIBLE_BIRTHRIGHT, Weight = 0.2}
}



function Abraha:AbrahaPostTearAte(tear)
    local player = tear.SpawnerEntity:ToPlayer()
    if not player or player:GetPlayerType() ~= chud then return end
        local data = tear:GetData()
        if data.AhPreviousPosition == nil then
            data.AhPreviousPosition = tear.Position
            data.AhTearDmg = tear.CollisionDamage
            data.AhTotalDistance = 0
            data.AhScale = tear.Scale
            tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
        else
            local previousPosition = data.AhPreviousPosition
            local currentPosition = tear.Position
            data.AhTotalDistance = data.AhTotalDistance + previousPosition:Distance(currentPosition)
            data.AhPreviousPosition = currentPosition
            tear.CollisionDamage = ((1 - 0.2)^data.AhTotalDistance/40)*data.AhTearDmg
            tear.Scale = ((1 + 0.33)^data.AhTotalDistance/40)*data.AhScale
        end
    end

function Abraha:ChargeCDBurner(player,numCharges)
    if numCharges == 0 then return end

    local max = 6
    local activeSlot
    local curCharge
    local newCharge

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
        max = max * 2
    end

    for i = 0, 2 do
		if player:GetActiveItem(i) == CDBurner then
			activeSlot = i
		end
	end

    curCharge = player:GetActiveCharge(activeSlot) + player:GetBatteryCharge(activeSlot)

    if curCharge < max then
        newCharge = curCharge + numCharges
        if newCharge > max then
            newCharge = max
        end

        player:SetActiveCharge(newCharge, activeSlot)
    end
end

function Abraha:trinketKilla(entity,collider)
    local player = collider:ToPlayer()
    local max = 6
    local activeSlot
    local curCharge

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
        max = max * 2
    end

    for i = 0, 2 do
		if player:GetActiveItem(i) == CDBurner then
			activeSlot = i
		end
	end

    curCharge = player:GetActiveCharge(activeSlot) + player:GetBatteryCharge(activeSlot)

    if not player then return end

    if player:HasCollectible(CDBurner) and entity.Variant == PickupVariant.PICKUP_TRINKET and curCharge < max then
        entity:remove()
        if entity.SubType & TrinketType.TRINKET_GOLDEN_FLAG ~= 0 then
        Abraha.ChargeCDBurner(player,1)
        else 
        Abraha.ChargeCDBurner(player,2)
        end
        return true
    end
end

function Abraha:useBurner(item, rng, player, useFlags, activeSlot)

if item ~= CDBurner then return end

if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then return end 

local pool = Isaac.GetPoolIdByName("disc")
local seed = rng:Next()
local spawnpos

spawnpos = Isaac.GetFreeNearPosition(player.Position,40)
local itemId = game:GetItemPool():GetCollectible(pool,true,seed)
local collectible = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE, itemId, spawnpos, Vector.Zero, nil):ToPickup()

end

function Abraha:freed0m(itemID, charge, firstTime, activeSlot, varData, player)
    if firstTime then
        local poo = Game():GetItemPool()
        poo:AddTemporaryCollectible(ItemPoolType.POOL_CURSE, add2Curse)
        poo:AddTemporaryCollectible(ItemPoolType.POOL_TREASURE, add2Tre)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Abraha.AbrahaPostTearAte)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Abraha.trinketKilla)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Abraha.useBurner)
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Abraha.freed0m, Fweedom)