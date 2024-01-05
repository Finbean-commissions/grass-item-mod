----Welcome to the "main.lua" file! Here is where all the magic happens, everything from functions to callbacks are done here.
local json = require("json")
local mod = RegisterMod("TouchGrass", 1)
local game = Game()

if not REPENTOGON then
    function mod:PostRender()
        Isaac.RenderText("THIS MOD REQUIRES REPENTOGON,", 50, 50, 1 ,1 ,1 ,1)
        Isaac.RenderText("PLEASE INSTALL IT BY FOLLOWING THE DIRECTION AT:", 50, 60, 1 ,1 ,1 ,1)
        Isaac.RenderText("https://repentogon.com/", 50, 70, 1 ,1 ,1 ,1)
    end
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.PostRender)
end

if REPENTOGON then
    -- Variable Tables
    mod.dataToSave = {
        grassTimer = 0
    }
    mod.achievements = {
        unlockGrassItem = nil,
        unlockMaestro = nil
    }
    mod.characters = {
        Maestro = Isaac.GetPlayerTypeByName("Phillip")
    }
    mod.items = {
        GrassItem = Isaac.GetItemIdByName("Lucky!"),
        DnBRecord = Isaac.GetNullItemIdByName("D&B Record")
    }
    mod.cards = {
        records = {
            DnB = Isaac.GetCardIdByName("D&B Record")
        }
    }

    --Timer Increase
    function mod:PostPeffectUpdate(player)
        mod.dataToSave.grassTimer = mod.dataToSave.grassTimer + 1
        if mod.dataToSave.grassTimer >= 50 and mod.achievements.unlockGrassItem ~= nil then
            mod:unlock(mod.achievements.unlockGrassItem, true)
        end
    end
    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.PostPeffectUpdate)

    -- Use Card
    function mod:myFunction(card, player, useFlags)
        if card == mod.cards.records.DnB then
            if player:GetPlayerType() == mod.characters.Maestro then
                local tempEffects = player:GetEffects()
                tempEffects:AddNullEffect(mod.items.DnBRecord, true, 1)
            end
        end
    end
    mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.myFunction)

    -- Main Menu Render
    function mod:MainMenuRender()
        local pgd = Isaac.GetPersistentGameData()
        if pgd:IsChallengeCompleted(Challenge.CHALLENGE_PURIST) == true and mod.achievements.unlockMaestro ~= nil then
            mod:unlock(mod.achievements.unlockMaestro, true)
        end
    end
    mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.MainMenuRender)

    -- Unlock
    function mod:unlock(unlock, force) -- from community remix mod
        local pgd = Isaac.GetPersistentGameData()
		if not force then
			if not game:AchievementUnlocksDisallowed() then
				if not pgd:Unlocked(unlock) then
					pgd:TryUnlock(unlock)
				end
			end
		else
			pgd:TryUnlock(unlock)
		end
	end
    function mod:GetAchievements()
        mod.achievements.unlockGrassItem = Isaac.GetAchievementIdByName("unlockGrassItem")
        mod.achievements.unlockMaestro = Isaac.GetAchievementIdByName("unlockMaestro")
    end
    mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, mod.GetAchievements)

    -- Save/Load Data
    function mod:SaveDataMod()
        local jsonString = json.encode(mod.dataToSave)
        mod:SaveData(jsonString)
    end
    function mod:LoadDataMod()
        if mod:HasData() then
            local loadedSaveData = json.decode(mod:LoadData())
            mod.dataToSave.grassTimer = loadedSaveData.grassTimer
        end
    end


    function mod:preGameExit()
        mod:SaveDataMod()
    end
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.preGameExit)

    function mod:OnGameStart()
        mod:LoadDataMod()
    end
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.OnGameStart)
end