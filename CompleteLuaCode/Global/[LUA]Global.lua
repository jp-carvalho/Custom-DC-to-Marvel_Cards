--Core Script originally made by 3vo of 3volutionary Gaming
--3vo's Pateron https://www.patreon.com/3vo
--Bladecom made the XML, UI, modified most of 3vo's orignal script below to fit the Cryptozoic Table, and added custom Lua scripts
--Majority of this table scripts, functions, and Assets were made Bladecom
--Bladecom's Pateron https://www.patreon.com/Bladecom
--Coiser made Lua scripts, with focus of quality of life, reporting, and DCDB Highlights
--DCDB's Pateron https://www.patreon.com/dcdeckbuilding
--Busket was here
--Marvel Reskin and PTBR translate by Oakenrill
function onLoad()
    objScripts_Score = getObjectFromGUID("0eb2fc")
    local handYposition = 4.00 -- TTS sometimes changes hand position when doing save & play.
    for i, v in pairs({"Green","White","Yellow","Red"}) do
        local ht = Player[v].getHandTransform(1)
        Player[v].setHandTransform({
            position = {ht.position.x, handYposition, ht.position.z},
            rotation = {ht.rotation.x, ht.rotation.y, ht.rotation.z},
            scale    = {ht.scale.x, ht.scale.y, ht.scale.z}
        },1)
    end
    registerZones()
    -- Sets Play Area Board status
    playBoard = getObjectFromGUID('7a5ad3')
    turnCounter = 0
    flipBossCounter = 0
	flipHostageCounter = 0
    -- Sets Table status
    sideTable = getObjectFromGUID("4418bd")
    sideTable.interactable = false
    mainTable = {"f2db8b", "2482a4", "f2265f", "7853b6"}
    mainTableSwitch = getObjectFromGUID("f2db8b")
    lockMainTable()
    tableNumber = 1
    tableSize = 1
    -- Other Table status
    mainClock = getObjectFromGUID('f8250f')
    boss1Value = 0
    boss2Value = 0
    boss3Value = 0
    boss4Value = 0
    boss5Value = 0
    dwtValue = 0
    -- UI Button Status
    refill = true
    flipBoss = true
    clearTheTable = true
    impossibleMode = false
    registerMenu()
    -- Set up for Game Buttons
    setupGameButtons()
    vpTokenBag = getObjectFromGUID("ec6362")
    -- Random Seed for math.random
    math.randomseed(os.time())
    broadcastToAll("Use Game Selection for Game Modes & Table Options. Use the Notebook for Chat Commands, Scripting Questions, How to Play, and Link to Discord.")
    -- Add Right Click Functionality To Vp Bags
    addRightClickFunctionalityToGameVpBag()
    addRightClickFunctionalityToVpBags()
	-- Add Right Click Functionality To Main Deck
	addRightClickFunctionalityToMainDeck()
    registerTables()
    playerBoardEnable()
	--updateTuckButtonVisibility()
   -- lineup initialization

    lineupSlots = {
        { slotZone = getObjectFromGUID('0c27f0') }, -- Lineup Slot 1
        { slotZone = getObjectFromGUID('f4deab') }, -- Lineup Slot 2
        { slotZone = getObjectFromGUID('f232af') }, -- Lineup Slot 3
        { slotZone = getObjectFromGUID('7e8a1c') }, -- Lineup Slot 4
        { slotZone = getObjectFromGUID('bc5125') }, -- Lineup Slot 5
    }

    eventSlots = {
        { slotZone = getObjectFromGUID('1b3c6f') }, -- Events
        { slotZone = getObjectFromGUID('231173') }, -- Event Lineup 1
        { slotZone = getObjectFromGUID('c5c2e4') }, -- Event Lineup 2
        { slotZone = getObjectFromGUID('0b4bd6') }, -- Event Lineup 3
        { slotZone = getObjectFromGUID('b9d48c') }, -- Event Lineup 4
        { slotZone = getObjectFromGUID('548ead') }, -- Event Lineup 5
    }
end
function onPlayerConnect(player)
    local color = player.color
    if autoPromotePlayer(color) then
        if player.promoted == false and player.host == false then
            function promoteCo()
                wait(4)
                player.promote()
                return 1
            end
            startLuaCoroutine(Global, "promoteCo")
        end
    end
    if isPlayerWhiteListed(color) then
        player.broadcast("\n\nWelcome [MOD] " .. player.steam_name .. "!", {1,1,1})
    end
end
function onPlayerChangeColor(player_color)
	playerBoardDisabled()
	playerBoardEnable()
end
function wait(time) --Wait delay, in seconds
    local start = os.time()
    repeat coroutine.yield(0) until os.time() > start + time
end
function waitExample(time) -- wait(time) Example in how to use it.
	local waitOne = true
	if waitOne == true then
		function oneSecondPause()
			wait(time)
			printToAll("Wait Finished")
			return 1
		end
		printToAll("I'll Print Before the wait if over 1 second")
		startLuaCoroutine(Global, "oneSecondPause")
	end
end
function updateRandomSeed() --Updates the Random Seed
    --1/10 chance to update
    local chance = math.random(1,10)
    if chance == 1 then
        math.randomseed(os.time())
    end
end
function lockMainTable() -- Makes table non-interactable
    --Loop entries in the object table setting interactable to false
    	for i=1, #mainTable, 1 do
        		obj = getObjectFromGUID(mainTable[i])
        		if obj ~= nil then
            			obj.interactable = false
        		end
    	end
end



--*****************Scripting Buttons********************--

function discardAtRandom(color)
    local handObjects = Player[color].getHandObjects()
    if #handObjects == 0 then
        printToColor("There are no cards in your hand", color, {1,1,1})
    else
        local randomCard = handObjects[math.random(#handObjects)]
        local name = Player[color].steam_name
		local master = objScripts_Score.getTable("masterCardTable")[randomCard.getName()]
        printToAll(name .. " randomly discarded " .. randomCard.getName(), {1,1,1})
        if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
			randomCard.setPosition({playerZone[color].discardH.getPosition().x,3,playerZone[color].discardH.getPosition().z})
			randomCard.setRotation(playerZone[color].playZoneRot)
		elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
			randomCard.setPosition({playerZone[color].discardV.getPosition().x,3,playerZone[color].discardV.getPosition().z})
			randomCard.setRotation(playerZone[color].playZoneRot)
		elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
			randomCard.setPosition({playerZone[color].discardSP.getPosition().x,3,playerZone[color].discardSP.getPosition().z})
			randomCard.setRotation(playerZone[color].playZoneRot)
		elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
			randomCard.setPosition({playerZone[color].discardE.getPosition().x,3,playerZone[color].discardE.getPosition().z})
			randomCard.setRotation(playerZone[color].playZoneRot)
		elseif master.isStarter==true then
			randomCard.setPosition({playerZone[color].discardS.getPosition().x,3,playerZone[color].discardS.getPosition().z})
			randomCard.setRotation(playerZone[color].playZoneRot)
		else
			randomCard.setPosition({playerZone[color].discardO.getPosition().x,3,playerZone[color].discardO.getPosition().z})
			randomCard.setRotation(playerZone[color].playZoneRot)
		end
    end
end
function shuffleDiscardAndMakePlayerDeck(color)
    local deckZoneObjects = playerZone[color].deckZone.getObjects()
    local c = 0
    for k,v in pairs(deckZoneObjects) do
        c = c+1
    end
    if c > 0 then
        printToColor("You cannot perform this action until your deck is empty.", color, {1,1,1})
    else
        function newDeckShuffleCo()
            --All Discard Zones
            local discardZoneObjectsAll = playerZone[color].discardZoneAll.getObjects()
            local yRotation = 0
            if color == "White" then
                yRotation = 180
            elseif color == "Red" then
                yRotation = 180
            elseif color == "Green" then
                yRotation = 0
            elseif color == "Yellow" then
                yRotation = 0
            end
			--[[LOOK AT]]--


            for i, object in ipairs(discardZoneObjectsAll) do
                local y=2
                if object.type  == "Deck" then
                    y=y+0.75
                    object.setPosition({playerZone[color].deckZone.getPosition().x, y, playerZone[color].deckZone.getPosition().z})
                    object.setRotation({playerZone[color].deckZone.getRotation().x, yRotation, 180})
                end
                if object.type  == "Card" then
                    --Don't Pull MCs Into New Deck If They Are Rotated And Overlap The Discard Piles
					local master = objScripts_Score.getTable("masterCardTable")[object.getName()]
					if master.isCharacter ~= true then
						y=y+0.75
						object.setPosition({playerZone[color].deckZone.getPosition().x, y, playerZone[color].deckZone.getPosition().z})
						object.setRotation({playerZone[color].deckZone.getRotation().x, yRotation, 180})
					end
                end
            end
            wait(1)
            local newDeckObjects = playerZone[color].deckZone.getObjects()
            for j, object in ipairs(newDeckObjects) do
                if object.type  == "Deck" then
                    --addRightClickFunctionalityToPlayersDeck(object)
                    for j=0, math.random(2,3) do
                        object.shuffle()
                        wait(0.2)
                    end
                end
            end

            --Check For Z15 Functionality
            if playerColorWithZ15 == color then
                --If She Is Active
                if z15IsActive == 1 then
                    if refreshingTopCard == 0 then
                        refreshingTopCard = 1
                        --Show Their Top Card In Player Hidden Zone
                        --log("Refreshing Top Card After Shuffling The Deck")
                        refreshTopCardShown(playerColorWithZ15)
                    end
                end
            end

            return 1
        end
        startLuaCoroutine(Global, "newDeckShuffleCo")
    end
end
function gainOneVp(color)
    local params = {}
    params.position = {playerZone[color].VPbag.getPosition().x, 5 , playerZone[color].VPbag.getPosition().z}
    gainToken = vpTokenBag.takeObject(params)
    local name = Player[color].steam_name
    printToAll(name .. " gained a VP Token.", {1,1,1})
end
function loseOneVp(color)
    local currentVP = playerZone[color].VPbag.getQuantity()
    local name = Player[color].steam_name
    if currentVP > 0 then
        printToAll(name .. " lost a VP Token.", {1,1,1})
        local backToVPTokenBag = {}
        backToVPTokenBag.position = {-46, 5, 0}
        removeVP = playerZone[color].VPbag.takeObject(backToVPTokenBag)
    else
        printToAll(name .. " has no VP to lose.", {1,1,1})
    end
end
function gainOneWeakness(color)
    local objectsInZone = zTable.zWeaknessStack.getObjects()
    local name = Player[color].steam_name
    --weaknessCount starts at -2 b/c there are 2x extra items here: "Custom_Tile" & "Custom_Token"
    local weaknessCount = -2
    for i, object in ipairs(objectsInZone) do
        weaknessCount = weaknessCount + 1
        if object.type  == "Deck" then
            object.takeObject({position=playerZone[color].discardO.getPosition(), rotation=playerZone[color].playZoneRot})
            printToAll(name .. " gained a Weakness.", {1,1,1})
        elseif object.type  == "Card" then
			object.setPosition(playerZone[color].discardO.getPosition())
			object.setRotation(playerZone[color].playZoneRot)
			printToAll(name .. " gained a Weakness.", {1,1,1})
		end
    end
    if weaknessCount == 0 then
        printToAll(name .. " tried to gain a Weakness, but the stack was empty.", {1,1,1})
    end
end
function onScriptingButtonUp(index, color, modifier, player)
    if color ~= "Black" and Player[color].seated then
        --Scripting Button 1 discards a random card from a player's hand
        if index == 1 then
            discardAtRandom(color)
		--Scripting Button 2 Add VP
		elseif index == 2 then
            gainOneVp(color)
        --Scripting Button 3 puts all of the cards in a player's discard zones into their empty deck zone and shuffles it
        elseif index == 3 then
            shuffleDiscardAndMakePlayerDeck(color)
		--Scripting Button 4 Move Card to Destroyed Zone
        elseif index == 4 then
            local selectedObjects = Player[color].getSelectedObjects()
            destroyObjects(selectedObjects, color)
		--Scripting Button 5 Remove a VP
		elseif index == 5 then
            loseOneVp(color)
        --Scripting Button 6 moves selected cards/decks to the Bottom of the Main Deck
        elseif index == 6 then
            local selectedObjects = Player[color].getSelectedObjects()
            putObjectsOnBottomOfMainDeck(selectedObjects, color)
        --Scripting Button 7 Is Gain A Weakness
        elseif index == 7 then
            gainOneWeakness(color)
		elseif index == 8 then --Randomly Select a Target
			local opponentTable = getSeatedPlayers()
			for i, _ in ipairs(opponentTable) do
				if opponentTable[i] == color then
					table.remove(opponentTable, i)
				end
			end
			--Make sure that there is at least one entry in the opponent table
			if #opponentTable > 0 then
				shuffle(opponentTable)
				broadcastToAll(Player[color].steam_name .. " randomly selected opponent: " .. Player[opponentTable[1]].steam_name, stringColorToRGB(opponentTable[1]))
			else
			printToAll("Unable to perform command as there are no opponents seated!", {1,1,1})
			end
        --Scripting Button 9 moves selected cards/decks to the Top of the Main Deck
        elseif index == 9 then
            local selectedObjects = Player[color].getSelectedObjects()
            for i, object in ipairs(selectedObjects) do
                if object.type  == "Deck" then
                    local deck = object
                    local cardsInDeck = deck.getObjects()
                    for j, card in ipairs(cardsInDeck) do
                        printToAll(Player[color].steam_name .. " has put " .. card.nickname .. " on top of the Main Deck.", {1,1,1})
                    end
                elseif object.type  == "Card" then
                    printToAll(Player[color].steam_name .. " has put " .. object.getName() .. " on top of the Main Deck.", {1,1,1})
                end
                --Put selected object(s) on top of the Main Deck
                object.setRotation({0,180,180})
                object.setPosition({zTable.zMainDeck.getPosition().x,5,zTable.zMainDeck.getPosition().z})
            end
		-- Scripting Button 10 Is Gain JLD Weakness
		elseif index == 10 then
			gainOneJLDWeakness(color)
        end
    end
end
function gainObject(selectedObjects, color)
    for i, object in ipairs(selectedObjects) do
        if object.type  == "Deck" then
            local deck = object
            local cardsInDeck = deck.getObjects()
            params = {}
            params.rotation = playerZone[color].playZoneRot
            params.smooth = true
            for j, card in ipairs(cardsInDeck) do
                printToAll(Player[color].steam_name .. " has " .. latestAction .. card.nickname .. ".", {1,1,1})
				local master = objScripts_Score.getTable("masterCardTable")[card.nickname]
				if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
					params.position = {playerZone[color].discardH.getPosition().x,3,playerZone[color].discardH.getPosition().z}
				elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
					params.position = {playerZone[color].discardV.getPosition().x,3,playerZone[color].discardV.getPosition().z}
				elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
					params.position = {playerZone[color].discardSP.getPosition().x,3,playerZone[color].discardSP.getPosition().z}
				elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
					params.position = {playerZone[color].discardE.getPosition().x,3,playerZone[color].discardE.getPosition().z}
				elseif master.isStarter==true then
					params.position = {playerZone[color].discardS.getPosition().x,3,playerZone[color].discardS.getPosition().z}
				else
					params.position = {playerZone[color].discardO.getPosition().x,3,playerZone[color].discardO.getPosition().z}
				end
				deck.takeObject(params)
            end
        elseif object.type  == "Card" then
            printToAll(Player[color].steam_name .. " has " .. latestAction .. object.getName() .. ".", {1,1,1})
			local master = objScripts_Score.getTable("masterCardTable")[object.getName()]
			if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
				object.setPositionSmooth({playerZone[color].discardH.getPosition().x,3,playerZone[color].discardH.getPosition().z})
				object.setRotation(playerZone[color].playZoneRot)
			elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
				object.setPositionSmooth({playerZone[color].discardV.getPosition().x,3,playerZone[color].discardV.getPosition().z})
				object.setRotation(playerZone[color].playZoneRot)
			elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
				object.setPositionSmooth({playerZone[color].discardSP.getPosition().x,3,playerZone[color].discardSP.getPosition().z})
				object.setRotation(playerZone[color].playZoneRot)
			elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
				object.setPositionSmooth({playerZone[color].discardE.getPosition().x,3,playerZone[color].discardE.getPosition().z})
				object.setRotation(playerZone[color].playZoneRot)
			elseif master.isStarter==true then
				object.setPositionSmooth({playerZone[color].discardS.getPosition().x,3,playerZone[color].discardS.getPosition().z})
				object.setRotation(playerZone[color].playZoneRot)
			else
				object.setPositionSmooth({playerZone[color].discardO.getPosition().x,3,playerZone[color].discardO.getPosition().z})
				object.setRotation(playerZone[color].playZoneRot)
			end
        end
    end
end
function putObjectsOnTopOfPlayerDeck(selectedObjects, color)
    for i, object in ipairs(selectedObjects) do
        --Set Final Destination
        params = {}
        params.position = {playerZone[color].deckZone.getPosition().x,5,playerZone[color].deckZone.getPosition().z}
        --Set Final Rotation
        if color == "White" or color == "Red" or color == "Brown" or color == "Pink" then
            params.rotation = {0,180,180}
        else
            params.rotation = {0,0,180}
        end
        if object.type  == "Deck" then
            local deck = object
            local cardsInDeck = deck.getObjects()
            for j, card in ipairs(cardsInDeck) do
                printToAll(Player[color].steam_name .. " has put " .. card.nickname .. " on the top of their deck.", {1,1,1})
                break
            end
            --Put Selected Object(s) On Top Of Their Deck
            object.takeObject(params)
        elseif object.type  == "Card" then
            printToAll(Player[color].steam_name .. " has put " .. object.getName() .. " on the top of their deck.", {1,1,1})
            --Put Selected Object(s) On Top Of Their Deck
            --object.takeObject(params)
            object.setPositionSmooth(params.position)
            object.setRotation(params.rotation)
        end
    end
end
function putObjectsOnBottomOfPlayerDeck(selectedObjects, color)
    for i, object in ipairs(selectedObjects) do
        if object.type  == "Deck" then
            local deck = object
            local cardsInDeck = deck.getObjects()
            for j, card in ipairs(cardsInDeck) do
                printToAll(Player[color].steam_name .. " has put " .. card.nickname .. " on the bottom of their deck.", {1,1,1})
            end
        elseif object.type  == "Card" then
            printToAll(Player[color].steam_name .. " has put " .. object.getName() .. " on the bottom of their deck.", {1,1,1})
        end
        --Move the Player's Deck Up In The Air
        local deckObject = playerZone[color].deckZone.getObjects()
        for i, thing in ipairs(deckObject) do
            if thing.type  == "Deck" or thing.type  == "Card" then
                thing.setPositionSmooth({playerZone[color].deckZone.getPosition().x,5,playerZone[color].deckZone.getPosition().z})
            end
        end
        --Set Selected Object(s) Rotation Properly
        if color == "White" or color == "Red" or color == "Brown" or color == "Pink" then
            object.setRotation({0,180,180})
        else
            object.setRotation({0,0,180})
        end
        --Put Selected Object(s) Underneath Their Deck
        object.setPositionSmooth({playerZone[color].deckZone.getPosition().x,1,playerZone[color].deckZone.getPosition().z})
    end
end
function putObjectsInPlayersHand(selectedObjects, color)
    for i, object in ipairs(selectedObjects) do
        if object.type  == "Deck" then
            local deck = object
            local cardsInDeck = deck.getObjects()
            for j, card in ipairs(cardsInDeck) do
                printToAll(Player[color].steam_name .. " has gained " .. card.nickname .. " and put it into their hand.", {1,1,1})
                break
            end
        elseif object.type  == "Card" then
            printToAll(Player[color].steam_name .. " has gained " .. object.getName() .. " and put it into their hand.", {1,1,1})
        end
        --Put Selected Object(s) Into Their Hand
        object.deal(1, color)
    end
end
function putObjectsOnBottomOfMainDeck(selectedObjects, color)
    rfgCard = 0
    for i, object in ipairs(selectedObjects) do
        if object.type  == "Deck" then
            local deck = object
            local cardsInDeck = deck.getObjects()
            for j, card in ipairs(cardsInDeck) do
                printToAll(Player[color].steam_name .. " has put " .. card.nickname .. " on the bottom of the Main Deck.", {1,1,1})
                if dcdbCubeGame == 1 then -- DCDeckbuilding.com Integration
					local master = objScripts_Score.getTable("masterCardTable")[card.nickname]
					if master.isBoss==true then
						rfgCard = 1 
					end
                end
            end
        elseif object.type  == "Card" then
            printToAll(Player[color].steam_name .. " has put " .. object.getName() .. " on the bottom of the Main Deck.", {1,1,1})
            if dcdbCubeGame == 1 then -- DCDeckbuilding.com Integration
				local master = objScripts_Score.getTable("masterCardTable")[object.getName()]
				if master.isBoss==true then
					rfgCard = 1
				end
            end
        end
        --Put On Bottom, Unless Boss Then RFG
        if rfgCard == 0 then
            --Move the Main Deck up into the air
            local mainDeckObjects = zTable.zMainDeck.getObjects()
            for i, mObj in ipairs(mainDeckObjects) do
                if mObj.type  == "Deck" or mObj.type  == "Card" then
                    mObj.setPosition({zTable.zMainDeck.getPosition().x,5,zTable.zMainDeck.getPosition().z})
                end
            end
            --Put selected object(s) underneath the Main Deck
            object.setRotation({0,180,180})
            object.setPositionSmooth({zTable.zMainDeck.getPosition().x,1,zTable.zMainDeck.getPosition().z})
        else
            --Put selected object(s) in RFG stack, face down
            printToAll("It was removed from the game.")
            object.setRotation({0,180,180})
            object.setPositionSmooth(destroyPileZone.rfgZone.getPosition())
        end
    end
end
function destroyObjects(selectedObjects, color)
    for i, object in ipairs(selectedObjects) do
		function destroyedObjectsFlip()
			if object.type  == "Deck" then
				local deck = object
				local cardsInDeck = deck.getObjects()
				deck.setRotationSmooth({0,180,180}) -- Funny thing, Decks always pull from Backside facing up, so instead doing an inverse pull, I just flipped the deck.
				wait(0.3)
				local params = {}
				params.rotation = destroyPileZone.dZoneRot
				for j, card in ipairs(cardsInDeck) do
					printToAll(Player[color].steam_name .. " has destroyed " .. card.nickname .. ".", {1,1,1})
					local master = objScripts_Score.getTable("masterCardTable")[card.nickname]

					-- 🔹 SPECIAL CASE: JLD Weakness returns to its stack
					if master and master.isWeakness == true and card.nickname == "JLD Weakness" then
						local params = {}
						params.position = {
							zTable.zOther2.getPosition().x,
							3,
							zTable.zOther2.getPosition().z
						}
						params.rotation = {0,180,180}
						deck.takeObject(params)

					else
						-- 🔹 ORIGINAL DESTROY LOGIC CONTINUES UNCHANGED
						local params = {}
						params.rotation = destroyPileZone.dZoneRot
						local rfgCard = 0

						if dcdbCubeGame == 1 then
							if master.isBoss==true then
								rfgCard = 1
								params.position = {
									destroyPileZone.rfgZone.getPosition().x,
									3,
									destroyPileZone.rfgZone.getPosition().z
								}
								params.rotation = zTable.zOther2.getRotation()
								deck.takeObject(params)
							end
						end

						if rfgCard == 0 then
							if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
								params.position = {destroyPileZone.hZone.getPosition().x,3,destroyPileZone.hZone.getPosition().z}
							elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
								params.position = {destroyPileZone.vZone.getPosition().x,3,destroyPileZone.vZone.getPosition().z}
							elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
								params.position = {destroyPileZone.spZone.getPosition().x,3,destroyPileZone.spZone.getPosition().z}
							elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
								params.position = {destroyPileZone.eZone.getPosition().x,3,destroyPileZone.eZone.getPosition().z}
							elseif master.isStarter==true then
								params.position = {destroyPileZone.sZone.getPosition().x,3,destroyPileZone.sZone.getPosition().z}
							elseif master.isLocation==true then
								params.position = {destroyPileZone.lZone.getPosition().x,3,destroyPileZone.lZone.getPosition().z}
							elseif master.isWeakness==true or master.isCorruption==true or master.isMWave==true then
								params.position = {destroyPileZone.wZone.getPosition().x,3,destroyPileZone.wZone.getPosition().z}
							else
								params.position = {destroyPileZone.oZone.getPosition().x,3,destroyPileZone.oZone.getPosition().z}
							end
							deck.takeObject(params)
						end
					end
				end
				return 1
			elseif object.type  == "Card" then
				wait(0.1)
				printToAll(Player[color].steam_name .. " has destroyed " .. object.getName() .. ".", {1,1,1})
				local master = objScripts_Score.getTable("masterCardTable")[object.getName()]
				-- Special Case: JLD Weakness returns to its stack instead
				if master and master.isWeakness == true and object.getName() == "JLD Weakness" then
					object.setRotationSmooth(zTable.zOther2.getRotation())
					object.setPositionSmooth({
						zTable.zOther2.getPosition().x,
						3,
						zTable.zOther2.getPosition().z
					})
					return 1
				end				
				local params = {}
				local rfgCard = 0
				if dcdbCubeGame == 1 then
					if master.isBoss == true then
						rfgCard = 1
						object.setRotation({0,180,180})
						object.setPositionSmooth({destroyPileZone.rfgZone.getPosition().x,3,destroyPileZone.rfgZone.getPosition().z})
					end
				end
				--Put On Bottom, Unless Boss Then RFG
				if rfgCard == 0 then
					if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
						params.position = {destroyPileZone.hZone.getPosition().x,3,destroyPileZone.hZone.getPosition().z}
					elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
						params.position = {destroyPileZone.vZone.getPosition().x,3,destroyPileZone.vZone.getPosition().z}
					elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
						params.position = {destroyPileZone.spZone.getPosition().x,3,destroyPileZone.spZone.getPosition().z}
					elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
						params.position = {destroyPileZone.eZone.getPosition().x,3,destroyPileZone.eZone.getPosition().z}
					elseif master.isStarter==true then
						params.position = {destroyPileZone.sZone.getPosition().x,3,destroyPileZone.sZone.getPosition().z}
					elseif master.isLocation==true then
						params.position = {destroyPileZone.lZone.getPosition().x,3,destroyPileZone.lZone.getPosition().z}
					elseif master.isWeakness==true or master.isCorruption==true or master.isMWave==true then
						params.position = {destroyPileZone.wZone.getPosition().x,3,destroyPileZone.wZone.getPosition().z}
					else
						params.position = {destroyPileZone.oZone.getPosition().x,3,destroyPileZone.oZone.getPosition().z}
					end
					object.setRotationSmooth({0,180,0})
					object.setPositionSmooth(params.position)
				else
					printToAll("It was removed from the game.")
				end
			end
			return 1
		end
		startLuaCoroutine(Global, "destroyedObjectsFlip")
    end
end
function gainOneJLDWeakness(color)
    local objectsInZone = zTable.zOther2.getObjects()
    local name = Player[color].steam_name
    -- weaknessCount starts at -2 b/c there are 2x extra items here: "Custom_Tile" & "Custom_Token"
    local weaknessCount = -2

    for i, object in ipairs(objectsInZone) do
        weaknessCount = weaknessCount + 1
        if object.type == "Deck" then
            object.takeObject({
                position = playerZone[color].discardO.getPosition(),
                rotation = playerZone[color].playZoneRot
            })
            printToAll(name .. " gained a JLD Weakness.", {1,1,1})
        elseif object.type == "Card" then
            object.setPosition(playerZone[color].discardO.getPosition())
            object.setRotation(playerZone[color].playZoneRot)
            printToAll(name .. " gained a JLD Weakness.", {1,1,1})
        end
    end

    if weaknessCount == 0 then
        printToAll(name .. " tried to gain a JLD Weakness, but the stack was empty.", {1,1,1})
    end
end

---------****************** DCDeckbuilding.com Integration
function flipNextBoss(flipBossTtsId)
    flipBossCounter = flipBossCounter + 1
end
function checkIfSeated(color)
    local players = getSeatedPlayers()
    for i, v in ipairs(players) do
        if v == color then
            return true
        end
    end
    return false
end
function onPlayerTurnStart(colorNext, colorPrev) --Move Player Area Board, and Broadcast Turn
	updateTuckButtonVisibility(colorNext)
	--Pass Play Area To The Next Seated Player
    movePlayBoard(colorNext)
    --Increment Turn Counter
    turnCounter = turnCounter + 1
    --Restart Clock If They Paused It
    if mainClock.Clock.paused == true then
        mainClock.Clock.pauseStart()
    end
    if dcdbCubeGame == 1 then
		--Move Any Tokens Off Cards In The Lineup
		moveTokensOffLineupCards()
		--Rotate MCs UpRight
		--rotateMCsUpright()
		--Rotate Ongoings UpRight
		--rotateOngoingsUpright()
	end
end
function rotateOngoingsUpright() -- Requires Rework --Busket hasnt updated for v10
--Rotate Each Players Ongoings Upright If Not Using Certain CO6 MC (i.e. BatCat, etc)
    greenPlayerMcSlot = {
        {gMcSlot=getObjectFromGUID('a14222')}, -- Player Mc Slot
        {gMcSlot=getObjectFromGUID('4cf578')}, -- Player Mc Slot
        {gMcSlot=getObjectFromGUID('31c824')}, -- Player Mc Slot
        {gMcSlot=getObjectFromGUID('4034a5')}, -- Player Mc Slot
        {gMcSlot=getObjectFromGUID('19a3cd')}, -- Player Mc Slot
    }
    yellowPlayerMcSlot = {
        {yMcSlot=getObjectFromGUID('2f7c5b')}, -- Player Mc Slot2
        {yMcSlot=getObjectFromGUID('8c3b36')}, -- Player Mc Slot3
        {yMcSlot=getObjectFromGUID('cfdb57')}, -- Player Mc Slot4
        {yMcSlot=getObjectFromGUID('db2835')}, -- Player Mc Slot5
        {yMcSlot=getObjectFromGUID('997c17')}, -- Player Mc Slot6
    }
    redPlayerMcSlot = {
        {rMcSlot=getObjectFromGUID('d30f57')}, -- Player Mc Slot2
        {rMcSlot=getObjectFromGUID('f54cc6')}, -- Player Mc Slot3
        {rMcSlot=getObjectFromGUID('ac3332')}, -- Player Mc Slot4
        {rMcSlot=getObjectFromGUID('13636c')}, -- Player Mc Slot5
        {rMcSlot=getObjectFromGUID('2327b1')}, -- Player Mc Slot6
    }
    whitePlayerMcSlot = {
        {wMcSlot=getObjectFromGUID('7e71c7')}, -- Player Mc Slot2
        {wMcSlot=getObjectFromGUID('1ac1a2')}, -- Player Mc Slot3
        {wMcSlot=getObjectFromGUID('425589')}, -- Player Mc Slot4
        {wMcSlot=getObjectFromGUID('694189')}, -- Player Mc Slot5
        {wMcSlot=getObjectFromGUID('245d97')}, -- Player Mc Slot6
    }

    greenPlayerOngoingSlot = {
        {gOngoingSlot=getObjectFromGUID('2a35be')}, -- Player Ongoing Slot1
        {gOngoingSlot=getObjectFromGUID('1ca129')}, -- Player Ongoing Slot2
        {gOngoingSlot=getObjectFromGUID('10eac3')}, -- Player Ongoing Slot3
        {gOngoingSlot=getObjectFromGUID('ccc189')}, -- Player Ongoing Slot4
        {gOngoingSlot=getObjectFromGUID('abb0f1')}, -- Player Ongoing Slot5
        {gOngoingSlot=getObjectFromGUID('063863')}, -- Player Ongoing Slot6
        {gOngoingSlot=getObjectFromGUID('a89007')}, -- Player Ongoing Slot7
        {gOngoingSlot=getObjectFromGUID('403f99')}, -- Player Ongoing Slot8
    }
    redPlayerOngoingSlot = {
        {rOngoingSlot=getObjectFromGUID('b93cd9')}, -- Player Ongoing Slot1
        {rOngoingSlot=getObjectFromGUID('b8227d')}, -- Player Ongoing Slot2
        {rOngoingSlot=getObjectFromGUID('807cd3')}, -- Player Ongoing Slot3
        {rOngoingSlot=getObjectFromGUID('d72706')}, -- Player Ongoing Slot4
        {rOngoingSlot=getObjectFromGUID('cb76cc')}, -- Player Ongoing Slot5
        {rOngoingSlot=getObjectFromGUID('750cae')}, -- Player Ongoing Slot6
        {rOngoingSlot=getObjectFromGUID('06a4d1')}, -- Player Ongoing Slot7
        {rOngoingSlot=getObjectFromGUID('30322e')}, -- Player Ongoing Slot8
    }
    yellowPlayerOngoingSlot = {
        {yOngoingSlot=getObjectFromGUID('b7e53c')}, -- Player Ongoing Slot1
        {yOngoingSlot=getObjectFromGUID('df7140')}, -- Player Ongoing Slot2
        {yOngoingSlot=getObjectFromGUID('26078f')}, -- Player Ongoing Slot3
        {yOngoingSlot=getObjectFromGUID('51e83c')}, -- Player Ongoing Slot4
        {yOngoingSlot=getObjectFromGUID('59e435')}, -- Player Ongoing Slot5
        {yOngoingSlot=getObjectFromGUID('5cc639')}, -- Player Ongoing Slot6
        {yOngoingSlot=getObjectFromGUID('0f5ada')}, -- Player Ongoing Slot7
        {yOngoingSlot=getObjectFromGUID('6f9039')}, -- Player Ongoing Slot8
    }
    whitePlayerOngoingSlot = {
        {wOngoingSlot=getObjectFromGUID('08e761')}, -- Player Ongoing Slot1
        {wOngoingSlot=getObjectFromGUID('eda755')}, -- Player Ongoing Slot2
        {wOngoingSlot=getObjectFromGUID('4bb78b')}, -- Player Ongoing Slot3
        {wOngoingSlot=getObjectFromGUID('c8a40d')}, -- Player Ongoing Slot4
        {wOngoingSlot=getObjectFromGUID('2bb0b1')}, -- Player Ongoing Slot5
        {wOngoingSlot=getObjectFromGUID('b566da')}, -- Player Ongoing Slot6
        {wOngoingSlot=getObjectFromGUID('5c127f')}, -- Player Ongoing Slot7
        {wOngoingSlot=getObjectFromGUID('e81aa4')}, -- Player Ongoing Slot8
    }

    --Check For Certain CO6 MCs For If We Can Rotate
    canRotateOngoings = true
	for i, zone in ipairs(greenPlayerMcSlot) do
		local objInZone = zone.gMcSlot.getObjects()
		checkRotationMCs(objInZone)
    end
    --Check If Can Rotate Ongoings Upright
    if canRotateOngoings  == true then
        for i, zone in ipairs(greenPlayerOngoingSlot) do
           local objInZone = zone.gOngoingSlot.getObjects()
           for j,v in pairs(objInZone) do
               if v.type  == "Card" or v.type  == "Deck" then
                   v.setRotationSmooth({0,0,0})
               end
           end
           for i, object in ipairs(objInZone) do
                if object.type  == "Deck" then
                    local deck = object
                    local cardsInDeck = deck.getObjects()
                    for j, card in ipairs(cardsInDeck) do
                        card.setRotationSmooth({0,0,0})
                    end
                end
            end
        end
    end

    canRotateOngoings = true
	for i, zone in ipairs(yellowPlayerMcSlot) do
		local objInZone = zone.yMcSlot.getObjects()
		checkRotationMCs(objInZone)
	end
    --Check If Can Rotate Ongoings Upright
    if canRotateOngoings  == true then
        for i, zone in ipairs(yellowPlayerOngoingSlot) do
           local objInZone = zone.yOngoingSlot.getObjects()
           for j,v in pairs(objInZone) do
               if v.type  == "Card" or v.type  == "Deck" then
                   v.setRotationSmooth({0,0,0})
               end
           end
           for i, object in ipairs(objInZone) do
                if object.type  == "Deck" then
                    local deck = object
                    local cardsInDeck = deck.getObjects()
                    for j, card in ipairs(cardsInDeck) do
                        card.setRotationSmooth({0,0,0})
                    end
                end
            end
        end
    end

    local canRotateOngoings = true
	for i, zone in ipairs(redPlayerMcSlot) do
		local objInZone = zone.rMcSlot.getObjects()
		checkRotationMCs(objInZone)
	end
    --Check If Can Rotate Ongoings Upright
    if canRotateOngoings  == true then
        for i, zone in ipairs(redPlayerOngoingSlot) do
           local objInZone = zone.rOngoingSlot.getObjects()
           for j,v in pairs(objInZone) do
               if v.type  == "Card" or v.type  == "Deck" then
                   v.setRotationSmooth({0,180,0})
               end
           end
           for i, object in ipairs(objInZone) do
                if object.type  == "Deck" then
                    local deck = object
                    local cardsInDeck = deck.getObjects()
                    for j, card in ipairs(cardsInDeck) do
                        card.setRotationSmooth({0,180,0})
                    end
                end
            end
        end
    end

    canRotateOngoings = true
	for i, zone in ipairs(whitePlayerMcSlot) do
		local objInZone = zone.wMcSlot.getObjects()
		checkRotationMCs(objInZone)
	end
    --Check If Can Rotate Ongoings Upright
    if canRotateOngoings  == true then
        for i, zone in ipairs(whitePlayerOngoingSlot) do
           local objInZone = zone.wOngoingSlot.getObjects()
           for j,v in pairs(objInZone) do
               if v.type  == "Card" or v.type  == "Deck" then
                   v.setRotationSmooth({0,180,0})
               end
           end
           for i, object in ipairs(objInZone) do
                if object.type  == "Deck" then
                    local deck = object
                    local cardsInDeck = deck.getObjects()
                    for j, card in ipairs(cardsInDeck) do
                        card.setRotationSmooth({0,180,0})
                    end
                end
            end
        end
    end

end
function checkRotationMCs(object) -- Requires Rework
	for j,v in pairs(object) do
		if v.type=="Card" then
			if v.getName() == "CO6 Batwoman" or v.getName() == "CO6 Black Canary" or v.getName() == "CO6 Catwoman"  then
				canRotateOngoings = false
			end
		elseif v.type=="Deck" then
			local cardsInDeck = v.getObjects()
			for j, card in ipairs(cardsInDeck) do
				if card.name == "CO6 Batwoman" or card.name == "CO6 Black Canary" or card.name == "CO6 Catwoman"  then
					canRotateOngoings = false
				end
			end
		end
	end
end
function rotateMCsUpright() -- Requires Rework -- Busket hasnt updated for v10 Table
--Rotate Each Players MCs Upright
    --Setup Player Zones, Need to Move This To Global But Throws Unknown Error
    -- ****** Watch These Variable Names, Their Is A Similar Global Variable With 's' At the End
    greenPlayerMcSlot = {
        {gMcSlot=getObjectFromGUID('a14222')}, -- Player Mc Slot2
        {gMcSlot=getObjectFromGUID('4cf578')}, -- Player Mc Slot3
        {gMcSlot=getObjectFromGUID('31c824')}, -- Player Mc Slot4
        {gMcSlot=getObjectFromGUID('4034a5')}, -- Player Mc Slot5
        {gMcSlot=getObjectFromGUID('19a3cd')}, -- Player Mc Slot6
        {gMcSlot=getObjectFromGUID('06c521')}, -- Player Under Mc Slot
    }
    yellowPlayerMcSlot = {
        {yMcSlot=getObjectFromGUID('2f7c5b')}, -- Player Mc Slot2
        {yMcSlot=getObjectFromGUID('8c3b36')}, -- Player Mc Slot3
        {yMcSlot=getObjectFromGUID('cfdb57')}, -- Player Mc Slot4
        {yMcSlot=getObjectFromGUID('db2835')}, -- Player Mc Slot5
        {yMcSlot=getObjectFromGUID('997c17')}, -- Player Mc Slot6
        {yMcSlot=getObjectFromGUID('b71a59')}, -- Player Under Mc Slot
    }
    redPlayerMcSlot = {
        {rMcSlot=getObjectFromGUID('d30f57')}, -- Player Mc Slot2
        {rMcSlot=getObjectFromGUID('f54cc6')}, -- Player Mc Slot3
        {rMcSlot=getObjectFromGUID('ac3332')}, -- Player Mc Slot4
        {rMcSlot=getObjectFromGUID('13636c')}, -- Player Mc Slot5
        {rMcSlot=getObjectFromGUID('2327b1')}, -- Player Mc Slot6
        {rMcSlot=getObjectFromGUID('84b01c')}, -- Player Under Mc Slot
    }
    whitePlayerMcSlot = {
        {wMcSlot=getObjectFromGUID('7e71c7')}, -- Player Mc Slot2
        {wMcSlot=getObjectFromGUID('1ac1a2')}, -- Player Mc Slot3
        {wMcSlot=getObjectFromGUID('425589')}, -- Player Mc Slot4
        {wMcSlot=getObjectFromGUID('694189')}, -- Player Mc Slot5
        {wMcSlot=getObjectFromGUID('245d97')}, -- Player Mc Slot6
        {wMcSlot=getObjectFromGUID('b95b40')}, -- Player Under Mc Slot
    }
	for i, zone in ipairs(greenPlayerMcSlot) do
		local objInZone = zone.gMcSlot.getObjects()
		for j,v in pairs(objInZone) do
			if v.type  == "Card" then
				--Don't Rotate Cards That Are Rotated Over MC Slots
				local master = objScripts_Score.getTable("masterCardTable")[v.getName()]
				if master.isCharacter == true then
					v.setRotationSmooth({0,0,0})
				end
			end
		end
	end
	for i, zone in ipairs(yellowPlayerMcSlot) do
		local objInZone = zone.yMcSlot.getObjects()
		for j,v in pairs(objInZone) do
			if v.type  == "Card" then
				--Don't Rotate Cards That Are Rotated Over MC Slots
				local master = objScripts_Score.getTable("masterCardTable")[v.getName()]
				if master.isCharacter == true then
					v.setRotationSmooth({0,0,0})
				end
			end
		end
	end
	for i, zone in ipairs(redPlayerMcSlot) do
		local objInZone = zone.rMcSlot.getObjects()
		for j,v in pairs(objInZone) do
			if v.type  == "Card" then
				--Don't Rotate Cards That Are Rotated Over MC Slots
				local master = objScripts_Score.getTable("masterCardTable")[v.getName()]
				if master.isCharacter == true then
					v.setRotationSmooth({0,0,0})
				end
			end
		end
	end
	for i, zone in ipairs(whitePlayerMcSlot) do
		local objInZone = zone.wMcSlot.getObjects()
		for j,v in pairs(objInZone) do
			if v.type  == "Card" then
				--Don't Rotate Cards That Are Rotated Over MC Slots
				local master = objScripts_Score.getTable("masterCardTable")[v.getName()]
				if master.isCharacter == true then
					v.setRotationSmooth({0,0,0})
				end
			end
		end
	end
end
function onPlayerTurnEnd(color) --End of Turn, Discard Cards, Refill Line-up, etc
    if turnCounter > 0 then
        checkForClockExpired(color)
    end
	if refill == true then
		if lineupEA2_Legends == true then
			findMainDeck()
		else
			if specialSetUp ~= "Multiverse" or specialSetUp ~= "Rebirth" then
				fillLineupSlots()
			else
				findMainDeck()
			end
		end
	end
	if flipBoss == true then
		findBossStack()
	end
	-- Hostage stack auto-flip (always on)
    findHostageStack()
	
    if turnCounter > 0 then
        findCardsInPlay(color)
    end
end
function checkForClockExpired(player_color)
    if dcdbCubeGame == 1 then
        if gameEnded == 0 then
            local gameTimeRemaining = mainClock.getValue()
            if gameTimeRemaining == 0 then
                gameEnded = 1
                local playerName = Player[player_color].steam_name
                print("Time Ended On " .. playerName .. "'s Turn.")
            end
        end
    end
end
function moveTokensOffLineupCards()
    --log("Moving Tokens From Lineup, Turn: " .. turnCounter)
    local positionToMove = 16
    for i, zone in ipairs(cardsInLineUpSlots) do
        local objInZone = zone.slotZone.getObjects()
        for k, thing in pairs(objInZone) do
            if thing.type  == "Tile" then
                local objectName = thing.getName()
                if objectName == "Time Travel Token" then
                    --Need To Move It
                    --log("Found In Lineup Slot:")
                    --log(thing.type )
                    --log(thing.getName())
                    shouldMove = 1
				elseif objectName  == "ARK Bribe" then
					--Need To Move It
					--log("Found In Lineup Slot:")
					--log(thing.type )
					--log(thing.getName())
                shouldMove = 1
                end
            elseif thing.type  == "Dice" then
                --Need To Move It
                --log("Found In Lineup Slot:")
                --log(thing.type )
                --log(thing.getName())
                shouldMove = 1	
            elseif thing.type  == "Card" or thing.type  == "Deck" then
                --log("Found In Lineup Slot:")
                --log(thing.type )
                --log(thing.getName())
            else
                --log("Found In Lineup Slot:")
                --log(thing.type )
                --log(thing.getName())
            end
            --Check To Move Or Not
            if shouldMove == 1 then
                --thing.setPositionSmooth({positionToMove,3,0})
                thing.setPositionSmooth({positionToMove,3,0})
                positionToMove = positionToMove + 5
                shouldMove = 0
            end
        end
    end
end
function onPlayerPing(player, position)
    --Pings Pretty Annoying For Features, Disabling Functionality For Now
        --log(player.steam_name .. " Pinged:")
        --log(position)
    --local nearestObjectsArray = findHitsInRadius(position, distantToCheckForPing)
        --log("Nearest Objects:")
        --log(nearestObjectsArray)
    --local nearestObjectGuid = nearestObjectsArray[1].hit_object.guid
        --log("Nearest Object Guid:")
        --log(nearestObjectGuid)
    --local pingedObject = getObjectFromGUID(nearestObjectGuid)
    --local pingedObjectName = pingedObject.getName()
    --if pingedObjectName ~= "" then
        --log("Nearest Object Name:")
        --log(pingedObjectName)
            --Loop To Check For What Is Pinged On
    --    checkForPingFunctionality(player, pingedObjectName)
    --else
        --log("Nothing Interesting Near The Pinged Location")
    --end
end
function checkForPingFunctionality(player, pingedObjectName)
    --log("Pinged " .. pingedObjectName)
    if pingedObjectName == "C4 The Flash" then
        useCrisisTheFlash(player.color)
    elseif pingedObjectName == "C2 Red Tornado" then
        useCrisisRedTornado(player.color)
    elseif pingedObjectName == "C2 Kyle Rayner" then
        mcKyleRaynerUse(player.color)
    elseif pingedObjectName == "RC Aquaman (Level 3)" then
        calcAqua15(player.color)
    end
end
function findHitsInRadius(pos, radius)
    local radius = (radius or 1)
    local hitList = Physics.cast({
        origin       = pos,
        direction    = {0,1,0},
        type         = 2,
        size         = {radius,radius,radius},
        max_distance = 0,
        debug        = true,
    })
    return hitList
end
function onPlayerAction(player, action, targets)
    --If DCDB Game Then Check Action Being Taken
    if dcdbCubeGame == 1 then
        --If Someone Is Shuffling A Deck Then...
        if action == Player.Action.Randomize then
            --If Player Is Using Z-15 Then...
            if playerColorWithZ15 ~= 0 then
                --If Her Ability Is Active Then...
                if z15IsActive == 1 then
                    --Check To See If Z-15 Player's Is Deck Being Shuffled, And If So Then Prevent It
                    local objectsInZone = playerDeckZones[playerColorWithZ15][1].slotZone.getObjects()
                    for j, target in ipairs(targets) do
                        if target.type  == "Deck" then
                            for i, object in ipairs(objectsInZone) do
                                if object.type  == "Deck" then
                                    --log("Comparing Two Decks:")
                                    --log(object)
                                    --log("Vs:")
                                    --log(target)
                                    if object == target then
                                        --They Are Trying To Shuffle Their Deck, Give Error Message & Don't Shuffle It
                                        --log("Z-15 Players Deck Was Prevented From Being Shuffled")
                                        printToAll(player.steam_name .. "'s Deck Was Prevented From Being Shuffled While Zatanna 15 Is Active; Toggle Her MC Ability If That Deck Needs To Be Manually Shuffled.  Please use Numpad 3 or the Vp Bag Right-Click Ability To Shuffle And Make A New Deck As Needed During The Game.")
                                        return false
                                    end
                                end
                            end
                        end
                    end
                end
            end

        end

    end

    --Default To True For All Player Actions
    return true
end
function onObjectEnterZone(zone, object)
    ----------------------------------------------------------------
    -- MAIN DECK RIGHT-CLICK HANDLING
    ----------------------------------------------------------------
    if zone == zTable.zMainDeck then
        if object.type == "Deck" or object.type == "Card" then
            Wait.frames(function()
                addRightClickFunctionalityToMainDeck()
            end, 1)
        end
    end

    ----------------------------------------------------------------
    -- EXISTING LINEUP LOGIC
    ----------------------------------------------------------------
    if object.type == "Card" then
        for i, slotToCheck in ipairs(cardsInLineUpSlots) do
            if zone == slotToCheck.slotZone then
                if slotToCheck.slotZone == cardDestination then
                    cardEnRoute = 0
                end
                addRightClickFunctionalityToLineupCards(object)
            end
        end
    end

    --If DCDB Game Then Check For Adding Card Functionality
    if dcdbCubeGame == 1 then
        if object.type  == "Card" then
            --print("A Card Entered Zone: " .. zone)

            --Check For An MC Entering An MC Slot
            for i, slotToCheck in ipairs(greenPlayerMcSlots) do
                --log(getObjectFromGUID(zone.guid))
                --log(" vs ")
                --log(slotToCheck.slotZone)
                if zone == slotToCheck.slotZone then
                    --Add Functionality To MCs
                    addScriptToMCs(object, "Green")
                end
            end
            for i, slotToCheck in ipairs(yellowPlayerMcSlots) do
                --log(getObjectFromGUID(zone.guid))
                --log(" vs ")
                --log(slotToCheck.slotZone)
                if zone == slotToCheck.slotZone then
                    --Add Functionality To MCs
                    addScriptToMCs(object, "Yellow")
                end
            end
            for i, slotToCheck in ipairs(redPlayerMcSlots) do
                --log(getObjectFromGUID(zone.guid))
                --log(" vs ")
                --log(slotToCheck.slotZone)
                if zone == slotToCheck.slotZone then
                    --Add Functionality To MCs
                    addScriptToMCs(object, "Red")
                end
            end
            for i, slotToCheck in ipairs(whitePlayerMcSlots) do
                --log(getObjectFromGUID(zone.guid))
                --log(" vs ")
                --log(slotToCheck.slotZone)
                if zone == slotToCheck.slotZone then
                    --Add Functionality To MCs
                    addScriptToMCs(object, "White")
                end
            end

            --If Player Has Z15 Then Check...
            if playerColorWithZ15 ~= 0 then
                --Check For Card Entering Deck
                if zone == playerDeckZones[playerColorWithZ15][1].slotZone then
                    if z15IsActive == 1 then
                        if refreshingTopCard == 0 then
                            --Show Their Top Card In Player Hidden Zone
                            refreshingTopCard = 1
                            --log("Refreshing Top Card After Card Entered Deck")
                            Wait.frames(function () refreshTopCardShown(playerColorWithZ15) end, shuffleDeckDuration)
                        end
                    end
                end

                --Check For Card Entering Hidden Scripting Zone
                if zone == playerHiddenInfoZones[playerColorWithZ15][1].slotZone then
                    local shouldBeRemoved = 0
                    for x, itemToDestroy in ipairs(doNotRemoveFromZone) do
                        if object == itemToDestroy then
                            shouldBeRemoved = 1
                        end
                    end
                    --Remove From List
                    for x, itemToDestroy in ipairs(doNotRemoveFromZone) do
                        if object == itemToDestroy then
                            table.remove(doNotRemoveFromZone, x)
                        end
                    end
                    if shouldBeRemoved == 0 then
                        --log("Object Placed Into Hidden Scripting Zone; Duplicating Then Deleting It")
                        printToAll("Error: Do Not Place Cards Into Special Scripting Zones")
                        object_list = {
                            object,
                        }
                        copy(object_list)
                        object.destruct()
                        paste({50,5,0})
                    else
                        --log("Object On 'Do Not Remove' List Left Zone")
                    end

                end

            end

        end
    end

end
function getSurgeDestinationSlot()
    local lastCardIndex = nil

    -- 1) Scan event lineup LEFT → RIGHT (skip slot 1)
    for i = 2, #eventSlots do
        local objs = eventSlots[i].slotZone.getObjects()
        for _, o in ipairs(objs) do
            if o.type == "Card" or o.type == "Deck" then
                lastCardIndex = i
                break
            end
        end
    end

    -- 2) If cards exist, place after last card
    if lastCardIndex then
        local nextIndex = lastCardIndex + 1
        if eventSlots[nextIndex] then
            return eventSlots[nextIndex].slotZone
        else
            print("Need space after final card in event lineup")
            return nil
        end
    end

    -- 3) Event lineup empty → use leftmost usable slot
    return eventSlots[2].slotZone
end
function surgeFromTopMainDeck(playerColor, object)
    local objs = zTable.zMainDeck.getObjects()
    local deck = nil

    for _, o in ipairs(objs) do
        if o.type == "Deck" then
            deck = o
            break
        elseif o.type == "Card" then
            deck = o
            break
        end
    end

    if not deck then
        broadcastToColor("Main Deck not found.", playerColor, {1,0,0})
        return
    end

    local card
    if deck.type == "Deck" then
        card = deck.takeObject()
    else
        card = deck
    end

    local targetZone = getSurgeDestinationSlot()
    if not targetZone then
        broadcastToColor("No valid surge slot available.", playerColor, {1,0,0})
        card.setPositionSmooth(deck.getPosition())
        return
    end

    local pos = targetZone.getPosition()
    card.setPositionSmooth(pos)
    card.setRotationSmooth({0,180,0})
end
function surgeFromBottomMainDeck(playerColor, object)
    local objs = zTable.zMainDeck.getObjects()
    local deck = nil

    for _, o in ipairs(objs) do
        if o.type == "Deck" then
            deck = o
            break
        elseif o.type == "Card" then
            deck = o
            break
        end
    end

    if not deck then
        broadcastToColor("Main Deck not found.", playerColor, {1,0,0})
        return
    end

    local card
    if deck.type == "Deck" then
        card = deck.takeObject({position = deck.getPosition(), index = deck.getQuantity() - 1})
    else
        card = deck
    end

    local targetZone = getSurgeDestinationSlot()
    if not targetZone then
        broadcastToColor("No valid surge slot available.", playerColor, {1,0,0})
        card.setPositionSmooth(deck.getPosition())
        return
    end

    local pos = targetZone.getPosition()
    card.setPositionSmooth(pos)
    card.setRotationSmooth({0,180,0})
end
function addRightClickFunctionalityToPlayersDeck(object)
    --All Deck Commands Are On Their VP Bag (So They Don't Get Lost If/When It Switches From A Deck To A Card)
end
function addRightClickFunctionalityToLineupCards(card)
    card.clearContextMenu()
    card.addContextMenuItem("Buy Card", buyTheCard)
    card.addContextMenuItem("Gain Card", gainTheCard)
    card.addContextMenuItem("Gain: Top Of Deck", gainToTopOfPlayersDeckFromLineup)
    card.addContextMenuItem("Gain: Bot Of Deck", gainToBotOfPlayersDeckFromLineup)
    card.addContextMenuItem("Gain: To Hand", gainToPlayersHandFromLineup)
    card.addContextMenuItem("-------------------------", dividerLine1)
    card.addContextMenuItem("Destroy Card", destroyTheCard)
    card.addContextMenuItem("Replace: Destroy", replaceDestroy)
    card.addContextMenuItem("Replace: On Bottom", replaceOnBottom)
end
function addRightClickFunctionalityToGeneralCards(card)
    --Don't Add General Right Click Functionality To MCs
	local master = objScripts_Score.getTable("masterCardTable")[card.getName()]
	if master.isCharacter ~= true then
		card.clearContextMenu()
		card.addContextMenuItem("Destroy Card", destroyTheCard)
		card.addContextMenuItem("Put On Top Of Deck", putOnTopOfPlayersDeck)
		card.addContextMenuItem("Put On Bot Of Deck", putOnBottomOfPlayersDeck)
	end
end
function addRightClickFunctionalityToWeaknessStack()
    local objectsInZone = zTable.zWeaknessStack.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" or object.type  == "Card" then
            object.addContextMenuItem("Gain Weakness", gainTheCard)
            object.addContextMenuItem("Gain: To Hand", gainToPlayersHandFromWeaknessStack)
		end
	end
end
function addRightClickFunctionalityToKickStack()
    local objectsInZone = zTable.zKickStack.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" or object.type  == "Card" then
            object.addContextMenuItem("Buy Kick", buyTheCard)
            --object.addContextMenuItem("Gain Kick", gainTheCard)
            --object.addContextMenuItem("Gain: Top Of Deck", gainToTopOfPlayersDeckFromKickStack)
            --object.addContextMenuItem("Gain: To Hand", gainToPlayersHandFromKickStack)
		end
	end
end
function addRightClickFunctionalityToMainDeck()
    local objectsInZone = zTable.zMainDeck.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" or object.type  == "Card" then
            object.addContextMenuItem("Gain: To Hand", gainToPlayersHandFromMainDeck)
			object.addContextMenuItem("Surge: From Top", surgeFromTopMainDeck)
			object.addContextMenuItem("Surge: From Bottom", surgeFromBottomMainDeck)
		end
	end
end
function addRightClickFunctionalityToGameVpBag()
    bag = getObjectFromGUID("ec6362")
    bag.addContextMenuItem("Gain a VP", gainVp)
    bag.addContextMenuItem("Lose a VP", loseVp)
end
function addRightClickFunctionalityToVpBags()
    local playerVpBags = {}
    --Get IDs For White, Red, Green & Yellow Vp Bags
    table.insert(playerVpBags, getObjectFromGUID("0b5d8b") )
    table.insert(playerVpBags, getObjectFromGUID("c98019") )
    table.insert(playerVpBags, getObjectFromGUID("9ada49") )
    table.insert(playerVpBags, getObjectFromGUID("568734") )

    for i, bag in ipairs(playerVpBags) do
        --Add Discard Deck Ability, Perhaps If Using Interceptor Or Teammate Crisis Red Tornado, Etc
        bag.addContextMenuItem("Make A New Deck", makeNewDeck)
        bag.addContextMenuItem("Discard Deck", discardEntireDeck)
        bag.addContextMenuItem("-------------------------", dividerLine1)
        bag.addContextMenuItem("Discard at Random", discardRandom)
        bag.addContextMenuItem("-------------------------", dividerLine2)
        bag.addContextMenuItem("Gain a VP", gainVp)
        bag.addContextMenuItem("Lose a VP", loseVp)
        bag.addContextMenuItem("-------------------------", dividerLine3)
        bag.addContextMenuItem("Gain a Weakness", gainWeakness)
		bag.addContextMenuItem("Gain JLD Weakness", gainJLDWeakness)
    end

end
function dividerLine1(player_color)
    --Dummy Function To Allow Line Breaks
end
function dividerLine2(player_color)
    --Dummy Function To Allow Line Breaks
end
function dividerLine3(player_color)
    --Dummy Function To Allow Line Breaks
end
function dividerLine4(player_color)
    --Dummy Function To Allow Line Breaks
end
function dividerLine5(player_color)
    --Dummy Function To Allow Line Breaks
end
function dividerLine6(player_color)
    --Dummy Function To Allow Line Breaks
end
function makeNewDeck(player_color)
    shuffleDiscardAndMakePlayerDeck(player_color)
end
function discardRandom(player_color)
    discardAtRandom(player_color)
end
function gainVp(player_color)
    gainOneVp(player_color)
end
function loseVp(player_color)
    loseOneVp(player_color)
end
function gainWeakness(player_color)
    gainOneWeakness(player_color)
end
function gainJLDWeakness(player_color)
    gainOneJLDWeakness(player_color)
end
function putOnBottomOfPlayersDeck(player_color)
    --printToAll("Putting A Card On Bottom Of Their Deck")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card On Bottom Of Their Deck
    putObjectsOnBottomOfPlayerDeck(selectedObjects, player_color)
end
function gainToBotOfPlayersDeckFromLineup(player_color)
    printToAll(Player[player_color].steam_name .. " Is Gaining A Card From The Lineup And Putting It On Bottom Of Their Deck")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card On Top Of Their Deck
    putObjectsOnBottomOfPlayerDeck(selectedObjects, player_color)
end
function putOnTopOfPlayersDeck(player_color)
    --printToAll("Putting A Card On Top Of Their Deck")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card On Top Of Their Deck
    putObjectsOnTopOfPlayerDeck(selectedObjects, player_color)
end
function gainToTopOfPlayersDeckFromLineup(player_color)
    printToAll(Player[player_color].steam_name .. " Is Gaining A Card From The Lineup And Putting It On Top Of Their Deck")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card On Top Of Their Deck
    putObjectsOnTopOfPlayerDeck(selectedObjects, player_color)
end
function gainToTopOfPlayersDeckFromKickStack(player_color)
    printToAll(Player[player_color].steam_name .. " Is Gaining A Kick From The Stack And Putting It On Top Of Their Deck")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card On Top Of Their Deck
    putObjectsOnTopOfPlayerDeck(selectedObjects, player_color)
end
function gainToPlayersHandFromLineup(player_color)
    printToAll(Player[player_color].steam_name .. " Is Gaining A Card From The Lineup And Putting It Into Their Hand")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card In Their Hand
    putObjectsInPlayersHand(selectedObjects, player_color)
end
function gainToPlayersHandFromWeaknessStack(player_color)
    printToAll(Player[player_color].steam_name .. " Is Gaining A Weakness And Putting It Into Their Hand")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card In Their Hand
    putObjectsInPlayersHand(selectedObjects, player_color)
end
function gainToPlayersHandFromKickStack(player_color)
    printToAll(Player[player_color].steam_name .. " Is Gaining A Kick From The Stack And Putting It Into Their Hand")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card In Their Hand
    putObjectsInPlayersHand(selectedObjects, player_color)
end
function gainToPlayersHandFromMainDeck(player_color)
    printToAll(Player[player_color].steam_name .. " Is Gaining A Card From The Main Deck And Putting It Into Their Hand")
    local selectedObjects = Player[player_color].getSelectedObjects()
    --Put Card In Their Hand
    putObjectsInPlayersHand(selectedObjects, player_color)
end
function replaceDestroy(player_color)
    --printToAll("Destroying A Card In The Lineup And Replacing It")
    local selectedObjects = Player[player_color].getSelectedObjects()
    local tempZoneObject = nil
    for i, object in ipairs(selectedObjects) do
        if object.type  == "Card" then
            tempZoneObject = object.getZones()
        end
    end

    local zoneToRefill = tempZoneObject[1]

    --Send To Destroyed Pile
    destroyObjects(selectedObjects, player_color)

    --Build Table Of Cards In Lineup & Event Zones
    refreshLineUpArray()

    --Get Main Deck As An Object
    local objectsInZone = zTable.zMainDeck.getObjects()
    for i, object in ipairs(objectsInZone) do
        if object.type  == "Deck" or object.type  == "Card" then
            --Replace Card In The Same Slot
            fillSpecificLineupSlot(object, zoneToRefill)
            break
        end
    end

end
function replaceOnBottom(player_color)
    --printToAll("Putting A Card In The Lineup On The Bottom Of The MD And Replacing It")
    local selectedObjects = Player[player_color].getSelectedObjects()
    local tempZoneObject = nil
    for i, object in ipairs(selectedObjects) do
		if object.type  == "Card" then
            tempZoneObject = object.getZones()
		end
	end

    local zoneToRefill = tempZoneObject[1]

    --Put Card On Bottom
    putObjectsOnBottomOfMainDeck(selectedObjects, player_color)

    --Build Table Of Cards In Lineup & Event Zones
    refreshLineUpArray()

    --Get Main Deck As An Object
    local objectsInZone = zTable.zMainDeck.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" or object.type  == "Card" then
            --Replace Card In The Same Slot
            fillSpecificLineupSlot(object, zoneToRefill)
			break
		end
	end

end
function buyTheCard(player_color)
    --printToAll("Bought a Card")
    latestAction = "bought "
    local selectedObjects = Player[player_color].getSelectedObjects()
    gainObject(selectedObjects, player_color)
end
function gainTheCard(player_color)
    --printToAll("Gained a Card")
    latestAction = "gained "
    local selectedObjects = Player[player_color].getSelectedObjects()
    gainObject(selectedObjects, player_color)
end
function destroyTheCard(player_color)
    --printToAll("Destroyed a Card")
    local selectedObjects = Player[player_color].getSelectedObjects()
    destroyObjects(selectedObjects, player_color)
end
function refreshTopCardShown(playerColorWithZ15)
    --Remove Previously Shown Card
    destroyAllRevealedTopCards()

    --Find Deck/Card In Z15 Players Deck Zone And Make Sure Its All One Container (So Wait Until Cards Finish Falling, Etc)
    local objectsInZone = playerDeckZones[playerColorWithZ15][1].slotZone.getObjects()
    local numOfObjectsInDeckZone = 0
    for i, object in ipairs(objectsInZone) do
        if object.type  == "Card" then
            numOfObjectsInDeckZone = numOfObjectsInDeckZone + 1
        end
        if object.type  == "Deck" then
            numOfObjectsInDeckZone = numOfObjectsInDeckZone + 1
        end
    end
    if numOfObjectsInDeckZone == 0 then
        --log("Z15 Player Has No Deck")
        --Reset Variable
        refreshingTopCard = 0
    elseif numOfObjectsInDeckZone == 1 then
        for i, object in ipairs(objectsInZone) do
            --log("Looping Through Objects In Deck Zone")
            --log(object)
            if object.type  == "Card" then
                --This Is A Single Card
                local cardToDuplicate = object.getData()
                --log("Found The Card")
                --log(cardToDuplicate)
                Wait.frames(function () finishRevealingCard(cardToDuplicate) end, z15RevealNextCardDuration)
            elseif object.type  == "Deck" then
                --Need To Loop Through The Deck
                --log("Found The Deck Object")
                --log(object.getData())
                local cardToDuplicate = nil
                for i, card_data in ipairs(object.getData().ContainedObjects) do
                    --log("Inside ivalues Loop")
                    --log(card_data)
                    --We Only Want The Top Card, So Exit Immediately After
                    cardToDuplicate = card_data
                    break
                end
                Wait.frames(function () finishRevealingCard(cardToDuplicate) end, z15RevealNextCardDuration)
            end
        end
    else
        --log("Waiting For All Objects In Zone To Become A Single Deck, Trying Again In 1 Second")
        Wait.frames(function () refreshTopCardShown(playerColorWithZ15) end, z15CheckTopCardDuration)
    end

end
function finishRevealingCard(cardToDuplicate)

    newObject = spawnObjectData( {
            data = cardToDuplicate,
            position = {playerHiddenInfoZones[playerColorWithZ15][1].xCord, playerHiddenInfoZones[playerColorWithZ15][1].yCord, playerHiddenInfoZones[playerColorWithZ15][1].zCord},
            --rotation = {0,180,0},
            rotation = {0,z15cardRotation,0},
        } )

    --Add To WhiteList So Not Removed From Zone
    table.insert(doNotRemoveFromZone, newObject)

    --Reset Variable
    refreshingTopCard = 0

end
function destroyAllRevealedTopCards()
    --Destroy All Cards In Hidden Zone So We Only Show The Top Card (Or No Card If Deck Is Empty)
    local hiddenObjects = playerHiddenInfoZones[playerColorWithZ15][1].slotZone.getObjects()
    --log("Destroying Previous Top Cards")
    for z, hiddenObject in ipairs(hiddenObjects) do
        if hiddenObject.type  == "Deck" then
            for y, hiddenCards in ipairs(hiddenObject) do
                --log("Destroying Card From Deck " .. hiddenCards.getName() )
                --log(hiddenCards)
                destroyObject( hiddenCards.takeObject() )
            end
        elseif hiddenObject.type  == "Card" then
            --log("Destroying Last Card " .. hiddenObject.getName() )
            --log(hiddenObject)
            destroyObject( hiddenObject )
        end
    end
    --log("Previously Revealed Cards Destroyed")
end
function addScriptToMCs(objInZone, playerColor)
    --Remove Any Right-Click Abilities Of MC (They May Get Them From Moving Through Other Zones Accidentally, etc)
    objInZone.clearContextMenu()
	local master = objScripts_Score.getTable("masterCardTable")[objInZone.getName()]
	--Give Aquaman 15 Ability To Calculate Power For Discard Pile
	if master.id == mcConfAqua15 then
		objInZone.addContextMenuItem("Count Power", calcAqua15)
		playerColorWithAqua15 = playerColor
	end
	--Give Kyle Rayner Ability To Reset Their Hand
	if master.id == mcKyleRayner then
		objInZone.addContextMenuItem("Check Requirement", mcKyleRaynerCheck)
		objInZone.addContextMenuItem("Reveal And Draw 5", mcKyleRaynerUse)
		playerColorWithKyleRayner = playerColor
	end
	--Give Crisis Red Tornado Ability To Discard Their Deck
	if master.id == mcCrisisRedTornado then
		objInZone.addContextMenuItem("Discard Deck", useCrisisRedTornado)
		playerColorWithCrisisRedTornado = playerColor
	end
	--Give Heroes Unite Red Tornado Ability To Get Power From 4 Colors In Discard Pile
	if master.id == mcHuRedTornado then
		objInZone.addContextMenuItem("Check Power", checkHuRedTornado)
		playerColorWithHuRedTornado = playerColor
	end
	--Give Superman 9 Ability To Flip A Card
	if master.id == mcSuperman9 then
		objInZone.addContextMenuItem("Add Card To Lineup", useSuperman9)
		playerColorWithSuperman9 = playerColor
	end
	--Give Crisis The Flash Ability To Flip A Cheaper Card
	if master.id == mcCrisisTheFlash then
		objInZone.addContextMenuItem("Add Card To Lineup", useCrisisTheFlash)
		playerColorWithCrisisTheFlash = playerColor
	end
	--Give Player Zatanna 15 Ability To See Their Top Card
	if master.id == z15 then
		--Temp Disabled While In Work
		--playerColorWithZ15 = playerColor
		--z15IsActive = 0
		--objInZone.addContextMenuItem("Show/Hide Top Card", toggleZ15showHide)
		--objInZone.addContextMenuItem("Reverse Direction", toggleZ15revealDirection)

		--If Want It To Highlight
		--z15McReference = objInZone
		--z15McReference.highlightOn({0.8,0,0})
	end
end
function mcKyleRaynerUse(player_color)
    mcKyleRaynerFunctionality(player_color, useMcAbility)
end
function mcKyleRaynerCheck(player_color)
    mcKyleRaynerFunctionality(player_color, checkMcRequirement)
end
function mcKyleRaynerFunctionality(player_color, abilityBeingUsed)
    --printToAll("Using: " .. abilityBeingUsed)
    --Check That They Are Using Their Own MC Ability
    if player_color == playerColorWithKyleRayner then
        --Get Cards In Hand To Check Types
        local handObjects = Player[player_color].getHandObjects()
        --Check For Sufficient Different Colors
            cardColorsInHandForRayner = {}
            for k, cardInHand in ipairs(handObjects) do
				local master = objScripts_Score.getTable("masterCardTable")[cardInHand.getName()]
				--Don't Check Specifically For Shapeshift Or Element Woman B/c They Have The Type, But Not The Color
				--Push Color To Array If Not Already There
				if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
					checkCardColor(cardColorsInHandForRayner, "Blue")
				elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
					checkCardColor(cardColorsInHandForRayner, "Red")
				elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
					checkCardColor(cardColorsInHandForRayner, "Orange")
				elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
					checkCardColor(cardColorsInHandForRayner, "Grey")
				elseif master.isStarter==true then
					checkCardColor(cardColorsInHandForRayner, "Yellow")
				elseif master.isLocation==true then
					checkCardColor(cardColorsInHandForRayner, "Purple")
				elseif master.isWeakness==true then
					checkCardColor(cardColorsInHandForRayner, "Green")
				else
					printToAll("Error determining color of " .. master.name)
				end
            end
            --Now We Have All The Different Colors In Their Hand, Check Array Size
            if #cardColorsInHandForRayner >= 3 then
                if abilityBeingUsed == useMcAbility then
                    --printToAll("------------------------------------")
                    printToAll(Player[player_color].steam_name .." has " .. #cardColorsInHandForRayner .." Different Color Cards in their Hand and is Using Kyle Rayner's Ability")
                    for k, cardInHand in ipairs(handObjects) do
                        printToAll("Discarding: " .. cardInHand.getName())
						local master = objScripts_Score.getTable("masterCardTable")[cardInHand.getName()]
						if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
							cardInHand.setPosition({playerZone[player_color].discardH.getPosition().x,3,playerZone[player_color].discardH.getPosition().z})
							cardInHand.setRotation(playerZone[player_color].playZoneRot)
						elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
							cardInHand.setPosition({playerZone[player_color].discardV.getPosition().x,3,playerZone[player_color].discardV.getPosition().z})
							cardInHand.setRotation(playerZone[player_color].playZoneRot)
						elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
							cardInHand.setPosition({playerZone[player_color].discardSP.getPosition().x,3,playerZone[player_color].discardSP.getPosition().z})
							cardInHand.setRotation(playerZone[player_color].playZoneRot)
						elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
							cardInHand.setPosition({playerZone[player_color].discardE.getPosition().x,3,playerZone[player_color].discardE.getPosition().z})
							cardInHand.setRotation(playerZone[player_color].playZoneRot)
						elseif master.isStarter==true then
							cardInHand.setPosition({playerZone[player_color].discardS.getPosition().x,3,playerZone[player_color].discardS.getPosition().z})
							cardInHand.setRotation(playerZone[player_color].playZoneRot)
						else
							cardInHand.setPosition({playerZone[player_color].discardO.getPosition().x,3,playerZone[player_color].discardO.getPosition().z})
							cardInHand.setRotation(playerZone[player_color].playZoneRot)
						end
                    end
                    --printToAll("------------------------------------")

                    --Get Players Deck Object (If They Have A Deck... Might Be Null)
                    local playerDeckObject = playerZone[player_color].deckZone.getObjects()

                    if playerDeckObject ~= nil then
                        local cardsToDrawForRayner = 5
                        --Try To Have Player Draw 5, But Not Shuffle To Make A Deck If Necessary
                        playerTryToDrawXcards(playerDeckObject[1], player_color, cardsToDrawForRayner)
                    else
                        printToAll(Player[player_color].steam_name .. " Needs to Draw 5 Cards")
                    end

                    --Not Going To Fully Automate This In Case They Have Trickster Or Some Reason They Don't Want To Shuffle Yet
                else
                    printToColor("------------------------------------", player_color)
                    printToColor("You Can Use Kyle Rayner's Ability", player_color)
                end
            else
                printToColor("------------------------------------", player_color)
                if #cardColorsInHandForRayner == 1 then
                    printToColor("You Have " .. #cardColorsInHandForRayner .. " Color of Card in Your Hand, and 3 or More is Required", player_color)
                else
                    printToColor("You Have " .. #cardColorsInHandForRayner .. " Different Color Cards in Your Hand, and 3 or More is Required", player_color)
                end
            end
        --end
    else
        --printToAll("------------------------------------")
        --printToAll(Player[player_color].steam_name .. " Tried To Use Kyle Rayner, But Then Remembered They Didn't Draft It")
    end
end
function checkCardType(cardColorsInDiscardForHuRedTornado, typeToFind)
    local foundType = 0
    for k, entriesInTable in ipairs(cardColorsInDiscardForHuRedTornado) do
        if entriesInTable == typeToFind then
            --printToAll("Found card type: " ..typeToFind)
            foundType = 1
            break
        end
    end
    if foundType == 0 then
        table.insert(cardColorsInDiscardForHuRedTornado, typeToFind)
    end
end
function checkCardColor(cardColorsInHandForRayner, colorToFind)
    local foundColor = 0
    for k, entriesInTable in ipairs(cardColorsInHandForRayner) do
        if entriesInTable == colorToFind then
            --printToAll("Found card color: " ..colorToFind)
            foundColor = 1
            break
        end
    end
    if foundColor == 0 then
        table.insert(cardColorsInHandForRayner, colorToFind)
    end
end
function toggleZ15revealDirection(player_color)
    if z15cardRotation == 0 then
        z15cardRotation = 180
    else
        z15cardRotation = 0
    end
    refreshTopCardShown(playerColorWithZ15)
end
function toggleZ15showHide(player_color)
    --Check If The Player Has The MC
    if player_color == playerColorWithZ15 then
        if z15IsActive == 0 then
            z15IsActive = 1
            --Highlight MC To Show 'On'
            --z15McReference.highlightOn({0,0.8,0})
            --Log In Chat
            printToAll(Player[player_color].steam_name .. " Is Viewing Their Top Card With Zatanna 15")
            --Begin Showing Card
            refreshTopCardShown(playerColorWithZ15)
        else
            z15IsActive = 0
            --Remove Previously Shown Card
            destroyAllRevealedTopCards()
            --Highlight MC To Show 'Off'
            --z15McReference.highlightOn({0.8,0,0})
            --Log In Chat
            printToAll(Player[player_color].steam_name .. "'s' Top Card Is Now Hidden")
        end
    end
end
function useSuperman9(player_color)
    --Check If Player Has MC
    if player_color == playerColorWithSuperman9 then
        --printToAll("------------------------------------")
        local cardAdded = nil
        cardAdded = addOneCardToLineup()
        if cardAdded ~= nil then
            printToAll(Player[player_color].steam_name .. " Used Superman 9, The Card Added Is: " .. cardAdded)
        else
            printToAll("To Use Superman 9, Move A Card From The Lineup To Make Room And Try Again")
        end
    else
        --printToAll("------------------------------------")
        --printToAll(Player[player_color].steam_name .. " Tried To Use Superman 9, But Then Remembered They Didn't Draft It")
    end
end
function useCrisisTheFlash(player_color)
    --Check If Player Has MC
    if player_color == playerColorWithCrisisTheFlash then
        --printToAll("------------------------------------")
        local cardAdded = nil
        cardAdded = addOneCardToLineup()
        if cardAdded ~= nil then
            printToAll(Player[player_color].steam_name .. " Used C4 Flash, The Card With Reduced Cost Is: " .. cardAdded)
        else
            printToAll("To Use C4 Flash, Move A Card From The Lineup To Make Room And Try Again")
        end
    else
        --printToAll("------------------------------------")
        --printToAll(Player[player_color].steam_name .. " Tried To Use C4 Flash, But Then Remembered They Didn't Draft It")
    end
end
function checkHuRedTornado(player_color)
    --Check All Cards In Each Of Their Discard Zones -- Check Them All In Case Their Discard Pile Is Sloppy
    --Also Check For Shapeshift And Element Woman
    cardColorsInDiscardForHuRedTornado = {}
    local playerHasSufficientTypes = 0
    local discardZoneObjectsAll = playerZone[playerColorWithHuRedTornado].discardZoneAll.getObjects()

    for z, object in ipairs(discardZoneObjectsAll) do
        if playerHasSufficientTypes == 0 then
            if object.type  == "Deck" then
                local deck = object
                local cardsInDeck = deck.getObjects()
                for j, card in ipairs(cardsInDeck) do
                    --Check For Element Woman Or Shapeshift
                    local master = objScripts_Score.getTable("masterCardTable")[card.nickname]
					--Log The Type So We Can Count Them Up
					--Check For Element Woman Or Shapeshift
					if master.id==9249 or master.id==6366 then
						--This Is Enough By Itself, No Need To Keep Looping
						playerHasSufficientTypes = 1
					elseif master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
						checkCardType(cardColorsInDiscardForHuRedTornado, "Hero")
					elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
						checkCardType(cardColorsInDiscardForHuRedTornado, "Villain")
					elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
						checkCardType(cardColorsInDiscardForHuRedTornado, "Super Power")
					elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
						checkCardType(cardColorsInDiscardForHuRedTornado, "Equipment")
					elseif master.isStarter==true then
						checkCardType(cardColorsInDiscardForHuRedTornado, "Starter")
					elseif master.isLocation==true then
						checkCardType(cardColorsInDiscardForHuRedTornado, "Location")
					elseif master.isWeakness==true then
						checkCardType(cardColorsInDiscardForHuRedTornado, "Weakness")
					else
						printToAll("Error determining card type of " .. master.name)
					end
                end
            elseif object.type  == "Card" then
                local master = objScripts_Score.getTable("masterCardTable")[object.getName()]
				--Log The Type So We Can Count Them Up
				--Check For Element Woman Or Shapeshift
				if master.id==9249 or master.id==6366 then
					--This Is Enough By Itself, No Need To Keep Looping
					playerHasSufficientTypes = 1
				elseif master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
					checkCardType(cardColorsInDiscardForHuRedTornado, "Hero")
				elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
					checkCardType(cardColorsInDiscardForHuRedTornado, "Villain")
				elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
					checkCardType(cardColorsInDiscardForHuRedTornado, "Super Power")
				elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
					checkCardType(cardColorsInDiscardForHuRedTornado, "Equipment")
				elseif master.isStarter==true then
					checkCardType(cardColorsInDiscardForHuRedTornado, "Starter")
				elseif master.isLocation==true then
					checkCardType(cardColorsInDiscardForHuRedTornado, "Location")
				elseif master.isWeakness==true then
					checkCardType(cardColorsInDiscardForHuRedTornado, "Weakness")
				else
					printToAll("Error determining card type of " .. master.name)
				end
            end
        end
    end

    local message = ""
    local playerWithMc = ""
    if Player[playerColorWithHuRedTornado].seated == true then
        --If Their Is No Seated Player Then Say Color, Otherwise Say Player Name
        playerWithMc = Player[playerColorWithHuRedTornado].steam_name
    else
        playerWithMc =  playerColorWithHuRedTornado
    end
    --Check Requirements
    if playerHasSufficientTypes == 1 then
        message = playerWithMc .. " Has 4 or More Card Types In Their Discard Pile, Netting Them 2 Power."
    else
        if #cardColorsInDiscardForHuRedTornado >= 4 then
            message = playerWithMc .. " Has 4 or More Card Types In Their Discard Pile, Netting Them 2 Power."
        else
            local cardsNeed = 4 - #cardColorsInDiscardForHuRedTornado
            message = playerWithMc .. " Has " .. #cardColorsInDiscardForHuRedTornado .. " Card Type(s) In Their Discard Pile And Need " .. cardsNeed .. " More Card Types To Activate This Ability."
        end
    end

    --Message To Everyone That They Used Their Own MC Ability
    if player_color == playerColorWithHuRedTornado then
        printToAll(message)
    else
        --Print To Color That Clicked It
        printToColor(message, player_color)
    end
end
function useCrisisRedTornado(player_color)
    --Check If Player Has MC
    if player_color == playerColorWithCrisisRedTornado then
        --printToAll("------------------------------------")
        printToAll(Player[player_color].steam_name .. " Used Crisis Red Tornado To Discard Their Deck")
        discardEntireDeck(player_color)
    else
        --printToAll("------------------------------------")
        --printToAll(Player[player_color].steam_name .. " Tried To Use Crisis Red Tornado, But Then Remembered They Didn't Draft It")
    end
end
function calcAqua15(player_color)
    --Check If Player Has MC
    local cardsInDiscardPile = 0
    local discardZoneObjectsAll = playerZone[playerColorWithAqua15].discardZoneAll.getObjects()
    for i, object in ipairs(discardZoneObjectsAll) do
        if object.type  == "Card" then
            cardsInDiscardPile = cardsInDiscardPile + 1
        end
        if object.type  == "Deck" then
            local deck = object
            local cardsInDeck = deck.getObjects()
            for j, card in ipairs(cardsInDeck) do
                cardsInDiscardPile = cardsInDiscardPile + 1
            end
        end
    end
    local aquaPower = math.floor(cardsInDiscardPile / 7) * 2
    --printToAll("------------------------------------")
    --If Their Is No Seated Player Then Say Color, Otherwise Say Player Name
    if Player[playerColorWithAqua15].seated == true then
        printToAll("Cards In " .. Player[playerColorWithAqua15].steam_name .. "'s Discard Pile: " .. cardsInDiscardPile)
    else
        printToAll("Cards In " .. playerColorWithAqua15 .. "'s Discard Pile: " .. cardsInDiscardPile)
    end
    printToAll("Power Aquaman-15 Can Provide: " .. aquaPower)
    --Tell How Many Cards Until Next Power Increase
    local cardsToNextIncrease = 8
    local modulusRemainder = 0
    repeat
        cardsToNextIncrease = cardsToNextIncrease - 1
        modulusRemainder = (cardsInDiscardPile + cardsToNextIncrease) % 7
    until( modulusRemainder == 0 )
    printToAll("Cards Needed For Additional Power: " .. cardsToNextIncrease)
end
function hideTopCardOfDeck(player_color, cardToHide)
    --Hide Card Back After Reveal Duration
    cardToHide.setRotationSmooth({cardToHide.getRotation().x,cardToHide.getRotation().y,180})
    cardToHide.setPositionSmooth({cardToHide.getPosition().x,3,cardToHide.getPosition().z})
    cardBeingRevealed[player_color] = 0
end
function discardEntireDeck(player_color)
    --No Matter Who Runs The Discard Deck Command, It Dumps Their Deck
    local selectedObjects = playerZone[player_color].deckZone.getObjects()
    --Dump Their Deck
    for i, object in ipairs(selectedObjects) do
        if object.type  == "Deck" then
            local deck = object
            local cardsInDeck = deck.getObjects()
            local params = {}
            params.rotation = playerZone[player_color].playZoneRot
            for j, card in ipairs(cardsInDeck) do
                --printToAll(Player[player_color].steam_name .. " has milled " .. card.name, {1,1,1})
                --Logged B/c Spamming Chat
                log(Player[player_color].steam_name .. " has milled " .. card.name)
                local master = objScripts_Score.getTable("masterCardTable")[card.name]
				if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
					params.position = {playerZone[player_color].discardH.getPosition().x,3,playerZone[player_color].discardH.getPosition().z}
				elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
					params.position = {playerZone[player_color].discardV.getPosition().x,3,playerZone[player_color].discardV.getPosition().z}
				elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
					params.position = {playerZone[player_color].discardSP.getPosition().x,3,playerZone[player_color].discardSP.getPosition().z}
				elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
					params.position = {playerZone[player_color].discardE.getPosition().x,3,playerZone[player_color].discardE.getPosition().z}
				elseif master.isStarter==true then
					params.position = {playerZone[player_color].discardS.getPosition().x,3,playerZone[player_color].discardS.getPosition().z}
				else
					params.position = {playerZone[player_color].discardO.getPosition().x,3,playerZone[player_color].discardO.getPosition().z}
				end
				deck.takeObject(params)
            end
        elseif object.type  == "Card" then
            local cardName = object.getName()
            --printToAll(Player[player_color].steam_name .. " has milled " .. cardName, {1,1,1})
            log(Player[player_color].steam_name .. " has milled " .. object.getName())
            local master = objScripts_Score.getTable("masterCardTable")[object.getName()]
			local params = {}
			if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
				params.position = {playerZone[player_color].discardH.getPosition().x,3,playerZone[player_color].discardH.getPosition().z}
			elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
				params.position = {playerZone[player_color].discardV.getPosition().x,3,playerZone[player_color].discardV.getPosition().z}
			elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
				params.position = {playerZone[player_color].discardSP.getPosition().x,3,playerZone[player_color].discardSP.getPosition().z}
			elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
				params.position = {playerZone[player_color].discardE.getPosition().x,3,playerZone[player_color].discardE.getPosition().z}
			elseif master.isStarter==true then
				params.position = {playerZone[player_color].discardS.getPosition().x,3,playerZone[player_color].discardS.getPosition().z}
			else
				params.position = {playerZone[player_color].discardO.getPosition().x,3,playerZone[player_color].discardO.getPosition().z}
			end
			object.setRotationSmooth({0,object.getRotation().y,0})
			object.setPositionSmooth(params.position)
        end
    end
end
function getSeatedPlayerInfo(seatColor, tempPlayerMCs)
    --Initialize Temp Object
    tempSpectatorObject = {}
    --Set Initial Values
    tempSpectatorObject["playerSeated"] = 0
    tempSpectatorObject["playerColor"] = seatColor
    --Check If There Is A Player Seated Here
    playerList = Player.getPlayers()
    for _, playerReference in ipairs(playerList) do
        if playerReference.color == seatColor then
            tempSpectatorObject["playerSeated"] = 1
            tempSpectatorObject["playerSteamName"] = playerReference.steam_name
            tempSpectatorObject["playerSteamId"] = playerReference.steam_id
        end
    end
    --Add MCs To Array
    tempSpectatorObject["playerMCs"] = tempPlayerMCs
    --Push Array To Master Object
    table.insert(masterSpectatorObject, tempSpectatorObject)
end
function putSVsInPlace()
    --Load Sv Stack New Way
    pullSvsFromContainer()
    --Pull Player Starters
    playerStartersToSet = 0
    --pullNextPlayerStarters(playerStartersToSet)
    Wait.frames(function () pullNextPlayerStarters(playerStartersToSet) end, pullFromBagFrameWaitDuration)
end
function pullPlayerStarterChoices(playerToSet)
    playerToSet = playerToSet + 1
    playerStartersToSet = playerToSet
    --printToAll("Processing JSON Element #" .. playerToSet)
    --printToAll("Total # Of JSON Elements = " .. playersDataFetched)
    if playerStartersToSet <= playersDataFetched then
        chosenStartersForSeatNumber = tonumber(playerStarterInfo[playerToSet]["playerSeat"])
        --printToAll( "chosenStartersForSeatNumber = " .. chosenStartersForSeatNumber )
        --printToAll(JSON.encode(playerStarterInfo))
        if tableSize == 1 then
            if chosenStartersForSeatNumber == 1 then
                chosenStartersForPlayerColor = "Green"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 2 then
                chosenStartersForPlayerColor = "Yellow"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 3 then
                chosenStartersForPlayerColor = "Red"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 4 then
                chosenStartersForPlayerColor = "White"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 5 then
                chosenStartersForPlayerColor = "Brown"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 6 then
                chosenStartersForPlayerColor = "Purple"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 7  then
                chosenStartersForPlayerColor = "Orange"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 8  then
                chosenStartersForPlayerColor = "Pink"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 9  then
                chosenStartersForPlayerColor = "Black"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 10  then
                chosenStartersForPlayerColor = "Grey"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            else
                --Error Catch
                chosenStartersForPlayerColor = "Unidentified Seat Color"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            end
        else
            if chosenStartersForSeatNumber == 1 then
                chosenStartersForPlayerColor = "Green"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 2 then
                chosenStartersForPlayerColor = "Yellow"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 3 then
                chosenStartersForPlayerColor = "Red"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 4 then
                chosenStartersForPlayerColor = "White"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 5 then
                chosenStartersForPlayerColor = "Brown"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 6 then
                chosenStartersForPlayerColor = "Purple"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 7 then
                chosenStartersForPlayerColor = "Orange"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 8 then
                chosenStartersForPlayerColor = "Pink"
                pullStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 9 then
                chosenStartersForPlayerColor = "Black"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            elseif chosenStartersForSeatNumber == 10 then
                chosenStartersForPlayerColor = "Grey"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            else
                --Error Catch
                chosenStartersForPlayerColor = "Unidentified Seat Color"
                printToAll("Skipping Starters For " .. chosenStartersForPlayerColor)
                pullNextPlayerStarters(playerToSet)
            end
        end
    else
        --I don't think we can arrive here b/c this loops through the JSON then stops.
    end
end
function pullStarters(playerToSet)
    if chosenStartersForPlayerColor ~= "Unidentified Seat Color" then
        --printToAll("Pulling Starters For " .. chosenStartersForPlayerColor)

        --printToAll("Pulling Punches For " .. chosenStartersForPlayerColor)
        punchDCDB = tonumber(playerStarterInfo[playerToSet]["favPunch"])
        if punchDCDB == 0 then
            punchDCDB = math.random (1, 12)
        end
        --printToAll( "Fav Punch = " .. punchDCDB )
        punchDcdbIntegration()

        --printToAll("Pulling Vulns For " .. chosenStartersForPlayerColor)
        vulnerabilityDCDB = tonumber(playerStarterInfo[playerToSet]["favVuln"])
        if vulnerabilityDCDB == 0 then
            vulnerabilityDCDB = math.random (1, 10)
        end
        --printToAll( "Fav Vuln = " .. vulnerabilityDCDB )
        vulnerabilityDcdbIntegration()

        --Set Kick And Weaknesses Based On First Returned Result
        if kickDCDB == 0 then
            printToAll("Kicks And Weaknesses Chosen By " .. Player[chosenStartersForPlayerColor].steam_name)

            --printToAll("Pulling Kicks For " .. chosenStartersForPlayerColor)
            kickDCDB = tonumber(playerStarterInfo[playerToSet]["favKick"])
            --printToAll( "Fav Kick = " .. kickDCDB )
            kickDcdbIntegration()

            --printToAll("Pulling Weaknesses For " .. chosenStartersForPlayerColor)
            weaknessDCDB = tonumber(playerStarterInfo[playerToSet]["favWeakness"])
            --printToAll( "Fav Weakness = " .. weaknessDCDB )
            weaknessDcdbIntegration()
        end
    end
end
function afterBagRemovedDCDB(tempBag, params)
    for i, data in ipairs(params) do
        if not data.color then
            tempBag.takeObject(data)
            if data.lock=="yes" then
                function lockCo()
                    wait(0.2)
                    getObjectFromGUID(data.guid).setLock(true)
                    return 1
                end
                startLuaCoroutine(Global, "lockCo")
            end
        elseif Player["Yellow"].seated == true and data.color == "Yellow" and chosenStartersForPlayerColor == "Yellow" then
            --printToAll("Placing Starters For Player -> " .. chosenStartersForPlayerColor)
            tempBag.takeObject(data)
            checkStarters()
        elseif Player["White"].seated == true and data.color == "White" and chosenStartersForPlayerColor == "White" then
            --printToAll("Placing Starters For Player -> " .. chosenStartersForPlayerColor)
            tempBag.takeObject(data)
            checkStarters()
        elseif Player["Red"].seated == true and data.color == "Red" and chosenStartersForPlayerColor == "Red" then
            --printToAll("Placing Starters For Player -> " .. chosenStartersForPlayerColor)
            tempBag.takeObject(data)
            checkStarters()
        elseif Player["Green"].seated == true and data.color == "Green" and chosenStartersForPlayerColor == "Green" then
            --printToAll("Placing Starters For Player -> " .. chosenStartersForPlayerColor)
            tempBag.takeObject(data)
            checkStarters()
		elseif Player["Brown"].seated == true and data.color == "Brown" and chosenStartersForPlayerColor == "Brown" then
            --printToAll("Placing Starters For Player -> " .. chosenStartersForPlayerColor)
            tempBag.takeObject(data)
            checkStarters()
        elseif Player["Purple"].seated == true and data.color == "Purple" and chosenStartersForPlayerColor == "Purple" then
            --printToAll("Placing Starters For Player -> " .. chosenStartersForPlayerColor)
            tempBag.takeObject(data)
            checkStarters()
        elseif Player["Orange"].seated == true and data.color == "Orange" and chosenStartersForPlayerColor == "Orange" then
            --printToAll("Placing Starters For Player -> " .. chosenStartersForPlayerColor)
            tempBag.takeObject(data)
            checkStarters()
        elseif Player["Pink"].seated == true and data.color == "Pink" and chosenStartersForPlayerColor == "Pink" then
            --printToAll("Placing Starters For Player -> " .. chosenStartersForPlayerColor)
            tempBag.takeObject(data)
            checkStarters()
        end
    end
    tempBag.destruct()
end
function checkStarters()
    playerStartersLoaded = playerStartersLoaded + 1
    if playerStartersLoaded == 2 then
        --printToAll("Pulling Next Players Starters")
        playerStartersLoaded = 0
        pullNextPlayerStarters()
    end
end
function pullNextPlayerStarters()
    --printToAll("playerStartersToSet = " .. playerStartersToSet)
    --printToAll("playersDataFetched = " .. playersDataFetched)
    if playerStartersToSet ~= playersDataFetched then
        --Load Next Players Starters
        Wait.frames(function () pullPlayerStarterChoices(playerStartersToSet) end, pullFromBagFrameWaitDuration)
    else
        --Something Was Causing This To Run Multiple Times, So Put A Limit On It
        if everythingPulled == 0 then
            everythingPulled = 1
            --Ready To Pull MD, MCs And SVs
            Wait.frames(function () pullMdMcAndSVs() end, pullFromBagFrameWaitDuration)
        end
    end
end
function pullMdMcAndSVs()
    --printToAll("Pulling MD And MCs")
    infBag.DCDBall.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic DCDB"], smooth = false})

    --Ready To Sort SV Stack
    Wait.frames(function () findSvsInStack() end, svSortWaitTime)
end
function calcTimeCubeGameEnds()
    --Calc Game End Unix Time Based On Game Clock
    local currentUnixTime = os.time(os.date("!*t"))
    local gameTimeRemaining = mainClock.getValue()
    local unixTimeGameEnds = currentUnixTime + gameTimeRemaining
    return unixTimeGameEnds
end
---------****************** DCDeckbuilding.com Integration

--************************Table Functions************************--

function movePlayBoard(colorNext) --Actual Function to move Play Area Board
    if colorNext == "White" then
		playBoard.setPositionSmooth({12.40, 0.96, -16.9})
		playBoard.setRotationSmooth({0, 180, 0})
    elseif colorNext == "Yellow" then
		playBoard.setPositionSmooth({12.40, 0.96, 16.9})
		playBoard.setRotationSmooth({0, 0, 0})
    elseif colorNext == "Red" then
		playBoard.setPositionSmooth({-12.40, 0.96, -16.9})
		playBoard.setRotationSmooth({0, 180, 0})
    elseif colorNext == "Green" then
		playBoard.setPositionSmooth({-12.40, 0.96, 16.9})
		playBoard.setRotationSmooth({0, 0, 0})
    elseif colorNext == "Brown" then
		playBoard.setPositionSmooth({-53.25, 0.96, -16.9})
		playBoard.setRotationSmooth({0, 180, 0})
    elseif colorNext == "Purple" then
		playBoard.setPositionSmooth({-53.25, 0.96, 16.9})
		playBoard.setRotationSmooth({0, 0, 0})
    elseif colorNext == "Orange" then
		playBoard.setPositionSmooth({53.25, 0.96, 16.9})
		playBoard.setRotationSmooth({0, 0, 0})
    elseif colorNext == "Pink" then
		playBoard.setPositionSmooth({53.25 , 0.96, -16.9})
		playBoard.setRotationSmooth({0, 180, 0})
    else
        return
    end
    --Put Anything Underneath The Play Area On Top Of It When It Stops Moving
    putObjectsOnPlayArea()

end
function putObjectsOnPlayArea()
    --Once Board Movement Stops Then Put Anything Under It On Top Of It
    if playBoard.isSmoothMoving() == true  then
        --Wait For It To Stop
        Wait.frames( function() putObjectsOnPlayArea() end, checkForPlayAreaDoneMoving)
    else
        --Its Done Moving, Now Put Objects On Top Of It
        local objectsOnPlayBoard = Physics.cast({origin=playBoard.getPosition(), direction={0,1,0}, type=3, max_distance=1, size={15,1,13}})
        for i, entry in ipairs(objectsOnPlayBoard) do
            if entry.hit_object.type  == "Deck" or entry.hit_object.type =="Card" then
                entry.hit_object.setPositionSmooth({entry.hit_object.getPosition().x,3,entry.hit_object.getPosition().z})
            end
        end
    end

end
function playerTryToDrawXcards(object, player_color, number)
    local cardsThatCanBeDrawn = checkHowManyCardsCanBeDrawn(object, player_color, number)
    if object ~= nil then
        Wait.frames( function() playerDrawXcards(object, player_color, cardsThatCanBeDrawn) end, discardingToDrawingDuration)
    end
end
function playerDrawXcards(object, player_color, number)
    object.deal(number, player_color)
end
function checkHowManyCardsCanBeDrawn(object, player_color, number)
    --Log When Players Draw Cards By Typing Number At Top Of Keyboard
    local name = Player[player_color].steam_name
    local numOfCardsActuallyDrawn = 0
    local numOfCardsInDeck = 0
    --log(object)
    if object ~= nil then
        if object.type  == "Card" then
            numOfCardsInDeck = 1
        end
        if object.type  == "Deck" then
            local cardsInDeck = object.getObjects()
            for j, card in ipairs(cardsInDeck) do
                numOfCardsInDeck = numOfCardsInDeck + 1
            end
        end
    else
        numOfCardsInDeck = 0
    end
    --Test Boundary Conditions
    if number > numOfCardsInDeck then
        --There Is Not Enough Cards To Draw The Number They Wanted To
        local cardsTheyNeedToDraw = number - numOfCardsInDeck
        if numOfCardsInDeck == 1 then
            printToAll(name .. " is drawing " .. number .. " cards. They drew " .. numOfCardsInDeck .. " card and need to draw " .. cardsTheyNeedToDraw .. " more.")
        else
            printToAll(name .. " is drawing " .. number .. " cards. They drew " .. numOfCardsInDeck .. " cards and need to draw " .. cardsTheyNeedToDraw .. " more.")
        end
        return numOfCardsInDeck
    else
        --They Draw As Many As They Intended To
        if number == 1 then
            printToAll(name .. " drew " .. number .. " card.")
        else
            printToAll(name .. " drew " .. number .. " cards.")
        end
        return number
    end
end
function getRightmostEmptyLineupSlot()
    for i = #lineupSlots, 1, -1 do
        local slot = lineupSlots[i].slotZone
        local hasCard = false

        for _, obj in ipairs(slot.getObjects()) do
            if obj.type == "Card" or obj.type == "Deck" then
                hasCard = true
                break
            end
        end

        if not hasCard then
            return slot
        end
    end

    return nil
end
function onObjectNumberTyped(object, player_color, number)
	--If Duplicate Input Is Detected Then Truncate And Just Draw The Intended Number
	--i.e. 22 = 2, 55 = 5, 88 = 8, etc
	if number > 10 then
		--Check For Duplicate Keystroke
		local numberString = tostring(number)
		local duplicateNumberPressDetected = true
		local correctNumberToDraw = number
			local charA = string.sub(numberString, 0, 1)
			local charB = string.sub(numberString, 1, 1)
			--print("Comparing " .. charA .. " vs " .. charB)
			if charA ~= charB then
				duplicateNumberPressDetected = false
				--print("They Are Different")
			else
				correctNumberToDraw = tonumber(charA)
				--print("They Are The Same, Truncating Number To Draw Down To: " .. correctNumberToDraw)
			end

		if duplicateNumberPressDetected == true then
			--print("Drawing A Different Number Than Pressed...")
			playerTryToDrawXcards(object, player_color, correctNumberToDraw)
			--Exit W/o Letting TTS Draw The Cards, As We've Already Handled It
			return true
		end
	end
	 --Get Count Of Cards They Should Draw (In Case Their Deck Doesn't Have Enough To Draw As Many As They Want)
    --log ("Drawing From Hover Object Is:")
    --log (object)
    local cardsThatCanBeDrawn = checkHowManyCardsCanBeDrawn(object, player_color, number)
end
function tuckRightmostMainLineupAndEndTurn(playerColor, object) --tuck oldest card and end turn
    local targetCard = nil

    -- 1) Scan main lineup right → left
    for i = #lineupSlots, 1, -1 do
        local zone = lineupSlots[i].slotZone
        if zone then
            local objs = zone.getObjects()
            local isFrozen = false

            -- detect frozen slot (mirror shiftLineupRight)
            for _, o in ipairs(objs) do
                if o.type == "Tile" and o.getName() == "Frozen Token" then
                    isFrozen = true
                    break
                end
            end

            -- if slot is NOT frozen, look for a card
            if not isFrozen then
                for _, o in ipairs(objs) do
                    if o.type == "Card" then
                        targetCard = o
                        break
                    end
                end
            end
        end

        if targetCard then break end
    end

    -- 2) No valid card → end turn normally
    if not targetCard then
        print("No card to tuck")
        Turns.endTurn()
        return
    end

    -- 3) Find main deck
    local deck = nil
    for _, o in ipairs(zTable.zMainDeck.getObjects()) do
        if o.type == "Deck" or o.type == "Card" then
            deck = o
            break
        end
    end

    if not deck then
        print("Main Deck not found.")
        Turns.endTurn()
        return
    end

    -- 4) Tuck card to bottom
    if deck.type == "Deck" then
        deck.putObject(targetCard)
    else
        -- Single-card deck case
        targetCard.setPositionSmooth(deck.getPosition())
    end

    -- 5) Delay, then end turn
    Wait.frames(function()
        Turns.endTurn()
    end, 30)
end
function tuckBribedCards() --tuck Bribed cards
    -- 1) Find main deck (mirror existing logic)
    local deck = nil
    for _, o in ipairs(zTable.zMainDeck.getObjects()) do
        if o.type == "Deck" or o.type == "Card" then
            deck = o
            break
        end
    end

    if not deck then
        print("Main Deck not found for bribe tuck.")
        return
    end

    -- Helper to scan a slot table
    local function scanSlots(slotTable)
        for _, slot in ipairs(slotTable) do
            local zone = slot.slotZone
            if zone then
                local objs = zone.getObjects()
                local card = nil
                local hasBribe = false

                for _, o in ipairs(objs) do
                    if o.type == "Card" then
                        card = o
                    elseif o.type == "Tile" and o.getName() == "ARK Bribe" then
                        hasBribe = true
                    end
                end

                if card and hasBribe then
                    -- Tuck card to bottom of main deck
                    if deck.type == "Deck" then
                        deck.putObject(card)
                    else
                        -- Single-card deck case
                        card.setPositionSmooth(deck.getPosition())
                    end
                end
            end
        end
    end

    -- 2) Scan event lineup first, then main lineup
    scanSlots(eventSlots)
    scanSlots(lineupSlots)
end
function shiftLineupRight()
    local movable = {}  -- { {obj=cardObj, origIndex=i}, ... }
    local frozenSlots = {} -- boolean per slot index

    -- 1) Scan slots left→right and collect movable cards (skip frozen slots)
    for i, slot in ipairs(lineupSlots) do
        local zone = slot.slotZone
        if not zone then
            print("Warning: shiftLineupRight - slotZone nil at index "..i)
            frozenSlots[i] = false
        else
            local objs = zone.getObjects()
            -- detect frozen
            local isFrozen = false
            for _, o in ipairs(objs) do
                if o.type == "Tile" and o.getName() == "Frozen Token" then
                    isFrozen = true
                    break
                end
            end
            frozenSlots[i] = isFrozen

            -- if not frozen, collect the card (if any) to be movable
            if not isFrozen then
                for _, o in ipairs(objs) do
                    if o.type == "Card" then
                        table.insert(movable, { obj = o, origIndex = i })
                        break -- only one card per slot expected
                    end
                    if o.type == "Deck" then
                        -- If a deck occupies the slot treat the top card as non-movable (or handle as you prefer)
                        -- Here we treat a deck as a card object (you may adjust if needed)
                        table.insert(movable, { obj = o, origIndex = i })
                        break
                    end
                end
            end
        end
    end

    -- Nothing or only one movable card -> nothing to shift
    if #movable == 0 then
        return false
    end

    -- 2) Temporarily move movable cards off table (same approach as before)
    local tempY = 5
    local tempX = 30
    for _, entry in ipairs(movable) do
        entry.obj.setPositionSmooth({tempX, tempY, 0}, false, true)
        tempX = tempX + 2
    end

    -- 3) Place movable cards back from rightmost -> left, skipping frozen slots
    local placeIndex = #lineupSlots
    local moved = false

    for idx = #movable, 1, -1 do
        -- find next non-frozen slot
        while placeIndex > 0 and frozenSlots[placeIndex] do
            placeIndex = placeIndex - 1
        end
        if placeIndex <= 0 then break end

        local targetZone = lineupSlots[placeIndex].slotZone
        if targetZone then
            local pos = targetZone.getPosition()
            local cardEntry = movable[idx]
            -- check whether it actually moves to a different index vs. original
            if cardEntry.origIndex ~= placeIndex then
                moved = true
            end
            cardEntry.obj.setPositionSmooth({pos.x, pos.y, pos.z})
            cardEntry.obj.setRotationSmooth({0, 180, 0})
        end

        placeIndex = placeIndex - 1
    end

    return moved
end
function shiftEventLineupLeft()
    local movable = {}     
    local frozenSlots = {}

    ----------------------------------------------------------------
    -- 1) Scan event lineup slots (START AT 2, skip Events bucket)
    ----------------------------------------------------------------
    for i = 2, #eventSlots do
        local slot = eventSlots[i]
        local zone = slot.slotZone

        if not zone then
            print("Warning: shiftEventLineupLeft - slotZone nil at index "..i)
            frozenSlots[i] = false
        else
            local objs = zone.getObjects()
            local isFrozen = false

            for _, o in ipairs(objs) do
                if o.type == "Tile" and o.getName() == "Frozen Token" then
                    isFrozen = true
                    break
                end
            end

            frozenSlots[i] = isFrozen

            if not isFrozen then
                for _, o in ipairs(objs) do
                    if o.type == "Card" or o.type == "Deck" then
                        table.insert(movable, { obj = o, origIndex = i })
                        break
                    end
                end
            end
        end
    end

    if #movable == 0 then
        return false
    end

    ----------------------------------------------------------------
    -- 2) Temp park
    ----------------------------------------------------------------
    local tempY = 5
    local tempX = -30
    for _, entry in ipairs(movable) do
        entry.obj.setPositionSmooth({tempX, tempY, 0}, false, true)
        tempX = tempX - 2
    end

    ----------------------------------------------------------------
    -- 3) Place LEFT → RIGHT, but only into slots 2+
    ----------------------------------------------------------------
    local placeIndex = 2
    local moved = false

    for idx = 1, #movable do
        while placeIndex <= #eventSlots and frozenSlots[placeIndex] do
            placeIndex = placeIndex + 1
        end
        if placeIndex > #eventSlots then break end

        local targetZone = eventSlots[placeIndex].slotZone
        if targetZone then
            local pos = targetZone.getPosition()
            local entry = movable[idx]

            if entry.origIndex ~= placeIndex then
                moved = true
            end

            entry.obj.setPositionSmooth({pos.x, pos.y, pos.z})
            entry.obj.setRotationSmooth({0,180,0})
        end

        placeIndex = placeIndex + 1
    end

    return moved
end
function fillLineupSlots() --Move Cards From Event Slots To Empty Lineup Slots As Able
    if specialSetUp == "Multiverse" or lineupEA2_Legends == true then
		findMainDeck()
	else
		fixLineUp()
	end
end
function addOneCardToLineup() --Add One Card To The Lineup
    --Only Allow To Add Another Card After The Last Card Added Reaches Its Destination
    local addedCard = 0
    local addedName = nil

    if cardEnRoute ~= 1 then
        local objectsInZone = zTable.zMainDeck.getObjects()
        for i, object in ipairs(objectsInZone) do
            if addedCard == 0 then
                if object.type  == "Deck" or object.type  == "Card" then
                    refreshLineUpArray()
                    for i, zone in ipairs(cardsInLineUpSlots) do
                        if addedCard == 0 then
                            local c = 0
                            local objInZone = zone.slotZone.getObjects()
                            for k,v in pairs(objInZone) do
                                if v.type  == "Card" or v.type  == "Deck" then
                                    c=c+1
                                end
                            end
                            if c==0 then
                                cardEnRoute = 1
                                cardDestination = zone.slotZone
                                if object.type  == "Deck" then
                                    addedCard = 1
                                    addedName = fillSpecificLineupSlot(object, zone.slotZone)
                                else
                                    object.setPosition(zone.slotZone.getPosition())
                                    object.setRotation({0,180,0})
                                    addedCard = 1
                                    addedName = object.getName()
                                end
                            end
                        end
                    end
                end
            end
        end
        if addedCard == 0 then
            printToAll("Move A Card From The Lineup To Make Room And Then Try Again")
        end
    end
    --Return Card Name For Functions Like mcCrisisTheFlash, etc
    return addedName
end
function findMainDeck() --See if there is a deck on the Main Deck zone
    if dcdbCubeGame == 1 then
        if turnCounter == 0 then
            numCardsOverCost = 0
            numCardsOverType = 0
        end
    end
	local objectsInZone = zTable.zMainDeck.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" or object.type  == "Card" then
			fillLineUp(object)
			break
		end
	end
	if lineupEA2_Legends == true then
	local legendsInZone = zTable.zEventDeck.getObjects()
		for i, object in ipairs(legendsInZone) do
			if object.type  == "Deck" or object.type  == "Card" then
				fillLegendsLineUp(object)
				break
			end
		end
	end
end
function getEmptyLineupSlotsRightToLeftIgnoringFrozen() --Finds empty slots for fill
    local empty = {}

    for i = #lineupSlots, 1, -1 do
        local slot = lineupSlots[i]
        local zone = slot.slotZone
        local hasCard = false
        local isFrozen = false

        if zone then
            for _, o in ipairs(zone.getObjects()) do
                if o.type == "Tile" and o.getName() == "Frozen Token" then
                    isFrozen = true
                    break
                end
            end

            if not isFrozen then
                for _, o in ipairs(zone.getObjects()) do
                    if o.type == "Card" or o.type == "Deck" then
                        hasCard = true
                        break
                    end
                end
            end
        end

        if zone and not isFrozen and not hasCard then
            table.insert(empty, zone)
        end
    end

    return empty
end
function fixLineUp()
    -- 1. Shift main lineup first
    local shifted = shiftLineupRight()

    -- prepare arrays
    local eventCardsToMove = {}

    --------------------------------------------------------------------
    -- 2. Wait 60 frames BEFORE scanning event lineup
    --------------------------------------------------------------------
    Wait.frames(function()

        ----------------------------------------------------------------
        -- 3. Scan event slots normally (left → right), but DO NOT move yet
        ----------------------------------------------------------------
        local eventSlotToCheck = 0

        for i, lineupZone in ipairs(lineupSlots) do
            local lineupObjects = lineupZone.slotZone.getObjects()
            local slotHasCard = false

            for _, obj in ipairs(lineupObjects) do
                if obj.type == "Card" or obj.type == "Deck" then
                    slotHasCard = true
                    break
                end
            end

            if not slotHasCard then
                local replacedCard = false
                local slotCanPullFrom = 0

                for j, eventZone in ipairs(eventSlots) do
                    if slotCanPullFrom == eventSlotToCheck then
                        if not replacedCard then
							local objInEvent = eventZone.slotZone.getObjects()
							local isFrozen = false

							-- detect frozen token in EVENT slot
							for _, o in ipairs(objInEvent) do
								if o.type == "Tile" and o.getName() == "Frozen Token" then
									isFrozen = true
									break
								end
							end

							-- skip this event slot entirely if frozen
							if not isFrozen then
								for _, evObj in ipairs(objInEvent) do
									if evObj.type == "Card" then
										table.insert(eventCardsToMove, evObj)
										replacedCard = true
										break
									elseif evObj.type == "Deck" then
										local top = evObj.takeObject()
										table.insert(eventCardsToMove, top)
										replacedCard = true
										break
									end
								end
							end
                        end
                        eventSlotToCheck = eventSlotToCheck + 1
                        if replacedCard then break end
                    end

                    slotCanPullFrom = slotCanPullFrom + 1
                end
            end
        end

        --------------------------------------------------------------------
        -- 4. Wait ANOTHER 60 frames before moving any event cards
        --------------------------------------------------------------------
        Wait.frames(function()

			----------------------------------------------------------------
			-- 5. Move event cards one-by-one with 50-frame delay
			--    (uses precomputed destination slots, skips frozen)
			----------------------------------------------------------------
			local delayBetweenCards = 50
			local delay = 0

			-- Precompute valid destination slots (right → left)
			local destinationSlots = {}
			for i = #lineupSlots, 1, -1 do
				local zone = lineupSlots[i].slotZone
				if zone then
					local objs = zone.getObjects()
					local hasCard = false
					local isFrozen = false

					for _, o in ipairs(objs) do
						if o.type == "Tile" and o.getName() == "Frozen Token" then
							isFrozen = true
							break
						end
						if o.type == "Card" or o.type == "Deck" then
							hasCard = true
						end
					end

					if not hasCard and not isFrozen then
						table.insert(destinationSlots, zone)
					end
				end
			end

			-- Move cards using reserved slots
			for idx, card in ipairs(eventCardsToMove) do
				local targetZone = destinationSlots[idx]
				if targetZone then
					Wait.frames(function()
						local pos = targetZone.getPosition()
						card.setPositionSmooth(pos)
						card.setRotationSmooth({0,180,0})
					end, delay)

					delay = delay + delayBetweenCards
				end
			end
            ----------------------------------------------------------------
            -- 6. After all event cards scheduled, refill from deck
            ----------------------------------------------------------------
            local lastDelay = #eventCardsToMove * delayBetweenCards
            Wait.frames(function()

				----------------------------------------------------------------
				-- NEW: buffer before shifting the event lineup
				----------------------------------------------------------------
				Wait.frames(function()
					shiftEventLineupLeft()
				end, 40)  

				----------------------------------------------------------------
				-- Refill from main deck
				----------------------------------------------------------------
				
                if #eventCardsToMove == 0 and not shifted then
                    findMainDeck()
                else
                    Wait.frames(findMainDeck, 60)
                end
            end, lastDelay)

        end, 60) -- end 60-frame post-scan delay

    end, 60) -- end 60-frame pre-scan delay
end
function cutMainDeck() --See if there is a deck on the Main Deck zone
	local objectsInZone = zTable.zMainDeck.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			object.shuffle()
			object.cut()
			object.setPositionSmooth({-8.76, 3, 4.75})
			break
		end
	end
end
function splitMainDeck() -- Cuts deck in half for Crisis & Crossover Setup
	tempInZone = zTable.zMainDeck
	getCurrentDeck()
	if currentDeck ~= nil then
		currentDeck.shuffle()
		cutStacks = currentDeck.split(2)
		function moveCutStacks()
			wait(0.5)
				cutStacks[1].setPosition({-8.76, 3, 4.75})
				cutStacks[1].setRotationSmooth({0, 180, 180})
				cutStacks[2].setRotationSmooth({0, 180, 180})
			return 1
		end
		startLuaCoroutine(Global, "moveCutStacks")
	end
end
function restoreMainDeck() -- Restore for Crisis & Crossover setup
	local objectsInZone = zTable.zOther1.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			object.shuffle()
			object.setPositionSmooth({-8.76, 3, 0})
			break
		end
	end
end
function changeTable1() -- Change to Default Table
	tableDefault()
	table4player()
	if tableNumber ~= 1 then
		mainTableSwitch=mainTableSwitch.setState(1)
		tableNumber = 1
		tableSize = 1
		gameTable1 = getObjectFromGUID("f2db8b")
		gameTable1.setPosition({0.00, 0.85, 0.00})
		Wait.frames(lockMainTable, 4)
		zTable.zMainDeck.clearButtons()
        if dcdbCubeGame == 1 then
            --Use Cube Buttons
            setupCubeButtons()
        else
            --Don't Use Cube Buttons
            setupGameButtons()
        end
	end
end
function changeTable2() -- Change to Rebirth table
	tableRebirth()
	table4player()
	if tableNumber ~= 2 then
		mainTableSwitch=mainTableSwitch.setState(2)
		tableNumber = 2
		tableSize = 1
		gameTable2 = getObjectFromGUID("2482a4")
		gameTable2.setPosition({0.00, 0.85, 0.00})
		Wait.frames(lockMainTable, 3)
		zTable.zMainDeck.clearButtons()
		zTable.zMainDeck.createButton({rotation={0,180,0}, position={0,0,1.2}, font_size=120, label="Refill", width=400, height=200, click_function='findMainDeck'})
	end
end
function changeTable3() -- Change to Default Table
	tableDefault()
	table8player()
	if tableNumber ~= 3 then
		mainTableSwitch=mainTableSwitch.setState(3)
		tableNumber = 3
		tableSize = 2
		gameTable3 = getObjectFromGUID("f2265f")
		gameTable3.setPosition({0.00, 0.75, 0.00})
		Wait.frames(lockMainTable, 2)
		zTable.zMainDeck.clearButtons()
		zTable.zMainDeck.createButton({rotation={0,180,0}, position={1,0,0}, font_size=120, label="Refill", width=400, height=200, click_function='findMainDeck'})
	end
end
function changeTable4() -- Change to Rebirth table
	tableRebirth()
	table8player()
	if tableNumber ~= 4 then
		mainTableSwitch = mainTableSwitch.setState(4)
		tableNumber = 4
		tableSize = 2
		gameTable4 = getObjectFromGUID("7853b6")
		gameTable4.setPosition({0.00, 0.75, 0.00})
		Wait.frames(lockMainTable, 1)
		zTable.zMainDeck.clearButtons()
		zTable.zMainDeck.createButton({rotation={0,180,0}, position={0,0,1.2}, font_size=120, label="Refill", width=400, height=200, click_function='findMainDeck'})
	end
end
function findBossStack() --See if the Boss Stack needs its top card flipped
    local objectsInZone = zTable.zBossStack.getObjects()
    local numUpCards = 0
    local numDownCards = 0
    local numDecks = 0
    for i, object in ipairs(objectsInZone) do
        if object.type  == "Card"  then
            if object.getRotation().z > 165 and object.getRotation().z < 195 then
                numDownCards = numDownCards + 1
            else
                numUpCards = numUpCards + 1
            end
        elseif object.type  == "Deck" then
            numDecks = numDecks + 1
        end
    end
    local dcdbSvFlip = 0
    for j, object in ipairs(objectsInZone) do
        if numUpCards ~= 1 and numDownCards == 1 and numDecks == 0 then
            if object.type  == "Card" then
                if dcdbSvFlip == 0 then
                    dcdbSvFlip = 1
                    svShouldFlip(objectsInZone)
                end
                object.flip()
            end
        elseif numUpCards ~= 1 and numDecks == 1 then
            if dcdbSvFlip == 0 then
                dcdbSvFlip = 1
                svShouldFlip(objectsInZone)
            end
            object.takeObject({position={zTable.zBossStack.getPosition().x,2,zTable.zBossStack.getPosition().z},flip=true})
        end
    end
end
function findHostageStack() -- Ensure top Hostage is face-up
    local objectsInZone = zTable.zCrisisStack.getObjects()
    local numUpCards = 0
    local numDownCards = 0
    local numDecks = 0

    -- First pass: count state
    for _, object in ipairs(objectsInZone) do
        if object.type == "Card" then
            if object.getRotation().z > 165 and object.getRotation().z < 195 then
                numDownCards = numDownCards + 1
            else
                numUpCards = numUpCards + 1
            end
        elseif object.type == "Deck" then
            numDecks = numDecks + 1
        end
    end

    -- Second pass: fix state if needed
    for _, object in ipairs(objectsInZone) do
        -- Case 1: single facedown card, no deck
        if numUpCards ~= 1 and numDownCards == 1 and numDecks == 0 then
            if object.type == "Card" then
                object.flip()
                break
            end

        -- Case 2: deck present → take and flip top card
        elseif numUpCards ~= 1 and numDecks == 1 then
            if object.type == "Deck" then
                object.takeObject({
                    position = {
                        zTable.zCrisisStack.getPosition().x,
                        2,
                        zTable.zCrisisStack.getPosition().z
                    },
                    flip = true
                })
                break
            end
        end
    end
end
function svShouldFlip(objectsInZone)
    ---------****************** DCDeckbuilding.com Integration
    for i, object in ipairs(objectsInZone) do
        if object.type  == "Deck" then
            local deck = object
            local cardsInDeck = deck.getObjects()
            for j, card in ipairs(cardsInDeck) do
				local master = objScripts_Score.getTable("masterCardTable")[card.name]
				--printToAll("Flipped Boss A = " .. master.name)
				--printToAll("Flipped Boss TTS ID = " .. master.id)
				bossFound = 1
				flipNextBoss(master.id)
                --Only Need The Top Card Of MC Stack, So Can Exit Loop
                break;
            end
        elseif object.type  == "Card" then
			local master = objScripts_Score.getTable("masterCardTable")[object.getName()]
			--printToAll("Flipped Boss B = " .. master.name)
			--printToAll("Flipped Boss TTS ID = " .. master.id)
			flipNextBoss(master.id)
        end
    end
    ---------****************** DCDeckbuilding.com Integration
end
function refreshLineUpArray()
    cardsInLineup = {}
    for i, zone in ipairs(cardsInLineUpSlots) do
        local objInZone = zone.slotZone.getObjects()
        for k,v in pairs(objInZone) do
            --if v.type  == "Card" or v.type  == "Deck" then
            if v.type  == "Card" then
                table.insert(cardsInLineup, v.getName())
            end
        end
    end
end
function fillSpecificLineupSlot(object, zone)
    --log(zone)
    --log(object)
    local topCardName = nil
    --If Cube Game
    if dcdbCubeGame == 1 then
        --Check For Top Card Being Duplicate In The Lineup, And If So Then Replace It
        local duplicateCard = 0
            --duplicateCard == 1 Means Duplicate Card In Lineup
            --duplicateCard == 2 Means Failed Opening Lineup Check
        --Begin Loop To Find Card That Can Enter The Lineup
        repeat
            --Initially Assume No Duplicates
            topCardName = nil
            duplicateCard = 0

            local cardsInDeck = object.getObjects()
            for j, card in ipairs(cardsInDeck) do
                topCardName = card.name
                --printToAll(topCardName .. " is the top card coming out")
                --Only Need The Check The Top Card Of MD, So Can Exit Loop
                break
            end

            --Check For Duplicate
            for i, cardToCheck in ipairs(cardsInLineup) do
                if cardToCheck == topCardName then
                    duplicateCard = 1
                end
            end

            --If No Duplicate, Then Check If Adjusting Opening Lineup
            if duplicateCard == 0 then
                --Adjust Opening Lineup
                if turnCounter == 0 then
                    --Find Card Info
					local master = objScripts_Score.getTable("masterCardTable")[topCardName]
					--Check Cost of topCardName
					if master.cost >= 5 then
						numCardsOverCost = numCardsOverCost + 1
						--Limit To One Card Costs 5 or Greater In Opening Lineup
						if numCardsOverCost > 1 then
							duplicateCard = 2
						end
					end

					--Check Type Of topCardName
					if master.isLocation == true then
						numCardsOverType = numCardsOverType + 1
						--Limit To One Location In Opening Lineup
						if numCardsOverType > 1 then
							duplicateCard = 2
						end
					end
                end
            end

            --Check If Card Should Be Removed
            if duplicateCard == 1 then
                --If Duplicate Then Delete (For IRL Just RFG It)
                --log("Removing Card From Lineup For Duplicate Rule:")
                --log(topCardName)
                destroyObject( object.takeObject() )
            elseif duplicateCard == 2 then
                --Adjust Opening Lineup (For IRL Just RFG It)
                --log("Removing Card From Opening Lineup:")
                --log(topCardName)
                destroyObject( object.takeObject() )
            end

        --Continue Going Through Cards As Needed Until Top Card Can Be Added To The Lineup
        until (duplicateCard == 0)

        --Push To Lineup Array
        table.insert(cardsInLineup, topCardName)
    end
    --Move Top Card Of MD To Lineup Slot
    object.takeObject({position=zone.getPosition(), rotation={0,180,0}})
    --Return Card Name For Other Function Uses (Like useCrisisTheFlash, etc)
    --log("Added Card Name:")
    --log(topCardName)
    return topCardName
end
function fillLineUp(object)
    refreshLineUpArray()

    -- Iterate from rightmost slot to leftmost
    for i = #lineupSlots, 1, -1 do
        local zone = lineupSlots[i]

        local c = 0
        local objInZone = zone.slotZone.getObjects()

        for k, v in pairs(objInZone) do
            if v.type == "Card" or v.type == "Deck" then
                c = c + 1
            end
        end

        if c == 0 then
            if object.type == "Deck" then
                fillSpecificLineupSlot(object, zone.slotZone)
            else
                object.setPosition(zone.slotZone.getPosition())
                object.setRotation({0,180,0})
            end
        end
    end
end
function fillLegendsLineUp(object)
    for i, zone in ipairs(legendsEA2Slots) do
        local c=0
        local objInZone = zone.slotZone.getObjects()
        for k,v in pairs(objInZone) do
            if v.type  == "Card" or v.type  == "Deck" then
                c=c+1
            end
        end
        if c==0 then
            if object.type  == "Deck" then
                fillSpecificLineupSlot(object, zone.slotZone)
            else
                object.setPosition(zone.slotZone.getPosition())
                object.setRotation({0,180,0})
            end
        end
    end
end
function tableDefault() -- Moves Script Zones to Default Table Loadout
zTable.zMainDeck.setPosition({-8.76, 1, 0})
zTable.zLineUp1.setPosition({-5.31, 1, 0})
zTable.zLineUp2.setPosition({-1.86, 1, 0})
zTable.zLineUp3.setPosition({1.59, 1, 0})
zTable.zLineUp4.setPosition({5.04, 1, 0})
zTable.zLineUp5.setPosition({8.49, 1, 0})
zTable.zEventDeck.setPosition({-8.76, 1, -4.75})
zTable.zEventLineUp1.setPosition({-5.31, 1, -4.75})
zTable.zEventLineUp2.setPosition({-1.86, 1, -4.75})
zTable.zEventLineUp3.setPosition({1.59, 1, -4.75})
zTable.zEventLineUp4.setPosition({5.04, 1, -4.75})
zTable.zEventLineUp5.setPosition({8.49, 1, -4.75})
zTable.zOther1.setPosition({-8.76, 1, 4.75})
zTable.zOther2.setPosition({-5.31, 1, 4.75})
zTable.zWeaknessStack.setPosition({-1.86, 1, 4.75})
zTable.zKickStack.setPosition({1.59, 1, 4.75})
zTable.zBossStack.setPosition({5.04, 1, 4.75})
zTable.zCrisisStack.setPosition({8.49, 1, 4.75})
zTable.zCharacter.setPosition({12.2, 1, 0})
registerTables()
end
function tableRebirth() -- Moves Script Zones to Rebirth Table Loadout
zTable.zMainDeck.setPosition({-11.51, 1, 2.47})
zTable.zLineUp1.setPosition({5.72, 1, 7.88})
zTable.zLineUp2.setPosition({6.48, 1, -2.34})
zTable.zLineUp3.setPosition({0, 1, -7.75})
zTable.zLineUp4.setPosition({-6.48, 1, -2.34})
zTable.zLineUp5.setPosition({-5.72, 1, 7.88})
zTable.zEventDeck.setPosition({-8.76, 1, -4.75})
zTable.zEventLineUp1.setPosition({0, 1, 7.83}) -- Locations
zTable.zEventLineUp2.setPosition({7.13, 1, 2.47})
zTable.zEventLineUp3.setPosition({5.75, 1, -7.82})
zTable.zEventLineUp4.setPosition({-5.75, 1, -7.82})
zTable.zEventLineUp5.setPosition({-7.13, 1, 2.47})
zTable.zOther1.setPosition({-10.57, 1, -2.34}) -- Scenario
zTable.zOther2.setPosition({10.67, 1, -2.34}) -- Special
zTable.zWeaknessStack.setPosition({11.51, 1, 2.47})
zTable.zKickStack.setPosition({1.59, 1, 4.75})
zTable.zBossStack.setPosition({-9, 1, 42})
zTable.zCrisisStack.setPosition({8.49, 1, 4.75})
zTable.zCharacter.setPosition({35, 1, 50})
registerTables()
end
function table4player() -- Moves Objects to 4 Player Table Setting
bagBrown.setPosition({-74.92, -10, -23.40})
scoreBrown.setPosition({-9, -10, 79})
displayBrown.setPosition({-9, -10, 74.5})
notecardBrown.setPosition({-9, -10, 79})
bagPurple.setPosition({-74.92, -10, 23.40})
scorePurple.setPosition({-9, -10, 89})
displayPurple.setPosition({-9, -10, 84.5})
notecardPurple.setPosition({-9, -10, 89})
bagOrange.setPosition({74.92, -10, 23.40})
scoreOrange.setPosition({9, -10, 89})
displayOrange.setPosition({9, -10, 84.5})
notecardOrange.setPosition({9, -10, 89})
bagPink.setPosition({74.92, -10, -23.40})
scorePink.setPosition({9, -10, 79})
displayPink.setPosition({9, -10, 74.5})
notecardPink.setPosition({9, -10, 79})
local params = {position = {x=0, y=1000, z=0},}
Player["Brown"].setHandTransform(params, 1)
Player["Purple"].setHandTransform(params, 1)
Player["Orange"].setHandTransform(params, 1)
Player["Pink"].setHandTransform(params, 1)
end
function table8player() -- Moves Objects to 8 Player Table Setting
bagBrown.setPosition({-74.92, 0.86, -23.40})
scoreBrown.setPosition({-9, 2.5, 79})
displayBrown.setPosition({-9, 0.85, 74.5})
notecardBrown.setPosition({-9, 0.97, 79})
bagPurple.setPosition({-74.92, 0.86, 23.40})
scorePurple.setPosition({-9, 2.5, 89})
displayPurple.setPosition({-9, 0.85, 84.5})
notecardPurple.setPosition({-9, 0.97, 89})
bagOrange.setPosition({74.92, 0.86, 23.40})
scoreOrange.setPosition({9, 2.5, 89})
displayOrange.setPosition({9, 0.85, 84.5})
notecardOrange.setPosition({9, 0.97, 89})
bagPink.setPosition({74.92, 0.86, -23.40})
scorePink.setPosition({9, 2.5, 79})
displayPink.setPosition({9, 0.85, 74.5})
notecardPink.setPosition({9, 0.97, 79})
local params1 = {position = {x=-65, y=4, z=-33}, scale = {x=15.78, y=6.48, z=5.87},}
local params2 = {position = {x=-65, y=4, z=33}, scale = {x=15.78, y=6.48, z=5.87}, rotation={0,180,0}}
local params3 = {position = {x=65, y=4, z=33}, scale = {x=15.78, y=6.48, z=5.87}, rotation={0,180,0}}
local params4 = {position = {x=65, y=4, z=-33}, scale = {x=15.78, y=6.48, z=5.87},}
Player["Brown"].setHandTransform(params1, 1)
Player["Purple"].setHandTransform(params2, 1)
Player["Orange"].setHandTransform(params3, 1)
Player["Pink"].setHandTransform(params4, 1)
end
function findCardsInPlay(color) --Grab Deck or Cards in Play Area, Move to Player's Discard zones.
    --Put Cards From Play Area Into Discard Pile
   for i=1, 2 do
        function findCardsCo()
            --Find cards that are on top of the Play Area board
            local objectsOnPlayBoard = Physics.cast({origin=playBoard.getPosition(), direction={0,1,0}, orientation=playerZone[color].playZoneRot, type=3, max_distance=1, size={15,1,13}})
            --Move those cards to the correct player's Discard Pile
            for i, entry in ipairs(objectsOnPlayBoard) do
                if entry.hit_object.type =="Deck" then
                    local deck = entry.hit_object
                    local cardsInDeck = deck.getObjects()
                    for j, card in ipairs(cardsInDeck) do
						local master = objScripts_Score.getTable("masterCardTable")[card.nickname]
						if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
							if #deck.getObjects() > 0 then
								deck.takeObject({position=playerZone[color].discardH.getPosition(), rotation=playerZone[color].playZoneRot, guid=card.guid})
							else
								entry.hit_object.setPositionSmooth(playerZone[color].discardH.getPosition())
								entry.hit_object.setRotation(playerZone[color].playZoneRot)
							end
						elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
							if #deck.getObjects() > 0 then
								deck.takeObject({position=playerZone[color].discardV.getPosition(), rotation=playerZone[color].playZoneRot, guid=card.guid})
							else
								entry.hit_object.setPositionSmooth(playerZone[color].discardV.getPosition())
								entry.hit_object.setRotation(playerZone[color].playZoneRot)
							end
						elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
							if #deck.getObjects() > 0 then
								deck.takeObject({position=playerZone[color].discardSP.getPosition(), rotation=playerZone[color].playZoneRot, guid=card.guid})
							else
								entry.hit_object.setPositionSmooth(playerZone[color].discardSP.getPosition())
								entry.hit_object.setRotation(playerZone[color].playZoneRot)
							end
						elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
							if #deck.getObjects() > 0 then
								deck.takeObject({position=playerZone[color].discardE.getPosition(), rotation=playerZone[color].playZoneRot, guid=card.guid})
							else
								entry.hit_object.setPositionSmooth(playerZone[color].discardE.getPosition())
								entry.hit_object.setRotation(playerZone[color].playZoneRot)
							end
						elseif master.isStarter==true then
							if #deck.getObjects() > 0 then
								deck.takeObject({position=playerZone[color].discardS.getPosition(), rotation=playerZone[color].playZoneRot, guid=card.guid})
							else
								entry.hit_object.setPositionSmooth(playerZone[color].discardS.getPosition())
								entry.hit_object.setRotation(playerZone[color].playZoneRot)
							end
						else
							if #deck.getObjects() > 0 then
								deck.takeObject({position=playerZone[color].discardO.getPosition(), rotation=playerZone[color].playZoneRot, guid=card.guid})
							else
								entry.hit_object.setPositionSmooth(playerZone[color].discardO.getPosition())
								entry.hit_object.setRotation(playerZone[color].playZoneRot)
							end
						end
					end
                elseif entry.hit_object.type =="Card" then
                    local master = objScripts_Score.getTable("masterCardTable")[entry.hit_object.getName()]
					if master.isHero==true or master.isAlly==true or master.isRick==true or master.isWizard==true then
						entry.hit_object.setPositionSmooth(playerZone[color].discardH.getPosition())
						entry.hit_object.setRotation(playerZone[color].playZoneRot)
					elseif master.isVillain==true or master.isEnemy==true or master.isMorty==true or master.isCreature==true then
						entry.hit_object.setPositionSmooth(playerZone[color].discardV.getPosition())
						entry.hit_object.setRotation(playerZone[color].playZoneRot)
					elseif master.isSuperPower==true or master.isManeuver==true or master.isTechnique==true or master.isSpecial==true or master.isSpell==true then
						entry.hit_object.setPositionSmooth(playerZone[color].discardSP.getPosition())
						entry.hit_object.setRotation(playerZone[color].playZoneRot)
					elseif master.isEquipment==true or master.isArtifact==true or master.isTreasure==true then
						entry.hit_object.setPositionSmooth(playerZone[color].discardE.getPosition())
						entry.hit_object.setRotation(playerZone[color].playZoneRot)
					elseif master.isStarter==true then
						entry.hit_object.setPositionSmooth(playerZone[color].discardS.getPosition())
						entry.hit_object.setRotation(playerZone[color].playZoneRot)
					else
						entry.hit_object.setPositionSmooth(playerZone[color].discardO.getPosition())
						entry.hit_object.setRotation(playerZone[color].playZoneRot)
					end
                end
            end
            wait(1)
            return 1
        end
        startLuaCoroutine(Global, "findCardsCo")
    end
end
function setupGameButtons() --Game Button Set Up
	objScripts_Score.call("buttons_Default")
	getObjectFromGUID('887020').createButton({rotation={0,180,0}, position={1.15,0,0.4}, font_size=75, label="Surge Topo", width=500, height=200, color={0.5, 0.5, 0.5}, font_color={1,1,1}, click_function='surgeFromTopMainDeck'})
    getObjectFromGUID('887020').createButton({rotation={0,180,0}, position={1.15,-0,0}, font_size=125, label="Add 1", width=500, height=200, color={0.5, 0.5, 0.5}, font_color={1,1,1}, click_function='addOneCardToLineup'})
	getObjectFromGUID('887020').createButton({rotation={0,180,0}, position={1.15,0,-0.4}, font_size=75, label="Surge Fundo", width=500, height=200, color={0.5, 0.5, 0.5}, font_color={1,1,1}, click_function='surgeFromBottomMainDeck'})
	--TEST BUTTON
	--getObjectFromGUID('887020').createButton({rotation={0,180,0}, position={1,0,-0.75}, font_size=120, label="Test", width=400, height=200, color={1,1,1,}, click_function='displayRemainingBossValue'})
end

function shuffleMainDeck() --Shuffle Main Deck
    local objectsInZone = zTable.zMainDeck.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			object.shuffle()
			break
		end
	end
end
function shuffleCrisisStack() --Shuffle Crisis Stack
    local objectsInZone = zTable.zCrisisStack.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			object.shuffle()
			break
		end
	end
end
function shuffleWeaknessStack()
    local objectsInZone = zTable.zWeaknessStack.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			object.shuffle()
			break
		end
	end
end
function shuffleOther1Stack()
    local objectsInZone = zTable.zOther1.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			object.shuffle()
			break
		end
	end
end

--************************Player Board************************--

function playerBoardClicked(player, valueOrClickType, id,) -- Clicking anything on Player Boards
	if player.color ~= "Grey" then
		local colorWhoClicked = player.color
		local currentZone
		local checkMatch
		if string.sub(id, 1, 3) == "Whi" then
			currentZone = playerBoardZones["White"].zone
			checkMatch = "White"
		elseif string.sub(id, 1, 3) == "Red" then
			currentZone = playerBoardZones["Red"].zone
			checkMatch = "Red"
		elseif string.sub(id, 1, 3) == "Gre" then
			currentZone = playerBoardZones["Green"].zone
			checkMatch = "Green"
		elseif string.sub(id, 1, 3) == "Yel" then
			currentZone = playerBoardZones["Yellow"].zone
			checkMatch = "Yellow"
		elseif string.sub(id, 1, 3) == "Bro" then
			currentZone = playerBoardZones["Brown"].zone
			checkMatch = "Brown"
		elseif string.sub(id, 1, 3) == "Pur" then
			currentZone = playerBoardZones["Purple"].zone
			checkMatch = "Purple"
		elseif string.sub(id, 1, 3) == "Ora" then
			currentZone = playerBoardZones["Orange"].zone
			checkMatch = "Orange"
		elseif string.sub(id, 1, 3) == "Pin" then
			currentZone = playerBoardZones["Pink"].zone
			checkMatch = "Pink"
		end
		local name = Player[player.color].steam_name
		if checkMatch == colorWhoClicked then
			for k, v in ipairs(playerBoardStats[colorWhoClicked]) do
				if id == v.uiNumberID then
					if valueOrClickType == "-1" then
						if playerBoardStats[colorWhoClicked][k].uiValue == playerBoardStats[colorWhoClicked][k].uiLimit then
							printToAll(name .. " tried to raise their " .. playerBoardStats[colorWhoClicked][k].uiName .. ". Though currently it's at max.")
						else
							printToAll(name .. " raised their " .. playerBoardStats[colorWhoClicked][k].uiName .. " from " .. playerBoardStats[colorWhoClicked][k].uiValue .. " to " .. playerBoardStats[colorWhoClicked][k].uiValue+1)
							playerBoardStats[colorWhoClicked][k].uiValue = playerBoardStats[colorWhoClicked][k].uiValue + 1
							currentZone.UI.setAttribute(playerBoardStats[colorWhoClicked][k].uiNumberID, "text", playerBoardStats[colorWhoClicked][k].uiValue)
							currentZone.UI.setAttribute(playerBoardStats[colorWhoClicked][k].uiNumberID, "textColor", "#FFFFFF")
						end
					elseif valueOrClickType == "-2" then
						if playerBoardStats[colorWhoClicked][k].uiValue == 0 then
							printToAll(name .. " tried lowered their " .. playerBoardStats[colorWhoClicked][k].uiName .. ". However, you can't have negative " .. playerBoardStats[colorWhoClicked][k].uiName)
							playerBoardStats[colorWhoClicked][k].uiValue = 0
						else
							printToAll(name .. " lowered their " .. playerBoardStats[colorWhoClicked][k].uiName .. " from " .. playerBoardStats[colorWhoClicked][k].uiValue .. " to " .. playerBoardStats[colorWhoClicked][k].uiValue-1)
							playerBoardStats[colorWhoClicked][k].uiValue = playerBoardStats[colorWhoClicked][k].uiValue - 1
							currentZone.UI.setAttribute(playerBoardStats[colorWhoClicked][k].uiNumberID, "text", playerBoardStats[colorWhoClicked][k].uiValue)
							currentZone.UI.setAttribute(playerBoardStats[colorWhoClicked][k].uiNumberID, "textColor", "#FFFFFF")
						end
					elseif valueOrClickType == "-3" then
						local staticStats = {20, 0, 0, 0, 0}
						printToAll(name .. " reset their " .. playerBoardStats[colorWhoClicked][k].uiName .. " from " .. playerBoardStats[colorWhoClicked][k].uiValue .. " to " .. staticStats[k])
						playerBoardStats[colorWhoClicked][k].uiValue = staticStats[k]
						currentZone.UI.setAttribute(playerBoardStats[colorWhoClicked][k].uiNumberID, "text", playerBoardStats[colorWhoClicked][k].uiValue)
						currentZone.UI.setAttribute(playerBoardStats[colorWhoClicked][k].uiNumberID, "textColor", "#FFFFFF")
					end
				end
			end
		else
			for k, v in ipairs(playerBoardStats[checkMatch]) do
				if id == v.uiNumberID then
					if valueOrClickType == "-1" then
						if playerBoardStats[checkMatch][k].uiValue == playerBoardStats[checkMatch][k].uiLimit then
							printToAll(name .. " tried to raise " .. checkMatch .. "'s " .. playerBoardStats[checkMatch][k].uiName .. ". Though currently it's at max.")
						else
							printToAll(name .. " raised " .. checkMatch .. "'s " .. playerBoardStats[checkMatch][k].uiName .. " from " .. playerBoardStats[checkMatch][k].uiValue .. " to " .. playerBoardStats[checkMatch][k].uiValue+1)
							playerBoardStats[checkMatch][k].uiValue = playerBoardStats[checkMatch][k].uiValue + 1
							currentZone.UI.setAttribute(playerBoardStats[checkMatch][k].uiNumberID, "text", playerBoardStats[checkMatch][k].uiValue)
							currentZone.UI.setAttribute(playerBoardStats[checkMatch][k].uiNumberID, "textColor", "#FFFFFF")
						end
					elseif valueOrClickType == "-2" then
						if playerBoardStats[checkMatch][k].uiValue == 0 then
							printToAll(name .. " tried lowered " .. checkMatch .. "'s " .. playerBoardStats[checkMatch][k].uiName .. ". However, players can't have negative " .. playerBoardStats[checkMatch][k].uiName)
							playerBoardStats[checkMatch][k].uiValue = 0
						else
							printToAll(name .. " lowered " .. checkMatch .. "'s ".. playerBoardStats[checkMatch][k].uiName .. " from " .. playerBoardStats[checkMatch][k].uiValue .. " to " .. playerBoardStats[checkMatch][k].uiValue-1)
							playerBoardStats[checkMatch][k].uiValue = playerBoardStats[checkMatch][k].uiValue - 1
							currentZone.UI.setAttribute(playerBoardStats[checkMatch][k].uiNumberID, "text", playerBoardStats[checkMatch][k].uiValue)
							currentZone.UI.setAttribute(playerBoardStats[checkMatch][k].uiNumberID, "textColor", "#FFFFFF")
						end
					elseif valueOrClickType == "-3" then
						local staticStats = {20, 0, 0, 0, 0}
						printToAll(name .. " reset " .. checkMatch .. "'s " .. playerBoardStats[checkMatch][k].uiName .. " from " .. playerBoardStats[checkMatch][k].uiValue .. " to " .. staticStats[k])
						playerBoardStats[checkMatch][k].uiValue = staticStats[k]
						currentZone.UI.setAttribute(playerBoardStats[checkMatch][k].uiNumberID, "text", playerBoardStats[checkMatch][k].uiValue)
						currentZone.UI.setAttribute(playerBoardStats[checkMatch][k].uiNumberID, "textColor", "#FFFFFF")
					end
				end
			end
		end
	end
end
function playerBoardEnable() -- Enables Active Player Boards
	playerBoardOptions()
	local currentPlayers = getSeatedPlayers()
	for i, color in ipairs(currentPlayers) do
		local currentZone = playerBoardZones[color].zone
		for n, list in ipairs(playerBoardStats[color]) do
			currentZone.UI.setAttribute(playerBoardStats[color][n].uiTextID, "active", playerBoardStats[color][n].uiActive)
			currentZone.UI.setAttribute(playerBoardStats[color][n].uiNumberID, "active", playerBoardStats[color][n].uiActive)
			currentZone.UI.setAttribute(playerBoardStats[color][n].uiNumberID, "text", playerBoardStats[color][n].uiValue)
			currentZone.UI.setAttribute(playerBoardStats[color][n].uiNumberID, "textColor", "#FFFFFF")
		end
	end
end
function playerBoardDisabled() -- Disables all Player Boards
	local disableColor = {"White", "Red", "Green", "Yellow", "Brown", "Purple", "Orange", "Pink",}
	for i, color in ipairs(disableColor) do
		local currentZone = playerBoardZones[color].zone
		for n, list in ipairs(playerBoardStats[color]) do
			playerBoardStats[color][n].uiActive = false
			currentZone.UI.setAttribute(playerBoardStats[color][n].uiTextID, "active", false)
			currentZone.UI.setAttribute(playerBoardStats[color][n].uiNumberID, "active", false)
		end
	end
end
function playerBoardOptions() -- Reset values to Correct Values
	local statToCheck = {"Health", "Meter", "Power", "Move", "Chakara"}
	for i, v in ipairs(statToCheck) do
		playerBoardCheckColors(statToCheck[i])
	end
end
function playerBoardPrepareSection(player, nothing, id) -- Toggle Buttons / Game Mode Value Change
	if player.color ~= "Grey" then
		if playerBoardStats[id].status == true then
			playerBoardStats[id].status = false
			self.UI.setAttribute(id, "isOn", "false")
			
		else
			playerBoardStats[id].status = true
			self.UI.setAttribute(id, "isOn", "true")
		end
		playerBoardDisabled()
		playerBoardCheckColors(id)
		playerBoardEnable()
	end
end
function playerBoardCheckColors(statToCheck) -- Applies Correct Values
	local checkColors = {"White", "Red", "Green", "Yellow", "Brown", "Purple", "Orange", "Pink",}
	for i, color in ipairs(checkColors) do
		local currentZone = playerBoardZones[color].zone
		for n, list in ipairs(playerBoardStats[color]) do
			if playerBoardStats[color][n].uiName == statToCheck then
				playerBoardStats[color][n].uiActive = playerBoardStats[statToCheck].status
			end
		end
	end
end
function playerBoardQuickEnable(statToEnable)
	playerBoardStats[statToEnable].status = true
	self.UI.setAttribute(statToEnable, "isOn", "true")
	playerBoardDisabled()
	playerBoardEnable() 
end
--************************Boss Setup************************--

function bossCountSetup()
	if dcdbCubeGame ~= 1 then
		for i, data in pairs(bossZoneTable) do
			if _G['boss'..data.level..'Value'] > 0 then
				getObjectFromGUID(bossZoneTable[i].guid).createButton({label=tonumber(_G['boss'..data.level..'Value']), click_function="none", position={0,0.1,1.5}, rotation={0,180,0}, height=250, width=550, font_size=240})
				getObjectFromGUID(bossZoneTable[i].guid).createButton({label="-", click_function="subBoss"..data.level.."Count", position={0.3,0.1,1}, rotation={0,180,0}, height=250, width=250, font_size=280})
				getObjectFromGUID(bossZoneTable[i].guid).createButton({label="+", click_function="addBoss"..data.level.."Count", position={-0.3,0.1,1}, rotation={0,180,0}, height=250, width=250, font_size=280})
			end
		end
	end
	--If the values combined are > 0, then create the button to setup the boss stack
	if quickSetup == 1 then
		if boss1Value + boss2Value + boss3Value + boss4Value + boss5Value > 0 then
			Wait.frames(createBossButton, 30)
		end
	elseif quickSetup == 2 then
		createSpecialDCSetupButton()
	elseif quickSetup == 3 then
		createSpecialOtherSetupButton()
	elseif quickSetup == 4 then
		createSpecialESWSetupButton()
	elseif quickSetup == 10 then
		for i, data in pairs(bossZoneTable) do
			getObjectFromGUID(bossZoneTable[i].guid).createButton({label=tonumber(_G['boss'..data.level..'Value']), click_function="none", position={0,0.1,1.5}, rotation={0,180,0}, height=250, width=550, font_size=240})
			getObjectFromGUID(bossZoneTable[i].guid).createButton({label="-", click_function="subBoss"..data.level.."Count", position={0.3,0.1,1}, rotation={0,180,0}, height=250, width=250, font_size=280})
			getObjectFromGUID(bossZoneTable[i].guid).createButton({label="+", click_function="addBoss"..data.level.."Count", position={-0.3,0.1,1}, rotation={0,180,0}, height=250, width=250, font_size=280})
		end
		Wait.frames(createCustomSetupButton, 30)
	end
end
function addBoss1Count(buttonObj) --Boss 1 Slot
    updateBoss1(1, buttonObj)
end
function subBoss1Count(buttonObj)
    updateBoss1(-1, buttonObj)
end
function updateBoss1(increment, buttonObj)
	boss1Value = boss1Value + increment
	local objectsInZone = zTable.zBoss1.getObjects()
	if boss1Value < 0 then
		boss1Value = 0
	end
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			if boss1Value > object.getQuantity() then
				boss1Value = object.getQuantity()
			end
		elseif object.type == "Card" then
			if boss1Value > 1 then
				boss1Value = 1
			end
		end
	end
    buttonObj.editButton({index=0, label=tonumber(boss1Value)})
end
function addBoss2Count(buttonObj) --Boss 2 Slot
    updateBoss2(1, buttonObj)
end
function subBoss2Count(buttonObj)
    updateBoss2(-1, buttonObj)
end
function updateBoss2(increment, buttonObj)
	boss2Value = boss2Value + increment
	local objectsInZone = zTable.zBoss2.getObjects()
	if boss2Value < 0 then
		boss2Value = 0
	end
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			if boss2Value > object.getQuantity() then
				boss2Value = object.getQuantity()
			end
		elseif object.type == "Card" then
			if boss2Value > 1 then
				boss2Value = 1
			end
		end
	end
    buttonObj.editButton({index=0, label=tonumber(boss2Value)})
end
function addBoss3Count(buttonObj) --Boss 3 Slot
    updateBoss3(1, buttonObj)
end
function subBoss3Count(buttonObj)
    updateBoss3(-1, buttonObj)
end
function updateBoss3(increment, buttonObj)
	boss3Value = boss3Value + increment
	local objectsInZone = zTable.zBoss3.getObjects()
	if boss3Value < 0 then
		boss3Value = 0
	end
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			if boss3Value > object.getQuantity() then
				boss3Value = object.getQuantity()
			end
		elseif object.type == "Card" then
			if boss3Value > 1 then
				boss3Value = 1
			end
		end
	end
    buttonObj.editButton({index=0, label=tonumber(boss3Value)})
end
function addBoss4Count(buttonObj) --Boss 4 Slot
    updateBoss4(1, buttonObj)
end
function subBoss4Count(buttonObj)
    updateBoss4(-1, buttonObj)
end
function updateBoss4(increment, buttonObj)
	boss4Value = boss4Value + increment
	local objectsInZone = zTable.zBoss4.getObjects()
	if boss4Value < 0 then
		boss4Value = 0
	end
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			if boss4Value > object.getQuantity() then
				boss4Value = object.getQuantity()
			end
		elseif object.type == "Card" then
			if boss4Value > 1 then
				boss4Value = 1
			end
		end
	end
    buttonObj.editButton({index=0, label=tonumber(boss4Value)})
end
function addBoss5Count(buttonObj) --Boss 5 Slot
    updateBoss5(1, buttonObj)
end
function subBoss5Count(buttonObj)
    updateBoss5(-1, buttonObj)
end
function updateBoss5(increment, buttonObj)
	boss5Value = boss5Value + increment
	local objectsInZone = zTable.zBoss5.getObjects()
	if boss5Value < 0 then
		boss5Value = 0
	end
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			if boss5Value > object.getQuantity() then
				boss5Value = object.getQuantity()
			end
		elseif object.type == "Card" then
			if boss5Value > 1 then
				boss5Value = 1
			end
		end
	end
    buttonObj.editButton({index=0, label=tonumber(boss5Value)})
end
function addDWTCount(buttonObj) --Boss 5 Slot
    updateDWT(1, buttonObj)
end
function subDWTCount(buttonObj)
    updateDWT(-1, buttonObj)
end
function updateDWT(increment, buttonObj)
	dwtValue = dwtValue + increment
    buttonObj.editButton({index=0, label=tonumber(dwtValue)})
end
function createBossButton() --Default Setup Game button
    getObjectFromGUID('0617c6').createButton({label="Set up\nBoss Stack", click_function="setupBossStack", position={0,0.1,-1.1}, rotation={0,180,0}, height=350, width=1000, font_size=130})
end
function createCubeBoss() --Cube Boss button
    getObjectFromGUID('0617c6').createButton({label="Set up\nBoss Stack", click_function="findCostNewDCDB", position={0,0.1,-1.1}, rotation={0,180,0}, height=350, width=1000, font_size=130})
end
function createSpecialDCSetupButton() --Special Setup Game button
	getObjectFromGUID('0617c6').createButton({label="Set up\nGame", click_function="setupSpecialDCSetupStack", position={0,0.1,-1.1}, rotation={0,180,0}, height=350, width=1000, font_size=130})
end
function createSpecialOtherSetupButton() --Special Setup Game button
	getObjectFromGUID('0617c6').createButton({label="Set up\nGame", click_function="setupSpecialOtherSetupStack", position={0,0.1,-1.1}, rotation={0,180,0}, height=350, width=1000, font_size=130})
end
function createSpecialESWSetupButton() --Special Setup Game button
	dwtValue = 4*#getSeatedPlayers()
	getObjectFromGUID('0617c6').createButton({label="Set up\nGame", click_function="setupSpecialESWSetupStack", position={0,0.1,-1.1}, rotation={0,180,0}, height=350, width=1000, font_size=130})
	Wait.frames(createDWTsetupButtons, 120)
end
function createDWTsetupButtons()
	getObjectFromGUID('a390af').createButton({label=tonumber(_G["dwtValue"]), click_function="none", position={7,1,-5}, rotation={0,0,0}, height=750, width=1000, font_size=800})
	getObjectFromGUID('a390af').createButton({label="Dead Wizard\nTokens", click_function="setupSpecialESWSetupStack", position={7,1,5.-7}, rotation={0,0,0}, height=1600, width=2800, font_size=500})
	getObjectFromGUID('a390af').createButton({label="-", click_function="subDWTCount", position={5,1,-5}, rotation={0,0,0}, height=750, width=800, font_size=800})
	getObjectFromGUID('a390af').createButton({label="+", click_function="addDWTCount", position={9,1,-5}, rotation={0,0,0}, height=750, width=800, font_size=800})
end
function createDWTCustomButtons()
	getObjectFromGUID('a390af').createButton({label=tonumber(_G["dwtValue"]), click_function="none", position={7,1,-5}, rotation={0,0,0}, height=750, width=1000, font_size=800})
	getObjectFromGUID('a390af').createButton({label="Dead Wizard\nTokens", click_function="setupCustomSetupStack", position={7,1,5.-7}, rotation={0,0,0}, height=1600, width=2800, font_size=500})
	getObjectFromGUID('a390af').createButton({label="-", click_function="subDWTCount", position={5,1,-5}, rotation={0,0,0}, height=750, width=800, font_size=800})
	getObjectFromGUID('a390af').createButton({label="+", click_function="addDWTCount", position={9,1,-5}, rotation={0,0,0}, height=750, width=800, font_size=800})
end
function createCustomSetupButton() --Special Setup Game button
	getObjectFromGUID('0617c6').createButton({label="Set up\nGame", click_function="setupCustomSetupStack", position={0,0.1,-1.1}, rotation={0,180,0}, height=350, width=1000, font_size=130})
end
--Boss Stack Set Up
function setupBossStack() -- Default Set up Boss Stack
	--Set the game clock
    mainClock.setValue(3600)
    --Clear the bossZone Buttons
    for i, data in pairs(bossZoneTable) do
        getObjectFromGUID(bossZoneTable[i].guid).clearButtons()
    end
	shuffleMainDeck()
	moveCardsToBossStack()
	Wait.frames(bossOrganize, 500)
    Wait.frames(moveCardstoRemoveZone, 500) -- wait for 4 seconds to work
end
function setupSpecialDCSetupStack() --Game Setup Crisis, Crossover, & Multiverse
	--Set the game clock
    mainClock.setValue(3600)
    mainClock.Clock.pauseStart()
    --Clear the bossZone Buttons
    for i, data in pairs(bossZoneTable) do
        getObjectFromGUID(bossZoneTable[i].guid).clearButtons()
    end
	splitMainDeck()
	Wait.frames(restoreMainDeck, 240)
	if specialSetUp ~= "Multiverse" then
		moveCardsToBossStack()
		Wait.frames(bossOrganize, 500)
		Wait.frames(moveCardstoRemoveZone, 500) -- wait for 2.5 seconds to work
	end
	if specialSetUp == "CrisisWS" then
		local crisis2Value = boss1Value + boss2Value + boss3Value - 1
		moveCrisistoCrisisZone(crisis2Value)
	elseif specialSetUp == "Watchmen" then
		local deal1 = zTable.zBoss4.getObjects()
		local deal2 = zTable.zBoss5.getObjects()
		for k,v in pairs (deal1) do -- Loop Start for Objects found
            if v.type  == "Deck" then -- if type ged as a Deck
				v.shuffle() -- Shuffle to randomize selection
				v.deal(1)
			end
		end
		for k,v in pairs (deal2) do -- Loop Start for Objects found
            if v.type  == "Deck" then -- if type ged as a Deck
				v.shuffle() -- Shuffle to randomize selection
				v.deal(1)
			end
		end
	elseif specialSetUp == "Multiverse" then
		listofdecksMultiverse = {
    	{deck=getObjectFromGUID("78bd33"), buttonID ="mvDC"}, {deck=getObjectFromGUID("f88cb0"), buttonID ="mvHU"},
		{deck=getObjectFromGUID("0ae6b3"), buttonID ="mvFE"}, {deck=getObjectFromGUID("71a06e"), buttonID ="mvTT"},
		{deck=getObjectFromGUID("1fd085"), buttonID ="mvDNM"}, {deck=getObjectFromGUID("761b5a"), buttonID ="mvINJ"},
		{deck=getObjectFromGUID("ab7f41"), buttonID ="mvC1"},{deck=getObjectFromGUID("e7ea20"), buttonID ="mvC2"},
		{deck=getObjectFromGUID("06b10a"), buttonID ="mvC3"}, {deck=getObjectFromGUID("48e13a"), buttonID ="mvC4"},
		{deck=getObjectFromGUID("02c52b"), buttonID ="mvCO1"}, {deck=getObjectFromGUID("8ddfc7"), buttonID ="mvCO2"},
		{deck=getObjectFromGUID("3263cf"), buttonID ="mvCO3"}, {deck=getObjectFromGUID("418d35"), buttonID ="mvCO4"},
		{deck=getObjectFromGUID("b482da"), buttonID ="mvCO5"}, {deck=getObjectFromGUID("cabb11"), buttonID ="mvCO6"},
		{deck=getObjectFromGUID("cf9c78"), buttonID ="mvCO7"}, {deck=getObjectFromGUID("e5123d"), buttonID ="mvCO8"},
		{deck=getObjectFromGUID("ce3e75"), buttonID ="mvCO9"},
		{deck=getObjectFromGUID("5d21bb"), buttonID ="mvR1"}, {deck=getObjectFromGUID("fcf746"), buttonID ="mvR2"},
		{deck=getObjectFromGUID("ee8008"), buttonID ="mvR3"}, {deck=getObjectFromGUID("29ec36"), buttonID ="mvRC"},
		{deck=getObjectFromGUID("18b2df"), buttonID ="mvRB"},
		{deck=getObjectFromGUID("43f00a"), buttonID ="mvTTG"},
		}
		--Inserting Deck into God Table
		for i, v in ipairs(listofdecksMultiverse) do
			for j, k in ipairs(menuToggleSetOptions) do
				if v.buttonID == k.mvID then
					if k.mvValue == false then
						menuToggleSetOptions[j].mvDeck = v.deck
					end
				end
			end
		end
		local locationMultiverse = getObjectFromGUID("f621ac")
		local listofMultiverseItems = {
		champ1 = zTable.zBoss2.getObjects(), champ2 = zTable.zBoss3.getObjects(), champ3 = zTable.zBoss4.getObjects(),
		convergence = zTable.zBoss1.getObjects() , events = zTable.zBoss5.getObjects(),
		heroes = zTable.zCharacter.getObjects(), multiverse = locationMultiverse.getObjects(),
		randomizers = zTable.zOther2.getObjects(),
		}
		shuffleMultiverse()
		for key, value in pairs(listofMultiverseItems) do
			for foundguid, founddeck in pairs(value) do
				if founddeck.type  == "Deck" then
					function mvPauseShuffle()
						founddeck.shuffle()
						wait(0.3)
						founddeck.shuffle()
						if key == "champ1" or key == "champ2" or key == "champ3" or key == "multiverse" then
							founddeck.deal(1)
							if key == "multiverse" then
								wait(0.3)
								founddeck.setPosition({0, 1, -39})
							end
						elseif key == "heroes" then
							wait(0.3)
							founddeck.deal(3)
							if multiverseImageRep == "DNM" then
								printToAll("Select one [b]Character[/b], The other two will be [FFFFFF][b]Captured[/b][FF0000]  by  [000000][b]The Batman Who Laugh[/b]")
							else
								printToAll("Select one [b]Character[/b], The other two place back in the [b]Character Pile[/b]")
							end
						elseif key == "events" then
							founddeck.setPosition({-8.76, 1.5, -4.75})
						elseif key == "randomizers" then
							--Takes a Certain Card out of a Deck
							local cardsInDeck = founddeck.getObjects()
							for j, card in ipairs(cardsInDeck) do
								local master = objScripts_Score.getTable("masterCardTable")[card.nickname]
								local cardGuide = card.guid
								local params = {position = destroyPileZone.rfgZone.getPosition(), guid = cardGuide}
								for h, core in ipairs(menuToggleSetOptions) do
									if card.nickname == core.mvRep then
										if core.mvValue == true then
											founddeck.takeObject(params)
											break
										elseif core.mvPicked == true then
											founddeck.takeObject(params)
											break
										end
									end
								end
							end
							founddeck.shuffle()
						end
						return 1
					end
					startLuaCoroutine(Global, "mvPauseShuffle")
				elseif founddeck.type  == "Card" then
					founddeck.setPosition({-8.76, 5, -4.75})
				end
			end
		end
		if menuToggleExtras.mvAddCrisis == true then
			local eventCrisis = zTable.zCrisisStack.getObjects()
			for key, value in ipairs (eventCrisis) do
				if value.type  == "Deck" then
					value.shuffle()
					value.takeObject({position={8.49, 10, 4.75}})
					value.setPosition(destroyPileZone.rfgZone.getPosition())
				end
			end
		end
		zTable.zOther2.createButton({rotation={0,180,0}, position={2.25,0,0}, label="New Event\nLine-Up", width=500, height=280, click_function='grabRandomizer'})
		readyMultiverse = true
		Wait.frames(moveCardstoRemoveZone, 240)
	end
end
function setupSpecialOtherSetupStack() --Game Setup for Games that require other sets or Extra Work
	--Set the game clock
    mainClock.setValue(3600)
    mainClock.Clock.pauseStart()
    --Clear the bossZone Buttons
    for i, data in pairs(bossZoneTable) do
        getObjectFromGUID(bossZoneTable[i].guid).clearButtons()
    end
	if specialSetUp ~= "Unexpected" and specialSetUp ~= "Smaug" then
		moveCardsToBossStack()
		Wait.frames(bossOrganize, 500)
		Wait.frames(moveCardstoRemoveZone, 500) -- wait for 2.5 seconds to work
	end
	if specialSetUp == "T2T" then
		tempInZone = zTable.zOther1
		getCurrentDeck()
		shuffleMainDeck()
		if currentDeck ~= nil then
			currentDeck.shuffle()
			function moveWall2Boss()
				wait(2.5)
				tempWallDeck = currentDeck.split(5)
				tempWallDeck[1].setPosition(zTable.zBoss1.getPosition())
				tempWallDeck[1].setRotationSmooth({0, 180, 180})
				tempWallDeck[2].setPosition(zTable.zBoss2.getPosition())
				tempWallDeck[2].setRotationSmooth({0, 180, 180})
				tempWallDeck[3].setPosition(zTable.zBoss3.getPosition())
				tempWallDeck[3].setRotationSmooth({0, 180, 180})
				tempWallDeck[4].setPosition(zTable.zBoss4.getPosition())
				tempWallDeck[4].setRotationSmooth({0, 180, 180})
				tempWallDeck[5].setPosition(zTable.zBoss5.getPosition())
				tempWallDeck[5].setRotationSmooth({0, 180, 180})
				wait(0.3)
				moveWallCardstoStack()
				wait(0.3)
				moveCardstoRemoveZone()
				wallStackShuffle()
				return 1
			end
			startLuaCoroutine(Global, "moveWall2Boss")
		end
	elseif specialSetUp == "Unexpected" then
		local l1 = zTable.zBoss1.getObjects()
		local l2 = zTable.zBoss2.getObjects()
		for k,v in pairs (l1) do -- Loop Start for Objects found
			if v.type  == "Deck" then -- if type ged as a Deck
				v.shuffle() -- Shuffle to randomize selection
			end
		end
		for k,v in pairs (l2) do -- Loop Start for Objects found
			if v.type  == "Deck" then -- if type ged as a Deck
				v.shuffle() -- Shuffle to randomize selection
			end
		end
		Wait.frames(moveLootCardsToBossStack, 40)
		Wait.frames(moveCardstoBossZoneHobbit, 240)
		Wait.frames(moveCardstoRemoveZone, 360)
		shuffleMainDeck()
	elseif specialSetUp == "Smaug" then
		moveLootCardsToBossStack()
		Wait.frames(moveCardstoBossZoneHobbit, 240)
		Wait.frames(moveCardstoRemoveZone, 360)
		local objectsInZone = zTable.zOther1.getObjects()
		for i, object in ipairs(objectsInZone) do
			if object.type  == "Deck" then
				object.shuffle()
				break
			end
		end
		shuffleMainDeck()
	elseif specialSetUp == "LotR" then
		tempInZone = zTable.zOther1
		getCurrentDeck()
		shuffleMainDeck()
		if currentDeck ~= nil then
			currentDeck.shuffle()
			function moveWall2Boss()
				wait(2.5)
				tempWallDeck = currentDeck.split(5)
				tempWallDeck[1].setPosition(zTable.zBoss1.getPosition())
				tempWallDeck[1].setRotationSmooth({0, 180, 180})
				tempWallDeck[2].setPosition(zTable.zBoss2.getPosition())
				tempWallDeck[2].setRotationSmooth({0, 180, 180})
				tempWallDeck[3].setPosition(zTable.zBoss3.getPosition())
				tempWallDeck[3].setRotationSmooth({0, 180, 180})
				tempWallDeck[4].setPosition(zTable.zBoss4.getPosition())
				tempWallDeck[4].setRotationSmooth({0, 180, 180})
				tempWallDeck[5].setPosition(zTable.zBoss5.getPosition())
				tempWallDeck[5].setRotationSmooth({0, 180, 180})
				wait(0.3)
				moveWallCardstoStack{}
				wait(0.3)
				moveCardstoRemoveZone()
				wallStackShuffle()
				wait(0.3)
				boss3Value = 0
				boss5Value = 0
				tempInZone = zTable.zEventLineUp1
				local loot1 = getObjectFromGUID("b75924")
				local loot2 = getObjectFromGUID("4deecf")
				local loot4 = getObjectFromGUID("ef8b1e")
				loot1.setPosition(zTable.zBoss1.getPosition())
				loot1.setRotationSmooth({0, 180, 180})
				loot2.setPosition(zTable.zBoss2.getPosition())
				loot2.setRotationSmooth({0, 180, 180})
				loot4.setPosition(zTable.zBoss4.getPosition())
				loot4.setRotationSmooth({0, 180, 180})
				wait(0.5)
				moveCardsToBossStack()
				wait(1.5)
				turnCounter = 9999
				bossOrganize()
				wait(0.5)
				turnCounter = 0
				moveCardstoRemoveZone()
				return 1
			end
			startLuaCoroutine(Global, "moveWall2Boss")
		end
	elseif specialSetUp == "Cartoon" then
		shuffleMainDeck()
		shuffleWeaknessStack()
	elseif specialSetUp == "RickMorty" then
		shuffleMainDeck()
		shuffleOther1Stack()
	end
end
function setupSpecialESWSetupStack()
    mainClock.setValue(3600)
    mainClock.Clock.pauseStart()
	local deadWizardTokenBag
	local bagEndPoint = {}
	local x = 12.5
	local y = 3
	local z = 4.6
	bagEndPoint.position = {x, y, z}
    for i, data in pairs(bossZoneTable) do
        getObjectFromGUID(bossZoneTable[i].guid).clearButtons()
    end
	shuffleMainDeck()
	if specialSetUp == "EA1" then
		moveCardsToBossStack()
		Wait.frames(bossOrganize, 500)
		Wait.frames(moveCardstoRemoveZone, 500) -- wait for 2.5 seconds to work
		deadWizardTokenBag = getObjectFromGUID("eca763")
	elseif specialSetUp == "EA2" then
		deadWizardTokenBag = getObjectFromGUID("c13ca5")
		local objectsInZone = zTable.zEventDeck.getObjects()
		for i, object in ipairs(objectsInZone) do
			if object.type  == "Deck" then
				object.shuffle()
			break
			end
		end
	elseif specialSetUp == "EGB+EA1" then
		deadWizardTokenBag = getObjectFromGUID("eeeddb")
		local shuffleGBTreasure = zTable.zCharacter.getObjects()
		local shuffleEA1Legends = zTable.zBossStack.getObjects()
		for i, object in ipairs(shuffleGBTreasure) do
			if object.type  == "Deck" then
				object.shuffle()
			break
			end
		end
		for i, object in ipairs(shuffleEA1Legends) do
			if object.type  == "Deck" then
				object.shuffle()
			break
			end
		end
	elseif specialSetUp == "EGB+EA2" then
		deadWizardTokenBag = getObjectFromGUID("eeeddb")
		lineupEA2_Legends = true
		local shuffleGBTreasure = zTable.zCharacter.getObjects()
		local shuffleEA1Legends = zTable.zBossStack.getObjects()
		local shuffleEA2Legends = zTable.zEventDeck.getObjects()
		for i, object in ipairs(shuffleGBTreasure) do
			if object.type  == "Deck" then
				object.shuffle()
			break
			end
		end
		for i, object in ipairs(shuffleEA1Legends) do
			if object.type  == "Deck" then
				object.shuffle()
			break
			end
		end
		for i, object in ipairs(shuffleEA2Legends) do
			if object.type  == "Deck" then
				object.shuffle()
			break
			end
		end
	elseif specialSetUp == "ESW" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.imgRep == "EA1" then
				if v.bESW == true then
					moveCardsToBossStack()
					Wait.frames(bossOrganize, 250)
					Wait.frames(moveCardstoRemoveZone, 250)
				end
			end
			if v.imgRep == "EA2" then
				if v.bESW == true then
					local shuffleEA2Legends = zTable.zEventDeck.getObjects()
					for i, object in ipairs(shuffleEA2Legends) do
						if object.type  == "Deck" then
							object.shuffle()
						break
						end
					end
					lineupEA2_Legends = true
				end
			end
			if v.imgRep == "EGB" then
				if v.bESW == true then
					local shuffleGBTreasure = zTable.zCharacter.getObjects()
					for i, object in ipairs(shuffleGBTreasure) do
						if object.type  == "Deck" then
							object.shuffle()
						break
						end
					end
				end
			end
		end
		deadWizardTokenBag = getObjectFromGUID(menuToggleExtras.eswDWT)
	elseif specialSetUp == "INJ" then
		moveCardsToBossStack()
		Wait.frames(bossOrganize, 500)
		Wait.frames(moveCardstoRemoveZone, 500) -- wait for 2.5 seconds to work
		deadWizardTokenBag = getObjectFromGUID("1c64a5")
	else
		deadWizardTokenBag = getObjectFromGUID(menuToggleExtras.eswDWT)
	end
	for i=dwtValue, 1, -1 do
		deadWizardTokenBag.takeObject(bagEndPoint)
		y = y + 1
		bagEndPoint.position = {x, y, z}
	end
	getObjectFromGUID('a390af').clearButtons()
end
function setupCustomSetupStack()
	setupBossStack()
	local yesUJLoot = false
	local loot1
	local loot2
	local loot4
	function pauseCustomSetupStack()
		if menuToggleExtras.cg2TWalls == true then
			tempInZone = zTable.zOther1
			getCurrentDeck()
			if currentDeck ~= nil then
				currentDeck.shuffle()
				wait(3)
				tempWallDeck = currentDeck.split(5)
				tempWallDeck[1].setPosition(zTable.zBoss1.getPosition())
				tempWallDeck[1].setRotationSmooth({0, 180, 180})
				tempWallDeck[2].setPosition(zTable.zBoss2.getPosition())
				tempWallDeck[2].setRotationSmooth({0, 180, 180})
				tempWallDeck[3].setPosition(zTable.zBoss3.getPosition())
				tempWallDeck[3].setRotationSmooth({0, 180, 180})
				tempWallDeck[4].setPosition(zTable.zBoss4.getPosition())
				tempWallDeck[4].setRotationSmooth({0, 180, 180})
				tempWallDeck[5].setPosition(zTable.zBoss5.getPosition())
				tempWallDeck[5].setRotationSmooth({0, 180, 180})
				wait(0.3)
				moveWallCardstoStack{}
				wait(0.3)
				moveCardstoRemoveZone()
				wallStackShuffle()
				wait(0.3)
			end
		end
		wait(3)
		for i, v in ipairs(menuToggleSetOptions) do
			if v.imgRep == "UJ" then
				if v.cgBoss == true or v.cgIM == true then
					boss3Value = 0
					boss5Value = 0
					if boss1Value >= 4 then
						boss1Value = 4
					end
					if boss2Value >= 4 then
						boss2Value = 4
					end
					yesUJLoot = true
					local loot1 = getObjectFromGUID("b75924")
					local loot2 = getObjectFromGUID("4deecf")
					loot1.setPosition(zTable.zBoss1.getPosition())
					loot1.setRotationSmooth({0, 180, 180})
					loot1.shuffle()
					loot2.setPosition(zTable.zBoss2.getPosition())
					loot2.setRotationSmooth({0, 180, 180})
					loot2.shuffle()
				end
			elseif v.imgRep == "DoS" then
				if v.cgBoss == true or v.cgIM == true then
					if yesUJLoot == false then
						boss1Value = 0
						boss2Value = 0
						boss3Value = 0
						boss5Value = 0
					end
					if boss4Value >= 4 then
						boss4Value = 4
					end
					local loot4 = getObjectFromGUID("ef8b1e")
					loot4.setPosition(zTable.zBoss4.getPosition())
					loot4.setRotationSmooth({0, 180, 180})
					loot4.shuffle()
					specialSetUp = "LotR"
					yesUJLoot = true
				else
					boss4Value = 0
				end
			elseif v.imgRep == "EGB" then
				if v.cgBoss == true then
					local shuffleGBTreasure = zTable.zCharacter.getObjects()
					for i, object in ipairs(shuffleGBTreasure) do
						if object.type  == "Deck" then
							object.shuffle()
						break
						end
					end
				end
			elseif v.imgRep == "EA2" then
				if v.cgBoss == true then
					local shuffleEA2Legends = zTable.zEventDeck.getObjects()
					lineupEA2_Legends = true
					for i, object in ipairs(shuffleEA2Legends) do
						if object.type  == "Deck" then
							object.shuffle()
						break
						end
					end
				end
			end
		end
		wait(5)
		if yesUJLoot == true then
			moveCardsToBossStack()
			wait(3)
			turnCounter = 6969
			bossOrganize()
			wait(0.5)
			turnCounter = 0
			moveCardstoRemoveZone()
		end
		wait(3)
		if menuToggleExtras.cgSplitLocations == true then --[[Example: Certain Card out of Deck]]--
			printToAll("Setting Up Location Deck, Portal Guns choosen as Kicks...")
			local LagFest = zTable.zMainDeck.getObjects() -- grab objects in a scripted zone
			for _, founddeck in ipairs(LagFest) do
				if founddeck.type == "Deck" then -- if object found is a deck
					local deck = founddeck -- local assign
					local cardsInDeck = deck.getObjects() --grabbing cards in object
					local LocationY = 1.5 -- local Height when dropped off
					for j = #cardsInDeck, 1, -1 do -- J = cardsInDeck Count, starts at Top, -1 in each loop
						local card = cardsInDeck[j]
						local master = objScripts_Score.getTable("masterCardTable")[card.nickname]
						if master.isLocation == true then
							local cardGuide = card.index -- Grabs In
							--printToAll(card.index) -- debug
							local params = {position = {-8.76, LocationY, 4.75}, rotation = {0,180,180}, index = cardGuide, smooth=false}
							founddeck.takeObject(params) -- take object from deck
							LocationY = LocationY + 0.5 -- raise the Y axis
						end
					end
				end
			end
			wait(8)
			shuffleMainDeck()
			shuffleOther1Stack()
			printToAll("Location Deck has been made.")
		end
		wait(3)
		if dwtValue > 0 then
			local deadWizardTokenBag
			local bagEndPoint = {}
			local x = 12.5
			local y = 3
			local z = 4.6
			bagEndPoint.position = {x, y, z}
			deadWizardTokenBag = getObjectFromGUID(menuToggleExtras.eswDWT)
			for i=dwtValue, 1, -1 do
				deadWizardTokenBag.takeObject(bagEndPoint)
				y = y + 1
				bagEndPoint.position = {x, y, z}
			end
			getObjectFromGUID('a390af').clearButtons()
			specialSetUp = "EA2"

		end
		return 1
	end
	startLuaCoroutine(Global, "pauseCustomSetupStack")
end
function moveCrisistoCrisisZone(value)
	local firstCrisis = zTable.zBoss4.getObjects()
	for k,v in pairs (firstCrisis) do -- Loop Start for Objects found
		if v.type  == "Card" then -- if type ged as a card
			v.setPosition({8.49,20,4.75})
            v.setRotation({0,180,0})
		end
	end
    if value > 0 then -- If bossZoneValue is 1, sort Bosses
        local zone = zTable.zBoss5 -- Local to See Objects from Script Zone
        local objInZone = zone.getObjects() -- Another Local needed to Grab Objects from Zone
        for k,v in pairs (objInZone) do -- Loop Start for Objects found
            if v.type  == "Deck" then -- if type ged as a Deck
				v.shuffle() -- Shuffle to randomize selection
                for j=1, value do -- Don't think j needs to be assigned, yAxis+1 should work
                    v.takeObject({position={8.49,2,4.75}, rotation={0,180,180}}) -- Takes top of Deck, places it in position
                end
            elseif v.type  == "Card" then -- if type ged as a card
                if value > 1 then  -- Error message for not enough cards
                    printToAll("Error: Only one card in slot.")
                else -- Else just move in place
                    v.setPosition({8.49,2,4.75})
                    v.setRotation({0,180,180})
                end
            end
        end
    end
end
function moveCardsToBossStack()
    for i=5, 1, -1 do -- I don't understand this
        local value = _G['boss'..i..'Value'] -- Value now set to match BossZoneValue to pick number of cards
        if value > 0 then -- If bossZoneValue is 1, sort Bosses
            local zone = getObjectFromGUID(bossZoneTable[i].guid) -- Local to See Objects from Script Zone
            local objInZone = zone.getObjects() -- Another Local needed to Grab Objects from Zone
            for k,v in pairs (objInZone) do -- Loop Start for Objects found
                if v.type  == "Deck" then -- if type ged as a Deck
					v.shuffle() -- Shuffle to randomize selection
                    for j=1, value do -- Don't think j needs to be assigned, yAxis+1 should work
                        v.takeObject({position={1.59,2,20}, rotation={0,180,180}}) -- Takes top of Deck, places it in position
                    end
                elseif v.type  == "Card" then -- if type ged as a card
                    if value > 1 then  -- Error message for not enough cards
                        printToAll("Error: Only one card in slot.")
                    else -- Else just move in place
                        v.setPosition({1.59,2,20})
                        v.setRotation({0,180,180})
                    end
                end
            end
        end
	end
end
function moveCardstoRemoveZone() --Mostly follows moveCardsToBossStack
	for i=5, 1, -1 do
		local zone = getObjectFromGUID(bossZoneTable[i].guid)
		local objInZone = zone.getObjects()
		for k,v in pairs (objInZone) do
			if v.type  == "Deck" then
				v.setPosition(destroyPileZone.rfgZone.getPosition())
				v.setRotation({0,180,180})
			end
			if v.type  == "Card" then
				v.setPosition(destroyPileZone.rfgZone.getPosition())
				v.setRotation({0,180,180})
			end
		end
	end
end
function moveWallCardstoStack()
	local startingSeatedPlayers = #getSeatedPlayers()
	if startingSeatedPlayers >= 5 then
		for i=5, 1, -1 do
			local zone = getObjectFromGUID(bossZoneTable[i].guid)
			local objInZone = zone.getObjects()
			for k,v in pairs (objInZone) do
				if v.type  == "Deck" then
					v.setPosition({-5.31, 1.5, 4.75})
					v.setRotation({0,180,180})
				end
				if v.type  == "Card" then
					v.setPosition({-5.31, 1.5, 4.75})
					v.setRotation({0,180,180})
				end
			end
		end
	end
	if startingSeatedPlayers == 4 then
		local zone4 = getObjectFromGUID(bossZoneTable[4].guid)
		local objInZone4 = zone4.getObjects()
		for k,v in pairs (objInZone4) do
			if v.type  == "Deck" then
				v.setPosition({-5.31, 1.5, 4.75})
				v.setRotation({0,180,180})
			end
			if v.type  == "Card" then
			v.setPosition({-5.31, 1.5, 4.75})
			v.setRotation({0,180,180})
			end
		end
	end
	if startingSeatedPlayers >= 3 and startingSeatedPlayers <= 4 then
		local zone3 = getObjectFromGUID(bossZoneTable[3].guid)
		local objInZone3 = zone3.getObjects()
		for k,v in pairs (objInZone3) do
			if v.type  == "Deck" then
				v.setPosition({-5.31, 1.75, 4.75})
				v.setRotation({0,180,180})
			end
			if v.type  == "Card" then
			v.setPosition({-5.31, 1.75, 4.75})
			v.setRotation({0,180,180})
			end
		end
	end
	if startingSeatedPlayers >= 2 and startingSeatedPlayers <= 4 then
		local zone2 = getObjectFromGUID(bossZoneTable[2].guid)
		local objInZone2 = zone2.getObjects()
		for k,v in pairs (objInZone2) do
			if v.type  == "Deck" then
				v.setPosition({-5.31, 2, 4.75})
				v.setRotation({0,180,180})
			end
			if v.type  == "Card" then
			v.setPosition({-5.31, 2, 4.75})
			v.setRotation({0,180,180})
			end
		end
	end
	if startingSeatedPlayers >= 1 and startingSeatedPlayers <= 4 then
		local zone1 = getObjectFromGUID(bossZoneTable[1].guid)
		local objInZone1 = zone1.getObjects()
		for k,v in pairs (objInZone1) do
			if v.type  == "Deck" then
				v.setPosition({-5.31, 2.25, 4.75})
				v.setRotation({0,180,180})
			end
			if v.type  == "Card" then
			v.setPosition({-5.31, 2.25, 4.75})
			v.setRotation({0,180,180})
			end
		end
	end
end
function wallStackShuffle()
	local objectsInZone = zTable.zOther2.getObjects()
	for i, object in ipairs(objectsInZone) do
		if object.type  == "Deck" then
			object.shuffle()
			break
		end
	end
end
function moveLootCardsToBossStack() --The Hobbit Special Set Up
    local value1= _G['boss'.. 1 ..'Value'] -- Loot1
	local value2= _G['boss'.. 2 ..'Value'] -- Loot2
	local value3= _G['boss'.. 3 ..'Value'] -- Loot4
    if value1 > 0 then -- If bossZoneValue is 1, sort Bosses
        local zone1 = getObjectFromGUID(bossZoneTable[1].guid) -- Local to See Objects from Script Zone
        local objInZone1 = zone1.getObjects() -- Another Local needed to Grab Objects from Zone
        for k,v in pairs (objInZone1) do -- Loop Start for Objects found
            if v.type  == "Deck" then -- if type ged as a Deck
				v.shuffle() -- Shuffle to randomize selection
                for j=1, value1 do -- Don't think j needs to be assigned, yAxis+1 should work
                    v.takeObject({position={8.49,1.5,14.25}, rotation={0,180,180}}) -- Takes top of Deck, places it in position
                end
            elseif v.type  == "Card" then -- if type ged as a card
                if value1 > 1 then  -- Error message for not enough cards
                    printToAll("Error: Only one card in slot.")
                else -- Else just move in place
                    v.setPosition({8.49,1.5,14.25})
                    v.setRotation({0,180,180})
                end
            end
        end
    end
    if value2 > 0 then -- If bossZoneValue is 2, sort Bosses
        local zone2 = getObjectFromGUID(bossZoneTable[2].guid) -- Local to See Objects from Script Zone
        local objInZone2 = zone2.getObjects() -- Another Local needed to Grab Objects from Zone
        for k,v in pairs (objInZone2) do -- Loop Start for Objects found
            if v.type  == "Deck" then -- if type ged as a Deck
				v.shuffle() -- Shuffle to randomize selection
                for j=1, value2 do -- Don't think j needs to be assigned, yAxis+1 should work
                    v.takeObject({position={8.49,1.5,4.75}, rotation={0,180,180}}) -- Takes top of Deck, places it in position
                end
            elseif v.type  == "Card" then -- if type ged as a card
                if value2 > 1 then  -- Error message for not enough cards
                    printToAll("Error: Only one card in slot.")
                else -- Else just move in place
                    v.setPosition({8.49,1.5,4.75})
                    v.setRotation({0,180,180})
                end
            end
        end
    end
    if value3 > 0 then -- If bossZoneValue is 1, sort Bosses
        local zone3 = getObjectFromGUID(bossZoneTable[3].guid) -- Local to See Objects from Script Zone
        local objInZone3 = zone3.getObjects() -- Another Local needed to Grab Objects from Zone
        for k,v in pairs (objInZone3) do -- Loop Start for Objects found
            if v.type  == "Deck" then -- if type ged as a Deck
				v.shuffle() -- Shuffle to randomize selection
                for j=1, value3 do -- Don't think j needs to be assigned, yAxis+1 should work
                    v.takeObject({position={5.04,1.5,4.75}, rotation={0,180,180}}) -- Takes top of Deck, places it in position
                end
            elseif v.type  == "Card" then -- if type ged as a card
                if value3 > 1 then  -- Error message for not enough cards
                    printToAll("Error: Only one card in slot.")
                else -- Else just move in place
                    v.setPosition({5.04,1.5,4.75})
                    v.setRotation({0,180,180})
                end
            end
        end
    end
end
function moveCardstoBossZoneHobbit() --Hobbit Special Set Up
	local bossTroll = getObjectFromGUID(bossZoneTable[4].guid)
	local bossGoblin = getObjectFromGUID(bossZoneTable[5].guid)
	local bossAzog = zTable.zCrisisStack
	local bossTrollpile = bossTroll.getObjects()
	local bossGoblinpile = bossGoblin.getObjects()
	local bossAzogpile = bossAzog.getObjects()
	for k,v in pairs (bossTrollpile) do
		if v.type  == "Deck" then
				v.setPosition({5.04, 4.5, 4.75})
				v.setRotation({0,180,180})
		end
		if v.type  == "Card" then
				v.setPosition({5.04, 4.5, 4.75})
				v.setRotation({0,180,180})
		end
	end
	for k,v in pairs (bossGoblinpile) do
		if v.type  == "Deck" then
				v.setPosition({5.04, 3, 4.75})
				v.setRotation({0,180,180})
		end
		if v.type  == "Card" then
				v.setPosition({5.04, 3, 4.75})
				v.setRotation({0,180,180})
		end
	end
	for k,v in pairs (bossAzogpile) do
		if v.type  == "Deck" then
				v.setPosition({5.04, 1.5, 4.75})
				v.setRotation({0,180,180})
		end
		if v.type  == "Card" then
				v.setPosition({5.04, 1.5, 4.75})
				v.setRotation({0,180,180})
		end
	end
end
function bossOrganize()
local theBossStack = getObjectFromGUID("f621ac")
local theGameBoss = theBossStack.getObjects()
local bossTotal = boss1Value + boss2Value + boss3Value + boss4Value + boss5Value
local bossSetup = 0
local locationofBoss = {}
local costOfBoss = {}
local NameOfBoss = {}
bCount = 1
	for i, object in ipairs(theGameBoss) do
		if object.type  == "Deck" then
			local bDeck = object -- Deck Found in Scripting Zone, Assigning Cards as Variable
			local bDeckCards = bDeck.getObjects() -- Assigning Cards in Deck as Variable
			for j, card in ipairs(bDeckCards) do
				bossSetup = bossSetup + 1 -- Loop starts by Adding one to counter, will be used to move cards later
				local master = objScripts_Score.getTable("masterCardTable")[card.nickname]
				if bCount ~= bossTotal + 1 then -- We Assigned boss#Value earlier (Setting number before we ran script), now boss#Count checks to see if we match that value
					locationofBoss[bCount] = j - 1 -- Saves Location in Stack
					costOfBoss[bCount] = master.cost -- Saves Card Cost
					NameOfBoss[bCount] = card.nickname -- Saves Card Name
					bCount = bCount + 1 -- Adds to Counter to compare against boss#Value to stop loop
				end
			end
			for x = bossTotal - 1, 0, -1 do
				local params = {}
				params.index = x
				params.position = {zTable.zBossStack.getPosition().x, 26 - costOfBoss[x+1], zTable.zBossStack.getPosition().z}
				if turnCounter == 6969 then
					params.position = {16, 26 - costOfBoss[x+1], 5.5}
				elseif turnCounter == 9999 then
					params.position = {zTable.zCrisisStack.getPosition().x, 26 - costOfBoss[x+1], zTable.zCrisisStack.getPosition().z}
				end
				params.rotation = {0, 180, 180}
				local deckFound
				for i, object in ipairs(theGameBoss) do
					if object.type  == "Deck" then
						object.takeObject(params)
					end
				end
			end
		end
	end
end

--************************UI Stuff************************--

shown = { --Menu State
  quickmenu = false
}
function showForPlayer(params) --Shows UI for only the player who clicks it
  local panel = params.panel
  local color = params.color
  local opened = self.UI.getAttribute(panel, "visibility")
  if opened == nil then opened = "" end
  if opened:find(color) then
    opened = opened:gsub("|" .. color, "")
    opened = opened:gsub(color .. "|", "")
    opened = opened:gsub(color, "")
    self.UI.setAttribute(panel, "visibility", opened)
    if opened == "" then
      self.UI.setAttribute(panel, "active", "false")
      shown.quickmenu = false
    end
  else
    if shown.quickmenu == false then
      self.UI.setAttribute(panel, "active", "true")
      self.UI.setAttribute(panel, "visibility", color)
      shown.quickmenu = true
    else
      self.UI.setAttribute(panel, "visibility", opened .. "|" .. color)
    end
  end
end
function openMainUI(player, value, id) -- Game Selection Button, and Close Button
	showForPlayer({panel = "Quick Game", color = player.color})
end
function quickGamesClicked(player, value, id) --UI buttons to switch between the tabs
	--Main Menu
	local menuIDTable = {
	{id="clickDC", menu="dcGameSetup"},
	{id="clickCustomMenu", menu="customSetup"},
	{id="clickOptions", menu="optionSetup"},
	{id="clickDCExpansions", menu="expansionSetupBase"},
	{id="clickDCRivals", menu="expansionSetupRivals"},
	{id="clickMultiverse", menu="expansionSetupMultiverse"},
	{id="clickLotR", menu="expansionSetupLotR"},
	{id="clickCartoon", menu="expansionSetupCN"},
	{id="clickRickMorty", menu="expansionSetupRickMorty"},
	{id="clickESW", menu="expansionSetupESW"},
	{id="clickGangBangers", menu="expansionSetupGangBangers"},
	{id="clickFullCustom", menu="expansionCustomSetup"},
	}
	for i, v in ipairs(menuIDTable) do
		if id == v.id then
			self.UI.setAttribute(v.menu, "active", "true")
			self.UI.setAttribute(v.id, "isOn", "true")
		else
			self.UI.setAttribute(v.menu, "active", "false")
			self.UI.setAttribute(v.id, "isOn", "false")
		end
	end
	if id == "clickCustomBack" then
		self.UI.setAttribute("clickCustomBack", "isOn", "false")
		for i, v in ipairs(menuIDTable) do
			self.UI.setAttribute(v.menu, "active", "false")
			self.UI.setAttribute(v.id, "isOn", "false")
		end
		self.UI.setAttribute("clickCustomMenu", "isOn", "true")
		self.UI.setAttribute("customSetup", "active", "true")
	end
end
function dceMenuSwitch(player, value, id)
	if id == "menuMD" then
		self.UI.setAttribute("expansionMainCards", "active", "true")
		self.UI.setAttribute("expansionCharacters", "active", "false")
	elseif id == "menuC" then
		self.UI.setAttribute("expansionMainCards", "active", "false")
		self.UI.setAttribute("expansionCharacters", "active", "true")
	end
end
function updateGameChoice(player, value, id) -- DC Expansion Drop Down Menu
    self.UI.setAttribute(id, "selected", value)
	local imageBase = {
	{name ="DC Base Set", image ="DC"}, {name ="Heroes United", image ="HU"}, {name ="Forever Evil", image ="FE"},
	{name ="Teen Titans", image ="TT"}, {name ="Dark Nights Metal", image ="DNM"}, {name ="Injustice", image ="INJ"}, 
	{name ="Teen Titans Go!", image ="TTG"},
	}
	local imageExpansion = {
	{name ="Crisis 1", image ="C1"}, {name ="Crisis 2", image ="C2"}, {name ="Crisis 3", image ="C3"}, {name ="Crisis 4", image ="C4"},
	{name ="CO1 - Justice Society of America", image ="CO1"}, {name ="CO2 - Arrow The Television Series", image ="CO2"},
	{name ="CO3 - Legion of Super Heroes", image ="CO3"}, {name ="CO4 - Watchmen", image ="CO4"},
	{name ="CO5 - The Rogues", image ="CO5"}, {name ="CO6 - Birds of Prey", image ="CO6"},
	{name ="CO7 - New God", image ="CO7"}, {name ="CO8 - Batman Ninja", image ="CO8"},
	{name ="CO9 - Bombshells", image ="CO9"}
	}
	self.UI.setAttribute(value)
	for i, v in ipairs(imageBase) do
		if value == v.name then baseImageRep = v.image
		end
	end
	self.UI.setAttribute(value)
	for i, v in ipairs(imageExpansion) do
		if value == v.name then expansionImageRep = v.image
		end
	end
	updateImageChoice(value)
end
function updateGameChoiceESW(player, value, id)
    self.UI.setAttribute(id, "selected", value)
	local imageBase = {
	{name ="ANNIHILAGEDDON", image ="EA1"},
	{name ="ANNIHILAGEDDON 2 - Xtreme Nacho Legends", image ="EA2"},
	}
	self.UI.setAttribute(value)
	for i, v in ipairs(imageBase) do
		if value == v.name then expansionRepESW = v.image
		end
	end
	self.UI.setAttribute(value)
	updateImageChoice(value)
end
function customMenuSwitch(player, value, id)
	local menuCustomIDTable = {
		{menu="customCharacters", id="menuCustomCharacters"},
		{menu="customMain", id="menuCustomMain"},
		{menu="customBosses", id="menuCustomBosses"},}
	for i, v in ipairs(menuCustomIDTable) do
		if id == v.id then
			self.UI.setAttribute(v.menu, "active", "true")
			self.UI.setAttribute(v.id, "isOn", "true")
		else
			self.UI.setAttribute(v.menu, "active", "false")
			self.UI.setAttribute(v.id, "isOn", "false")
		end
	end
end
function updateMultiverseChoice(player, value, id) -- Multiverse Drop Down Menu
	local imageMultiverse = {
	{name ="DC Base Set", image ="DC"}, {name ="Heroes United", image ="HU"}, {name ="Forever Evil", image ="FE"},
	{name ="Teen Titans", image ="TT"}, {name ="Dark Nights Metal", image ="DNM"}, {name ="Injustice", image ="INJ"},
	{name ="Confrontations", image ="RC"},
	}
	self.UI.setAttribute(value)
	for i, v in ipairs(imageMultiverse) do
		if value == v.name then multiverseImageRep = v.image
		end
	end
	--Enables core set for Game Spawn
	for ii, vv in ipairs(menuToggleSetOptions) do
		if vv.mvMain == true then
			if multiverseImageRep == vv.imgRep then
				vv.mvPicked = true
				menuToggleSetOptions[ii].mvPicked = vv.mvPicked
			elseif multiverseImageRep ~= vv.imgRep then
				mvPickedSwapper = false
				menuToggleSetOptions[ii].mvPicked = mvPickedSwapper
			end
		end
	end
	updateImageChoice(value)
end
function updateImageChoice(value) -- Expansion Image Rep Changes
	self.UI.setAttribute("baseRep", "image", baseImageRep)
	self.UI.setAttribute("expansionRep", "image", expansionImageRep)
	self.UI.setAttribute("multiverseRep", "image", multiverseImageRep)
	self.UI.setAttribute("expansionRepESW", "image", expansionRepESW)
end
function changeToggleUI(player, value, id) -- Button to Reset Table
    if player.color ~= "Grey" then
		if id == "clearTableToggleNow" then
			setupFreshStart(player, value, id)
			deleteEverything()
			printToAll(player.steam_name .. " has [b]Reset[/b] the Table")
		end
    end
end
function spawnCharactersUI(player, value, id)
    if player.color ~= "Grey" then
		if id == "spawnDCCharacters" then
			spawnCharactersDC()
			printToAll(player.steam_name .. " has loaded DC Characters")
		elseif id == "spawnCrisisCharacters" then
			spawnCharactersCrisis()
			printToAll(player.steam_name .. " has loaded Crisis Characters")
		elseif id == "spawnRivalsCharacters" then
			spawnCharactersRivals()
			printToAll(player.steam_name .. " has loaded Rival Characters")
		elseif id == "spawnRebirthCharacters" then
			spawnCharactersRebirth()
			printToAll(player.steam_name .. " has loaded Rebirth Characters")
		elseif id == "spawnLotRCharacters" then
			spawnCharactersLotR()
			printToAll(player.steam_name .. " has loaded Lord of the Ring Characters")
		elseif id == "spawnCartoonCharacters" then
			spawnCharactersCartoon()
			printToAll(player.steam_name .. " has loaded Cartoon Network Characters")
		elseif id == "spawnRickandMortyCharacters" then
			spawnCharactersRickMorty()
			printToAll(player.steam_name .. " has loaded Rick & Morty Characters")
		elseif id == "spawnESWCharacters" then
			spawnCharactersESW()
			printToAll(player.steam_name .. " has loaded Epic Spell Wars of the Battle Wizards Annihilageddon Characters")
		elseif id == "spawnGangBangerCharacters" then
			spawnCharactersGangBangers()
			printToAll(player.steam_name .. " has loaded Gang Bangers")
		elseif id == "spawnOtherCharacters" then
			spawnCharactersOther()
			printToAll(player.steam_name .. ' has loaded "Other" Series Characters')
		end
    end
end
function playerNumberToggleUI(player, value, id)
    if player.color ~= "Grey" then
		if id == "4pToggle" then
			tableSize = 1
			self.UI.setAttribute("4pToggle", "isOn", "true")
			self.UI.setAttribute("8pToggle", "isOn", "false")
			if tableNumber == 3 then
                changeTable1()
			elseif tableNumber == 4 then
                changeTable2()
			end
		elseif id == "8pToggle" then
			tablesize = 2
			self.UI.setAttribute("4pToggle", "isOn", "false")
			self.UI.setAttribute("8pToggle", "isOn", "true")
			if tableNumber == 1 then
                changeTable3()
			elseif tableNumber == 2 then
                changeTable4()
			end
		end
	end
end
function optionImpossibleMode(player, value, id)
	if player.color ~= "Grey" then
		if id == "impossibleToggleON" or id == "impossibleToggleON-LotR" then
			self.UI.setAttribute("impossibleToggleON", "isOn", "true")
			self.UI.setAttribute("impossibleToggleOFF", "isOn", "false")
			self.UI.setAttribute("impossibleToggleON-LotR", "isOn", "true")
			self.UI.setAttribute("impossibleToggleOFF-LotR", "isOn", "false")
			if impossibleMode == false then
				impossibleMode = true
				printToAll(player.steam_name .. " has [00FF00][b]Enabled[/b] [FFFFFF]Impossible Mode Bosses")
			end
		elseif id == "impossibleToggleOFF" or id == "impossibleToggleOFF-LotR" then
			self.UI.setAttribute("impossibleToggleON", "isOn", "false")
			self.UI.setAttribute("impossibleToggleOFF", "isOn", "true")
			self.UI.setAttribute("impossibleToggleON-LotR", "isOn", "false")
			self.UI.setAttribute("impossibleToggleOFF-LotR", "isOn", "true")
			if impossibleMode == true then
				impossibleMode = false
				printToAll(player.steam_name .. " has [FF0000][b]Disabled[/b] [FFFFFF]Impossible Mode Bosses")
			end
		end
	end
end
function optionLineUpRefill(player, value, id)
	if player.color ~= "Grey" then
		if id == "refillToggleON" then
			self.UI.setAttribute("refillToggleON", "isOn", "true")
			self.UI.setAttribute("refillToggleOFF", "isOn", "false")
			if refill == false then
				refill = true
				printToAll(player.steam_name .. " has [00FF00][b]Enabled[/b] [FFFFFF]automatic Line-Up Refill")
			end
		elseif id == "refillToggleOFF" then
			self.UI.setAttribute("refillToggleON", "isOn", "false")
			self.UI.setAttribute("refillToggleOFF", "isOn", "true")
			if refill == true then
				refill = false
				printToAll(player.steam_name .. " has [FF0000][b]Disabled[/b] [FFFFFF]automatic Line-Up Refill")
			end
		end
	end
end
function optionNewBossFlip(player, value, id)
	if player.color ~= "Grey" then
		if id == "flipBossToggleON" then
			self.UI.setAttribute("flipBossToggleON", "isOn", "true")
			self.UI.setAttribute("flipBossToggleOFF", "isOn", "false")
			if flipBoss == false then
				flipBoss = true
				printToAll(player.steam_name .. " has [00FF00][b]Enabled[/b] [FFFFFF]automatic Boss Flipping")
			end
		elseif id == "flipBossToggleOFF" then
			self.UI.setAttribute("flipBossToggleON", "isOn", "false")
			self.UI.setAttribute("flipBossToggleOFF", "isOn", "true")
			if flipBoss == true then
				flipBoss = false
				printToAll(player.steam_name .. " has [FF0000][b]Disabled[/b] [FFFFFF]automatic Boss Flipping")
			end
		end
	end
end
function optionKeepObjects(player, value, id)
	if player.color ~= "Grey" then
		if id == "clearTableToggleON" then
			self.UI.setAttribute("clearTableToggleON", "isOn", "true")
			self.UI.setAttribute("clearTableToggleOFF", "isOn", "false")
			if clearTheTable == false then
				clearTheTable = true
				printToAll(player.steam_name .. " has [00FF00][b]Enabled[/b] [FFFFFF]clearing the table on Loading up a Game")
			end
		elseif id == "clearTableToggleOFF" then
			self.UI.setAttribute("clearTableToggleON", "isOn", "false")
			self.UI.setAttribute("clearTableToggleOFF", "isOn", "true")
			if clearTheTable == true then
				clearTheTable = false
				printToAll(player.steam_name .. " has [FF0000][b]Disabled[/b] [FFFFFF]clearing the table on Loading up a Game")
			end
		end
	end
end
function optionCGCharacter(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if id == v.cg_cID then
				if v.cgCharacter == true then
					menuToggleSetOptions[i].cgCharacter = false
				else
					menuToggleSetOptions[i].cgCharacter = true
				end
			end
		end
	end
end
function optionCGCharactersSelectAll(player, value, id)
	if player.color ~= "Grey" then
		if menuToggleExtras.cgC == false then
			menuToggleExtras.cgC = true
			for k,v in pairs(menuToggleSetOptions) do
				if v.cgCharacter == false then
					menuToggleSetOptions[k].cgCharacter = true
					self.UI.setAttribute(v.cg_cID, "isOn", "true")
				end
			end
		else
			menuToggleExtras.cgC = false
			for k,v in pairs(menuToggleSetOptions) do
				if v.cgCharacter == true then
					menuToggleSetOptions[k].cgCharacter = false
					self.UI.setAttribute(v.cg_cID, "isOn", "false")
				end
			end
		end
	end
end
function optionCGMainDeck(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if id == v.cg_mdID then
				if v.cgMain == true then
					menuToggleSetOptions[i].cgMain = false
				else
					menuToggleSetOptions[i].cgMain = true
				end
			end
		end
	end
end
function optionCGMainDeckSelectAll(player, value, id)
	if player.color ~= "Grey" then
		if menuToggleExtras.cgMD == false then
			menuToggleExtras.cgMD = true
			for k,v in pairs(menuToggleSetOptions) do
				if v.cgMain == false then
					menuToggleSetOptions[k].cgMain = true
					self.UI.setAttribute(v.cg_mdID, "isOn", "true")
				end
			end
		else
			menuToggleExtras.cgMD = false
			for k,v in pairs(menuToggleSetOptions) do
				if v.cgMain == true then
					menuToggleSetOptions[k].cgMain = false
					self.UI.setAttribute(v.cg_mdID, "isOn", "false")
				end
			end
		end
	end
end
function optionCGBoss(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if id == v.cg_bID then
				if v.cgBoss == true then
					menuToggleSetOptions[i].cgBoss = false
				else
					menuToggleSetOptions[i].cgBoss = true
				end
			end
		end
	end
end
function optionCGBossIM(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if id == v.cg_imID then
				if v.cgIM == true then
					menuToggleSetOptions[i].cgIM = false
				else
					menuToggleSetOptions[i].cgIM = true
				end
			end
		end
	end
end
function optionCGBossSelectAll(player, value, id)
	if player.color ~= "Grey" then
		if menuToggleExtras.cgB == false then
			menuToggleExtras.cgB = true
			for k,v in pairs(menuToggleSetOptions) do
				if v.cgBoss == false then
					menuToggleSetOptions[k].cgBoss = true
					self.UI.setAttribute(v.cg_bID, "isOn", "true")
				end
				if v.cgIM == false then
					menuToggleSetOptions[k].cgIM = true
					self.UI.setAttribute(v.cg_imID, "isOn", "true")
				end
			end
		else
			menuToggleExtras.cgB = false
			for k,v in pairs(menuToggleSetOptions) do
				if v.cgBoss == true then
					menuToggleSetOptions[k].cgBoss = false
					self.UI.setAttribute(v.cg_bID, "isOn", "false")
				end
				if v.cgIM == true then
					menuToggleSetOptions[k].cgIM = false
					self.UI.setAttribute(v.cg_imID, "isOn", "false")
				end
			end
		end
	end
end
function optionsCGStarters(player, value, id) -- Custom Game Drop Down Menu - Starters
    self.UI.setAttribute(id, "selected", value)
	local cgFindStarters = {
	{name ="DC Base Set", image ="DC"}, 
	{name ="Heroes United", image ="HU"}, 
	{name ="Forever Evil", image ="FE"}, 
	{name ="Teen Titans", image ="TT"},
	{name ="Dark Nights Metal", image ="DNM"}, 
	{name ="Injustice", image ="INJ"},
	{name ="Rivals 1", image ="R1"},
	{name ="Rivals 2", image ="R2"}, 
	{name ="Rivals 3", image ="R3"}, 
	{name ="Confrontations", image ="RC"},
	{name ="Fellowship of the Ring", image ="FotR"}, 
	{name ="The Two Towers", image ="2T"}, 
	{name ="Return of the King", image ="RotK"}, 
	{name ="An Unexpected Journey", image ="UJ"},
	{name ="Crossover Crisis", image ="CN"}, 
	{name ="Animation Annihilation", image ="AA"}, 
	{name ="Teen Titans Go!", image ="TTG"},
	{name ="Rick and Morty 1", image ="RM1"},
	{name ="Rick and Morty 2", image ="RM2"}, 
	{name ="Street Fighter", image ="SF"}, 
	{name ="Naruto Shippuden", image ="NS"}, 
	{name ="Epic Spell Wars", image ="EGB"}, 
	{name ="DC Rebirth", image ="RB"},
	}
	self.UI.setAttribute(value)
	for i, v in ipairs(cgFindStarters) do
		if value == v.name then
			menuToggleExtras.cgStarters = v.image
		end
	end
end
function optionsCGKicks(player, value, id) -- Custom Game Drop Down Menu - Kicks
    self.UI.setAttribute(id, "selected", value)
	local cgFindKickStack = {
	{name ="DC Base Set", image ="DC"}, 
	{name ="Heroes United", image ="HU"}, 
	{name ="Forever Evil", image ="FE"}, 
	{name ="Teen Titans", image ="TT"},
	{name ="Dark Nights Metal", image ="DNM"}, 
	{name ="Injustice", image ="INJ"}, 
	{name ="Rivals 1", image ="R1"},
	{name ="Rivals 2", image ="R2"}, 
	{name ="Rivals 3", image ="R3"}, 
	{name ="Confrontations", image ="RC"},
	{name ="Fellowship of the Ring", image ="FotR"}, 
	{name ="The Two Towers", image ="2T"}, 
	{name ="Return of the King", image ="RotK"}, 
	{name ="An Unexpected Journey", image ="UJ"},
	{name ="Crossover Crisis", image ="CN"}, 
	{name ="Animation Annihilation", image ="AA"}, 
	{name ="Teen Titans Go!", image ="TTG"}, 
	{name ="Rick and Morty 1", image ="RM1"},
	{name ="Rick and Morty 2", image ="RM2"}, 
	{name ="Street Fighter", image ="SF"}, 
	{name ="Naruto Shippuden", image ="NS"}, 
	{name ="Epic Spell Wars", image ="EA1"},
	}
	self.UI.setAttribute(value)
	for i, v in ipairs(cgFindKickStack) do
		if value == v.name then
			menuToggleExtras.cgKickStack = v.image
		end
	end
end
function optionsCGWeaknesses(player, value, id) -- Custom Game Drop Down Menu - Weaknesses
    self.UI.setAttribute(id, "selected", value)
	local cgFindWeaknessStack = {
	{name ="DC Base Set", image ="DC"}, 
	{name ="Heroes United", image ="HU"}, 
	{name ="Forever Evil", image ="FE"}, 
	{name ="Teen Titans", image ="TT"},
	{name ="Dark Nights Metal", image ="DNM"}, 
	{name ="Injustice", image ="INJ"},
	{name ="Rivals 1", image ="R1"},
	{name ="Rivals 2", image ="R2"}, 
	{name ="Rivals 3", image ="R3"}, 
	{name ="Confrontations", image ="RC"},
	{name ="Fellowship of the Ring", image ="FotR"}, 
	{name ="The Two Towers", image ="2T"}, 
	{name ="Return of the King", image ="RotK"}, 
	{name ="An Unexpected Journey", image ="UJ"},
	{name ="Cartoon Network + TTG!", image ="Wacky"}, 
	{name ="Rick and Morty 1", image ="RM1"}, 
	{name ="Rick and Morty 2", image ="RM2"}, 
	{name ="Street Fighter", image ="SF"},
	{name ="Naruto Shippuden", image ="NS"}, 
	{name ="Epic Spell Wars", image ="EA2"}, 
	{name ="DC Rebirth", image ="RB"},
	}
	self.UI.setAttribute(value)
	for i, v in ipairs(cgFindWeaknessStack) do
		if value == v.name then
			menuToggleExtras.cgWeaknessStack = v.image
		end
	end
end
function optionsCGAddCrisis(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesAddCrisisCG" then
			self.UI.setAttribute("yesAddCrisisCG", "isOn", "true")
			self.UI.setAttribute("noAddCrisisCG", "isOn", "false")
			menuToggleExtras.cgCrisis = true
		elseif id == "noAddCrisisCG" then
			self.UI.setAttribute("yesAddCrisisCG", "isOn", "false")
			self.UI.setAttribute("noAddCrisisCG", "isOn", "true")
			menuToggleExtras.cgCrisis = false
		end
	end
end
function optionsCGAddEvents(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesAddEventsCG" then
			self.UI.setAttribute("yesAddEventsCG", "isOn", "true")
			self.UI.setAttribute("noAddEventsCG", "isOn", "false")
			menuToggleExtras.cgEvents = true
		elseif id == "noAddEventsCG" then
			self.UI.setAttribute("yesAddEventsCG", "isOn", "false")
			self.UI.setAttribute("noAddEventsCG", "isOn", "true")
			menuToggleExtras.cgEvents = false
		end
	end
end
function optionsCGAddHands(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesAddHandssCG" then
			self.UI.setAttribute("yesAddHandssCG", "isOn", "true")
			self.UI.setAttribute("noAddHandsCG", "isOn", "false")
			menuToggleExtras.cgHands = true
		elseif id == "noAddHandsCG" then
			self.UI.setAttribute("yesAddHandssCG", "isOn", "false")
			self.UI.setAttribute("noAddHandsCG", "isOn", "true")
			menuToggleExtras.cgHands = false
		end
	end
end
function optionDCEMainDeck(player, value, id)
	if player.color ~= "Grey" then
		local optionDCEMainDeckSwapper
		for i, v in ipairs(menuToggleSetOptions) do
			if id == v.mdID then
				optionDCEMainDeckSwapper = v.mdValue
			end
			if optionDCEMainDeckSwapper == true then
				optionDCEMainDeckSwapper = false
			else
				optionDCEMainDeckSwapper = true
			end
			if id == v.mdID then
			v.mdValue = optionDCEMainDeckSwapper
			menuToggleSetOptions[i].mdValue = v.mdValue
			end
		end
	end
end
function optionDCEMainDeckSelectAll(player, value, id)
	if player.color ~= "Grey" then
		if menuToggleExtras.dceMD == false then
			menuToggleExtras.dceMD = true
			for k,v in pairs(menuToggleSetOptions) do
				if v.isDCE == true then
					menuToggleSetOptions[k].mdValue = true
					self.UI.setAttribute(v.mdID, "isOn", "true")
				end
			end
		else
			menuToggleExtras.dceMD = false
			for k,v in pairs(menuToggleSetOptions) do
				if v.isDCE == true then
					menuToggleSetOptions[k].mdValue = false
					self.UI.setAttribute(v.mdID, "isOn", "false")
				end
			end
		end
	end
end
function optionDCECharacter(player, value, id)
	if player.color ~= "Grey" then
		local optionDCECharacterSwapper
		for i, v in ipairs(menuToggleSetOptions) do
			if id == v.cID then
				optionDCECharacterSwapper = v.cValue
			end
			if optionDCECharacterSwapper == true then
				optionDCECharacterSwapper = false
			else
				optionDCECharacterSwapper = true
			end
			if id == v.cID then
			v.cValue = optionDCECharacterSwapper
			menuToggleSetOptions[i].cValue = v.cValue
			end
		end
	end
end
function optionDCECharacterSelectAll(player, value, id)
	if player.color ~= "Grey" then
		if menuToggleExtras.dceC == false then
			menuToggleExtras.dceC = true
			for k,v in pairs(menuToggleSetOptions) do
				if v.isDCE == true then
					menuToggleSetOptions[k].cValue = true
					self.UI.setAttribute(v.cID, "isOn", "true")
				end
			end
		else
			menuToggleExtras.dceC = false
			for k,v in pairs(menuToggleSetOptions) do
				if v.isDCE == true then
					menuToggleSetOptions[k].cValue = false
					self.UI.setAttribute(v.cID, "isOn", "false")
				end
			end
		end
	end
end
function optionsRivalsCharacters(player, value, id)
	if player.color ~= "Grey" then
		local optionRivalsSwapper
		if menuToggleRivalsCharacters[id].isEnabled == true then 
			menuToggleRivalsCharacters[id].isEnabled = false
		else menuToggleRivalsCharacters[id].isEnabled = true
		end
	end
end
function optionsRivalsStarters(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.spawnRivals == true then
				if id == v.rivalsStarters_id then
					self.UI.setAttribute(v.rivalsStarters_id, "isOn", "true")
					menuToggleSetOptions[i].rivalsStarters = true
				else
					self.UI.setAttribute(v.rivalsStarters_id, "isOn", "false")
					menuToggleSetOptions[i].rivalsStarters = false
				end
			end
		end
	end
end
function optionsRivalsWeakness(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.spawnRivals == true then
				if id == v.rivalsWeakness_id then
					self.UI.setAttribute(v.rivalsWeakness_id, "isOn", "true")
					menuToggleSetOptions[i].rivalsWeakness = true
				else
					self.UI.setAttribute(v.rivalsWeakness_id, "isOn", "false")
					menuToggleSetOptions[i].rivalsWeakness = false
				end
			end
		end
	end
end
function optionsRivalsKicks(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.spawnRivals == true then
				if id == v.rivalsKick_id then
					self.UI.setAttribute(v.rivalsKick_id, "isOn", "true")
					menuToggleSetOptions[i].rivalsKick = true
				else
					self.UI.setAttribute(v.rivalsKick_id, "isOn", "false")
					menuToggleSetOptions[i].rivalsKick = false
				end
			end
		end
	end
end
function optionsRivalsAmounts(player, value, id)
	if player.color ~= "Grey" then	
		if id == "ka8" then
			self.UI.setAttribute("ka8", "isOn", "true")
			self.UI.setAttribute("ka16", "isOn", "false")
			menuToggleExtras.rivals_kick8 = true
		elseif id == "ka16" then
			self.UI.setAttribute("ka8", "isOn", "false")
			self.UI.setAttribute("ka16", "isOn", "true")
			menuToggleExtras.rivals_kick8 = false
		elseif id == "wa10" then
			self.UI.setAttribute("wa10", "isOn", "true")
			self.UI.setAttribute("wa20", "isOn", "false")
			menuToggleExtras.rivals_weakness10 = true
		elseif id == "wa20" then
			self.UI.setAttribute("wa10", "isOn", "false")
			self.UI.setAttribute("wa20", "isOn", "true")
			menuToggleExtras.rivals_weakness10 = false
		end
	end
end
function optionsRivalsRules(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesRulesRivals" then
			self.UI.setAttribute("yesRulesRivals", "isOn", "true")
			self.UI.setAttribute("noRulesRivals", "isOn", "false")
			menuToggleExtras.ruleRivals = true
		elseif id == "noRulesRivals" then
			self.UI.setAttribute("yesRulesRivals", "isOn", "false")
			self.UI.setAttribute("noRulesRivals", "isOn", "true")
			menuToggleExtras.ruleRivals = false
		end
	end
end
function optionRivalsSelectAll(player, value, id)
    local menuToggleRivalsSelectAll = {
		batman = "isR1_H", joker = "isR1_V",
		greenlantern = "isR2_H", sinestro = "isR2_V",
		flash = "isR3_H", reverseflash = "isR3_V",
		superman = "isRC_S", lexluthor = "isRC_L", wonderwoman = "isRC_W", circe = "isRC_C",
		aquaman = "isRC_A", oceanmaster = "isRC_O", zatanazatara = "isRC_Z", felixfaust = "isRC_F",
	}
	if menuToggleExtras.rivals_selectall == false then
		menuToggleExtras.rivals_selectall = true
		for k,v in pairs(menuToggleRivalsCharacters) do
			menuToggleRivalsCharacters[k].isEnabled = true
		end
		for i, c in pairs(menuToggleRivalsSelectAll) do
			self.UI.setAttribute(c, "isOn", "true")
		end
	else
		menuToggleExtras.rivals_selectall = false
		for k,v in pairs(menuToggleRivalsCharacters) do
			menuToggleRivalsCharacters[k].isEnabled = false
		end
		for i, c in pairs(menuToggleRivalsSelectAll) do
			self.UI.setAttribute(c, "isOn", "false")
		end
	end
end
function optionsLOTRStarters(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isLOTR == true then
				if v.imgRep ~= "DoS" then
					if id == v.startersLOTR_id then
						self.UI.setAttribute(v.startersLOTR_id, "isOn", "true")
						menuToggleSetOptions[i].startersLOTR = true
					else
						self.UI.setAttribute(v.startersLOTR_id, "isOn", "false")
						menuToggleSetOptions[i].startersLOTR = false
					end
				end
			end
		end
	end
end
function optionsLOTRValor(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isLOTR == true then
				if v.imgRep ~= "DoS" then
					if id == v.valorLOTR_id then
						self.UI.setAttribute(v.valorLOTR_id, "isOn", "true")
						menuToggleSetOptions[i].valorLOTR = true
					else
						self.UI.setAttribute(v.valorLOTR_id, "isOn", "false")
						menuToggleSetOptions[i].valorLOTR = false
					end
				end
			end
		end
	end
end
function optionsLOTRCorruption(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isLOTR == true then
				if v.imgRep ~= "DoS" then
					if id == v.corruptionLOTR_id then
						self.UI.setAttribute(v.corruptionLOTR_id, "isOn", "true")
						menuToggleSetOptions[i].corruptionLOTR = true
					else
						self.UI.setAttribute(v.corruptionLOTR_id, "isOn", "false")
						menuToggleSetOptions[i].corruptionLOTR = false
					end
				end
			end
		end
	end
end
function optionsLOTRrules(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesRulesLotR" then
			self.UI.setAttribute("yesRulesLotR", "isOn", "true")
			self.UI.setAttribute("noRulesLotR", "isOn", "false")
			menuToggleExtras.ruleLOTR = true
		elseif id == "noRulesLotR" then
			self.UI.setAttribute("yesRulesLotR", "isOn", "false")
			self.UI.setAttribute("noRulesLotR", "isOn", "true")
			menuToggleExtras.ruleLOTR = false
		end
	end
end
function optionsLOTRCorruptionDoS(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isLOTR == true then
				if v.imgRep == "DoS" then
					if id == "yesDoSLotR" then
						self.UI.setAttribute("yesDoSLotR", "isOn", "true")
						self.UI.setAttribute("noDoSLotR", "isOn", "false")
						menuToggleSetOptions[i].corruptionLOTR = true
					elseif id == "noDoSLotR" then
						self.UI.setAttribute("yesDoSLotR", "isOn", "false")
						self.UI.setAttribute("noDoSLotR", "isOn", "true")
						menuToggleSetOptions[i].corruptionLOTR = false
					end
				end
			end
		end
	end
end
function optionsLOTRRemoveCharacter(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isLOTR == true then
				if id == v.cLOTR_id then
					if v.cLOTR == true then
						menuToggleSetOptions[i].cLOTR = false
					else
						menuToggleSetOptions[i].cLOTR = true
					end
				end
			end
		end
	end
end
function optionsLOTRRemoveMain(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isLOTR == true then
				if id == v.mainLOTR_id then
					if v.mainLOTR == true then
						menuToggleSetOptions[i].mainLOTR = false
					else
						menuToggleSetOptions[i].mainLOTR = true
					end
				end
			end
		end
	end
end
function optionsLOTRRemoveBoss(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isLOTR == true then
				if id == v.bLOTR_id then
					if v.bLOTR == true then
						menuToggleSetOptions[i].bLOTR = false
					else
						menuToggleSetOptions[i].bLOTR = true
					end
				end
			end
		end
	end
end
function optionsCartoonRules(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesRulesCartoon" then
			self.UI.setAttribute("yesRulesCartoon", "isOn", "true")
			self.UI.setAttribute("noRulesCartoon", "isOn", "false")
			menuToggleExtras.ruleCartoon = true
		elseif id == "noRulesCartoon" then
			self.UI.setAttribute("yesRulesCartoon", "isOn", "false")
			self.UI.setAttribute("noRulesCartoon", "isOn", "true")
			menuToggleExtras.ruleCartoon = false
		end
	end
end
function optionsCartoonEvents(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesEventsCartoon" then
			self.UI.setAttribute("yesEventsCartoon", "isOn", "true")
			self.UI.setAttribute("noEventsCartoon", "isOn", "false")
			menuToggleExtras.eventCartoon = true
		elseif id == "noEventsCartoon" then
			self.UI.setAttribute("yesEventsCartoon", "isOn", "false")
			self.UI.setAttribute("noEventsCartoon", "isOn", "true")
			menuToggleExtras.eventCartoon = false
		end
	end
end
function optionsCartoonJoke(player, value, id)
	if player.color ~= "Grey" then
		if id == "jokeCN" then
			self.UI.setAttribute("jokeCN", "isOn", "true")
			self.UI.setAttribute("jokeAA", "isOn", "false")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.imgRep == "CN" then
					menuToggleSetOptions[i].cartoonJoke = true
				elseif v.imgRep == "AA" then
					menuToggleSetOptions[i].cartoonJoke = false
				end
			end
		elseif id == "jokeAA" then
			self.UI.setAttribute("jokeCN", "isOn", "false")
			self.UI.setAttribute("jokeAA", "isOn", "true")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.imgRep == "CN" then
					menuToggleSetOptions[i].cartoonJoke = false
				elseif v.imgRep == "AA" then
					menuToggleSetOptions[i].cartoonJoke = true
				end
			end
		end
	end
end
function optionsCartoonTTG(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesStackTG" then
			self.UI.setAttribute("yesStackTG", "isOn", "true")
			self.UI.setAttribute("noStackTG", "isOn", "false")
			menuToggleExtras.stackTG = true
		elseif id == "noStackTG" then
			self.UI.setAttribute("yesStackTG", "isOn", "false")
			self.UI.setAttribute("noStackTG", "isOn", "true")
			menuToggleExtras.stackTG = false
		end
	end
end
function optionsCartoonRemoveCharacter(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.spawnCartoon == true then
				if id == v.cartoonCharacter_id then
					if v.cartoonCharacter == true then
						menuToggleSetOptions[i].cartoonCharacter = false
						self.UI.setAttribute(v.cartoonCharacter_id, "isOn", "true")
					else
						menuToggleSetOptions[i].cartoonCharacter = true
						self.UI.setAttribute(v.cartoonCharacter_id, "isOn", "false")
					end
				end
			end
		end
	end
end
function optionsCartoonRemoveMain(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.spawnCartoon == true then
				if id == v.cartoonMain_id then
					if v.cartoonMain == true then
						menuToggleSetOptions[i].cartoonMain = false
						self.UI.setAttribute(v.cartoonMain_id, "isOn", "true")
					else
						menuToggleSetOptions[i].cartoonMain = true
						self.UI.setAttribute(v.cartoonMain_id, "isOn", "false")
					end
				end
			end
		end
	end
end
function optionsCartoonRemoveNemesis(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.spawnCartoon == true then
				if id == v.cartoonNemesis_id then
					if v.cartoonNemesis == true then
						menuToggleSetOptions[i].cartoonNemesis = false
						self.UI.setAttribute(v.cartoonNemesis_id, "isOn", "true")
					else
						menuToggleSetOptions[i].cartoonNemesis = true
						self.UI.setAttribute(v.cartoonNemesis_id, "isOn", "false")
					end
				end
			end
		end
	end
end
function optionsCartoonRemoveWeakness(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.spawnCartoon == true then
				if id == v.cartoonWeakness_id then
					if v.cartoonWeakness == true then
						menuToggleSetOptions[i].cartoonWeakness = false
						self.UI.setAttribute(v.cartoonWeakness_id, "isOn", "true")
					else
						menuToggleSetOptions[i].cartoonWeakness = true
						self.UI.setAttribute(v.cartoonWeakness_id, "isOn", "false")
					end
				end
			end
		end
	end
end
function optionsCartoonRemoveStarter(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.spawnCartoon == true then
				if id == v.cartoonStarters_id then
					self.UI.setAttribute(v.cartoonStarters_id, "isOn", "true")
					menuToggleSetOptions[i].cartoonStarters = true
				else
					self.UI.setAttribute(v.cartoonStarters_id, "isOn", "false")
					menuToggleSetOptions[i].cartoonStarters = false
				end
			end
		end
	end
end
function optionsRickMortyRules(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesRulesRickMorty" then
			self.UI.setAttribute("yesRulesRickMorty", "isOn", "true")
			self.UI.setAttribute("noRulesRickMorty", "isOn", "false")
			menuToggleExtras.ruleRickMorty = true
		elseif id == "noRulesRickMorty" then
			self.UI.setAttribute("yesRulesRickMorty", "isOn", "false")
			self.UI.setAttribute("noRulesRickMorty", "isOn", "true")
			menuToggleExtras.ruleRickMorty = false
		end
	end
end
function optionsRickMortyCouncil(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesCouncil" then
			self.UI.setAttribute("yesCouncil", "isOn", "true")
			self.UI.setAttribute("noCouncil", "isOn", "false")
			menuToggleExtras.councilRickMorty = true
		elseif id == "noCouncil" then
			self.UI.setAttribute("yesCouncil", "isOn", "false")
			self.UI.setAttribute("noCouncil", "isOn", "true")
			menuToggleExtras.councilRickMorty = false
		end
	end
end
function optionsRickMortyStarter(player, value, id)
	if player.color ~= "Grey" then
		if id == "rmcStarterRM1" then
			self.UI.setAttribute("rmcStarterRM1", "isOn", "true")
			self.UI.setAttribute("rmcStarterRM2", "isOn", "false")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.imgRep == "RM1" then
					menuToggleSetOptions[i].rmcStarters = true
				elseif v.imgRep == "RM2" then
					menuToggleSetOptions[i].rmcStarters = false
				end
			end
		elseif id == "rmcStarterRM2" then
			self.UI.setAttribute("rmcStarterRM1", "isOn", "false")
			self.UI.setAttribute("rmcStarterRM2", "isOn", "true")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.imgRep == "RM1" then
					menuToggleSetOptions[i].rmcStarters = false
				elseif v.imgRep == "RM2" then
					menuToggleSetOptions[i].rmcStarters = true
				end
			end
		end
	end
end
function optionsRickMortyWeakness(player, value, id)
	if player.color ~= "Grey" then
		if id == "rmcMortyWavesRM1" then
			self.UI.setAttribute("rmcMortyWavesRM1", "isOn", "true")
			self.UI.setAttribute("rmcMortyWavesRM2", "isOn", "false")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.imgRep == "RM1" then
					menuToggleSetOptions[i].rmcMortyWaves = true
				elseif v.imgRep == "RM2" then
					menuToggleSetOptions[i].rmcMortyWaves = false
				end
			end
		elseif id == "rmcMortyWavesRM2" then
			self.UI.setAttribute("rmcMortyWavesRM1", "isOn", "false")
			self.UI.setAttribute("rmcMortyWavesRM2", "isOn", "true")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.imgRep == "RM1" then
					menuToggleSetOptions[i].rmcMortyWaves = false
				elseif v.imgRep == "RM2" then
					menuToggleSetOptions[i].rmcMortyWaves = true
				end
			end
		end
	end
end
function optionsESWRemoveLegends(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isESW == true then
				if id == v.bESW_id then
					if v.bESW == true then
						menuToggleSetOptions[i].bESW = false
					else
						menuToggleSetOptions[i].bESW = true
					end
				end
			end
		end
	end
end
function optionsESWRemoveMayhems(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isESW == true then
				if id == v.mESW_id then
					if v.mayhemESW == true then
						menuToggleSetOptions[i].mayhemESW = false
					else
						menuToggleSetOptions[i].mayhemESW = true
					end
				end
			end
		end
	end
end
function optionsESWRemoveDWT(player, value, id)
	if player.color ~= "Grey" then
		if id == "esw_dwt_EA1" then
			if menuToggleExtras.dwtEA1 == true then
				menuToggleExtras.dwtEA1 = false
			else
				menuToggleExtras.dwtEA1 = true
			end
		elseif id == "esw_dwt_EA2" then
			if menuToggleExtras.dwtEA2 == true then
				menuToggleExtras.dwtEA2 = false
			else
				menuToggleExtras.dwtEA2 = true
			end
		elseif id == "esw_dwt_EGB" then
			if menuToggleExtras.dwtEGB == true then
				menuToggleExtras.dwtEGB = false
			else
				menuToggleExtras.dwtEGB = true
			end
		end
	end
end
function optionsESWRemovStandee(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isESW == true then
				if id == v.sESW_id then
					if v.standeeESW == true then
						menuToggleSetOptions[i].standeeESW = false
					else
						menuToggleSetOptions[i].standeeESW = true
					end
				end
			end
		end
	end
end
function optionsESWRemoveMD(player, value, id)
	if player.color ~= "Grey" then
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isESW == true then
				if id == v.mdESW_id then
					if v.mainESW == true then
						menuToggleSetOptions[i].mainESW = false
					else
						menuToggleSetOptions[i].mainESW = true
					end
				end
			end
		end
	end
end
function optionsESWrules(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesRulesESW" then
			self.UI.setAttribute("yesRulesESW", "isOn", "true")
			self.UI.setAttribute("noRulesESW", "isOn", "false")
			menuToggleExtras.ruleESW = true
		elseif id == "noRulesESW" then
			self.UI.setAttribute("yesRulesESW", "isOn", "false")
			self.UI.setAttribute("noRulesESW", "isOn", "true")
			menuToggleExtras.ruleESW = false
		end
	end
end
function optionsGangBangers(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesGangBangers" then
			self.UI.setAttribute("yesGangBangers", "isOn", "true")
			self.UI.setAttribute("noGangBangers", "isOn", "false")
			menuToggleExtras.eswGB = true
		elseif id == "noGangBangers" then
			self.UI.setAttribute("yesGangBangers", "isOn", "false")
			self.UI.setAttribute("noGangBangers", "isOn", "true")
			menuToggleExtras.eswGB = false
		end
	end
end
function optionsESWPromo(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesESWPromo" then
			self.UI.setAttribute("yesESWPromo", "isOn", "true")
			self.UI.setAttribute("noESWPromo", "isOn", "false")
			menuToggleExtras.eswVP = true
		elseif id == "noESWPromo" then
			self.UI.setAttribute("yesESWPromo", "isOn", "false")
			self.UI.setAttribute("noESWPromo", "isOn", "true")
			menuToggleExtras.eswVP = false
		end
	end
end
function optionsESWRemoveAbility(player, value, id)
	if player.color ~= "Grey" then
		if id == "esw_ability_EA1" then
			if menuToggleExtras.abilityEA1 == true then
				menuToggleExtras.abilityEA1 = false
			else
				menuToggleExtras.abilityEA1 = true
			end
		elseif id == "esw_ability_EA2" then
			if menuToggleExtras.abilityEA2 == true then
				menuToggleExtras.abilityEA2 = false
			else
				menuToggleExtras.abilityEA2 = true
			end
		end
	end
end
function optionsESWWand(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesESWWand" then
			self.UI.setAttribute("yesESWWand", "isOn", "true")
			self.UI.setAttribute("noESWWand", "isOn", "false")
			menuToggleExtras.eswWand = true
		elseif id == "noESWWand" then
			self.UI.setAttribute("yesESWWand", "isOn", "false")
			self.UI.setAttribute("noESWWand", "isOn", "true")
			menuToggleExtras.eswWand = false
		end
	end
end
function optionsESWCheese(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesESWCheese" then
			self.UI.setAttribute("yesESWCheese", "isOn", "true")
			self.UI.setAttribute("noESWCheese", "isOn", "false")
			menuToggleExtras.eswCheese = true
		elseif id == "noESWCheese" then
			self.UI.setAttribute("yesESWCheese", "isOn", "false")
			self.UI.setAttribute("noESWCheese", "isOn", "true")
			menuToggleExtras.eswCheese = false
		end
	end
end
function optionsESWBlasting(player, value, id)
	if player.color ~= "Grey" then
		if id == "yesESWBlasting" then
			self.UI.setAttribute("yesESWBlasting", "isOn", "true")
			self.UI.setAttribute("noESWBlasting", "isOn", "false")
			menuToggleExtras.eswBlasting = true
		elseif id == "noESWBlasting" then
			self.UI.setAttribute("yesESWBlasting", "isOn", "false")
			self.UI.setAttribute("noESWBlasting", "isOn", "true")
			menuToggleExtras.eswBlasting = false
		end
	end
end
function optionMultiverse(player, value, id)
	if player.color ~= "Grey" then
		if id == "mvStandard" then
			self.UI.setAttribute("mvStandard", "isOn", "true")
			self.UI.setAttribute("mvImpossible", "isOn", "false")
			if menuToggleExtras.mvGameModeStandard == false then
				menuToggleExtras.mvGameModeStandard = true
			end
		elseif id == "mvImpossible" then
			self.UI.setAttribute("mvStandard", "isOn", "false")
			self.UI.setAttribute("mvImpossible", "isOn", "true")
			if menuToggleExtras.mvGameModeStandard == true then
				menuToggleExtras.mvGameModeStandard = false
			end
		elseif id == "mvLengthStandard" then
			self.UI.setAttribute("mvLengthStandard", "isOn", "true")
			self.UI.setAttribute("mvLengthShort", "isOn", "false")
			if menuToggleExtras.mvGameLengthStandard == false then
				menuToggleExtras.mvGameLengthStandard = true
			end
		elseif id == "mvLengthShort" then
			self.UI.setAttribute("mvLengthStandard", "isOn", "false")
			self.UI.setAttribute("mvLengthShort", "isOn", "true")
			if menuToggleExtras.mvGameLengthStandard == true then
				menuToggleExtras.mvGameLengthStandard = false
			end
		elseif id == "mvInfiniteYes" then
			self.UI.setAttribute("mvInfiniteYes", "isOn", "true")
			self.UI.setAttribute("mvInfiniteNo", "isOn", "false")
			if menuToggleExtras.mvAddCrisis == false then
				menuToggleExtras.mvAddCrisis = true
			end
		elseif id == "mvInfiniteNo" then
			self.UI.setAttribute("mvInfiniteYes", "isOn", "false")
			self.UI.setAttribute("mvInfiniteNo", "isOn", "true")
			if menuToggleExtras.mvAddCrisis == true then
				menuToggleExtras.mvAddCrisis = false
			end
		end
	end
end
function optionMultiverseSets(player, value, id)
	if player.color ~= "Grey" then
		local optionMultivereSetSwapper
		local readIndex
		for i, v in ipairs(menuToggleSetOptions) do
			if id == v.mvID then
				optionMultivereSetSwapper = v.mvValue
			end
			if optionMultivereSetSwapper == true then
				optionMultivereSetSwapper = false
			else
				optionMultivereSetSwapper = true
			end
			if id == v.mvID then
			v.mvValue = optionMultivereSetSwapper
			menuToggleSetOptions[i].mvValue = v.mvValue
			readIndex = i
			end
		end
	end
end
function updateTuckButtonVisibility(colorNext)
    UI.setAttribute("tuckEndTurnButton", "visibility", "")
	UI.setAttribute("tuckEndTurnButton", "outlineColor", "#FFFFFF")
		
    -- Color → outline hex map
    local outlineColors = {
        White  = "#FFFFFF",
        Yellow = "#FFD700",
        Red    = "#FF0000",
        Green  = "#00AA00",
        Brown  = "#8B4513",
        Purple = "#800080",
        Orange = "#FFA500",
        Pink   = "#FF69B4"
    }
	
	if colorNext == "White" then
        UI.setAttribute("tuckEndTurnButton", "visibility", "White")
		UI.setAttribute("tuckEndTurnButton", "outlineColor", "#FFFFFF")
    elseif colorNext == "Yellow" then
		UI.setAttribute("tuckEndTurnButton", "visibility", "Yellow")
		UI.setAttribute("tuckEndTurnButton", "outlineColor", "#FFD700")
    elseif colorNext == "Red" then
		UI.setAttribute("tuckEndTurnButton", "visibility", "Red")
		UI.setAttribute("tuckEndTurnButton", "outlineColor", "#FF0000")
    elseif colorNext == "Green" then
		UI.setAttribute("tuckEndTurnButton", "visibility", "Green")
		UI.setAttribute("tuckEndTurnButton", "outlineColor", "#00AA00")
    elseif colorNext == "Brown" then
		UI.setAttribute("tuckEndTurnButton", "visibility", "Brown")
		UI.setAttribute("tuckEndTurnButton", "outlineColor", "#8B4513")
    elseif colorNext == "Purple" then
		UI.setAttribute("tuckEndTurnButton", "visibility", "Purple")
		UI.setAttribute("tuckEndTurnButton", "outlineColor", "#800080")
    elseif colorNext == "Orange" then
		UI.setAttribute("tuckEndTurnButton", "visibility", "Orange")
		UI.setAttribute("tuckEndTurnButton", "outlineColor", "#FFA500")
    elseif colorNext == "Pink" then
		UI.setAttribute("tuckEndTurnButton", "visibility", "Pink")
		UI.setAttribute("tuckEndTurnButton", "outlineColor", "#FF69B4")
    else
        return
    end
end
function setupQuickRandom(player, value, id) --Random Game Clicked
	self.UI.setAttribute("clickRandom", "isOn", "false")
	updateRandomSeed()
    local randomNumber = math.random(1,29)
	local randomSetName = {
	"[0E18A6]DC Base Set", "[FF3A3A]Heroes United", "[9600B3]Forever Evil", "[F2621B]Teen Titans", "[888888]Dark Nights Metal",
	"[2B2237]Rivals 1 - Batman vs The Joker", "[039615]Rivals 2 - Green Lantern vs Sinestro", "[0D23CC]Confrontations",
	"[9DD8FF]LotR - Fellowship of the Rings", "[D31C06]LotR - The Two Towers", "[2F000A]LotR - Return of the King",
	"[F4AE2C]The Hobbit - Unexpected Journey", "[7641C1]The Hobbit - The Desolation of Smaug",
	"[FF8222]Cartoon Network Crossover Crisis", "[3D68B7]Cartoon Network Animation Annihilation", "[AD1100]Teen Titans Go!",
	"[CEBB52]Close Rick-Counters of the Rick Kind Cards!", "[228EC7]The Rickshank Rickdemption!",
	"[9A4C18]Street Fighter", "[FF9900]Naruto Shippuden",
	"[1F7096]Epic Spell Wars of the Battle Wizards - [C92D39]ANNIHILAGEDDON",
	"[1F7096]Epic Spell Wars of the Battle Wizards - [C92D39]ANNIHILAGEDDON [ED4018]2 - [E9BD17]Xtreme [ED9118]Nacho [ED4018]Legends",
	"[0B7AFF]DC Rebirth", "[808080]DCDB Cube", "[EDF01D]Multiverse",}
	local randomSetNameResult = randomSetName[randomNumber]

	local randomCrossoverExp = math.random(1,9)
	local randomCrossoverName = {
	"[5ABCFE]Crossover 1  - Justice Society of America", "[0D5C10]Crossover 2 - Arrow - The Television Series",
	"[B62323]Crossover 3 - Legion of Super-Heroes", "[FFE400]Crossover 4 - Watchmen",
	"[00FFF4]Crossover 5 - Rouges", "[FF8FFA]Crossover 6 - Birds of Prey",
	"[9861FF]Crossover 7 - New Gods", "[18358C]Crossover 8 - Ninja Batman",
	"[646630]Crossover 9 - Bombshells",}
	local randomCrossoverNameResult = randomCrossoverName[randomCrossoverExp]

	local randomCrisisExp = math.random(1,4)
	local randomCrisisName = {
	"[0068B3]Crisis 1", "[1B1B16]Crisis 2", "[451AE2]Crisis 3", "[B44B14]Crisis 4",}
	local randomCrisisNameResult = randomCrisisName[randomCrisisExp]

	local randomBase = math.random(1,6)
	local randomBaseName = {
	"[0E18A6]DC Base Set", "[FF3A3A]Heroes United", "[9600B3]Forever Evil", "[F2621B]Teen Titans", "[888888]Dark Nights Metal",
	"[AD1100]Teen Titans Go!",}
	local randomBaseNameResult = randomBaseName[randomBase]

	local randomESW = math.random (1,2)
	local randomESWName = {
	"[C92D39]ANNIHILAGEDDON",
	"[C92D39]ANNIHILAGEDDON [ED4018]2 - [E9BD17]Xtreme [ED9118]Nacho [ED4018]Legends",}
	local randomESWResult = randomESWName[randomESW]
    --Broadcast Result
	if randomNumber < 26 then
		printToAll(player.steam_name .. " clicked random...up for " .. randomSetNameResult .."[FFFFFF]?")
	elseif randomNumber == 26 then
		printToAll(player.steam_name .. " clicked random...up for " .. randomCrisisNameResult .. " [FFFFFF]with " .. randomBaseNameResult .. "[FFFFFF]?")
	elseif randomNumber == 27 then
		printToAll(player.steam_name .. " clicked random...up for " .. randomCrossoverNameResult .. " [FFFFFF]with " .. randomBaseNameResult .. "[FFFFFF]?")
	elseif randomNumber == 28 then
		printToAll(player.steam_name .. " clicked random...up for[1F7096]Epic Spell Wars of the Battle Wizards - [C09000]Gang Bangers [FFFFFF]with " .. randomESWResult .. "[FFFFFF]?")
	end
end

--************************Quick Games Functions************************--

function setupFreshStart(player, value, id)
	if clearTheTable == true then
		deleteEverything()
	end
	playerBoardDisabled()
	objScripts_Score.call("clearVPBags")
	objScripts_Score.call("clearCounters")
	objScripts_Score.call("removeScoreCardHighlights")
	showForPlayer({panel = "Quick Game", color = player.color})
	resetScore()
	if tableSize == 1 then
		changeTable1()
	elseif tableSize == 2 then
		changeTable3()
	end
	turnCounter = 0
	boss1Value = 0
	boss2Value = 0
	boss3Value = 0
	boss4Value = 0
	boss5Value = 0
	dcdbCubeGame = 0
	dwtValue = 0
	lineupEA2_Legends = false
	specialSetUp = ""
	bagID=""
	bagSet = nil
	startingPlayer = "noStartingPlayerChosen"
	startingPlayerLocked = 0
	resetYlist()
	zTable.zBossStack.clearButtons()
	playerBoardEnable()
end
function resetYlist()
	menuToggleExtras.mdBagID_y = 3
	menuToggleExtras.cBagID_y = 1.5
	menuToggleExtras.kBagID_y = 1.5
	menuToggleExtras.wBagID_y = 2.75
	menuToggleExtras.bBagID_y = 1.5
	registerTables()
end
function setupQuickGame(player, value, id)
	if player.color ~= "Grey" then
		setupFreshStart(player, value, id)
		quickSetup = 1
		if id == "DCQuick" then
			bagID="Basic DC"
			starterID="DC"
			bagSet=infBag.DCstart
			bossDC()
			printToAll(player.steam_name .. " is loading the DC Base Game!")
		elseif id == "HUQuick" then
			bagID="Basic HU"
			starterID="HU"
			bagSet=infBag.HUstart
			bossHU()
			printToAll(player.steam_name .. " is loading Heroes United")
		elseif id == "FEQuick" then
			bagID="Basic FE"
			starterID="FE"
			bagSet=infBag.FEstart
			bossFE()
			printToAll(player.steam_name .. " is loading Forever Evil")
		elseif id == "TTQuick" then
			bagID="Basic TT"
			starterID="TT"
			bagSet=infBag.TTstart
			bossTT()
			printToAll(player.steam_name .. " is loading Teen Titans")
		elseif id == "DNMQuick" then
			bagID="Basic DNM"
			starterID="DNM"
			bagSet=infBag.DNMstart
			bossDNM()
			printToAll(player.steam_name .. " is loading Dark Nights Metal")
		elseif id == "INJQuick" then
			bagID="Basic INJ"
			starterID="INJ"
			bagSet=infBag.INJstart
			bossINJ()
			playerBoardQuickEnable("Health")
			playerBoardQuickEnable("Meter")
			specialSetUp = "INJ"
			quickSetup = 4
			printToAll(player.steam_name .. " is loading Injustice")
		elseif id == "R1Quick" then
			bagID="Basic R1"
			starterID="R1"
			bagSet=infBag.R1start
			printToAll(player.steam_name .. " is loading Rivals 1 - Batman Vs The Joker")
		elseif id == "R2Quick" then
			bagID="Basic R2"
			starterID="R2"
			bagSet=infBag.R2start
			printToAll(player.steam_name .. " is loading Rivals 2 - Green Lantern vs Sinestro")
		elseif id == "R3Quick" then
			bagID="Basic R3"
			starterID="R3"
			bagSet=infBag.R3start
			printToAll(player.steam_name .. " is loading Rivals 3 - Flash vs Reverse-Flash")
		elseif id == "RCQuick" then
			bagID="Basic RC"
			starterID="RC"
			bagSet=infBag.RCstart
			printToAll(player.steam_name .. " is loading Confrontations")
		elseif id == "FotRQuick" then
			bagID="Basic FotR"
			starterID="FotR"
			bagSet=infBag.FotRstart
			bossFotR()
			printToAll(player.steam_name .. " is loading Lord of the Rings - Fellowship of the Ring")
		elseif id == "2TQuick" then
			bagID="Basic 2T"
			starterID="2T"
			bagSet=infBag.T2Tstart
			specialSetUp = "T2T"
			boss2T()
			quickSetup = 3
			printToAll(player.steam_name .. " is loading Lord of the Rings - The Two Towers")
		elseif id == "RotKQuick" then
			bagID="Basic RotK"
			starterID="RotK"
			bagSet=infBag.RotKstart
			bossRotK()
			printToAll(player.steam_name .. " is loading Lord of the Rings - Return of the King")
		elseif id == "UJQuick" then
			bagID="Basic UJ"
			starterID="UJ"
			bagSet=infBag.UJstart
			specialSetUp = "Unexpected"
			bossUJ()
			quickSetup = 3
			printToAll(player.steam_name .. " is loading The Hobbit - An Unexpected Journey")
		elseif id == "DoSQuick" then
			bagID="Basic UJ"
			starterID="UJ"
			bagSet=infBag.UJstart
			specialSetUp = "Smaug"
			bossDoS()
			quickSetup = 3
			printToAll(player.steam_name .. " is loading The Hobbit - The Desolation of Smaug")
		elseif id == "CNQuick" then
			bagID="Basic CN"
			starterID="CN"
			bagSet=infBag.CNstart
			printToAll(player.steam_name .. " is loading Cartoon Network Crossover Crisis")
			boss1Value = 1
			boss2Value = 3
			boss3Value = 2
		elseif id == "AAQuick" then
			bagID="Basic AA"
			starterID="AA"
			bagSet=infBag.AAstart
			printToAll(player.steam_name .. " is loading Cartoon Network Animation Annihilation")
			boss1Value = 1
			boss2Value = 3
			boss3Value = 2
		elseif id == "TTGQuick" then
			bagID="Basic TTG"
			starterID="TTG"
			bagSet=infBag.TTGstart
			bossTTG()
			printToAll(player.steam_name .. " is loading Teen Titans Go!")
		elseif id == "RM1Quick" then
			bagID="Basic RM1"
			starterID="RM1"
			bagSet=infBag.RM1start
			printToAll(player.steam_name .. " is loading Rick & Morty: Close Rick-Counters of the Rick Kind!")
			boss1Value = 1
			boss2Value = 4
			boss3Value = 2
		elseif id == "RM2Quick" then
			bagID="Basic RM2"
			starterID="RM2"
			bagSet=infBag.RM2start
			printToAll(player.steam_name .. " is loading Rick & Morty: The Rickshank Rickdemption")
			boss1Value = 1
			boss2Value = 3
			boss3Value = 2
			boss5Value = 1
		elseif id == "SFQuick" then
			bagID="Basic SF"
			starterID="SF"
			bagSet=infBag.SFstart
			printToAll(player.steam_name .. " is loading Street Fighter")
			boss1Value = 1
			boss2Value = 5
			boss3Value = 1
			boss5Value = 1
		elseif id == "NSQuick" then
			bagID="Basic NS"
			starterID="NS"
			bagSet=infBag.NSstart
			printToAll(player.steam_name .. " is loading Naruto Shippuden")
			boss1Value = 1
			boss2Value = 3
			boss3Value = 3
			boss5Value = 1
			playerBoardQuickEnable("Chakara")
		elseif id == "EA1Quick" then
			bagID="Basic EA1"
			starterID="EA1"
			bagSet=infBag.EA1start
			specialSetUp = "EA1"
			bossESW()
			broadcastToAll("[FF0000]WARNING: Epic Spell Wars is NSFW[FF0000]")
			printToAll(player.steam_name .. " is loading Epic Spell Wars of the Battle Wizards - ANNIHILAGEDDON")
			quickSetup = 4
			playerBoardQuickEnable("Health")
		elseif id == "EA2Quick" then
			bagID="Basic EA2"
			starterID="EA2"
			bagSet=infBag.EA2start
			specialSetUp = "EA2"
			lineupEA2_Legends = true
			bossESW()
			broadcastToAll("[FF0000]WARNING: Epic Spell Wars is NSFW[FF0000]")
			printToAll(player.steam_name .. " is loading Epic Spell Wars of the Battle Wizards - ANNIHILAGEDDON 2 - Xtreme Nacho Legends")
			quickSetup = 4
			playerBoardQuickEnable("Health")
		elseif id == "RBQuick" then
			bagID="Basic RB"
			starterID="RB"
			bagSet=infBag.RBstart
			printToAll(player.steam_name .. " is loading DC Rebirth")
			if tableSize == 1 then
				changeTable2()
			elseif tableSize == 2 then
				changeTable4()
			end
			createRebirthButton()
			refill = false
			flipBoss = false
			specialSetUp = "Rebirth"
			self.UI.setAttribute("refillToggleON", "isOn", "false")
			self.UI.setAttribute("refillToggleOFF", "isOn", "true")
			self.UI.setAttribute("flipBossToggleON", "isOn", "false")
			self.UI.setAttribute("flipBossToggleOFF", "isOn", "true")
			printToAll("Automatic Line-Up Refill & Boss Flipping have been [FF0000][b]Disabled[/b] [FFFFFF]for DC Rebirth")
			playerBoardQuickEnable("Move")
		end
		grabMainBag()
		grabStarters()
		playerBoardDisabled()
		playerBoardEnable()
		Wait.frames(bossCountSetup, 120)
	end
end
function setupDCDBCubeGame(player, value, id)
    if gameLoading == 0 then
        if player.color ~= "Grey" then
            if id == "DCDBQuick" then
                --Don't Let Cube Be Loaded Again Until It Finishes Loading
                gameLoading = 1
				dcdbCubeGame = 1
            end
			setupFreshStart(player, value, id)
			quickSetup = 1
			printToAll(player.steam_name .. " is loading their Custom Cube")
			dcdbCubeGame = 1
			bagSet = infBag.DCDBall
			mainClock.setValue(3600)
			beginGame()
			Wait.frames(bossCountSetup, 120)
		end
	else
	--Someone Already Starting Loading A Cube Game, Just Close The Pop-Up Like They Loaded It
	showForPlayer({panel = "Quick Game", color = player.color})
	end
end
function spawnCustomGame(player, value, id)
	if player.color ~= "Grey" then
        dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		menuToggleExtras.cgDWT = 0
		menuToggleExtras.cgAT = 0
		quickSetup = 10
		local currentPlayerCount = #getSeatedPlayers()
		printToAll(player.steam_name .. " is loading a [E61639]Custom Game[FFFFFF]...")
		for i, v in ipairs(menuToggleSetOptions) do
			function customPause()
				bagSet = v.bagSet
				if v.cgCharacter == true then
					if v.imgRep == "INJ" then
						playerBoardQuickEnable("Health")
						playerBoardQuickEnable("Meter")
					elseif v.imgRep == "EA1" or v.imgRep == "EA2" or v.imgRep == "EGB" then
						playerBoardQuickEnable("Health")
					elseif v.imgRep == "NS" then
						playerBoardQuickEnable("Chakara")
					elseif v.imgRep == "" then
						playerBoardQuickEnable("Move")
					end
					wait(0.2)
					v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
					if v.spawnCrisis == true then
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID_Crisis]})
					end
					menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
					registerTables()
				end
				if v.cgMain == true then
					if v.imgRep == "INJ" then
						playerBoardQuickEnable("Health")
						playerBoardQuickEnable("Meter")
					elseif v.imgRep == "EA1" or v.imgRep == "EA2" or v.imgRep == "EGB" then
						playerBoardQuickEnable("Health")
					elseif v.imgRep == "NS" then
						playerBoardQuickEnable("Chakara")
					elseif v.imgRep == "" then
						playerBoardQuickEnable("Move")
					end
					wait(0.2)
					v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mdBagID]})
					menuToggleExtras.mdBagID_y = menuToggleExtras.mdBagID_y + 2
					registerTables()
					--Rick and Morty Locations ontop of Main Deck
					if v.imgRep == "RM1" or v.imgRep == "RM2" then
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cgLocationID]})
						menuToggleExtras.mdBagID_y = menuToggleExtras.mdBagID_y + 2
						registerTables()
					end
				end
				if v.cgBoss == true then
					if v.imgRep == "INJ" then
						playerBoardQuickEnable("Health")
						playerBoardQuickEnable("Meter")
					elseif v.imgRep == "EA1" or v.imgRep == "EA2" or v.imgRep == "EGB" then
						playerBoardQuickEnable("Health")
					elseif v.imgRep == "NS" then
						playerBoardQuickEnable("Chakara")
					elseif v.imgRep == "" then
						playerBoardQuickEnable("Move")
					end
					wait(0.2)
					v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.bBagID]})
					menuToggleExtras.bBagID_y = menuToggleExtras.bBagID_y + 1
					registerTables()
				end
				if v.cgIM == true then
					wait(0.2)
					v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.bBagID_IM]})
					menuToggleExtras.bBagID_y = menuToggleExtras.bBagID_y + 1
					registerTables()
				end
				if v.imgRep == menuToggleExtras.cgWeaknessStack then
					wait(0.2)
					v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.wBagID]})
					if v.imgRep == "UJ" then
					infBag.DoSstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Corruption DoS"]})
					end
				end
				if v.imgRep == menuToggleExtras.cgKickStack then
					wait(0.2)
					v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.kBagID]})
					if v.imgRep == "RM1" or v.imgRep == "RM2" then
						menuToggleExtras.cgSplitLocations = true
					else
						menuToggleExtras.cgSplitLocations = false
					end
				end
				--LotR Extras
				if v.imgRep == "2T" then
					if v.cgBoss == true or v.cgMain == true or v.cgIM == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["2T - LotR Custom"]})
						menuToggleExtras.cg2TWalls = true
					else
						menuToggleExtras.cg2TWalls = false
					end
				elseif v.imgRep == "RotK" then
					if v.cgBoss == true or v.cgMain == true or v.cgIM == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RotK - LotR Custom"]})
					end
				elseif v.imgRep == "UJ" then
					if v.cgBoss == true or v.cgIM == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["UJ - LotR Custom"]})
					elseif v.cgMain == true and v.cgBoss == false and v.cgIM == false then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["UJ - Custom Game - Ring"]})
					end
				elseif v.imgRep == "DoS" then
					if v.cgBoss == true or v.cgIM == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["DoS - LotR Custom"]})
					end
				elseif v.imgRep == "RM2" then
					if v.cgBoss == true or v.cgMain == true or v.cgCharacter == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RM2 Custom Game Access Tokens"]})
					end
				end
				--ESW Extras
				if v.imgRep == "EA1" then
					if v.cgCharacter == true then
						menuToggleExtras.cgDWT = menuToggleExtras.cgDWT + 1
						menuToggleExtras.cgAT = menuToggleExtras.cgAT + 1
					end
				elseif v.imgRep == "EGB" then
					if v.cgCharacter == true then
						menuToggleExtras.cgDWT = menuToggleExtras.cgDWT + 2
					end
				elseif v.imgRep == "EA2" then
					if v.cgCharacter == true then
						menuToggleExtras.cgDWT = menuToggleExtras.cgDWT + 4
						menuToggleExtras.cgAT = menuToggleExtras.cgAT + 2
					end
					if v.cgCharacter == true or v.cgMain == true or v.cgBoss == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Custom Nacho Tokens"]})
					end
				end
				return 1
			end
			startLuaCoroutine(Global, "customPause")
		end
		function customPause1()
			if menuToggleExtras.cgCrisis == true then
				wait(0.2)
				infBag.C1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["C1 Custom CrisisStack"]})
				infBag.C2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["C2 Custom CrisisStack"]})
				infBag.C3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["C3 Custom CrisisStack"]})
				infBag.C4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["C4 Custom CrisisStack"]})
			end
			wait(1)
			if menuToggleExtras.cgDWT > 0 then
				local cgDWTchoice = {
				{set=infBag.EA1start, label="eca763", id="ESW Dead Wizard Tokens EA1"},
				{set=infBag.EGBstart, label="eeeddb", id="ESW Dead Wizard Tokens EGB"},
				{set=infBag.EGBstart, label="93b726", id="ESW Dead Wizard Tokens EA1+EGB"},
				{set=infBag.EA2start, label="c13ca5", id="ESW Dead Wizard Tokens EA2"},
				{set=infBag.EGBstart, label="39cb36", id="ESW Dead Wizard Tokens EA1+EA2"},
				{set=infBag.EGBstart, label="55e418", id="ESW Dead Wizard Tokens EA2+EGB"},
				{set=infBag.EGBstart, label="dd98a2", id="ESW Dead Wizard Tokens All"},}
				menuToggleExtras.eswDWT = cgDWTchoice[menuToggleExtras.cgDWT].label
				dwtValue = 4*#getSeatedPlayers()
				wait(0.2)
				infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Dead Wizard Tokens Empty"]})
				wait(0.2)
				cgDWTchoice[menuToggleExtras.cgDWT].set.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[cgDWTchoice[menuToggleExtras.cgDWT].id]})
				wait(0.2)
				infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Custom Health Trackers"]})
				Wait.frames(createDWTCustomButtons, 120)
			end
			if menuToggleExtras.cgAT > 0 then
				local cgATchoice = {
				{set=infBag.EA1start, id="Ability Tokens EA1"},
				{set=infBag.EA2start, id="Ability Tokens EA2"},
				{set=infBag.EGBstart, id="Ability Tokens All"},}
				wait(0.2)
				cgATchoice[menuToggleExtras.cgAT].set.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[cgATchoice[menuToggleExtras.cgAT].id]})
			end
			if menuToggleExtras.cgHands == true then
				wait(0.2)
				infBag.NSstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Naruto Custom Game Hand Signs"]})
			end
			if menuToggleExtras.cgEvents == true then
				wait(0.2)
				infBag.CNstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoon Events CN"]})
				infBag.AAstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoon Events AA"]})
				infBag.TTGstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoon Events TTG"]})
			end
			if menuToggleExtras.cgWeaknessStack == "Wacky" then
				wait(0.2)
				infBag.CNstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Weakness Cartoon CN"]})
				infBag.AAstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Weakness Cartoon AA"]})
				infBag.TTGstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Weakness Cartoon TTG"]})
			end
			for i, v in ipairs(menuToggleSetOptions) do
				if v.imgRep == menuToggleExtras.cgStarters then
					wait(4)
					bagSet = v.bagSet
					bagID = v.generalID
					starterID = v.imgRep
					if v.imgRep == "EGB" then
						bagID = "ESW All"
						starterID = "ESW All"
					end
					grabStarters()
				end
			end
			return 1
		end
		startLuaCoroutine(Global, "customPause1")
		Wait.frames(bossCountSetup, 120)
		resetYlist()
	end
end
function spawnGameChoice(player, value, id) -- 10/26/21 Needs Rework
	if player.color ~= "Grey" then
		--not playing a Cube Game
        dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		quickSetup = 2
		local currentPlayerCount = #getSeatedPlayers()
		local corePrint
		for i, v in ipairs(menuToggleSetOptions) do
			if baseImageRep == v.imgRep then
				bagID=v.standardID
				bagSet=v.bagSet
				starterID = v.imgRep
				if v.imgRep == "INJ" then
					playerBoardQuickEnable("Health")
					playerBoardQuickEnable("Meter")
				end
				corePrint=v.printName
				if v.mdValue == true then
					menuToggleSetOptions[i].mdValue = false
					self.UI.setAttribute(v.mdID, "isOn", "false")
				end
				if v.cValue == true then
					menuToggleSetOptions[i].cValue = false
					self.UI.setAttribute(v.cID, "isOn", "false")
				end
			end
			if expansionImageRep == v.imgRep then
				if v.mdValue == true then
					menuToggleSetOptions[i].mdValue = false
					self.UI.setAttribute(v.mdID, "isOn", "false")
				end
				if v.cValue == true then
					menuToggleSetOptions[i].cValue = false
					self.UI.setAttribute(v.cID, "isOn", "false")
				end
			end
		end
		printToAll(player.steam_name .. " is loading " .. corePrint .. ".")
		if expansionImageRep == "C1" then
			infBag.C1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic C1"]})
			infBag.C1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss C1"]})
			crisisRefill()
			specialSetUp = "CrisisWS"
			if currentPlayerCount == 3 then
				boss1Value = 1
				boss2Value = 9
				boss3Value = 1
			elseif currentPlayerCount == 4 then
				boss1Value = 1
				boss2Value = 7
				boss3Value = 1
			else
				boss1Value = 1
				boss2Value = 11
				boss3Value = 1
			end
		elseif expansionImageRep == "C2" then
			infBag.C2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic C2"]})
			infBag.C2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss C2"]})
			crisisRefill()
			specialSetUp = "CrisisWS"
			if currentPlayerCount == 3 then
				boss1Value = 1
				boss2Value = 9
				boss3Value = 1
			elseif currentPlayerCount == 4 then
				boss1Value = 1
				boss2Value = 7
				boss3Value = 1
			else
				boss1Value = 1
				boss2Value = 11
				boss3Value = 1
			end
		elseif expansionImageRep == "C3" then
			infBag.C3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic C3"]})
			infBag.C3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss C3"]})
			crisisRefill()
			specialSetUp = "CrisisWS"
			if currentPlayerCount == 3 then
				boss1Value = 1
				boss2Value = 5
				boss3Value = 1
			elseif currentPlayerCount == 4 then
				boss1Value = 1
				boss2Value = 3
				boss3Value = 1
			else
				boss1Value = 1
				boss2Value = 7
				boss3Value = 1
			end
		elseif expansionImageRep == "C4" then
			infBag.C4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic C4"]})
			infBag.C4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss C4"]})
			crisisRefill()
			if currentPlayerCount == 3 then
				boss1Value = 1
				boss2Value = 2
				boss3Value = 2
				boss4Value = 1
				boss5Value = 1
			elseif currentPlayerCount == 4 then
				boss1Value = 1
				boss2Value = 1
				boss3Value = 1
				boss4Value = 1
				boss5Value = 1
			else
				boss1Value = 1
				boss2Value = 2
				boss3Value = 3
				boss4Value = 2
				boss3Value = 1
			end
		elseif expansionImageRep == "CO1" then
			infBag.CO1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO1"]})
			boss1Value = 1
			boss2Value = 2
			boss3Value = 2
			boss4Value = 2
			boss5Value = 1
		elseif expansionImageRep == "CO2" then
			infBag.CO2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO2"]})
			boss1Value = 1
			boss2Value = 2
			boss3Value = 2
			boss4Value = 2
			boss5Value = 1
		elseif expansionImageRep == "CO3" then
			infBag.CO3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO3"]})
			boss1Value = 1
			boss2Value = 2
			boss3Value = 2
			boss4Value = 2
			boss5Value = 1
		elseif expansionImageRep == "CO4" then
			infBag.CO4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO4"]})
			Wait.frames(vmCO4random, 10)
			boss1Value = 1
			boss2Value = 1
			boss3Value = 1
			vmCO4 = math.random (1, 4)
			specialSetUp = "Watchmen"
		elseif expansionImageRep == "CO5" then
			infBag.CO5start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO5"]})
			boss1Value = 1
			boss2Value = 2
			boss3Value = 2
			boss4Value = 2
			boss5Value = 1
		elseif expansionImageRep == "CO6" then
			infBag.CO6start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO6"]})
			boss1Value = 1
			boss2Value = 2
			boss3Value = 2
			boss4Value = 2
			boss5Value = 1
		elseif expansionImageRep == "CO7" then
			infBag.CO7start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO7"]})
		elseif expansionImageRep == "CO8" then
			infBag.CO8start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO8"]})
		elseif expansionImageRep == "CO9" then
			boss1Value = 1
			boss2Value = 2
			boss3Value = 2
			boss4Value = 2
			boss5Value = 1
			infBag.CO9start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic CO9"]})
		end
		grabMainBag()
		grabStarters()
		Wait.frames(grabExtrasDCE, 60)
		Wait.frames(bossCountSetup, 120)
	end
end
function setupRivalGame(player, value, id)
	if player.color ~= "Grey" then
		dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		printToAll(player.steam_name .. " is loading a Rivals Custom Game")
		grabRivalsCards()
	end
end
function setupMultiverse(player, value, id)
	if player.color ~= "Grey" then
        dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		specialSetUp = "Multiverse"
		readyMultiverse = false
		quickSetup = 2
		local currentPlayerCount = #getSeatedPlayers()
		local corePrint
		local mvPrint
		--Setting Up Core Sets for Picked vs Not Picked
		for k, v in ipairs(menuToggleSetOptions) do
			if v.mvPicked == true then
				if v.mvValue == true then
					menuToggleSetOptions[k].mvValue = false
					self.UI.setAttribute(v.mvID, "isOn", "false")
				end
				bagID = v.generalID
				starterID = v.imgRep
				if v.imgRep == "INJ" then
					playerBoardQuickEnable("Health")
					playerBoardQuickEnable("Meter")
				end
				bagSet = v.bagSet
				corePrint = v.printName
				bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mvMainID]})
			elseif v.mvPicked == false then
				if v.mvValue == false then
					v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mvNotMainID]})
				end
			end
			if v.imgRep == "MV" then
				mvPrint = v.printName
			end
		end
		printToAll(player.steam_name .. " is loading " .. corePrint .. " for " .. mvPrint .. ".")
		--should be a wait frame function
		infBag.MVstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV"]})
		grabStarters()
		Wait.frames(grabMultiverseSetUp, 75)
		Wait.frames(bossCountSetup, 120)
	end
end
function setupLotR(player, value, id)
	if player.color ~= "Grey" then
        dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		specialSetUp = "LotR"
		quickSetup = 3
		local currentPlayerCount = #getSeatedPlayers()
		printToAll(player.steam_name .. " is loading [D4B52D]The Lord of the Rings [E61639]Custom Game[FFFFFF]...")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.isLOTR == true then
					function lotrPause()
						if v.startersLOTR == true then
							bagID = v.generalID
							bagSet = v.bagSet
							starterID = v.imgRep
							grabStarters()
						end
						if v.imgRep == "RotK" or v.imgRep == "DoS" then
							if v.bLOTR == true then
								boss4Value = 1
							end
						end
						if v.valorLOTR == true then
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.kBagID]})
						end
						if v.corruptionLOTR == true then
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.wBagID]})
						end
						if v.mainLOTR == true then
							wait(0.2)
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mdBagID]})
							menuToggleExtras.mdBagID_y = menuToggleExtras.mdBagID_y + 1.5
							registerTables()
						end
						if v.cLOTR == true then
							wait(0.2)
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
							menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
							registerTables()
						end
						if v.bLOTR == true then
							wait(0.2)
								if impossibleMode == false then
									v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.bBagID]})
								else
									v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.bBagID_IM]})
								end
							menuToggleExtras.bBagID_y = menuToggleExtras.bBagID_y + 1
							registerTables()
						end
						return 1
					end
					startLuaCoroutine(Global, "lotrPause")
				end
			end
		infBag.T2Tstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["2T - LotR Custom"]})
		infBag.RotKstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RotK - LotR Custom"]})
		infBag.UJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["UJ - LotR Custom"]})
		infBag.DoSstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["DoS - LotR Custom"]})
		if menuToggleExtras.ruleLOTR == true then
			function lotrPause2()
				wait(1)
				infBag.FotRstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["LotR Custom Rulebook FotR"]})
				infBag.T2Tstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["LotR Custom Rulebook 2T"]})
				infBag.RotKstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["LotR Custom Rulebook RotK"]})
				infBag.UJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["LotR Custom Rulebook UJ"]})
				infBag.DoSstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["LotR Custom Rulebook DoS"]})
				return 1
			end
			startLuaCoroutine(Global, "lotrPause2")
		end
		boss1Value = 1
		boss2Value = 2
		boss3Value = 3
		boss5Value = 1
		Wait.frames(bossCountSetup, 120)
		resetYlist()
	end
end
function setupCartoon(player, value, id)
	if player.color ~= "Grey" then
        dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		specialSetUp = "Cartoon"
		quickSetup = 3
		local currentPlayerCount = #getSeatedPlayers()
		printToAll(player.steam_name .. " is loading a [000000]Cartoon [FFFFFF]Network [E61639]Custom Game[FFFFFF]...")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.spawnCartoon == true then
					function cartoonPause()
						if v.cartoonStarters == true then
							bagID = v.generalID
							bagSet = v.bagSet
							starterID = v.imgRep
							grabStarters()
						end
						if v.cartoonJoke == true then
							wait(0.2)
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.kBagID]})
						end
						if v.cartoonWeakness == true then
							wait(0.2)
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.wBagCartoonID]})
							menuToggleExtras.wBagID_y = menuToggleExtras.wBagID_y + 1.5
							registerTables()
						end
						if v.cartoonMain == true then
							wait(0.2)
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mdBagID]})
							menuToggleExtras.mdBagID_y = menuToggleExtras.mdBagID_y + 1.5
							registerTables()
						end
						if v.cartoonCharacter == true then
							wait(0.2)
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
							menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
							registerTables()
						end
						if v.cartoonNemesis == true then
							wait(0.2)
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.bBagID]})
							menuToggleExtras.cBagID_y = menuToggleExtras.bBagID_y + 1
							registerTables()
						end
						return 1
					end
					startLuaCoroutine(Global, "cartoonPause")
				end
			end
		function cartoonPause3()
			if menuToggleExtras.stackTG == true then
				wait(0.2)
				infBag.TTGstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoons Titans Go TTG"]})
			end
			if menuToggleExtras.eventCartoon == true then
				wait(0.2)
				infBag.CNstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoon Events CN"]})
				infBag.AAstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoon Events AA"]})
				infBag.TTGstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoon Events TTG"]})
			end
			if menuToggleExtras.ruleCartoon == true then
				wait(1)
				infBag.AAstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoon Custom Rulebook AA"]})
				infBag.TTGstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Cartoon Custom Rulebook TTG"]})
			end
			return 1
		end
		startLuaCoroutine(Global, "cartoonPause3")
		boss1Value = 1
		boss2Value = 4
		boss3Value = 3
		Wait.frames(bossCountSetup, 120)
		resetYlist()
	end
end
function setupRickMorty(player, value, id)
	if player.color ~= "Grey" then
        dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		specialSetUp = "RickMorty"
		quickSetup = 3
		local currentPlayerCount = #getSeatedPlayers()
		printToAll(player.steam_name .. " is loading a [2B922C]Rick & Morty [E61639]Custom Game[FFFFFF]...")
			for i, v in ipairs(menuToggleSetOptions) do
				if v.spawnRickMorty == true then
					function rickmortyPause()
						if v.rmcStarters == true then
							bagID = v.generalID
							bagSet = v.bagSet
							starterID = v.imgRep
							grabStarters()
						end
						if v.rmcMortyWaves == true then
							wait(0.2)
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.kBagID]})
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.wBagID]})
						end
						return 1
					end
					startLuaCoroutine(Global, "rickmortyPause")
				end
			end
		function rickmortyPause()
			if menuToggleExtras.ruleRickMorty == true then
				wait(1)
				infBag.RM1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RickMorty Custom Rulebook RM1"]})
				infBag.RM2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RickMorty Custom Rulebook RM2"]})
			end
			wait(0.2)
			infBag.RM1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RickMorty Custom Locations RM1"]})
			infBag.RM2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RickMorty Custom Locations RM2"]})
			wait(0.2)
			infBag.RM1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["CM Nemesis RM1"]})
			infBag.RM2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["CM Nemesis RM2"]})
			wait(0.2)
			infBag.RM2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RickMorty Custom Access Tokens RM2"]})
			wait(0.2)
			infBag.RM1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MainDeck RM1"]})
			wait(0.2)
			infBag.RM1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters RM1"]})
			menuToggleExtras.mdBagID_y = menuToggleExtras.mdBagID_y + 2
			menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
			wait(0.2)
			if menuToggleExtras.councilRickMorty == false then
				infBag.RM2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RickMorty Custom Not Council RM2"]})
			else
				infBag.RM2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MainDeck RM2"]})
				infBag.RM2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters RM2"]})
			end
			return 1
		end
		startLuaCoroutine(Global, "rickmortyPause")
		boss1Value = 1
		boss2Value = 3
		boss3Value = 2
		boss5Value = 1
		Wait.frames(bossCountSetup, 120)
		resetYlist()
	end
end
function setupESW(player, value, id)
	if player.color ~= "Grey" then
        dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		specialSetUp = "ESW"
		quickSetup = 4
		local currentPlayerCount = #getSeatedPlayers()
		printToAll(player.steam_name .. " is loading [1F7096]Epic Spell Wars of the Battle Wizards [FFFFFF]Custom Game...")
		infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Wild Magic EA1"]})
		infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Limp Wand EA2"]})
		infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Dead Wizard Tokens Empty"]})
		for i, v in ipairs(menuToggleSetOptions) do
			if v.isESW == true then
				function eswPause()
					if v.mainESW == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.eswMain]})
						menuToggleExtras.mdBagID_y = menuToggleExtras.mdBagID_y + 1.5
						registerTables()
					end
					if v.mayhemESW == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mayhemID]})
						menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
						registerTables()
					end
					if v.bESW == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.eswLegend]})
						menuToggleExtras.bBagID_y = menuToggleExtras.bBagID_y + 1
						registerTables()
						if v.imgRep == "EA1" then
						boss1Value = 1
						boss2Value = 4
						boss3Value = 2
						end
						if v.imgRep == "EA2" then
							if v.mayhemESW == true then
								wait(0.2)
								v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mayhemMegaID]})
								menuToggleExtras.bBagID_y = menuToggleExtras.bBagID_y + 1
								registerTables()
							end
						end
					end
					if v.standeeESW == true then
						wait(0.2)
						v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.standeeID]})
						menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
						registerTables()
					end
					return 1
				end
				startLuaCoroutine(Global, "eswPause")
			end
		end
		infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Nacho Tokens"]})
		function eswPause2()
			if menuToggleExtras.eswGB == true then
				wait(0.2)
				infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Gang Bangers EGB"]})
			end
			if menuToggleExtras.eswVP == true then
				infBag.Promoall.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Promos VP"]})
			end
			if menuToggleExtras.ruleESW == true then
				wait(1)
				infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Custom Rulebook EA1"]})
				infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Custom Rulebook EA2"]})
				infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Custom Rulebook EGB"]})
				wait(1)
			end
			wait(0.2)
			if menuToggleExtras.abilityEA1 == true then
				if menuToggleExtras.abilityEA2 == true then
					infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Ability Tokens All"]})
				else
					infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Ability Tokens EA1"]})
				end
			else
				if menuToggleExtras.abilityEA2 == true then
					infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Ability Tokens EA2"]})
				end
			end
			wait(0.2)
			infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Characters EA1"]})
			infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Characters EA2"]})
			infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Characters EGB"]})
			wait(0.2)
			infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Health Trackers"]})
			wait(0.2)
			bagSet=infBag.EGBstart
			if menuToggleExtras.dwtEA1 == true then
				if menuToggleExtras.dwtEA2 == true then
					if menuToggleExtras.dwtEGB == true then
						bagID="ESW Dead Wizard Tokens All"
						menuToggleExtras.eswDWT="dd98a2"
					else
						bagID="ESW Dead Wizard Tokens EA1+EA2"
						menuToggleExtras.eswDWT="39cb36"
					end
				elseif menuToggleExtras.dwtEA2 == false and menuToggleExtras.dwtEGB == true then
					bagID="ESW Dead Wizard Tokens EA1+EGB"
					menuToggleExtras.eswDWT="93b726"
				else
					bagID="ESW Dead Wizard Tokens EA1"
					menuToggleExtras.eswDWT="eca763"
					bagSet=infBag.EA1start
				end
			elseif menuToggleExtras.dwtEA1 == false and menuToggleExtras.dwtEA2 == true then
				if menuToggleExtras.dwtEGB == true then
					bagID="ESW Dead Wizard Tokens EA2+EGB"
					menuToggleExtras.eswDWT="55e418"
				else
					bagID="ESW Dead Wizard Tokens EA2"
					menuToggleExtras.eswDWT="c13ca5"
					bagSet=infBag.EA2start
				end
			else
				if menuToggleExtras.dwtEGB == true then
					bagID="ESW Dead Wizard Tokens EGB"
					menuToggleExtras.eswDWT="eeeddb"
				else
					bagID="ESW Dead Wizard Tokens Empty"
					menuToggleExtras.eswDWT="ec6362"
				end
			end
			if bagID ~= "ESW Dead Wizard Tokens Empty" then
				bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[bagID]})
			end
			wait(0.2)
			bagSet=infBag.EGBstart
			if menuToggleExtras.eswWand == true then
				if menuToggleExtras.eswCheese == true then
					if menuToggleExtras.eswBlasting == true then
						bagID="ESW All"
						starterID = "ESW All"
					else
						bagID="ESW EA1+EA2"
						starterID = "ESW EA1+EA2"
					end
				elseif menuToggleExtras.eswCheese == false and menuToggleExtras.eswBlasting == true then
					bagID="ESW EA1+EGB"
					starterID = "ESW EA1+EGB"
				else
					bagID="Basic EA1"
					starterID = "EA1"
					bagSet=infBag.EA1start
				end
			elseif menuToggleExtras.eswWand == false and menuToggleExtras.eswCheese == true then
				if menuToggleExtras.eswBlasting == true then
					bagID="ESW EA2+EGB"
					starterID = "ESW EA2+EGB"
				else
					bagID="Basic EA2"
					starterID = "EA2"
					bagSet=infBag.EA2start
				end
			else
				if menuToggleExtras.eswBlasting == true then
					bagID="ESW EGB"
					starterID = "ESW EGB"
				else
					bagID="ESW None"
					starterID = "ESW None"
				end
			end
			grabStarters()
			return 1
		end
		startLuaCoroutine(Global, "eswPause2")
		Wait.frames(bossCountSetup, 120)
		broadcastToAll("[FF0000]WARNING: Epic Spell Wars is NSFW[FF0000]")
		resetYlist()
		playerBoardQuickEnable("Health")
	end
end
function setupGangBangers(player, value, id)
	if player.color ~= "Grey" then
		--not playing a Cube Game
        dcdbCubeGame = 0
		setupFreshStart(player, value, id)
		quickSetup = 4
		local currentPlayerCount = #getSeatedPlayers()
		for i, v in ipairs(menuToggleSetOptions) do
			if expansionRepESW == v.imgRep then
				bagID=v.standardID
				bagSet=v.bagSet
				if v.mdValue == true then
					menuToggleSetOptions[i].mdValue = false
					self.UI.setAttribute(v.mdID, "isOn", "false")
				end
				if v.cValue == true then
					menuToggleSetOptions[i].cValue = false
					self.UI.setAttribute(v.cID, "isOn", "false")
				end
			end
		end
		infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Dead Wizard Tokens Empty"]})
		infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Legend Stack EGB"]})
		function eswGBWait()
			wait(0.2)
			infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["c809da"]})
			wait(0.2)
			infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Health Trackers"]})
			wait(0.2)
			return 1
		end
		startLuaCoroutine(Global, "eswGBWait")
		grabMainBag()
		bagSet=infBag.EGBstart
		printToAll(player.steam_name .. " is loading Epic Spell Wars of the Battle Wizards - ANNIHILAGEDDON - Gang Bangers Expansion")
		if expansionRepESW == "EA1" then
			specialSetUp = "EGB+EA1"
			bagID="EGB EA1"
			starterID = "EGB EA1"
			infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Characters Only EA1"]})
		elseif expansionRepESW == "EA2" then
			specialSetUp = "EGB+EA2"
			bagID="EGB EA2"
			starterID = "EGB EA2"
			function eswEGBEA2wait()
				infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Characters Only EA2"]})
				wait(0.2)
				infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Legend EA2"]})
				wait(0.2)
				infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Nacho Shack"]})
				return 1
			end
			startLuaCoroutine(Global, "eswEGBEA2wait")
		end
		grabStarters()
		Wait.frames(bossCountSetup, 120)
		flipBoss = false
		self.UI.setAttribute("flipBossToggleON", "isOn", "false")
		self.UI.setAttribute("flipBossToggleOFF", "isOn", "true")
		broadcastToAll("[FF0000]WARNING: Epic Spell Wars is NSFW[FF0000]")
		printToAll("Boss Flipping have been [FF0000][b]Disabled[/b] [FFFFFF]for the Gang Bangers Expansion. They are set aside for certain cards to utilize")
		playerBoardQuickEnable("Health")
	end
end
--Main Set Up
function grabMainBag()
bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[bagID]})
end
function grabExtrasDCE()
	--Main Deck
	for i, v in ipairs(menuToggleSetOptions) do
		if v.mdValue == true then
			if v.imgRep == "INJ" then
				playerBoardQuickEnable("Health")
				playerBoardQuickEnable("Meter")
			elseif v.imgRep == "RB" then
				playerBoardQuickEnable("Move")
			end
			function pauseDCEMainDeck()
				menuToggleExtras.mdBagID_y = menuToggleExtras.mdBagID_y + 1.5
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mdBagID]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pauseDCEMainDeck")
		end
	end
	--Characters
	for i, v in ipairs(menuToggleSetOptions) do
		if v.cValue == true then
			if v.imgRep == "INJ" then
				playerBoardQuickEnable("Health")
				playerBoardQuickEnable("Meter")
			elseif v.imgRep == "RB" then
				playerBoardQuickEnable("Move")
			end
			function pauseDCECharacters()
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 0.5
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pauseDCECharacters")
		end
	end
	resetYlist()
	--Crisis Characters
	if menuToggleSetOptions[6].cValue == true then infBag.C1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters C1 Crisis"]}) end
	if menuToggleSetOptions[7].cValue == true then infBag.C2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters C2 Crisis"]}) end
	if menuToggleSetOptions[8].cValue == true then infBag.C3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters C3 Crisis"]}) end
	if menuToggleSetOptions[9].cValue == true then infBag.C4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters C4 Crisis"]}) end
end
function grabStarters()
	local currentPlayers = getSeatedPlayers()
	for i, color in ipairs(currentPlayers) do
		registerStarters(color)
		function starterPause()
			wait(1)
			return 1
		end
		startLuaCoroutine(Global, "starterPause")
	end
end
--Boss Set Up
function bossDC()
	if impossibleMode == false then
		infBag.DCstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss DC"]})
		boss1Value = 1
		boss2Value = 4
		boss3Value = 3
	else
		infBag.C1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["CM Boss C1"]})
		boss1Value = 1
		boss2Value = 4
		boss3Value = 2
		boss4Value = 1
	end
end
function bossHU()
	if impossibleMode == false then
		infBag.HUstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss HU"]})
		boss1Value = 1
		boss2Value = 3
		boss3Value = 4
	else
		infBag.C2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["CM Boss C2"]})
		boss1Value = 1
		boss2Value = 2
		boss3Value = 3
		boss4Value = 2
	end
end
function bossFE()
	if impossibleMode == false then
		infBag.FEstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss FE"]})
		boss1Value = 1
		boss2Value = 3
		boss3Value = 3
		boss4Value = 1
	else
		infBag.C3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["CM Boss C3"]})
		boss1Value = 1
		boss2Value = 2
		boss3Value = 3
		boss4Value = 2
	end
end
function bossTT()
	if impossibleMode == false then
		infBag.TTstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss TT"]})
		boss1Value = 1
		boss2Value = 3
		boss3Value = 3
		boss5Value = 1
	else
		infBag.C4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["CM Boss C4"]})
		boss1Value = 1
		boss2Value = 2
		boss3Value = 5
	end
end
function bossDNM()
	infBag.DNMstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss DNM"]})
	boss2Value = 3
	boss3Value = 3
	boss5Value = 1
end
function bossINJ()
	infBag.INJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss INJ"]})
	infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Dead Wizard Tokens Empty"]})
	boss1Value = 1
	boss2Value = 3
	boss3Value = 2
	boss5Value = 1
	function injWait()
		if impossibleMode == true then
			wait(1)
			infBag.INJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Mayhem INJ"]})
		end
		wait(1)
		infBag.INJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["INJ KO'd Tokens"]})
		return 1
	end
	startLuaCoroutine(Global, "injWait")
end
function bossFotR()
	if impossibleMode == false then
		infBag.FotRstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss FotR"]})
		boss1Value = 1
		boss2Value = 3
		boss3Value = 3
		boss5Value = 1
	else
		infBag.FotRstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss FotR IM"]})
		Wait.frames(shuffleMainDeck, 360)
	end
end
function boss2T()
	if impossibleMode == false then
		infBag.T2Tstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss 2T"]})
		boss1Value = 1
		boss2Value = 3
		boss3Value = 3
		boss5Value = 1
	else
		infBag.T2Tstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss 2T IM"]})
		Wait.frames(shuffleMainDeck, 360)
	end
end
function bossRotK()
	if impossibleMode == false then
		infBag.RotKstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss RotK"]})
		boss1Value = 1
		boss2Value = 2
		boss3Value = 3
		boss4Value = 1
		boss5Value = 1
	else
		infBag.RotKstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss RotK IM"]})
		Wait.frames(shuffleMainDeck, 360)
	end
end
function bossUJ()
	boss1Value = 4
	boss2Value = 4
	if impossibleMode == false then
		infBag.UJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss UJ"]})
	else
		infBag.UJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss UJ IM"]})
		Wait.frames(shuffleMainDeck, 360)
	end
end
function bossDoS()
	boss1Value = 2
	boss2Value = 2
	boss3Value = 4
	infBag.DoSstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Basic DoS"]})
	if impossibleMode == false then
		infBag.UJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss UJ"]})
		infBag.DoSstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss DoS"]})
	else
		infBag.UJstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss UJ IM"]})
		infBag.DoSstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss DoS IM"]})
		Wait.frames(shuffleMainDeck, 360)
	end
end
function bossTTG()
	infBag.TTGstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Boss TTG"]})
	boss1Value = 1
	boss2Value = 7
end
function bossESW()
	if specialSetUp == "EA1" then
		infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Dead Wizard Tokens Empty"]})
		infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Legend EA1"]})
		boss1Value = 1
		boss2Value = 4
		boss3Value = 2
		function esw1Wait()
			wait(1)
			infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Characters EA1"]})
			infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Characters EGB"]})
			wait(1)
			infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Dead Wizard Tokens EA1"]})
			infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Health Trackers"]})
			wait(1)
			infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Trophy Standee EA1"]})
			wait(1)
			infBag.EA1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Ability Tokens EA1"]})
			return 1
		end
		startLuaCoroutine(Global, "esw1Wait")
	elseif specialSetUp == "EA2" then
		infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Dead Wizard Tokens Empty"]})
		infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Legend EA2"]})
		function esw2Wait()
			wait(1)
			infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Characters EA2"]})
			infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Health Trackers"]})
			wait(1)
			infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Dead Wizard Tokens EA2"]})
			wait(1)
			infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Trophy Standee EA2"]})
			wait(1)
			infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Ability Tokens EA2"]})
			wait(1)
			infBag.EA2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Nacho Shack Inactive"]})
			return 1
		end
		startLuaCoroutine(Global, "esw2Wait")
	end
end
--Rivals Set Up
function grabRivalsCards() -- Places Rival Cards on the Table for Rival Custom Game
	local waitOne = true
	local allRivialsCharacters = true
	menuToggleExtras.rivals_R3extras = false
	for i, v in pairs(menuToggleRivalsCharacters) do
		if v.isEnabled == false then
			allRivialsCharacters = false
			break
		end
	end
	if waitOne == true then
		function rivalsWait()
			if allRivialsCharacters == true then
				menuToggleExtras.mdBagID_y = 2
				infBag.R1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MainDeck R1"]})
				menuToggleExtras.mdBagID_y = 4
				wait(0.2)
				infBag.R2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MainDeck R2"]})
				menuToggleExtras.mdBagID_y = 6
				wait(0.2)
				infBag.R3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MainDeck R3"]})
				menuToggleExtras.mdBagID_y = 8
				wait(0.2)
				infBag.RCstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MainDeck RC"]})
				wait(0.2)
				spawnCharactersRivals()
				wait(0.2)
			else
				for i, v in pairs(menuToggleRivalsCharacters) do
					if v.isEnabled == true then
						menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 0.5
						local tempBag_Rivals = v.bag
						local tempPlacement_RivalsC = v.params
						tempBag_Rivals.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[tempPlacement_RivalsC]})
						registerTables()
						wait(0.2)
						if v.name == "isR3_H" or v.name == "isR3_V" then
							menuToggleExtras.rivals_R3extras = true
						end
					end
				end
				if menuToggleExtras.rivals_R3extras == true then
					infBag.R3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Rivals R3 Extras"]})
				end
			end
			for i, v in ipairs(menuToggleSetOptions) do
				if v.spawnRivals == true then
					if v.rivalsStarters == true then
						bagID = v.generalID
						bagSet = v.bagSet
						starterID = v.imgRep
						grabStarters()
					end
					if v.rivalsKick == true then
						wait(0.2)
						if menuToggleExtras.rivals_kick8 == false then
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.kBagID]})
						else
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.kBagID8]})
						end
					end
					if v.rivalsWeakness == true then
						wait(0.2)
						if menuToggleExtras.rivals_weakness10 == false then
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.wBagID]})
						else
							v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.wBagID10]})
						end
					end
				end
			end
			if menuToggleExtras.ruleRivals == true then
				wait(1)
				infBag.RCstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Rivals RuleBook RC"]})
				infBag.MVstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Rivals RuleBook MV"]})
			end
			return 1
		end
		startLuaCoroutine(Global, "rivalsWait")
	end
	Wait.frames(shuffleMainDeck, 300)
end

--************************Multiverse************************--

function grabMultiverseSetUp() -- Grabs MCs, Decks, Villains, and Crisis card for Multiverse
	--Grabbing Multiverse Characters, and Decks
	for i, v in ipairs(menuToggleSetOptions) do
		if v.mvValue == false then
			if v.mvCore ~= nil then
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 0.5
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.mvCore]})
				if v.imgRep == "INJ" then
					playerBoardQuickEnable("Health")
					playerBoardQuickEnable("Meter")
				elseif v.imgRep == "RB" then
					playerBoardQuickEnable("Move")
				end
			end
		end
	end
	--Grabbing Multiverse Champions for Short Game
	if menuToggleExtras.mvGameModeStandard == true then
		infBag.MVstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV_Standard"]})
	else
		infBag.MVstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV_Impossible"]})
	end
	--Grabbing Multiverse Champions for Standard Game
	function grabMultiverseWait()
		wait(0.5)
		if menuToggleExtras.mvGameModeStandard == true then
			if menuToggleExtras.mvGameLengthStandard == true then
				infBag.MVstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV_StandardExtra"]})
			end
		else
			if menuToggleExtras.mvGameLengthStandard == true then
				infBag.MVstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV_ImpossibleExtra"]})
			end
		end
		--Grabbing Crisis Cards, and Crisis Event card if enabled
		if menuToggleExtras.mvAddCrisis == true then
			wait(0.5)
			infBag.MVstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV_CrisisEvent"]})
			infBag.C1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV_C1_CrisisStack"]})
			infBag.C2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV_C2_CrisisStack"]})
			infBag.C3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["MV_C3_CrisisStack"]})
		end
		return 1
	end
	startLuaCoroutine(Global, "grabMultiverseWait")
end
function grabRandomizer() -- Grabs Randomizer Card, Reads It, and Runs the grabEventLineUP function
	local found = false
	local objInZone = zTable.zOther2.getObjects() -- Grab everything in Script Zone
	for index, foundObjInZone in ipairs(objInZone) do -- Search Script Zone
		if foundObjInZone.type  == "Deck" then  -- If you Found Deck in Zone
			local deckRandmoizer = foundObjInZone.getObjects() -- Grab everything in Deck Found
			for j, card in ipairs(deckRandmoizer) do -- Search Deck
				local cardGuide = card.guid
				local params = {position = {zTable.zOther1.getPosition().x,2.5,zTable.zOther1.getPosition().z}, rotation ={0,180,0}, guid = cardGuide}
				local cardGuid = {}
				while found == false do -- While Loop
					local object = nil
					for x, y in ipairs(menuToggleSetOptions) do
						if card.nickname == y.mvRep then
						object = y.mvDeck
						end
					end
					foundObjInZone.takeObject(params)
					grabEventLineUP(object)
					found = true -- End While Loop
				end
			end
		elseif foundObjInZone.type  == "Card" then
			while found == false do -- While Loop
				local object = nil
				for x, y in ipairs(menuToggleSetOptions) do
					if foundObjInZone.getName() == y.mvRep then
					object = y.mvDeck
					end
				end
				foundObjInZone.setPosition({zTable.zOther1.getPosition().x,2.5,zTable.zOther1.getPosition().z})
				foundObjInZone.setRotation({0,180,0})
				grabEventLineUP(object)
				found = true -- End While Loop
			end
		end
	end
end
function grabEventLineUP(object) -- Adds an Event LineUP based on the Randomizer Card found
	for i, zone in ipairs(eventSlots) do
		local c=0
		local objInZone = zone.slotZone.getObjects()
		for k,v in pairs(objInZone) do
			if v.type  == "Card" or v.type  == "Deck" then
				c=c+1
			end
		end
		if c==0 then
			if object.type  == "Deck" then
				fillSpecificLineupSlot(object, zone.slotZone)
			else
				object.setPosition(zone.slotZone.getPosition())
				object.setRotation({0,180,0})
			end
		end
	end
end
function shuffleMultiverse() -- Shuffles All Multiverse Core Decks at Start
	for key, value in pairs(menuToggleSetOptions) do
		if value.mvValue == false then
			value.mvDeck.shuffle()
		end
	end
end

--************************Rebirth Stuff************************--

function createRebirthButton() -- Creates Buttons for Rebirth
    zTable.zCharacter.createButton({label="Cooperative", click_function="setupCooperative", position={0,0.1,1}, rotation={0,180,0}, height=125, width=700, font_size=120})
	zTable.zCharacter.createButton({label="Competitive", click_function="setupCompetitive", position={0,0.1,0.5}, rotation={0,180,0}, height=125, width=700, font_size=120})
	zTable.zCharacter.createButton({label="Training", click_function="setupTraining", position={0,0.1,0}, rotation={0,180,0}, height=125, width=700, font_size=120})
	zTable.zCharacter.createButton({label="Scenario 1", click_function="setupScenario1", position={-1.5,0.1,1}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Scenario 2", click_function="setupScenario2", position={-2.95,0.1,1}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Scenario 3", click_function="setupScenario3", position={-4.4,0.1,1}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Scenario 4", click_function="setupScenario4", position={-5.85,0.1,1}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Scenario 5", click_function="setupScenario5", position={-1.5,0.1,-0.8}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Scenario 6", click_function="setupScenario6", position={-2.95,0.1,-0.8}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Scenario 7", click_function="setupScenario7", position={-4.4,0.1,-0.8}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Scenario 8", click_function="setupScenario8", position={-5.85,0.1,-0.8}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="[b]Rebirth\nCampaign\nLog[/b]", click_function="getRBCampaignLog", position={-7.8,0.1,-0.8}, rotation={0,180,0}, height=450, width=650, font_size=125})
	zTable.zCharacter.createButton({label="[b]Spoilers & Unlocks[/b]", click_function="none", position={2.95,0.1,2.5}, rotation={0,180,0}, height=150, width=1150, font_size=125})
	zTable.zCharacter.createButton({label="Krypto", click_function="none", position={2.95,0.1,2}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Recruit", click_function="recruitKrypto", position={3.35,0.1,1.6}, rotation={0,180,0}, height=125, width=400, font_size=80})
	zTable.zCharacter.createButton({label="Unlocked", click_function="unlockKrypto", position={2.55,0.1,1.6}, rotation={0,180,0}, height=125, width=400, font_size=80})
	zTable.zCharacter.createButton({label="The Ray", click_function="none", position={2.95,0.1,1.1}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Recruit", click_function="recruitTheRay", position={3.35,0.1,0.7}, rotation={0,180,0}, height=125, width=400, font_size=80})
	zTable.zCharacter.createButton({label="Unlocked", click_function="unlockTheRay", position={2.55,0.1,0.7}, rotation={0,180,0}, height=125, width=400, font_size=80})
	zTable.zCharacter.createButton({label="Repairs", click_function="unlockRepair", position={2.95,0.1,0.2}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Spoiler 1", click_function="unlockSpoiler1", position={2.95,0.1,-0.3}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Spoiler 2", click_function="unlockSpoiler2", position={2.95,0.1,-0.7}, rotation={0,180,0}, height=125, width=650, font_size=120})
	zTable.zCharacter.createButton({label="Spoiler 3", click_function="unlockSpoiler3", position={2.95,0.1,-1.1}, rotation={0,180,0}, height=125, width=650, font_size=120})
end
function getRBCampaignLog()
infBag.RBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Log"]})
printToAll("[000000][b]Important[/b] [FFFFFF]Save your Rebirth Campaign Sheet after Every Scenario!")
end
function recruitKrypto()
registerRebirth()
infBagRebirth.RBSP2.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Recruit Krypto"]})
end
function unlockKrypto()
registerRebirth()
local infinitebagRBUK = {["47b01f"] = {{position={-10.57, 5, 2.47}, rotation={0, 180, 180}, smooth=false, guid="c1a366"},}}
infBagRebirth.RBSP2.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Unlock Krypto"]})
end
function recruitTheRay()
registerRebirth()
infBagRebirth.RBSP2.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Recruit The Ray"]})
end
function unlockTheRay()
registerRebirth()
local infinitebagRBUR = {["47b01f"] = {{position={-10.57, 5, 2.47}, rotation={0, 180, 180}, smooth=false, guid="8e8436"},}}
infBagRebirth.RBSP2.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Unlock The Ray"]})
end
function unlockRepair()
registerRebirth()
infBagRebirth.RBSP2.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Repairs"]})
end
function unlockSpoiler1()
registerRebirth()
infBagRebirth.RBSP3.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Unlock Mister Mxyzptlk"]})
end
function unlockSpoiler2()
registerRebirth()
infBagRebirth.RBSP5.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Unlock Starro"]})
end
function unlockSpoiler3()
registerRebirth()
infBagRebirth.RBSP8.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Unlock Impossible Mode"]})
end
function setupCooperative()
	registerRebirth()
	boss2Value = 2
	boss3Value = 2
	boss4Value = 2
	boss5Value = 2
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 300)
	rebirthShuffle5Locations()
	rebirthShuffle7Locations()
	runRBLocationCheck()
end
function setupCompetitive()
	registerRebirth()
	RBTT.setRotation{0, 180, 0}
	RBTTExtra.setRotation{0, 180, 0}
	boss2Value = 2
	boss3Value = 2
	boss4Value = 2
	boss5Value = 2
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 300)
	rebirthShuffle5Locations()
	rebirthShuffle7Locations()
	runRBLocationCheck()
end
function setupTraining()
	registerRebirth()
	local objectsInZone = zTable.zMainDeck.getObjects()
		for i, object in ipairs(objectsInZone) do
			if object.type  == "Deck" then
				object.shuffle()
				object.cut(35)
				object.setPositionSmooth(destroyPileZone.rfgZone.getPosition())
				break
			end
		end
	local function getterdone()
		local objectsInZone = zTable.zMainDeck.getObjects()
			for i, object in ipairs(objectsInZone) do
				if object.type  == "Deck" then
					object.shuffle()
					object.cut(30)
					object.setPositionSmooth({zTable.zBoss3.getPosition()})
					object.setRotation({0, 180, 180})
					break
				end
			end
	end
	local function getterdone2()
		local objectsInZone = zTable.zMainDeck.getObjects()
		for i, object in ipairs(objectsInZone) do
			if object.type  == "Deck" then
				rebirthStacks = object.split(2)
				local function moveTrainingStacks()
					rebirthStacks[1].setPosition(zTable.zBoss1.getPosition())
					rebirthStacks[1].setRotationSmooth({0, 180, 180})
					rebirthStacks[2].setPosition(zTable.zBoss2.getPosition())
					rebirthStacks[2].setRotationSmooth({0, 180, 180})
				end
				moveTrainingStacks()
			end
		end
	end
	local function getterdone3()
	    for _, object in ipairs(zTable.zBossStack.getObjects()) do
			if object.type  == 'Deck' then
				currentBossDeck = object
				currentBossDeck.takeObject({guid="156eb2", position=zTable.zBoss2.getPosition(), rotation={0,180,180}})
				currentBossDeck.takeObject({guid="73c5d2", position=zTable.zBoss2.getPosition(), rotation={0,180,180}})
			end
		end
	end
	Wait.frames(getterdone, 20)
	Wait.frames(getterdone2, 40)
	getterdone3()
	local function getterdone4()
		for _, object in ipairs(zTable.zBoss1.getObjects()) do
			if object.type  == 'Deck' then
				local pile1 = object
				pile1.shuffle()
				pile1.setPositionSmooth({-10.57,5,2.47})
			end
		end
		for _, object in ipairs(zTable.zBoss2.getObjects()) do
			if object.type  == 'Deck' then
				local pile2 = object
				pile2.shuffle()
				pile2.setPositionSmooth({-10.57,3,2.47})
			end
		end
		for _, object in ipairs(zTable.zBoss3.getObjects()) do
			if object.type  == 'Deck' then
				local pile3 = object
				pile3.shuffle()
				pile3.setPositionSmooth({-10.57,1.25,2.47})
			end
		end
	end
	Wait.frames(getterdone4, 200)
	rebirthShuffle5Locations()
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker Blank - L1"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker Blank - L2"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker Blank - L3"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker Blank - L5"]})
	local tc = getObjectFromGUID('689aa3')
	tc.setPosition({-10.57, 1.5, -2.34})
	tc.setRotation({0, 180, 0})
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Daily" then
			rbLocationCheck[k].spot = locationRB1
		elseif v.name == "Police" then
			rbLocationCheck[k].spot = locationRB2
		elseif v.name == "STAR" then
			rbLocationCheck[k].spot = locationRB3
		elseif v.name == "Arkham" then
			rbLocationCheck[k].spot = locationRB4
			rbLocationCheck[k].sideA = false
		elseif v.name == "City" then
			rbLocationCheck[k].spot = locationRB5
			rbLocationCheck[k].sideA = false
		end
	end
	runRBLocationCheck()
end
function setupScenario1()
	registerRebirth()
	local currentPlayerCount = #getSeatedPlayers() --Gets Seat Count for Later
	boss2Value = 2 --Values for Amount of Bosses to Pull, in this case 2, for Stack 2
	boss3Value = 2
	boss4Value = 2
	boss5Value = 2
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 300) -- Time needed to Return Stacks in order
	infBagRebirth.RBSP1.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Scenario 1"]}) -- Places Default Threat Tracker Token
	if currentPlayerCount < 3 then -- If Seated Players less then 3, then do following
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker A - L2/T2"]})
	end
	rebirthShuffle5Locations()
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Arkham" then
			rbLocationCheck[k].spot = locationRB1
		elseif v.name == "Daily" then
			rbLocationCheck[k].spot = locationRB2
		elseif v.name == "Batcave" then
			rbLocationCheck[k].spot = locationRB3
			rbLocationCheck[k].sideA = false
		elseif v.name == "City" then
			rbLocationCheck[k].spot = locationRB4
			rbLocationCheck[k].sideA = false
		elseif v.name == "Police" then
			rbLocationCheck[k].spot = locationRB5
			rbLocationCheck[k].sideA = false
		end
	end
	runRBLocationCheck() -- checks that value, and pulls to correct spot on the board
	printToAll("[800080][b]Important![/b] [FFFFFF]After you Beat Scenario 1 you Unlock your Signature [b]1[/b] cards for the [b]Rest of the Campaign[/b]! These [b]Replace[/b] a [b]Punch[/b] card in your starting deck")
end
function setupScenario2()
	registerRebirth()
	local currentPlayerCount = #getSeatedPlayers()
	boss2Value = 2
	boss3Value = 2
	boss4Value = 2
	boss5Value = 2
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 300)
	infBagRebirth.RBSP2.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Scenario 2"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker F - L0/T2"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker B - L4/T1"]})
	if currentPlayerCount < 3 then
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker E - L1/T2"]})
	end
	rebirthShuffle5Locations()
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Arkham" then
			rbLocationCheck[k].spot = locationRB1
			rbLocationCheck[k].sideA = false
		elseif v.name == "Bank" then
			rbLocationCheck[k].spot = locationRB2
			rbLocationCheck[k].sideA = false
		elseif v.name == "City" then
			rbLocationCheck[k].spot = locationRB3
		elseif v.name == "STAR" then
			rbLocationCheck[k].spot = locationRB4
			rbLocationCheck[k].sideA = false
		elseif v.name == "Police" then
			rbLocationCheck[k].spot = locationRB5
		end
	end
	runRBLocationCheck()
	printToAll("[800080][b]Important![/b] [FFFFFF]Before any Future game, Go to the Spoilers and select if you Unlocked Krypto or The Ray. If you have not, then Select Recruit. Repairs can also be called from this Menu, Reminder that it is a [b]One Time Use[/b] for your Campaign")
end
function setupScenario3()
	registerRebirth()
	local currentPlayerCount = #getSeatedPlayers()
	local function fuckDoomsday()
	    for _, object in ipairs(zTable.zBossStack.getObjects()) do
			if object.type  == 'Deck' then
				currentBossDeck = object
				currentBossDeck.takeObject({guid="0e45f6", position=destroyPileZone.rfgZone.getPosition(), rotation={0,180,180}})
			end
		end
	end
	fuckDoomsday()
	infBagRebirth.RBSP3.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Scenario 3"]})
	splitRebirth()
	boss2Value = 1
	boss3Value = 2
	boss4Value = 2
	boss5Value = 2
	Wait.frames(runSplitBossShuffle, 200)
	Wait.frames(returnRebirth, 800)
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker B - L4/T1"]})
	if currentPlayerCount < 3 then
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker A - L2/T2"]})
	end
	rebirthShuffle5Locations()
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Arkham" then
			rbLocationCheck[k].spot = locationRB1
		elseif v.name == "City" then
			rbLocationCheck[k].spot = locationRB2
		elseif v.name == "Daily" then
			rbLocationCheck[k].spot = locationRB3
			rbLocationCheck[k].sideA = false
		elseif v.name == "Police" then
			rbLocationCheck[k].spot = locationRB4
		elseif v.name == "STAR" then
			rbLocationCheck[k].spot = locationRB5
			rbLocationCheck[k].sideA = false
		end
	end
	runRBLocationCheck()
end
function setupScenario4()
	registerRebirth()
	local currentPlayerCount = #getSeatedPlayers()
	boss2Value = 2
	boss3Value = 2
	boss4Value = 2
	boss5Value = 1
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 300)
	infBagRebirth.RBSP4.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Scenario 4"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker D - L0/T2"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker B - L4/T1"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker H - L2/T1"]})
	if currentPlayerCount < 3 then
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker A - L2/T2"]})
	end
	rebirthShuffle5Locations()
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Bank" then
			rbLocationCheck[k].spot = locationRB1
		elseif v.name == "Daily" then
			rbLocationCheck[k].spot = locationRB2
		elseif v.name == "Police" then
			rbLocationCheck[k].spot = locationRB3
		elseif v.name == "Arkham" then
			rbLocationCheck[k].spot = locationRB4
			rbLocationCheck[k].sideA = false
		elseif v.name == "Batcave" then
			rbLocationCheck[k].spot = locationRB5
			rbLocationCheck[k].sideA = false
		end
	end
	runRBLocationCheck()
	printToAll("[800080][b]Congratulations![/b] [FFFFFF]You Have Unlocked [FF0000][b]Mister Mxyzptlk[/b][FFFFFF], Before any Rebirth Game, click on Spoiler 1 to add it to a game.")
	printToAll("[800080][b]Important[/b] [FFFFFF]Players who did not Earn their Signature [b]2[/b] cards Gain them now for the [b]Rest of the Campaign[/b]! These [b]Replace[/b] a [b]Punch[/b] card in your starting deck")
end
function setupScenario5()
	registerRebirth()
	local currentPlayerCount = #getSeatedPlayers()
	boss2Value = 2
	boss3Value = 1
	boss4Value = 2
	boss5Value = 2
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 400)
	infBagRebirth.RBSP5.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Scenario 5"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker B - L4/T1"]})
	if currentPlayerCount < 3 then
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker A - L2/T2"]})
	end
	rebirthShuffle5Locations()
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Batcave" then
			rbLocationCheck[k].spot = locationRB1
		elseif v.name == "Daily" then
			rbLocationCheck[k].spot = locationRB2
		elseif v.name == "STAR" then
			rbLocationCheck[k].spot = locationRB3
		elseif v.name == "City" then
			rbLocationCheck[k].spot = locationRB4
			rbLocationCheck[k].sideA = false
		elseif v.name == "Bank" then
			rbLocationCheck[k].spot = locationRB5
			rbLocationCheck[k].sideA = false
		end
	end
	runRBLocationCheck()
end
function setupScenario6()
	registerRebirth()
	local currentPlayerCount = #getSeatedPlayers()
	boss2Value = 2
	boss3Value = 2
	boss4Value = 2
	boss5Value = 1
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 300)
	infBagRebirth.RBSP6.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Scenario 6"]})
	if currentPlayerCount < 3 then
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker C - L1/T1"]})
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker G - L2/T2"]})
	else
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker C - L1/T1"]})
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker G - L2/T2"]})
	end
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker B - L3/T1"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker A - L4/T1"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker I - L5/T1"]})
	rebirthShuffle5Locations()
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Bank" then
			rbLocationCheck[k].spot = locationRB1
		elseif v.name == "Daily" then
			rbLocationCheck[k].spot = locationRB2
		elseif v.name == "Arkham" then
			rbLocationCheck[k].spot = locationRB3
			rbLocationCheck[k].sideA = false
		elseif v.name == "Police" then
			rbLocationCheck[k].spot = locationRB4
			rbLocationCheck[k].sideA = false
		elseif v.name == "STAR" then
			rbLocationCheck[k].spot = locationRB5
			rbLocationCheck[k].sideA = false
		end
	end
	runRBLocationCheck()
	printToAll("[800080][b]Congratulations![/b] [FFFFFF]You Have Unlocked [FF0000][b]Starro[/b][FFFFFF], Before any Rebirth Game, click on Spoiler 2 to add it to a game.")
end
function setupScenario7()
	registerRebirth()
	boss2Value = 2
	boss3Value = 2
	boss4Value = 2
	boss5Value = 1
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 300)
	infBagRebirth.RBSP7.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Scenario 7"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker B - L4/T1"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker Blank - L2"]})
	printToAll("[FF0000][b]Important![/b] [FFFFFF]Keep Track of Destroyed Cards, You'll Need to Remove them Before you start Scenario 8, This Mod Will Not Track it For You.")
	rebirthShuffle5Locations()
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Batcave" then
			rbLocationCheck[k].spot = locationRB1
		elseif v.name == "STAR" then
			rbLocationCheck[k].spot = locationRB2
		elseif v.name == "Bank" then
			rbLocationCheck[k].spot = locationRB3
			rbLocationCheck[k].sideA = false
		elseif v.name == "City" then
			rbLocationCheck[k].spot = locationRB4
			rbLocationCheck[k].sideA = false
		elseif v.name == "Daily" then
			rbLocationCheck[k].spot = locationRB5
			rbLocationCheck[k].sideA = false
		end
	end
	runRBLocationCheck()
	printToAll("[800080][b]Important[/b] [FFFFFF]Players who did not Earn their Signature [b]3[/b] cards Gain them now for the [b]Rest of the Campaign[/b]! These [b]Replace[/b] a [b]Punch[/b] card in your starting deck")
end
function setupScenario8()
	registerRebirth()
	local currentPlayerCount = #getSeatedPlayers()
	boss3Value = 2
	boss4Value = 2
	boss5Value = 2
	runSplitBossShuffle()
	Wait.frames(returnRebirth, 400)
	infBagRebirth.RBSP8.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Scenario 8"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker Blank - L1"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker B - L2/T1"]})
	infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker A - L4/T1"]})
	if currentPlayerCount < 3 then
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker C - L3/T1"]})
	else
		infBagRebirth.RBTTA.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["RB Tracker Blank - L3"]})
	end
	local function shuffle4Now (t,from, to)  -- second, exclude duplicates
	local num = math.random (from, to)
		if t[num] then  num = shuffle4Now (t, from, to)   end
		t[num]=num
		return num
	end
	local t = {}    -- initialize  table with not duplicate values
	for k ,v in ipairs(rbLocationCheck) do
		if v.name == "Arkham" then
			rbLocationCheck[k].spot = 1
		elseif v.name == "Bank" then
			rbLocationCheck[k].spot = shuffle4Now (t, 2, 5)
		elseif v.name == "Police" then
			rbLocationCheck[k].spot = shuffle4Now (t, 2, 5)
		elseif v.name == "Batcave" then
			rbLocationCheck[k].spot = shuffle4Now (t, 2, 5)
			rbLocationCheck[k].sideA = false
		elseif v.name == "City" then
			rbLocationCheck[k].spot = shuffle4Now (t, 2, 5)
			rbLocationCheck[k].sideA = false
		end
	end
	runRBLocationCheck()
	printToAll("[800080][b]Congratulations![/b] [FFFFFF]You Have Unlocked [FF0000][b]Impossible Mode[/b][FFFFFF], Before any Rebirth Game, click on Spoiler 3 to have on the Board.")
end
function rebirthBoss() -- Adds Bosses to Rebirth Stacks
    local currentBossDeck = nil
    -- try to find a Deck
    for _, object in ipairs(zTable.zBossStack.getObjects()) do
        if object.type  == 'Deck' then
            currentBossDeck = object
			currentBossDeck.shuffle()
			function moveRebirthBoss()
				wait(0.6)
				if boss2Value == 2 then
					currentBossDeck.takeObject({position=zTable.zBoss2.getPosition(), rotation={0,180,180}})
					currentBossDeck.takeObject({position=zTable.zBoss2.getPosition(), rotation={0,180,180}})
				elseif boss2Value == 1 then
					currentBossDeck.takeObject({position=zTable.zBoss2.getPosition(), rotation={0,180,180}})
				end
				if boss3Value == 2 then
					currentBossDeck.takeObject({position=zTable.zBoss3.getPosition(), rotation={0,180,180}})
					currentBossDeck.takeObject({position=zTable.zBoss3.getPosition(), rotation={0,180,180}})
				elseif boss3Value == 1 then
					currentBossDeck.takeObject({position=zTable.zBoss3.getPosition(), rotation={0,180,180}})
				end
				if boss4Value == 2 then
					currentBossDeck.takeObject({position=zTable.zBoss4.getPosition(), rotation={0,180,180}})
					currentBossDeck.takeObject({position=zTable.zBoss4.getPosition(), rotation={0,180,180}})
				elseif boss4Value == 1 then
					currentBossDeck.takeObject({position=zTable.zBoss4.getPosition(), rotation={0,180,180}})
				end
				if boss5Value == 2 then
					currentBossDeck.takeObject({position=zTable.zBoss5.getPosition(), rotation={0,180,180}})
					currentBossDeck.takeObject({position=zTable.zBoss5.getPosition(), rotation={0,180,180}})
				elseif boss5Value == 1 then
					currentBossDeck.takeObject({position=zTable.zBoss5.getPosition(), rotation={0,180,180}})
				end
				return 1
			end
		startLuaCoroutine(Global, "moveRebirthBoss")
		break
        end
    end
end
function splitRebirth() -- Splits Rebirth into 5 stacks and Moves them
	tempInZone = zTable.zMainDeck
	getCurrentDeck()
	if currentDeck ~= nil then
		currentDeck.shuffle()
		rebirthStacks = currentDeck.split(5)
		function moveRebirthStacks()
			wait(1)
				rebirthStacks[1].setPosition(zTable.zBoss1.getPosition())
				rebirthStacks[1].setRotationSmooth({0, 180, 180})
				rebirthStacks[2].setPosition(zTable.zBoss2.getPosition())
				rebirthStacks[2].setRotationSmooth({0, 180, 180})
				rebirthStacks[3].setPosition(zTable.zBoss3.getPosition())
				rebirthStacks[3].setRotationSmooth({0, 180, 180})
				rebirthStacks[4].setPosition(zTable.zBoss4.getPosition())
				rebirthStacks[4].setRotationSmooth({0, 180, 180})
				rebirthStacks[5].setPosition(zTable.zBoss5.getPosition())
				rebirthStacks[5].setRotationSmooth({0, 180, 180})
			return 1
		end
		startLuaCoroutine(Global, "moveRebirthStacks")
	end
end
function shuffleStacks() -- Shuffles the 5 stacks
	stack1Rebirth = nil
	stack2Rebirth = nil
	stack3Rebirth = nil
	stack4Rebirth = nil
	stack5Rebirth = nil
	for _, object in ipairs(zTable.zBoss1.getObjects()) do
		if object.type  == 'Deck' then
		stack1Rebirth = object
		stack1Rebirth.shuffle()
		break
		end
	end
	for _, object in ipairs(zTable.zBoss2.getObjects()) do
		if object.type  == 'Deck' then
		stack2Rebirth = object
		stack2Rebirth.shuffle()
		break
		end
	end
	for _, object in ipairs(zTable.zBoss3.getObjects()) do
		if object.type  == 'Deck' then
		stack3Rebirth = object
		stack3Rebirth.shuffle()
		break
		end
	end
	for _, object in ipairs(zTable.zBoss4.getObjects()) do
		if object.type  == 'Deck' then
		stack4Rebirth = object
		stack4Rebirth.shuffle()
		break
		end
	end
	for _, object in ipairs(zTable.zBoss5.getObjects()) do
		if object.type  == 'Deck' then
		stack5Rebirth = object
		stack5Rebirth.shuffle()
		break
		end
	end
end
function runSplitBossShuffle() -- Runs rebirthBoss(), splitRebirth(), shuffleStacks()
	function actuallyRunSplitBossShuffle()
		splitRebirth()
		rebirthBoss()
		wait(2)
		shuffleStacks()
		return 1
	end
	startLuaCoroutine(Global, "actuallyRunSplitBossShuffle")
end
function returnRebirth() -- Returns 5 stacks to top of Main Deck Zone
stack5Rebirth.setPositionSmooth({zTable.zMainDeck.getPosition().x,1,zTable.zMainDeck.getPosition().z})
stack4Rebirth.setPositionSmooth({zTable.zMainDeck.getPosition().x,2,zTable.zMainDeck.getPosition().z})
stack3Rebirth.setPositionSmooth({zTable.zMainDeck.getPosition().x,3,zTable.zMainDeck.getPosition().z})
stack2Rebirth.setPositionSmooth({zTable.zMainDeck.getPosition().x,4,zTable.zMainDeck.getPosition().z})
stack1Rebirth.setPositionSmooth({zTable.zMainDeck.getPosition().x,5,zTable.zMainDeck.getPosition().z})
end
function registerRebirth() -- registers bags to set up with, Resets Location Values
	infBagRebirth = {
    	RBSP1=getObjectFromGUID("972d72"), RBSP2=getObjectFromGUID("47b01f"), RBSP3=getObjectFromGUID("8d17db"), RBSP4=getObjectFromGUID("0a108a"),
		RBSP5=getObjectFromGUID("237f86"), RBSP6=getObjectFromGUID("f59936"), RBSP7=getObjectFromGUID("d7f38f"), RBSP8=getObjectFromGUID("07a40e"),
		RBTTA=getObjectFromGUID("912e03"), RBL=getObjectFromGUID("1a00c2"), RBBC=getObjectFromGUID("269e4f"),
					}
	RBTT = getObjectFromGUID("6f380f")
	RBTTExtra = getObjectFromGUID("0bfadb")
	rbLocationCheck = {
	{name="Arkham" , spot=0, sideA=true,
	idA1="RB Arkham 1A", idB1="RB Arkham 1B", idS1="RB Toss 1B",
	idA2="RB Arkham 2A", idB2="RB Arkham 2B", idS2="RB Toss 2B",
	idA3="RB Arkham 3A", idB3="RB Arkham 3B", idS3="RB Toss 3B",
	idA4="RB Arkham 4A", idB4="RB Arkham 4B", idS4="RB Toss 4B",
	idA5="RB Arkham 5A", idB5="RB Arkham 5B", idS5="RB Toss 5B",
	},
	{name="Bank" , spot=0, sideA=true,
	idA1="RB Bank 1A", idB1="RB Bank 1B", idS1="RB Withdrawal 1B",
	idA2="RB Bank 2A", idB2="RB Bank 2B", idS2="RB Withdrawal 2B",
	idA3="RB Bank 3A", idB3="RB Bank 3B", idS3="RB Withdrawal 3B",
	idA4="RB Bank 4A", idB4="RB Bank 4B", idS4="RB Withdrawal 4B",
	idA5="RB Bank 5A", idB5="RB Bank 5B", idS5="RB Withdrawal 5B",
	},
	{name="Batcave" , spot=0, sideA=true,
	idA1="RB Batcave 1A", idB1="RB Batcave 1B", idS1="RB Batcycle 1B",
	idA2="RB Batcave 2A", idB2="RB Batcave 2B", idS2="RB Batcycle 2B",
	idA3="RB Batcave 3A", idB3="RB Batcave 3B", idS3="RB Batcycle 3B",
	idA4="RB Batcave 4A", idB4="RB Batcave 4B", idS4="RB Batcycle 4B",
	idA5="RB Batcave 5A", idB5="RB Batcave 5B", idS5="RB Batcycle 5B",
	},
	{name="City" , spot=0, sideA=true,
	idA1="RB City 1A", idB1="RB City 1B", idS1="RB Flight 1B",
	idA2="RB City 2A", idB2="RB City 2B", idS2="RB Flight 2B",
	idA3="RB City 3A", idB3="RB City 3B", idS3="RB Flight 3B",
	idA4="RB City 4A", idB4="RB City 4B", idS4="RB Flight 4B",
	idA5="RB City 5A", idB5="RB City 5B", idS5="RB Flight 5B",
	},
	{name="Daily" , spot=0, sideA=true,
	idA1="RB Daily 1A", idB1="RB Daily 1B", idS1="RB Tomorrow 1B",
	idA2="RB Daily 2A", idB2="RB Daily 2B", idS2="RB Tomorrow 2B",
	idA3="RB Daily 3A", idB3="RB Daily 3B", idS3="RB Tomorrow 3B",
	idA4="RB Daily 4A", idB4="RB Daily 4B", idS4="RB Tomorrow 4B",
	idA5="RB Daily 5A", idB5="RB Daily 5B", idS5="RB Tomorrow 5B",
	},
	{name="Police" , spot=0, sideA=true,
	idA1="RB Police 1A", idB1="RB Police 1B", idS1="RB Batsignal 1B",
	idA2="RB Police 2A", idB2="RB Police 2B", idS2="RB Batsignal 2B",
	idA3="RB Police 3A", idB3="RB Police 3B", idS3="RB Batsignal 3B",
	idA4="RB Police 4A", idB4="RB Police 4B", idS4="RB Batsignal 4B",
	idA5="RB Police 5A", idB5="RB Police 5B", idS5="RB Batsignal 5B",
	},
	{name="STAR" , spot=0, sideA=true,
	idA1="RB STAR 1A", idB1="RB STAR 1B", idS1="RB Super Speed 1B",
	idA2="RB STAR 2A", idB2="RB STAR 2B", idS2="RB Super Speed 2B",
	idA3="RB STAR 3A", idB3="RB STAR 3B", idS3="RB Super Speed 3B",
	idA4="RB STAR 4A", idB4="RB STAR 4B", idS4="RB Super Speed 4B",
	idA5="RB STAR 5A", idB5="RB STAR 5B", idS5="RB Super Speed 5B",
	},
	}
end
function rebirthShuffle7Locations() -- Shuffles #'s 1-7 to randomly pick Location, for Non Scenarios
	local function shuffle7Now (t,from, to)  -- second, exclude duplicates
	local num = math.random (from, to)
		if t[num] then  num = shuffle7Now (t, from, to)   end
		t[num]=num
		return num
	end
	local h = {}    -- initialize  table with not duplicate values
	--First Half for Location by # Value
	local locationPick1 = shuffle7Now (h, 1, 7)
	local locationPick2 = shuffle7Now (h, 1, 7)
	local locationPick3 = shuffle7Now (h, 1, 7)
	local locationPick4 = shuffle7Now (h, 1, 7)
	local locationPick5 = shuffle7Now (h, 1, 7)
	--2nd Half for A/B Side
	local locationPick1_AB = math.random(1, 2)
	local locationPick2_AB = math.random(1, 2)
	local locationPick3_AB = math.random(1, 2)
	local locationPick4_AB = math.random(1, 2)
	local locationPick5_AB = math.random(1, 2)
	rbLocationCheck[locationPick1].spot = locationRB1
	if locationPick1_AB == 1 then
		rbLocationCheck[locationPick1].sideA = false
	end
	rbLocationCheck[locationPick2].spot = locationRB2
	if locationPick2_AB == 1 then
		rbLocationCheck[locationPick2].sideA = false
	end
	rbLocationCheck[locationPick3].spot = locationRB3
	if locationPick3_AB == 1 then
		rbLocationCheck[locationPick3].sideA = false
	end
	rbLocationCheck[locationPick4].spot = locationRB4
	if locationPick4_AB == 1 then
		rbLocationCheck[locationPick4].sideA = false
	end
	rbLocationCheck[locationPick5].spot = locationRB5
	if locationPick5_AB == 1 then
		rbLocationCheck[locationPick5].sideA = false
	end
end
function rebirthShuffle5Locations() -- Shuffles #'s 1-5 to randomly pick Location spots
	local function shuffle5Now (t,from, to)  -- second, exclude duplicates
	local num = math.random (from, to)
		if t[num] then  num = shuffle5Now (t, from, to)   end
		t[num]=num
		return num
	end
	local t = {}    -- initialize  table with not duplicate values
locationRB1 = shuffle5Now (t, 1, 5)
locationRB2 = shuffle5Now (t, 1, 5)
locationRB3 = shuffle5Now (t, 1, 5)
locationRB4 = shuffle5Now (t, 1, 5)
locationRB5 = shuffle5Now (t, 1, 5)
end
function runRBLocationCheck() -- Checks Location Values for Placement on the Board
	for k, v in ipairs(rbLocationCheck) do
		if v.spot == 1 then
			if v.sideA == true then
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idA1]})
			else
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idB1]})
				infBagRebirth.RBBC.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idS1]})
			end
		elseif v.spot == 2 then
			if v.sideA == true then
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idA2]})
			else
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idB2]})
				infBagRebirth.RBBC.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idS2]})
			end
		elseif v.spot == 3 then
			if v.sideA == true then
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idA3]})
			else
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idB3]})
				infBagRebirth.RBBC.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idS3]})
			end
		elseif v.spot == 4 then
			if v.sideA == true then
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idA4]})
			else
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idB4]})
				infBagRebirth.RBBC.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idS4]})
			end
		elseif v.spot == 5 then
			if v.sideA == true then
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idA5]})
			else
				infBagRebirth.RBL.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idB5]})
				infBagRebirth.RBBC.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.idS5]})
			end
		end
	end
	--clears buttons at the end
	zTable.zCharacter.clearButtons()
end
function getCurrentDeck() --Find Current deck for Game Set up
    currentDeck = nil
    -- try to find a Deck
    for _, object in ipairs(tempInZone.getObjects()) do
        if object.type  == 'Deck' then
            currentDeck = object
            break
        end
    end
    -- if not deck was found, try to find a single card
    if currentDeck == nil then
        for _, object in ipairs(tempInZone.getObjects()) do
            if object.type  == 'Card' then
                currentDeck = object
                break
            end
        end
    end
    return currentDeck
end

--************************Option Functions************************--

function none() end --Dummy function for disabling button clicks.
function crisisRefill()
	refill = false
	printToAll("[FF0000][b]Disabled[/b] [FFFFFF]Automatic Line-Up Refill has been disabled for [00008b][b]Crisis[/b]")
	self.UI.setAttribute("refillToggleON", "isOn", "false")
	self.UI.setAttribute("refillToggleOFF", "isOn", "true")
end
function resetScore()
    --Reset the Score Counters
    counterTable = {
        {counter=getObjectFromGUID("21766f")},
        {counter=getObjectFromGUID("89c010")},
        {counter=getObjectFromGUID("41a702")},
        {counter=getObjectFromGUID("b83860")},
    }
    for i, c in pairs(counterTable) do
        --delete button "counter"
        c.counter.clearButtons()
    end
end
function deleteEverything() --Delete all objects if their GUID doesn't match one found in the guidWhiteList
    for _, object in ipairs(getAllObjects()) do
        foundGUID = false
        local objectGUID = object.getGUID()
        for _, guid in ipairs(guidWhiteList) do
            if guid == objectGUID then
                foundGUID = true
                break
            end
        end
        object.clearButtons()
        if foundGUID == false then
            destroyObject(object)
        end
    end
    if dcdbCubeGame == 0 then
        setupGameButtons()
    else
        setupCubeButtons()
    end
end
function spawnCharactersDC()
	registerTables()
	for i, v in ipairs(menuToggleSetOptions) do
		if v.spawnDC == true then
			function pauseSpawnCharactersDC()
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pauseSpawnCharactersDC")
		end
	end
	resetYlist()
end
function spawnCharactersCrisis()
	registerTables()
	for i, v in ipairs(menuToggleSetOptions) do
		if v.spawnCrisis == true then
			function pauseSpawnCharactersCrisis()
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID_Crisis]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pauseSpawnCharactersCrisis")
		end
	end
	resetYlist()
end
function spawnCharactersRivals()
	infBag.R1start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters R1"]})
	infBag.R2start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters R2"]})
	infBag.R3start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters R3"]})
	infBag.RCstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters RC"]})
end
function spawnCharactersRebirth()
	infBag.RBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Characters RB"]})
	resetYlist()
end
function spawnCharactersLotR()
	registerTables()
	for i, v in ipairs(menuToggleSetOptions) do
		if v.spawnLOTR == true then
			function pauseSpawnCharactersCrisis()
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pauseSpawnCharactersCrisis")
		end
	end
	resetYlist()
end
function spawnCharactersCartoon()
	registerTables()
	for i, v in ipairs(menuToggleSetOptions) do
		if v.spawnCartoon == true then
			function pausespawnCharactersCartoon()
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pausespawnCharactersCartoon")
		end
	end
	resetYlist()
end
function spawnCharactersRickMorty()
	registerTables()
	for i, v in ipairs(menuToggleSetOptions) do
		if v.spawnRickMorty == true then
			function pausespawnCharactersRickMorty()
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pausespawnCharactersRickMorty")
		end
	end
	resetYlist()
end
function spawnCharactersESW()
	registerTables()
	for i, v in ipairs(menuToggleSetOptions) do
		if v.spawnESW == true then
			function pausespawnCharactersESW()
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pausespawnCharactersESW")
		end
	end
	infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Custom Health Trackers"]})
	infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Ability Tokens All"]})
	broadcastToAll("[FF0000]WARNING: Epic Spell Wars is NSFW[FF0000]")
	resetYlist()
end
function spawnCharactersGangBangers()
	infBag.EGBstart.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["ESW Gang Bangers EGB"]})
	broadcastToAll("[FF0000]WARNING: Epic Spell Wars is NSFW[FF0000]")
end
function spawnCharactersOther()
	registerTables()
	for i, v in ipairs(menuToggleSetOptions) do
		if v.spawnOther == true then
			function pausespawnCharactersOther()
				menuToggleExtras.cBagID_y = menuToggleExtras.cBagID_y + 1
				registerTables()
				v.bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList[v.cBagID]})
				wait(0.1)
				return 1
			end
			startLuaCoroutine(Global, "pausespawnCharactersOther")
		end
	end
	resetYlist()
end
function afterBagRemoved(tempBag, params) --Actually placing items onto the table
    for i, data in ipairs(params) do
        if not data.color then
            tempBag.takeObject(data)
            if data.lock=="yes" then
                function lockCo()
                    wait(0.5)
                    getObjectFromGUID(data.guid).setLock(true)
                    return 1
                end
                startLuaCoroutine(Global, "lockCo")
            end
        elseif Player["Yellow"].seated == true and data.color == "Yellow" then
            tempBag.takeObject(data)
        elseif Player["White"].seated == true and data.color == "White" then
            tempBag.takeObject(data)
        elseif Player["Red"].seated == true and data.color == "Red" then
            tempBag.takeObject(data)
        elseif Player["Green"].seated == true and data.color == "Green" then
            tempBag.takeObject(data)
		elseif Player["Brown"].seated == true and data.color == "Brown" then
            tempBag.takeObject(data)
		elseif Player["Purple"].seated == true and data.color == "Purple" then
            tempBag.takeObject(data)
		elseif Player["Orange"].seated == true and data.color == "Orange" then
            tempBag.takeObject(data)
		elseif Player["Pink"].seated == true and data.color == "Pink" then
            tempBag.takeObject(data)
        end
    end
    tempBag.destruct()
end

--*********************End of UI Stuff*********************--

--*********************Chat Commands*********************--
--*********************Created by 3vo*********************--

function onChat(message, player)
    if string.sub(message, 1, 1) == "!" then
        --Trim off the "!", split the words into table entries
        message = string.sub(message, 2, string.len(message))
        local messageSplit = stringSplit(message, "%S+")
        --Get command name
        local commandName = ""
        if #messageSplit ~= 0 then
            commandName = string.lower(messageSplit[1])
        else
            player.broadcast("No command entered.", {0.9,0.2,0.2})
            --Kill the function if no command was entered after "!"
            return false
        end
        --Activate command if one exists
        if ref_commandFunctions[commandName] ~= nil then
            local modifier = ""
            if messageSplit[2] ~= nil then
                local spaceIndex = string.find(message, " ")
                modifier = string.sub(message, spaceIndex+1, string.len(message))
            end
            ref_commandFunctions[commandName].func(modifier, player)
        else
            player.broadcast("Command not found: "..messageSplit[1], {0.9,0.2,0.2})
        end

        --Block the chat message from going to chat
        return false
    end
end
function isPlayerAdmin(color) --Determine if the player is an admin (host/promoted)
    if ref_validCapColors[color] == nil then
        --Is admin and not at a color (spectator), or is on the autoPromoteList but hasn't sat at a color yet
        if color.admin or autoPromotePlayer(color) then 
			return true 
		else 
			return false 
		end
    end
    if Player[color].admin then
        return true
    end
    return false
end
function isPlayerWhiteListed(color) --Determine if the player is whiteListed
    local playerID = ""
    if ref_validCapColors[color] == nil then
        playerID = color.steam_id
    else
        playerID = Player[color].steam_id
    end
    for i=1, #whiteListedPlayers do
        if playerID == whiteListedPlayers[i] then
            return true
        end
    end
    return false
end
function autoPromotePlayer(color) -- Automatically promote specific players, by SteamID
    local playerID = ""
    if ref_validCapColors[color] == nil then
        playerID = color.steam_id
    else
        playerID = Player[color].steam_id
    end
    for i=1, #promotedPlayers do
        if playerID == promotedPlayers[i] then
            return true
        end
    end
    return false
end
function getTargetPlayer(modifier, player) --Obtains a target player from the string message
    --Check that a color or player was given to the function
    if modifier ~= "" then
        --Check for if a color name was entered
        local colorName = getColorNameFromString(modifier)
        if colorName ~= nil then
            --Name entered was a color
            if Player[colorName].seated then
                return Player[colorName]
            else
                player.broadcast("No player was in the "..colorName.." seat.", {0.9,0.2,0.2})
            end
        else
            --Name entered was a steam name
            local playerRef = getPlayerFromString(modifier)
            if playerRef ~= nil then
                return playerRef
            else
                player.broadcast("No target match for: "..modifier, {0.9,0.2,0.2})
            end
        end
    else
        player.broadcast("No target submitted. Provide a [i]color[/i] or [i]Steam name[/i].", {0.9,0.2,0.2})
        return nil
    end
end
function gmPlayer(modifier, player) --Move player to GM / Black seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [000000][i]GM/Black[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Black")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [000000][i]GM/Black[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Black")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function whitePlayer(modifier, player) --Move player to White seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [FFFFFF][i]White[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("White")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [FFFFFF][i]White[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("White")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function redPlayer(modifier, player) --Move player to Red seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [DA1917][i]Red[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Red")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [DA1917][i]Red[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Red")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function greenPlayer(modifier, player) --Move player to Green seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [31B32B][i]Green[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Green")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [31B32B][i]Green[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Green")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function yellowPlayer(modifier, player) --Move player to Yellow seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [e7e52c][i]Yellow[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Yellow")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [e7e52c][i]Yellow[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Yellow")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function brownPlayer(modifier, player) --Move player to Brown seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [713b17][i]Brown[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Brown")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [713b17][i]Brown[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Brown")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function purplePlayer(modifier, player) --Move player to Brown seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [a020f0][i]Purple[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Purple")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [a020f0][i]Purple[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Purple")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function orangePlayer(modifier, player) --Move player to Brown seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [f4641d][i]Orange[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Orange")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [f4641d][i]Orange[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Orange")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function pinkPlayer(modifier, player) --Move player to Brown seat; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [f570ce][i]Pink[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Pink")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved ["  .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [f570ce][i]Pink[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Pink")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function promotePlayer(modifier, player) --Promote player; Admin only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has promoted player: [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b]", {0.2,0.9,0.2})
            targetPlayer.promote()
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function kickPlayer(modifier, player) --Kick player; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has kicked player: [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b]", {0.2,0.9,0.2})
            targetPlayer.kick()
            return
        elseif isPlayerWhiteListed(player) then
            if targetPlayer.admin then
                player.broadcast("Stop trying to kick an Admin!", {0.9,0.2,0.2})
                return
            else
                printToAll("[MOD] " .. player.steam_name .. " has kicked player: [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b]", {0.2,0.9,0.2})
                targetPlayer.kick()
                return
            end
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function mutePlayer(modifier, player) --Mute player; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has toggled mute on player: [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b]", {0.2,0.9,0.2})
            targetPlayer.mute()
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has toggled mute on player: [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b]", {0.2,0.9,0.2})
            targetPlayer.mute()
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function movePlayer(modifier, player) --Move player to Spectator; Admin or WhiteListed only
    local targetPlayer = getTargetPlayer(modifier, player)
    if targetPlayer ~= nil then
        local ct = stringColorToRGB(targetPlayer.color)
        local hexValue = string.format('%02x%02x%02x', math.floor(ct.r*255), math.floor(ct.g*255), math.floor(ct.b*255))
        if isPlayerAdmin(player) then
            printToAll("[ADMIN] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [808080][i]Spectator[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Grey")
        elseif isPlayerWhiteListed(player) then
            printToAll("[MOD] " .. player.steam_name .. " has moved [" .. hexValue .. "][b]" .. targetPlayer.steam_name .. "[/b][-] to [808080][i]Spectator[/i][-].", {0.2,0.9,0.2})
            targetPlayer.changeColor("Grey")
        else
            player.broadcast("You do not have permission to use this command.", {0.9,0.2,0.2})
        end
    end
end
function randomPlayer(modifier, player) --Select a player randomly from those seated
    local playerTable = getSeatedPlayers()
    shuffle(playerTable)
    local pt = stringColorToRGB(player.color)
    local hexValue = string.format('%02x%02x%02x', math.floor(pt.r*255), math.floor(pt.g*255), math.floor(pt.b*255))
    broadcastToAll("[" .. hexValue .. "]" .. player.steam_name .. "[-] randomly selected player: [b]" .. Player[playerTable[1]].steam_name .. "[/b]", stringColorToRGB(playerTable[1]))
end
function randomOpponent(modifier, player) --Select an opponent randomly from those seated
    if player.color == "Black" then
        player.broadcast("The GM doesn't have any opponents; try using !player instead.", {1,1,1})
        return
    end
    local opponentTable = getSeatedPlayers()
        for i, _ in ipairs(opponentTable) do
            if opponentTable[i] == player.color then
                table.remove(opponentTable, i)
            end
        end
    --Make sure that there is at least one entry in the opponent table
    if #opponentTable > 0 then
        shuffle(opponentTable)
        broadcastToAll(player.steam_name .. " randomly selected opponent: " .. Player[opponentTable[1]].steam_name, stringColorToRGB(opponentTable[1]))
    else
        player.broadcast("Unable to perform command as there are no opponents seated!", {1,1,1})
    end
end
function rollDice(modifier, player) --Simulates dice roll
    local diceCount, diceSides = getDiceToRoll(modifier, player)
    if diceSides > 100 then
        player.broadcast("D100 is the largest supported size.", {0.9,0.2,0.2})
        return
    elseif diceCount > 20 then
        player.broadcast("Number of dice is limited to 20 max.", {0.9,0.2,0.2})
        return
    elseif diceSides ~= nil then
        --Roll dice
        local total = 0
        for i=1, diceCount do
            local result = math.random(1,diceSides)
            total = total + result
        end
        local ct = stringColorToRGB(player.color)
        broadcastToAll(player.steam_name .. " [33E633]has rolled [65CA5F]" .. diceCount .. "d" .. diceSides .. "[-]: [ffffff][b]" .. total .. "[/b]", ct)
    end
end
function getDiceToRoll(modifier, player) --Obtains how many dice to roll and how many sides it should have
    --Check if a die type/sides were given
    if modifier != "" then
        local dt = stringSplit(modifier, "[^Dd]+")
        local dt1, dt2 = tonumber(dt[1]), tonumber(dt[2])
        if dt1~=nil and dt2~=nil then
            return dt1, dt2
        elseif dt1~=nil then
            return 1, dt1
        else
            player.broadcast("Invalid input. Try '!roll 2d20' or '!roll 12'.", {0.9,0.2,0.2})
            return nil, nil
        end
    else
        --If not sides/type given, rolls a 1d6
        return 1, 6
    end
end
function flipCoin(modifier, player) --Simulates flipping a coin
    local coinFace = ""
    local result = math.random(0,1)
    if result == 0 then coinFace = "Heads!" else coinFace = "Tails!" end
    local ct = stringColorToRGB(player.color)
    broadcastToAll(player.steam_name.." [33E633]has flipped: [b]" .. coinFace .. "[/b]", ct)
end
function getColorNameFromString(str) --Finds a color from string data (player color)
    local messageString = string.lower(str)
    if ref_validColors[messageString] ~= nil then
        return (messageString:gsub("^%l", string.upper))
    else
        return nil
    end
end
function getPlayerFromString(str) --Finds a player from string data (player spectator reference or player steam name)
    for _, player in ipairs(Player.getPlayers()) do
        local scName = string.lower(player.steam_name)
        local find = string.find(scName, string.lower(str))
        if find ~= nil then
            return player
        end
    end
    local spectators = Player.getSpectators()
    for i, player in ipairs(spectators) do
        local specName = string.lower(spectators[i].steam_name)
        local foundSpec = string.find(specName, string.lower(str))
        if foundSpec ~= nil then
            local specPlayer = spectators[i]
            return specPlayer
        end
    end

    return nil
end
function stringSplit(s, pattern) --Splits a string at the spaces, returning a table with each word being an entry
    local t = {}
    for i in string.gmatch(s, pattern) do
        table.insert(t, i)
    end
    return t
end
function randomMultiverse() -- Function for Certain MV Cards
	local mvSetShuffle = {}
	local countNumber = 0
	for key, value in pairs(menuToggleSetOptions) do
		if value.mvValue == false then
			if value.mvPicked ~= true then
				countNumber = countNumber + 1
				table.insert(mvSetShuffle, value.imgRep)
			end
		end
	end
	shuffle(mvSetShuffle)
	printToAll("Random Multiverse selected is " .. mvSetShuffle[1])
end
function shuffle(tbl)
    for i = #tbl, 1, -1 do
        local rand = math.random(#tbl)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
    return tbl
end
ref_commandFunctions = {
    ["kick"] = {func = function(x,y) kickPlayer(x,y) end,},
    ["promote"] = {func = function(x,y) promotePlayer(x,y) end,},
    ["mute"] = {func = function(x,y) mutePlayer(x,y) end,},
    ["move"] = {func = function(x,y) movePlayer(x,y) end,},
    ["gm"] = {func = function(x,y) gmPlayer(x,y) end,},
    ["black"] = {func = function(x,y) gmPlayer(x,y) end,},
    ["white"] = {func = function(x,y) whitePlayer(x,y) end,},
    ["red"] = {func = function(x,y) redPlayer(x,y) end,},
    ["green"] = {func = function(x,y) greenPlayer(x,y) end,},
    ["yellow"] = {func = function(x,y) yellowPlayer(x,y) end,},
	["brown"] = {func = function(x,y) brownPlayer(x,y) end,},
	["purple"] = {func = function(x,y) purplePlayer(x,y) end,},
	["orange"] = {func = function(x,y) orangePlayer(x,y) end,},
	["pink"] = {func = function(x,y) pinkPlayer(x,y) end,},
    ["roll"] = {func = function(x,y) rollDice(x,y) end,},
    ["flip"] = {func = function(x,y) flipCoin(x,y) end,},
    ["player"] = {func = function(x,y) randomPlayer(x,y) end,},
    ["random"] = {func = function(x,y) randomOpponent(x,y) end,},
	["ran"] = {func = function(x,y) randomOpponent(x,y) end,},
	["opponent"] = {func = function(x,y) randomOpponent(x,y) end,},
    ["opp"] = {func = function(x,y) randomOpponent(x,y) end,},
	["mv"] = {func = function(x,y) randomMultiverse(x,y) end,},
	["multiverse"] = {func = function(x,y) randomMultiverse(x,y) end,},
	["randommv"] = {func = function(x,y) randomMultiverse(x,y) end,},
	["randommultiverse"] = {func = function(x,y) randomMultiverse(x,y) end,},
	["bizzaro"] = {func = function(x,y) randomMultiverse(x,y) end,},
	["world"] = {func = function(x,y) randomMultiverse(x,y) end,},
	["vanishing"] = {func = function(x,y) randomMultiverse(x,y) end,},
	["vanish"] = {func = function(x,y) randomMultiverse(x,y) end,},
	["point"] = {func = function(x,y) randomMultiverse(x,y) end,},
	}
ref_validColors = {
    ["white"]=false,
    ["red"]=false,
    ["green"]=false,
    ["yellow"]=false,
	["brown"]=false,
	["purple"]=false,
	["orange"]=false,
	["pink"]=false,
    --["grey"]=false,
    ["black"]=false
}
ref_validCapColors = {
    ["White"]=false,
    ["Red"]=false,
    ["Green"]=false,
    ["Yellow"]=false,
	["Brown"]=false,
	["Purple"]=false,
	["Orange"]=false,
	["Pink"]=false,
    --["Grey"]=false,
    ["Black"]=false
}
promotedPlayers = { --List of SteamIDs to auto promote
    "76561198004478272",  --3vo
    "76561197984049162",  --Bladecom
	"76561198024811228",  --Coiser
}
whiteListedPlayers = { --WhiteList of SteamIDs that have permission to choose a color, lock seating, and kick/mute non-admin players at any time
    "76561198004478272",  --3vo
    "76561197984049162",  --Bladecom
	"76561198024811228",  --Coiser
}

--*********************Infinite Bag Placment Tables*********************--

tempDcdbJsonToBuild = {
        ["96f525"] = {
            {position={33.06, 1.5, -18.08}, rotation={0, 180, 0}, guid="7f1f84", color="White", smooth=false,},
            {position={-33.06, 1.5, -18.08}, rotation={0, 180, 0}, guid="e30615", color="Red", smooth=false,},
            {position={-33.06, 1.5, 18.08}, rotation={0, 0, 0}, guid="1e04f1", color="Green", smooth=false,},
            {position={33.06, 1.5, 18.08}, rotation={0, 0, 0}, guid="42bd01", color="Yellow", smooth=false,},
            {position={-73.06, 1.5, -18.08}, rotation={0, 180, 0}, guid="5ee5f3", color="Brown", smooth=false},
            {position={73.06, 1.5, 18.08}, rotation={0, 0, 0}, guid="7462de", color="Orange", smooth=false},
            {position={-73.06, 1.5, 18.08}, rotation={0, 0, 0}, guid="6fb0f5", color="Purple", smooth=false},
            {position={73.06, 1.5, -18.08}, rotation={0, 180, 0}, guid="a7c665", color="Pink", smooth=false},
        }
}
function registerTables()
	infiniteBagPlacementList = {
		["Basic DC"] = {
		{position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="eea05f", smooth=false}, --Characters
		{position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="78bd33", smooth=false}, --Main Deck
		{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="6df524", smooth=false}, --Kicks
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="fa9c3f", smooth=false}, --Weakness
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="7a8976", smooth=false, lock="yes"},}, --RuleBook
		["Basic HU"] = {
		{position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="d2fefe", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="f88cb0", smooth=false,},
		{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="2a840a", smooth=false,},
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="8287cf", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="d0bafa", smooth=false, lock="yes"},},
		["Basic FE"] = {
		{position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="cd106c", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="0ae6b3", smooth=false,},
		{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="b5abe3", smooth=false,},
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="762e23", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="2c82c0", smooth=false, lock="yes"},},
		["Basic TT"] = {
		{position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="507555", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="71a06e", smooth=false,},
		{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="03c7d0", smooth=false,},
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="cc5112", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="fd7f24", smooth=false, lock="yes"},},
		["Basic DNM"] = {
		{position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="89ef1d", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="1fd085", smooth=false,},
		{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="723dc3", smooth=false,},
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="7f97ee", smooth=false,},
		{position={25.25, 1.5, 0}, rotation={0, 180, 0}, guid="8f966b", smooth=false,}, --Who laughs
		{position={29.5, 1.5, 0}, rotation={0, 180, 0}, guid="9a2e3c", smooth=false,}, -- Batman
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="61e7f8", smooth=false, lock="yes"},
		},
		["Basic INJ"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 0}, guid="eccebe", smooth=false,},
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z-5.5}, rotation={0, 180, 0}, guid="c1a812", smooth=false,}, -- Super Moves
		{position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="761b5a", smooth=false,},
		{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="1e882f", smooth=false,},
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="1e45c6", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="ca4cfc", smooth=false, lock="yes"},},
		["Basic C1"] = {
		{position={21, 1.5, 0}, rotation={0, 180, 0}, guid="56804e", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="ab7f41", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="8f2f4a", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="5b184d", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="5f205e", smooth=false,},
		{position={30, 1, 50}, rotation={0, 180, 0}, guid="1baf2c", smooth=false, lock="yes"},
		},
		["Basic C2"] = {
		{position={21, 1.5, 0}, rotation={0, 180, 0}, guid="9f08f1", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="e7ea20", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="20d606", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="5b184d", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="cebc2c", smooth=false,},
		{position={30, 1, 50}, rotation={0, 180, 0}, guid="84064a", smooth=false, lock="yes"},
		},
		["Basic C3"] = {
		{position={21, 1.5, 0}, rotation={0, 180, 0}, guid="117c53", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="06b10a", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="48c9f7", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="0963fd", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="bd030d", smooth=false,},
		{position={12.48, 1.5, 5}, rotation={0, 90, 180}, guid="faf339", smooth=false,},
		{position={30, 1, 50}, rotation={0, 180, 0}, guid="1ab772", smooth=false, lock="yes"},
		},
		["Basic C4"] = {
		{position={21, 1.5, 0}, rotation={0, 180, 0}, guid="96fc96", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="48e13a", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="1e16e9", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="3e5fd7", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="b4f4bf", smooth=false,},
		{position={8.49, 1.5, 4.75}, rotation={0, 180, 180}, guid="01e804", smooth=false,},
		{position={30, 1, 50}, rotation={0, 180, 0}, guid="c38728", smooth=false, lock="yes"},
		},
		["Basic R1"] = {
					  {position={-12.5, 1.5, -12}, rotation={0, 180, 0}, guid="682309", smooth=false,},
					  {position={12.5, 1.5, -12}, rotation={0, 180, 0}, guid="983696", smooth=false,},
					  {position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="5d21bb", smooth=false,},
					  {position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="ddd43a", smooth=false,},
					  {position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="701e7b", smooth=false,},
					  {position={0, 1, 50}, rotation={0, 180, 0}, guid="60f5f5", smooth=false, lock="yes"},},
		["Basic R2"] = {
		{position={-12.5, 1.5, -12}, rotation={0, 180, 0}, guid="543c41", smooth=false,},
		{position={12.5, 1.5, -12}, rotation={0, 180, 0}, guid="b0140a", smooth=false,},
		{position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="fcf746", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="f00ed6", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="6635a5", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="27b098", smooth=false, lock="yes"},},
		["Basic R3"] = {
		{position={-12.5, 1.5, -12}, rotation={0, 180, 0}, guid="4b4672", smooth=false,},
		{position={12.5, 1.5, -12}, rotation={0, 180, 0}, guid="db7b79", smooth=false,},
		{position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="ee8008", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="939ed9", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="28bd44", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="3e05c6", smooth=false, lock="yes"},},
		["Basic RC"] = {
		{position={-12.5, 1.5, -12}, rotation={0, 180, 0}, guid="4a7e6a", smooth=false,},
		{position={12.5, 1.5, -12}, rotation={0, 180, 0}, guid="11f62c", smooth=false,},
		{position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="29ec36", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="ccc6ff", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="829499", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="79262f", smooth=false, lock="yes"},},
		["Basic CO1"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="23266b", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="02c52b", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="238c73", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="e22ec3", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="2cc1f6", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="93c10e", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="873dec", smooth=false,},
		},
		["Basic CO2"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="b8d513", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="8ddfc7", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="5095ef", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="7224c0", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="be7ad9", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="2922e7", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="ecab22", smooth=false,},
		},
		["Basic CO3"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="f30a15", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="3263cf", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="0d2299", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="3c67ec", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="3e8233", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="d410f9", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="e9b154", smooth=false,},
		},
		["Basic CO4"] = {
					  {position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="2f8a1e", smooth=false},
					  {position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="418d35", smooth=false},
					  {position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="b9640a", smooth=false,},
					  {position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="76b19a", smooth=false,},
					  {position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="fe9f96", smooth=false,},
					  {position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="babe77", smooth=false,},
					  {position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="dba613", smooth=false,},
					  {position={zTable.zBoss4.getPosition().x, 2, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="043bf8", color="White", smooth=false},
					  {position={zTable.zBoss4.getPosition().x, 3, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="755451", color="Red", smooth=false},
					  {position={zTable.zBoss4.getPosition().x, 4, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="c7516d", color="Yellow", smooth=false},
					  {position={zTable.zBoss4.getPosition().x, 5, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="22c9b0", color="Green", smooth=false},
					  {position={30, 1, 50}, rotation={0, 180, 0}, guid="f6063e", smooth=false, lock="yes"},},
		["Basic CO5"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="768bb5", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="b482da", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="592010", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="94cf62", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="01ae2c", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="239bfa", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="2f8485", smooth=false,},
		},
		["Basic CO6"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="49f230", smooth=false},
		{position={zTable.zOther1.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zOther1.getPosition().z}, rotation={0, 180, 180}, guid="cabb11", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="7a71a1", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="8633da", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="53a778", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="19cc08", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="d7eefc", smooth=false,},
		},
		["Basic CO7"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="dea298", smooth=false},
		{position={21, 1.5, 0}, rotation={0, 180, 0}, guid="878df4", smooth=false},
		{position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="cf9c78", smooth=false},
		{position={5.04, 1.5, 4.75}, rotation={0, 180, 0}, guid="6bab4c", smooth=false},
		{position={8.49, 1.5, 4.75}, rotation={0, 180, 0}, guid="566bb0", smooth=false},
		},
		["Basic CO8"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="5d06d6", smooth=false},
		{position={zTable.zOther1.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zOther1.getPosition().z}, rotation={0, 180, 180}, guid="e5123d", smooth=false},
		{position={-22.5, 1.5, 4.2}, rotation={0, 90, 0}, guid="5bbb3e", smooth=false},
		{position={-25.55, 1.5, 0}, rotation={0, 90, 180}, guid="56ef58", smooth=false},
		{position={-20, 1.5, 0}, rotation={0, 90, 180}, guid="82ea6d", smooth=false},
		{position={-25.55, 1.5, -4.15}, rotation={0, 90, 180}, guid="eb7600", smooth=false},
		{position={-20, 1.5, -4.15}, rotation={0, 90, 180}, guid="6cf96d", smooth=false},
		},
		["Basic CO9"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="bcb174", smooth=false},
		{position={zTable.zOther1.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zOther1.getPosition().z}, rotation={0, 180, 180}, guid="ce3e75", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="b1eb4a", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="0a3892", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="427e11", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="69b919", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="954a71", smooth=false,},
		{position={30, 1, 50}, rotation={0, 180, 0}, guid="38f9de", smooth=false,},
		},
		["Basic FotR"] = {
					  {position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="59c016", smooth=false,}, -- Characters
					  {position={12.48, 1.5, 5.5}, rotation={0, 180, 0}, guid="3239fd", smooth=false,}, -- Character Signatures
					  {position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="e41907", smooth=false,},
					  {position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="434ea1", smooth=false,},
					  {position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="7a868d", smooth=false,},
					  {position={0, 1, 50}, rotation={0, 180, 0}, guid="941502", smooth=false, lock="yes"},},
		["Basic 2T"] = {
					  {position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="355457", smooth=false,},
					  {position={12.48, 1.5, 5.5}, rotation={0, 180, 0}, guid="32943c", smooth=false,},
					  {position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="966cb3", smooth=false,},
					  {position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="cdceef", smooth=false,},
					  {position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="6614be", smooth=false,},
					  {position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="83c686", smooth=false,}, --wall Deck
					  {position={-5.31, 1.5, 4.75}, rotation={0, 180, 180}, guid="dae692", smooth=false,}, --Breached
					  {position={12.48, 1.5, -5.5}, rotation={0, 180, 0}, guid="a5e3dc", smooth=false,}, --Ring
					  {position={0, 1, 50}, rotation={0, 180, 0}, guid="800cda", smooth=false, lock="yes"},},
		["Basic RotK"] = {
					  {position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="6170e0", smooth=false,},
					  {position={12.48, 1.5, 5.5}, rotation={0, 180, 0}, guid="6391e5", smooth=false,},
					  {position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="9cd1a0", smooth=false,},
					  {position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="585b63", smooth=false,},
					  {position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="eb1405", smooth=false,},
					  {position={0, 0.96, 31.5}, rotation={0, 180, 0}, guid="873ff5", smooth=false, lock="yes",},
					  {position={-4.1, 2, 28.55}, rotation={0, 180, 0}, guid="f76f87", smooth=false,},
					  {position={0, 1, 50}, rotation={0, 180, 0}, guid="0251a6", smooth=false, lock="yes"},},
	    ["Basic UJ"] = {
					  {position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="8538e3", smooth=false}, --Character
					  {position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="b5e678", smooth=false}, --Main Deck
					  {position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="f0d3c9", smooth=false}, --Valor
					  {position={-1.86, 4, 4.75}, rotation={0, 180, 0}, guid="3cf9d6", smooth=false}, --Corruptions
					  {position={0, 1, 50}, rotation={0, 180, 0}, guid="50da73", smooth=false, lock="yes"}, --Rule Book
					  {position={8.49, 4, 14.25}, rotation={0, 180, 180}, guid="e1a375", smooth=false,}, --One Ring
					  {position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="b75924", smooth=false}, --Loot 1
					  {position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="4deecf", smooth=false}, --Loot 2
					  },
	    ["Basic DoS"] = {
					  {position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="408ae0", smooth=false}, --Characters
					  {position={-8.76, 2, 4.75}, rotation={0, 180, 180}, guid="764057", smooth=false}, --Main Deck
					  {position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="e5c018", smooth=false}, --Corruptions
					  {position={30, 1, 50}, rotation={0, 180, 0}, guid="78cc9e", smooth=false, lock="yes"}, --Rule Book
					  {position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="ef8b1e", smooth=false}, --Loot 4
					  },
		["Basic CN"] = {
					  {position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="f25879", smooth=false,},
					  {position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="15de2b", smooth=false,},
					  {position={12.48, 1.5, -5.5}, rotation={0, 180, 0}, guid="6405ed", smooth=false,}, -- Events
					  {position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="e68cb0", smooth=false,},
					  {position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="5b8e3e", smooth=false,},
					  {position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="2a2b7f", smooth=false,},
					  {position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="8c0102", smooth=false,},
					  {position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="858ca5", smooth=false,},},
		["Basic AA"] = {
					  {position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="bfe4a7", smooth=false,},
					  {position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="3563dd", smooth=false,},
					  {position={12.48, 1.5, -5.5}, rotation={0, 180, 0}, guid="35ce94", smooth=false,}, -- Events
					  {position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="a87134", smooth=false,},
					  {position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="ae2845", smooth=false,},
					  {position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="963aa5", smooth=false,},
					  {position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="fe35df", smooth=false,},
					  {position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="589faa", smooth=false,},
					  {position={0, 1, 50}, rotation={0, 180, 0}, guid="dea0f7", smooth=false, lock="yes"},},
		["Basic TTG"] = {
					  {position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="ca96c4", smooth=false,},
					  {position={7.5, 1.5, -12}, rotation={0, 180, 0}, guid="2ef475", smooth=false,},
					  {position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="43f00a", smooth=false,},
					  {position={12.48, 1.5, -5.5}, rotation={0, 180, 0}, guid="39005e", smooth=false,}, -- Events
					  {position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="201af8", smooth=false,},
					  {position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="39fcea", smooth=false,},
					  {position={0, 1, 50}, rotation={0, 180, 0}, guid="02422c", smooth=false, lock="yes"},},
		["Basic RM1"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 0}, guid="2d34cf", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="f118f2", smooth=false,},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="8f2659", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="0800ad", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="dbe704", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="dc32c1", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="1f2618", smooth=false,},
		{position={-8.75, 1.5, 4.75}, rotation={0, 180, 180}, guid="c03219", smooth=false,},
		{position={-8.75, 2.5, 4.75}, rotation={0, 180, 0}, guid="60400f", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="0d915d", smooth=false, lock="yes"},},
		["Basic RM2"] = {
		{position={zTable.zCharacter.getPosition().x, 0.5+menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 0}, guid="e3715e", smooth=false,},
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 0}, guid="9b389f", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="9ffa85", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, 1.5+menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="218978", smooth=false,},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="1d185f", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="85483c", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="a4dcc9", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="fe44eb", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="d627d3", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="0ce230", smooth=false,},
		{position={8.5, 1, 4.75}, rotation={0, 180, 0}, guid="f82d51", smooth=false, lock="yes",},
		{position={-8.75, 1.5, 4.75}, rotation={0, 180, 180}, guid="b2547b", smooth=false,},
		{position={-8.75, 2.5, 4.75}, rotation={0, 180, 0}, guid="f3fe1d", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="a3bf69", smooth=false, lock="yes"},},
		["Basic SF"] = {
		{position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="44d584", smooth=false,},
		{position={12.48, 1.5, 5.5}, rotation={0, 180, 0}, guid="a265da", smooth=false,}, -- Ultras
		{position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="98b37e", smooth=false,},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="eabca4", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="0db766", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="89ee45", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="fdc6c6", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="afac8d", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="ce7307", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="615a56", smooth=false, lock="yes"},},
		["Basic NS"] = {
		{position={12.48, 1.5, 0}, rotation={0, 180, 0}, guid="e094d0", smooth=false,},
		{position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="13a7a5", smooth=false,},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="743ccb", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="02a24f", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="6b51c9", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="7c286c", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="52044c", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="084a41", smooth=false,},
		{position={-5.3, 1.5, 4.75}, rotation={0, 180, 0}, guid="6d9beb", smooth=false,},
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="b37a5b", smooth=false, lock="yes"},},
		["Basic EA1"] = {
		{position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="04076d", smooth=false}, --Main Deck
		{position={-8.76, 2.5, 0}, rotation={0, 180, 180}, guid="a797a3", smooth=false}, --Mayhem
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="5dbd48", smooth=false}, --Wild Magic
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="e37c8e", smooth=false}, --Limp
		{position={-52, 2.5, -3}, rotation={0, 180, 0}, guid="980708", smooth=false}, --Monolith
		{position={-52, 2.5, -6.00}, rotation={0, 180, 0}, guid="bd4b02", smooth=false}, --Monolith (Promo)
		{position={-52, 1, -6.00}, rotation={0, 180, 0}, guid="1ba9e1", smooth=false}, --EA1 Cthulhu (Promo)
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="b0225c", smooth=false, lock="yes"},}, --RuleBook
		["Basic EA2"] = {
		{position={-8.76, 2, 0}, rotation={0, 180, 180}, guid="d35922", smooth=false}, --Main Deck
		{position={-8.76, 2.5, 0}, rotation={0, 180, 180}, guid="916e6f", smooth=false}, --Mayhem
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="9c12be", smooth=false}, --Wild Magic
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="d8a034", smooth=false}, --Limp
		{position={-8.76, 1, 4.63}, rotation={0, 180, 0}, guid="e48ce1", smooth=false, lock="yes"}, --Nacho
		{position={-5.31, 1, 4.63}, rotation={0, 180, 0}, guid="ee2728", smooth=false, lock="yes"}, --Dingler
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="b04e45", smooth=false, lock="yes"},}, --RuleBook
		--[[EGB]]	["c809da"] = {
		{position={12.48, 1.05, -0.63}, rotation={0, 180, 0}, guid="c524d9", smooth=false, lock="yes"}, -- Chest
		{position={12.48, 4, 0}, rotation={0, 180, 0}, guid="7a7f64", smooth=false}, --Lock
		{position={12.48, 1.5, 0}, rotation={0, 180, 180}, guid="e1ce6e", smooth=false}, --Legends Deck
		{position={-2, 1.5, -12}, rotation={0, 90, 0}, guid="62c0bf", smooth=false}, -- Characters
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="eeeddb", smooth=false, lock="yes"}, --DWT
		{position={-52, 2.5, 6}, rotation={0, 0, 0}, guid="ae756e", smooth=false,}, --Standee
		{position={30, 1, 50}, rotation={0, 180, 0}, guid="488780", smooth=false, lock="yes"}, --Rulebook
		{position={19.72, 1.5, -3.36}, rotation={0, 180, 0}, guid="d9a9fc", smooth=false},
		{position={24.18, 1.5, -3.36}, rotation={0, 180, 0}, guid="265ca2", smooth=false}, -- Voodoo
		{position={28.63, 1.5, -3.36}, rotation={0, 180, 0}, guid="6bd48e", smooth=false}, -- Fruits
		{position={33.10, 1.5, -3.36}, rotation={0, 180, 0}, guid="9cb479", smooth=false}, -- K Kids
		{position={37.53, 1.5, -5.29}, rotation={0, 180, 0}, guid="54f88d", smooth=false}, -- Merkins
		{position={41.98, 1.5, -5.29}, rotation={0, 180, 0}, guid="323088", smooth=false},
		{position={19.72, 1.5, -7.90}, rotation={0, 180, 0}, guid="1c2d37", smooth=false}, -- Sk8 Ratz
		{position={24.18, 1.5, -7.90}, rotation={0, 180, 0}, guid="84895b", smooth=false},
		{position={28.63, 1.5, -7.90}, rotation={0, 180, 0}, guid="0a3b66", smooth=false}, -- Rockers
		{position={33.10, 1.5, -7.90}, rotation={0, 180, 0}, guid="4705d6", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="672161", smooth=false},
		},
		["Basic RB"] = {
			{position={-9, 1, 57}, rotation={0, 180, 0}, guid="f7fa91", smooth=false,},
			--Location Markers
			{position={0, 1, 10.8}, rotation={0, 180, 0}, guid="529242", smooth=false, lock="yes"},
			{position={8.2, 1, 5.4}, rotation={0, 180, 0}, guid="1617ac", smooth=false, lock="yes"},
			{position={9, 1, -5.4}, rotation={0, 180, 0}, guid="f173d7", smooth=false, lock="yes"},
			{position={-9, 1, -5.4}, rotation={0, 180, 0}, guid="4d27e3", smooth=false, lock="yes"},
			{position={-8.2, 1, 5.4}, rotation={0, 180, 0}, guid="9f8b3b", smooth=false, lock="yes"},
			--Location Bags
			{position={-3, 1, 63}, rotation={0, 180, 0}, guid="1a00c2", smooth=false, lock="yes"},
			{position={3, 1, 63}, rotation={0, 180, 0}, guid="269e4f", smooth=false, lock="yes"},
			{position={9, 1, 63}, rotation={0, 180, 0}, guid="912e03", smooth=false, lock="yes"},
			{position={-20, 1, 0}, rotation={0, 0, 0}, guid="07d96c", smooth=false, lock="yes"},
			{position={20, 1, 0}, rotation={0, 0, 0}, guid="859323", smooth=false, lock="yes"},
			--Main Deck
			{position={-11.51, 2.5, 2.47}, rotation={0, 180, 180}, guid="18b2df", smooth=false,},
			--Weakness Stack
			{position={11.51, 1.5, 2.47}, rotation={0, 180, 0}, guid="8e06ae", smooth=false,},
			--Boss Stack
			{position={-9, 1, 42}, rotation={0, 180, 180}, guid="c626d6", smooth=false,},
			--Threat Tracker
			{position={-2.20, 1, 0}, rotation={0, 180, 180}, guid="6f380f", smooth=false, lock="yes"}, --Main
			{position={2.20, 1, 0}, rotation={0, 180, 180}, guid="0bfadb", smooth=false, lock="yes"}, --Extra
			--Threat Tracker Token
			{position={-3.87, 2.5, -3.15}, rotation={0, 0, 180}, guid="0fec0f", smooth=false,}, --original
			{position={3.87, 2.5, -3.15}, rotation={0, 0, 180}, guid="d39173", smooth=false,}, -- colored one
			--Character Stands
			{position={10, 1, 59}, rotation={0, 180, 0}, guid="8a8e5d", smooth=false,},
			{position={14, 1, 59}, rotation={0, 180, 0}, guid="aaaa4a", smooth=false,},
			{position={10, 1, 55}, rotation={0, 180, 0}, guid="845441", smooth=false,},
			{position={14, 1, 55}, rotation={0, 180, 0}, guid="474bd1", smooth=false,},
			{position={10, 1, 51}, rotation={0, 180, 0}, guid="f0f9af", smooth=false,},
			{position={14, 1, 51}, rotation={0, 180, 0}, guid="044d4e", smooth=false,},
			{position={10, 1, 47}, rotation={0, 180, 0}, guid="135dd8", smooth=false,},
			{position={14, 1, 47}, rotation={0, 180, 0}, guid="a532a3", smooth=false,},
			--Scenario Packs
			{position={31, 1, 60}, rotation={0, 180, 180}, guid="689aa3", smooth=false,},
			{position={41, 1, 60}, rotation={0, 180, 180}, guid="972d72", smooth=false, lock="yes"},
			{position={47, 1, 60}, rotation={0, 180, 180}, guid="47b01f", smooth=false, lock="yes"},
			{position={53, 1, 60}, rotation={0, 180, 180}, guid="8d17db", smooth=false, lock="yes"},
			{position={59, 1, 60}, rotation={0, 180, 180}, guid="0a108a", smooth=false, lock="yes"},
			{position={41, 1, 50}, rotation={0,  180, 180}, guid="237f86", smooth=false, lock="yes"},
			{position={47, 1, 50}, rotation={0, 180, 180}, guid="f59936", smooth=false, lock="yes"},
			{position={53, 1, 50}, rotation={0, 180, 180}, guid="d7f38f", smooth=false, lock="yes"},
			{position={59, 1, 50}, rotation={0, 180, 180}, guid="07a40e", smooth=false, lock="yes"},
			--Signature
			{position={-15, 1, 52}, rotation={0, 180, 180}, guid="92e115", smooth=false,},
			{position={-15, 1, 47}, rotation={0, 180, 180}, guid="787afa", smooth=false,},
			{position={-15, 1, 42}, rotation={0, 180, 180}, guid="514a26", smooth=false,},
			--RuleBook
			{position={64, 1, 0}, rotation={0, 180, 0}, guid="86596b", smooth=false},},
		["Basic DCDB"] = {
			--Boss Token
			{position={8.49, 2, 4.75}, rotation={0, 180, 180}, guid="aad4c5", smooth=false,},
			--Main Deck
			{position={-8.76, 3, 0}, rotation={0, 180, 180}, guid="3d9ead", smooth=false,},
			--Characters
			{position={-12.5, 1.5, -12}, rotation={0, 180, 0}, guid="9dba02", smooth=false,},
			{position={-7.5, 1.5, -12}, rotation={0, 180, 0}, guid="dfbd7c", smooth=false,},
			{position={-2.5, 1.5, -12}, rotation={0, 180, 0}, guid="902f79", smooth=false,},
			{position={2.5, 1.5, -12}, rotation={0, 180, 0}, guid="7b45d0", smooth=false,},
			{position={7.5, 1.5, -12}, rotation={0, 180, 0}, guid="f36247", smooth=false,},
			--Uncomment This Line And Swap Guid To Stack ID To Use Tier 6 MCs
			--{position={12.5, 1.5, -12}, rotation={0, 180, 0}, guid="bc3bd1", smooth=false,},
			--Flying Kick
			{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="1e882f", smooth=false,},
			--Tokens
			{position={-11.25, 5, -10}, rotation={0, 180, 0}, guid="ffb509", smooth=false,},
			{position={-6.25, 5, -10}, rotation={0, 180, 0}, guid="f364a4", smooth=false,},
			{position={-1.25, 5, -10}, rotation={0, 180, 0}, guid="d3abb0", smooth=false,},
			{position={3.75, 5, -10}, rotation={0, 180, 0}, guid="5fa797", smooth=false,},
			{position={8.75, 5, -10}, rotation={0, 180, 0}, guid="1dd6fe", smooth=false,},
			--Uncomment This Line To Use Tier 6 MCs
			--{position={13.75, 5, -10}, rotation={0, 180, 0}, guid="1ca8fd", smooth=false,},
		},
		--Characters
		["Characters DC"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="eea05f", smooth=false},
		},
		["Characters HU"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="d2fefe", smooth=false},
		},
		["Characters FE"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="cd106c", smooth=false},
		},
		["Characters TT"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="507555", smooth=false},
		},
		["Characters DNM"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="89ef1d", smooth=false},
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="9a2e3c", smooth=false},
		},
		["Characters INJ"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="eccebe", smooth=false},
		{position={17.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="c1a812", smooth=false},
		},
		["Characters C1"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="38a1c3", smooth=false},
		},
		["Characters C1 Crisis"] = {
		{position={-7.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="56804e", smooth=false},
		},
		["Characters C2"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="db38b9", smooth=false},
		},
		["Characters C2 Crisis"] = {
		{position={-7.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="9f08f1", smooth=false},
		},
		["Characters C3"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="597b31", smooth=false},
		},
		["Characters C3 Crisis"] = {
		{position={-7.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="117c53", smooth=false},
		},
		["Characters C4"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="3a8037", smooth=false},
		},
		["Characters C4 Crisis"] = {
		{position={-7.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="96fc96", smooth=false},
		},
		["Characters CO1"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="23266b", smooth=false},
		},
		["Characters CO2"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="b8d513", smooth=false},
		},
		["Characters CO3"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="f30a15", smooth=false},
		},
		["Characters CO4"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="2f8a1e", smooth=false},
		},
		["Characters CO5"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="768bb5", smooth=false},
		},
		["Characters CO6"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="49f230", smooth=false},
		},
		["Characters CO7"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="dea298", smooth=false},
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="878df4", smooth=false},
		},
		["Characters CO8"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="5d06d6", smooth=false},
		},
		["Characters CO9"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="bcb174", smooth=false},
		},
		["Characters R1"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="682309", smooth=false},
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="983696", smooth=false},
		},
		["Characters R2"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="543c41", smooth=false},
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="b0140a", smooth=false},
		},
		["Characters R3"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="4b4672", smooth=false},
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="db7b79", smooth=false},
		},
		["Characters RC"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="4a7e6a", smooth=false},
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="11f62c", smooth=false},
		},
		["Characters FotR"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="59c016", smooth=false},
		{position={-17.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="3239fd", smooth=false},
		},
		["Characters 2T"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="355457", smooth=false},
		{position={-17.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="32943c", smooth=false},
		},
		["Characters RotK"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="6170e0", smooth=false},
		{position={-17.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="6391e5", smooth=false},
		},
		["Characters UJ"] = {
		{position={-7.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="8538e3", smooth=false},
		},
		["Characters DoS"] = {
		{position={-7.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="408ae0", smooth=false},
		},
		["Characters CN"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="f25879", smooth=false},
		},
		["Characters AA"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="bfe4a7", smooth=false},
		},
		["Characters TTG"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="ca96c4", smooth=false},
		{position={-17.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="2ef475", smooth=false},
		},
		["Characters RM1"] = {
		{position={2.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="2d34cf", smooth=false},
		},
		["Characters RM2"] = {
		{position={2.5, 0.5+menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="e3715e", smooth=false},
		{position={2.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="9b389f", smooth=false},
		},
		["Characters SF"] = {
		{position={12.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="44d584", smooth=false},
		{position={17.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="a265da", smooth=false},
		},
		["Characters NS"] = {
		{position={-12.5, menuToggleExtras.cBagID_y, -25}, rotation={0, 180, 0}, guid="e094d0", smooth=false},
		},
		["Characters MV"] = {
		{position={-13.5, menuToggleExtras.cBagID_y, -4.75}, rotation={0, 90, 0}, guid="f228a6", smooth=false},
		},
		["Characters Promo"] = {
		{position={7.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="96f014", smooth=false},
		{position={7.5, menuToggleExtras.cBagID_y+1, -18.5}, rotation={0, 180, 0}, guid="a0ff88", smooth=false},
		},
		["Characters EA1"] = {
		{position={49, menuToggleExtras.cBagID_y, -12}, rotation={0, 90, 0}, guid="0a9b8a", smooth=false},
		{position={41.4, menuToggleExtras.cBagID_y, -11.45}, rotation={0, 180, 0}, guid="f54337", smooth=false},
		{position={-49, 2.5, 9}, rotation={0, 0, 0}, guid="2179a8", smooth=false,},
		},
		["Characters EA2"] = {
		{position={49, menuToggleExtras.cBagID_y, -12}, rotation={0, 90, 0}, guid="546da9", smooth=false},
		{position={41.4, menuToggleExtras.cBagID_y, -11.45}, rotation={0, 180, 0}, guid="817679", smooth=false},
		{position={41.4, menuToggleExtras.cBagID_y, -17.15}, rotation={0, 180, 0}, guid="5e7dd4", smooth=false},
		{position={-49, 2.5, 3}, rotation={0, 0, 0}, guid="b8e194", smooth=false,},
		},
		["Characters EGB"] = {
		{position={49, menuToggleExtras.cBagID_y, -12}, rotation={0, 90, 0}, guid="62c0bf", smooth=false},
		{position={41.4, menuToggleExtras.cBagID_y, -11.45}, rotation={0, 180, 0}, guid="67b54b", smooth=false},
		{position={19.72, 1.5, -3.36}, rotation={0, 180, 0}, guid="d9a9fc", smooth=false},
		{position={24.18, 1.5, -3.36}, rotation={0, 180, 0}, guid="265ca2", smooth=false},
		{position={28.63, 1.5, -3.36}, rotation={0, 180, 0}, guid="6bd48e", smooth=false},
		{position={33.10, 1.5, -3.36}, rotation={0, 180, 0}, guid="9cb479", smooth=false},
		{position={37.53, 1.5, -5.29}, rotation={0, 180, 0}, guid="54f88d", smooth=false},
		{position={41.98, 1.5, -5.29}, rotation={0, 180, 0}, guid="323088", smooth=false},
		{position={19.72, 1.5, -7.90}, rotation={0, 180, 0}, guid="1c2d37", smooth=false},
		{position={24.18, 1.5, -7.90}, rotation={0, 180, 0}, guid="84895b", smooth=false},
		{position={28.63, 1.5, -7.90}, rotation={0, 180, 0}, guid="0a3b66", smooth=false},
		{position={33.10, 1.5, -7.90}, rotation={0, 180, 0}, guid="4705d6", smooth=false},
		{position={-49, 2.5, 6}, rotation={0, 0, 0}, guid="ae756e", smooth=false,},
		},
		["Ability Tokens All"] = {
		{position={41.4, 2.5, -22.88}, rotation={0, 180, 0}, guid="fc8c46", smooth=false},
		{position={-3.45, 1.5, -33.95}, rotation={0, 180, 0}, guid="9c1412", smooth=false},},
		["Ability Tokens EA1"] = {
		{position={41.4, 2.5, -22.88}, rotation={0, 180, 0}, guid="db31bf", smooth=false},},
		["Ability Tokens EA2"] = {
		{position={41.4, 2.5, -22.88}, rotation={0, 180, 0}, guid="9569fe", smooth=false},
		{position={-3.45, 1.5, -33.95}, rotation={0, 180, 0}, guid="a5968c", smooth=false},},
		["Characters RB"] = {
		{position={7.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="f7fa91", smooth=false},
		},
		--Main Deck
		["MainDeck DC"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="78bd33", smooth=false},
		},
		["MainDeck HU"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="f88cb0", smooth=false},
		},
		["MainDeck FE"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="0ae6b3", smooth=false},
		},
		["MainDeck TT"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="71a06e", smooth=false},
		},
		["MainDeck DNM"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="1fd085", smooth=false},
		},
		["MainDeck INJ"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="761b5a", smooth=false},
		},
		["MainDeck C1"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="ab7f41", smooth=false},
		},
		["MainDeck C2"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="e7ea20", smooth=false},
		},
		["MainDeck C3"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="06b10a", smooth=false},
		},
		["MainDeck C4"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="48e13a", smooth=false},
		},
		["MainDeck CO1"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="02c52b", smooth=false},
		},
		["MainDeck CO2"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="8ddfc7", smooth=false},
		},
		["MainDeck CO3"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="3263cf", smooth=false},
		},
		["MainDeck CO4"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="418d35", smooth=false},
		},
		["MainDeck CO5"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="b482da", smooth=false},
		},
		["MainDeck CO6"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="cabb11", smooth=false},
		},
		["MainDeck CO7"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="cf9c78", smooth=false},
		},
		["MainDeck CO8"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="e5123d", smooth=false},
		},
		["MainDeck CO9"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="ce3e75", smooth=false},
		},
		["MainDeck R1"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="5d21bb", smooth=false},
		},
		["MainDeck R2"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="fcf746", smooth=false},
		},
		["MainDeck R3"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="ee8008", smooth=false},
		},
		["MainDeck RC"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="29ec36", smooth=false},
		},
		["MainDeck FotR"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="e41907", smooth=false},
		},
		["MainDeck 2T"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="966cb3", smooth=false},
		{position={12.48, 1.5, -5.5}, rotation={0, 180, 0}, guid="a5e3dc", smooth=false,}, --Ring
		},
		["MainDeck RotK"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="9cd1a0", smooth=false},
		},
		["MainDeck UJ"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="b5e678", smooth=false},
		},
		["MainDeck DoS"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="764057", smooth=false},
		},
		["MainDeck CN"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="15de2b", smooth=false},
		},
		["MainDeck AA"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="3563dd", smooth=false},
		},
		["MainDeck TTG"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="43f00a", smooth=false},
		},
		["MainDeck RM1"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="f118f2", smooth=false},
		},
		["MainDeck RM2"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="9ffa85", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, 1.5+menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="218978", smooth=false},
		},
		["MainDeck SF"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="98b37e", smooth=false},
		},
		["MainDeck NS"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="13a7a5", smooth=false},
		},
		["MainDeck Promo"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.1, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="c97253", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="774438", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.3, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="85c26e", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.4, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="a23813", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.5, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="922532", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.6, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="a2d987", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.7, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="86f2be", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.8, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="307c05", smooth=false,},
		{position={-49, 2.5, -6.00}, rotation={0, 180, 0}, guid="7a50a1", smooth=false},
		},
		["MainDeck EA1"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="04076d", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.3, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="a797a3", smooth=false},
		{position={-49, 2.5, -3}, rotation={0, 180, 0}, guid="980708", smooth=false},
		},
		["MainDeck EA2"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="d35922", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+0.3, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="916e6f", smooth=false},
		},
		["MainDeck EGB"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="672161", smooth=false},
		},
		["MainDeck RB"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="18b2df", smooth=false},
		},
		["MainDeck MV"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="bbaeea", smooth=false},
		},
		["Mayhem EA1"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="a797a3", smooth=false},
		},
		["Mayhem EA2"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="916e6f", smooth=false},
		},
		["Mayhem INJ"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="50ffe7", smooth=false},
		},
		--Kick Stacks
		["Kick DC"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="6df524", smooth=false},
		},
		["Kick HU"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="2a840a", smooth=false},
		},
		["Kick FE"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="b5abe3", smooth=false},
		},
		["Kick TT"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="03c7d0", smooth=false},
		},
		["Breakthrough DNM"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="723dc3", smooth=false},
		},
		["Flying Kick INJ"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="1e882f", smooth=false},
		},
		["Kick R1[8]"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="ddd43a", smooth=false},
		},
		["Kick R1[16]"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="e6b681", smooth=false},
		},
		["Kick R2[8]"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="f00ed6", smooth=false},
		},
		["Kick R2[16]"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="faa45c", smooth=false},
		},
		["Kick R3[8]"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="939ed9", smooth=false},
		},
		["Kick R3[16]"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="e69b17", smooth=false},
		},
		["Kick RC[8]"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="317cb7", smooth=false},
		},
		["Kick RC[16]"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="ccc6ff", smooth=false},
		},
		["Valor FotR"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="434ea1", smooth=false},
		},
		["Valor 2T"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="cdceef", smooth=false},
		},
		["Valor RotK"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="585b63", smooth=false},
		},
		["Valor UJ"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="f0d3c9", smooth=false},
		},
		["Inside Joke CN"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="8c0102", smooth=false},
		},
		["Inside Joke AA"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="fe35df", smooth=false},
		},
		["Cartoons Titans Go TTG"] = {
		{position={zTable.zOther2.getPosition().x, 1.5, zTable.zOther2.getPosition().z}, rotation={0, 180, 0}, guid="201af8", smooth=false},
		},
		["Titans Go! TTG"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="201af8", smooth=false},
		},
		["Portal Gun RM1"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="dc32c1", smooth=false},
		},
		["Portal Gun RM2"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="d627d3", smooth=false},
		},
		["Kick SF"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="afac8d", smooth=false},
		},
		["Kick NS"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="52044c", smooth=false},
		},
		["Wild Magic EA1"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="5dbd48", smooth=false},
		},
		["Wild Magic EA2"] = {
		{position={zTable.zKickStack.getPosition().x, menuToggleExtras.kBagID_y, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="9c12be", smooth=false},
		},
		--Weakness Stacks
		["Weakness DC"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="fa9c3f", smooth=false},
		},
		["Weakness HU"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="8287cf", smooth=false},
		},
		["Weakness FE"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="762e23", smooth=false},
		},
		["Weakness TT"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="cc5112", smooth=false},
		},
		["Weakness DNM"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="7f97ee", smooth=false},
		{position={25.25, 1.5, 0}, rotation={0, 180, 0}, guid="8f966b", smooth=false,}, -- Who Laughs
		},
		["Weakness INJ"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="1e45c6", smooth=false},
		},
		["Weakness R1[10]"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="701e7b", smooth=false},
		},
		["Weakness R1[20]"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="f55d52", smooth=false},
		},
		["Weakness R2[10]"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="6635a5", smooth=false},
		},
		["Weakness R2[20]"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="4ad568", smooth=false},
		},
		["Weakness R3[10]"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="28bd44", smooth=false},
		},
		["Weakness R3[20]"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="fa273a", smooth=false},
		},
		["Weakness RC[10]"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="1020a8", smooth=false},
		},
		["Weakness RC[20]"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="829499", smooth=false},
		},
		["Corruption FotR"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="7a868d", smooth=false},
		},
		["Corruption 2T"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="6614be", smooth=false},
		},
		["Corruption RotK"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="eb1405", smooth=false},
		},
		["Corruption UJ"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="3cf9d6", smooth=false},
		},
		["Corruption DoS"] = {
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="e5c018", smooth=false},
		},
		["Weakness CN"] = {
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="858ca5", smooth=false},
		},
		["Weakness Cartoon CN"] = {
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 180}, guid="858ca5", smooth=false},
		},
		["Weakness AA"] = {
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="589faa", smooth=false},
		},
		["Weakness Cartoon AA"] = {
		{position={zTable.zWeaknessStack.getPosition().x, 3, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 180}, guid="589faa", smooth=false},
		},
		["Weakness TTG"] = {
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="39fcea", smooth=false},
		},
		["Weakness Cartoon TTG"] = {
		{position={zTable.zWeaknessStack.getPosition().x, 4.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 180}, guid="39fcea", smooth=false},
		},
		["MortyWave RM1"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="1f2618", smooth=false},
		},
		["MortyWave RM2"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="0ce230", smooth=false},
		},
		["Weakness SF"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="ce7307", smooth=false},
		},
		["Weakness NS"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="084a41", smooth=false},
		},
		["Weakness RB"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="8e06ae", smooth=false},
		},
		["Limp Wand EA1"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="e37c8e", smooth=false},
		},
		["Limp Wand EA2"] = {
		{position={zTable.zWeaknessStack.getPosition().x, menuToggleExtras.wBagID_y, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="d8a034", smooth=false},
		},
		--Boss Stack Default Locations
	    ["Boss DC"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="1fe2ea", smooth=false},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="d99739", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="0c6138", smooth=false},
		},
	    ["Boss HU"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="f56430", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="64f65e", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="10b010", smooth=false,},
		},
	    ["Boss FE"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="5df7fc", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="f7b885", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="1c16cf", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="cf870f", smooth=false,},
		},
	    ["Boss TT"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="95803b", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="056612", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="f4da3b", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="afe43a", smooth=false,},
		},
	    ["Boss DNM"] = {
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="e3b401", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="66b404", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="4cb9a1", smooth=false,},
		},
	    ["Boss INJ"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="e81c9a", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="27661d", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="360856", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="6c343e", smooth=false,},
		},
		["Boss C1"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="38a1c3", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="a36b59", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="3c2b26", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y+1.5, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="800282", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y+3, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="b9b139", smooth=false,},
		},
		["Boss C2"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="db38b9", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="7db3c5", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="32381c", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y+1.5, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="8d5642", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y+3, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="f11d14", smooth=false,},
		},
		["Boss C3"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="597b31", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="01f2aa", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="19aed1", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y+1.5, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="ed4d2f", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y+3, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="8b00c4", smooth=false,},
		},
		["Boss C4"] = {
		{position={16.75, 1.5, 0}, rotation={0, 180, 0}, guid="3a8037", smooth=false},
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="ab2ff5", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="1efbe9", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="8c35be", smooth=false,},
		},
		["Boss FotR"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="8d913e", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="b0f5f8", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="a7c56c", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="47f7ac", smooth=false,},
		},
		["Boss FotR IM"] = {
		{position={5.04, 1.5, 4.75}, rotation={0, 180, 180}, guid="521e24", smooth=false,},
		{position={5.04, 5, 4.75}, rotation={0, 180, 0}, guid="f755f5", smooth=false,},
		},
		["Boss 2T"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="e15582", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="76bf25", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="b61de1", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="e39d7f", smooth=false,},
		},
		["Boss 2T IM"] = {
		{position={5.04, 1.5, 4.75}, rotation={0, 180, 180}, guid="a934f7", smooth=false,},
		{position={5.04, 5, 4.75}, rotation={0, 180, 0}, guid="c28283", smooth=false,},
		},
		["Boss RotK"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="0a79c5", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="9620d9", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="e0028e", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="30f23f", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="b7fd62", smooth=false,},
		},
		["Boss RotK IM"] = {
		{position={5.04, 1.5, 4.75}, rotation={0, 180, 180}, guid="832091", smooth=false,},
		{position={5.04, 5, 4.75}, rotation={0, 180, 0}, guid="f9f316", smooth=false,},
		},
		["Boss UJ"] = {
					  {position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="94860a", smooth=false,}, --Boss 1
					  {position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="8ec9dc", smooth=false,}, --Boss 2
					  {position={8.49, 4, 4.75}, rotation={0, 180, 180}, guid="d0fd60", smooth=false,},
					  },
		["Boss DoS"] = {
					  {position={8.49, 1.5, 4.75}, rotation={0, 180, 180}, guid="be6b6c", smooth=false,},
					  {position={5.04, 1.5, 4.75}, rotation={0, 180, 180}, guid="05fb42", smooth=false,},
					  },
		["Boss TTG"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="b5a62b", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="f1793d", smooth=false,},
		},
		["Boss UJ IM"] = {
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="75b172", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="ed21d4", smooth=false,},
		{position={8.49, 4, 4.75}, rotation={0, 180, 180}, guid="78a0b0", smooth=false,},
		},
		["Boss Dos IM"] = {
		{position={8.49, 1.5, 4.75}, rotation={0, 180, 180}, guid="537bd2", smooth=false,},
		{position={5.04, 1.5, 4.75}, rotation={0, 180, 180}, guid="d3bd8a", smooth=false,},
		},
	    ["Legend EA1"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="57795b", smooth=false},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="0ee4fb", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="7a0bda", smooth=false},
		},
		["Legend EA2"] = {
		{position={zTable.zEventDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zEventDeck.getPosition().z}, rotation={0, 180, 180}, guid="e525b0", smooth=false},
		{position={zTable.zEventDeck.getPosition().x, menuToggleExtras.mdBagID_y+1, zTable.zEventDeck.getPosition().z}, rotation={0, 180, 180}, guid="a87c59", smooth=false},
		},
	    ["Legend EGB"] = {
		{position={12.48, 1.05, -0.63}, rotation={0, 180, 0}, guid="c524d9", smooth=false, lock="yes"},
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.bBagID_y+2, zTable.zCharacter.getPosition().z}, rotation={0, 180, 0}, guid="7a7f64", smooth=false},
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.bBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="e1ce6e", smooth=false},
		},
		--Custom Mode Boss Locations
	    ["CM Boss DC"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="1fe2ea", smooth=false},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="d99739", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="0c6138", smooth=false},
		},
	    ["CM Boss HU"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="f56430", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="64f65e", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="10b010", smooth=false,},
		},
	    ["CM Boss FE"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="5df7fc", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="f7b885", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="1c16cf", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="cf870f", smooth=false,},
		},
	    ["CM Boss TT"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="95803b", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="056612", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="f4da3b", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="afe43a", smooth=false,},
		},
	    ["CM Boss DNM"] = {
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="e3b401", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="66b404", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="4cb9a1", smooth=false,},
		},
	    ["CM Boss INJ"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="e81c9a", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="27661d", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="360856", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="6c343e", smooth=false,},
		},
		["CM Boss C1"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="a36b59", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="3c2b26", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="800282", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="b9b139", smooth=false,},
		},
		["CM Boss C1 Crisis"] = {
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="8f2f4a", smooth=false,},
		},
		["CM Boss C2"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="7db3c5", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="32381c", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="8d5642", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="f11d14", smooth=false,},
		},
		["CM Boss C2 Crisis"] = {
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="20d606", smooth=false,},
		},
		["CM Boss C3"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="01f2aa", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="19aed1", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="ed4d2f", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="8b00c4", smooth=false,},
		},
		["CM Boss C3 Crisis"] = {
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="48c9f7", smooth=false,},
		},
		["CM Boss C4"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="ab2ff5", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="1efbe9", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="8c35be", smooth=false,},
		},
		["CM Boss C4 Crisis"] = {
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="1e16e9", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="3e5fd7", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="b4f4bf", smooth=false,},
		},
		["CM Boss CO1"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="238c73", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="e22ec3", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="2cc1f6", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="93c10e", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="873dec", smooth=false,},
		},
		["CM Boss CO2"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="5095ef", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="7224c0", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="be7ad9", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="2922e7", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="ecab22", smooth=false,},
		},
		["CM Boss CO3"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="0d2299", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="3c67ec", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="3e8233", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="d410f9", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="e9b154", smooth=false,},
		},
		["CM Boss CO5"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="592010", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="94cf62", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="01ae2c", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="239bfa", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="2f8485", smooth=false,},
		},
		["CM Boss CO6"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="7a71a1", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="8633da", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="53a778", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="19cc08", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="d7eefc", smooth=false,},
		},
		["CM Boss CO7"] = {
		{position={5.04, 1.5, 9.5}, rotation={0, 180, 0}, guid="6bab4c", smooth=false},
		{position={8.49, 1.5, 9.5}, rotation={0, 180, 0}, guid="566bb0", smooth=false},
		},
		["CM Boss CO8"] = {
		{position={-22.5, 1.5, 4.2}, rotation={0, 90, 0}, guid="5bbb3e", smooth=false},
		{position={-25.55, 1.5, 0}, rotation={0, 90, 180}, guid="56ef58", smooth=false},
		{position={-20, 1.5, 0}, rotation={0, 90, 180}, guid="82ea6d", smooth=false},
		{position={-25.55, 1.5, -4.15}, rotation={0, 90, 180}, guid="eb7600", smooth=false},
		{position={-20, 1.5, -4.15}, rotation={0, 90, 180}, guid="6cf96d", smooth=false},
		},
		["CM Boss CO9"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="b1eb4a", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="0a3892", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="427e11", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="69b919", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="954a71", smooth=false,},
		},
		["CM Boss FotR"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="8d913e", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="b0f5f8", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="a7c56c", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="47f7ac", smooth=false,},
		},
		["CM Boss FotR IM"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="63baa4", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="28980b", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="abcaa1", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="b05703", smooth=false,},
		},
		["CM Boss 2T"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="e15582", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="76bf25", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="b61de1", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="e39d7f", smooth=false,},
		},
		["CM Boss 2T IM"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="7837ff", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="1518c5", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="83779a", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="df1965", smooth=false,},
		},
		["CM Boss RotK"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="0a79c5", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="9620d9", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="e0028e", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="30f23f", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="b7fd62", smooth=false,},
		},
		["CM Boss RotK IM"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="c3c4ff", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="81c7cb", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="92e344", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="b1ee67", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="6498a0", smooth=false,},
		},
		["CM Boss UJ"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="94860a", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="8ec9dc", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="d0fd60", smooth=false,},
		},
		["CM Boss UJ IM"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="73adb4", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="ed21d4", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="78a0b0", smooth=false,},
		},
		["CM Boss DoS"] = {
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="be6b6c", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="05fb42", smooth=false,},
		},
		["CM Boss DoS IM"] = {
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="537bd2", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="d3bd8a", smooth=false,},
		},
		["CM Nemesis CN"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="e68cb0", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="5b8e3e", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="2a2b7f", smooth=false,},
		},
		["CM Nemesis AA"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="a87134", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="ae2845", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="963aa5", smooth=false,},
		},
		["CM Nemesis TTG"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="b5a62b", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="f1793d", smooth=false,},
		},
		["CM Nemesis RM1"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="8f2659", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="0800ad", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="dbe704", smooth=false,},
		},
		["CM Nemesis RM2"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="1d185f", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="85483c", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="a4dcc9", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="fe44eb", smooth=false,},
		},
		["CM Location SF"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="eabca4", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="0db766", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="89ee45", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="fdc6c6", smooth=false,},
		},
		["CM Archenemy NS"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="743ccb", smooth=false,},
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="02a24f", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="6b51c9", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="7c286c", smooth=false,},
		},
		["CM Boss MV"] = {
		{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="0c6824", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="c2cf0f", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y+0.25, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="c2ec02", smooth=false,},
		},
		["CM Boss RB"] = {
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="24ea8d", smooth=false,},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="e48863", smooth=false,},
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="570eee", smooth=false,},
		{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="8f27bb", smooth=false,},
		},
		--Multiverse
		["MV"] = {
					  {position={1.59, 1.5, 20}, rotation={0, 90, 180}, guid="f228a6", smooth=false,}, -- Multiverse Locations
					  {position={-8.76, 1.5, 4.75}, rotation={0, 180, 180}, guid="bbaeea", smooth=false,}, -- Main Deck
					  {position={5.04, 2.5, 4.75}, rotation={0, 180, 0}, guid="0c6824", smooth=false,}, -- Boss 10
					  {position={5.04, 2, 4.75}, rotation={0, 180, 180}, guid="c2cf0f", smooth=false,}, -- Boss 15
					  {position={5.04, 1.5, 4.75}, rotation={0, 180, 180}, guid="c2ec02", smooth=false,}, -- Boss 23
					  {position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 0}, guid="04baf6", smooth=false,}, -- Convergence
					  {position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="82b452", smooth=false,}, -- Events
					  {position={-5.31, 1.5, 4.75}, rotation={0, 180, 180}, guid="3f5abc", smooth=false,}, -- Randomizers
					  {position={30, 1, 50}, rotation={0, 180, 0}, guid="5641ed", smooth=false, lock="yes"},}, -- RuleBook
		["MV_DC"] = {
					  {position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="78bd33", smooth=false},
					  {position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="6df524", smooth=false},
					  {position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="fa9c3f", smooth=false},},
		["MV_HU"] = {
					  {position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="f88cb0", smooth=false,},
					  {position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="2a840a", smooth=false,},
					  {position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="8287cf", smooth=false,},},
		["MV_FE"] = {
					  {position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="0ae6b3", smooth=false,},
					  {position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="b5abe3", smooth=false,},
					  {position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="762e23", smooth=false,},},
		["MV_TT"] = {
					  {position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="71a06e", smooth=false,},
					  {position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="03c7d0", smooth=false,},
					  {position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="cc5112", smooth=false,},},
		["MV_DNM"] = {
					  {position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="1fd085", smooth=false,},
					  {position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="723dc3", smooth=false,},
					  {position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="7f97ee", smooth=false,},
					  {position={25.25, 1.5, 0}, rotation={0, 180, 0}, guid="8f966b", smooth=false,},}, --Who laughs
		["MV_RC"] = {
					  {position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="29ec36", smooth=false,},
					  {position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="ccc6ff", smooth=false,},
					  {position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="829499", smooth=false,},},
		["MV_INJ"] = {
					  {position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="761b5a", smooth=false},
					  {position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="1e882f", smooth=false},
					  {position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="1e45c6", smooth=false},},
		["MV_Standard"] = {
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="0ae7e2", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="f2482e", smooth=false},},
		["MV_Impossible"] = {
		{position={zTable.zBoss2.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss2.getPosition().z}, rotation={0, 180, 180}, guid="e414b8", smooth=false},
		{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="2268e7", smooth=false},},
		["MV_StandardExtra"] = {
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="afefed", smooth=false,},},
		["MV_ImpossibleExtra"] = {
		{position={zTable.zBoss4.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss4.getPosition().z}, rotation={0, 180, 180}, guid="efff09", smooth=false,},},
		["MV_CrisisEvent"] = {
		{position={8.49, 2, 14.25}, rotation={0, 180, 180}, guid="7326cb", smooth=false,},},
		["MV_C1_CrisisStack"] = {
		{position={8.49, 1.5, 4.75}, rotation={0, 180, 180}, guid="5f205e", smooth=false,},},
		["MV_C2_CrisisStack"] = {
		{position={8.49, 2, 4.75}, rotation={0, 180, 180}, guid="cebc2c", smooth=false,},},
		["MV_C3_CrisisStack"] = {
		{position={8.49, 2.5, 4.75}, rotation={0, 180, 180}, guid="bd030d", smooth=false,},},
		["MV_MCs_DC"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="eea05f", smooth=false,},},
		["MV_MCs_HU"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="d2fefe", smooth=false,},},
		["MV_MCs_FE"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="cd106c", smooth=false,},},
		["MV_MCs_TT"] = {
		{position={12.48, 3.5, 0}, rotation={0, 180, 180}, guid="507555", smooth=false,},},
		["MV_MCs_DNM"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="89ef1d", smooth=false,},
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y+0.25, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="9a2e3c", smooth=false,},},
		["MV_MCs_INJ"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="eccebe", smooth=false,},},
		["MV_NotPicked_DC"] = {
		{position={-8.76, 1.5, 56.5}, rotation={0, 180, 180}, guid="78bd33", smooth=false,},},
		["MV_NotPicked_HU"] = {
		{position={-5.31, 1.5, 56.5}, rotation={0, 180, 180}, guid="f88cb0", smooth=false,},},
		["MV_NotPicked_FE"] = {
		{position={-1.86, 1.5, 56.5}, rotation={0, 180, 180}, guid="0ae6b3", smooth=false,},},
		["MV_NotPicked_TT"] = {
		{position={1.59, 1.5, 56.5}, rotation={0, 180, 180}, guid="71a06e", smooth=false,},},
		["MV_NotPicked_DNM"] = {
		{position={5.04, 1.5, 56.5}, rotation={0, 180, 180}, guid="1fd085", smooth=false,},},
		["MV_NotPicked_RC"] = {
		{position={5.04, 1.5, 37.5}, rotation={0, 180, 180}, guid="29ec36", smooth=false,},},
		["MV_NotPicked_INJ"] = {
		{position={-5.31, 1.5, 32.75}, rotation={0, 180, 180}, guid="761b5a", smooth=false,},},
		["MV_Picked_DC"] = {
		{position={-8.76, 1.5, 0}, rotation={0, 180, 180}, guid="78bd33", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="6df524", smooth=false},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="fa9c3f", smooth=false},},
		["MV_Picked_HU"] = {
		{position={-8.76, 1.5, 0}, rotation={0, 180, 180}, guid="f88cb0", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="2a840a", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="8287cf", smooth=false,},},
		["MV_Picked_FE"] = {
		{position={-8.76, 1.5, 0}, rotation={0, 180, 180}, guid="0ae6b3", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="b5abe3", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="762e23", smooth=false,},},
		["MV_Picked_TT"] = {
		{position={-8.76, 1.5, 0}, rotation={0, 180, 180}, guid="71a06e", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="03c7d0", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="cc5112", smooth=false,},},
		["MV_Picked_DNM"] = {
		{position={-8.76, 1.5, 0}, rotation={0, 180, 180}, guid="1fd085", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="723dc3", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="7f97ee", smooth=false,},
		{position={25.25, 1.5, 0}, rotation={0, 180, 0}, guid="8f966b", smooth=false,},}, -- who laughs
		["MV_Picked_RC"] = {
		{position={-8.76, 1.5, 0}, rotation={0, 180, 180}, guid="29ec36", smooth=false,},
		{position={1.59, 1.5, 4.75}, rotation={0, 180, 0}, guid="ccc6ff", smooth=false,},
		{position={-1.86, 1.5, 4.75}, rotation={0, 180, 0}, guid="829499", smooth=false,},},
		["MV_Picked_INJ"] = {
			{position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="761b5a", smooth=false},
			{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="1e882f", smooth=false},
			{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="1e45c6", smooth=false},},
		["MV_Core_C1"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="38a1c3", smooth=false,},
		{position={-8.76, 1.5, 51.75}, rotation={0, 180, 180}, guid="ab7f41", smooth=false,},},
		["MV_Core_C2"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="db38b9", smooth=false,},
		{position={-5.31, 1.5, 51.75}, rotation={0, 180, 180}, guid="e7ea20", smooth=false,},},
		["MV_Core_C3"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="597b31", smooth=false,},
		{position={-1.86, 1.5, 51.75}, rotation={0, 180, 180}, guid="06b10a", smooth=false,},},
		["MV_Core_C4"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="3a8037", smooth=false,},
		{position={1.59, 1.5, 51.75}, rotation={0, 180, 180}, guid="48e13a", smooth=false,},},
		["MV_Core_CO1"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="23266b", smooth=false,},
		{position={-8.76, 1.5, 47}, rotation={0, 180, 180}, guid="02c52b", smooth=false,},},
		["MV_Core_CO2"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="b8d513", smooth=false,},
		{position={-5.31, 1.5, 47}, rotation={0, 180, 180}, guid="8ddfc7", smooth=false,},},
		["MV_Core_CO3"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="f30a15", smooth=false,},
		{position={-1.86, 1.5, 47}, rotation={0, 180, 180}, guid="3263cf", smooth=false,},},
		["MV_Core_CO4"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="2f8a1e", smooth=false,},
		{position={1.59, 1.5, 47}, rotation={0, 180, 180}, guid="418d35", smooth=false,},},
		["MV_Core_CO5"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="768bb5", smooth=false,},
		{position={5.04, 1.5, 47}, rotation={0, 180, 180}, guid="b482da", smooth=false,},},
		["MV_Core_CO6"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="49f230", smooth=false,},
		{position={-8.76, 1.5, 42.25}, rotation={0, 180, 180}, guid="cabb11", smooth=false,},},
		["MV_Core_CO7"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="dea298", smooth=false,},
		{position={-5.31, 1.5, 42.25}, rotation={0, 180, 180}, guid="cf9c78", smooth=false,},},
		["MV_Core_CO8"] = {
		{position={12.48, 10, 0}, rotation={0, 180, 180}, guid="5d06d6", smooth=false,},
		{position={-1.86, 1.5, 42.25}, rotation={0, 180, 180}, guid="e5123d", smooth=false,},},
		["MV_Core_CO9"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="bcb174", smooth=false,},
		{position={1.59, 1.5, 42.25}, rotation={0, 180, 180}, guid="ce3e75", smooth=false,},},
		["MV_Core_R1"] = {
		{position={-8.76, 1.5, 37.5}, rotation={0, 180, 180}, guid="5d21bb", smooth=false,},},
		["MV_Core_R2"] = {
		{position={-5.31, 1.5, 37.5}, rotation={0, 180, 180}, guid="fcf746", smooth=false,},},
		["MV_Core_R3"] = {
		{position={-1.86, 1.5, 37.5}, rotation={0, 180, 180}, guid="ee8008", smooth=false,},},
		["MV_Core_RB"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="f7fa91", smooth=false,},
		{position={-8.76, 1.5, 32.75}, rotation={0, 180, 180}, guid="18b2df", smooth=false,},},
		["MV_Core_TTG"] = {
		{position={zTable.zCharacter.getPosition().x, menuToggleExtras.cBagID_y, zTable.zCharacter.getPosition().z}, rotation={0, 180, 180}, guid="ca96c4", smooth=false,},
		{position={5.04, 1.5, 32.75}, rotation={0, 180, 180}, guid="43f00a", smooth=false,},},
		--DCDB
		["Cube Boss Stack"] = {
        {position={6.85, 1.4, -29.05}, rotation={0, 180, 180}, guid="ee8177", smooth=false,}, --8
        {position={6.85, 1.4, -29.05}, rotation={0, 180, 180}, guid="658875", smooth=false,}, --9
        {position={6.85, 1.4, -29.05}, rotation={0, 180, 180}, guid="790e8e", smooth=false,}, --10
        {position={6.85, 1.4, -29.05}, rotation={0, 180, 180}, guid="46168a", smooth=false,}, --11
        {position={6.85, 1.4, -29.05}, rotation={0, 180, 180}, guid="51f66d", smooth=false,}, --12
        {position={6.85, 1.4, -29.05}, rotation={0, 180, 180}, guid="b92935", smooth=false,}, --13
        {position={6.85, 1.4, -29.05}, rotation={0, 180, 180}, guid="e185bf", smooth=false,}, --14
		},
		["Custom Cube"] = {
		{position={5.02, 1.56, 8.44}, rotation={0, 180, 180}, guid="aad4c5", smooth=false, lock="yes",},
		{position={-12.5, 1.5, -12}, rotation={0, 180, 0}, guid="65038d", smooth=false}, --tier 1
		{position={-7.5, 1.5, -12}, rotation={0, 180, 0}, guid="e7488e", smooth=false}, --tier 2
		{position={-2.5, 1.5, -12}, rotation={0, 180, 0}, guid="5a0870", smooth=false}, --tier 3
		{position={2.5, 1.5, -12}, rotation={0, 180, 0}, guid="3abfa6", smooth=false}, --tier 4
		{position={7.5, 1.5, -12}, rotation={0, 180, 0}, guid="13bad1", smooth=false}, --tier 5
		{position={12.5, 1.5, -12}, rotation={0, 180, 0}, guid="1cdcb4", smooth=false}, --tier 6
		--{position={-7.5, 1.5, -18.5}, rotation={0, 180, 0}, guid="630e9c", smooth=false}, --tier 7
		--{position={-2.5, 1.5, -18.5}, rotation={0, 180, 0}, guid="29dffe", smooth=false}, --tier 8
		--{position={2.5, 1.5, -18.5}, rotation={0, 180, 0}, guid="cf582b", smooth=false}, --tier 9
		
		{position={-12.5, 1.5, -14}, rotation={0, 180, 0}, guid="ffb509", smooth=false}, --token 1
		{position={-7.5, 1.5, -14}, rotation={0, 180, 0}, guid="f364a4", smooth=false}, --token 2
		{position={-2.5, 1.5, -14}, rotation={0, 180, 0}, guid="d3abb0", smooth=false}, --token 3
		{position={2.5, 1.5, -14}, rotation={0, 180, 0}, guid="5fa797", smooth=false}, --token 4
		{position={7.5, 1.5, -14}, rotation={0, 180, 0}, guid="1dd6fe", smooth=false}, --token 5
		{position={12.5, 1.5, -14}, rotation={0, 180, 0}, guid="1ca8fd", smooth=false}, --token 6
		--{position={-7.5, 1.5, -20.5}, rotation={0, 180, 0}, guid="9123ec", smooth=false}, --token 7
		--{position={-2.5, 1.5, -20.5}, rotation={0, 180, 0}, guid="b1a79e", smooth=false}, --token 8
		--{position={2.5, 1.5, -20.5}, rotation={0, 0, 0}, guid="4694f7", smooth=false}, --token 9
		{position={12.2, 1, 0}, rotation={0, 180, 0}, guid="68a60c", smooth=false}, --Doctor Fate Transformed
		{position={zTable.zMainDeck.getPosition().x, 2, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="ca7c5e", smooth=false}, --Main Deck
		{position={zTable.zKickStack.getPosition().x, 1.5, zTable.zKickStack.getPosition().z}, rotation={0, 180, 0}, guid="7caeb0", smooth=false}, --Kicks
		{position={zTable.zWeaknessStack.getPosition().x, 1.5, zTable.zWeaknessStack.getPosition().z}, rotation={0, 180, 0}, guid="3cd490", smooth=false}, --Weakness
		{position={zTable.zOther1.getPosition().x, 2, zTable.zOther1.getPosition().z}, rotation={0, 180, 0}, guid="7c411d", smooth=false}, --other 1
		{position={zTable.zOther2.getPosition().x, 1.5, zTable.zOther2.getPosition().z}, rotation={0, 180, 0}, guid="cd165a", smooth=false}, --other 2
		{position={zTable.zCrisisStack.getPosition().x, 1.5, zTable.zCrisisStack.getPosition().z}, rotation={0, 180, 180}, guid="99563c", smooth=false}, --crisis
		--{position={zTable.zBoss1.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss1.getPosition().z}, rotation={0, 180, 180}, guid="71b989", smooth=false,}, --Start Boss
		--{position={zTable.zBoss3.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss3.getPosition().z}, rotation={0, 180, 180}, guid="76f234", smooth=false,}, --Middle Boss
		--{position={zTable.zBoss5.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBoss5.getPosition().z}, rotation={0, 180, 180}, guid="8af2ea", smooth=false,}, --Final Boss
		},
		--Rebirth
		["RB Scenario 1"] = {
			{position={-10.57, 5, -2.34}, rotation={0, 180, 0}, guid="a3fb42", smooth=false,},
			{position={-15.57, 5, -2.34}, rotation={0, 180, 180}, guid="dbf2f5", smooth=false,},},
		["RB Scenario 2"] = {
			{position={-10.57, 5, -2.34}, rotation={0, 180, 0}, guid="206eaf", smooth=false,},
			{position={-15.57, 5, -2.34}, rotation={0, 180, 180}, guid="e944ad", smooth=false,},
			{position={-5.75, 5, -13.5}, rotation={0, 180, 0}, guid="0f3dcf", smooth=false,},
			{position={-5.75, 3, -13.5}, rotation={0, 180, 180}, guid="c1a366", smooth=false,},
			{position={5.75, 5, -13.5}, rotation={0, 180, 0}, guid="fbef75", smooth=false,},
			{position={5.75, 3, -13.5}, rotation={0, 180, 180}, guid="8e8436", smooth=false,},
			{position={0, 5, -13.5}, rotation={0, 180, 0}, guid="08b1c9", smooth=false,},},
		["RB Scenario 3"] = {
			{position={-10.57, 5, -2.34}, rotation={0, 180, 0}, guid="f8a8f5", smooth=false,},
			{position={-1.87, 5, 14.25}, rotation={0, 180, 180}, guid="c1a366", smooth=false,},
			{position={-1.87, 15, 14.25}, rotation={0, 180, 180}, guid="fc4d34", smooth=false,},},
		["RB Scenario 4"] = {
			{position={-10.57, 5, -2.34}, rotation={0, 180, 0}, guid="447135", smooth=false,},
			{position={-15.57, 5, -2.34}, rotation={0, 180, 180}, guid="dbf2f5", smooth=false,},},
		["RB Scenario 5"] = {
			{position={-10.57, 5, -2.34}, rotation={0, 180, 0}, guid="482efd", smooth=false,},
			{position={-15.57, 5, -2.34}, rotation={0, 180, 180}, guid="ebebad", smooth=false,},
			{position={1.59, 10, 14.25}, rotation={0, 180, 180}, guid="c1a366", smooth=false,},},
		["RB Scenario 6"] = {
			{position={-10.57, 5, -2.34}, rotation={0, 180, 0}, guid="02bf3a", smooth=false,},
			{position={-15.57, 5, -2.34}, rotation={0, 180, 180}, guid="dbf2f5", smooth=false,},},
		["RB Scenario 7"] = {
			{position={-10.57, 5, -2.34}, rotation={0, 180, 180}, guid="721465", smooth=false,},
			{position={-15.57, 5, -2.34}, rotation={0, 180, 180}, guid="dbf2f5", smooth=false,},},
		["RB Scenario 8"] = {
			{position={-10.57, 5, -2.34}, rotation={0, 180, 0}, guid="fb0922", smooth=false,},
			{position={-1.86, 5, 14.25}, rotation={0, 180, 180}, guid="c1a366", smooth=false,},
			{position={-15.57, 5, -2.34}, rotation={0, 180, 0}, guid="d44aa8", smooth=false,},
			{position={10.57, 5, -2.34}, rotation={0, 180, 180}, guid="0f68ed", smooth=false,},},
		["RB Log"] = {
		{position={76.7, 1.2, 59}, rotation={0, 180, 0}, guid="eda22b", smooth=false, lock="yes",},},
		["RB Tracker A - L2/T2"] = {
		{position={1.8, 1.5, -1.23}, rotation={0, 180, 0}, guid="8e0023", smooth=false,},},
		["RB Tracker A - L4/T1"] = {
		{position={-1.8, 1.5, 0.66}, rotation={0, 180, 0}, guid="8e0023", smooth=false,},},
		["RB Tracker B - L2/T1"] = {
		{position={-1.8, 1.5, -1.23}, rotation={0, 180, 0}, guid="18bb99", smooth=false,},},
		["RB Tracker B - L3/T1"] = {
		{position={-1.8, 1.5, -0.29}, rotation={0, 180, 0}, guid="18bb99", smooth=false,},},
		["RB Tracker B - L4/T1"] = {
		{position={-1.8, 1.5, 0.66}, rotation={0, 180, 0}, guid="18bb99", smooth=false,},},
		["RB Tracker C - L1/T1"] = {
		{position={-1.8, 1.5, -2.18}, rotation={0, 180, 0}, guid="81f4c4", smooth=false,},},
		["RB Tracker C - L3/T1"] = {
		{position={-1.8, 1.5, -0.29}, rotation={0, 180, 0}, guid="81f4c4", smooth=false,},},
		["RB Tracker D - L0/T2"] = {
		{position={1.8, 1.5, -3.12}, rotation={0, 180, 0}, guid="574ecf", smooth=false,},},
		["RB Tracker E - L1/T2"] = {
		{position={1.8, 1.5, -2.18}, rotation={0, 180, 0}, guid="ab57a8", smooth=false,},},
		["RB Tracker F - L0/T2"] = {
		{position={1.8, 1.5, -3.12}, rotation={0, 180, 0}, guid="3861b9", smooth=false,},},
		["RB Tracker G - L1/T2"] = {
		{position={1.8, 1.5, -1.23}, rotation={0, 180, 0}, guid="2fc22d", smooth=false,},},
		["RB Tracker G - L2/T2"] = {
		{position={1.8, 1.5, -2.18}, rotation={0, 180, 0}, guid="2fc22d", smooth=false,},},
		["RB Tracker H - L2/T1"] = {
		{position={-1.8, 1.5, -1.23}, rotation={0, 180, 0}, guid="6633f7", smooth=false,},},
		["RB Tracker I - L5/T1"] = {
		{position={-1.8, 1.5, 1.96}, rotation={0, 180, 0}, guid="f71799", smooth=false,},},
		["RB Tracker Blank - L5"] = {
		{position={-1.8, 1.5, 1.96}, rotation={0, 180, 180}, guid="f71799", smooth=false,},},
		["RB Tracker Blank - L1"] = {
		{position={-1.8, 1.5, -2.18}, rotation={0, 180, 180}, guid="ab57a8", smooth=false,},},
		["RB Tracker Blank - L2"] = {
		{position={-1.8, 1.5, -1.23}, rotation={0, 180, 180}, guid="2fc22d", smooth=false,},},
		["RB Tracker Blank - L3"] = {
		{position={-1.8, 1.5, 0.29}, rotation={0, 180, 180}, guid="81f4c4", smooth=false,},},
		["RB Repairs"] = {
		{position={0, 5, -13.5}, rotation={0, 180, 0}, guid="08b1c9", smooth=false,},},
		["RB Recruit Krypto"] = {
		{position={-5.75, 5, -13.5}, rotation={0, 180, 0}, smooth=false, guid="0f3dcf"},
		{position={-5.75, 3, -13.5}, rotation={0, 180, 180}, smooth=false, guid="c1a366"},},
		["RB Recruit The Ray"] = {
		{position={5.75, 5, -13.5}, rotation={0, 180, 0}, smooth=false, guid="fbef75"},
		{position={5.75, 3, -13.5}, rotation={0, 180, 180}, smooth=false, guid="8e8436"},},
		["RB Unlock Krypto"] = {
		{position={zTable.zMainDeck.getPosition().x,3,zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="c1a366", smooth=false,},},
		["RB Unlock The Ray"] = {
		{position={zTable.zMainDeck.getPosition().x,3,zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="8e8436", smooth=false,},},
		["RB Unlock Mister Mxyzptlk"] = {
		{position={zTable.zBossStack.getPosition().x,2,zTable.zBossStack.getPosition().z}, rotation={0, 180, 180}, guid="c1a366", smooth=false,},},
		["RB Unlock Starro"] = {
		{position={zTable.zBossStack.getPosition().x,2,zTable.zBossStack.getPosition().z}, rotation={0, 180, 180}, guid="a0ee0a", smooth=false,},},
		["RB Unlock Impossible Mode"] = {
		{position={zTable.zOther2.getPosition().x,1.5,zTable.zOther2.getPosition().z}, rotation={0, 180, 180}, guid="0f68ed", smooth=false,},},
		["RB Arkham 1A"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Arkham 2A"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Arkham 3A"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Arkham 4A"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Arkham 5A"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Bank 1A"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Bank 2A"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Bank 3A"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Bank 4A"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Bank 5A"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Batcave 1A"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB Batcave 2A"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB Batcave 3A"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB Batcave 4A"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB Batcave 5A"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB City 1A"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB City 2A"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB City 3A"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB City 4A"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB City 5A"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB Daily 1A"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Daily 2A"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Daily 3A"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Daily 4A"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Daily 5A"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Police 1A"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="6820b0", smooth=false, lock="yes",},},
		["RB Police 2A"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="6820b0", smooth=false, lock="yes",},},
		["RB Police 3A"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="6820b0", smooth=false, lock="yes",},},
		["RB Police 4A"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="6820b0", smooth=false, lock="yes",},},
		["RB Police 5A"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="6820b0", smooth=false, lock="yes",},},
		["RB STAR 1A"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="6f208b", smooth=false, lock="yes",},},
		["RB STAR 2A"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="6f208b", smooth=false, lock="yes",},},
		["RB STAR 3A"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="6f208b", smooth=false, lock="yes",},},
		["RB STAR 4A"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="6f208b", smooth=false, lock="yes",},},
		["RB STAR 5A"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="6f208b", smooth=false, lock="yes",},},
		["RB Arkham 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 180}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Arkham 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 180}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Arkham 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 180}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Arkham 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 180}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Arkham 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 180}, guid="1b2dcf", smooth=false, lock="yes",},},
		["RB Bank 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 180}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Bank 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 180}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Bank 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 180}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Bank 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 180}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Bank 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 180}, guid="373dd9", smooth=false, lock="yes",},},
		["RB Batcave 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 180}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB Batcave 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 180}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB Batcave 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 180}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB Batcave 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 180}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB Batcave 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 180}, guid="ac72a4", smooth=false, lock="yes",},},
		["RB City 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 180}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB City 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 180}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB City 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 180}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB City 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 180}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB City 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 180}, guid="dc6de0", smooth=false, lock="yes",},},
		["RB Daily 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 180}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Daily 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 180}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Daily 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 180}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Daily 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 180}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Daily 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 180}, guid="5e6145", smooth=false, lock="yes",},},
		["RB Police 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 180}, guid="6820b0", smooth=false, lock="yes",},},
		["RB Police 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 180}, guid="6820b0", smooth=false, lock="yes",},},
		["RB Police 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 180}, guid="6820b0", smooth=false, lock="yes",},},
		["RB Police 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 180}, guid="6820b0", smooth=false, lock="yes",},},
		["RB Police 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 180}, guid="6820b0", smooth=false, lock="yes",},},
		["RB STAR 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,1,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 180}, guid="6f208b", smooth=false, lock="yes",},},
		["RB STAR 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,1,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 180}, guid="6f208b", smooth=false, lock="yes",},},
		["RB STAR 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,1,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 180}, guid="6f208b", smooth=false, lock="yes",},},
		["RB STAR 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,1,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 180}, guid="6f208b", smooth=false, lock="yes",},},
		["RB STAR 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,1,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 180}, guid="6f208b", smooth=false, lock="yes",},},
		["RB Batcycle 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,3,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="6d716f", smooth=false,},},
		["RB Batcycle 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,3,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="6d716f", smooth=false,},},
		["RB Batcycle 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,3,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="6d716f", smooth=false,},},
		["RB Batcycle 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,3,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="6d716f", smooth=false,},},
		["RB Batcycle 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,3,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="6d716f", smooth=false,},},
		["RB Batsignal 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,3,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="e9e940", smooth=false,},},
		["RB Batsignal 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,3,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="e9e940", smooth=false,},},
		["RB Batsignal 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,3,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="e9e940", smooth=false,},},
		["RB Batsignal 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,3,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="e9e940", smooth=false,},},
		["RB Batsignal 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,3,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="e9e940", smooth=false,},},
		["RB Flight 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,3,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="9bf4d4", smooth=false,},},
		["RB Flight 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,3,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="9bf4d4", smooth=false,},},
		["RB Flight 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,3,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="9bf4d4", smooth=false,},},
		["RB Flight 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,3,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="9bf4d4", smooth=false,},},
		["RB Flight 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,3,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="9bf4d4", smooth=false,},},
		["RB Super Speed 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,3,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="d2023d", smooth=false,},},
		["RB Super Speed 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,3,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="d2023d", smooth=false,},},
		["RB Super Speed 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,3,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="d2023d", smooth=false,},},
		["RB Super Speed 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,3,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="d2023d", smooth=false,},},
		["RB Super Speed 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,3,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="d2023d", smooth=false,},},
		["RB Tomorrow 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,3,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="0125e8", smooth=false,},},
		["RB Tomorrow 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,3,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="0125e8", smooth=false,},},
		["RB Tomorrow 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,3,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="0125e8", smooth=false,},},
		["RB Tomorrow 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,3,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="0125e8", smooth=false,},},
		["RB Tomorrow 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,3,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="0125e8", smooth=false,},},
		["RB Toss 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,3,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="636372", smooth=false,},},
		["RB Toss 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,3,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="636372", smooth=false,},},
		["RB Toss 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,3,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="636372", smooth=false,},},
		["RB Toss 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,3,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="636372", smooth=false,},},
		["RB Toss 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,3,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="636372", smooth=false,},},
		["RB Withdrawal 1B"] = {
		{position={zTable.zEventLineUp1.getPosition().x,3,zTable.zEventLineUp1.getPosition().z}, rotation={0, 180, 0}, guid="d8b9a0", smooth=false,},},
		["RB Withdrawal 2B"] = {
		{position={zTable.zEventLineUp2.getPosition().x,3,zTable.zEventLineUp2.getPosition().z}, rotation={0, 180, 0}, guid="d8b9a0", smooth=false,},},
		["RB Withdrawal 3B"] = {
		{position={zTable.zEventLineUp3.getPosition().x,3,zTable.zEventLineUp3.getPosition().z}, rotation={0, 180, 0}, guid="d8b9a0", smooth=false,},},
		["RB Withdrawal 4B"] = {
		{position={zTable.zEventLineUp4.getPosition().x,3,zTable.zEventLineUp4.getPosition().z}, rotation={0, 180, 0}, guid="d8b9a0", smooth=false,},},
		["RB Withdrawal 5B"] = {
		{position={zTable.zEventLineUp5.getPosition().x,3,zTable.zEventLineUp5.getPosition().z}, rotation={0, 180, 0}, guid="d8b9a0", smooth=false,},},
		--Special Custom Games
		["INJ KO'd Tokens"] = {
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="1c64a5", smooth=false, lock="yes"},},
		["Rivals Batman"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="682309", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="9d6063", smooth=false},
		},
		["Rivals The Joker"] = {
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="983696", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="4251ef", smooth=false},
		},
		["Rivals Green Lantern"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="543c41", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="1d072f", smooth=false},
		},
		["Rivals Sinestro"] = {
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="b0140a", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="4062f1", smooth=false},
		},
		["Rivals Flash"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="4b4672", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="d824d6", smooth=false},
		},
		["Rivals Reverse-Flash"] = {
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="db7b79", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="cd123c", smooth=false},
		},
		["Rivals R3 Extras"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="fb7ebd", smooth=false},
		},
		["Rivals Superman"] = {
		{position={-2.5,menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="4e2dc6", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="46ed42", smooth=false},
		},
		["Rivals Lex Luthor"] = {
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="7364c3", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="4ecc66", smooth=false},
		},
		["Rivals Wonder Woman"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="0f0cd0", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="f8c4d9", smooth=false},
		},
		["Rivals Circe"] = {
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="9b5f4a", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="fc0947", smooth=false},
		},
		["Rivals Aquaman"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="d28d73", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="d49224", smooth=false},
		},
		["Rivals Ocean Master"] = {
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="549fa9", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="e85d2b", smooth=false},
		},
		["Rivals Zatana Zatara"] = {
		{position={-2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="ec13ff", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="ef8447", smooth=false},
		},
		["Rivals Felix Faust"] = {
		{position={2.5, menuToggleExtras.cBagID_y, -12}, rotation={0, 180, 0}, guid="707680", smooth=false},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.cBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="b1f813", smooth=false},
		},
		["Rivals RuleBook RC"] = {
		{position={0, 1, 50}, rotation={0, 180, 0}, guid="79262f", smooth=false},
		},
		["Rivals RuleBook MV"] = {
		{position={30, 1, 50}, rotation={0, 180, 0}, guid="5641ed", smooth=false},
		},
		["2T - LotR Custom"] = {
		{position={zTable.zOther1.getPosition{}.x, 1.5, zTable.zOther1.getPosition{}.z}, rotation={0, 180, 180}, guid="83c686", smooth=false,}, -- Wall Deck
		{position={zTable.zOther2.getPosition{}.x, 1.5, zTable.zOther2.getPosition{}.z}, rotation={0, 180, 180}, guid="dae692", smooth=false,}, -- Breached
		},
		["RotK - LotR Custom"] = {
		{position={0, 0.96, 31.5}, rotation={0, 180, 0}, guid="873ff5", smooth=false, lock="yes",}, -- Board
		{position={-4.1, 2, 28.55}, rotation={0, 180, 0}, guid="f76f87", smooth=false,}, --Ring
		},
		["UJ - LotR Custom"] = {
		{position={12.48, 1.5, -5.5}, rotation={0, 180, 0}, guid="e1a375", smooth=false,}, --Ring
		{position={zTable.zEventLineUp1.getPosition{}.x, 1.5, zTable.zEventLineUp1.getPosition{}.z}, rotation={0, 180, 0}, guid="b75924", smooth=false,},
		{position={zTable.zEventLineUp2.getPosition{}.x, 1.5, zTable.zEventLineUp2.getPosition{}.z}, rotation={0, 180, 0}, guid="4deecf", smooth=false,},
		},
		["UJ - Custom Game - Ring"] = {
		{position={12.48, 2.5, -5.5}, rotation={0, 180, 0}, guid="e1a375", smooth=false,}, --Ring
		},
		["DoS - LotR Custom"] = {
		{position={zTable.zEventLineUp4.getPosition{}.x, 1.5, zTable.zEventLineUp4.getPosition{}.z}, rotation={0, 180, 0}, guid="ef8b1e", smooth=false,},
		},
		["LotR Custom Rulebook FotR"] = {
		{position={-60, 1.5, -50}, rotation={0, 180, 0}, guid="941502", smooth=false, lock="yes"},
		},
		["LotR Custom Rulebook 2T"] = {
		{position={-30, 1.5, -50}, rotation={0, 180, 0}, guid="800cda", smooth=false, lock="yes"},
		},
		["LotR Custom Rulebook RotK"] = {
		{position={0, 1.5, -50}, rotation={0, 180, 0}, guid="0251a6", smooth=false, lock="yes"},
		},
		["LotR Custom Rulebook UJ"] = {
		{position={30, 1.5, -50}, rotation={0, 180, 0}, guid="50da73", smooth=false, lock="yes"},
		},
		["LotR Custom Rulebook DoS"] = {
		{position={60, 1.5, -50}, rotation={0, 180, 0}, guid="78cc9e", smooth=false, lock="yes"},
		},
		["Cartoon Custom Rulebook AA"] = {
		{position={30, 1.5, 50}, rotation={0, 180, 0}, guid="dea0f7", smooth=false, lock="yes"},
		},
		["Cartoon Custom Rulebook TTG"] = {
		{position={0, 1.5, 50}, rotation={0, 180, 0}, guid="02422c", smooth=false, lock="yes"},
		},
		["Cartoon Events CN"] = {
		{position={zTable.zMainDeck.getPosition{}.x, menuToggleExtras.mdBagID_y+2, zTable.zMainDeck.getPosition{}.z}, rotation={0, 180, 180}, guid="6405ed", smooth=false,},
		},
		["Cartoon Events AA"] = {
		{position={zTable.zMainDeck.getPosition{}.x, menuToggleExtras.mdBagID_y+4, zTable.zMainDeck.getPosition{}.z}, rotation={0, 180, 180}, guid="35ce94", smooth=false,},
		},
		["Cartoon Events TTG"] = {
		{position={zTable.zMainDeck.getPosition{}.x, menuToggleExtras.mdBagID_y+6, zTable.zMainDeck.getPosition{}.z}, rotation={0, 180, 180}, guid="39005e", smooth=false,},
		},
		["RickMorty Custom Not Council RM2"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="9ffa85", smooth=false},
		{position={2.5, menuToggleExtras.cBagID_y, -18.5}, rotation={0, 180, 0}, guid="9b389f", smooth=false},
		},
		["RickMorty Custom Council RM2"] = {
		{position={zTable.zMainDeck.getPosition().x, 0.75+menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="218978", smooth=false,},
		},
		["RickMorty Custom Rulebook RM1"] = {
		{position={30, 1.5, 50}, rotation={0, 180, 0}, guid="0d915d", smooth=false, lock="yes"},
		},
		["RickMorty Custom Rulebook RM2"] = {
		{position={0, 1.5, 50}, rotation={0, 180, 0}, guid="a3bf69", smooth=false, lock="yes"},
		},
		["RickMorty Custom Locations RM1"] = {
		{position={zTable.zOther1.getPosition{}.x, 1.5, zTable.zOther1.getPosition{}.z}, rotation={0, 180, 180}, guid="c03219", smooth=false,},
		{position={zTable.zOther1.getPosition{}.x, 4, zTable.zOther1.getPosition{}.z}, rotation={0, 180, 0}, guid="60400f", smooth=false,},
		},
		["RickMorty Custom Locations RM2"] = {
		{position={zTable.zOther1.getPosition{}.x, 2.5, zTable.zOther1.getPosition{}.z}, rotation={0, 180, 180}, guid="b2547b", smooth=false,},
		{position={zTable.zOther2.getPosition{}.x, 1.5, zTable.zOther2.getPosition{}.z}, rotation={0, 180, 180}, guid="f3fe1d", smooth=false,},
		},
		["RickMorty Custom Access Tokens RM2"] = {
		{position={8.5, 1, 4.75}, rotation={0, 180, 0}, guid="f82d51", smooth=false, lock="yes",},
		},
		["RickMorty Custom Game Locations RM1"] = {
		{position={zTable.zMainDeck.getPosition{}.x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition{}.z}, rotation={0, 180, 180}, guid="c03219", smooth=false,},
		},
		["RickMorty Custom Game Locations RM2"] = {
		{position={zTable.zMainDeck.getPosition{}.x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition{}.z}, rotation={0, 180, 180}, guid="b2547b", smooth=false,},
		},
		["Naruto Custom Game Hand Signs"] = {
		{position={1.59, 1.5, 9.5}, rotation={0, 180, 0}, guid="6d9beb", smooth=false,},
		},
		["RM2 Custom Game Access Tokens"] = {
		{position={-1.86, 1, 9.5}, rotation={0, 180, 0}, guid="f82d51", smooth=false, lock="yes",},
		},
		["C1 Custom CrisisStack"] = {
		{position={zTable.zCrisisStack.getPosition{}.x, 1.5, zTable.zCrisisStack.getPosition{}.z}, rotation={0, 180, 180}, guid="5f205e", smooth=false,},},
		["C2 Custom CrisisStack"] = {
		{position={zTable.zCrisisStack.getPosition{}.x, 3, zTable.zCrisisStack.getPosition{}.z}, rotation={0, 180, 180}, guid="cebc2c", smooth=false,},},
		["C3 Custom CrisisStack"] = {
		{position={zTable.zCrisisStack.getPosition{}.x, 4.5, zTable.zCrisisStack.getPosition{}.z}, rotation={0, 180, 180}, guid="bd030d", smooth=false,},},
		["C4 Custom CrisisStack"] = {
		{position={12.48, 1.5, 10.2}, rotation={0, 180, 180}, guid="01e804", smooth=false,},},
		["ESW Characters EA1"] = {
		{position={-2, 2, -12}, rotation={0, 90, 0}, guid="0a9b8a", smooth=false},
		{position={6, 2, -12}, rotation={0, 180, 0}, guid="f54337", smooth=false},},
		["ESW Characters EGB"] = {
		{position={-2, 1.5, -12}, rotation={0, 90, 0}, guid="62c0bf", smooth=false},
		{position={6, 1.5, -12}, rotation={0, 180, 0}, guid="67b54b", smooth=false},},
		["ESW Characters EA2"] = {
		{position={-2, 2.5, -12}, rotation={0, 90, 0}, guid="546da9", smooth=false},
		{position={6, 2.5, -12}, rotation={0, 180, 0}, guid="817679", smooth=false},
		{position={10, 2.5, -12}, rotation={0, 180, 0}, guid="5e7dd4", smooth=false},},
		["ESW Characters Only EA1"] = {
		{position={-2, 2, -12}, rotation={0, 90, 0}, guid="0a9b8a", smooth=false},},
		["ESW Characters Only EA2"] = {
		{position={-2, 2.5, -12}, rotation={0, 90, 0}, guid="546da9", smooth=false},},
		["ESW Gang Bangers EGB"] = {
		{position={19.72, 1.5, -3.36}, rotation={0, 180, 0}, guid="d9a9fc", smooth=false},
		{position={24.18, 1.5, -3.36}, rotation={0, 180, 0}, guid="265ca2", smooth=false},
		{position={28.63, 1.5, -3.36}, rotation={0, 180, 0}, guid="6bd48e", smooth=false},
		{position={33.10, 1.5, -3.36}, rotation={0, 180, 0}, guid="9cb479", smooth=false},
		{position={37.53, 1.5, -5.29}, rotation={0, 180, 0}, guid="54f88d", smooth=false},
		{position={41.98, 1.5, -5.29}, rotation={0, 180, 0}, guid="323088", smooth=false},
		{position={19.72, 1.5, -7.90}, rotation={0, 180, 0}, guid="1c2d37", smooth=false},
		{position={24.18, 1.5, -7.90}, rotation={0, 180, 0}, guid="84895b", smooth=false},
		{position={28.63, 1.5, -7.90}, rotation={0, 180, 0}, guid="0a3b66", smooth=false},
		{position={33.10, 1.5, -7.90}, rotation={0, 180, 0}, guid="4705d6", smooth=false},},
		["ESW Health Trackers"] = {
		{position={-6, 1.5, -16}, rotation={0, 180, 0}, guid="37819e", color="White", smooth=false,},
		{position={-3.75, 1.5, -16}, rotation={0, 180, 0}, guid="2d48dc", color="Red", smooth=false,},
		{position={-1.25, 1.5, -16}, rotation={0, 180, 0}, guid="450233", color="Yellow", smooth=false,},
		{position={1, 1.5, -16}, rotation={0, 180, 0}, guid="49585f", color="Green", smooth=false,},
		{position={-5, 1.5, -16}, rotation={0, 180, 0}, guid="4a8cf9", color="Brown", smooth=false,},
		{position={-2.75, 1.5, -16}, rotation={0, 180, 0}, guid="e55339", color="Orange", smooth=false,},
		{position={-0.25, 1.5, -16}, rotation={0, 180, 0}, guid="9fa526", color="Purple", smooth=false,},
		{position={2, 1.5, -16}, rotation={0, 180, 0}, guid="8bba27", color="Pink", smooth=false,},},
		["ESW Custom Health Trackers"] = {
		{position={46, 1.5, -16}, rotation={0, 180, 0}, guid="37819e", color="White", smooth=false,},
		{position={48.25, 1.5, -16}, rotation={0, 180, 0}, guid="2d48dc", color="Red", smooth=false,},
		{position={50.75, 1.5, -16}, rotation={0, 180, 0}, guid="450233", color="Yellow", smooth=false,},
		{position={53, 1.5, -16}, rotation={0, 180, 0}, guid="49585f", color="Green", smooth=false,},
		{position={47, 1.5, -16}, rotation={0, 180, 0}, guid="4a8cf9", color="Brown", smooth=false,},
		{position={49.25, 1.5, -16}, rotation={0, 180, 0}, guid="e55339", color="Orange", smooth=false,},
		{position={51.75, 1.5, -16}, rotation={0, 180, 0}, guid="9fa526", color="Purple", smooth=false,},
		{position={54, 1.5, -16}, rotation={0, 180, 0}, guid="8bba27", color="Pink", smooth=false,},},
		["ESW - Maindeck No Mayhem - EA1"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="04076d", smooth=false},
		},
		["ESW - Maindeck No Mayhem - EA2"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="d35922", smooth=false},
		},
		["ESW - Legends No Mayhem - EA2"] = {
		{position={zTable.zEventDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zEventDeck.getPosition().z}, rotation={0, 180, 180}, guid="e525b0", smooth=false},
		},
		["ESW Mega Mayhem EA2"] = {
		{position={zTable.zEventDeck.getPosition().x, menuToggleExtras.mdBagID_y, zTable.zEventDeck.getPosition().z}, rotation={0, 180, 180}, guid="a87c59", smooth=false},
		},
		["ESW Legend Stack EGB"] ={ --EA1 static
		{position={zTable.zBossStack.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBossStack.getPosition().z}, rotation={0, 180, 180}, guid="57795b", smooth=false},
		{position={zTable.zBossStack.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBossStack.getPosition().z}, rotation={0, 180, 180}, guid="0ee4fb", smooth=false},
		{position={zTable.zBossStack.getPosition().x, menuToggleExtras.bBagID_y, zTable.zBossStack.getPosition().z}, rotation={0, 180, 180}, guid="7a0bda", smooth=false},
		},
		["ESW Ability Tokens All"] = {
		{position={-9, 2.5, -12}, rotation={0, 180, 0}, guid="fc8c46", smooth=false},
		{position={-3.45, 1.5, -33.95}, rotation={0, 180, 0}, guid="9c1412", smooth=false},},
		["ESW Ability Tokens EA1"] = {
		{position={-9, 2.5, -12}, rotation={0, 180, 0}, guid="db31bf", smooth=false},},
		["ESW Ability Tokens EA2"] = {
		{position={-9, 2.5, -12}, rotation={0, 180, 0}, guid="9569fe", smooth=false},
		{position={-3.45, 1.5, -33.95}, rotation={0, 180, 0}, guid="a5968c", smooth=false},},
		["ESW Dead Wizard Tokens Empty"] = {
		{position={12.48, 0.8, 4.63}, rotation={0, 180, 0}, guid="a390af", smooth=false, lock="yes"},},
		["ESW Dead Wizard Tokens All"] = {
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="dd98a2", smooth=false, lock="yes"},},
		["ESW Dead Wizard Tokens EA1+EGB"] = {
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="93b726", smooth=false, lock="yes"},},
		["ESW Dead Wizard Tokens EA1+EA2"] = {
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="39cb36", smooth=false, lock="yes"},},
		["ESW Dead Wizard Tokens EA2+EGB"] = {
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="55e418", smooth=false, lock="yes"},},
		["ESW Dead Wizard Tokens EA1"] = {
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="eca763", smooth=false, lock="yes"},},
		["ESW Dead Wizard Tokens EGB"] = {
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="eeeddb", smooth=false, lock="yes"},},
		["ESW Dead Wizard Tokens EA2"] = {
		{position={10.15, 0.8, -27.5}, rotation={0, 180, 0}, guid="c13ca5", smooth=false, lock="yes"},},
		["ESW Trophy Standee EA1"] = {
		{position={-52, 2.5, 9}, rotation={0, 0, 0}, guid="2179a8", smooth=false,},},
		["ESW Trophy Standee EGB"] = {
		{position={-52, 2.5, 6}, rotation={0, 0, 0}, guid="ae756e", smooth=false,},},
		["ESW Trophy Standee EA2"] = {
		{position={-52, 2.5, 3}, rotation={0, 0, 0}, guid="b8e194", smooth=false,},},
		["ESW Promos VP"] = {
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+3, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="307c05", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+4, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="a2d987", smooth=false,},
		{position={zTable.zMainDeck.getPosition().x, menuToggleExtras.mdBagID_y+5, zTable.zMainDeck.getPosition().z}, rotation={0, 180, 180}, guid="86f2be", smooth=false,},
		{position={-52, 2.5, -6.00}, rotation={0, 180, 0}, guid="7a50a1", smooth=false},
		},
		["ESW Custom Rulebook EA1"] = {
		{position={0, 1.5, -50}, rotation={0, 180, 0}, guid="b0225c", smooth=false, lock="yes"},
		},
		["ESW Custom Rulebook EA2"] = {
		{position={30, 1.5, -50}, rotation={0, 180, 0}, guid="b04e45", smooth=false, lock="yes"},
		},
		["ESW Custom Rulebook EGB"] = {
		{position={-30, 1.5, -50}, rotation={0, 180, 0}, guid="488780", smooth=false, lock="yes"},
		},
		["ESW Nacho Shack"] = {
		{position={0, 0.96, 31.5}, rotation={0, 180, 0}, guid="9e4709", smooth=false,},},
		["ESW Nacho Shack Inactive"] = {
		{position={0, 0.96, 31.5}, rotation={0, 180, 180}, guid="9e4709", smooth=false,},},
		["ESW Nacho Tokens"] = {
		{position={0, 0.96, 31.5}, rotation={0, 180, 0}, guid="9e4709", smooth=false,},
		{position={-8.76, 1.25, 4.75}, rotation={0, 180, 0}, guid="e48ce1", smooth=false,},
		{position={-5.31, 1.25, 4.75}, rotation={0, 180, 0}, guid="ee2728", smooth=false,},
		},
		["ESW Custom Nacho Tokens"] = {
		{position={-14.3, 0.9, 31.5}, rotation={0, 180, 0}, guid="9e4709", smooth=false, lock="yes"},
		{position={-46, 0.88, -9}, rotation={0, 180, 0}, guid="e48ce1", smooth=false, lock="yes"},
		{position={-46, 0.88, 12}, rotation={0, 180, 0}, guid="ee2728", smooth=false, lock="yes"},
		},
	}
end
function registerStarters(color)

	--Temp Table for starter GUIDs
	local starterGUIDs ={ 
	["DC"] = {"16ae15"},
	["HU"] = {"c1544e"},
	["FE"] = {"dbe1e7"},
	["TT"] = {"54cb4c"},
	["DNM"] = {"21e66f"},
	["INJ"] = {"b15a4a"},
	["R1"] = {"553af3"},
	["R2"] = {"092f88"},
	["R3"] = {"3284f1"},
	["RC"] = {"52bfa9"},
	["FotR"] = {"021407"},
	["2T"] = {"e2dc1f"},
	["RotK"] = {"e2d8f0"},
	["UJ"] = {"aa0931"},
	["CN"] = {"51f25f"},
	["AA"] = {"04144f"},
	["TTG"] = {"fda523"},
	["RM1"] = {"df2869"},
	["RM2"] = {"15a7eb"},
	["SF"] = {"c9bce7"},
	["NS"] = {"9c91ea"},
	["RB"] = {"ccbab6"},
	["EA1"] = {"65632d"},
	["EA2"] = {"ee182f"},
	["EGB EA1"] = {"a2e2eb"},
	["EGB EA2"] = {"84cca8"},
	["ESW All"] = {"027ef2"},
	["ESW EA1+EA2"] = {"fdafc8"},
	["ESW EA1+EGB"] = {"a2e2eb"},
	["ESW EA2+EGB"] = {"84cca8"},
	["ESW EGB"] = {"10a477"},
	["ESW None"] = {"57154e"},
	
	
	["DCDB"] = {"7fa130"},
	}
	
	--Temp Params for Set and location of Starters
	local starterParams = {
	["Temp"] = {
	{position ={playerZone[color].discardS.getPosition().x, 1.5, playerZone[color].discardS.getPosition().z}, 
	rotation = playerZone[color].playZoneRot,
	guid=starterGUIDs[starterID][1], 
	smooth=false,},}}

	--Sets with Different Starters, every other player gets something different
	if color == "Red" or color == "Yellow" or color == "Pink" or color == "Purple" then
		if bagID == "Basic R2" then
			starterParams["Temp"][1].guid = "875e5d"
		elseif bagID == "Basic R3" then
			starterParams["Temp"][1].guid = "4e9a82"
		elseif bagID == "Basic RC" then
			starterParams["Temp"][1].guid = "f5ce47"
		elseif bagID == "Basic INJ" then
			starterParams["Temp"][1].guid = "990519"
		end
	end

	bagSet.takeObject({callback="afterBagRemoved", callback_owner=Global, params=starterParams["Temp"]})
end
--Custom Game Stuff
function vmCO4random()
	vmCO4_1 = {["417fca"] = {{position={8.49, 1.5, 4.75}, rotation={0, 180, 0}, guid="2a2307", smooth=false,},}}
	vmCO4_2 = {["417fca"] = {{position={8.49, 1.5, 4.75}, rotation={0, 180, 0}, guid="5d0593", smooth=false,},}}
	vmCO4_3 = {["417fca"] = {{position={8.49, 1.5, 4.75}, rotation={0, 180, 0}, guid="82e686", smooth=false,},}}
	vmCO4_4 = {["417fca"] = {{position={8.49, 1.5, 4.75}, rotation={0, 180, 0}, guid="2d395a", smooth=false,},}}
	if vmCO4 == 1 then infBag.CO4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=vmCO4_1["417fca"]})
	elseif vmCO4 == 2 then infBag.CO4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=vmCO4_2["417fca"]})
	elseif vmCO4 == 3 then infBag.CO4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=vmCO4_3["417fca"]})
	elseif vmCO4 == 4 then infBag.CO4start.takeObject({callback="afterBagRemoved", callback_owner=Global, params=vmCO4_4["417fca"]})
	end
end

--************************DCDB Stuff************************--
---------****************** DCDeckbuilding.com Integration
function beginGame()
	--Load Sv Stack The Old Way
	createCubeBoss()
	function dcdbOfflineWait()
		wait(0.2)
		infBag.DCDBall.takeObject({callback="afterBagRemoved", callback_owner=Global, params=infiniteBagPlacementList["Custom Cube"], smooth = false})
		wait(1)
		shuffleMainDeck()
		shuffleCrisisStack()
		return 1
	end
	starterID="DCDB"
	grabStarters()
	quickSetup = 1
	startLuaCoroutine(Global, "dcdbOfflineWait")
	Wait.frames(bossCountSetup, 120)
	gameLoading = 0
end
gameEnded = 0
dcdbCubeGame = 0
gameLoading = 0
ttsGameState = 0
playerStartersToSet = 0
playersDataFetched = 0
everythingPulled = 0
playerStartersLoaded = 0
chosenStartersForPlayerColor = "Fail"
spectatorArray = {}
svFlipSoundDuration = 90
pullFromBagFrameWaitDuration = 5
addScriptingFunctionalityWaitDuration = 30
addLongScriptingWaitDuration = 240
cubeGameBeginningMusicWaitDuration = 240
discardingToDrawingDuration = 30
checkForPlayAreaDoneMoving = 15
z15CheckTopCardDuration = 60
z15RevealNextCardDuration = 10
shuffleDeckDuration = 120
revealCardDuration = 150
svSortWaitTime = 120
playerStarterInfo = {}
buttonsToChangeForCube = {}
chosenStartersForSeatNumber = 0
cardsInLineup = {}
numCardsOverCost = 0
numCardsOverType = 0
cardEnRoute = 0
cardDestination = nil
bossDiceCounter = nil
distantToCheckForPing = 3.5
refreshingTopCard = 0
doNotRemoveFromZone = {}
useMcAbility = "Use"
checkMcRequirement = "Check"
mcConfAqua15 = 4419
mcKyleRayner = 1500
mcCrisisRedTornado = 7162
mcHuRedTornado = 9402
mcSuperman9 = 7243
mcCrisisTheFlash = 7715
shapeShiftTtsId = 6366
elementWomanTtsId = 9249
z15 = 8093
playerColorWithAqua15 = 0
playerColorWithKyleRayner = 0
playerColorWithCrisisRedTornado = 0
playerColorWithHuRedTornado = 0
playerColorWithSuperman9 = 0
playerColorWithCrisisTheFlash = 0
playerColorWithZ15 = 0
z15IsActive = 0
z15cardRotation = 0
--z15McReference = nil
cardColorsInHandForRayner = {}
cardColorsInDiscardForHuRedTornado = {}
latestAction = ""
loadingCubeMusic = 0
entraceMusic = 1
svWithFaaFlips = 2
svDestroyed = 3
noDecksFoundSound = 4
--Event Logs
destroyCard = 1
flipSv = 2
---------****************** DCDeckbuilding.com Integration
function findCostDCDB()
    local costOfBoss = {} 
    local bossCount = 1
    costOfBoss[bossCount] = math.random(8,9); -- Starting boss 8 or 9

    for i = 2, 5, 1 do
        local bossCostIncrease = 3
        local bossCostIncreaseWeight = math.random(0,100)

        -- NEW: Increase chance of bigger jumps for later bosses
        if i == 4 and costOfBoss[2] <= 9 and costOfBoss[3] <= 10 then
            -- Moderate boost if first three bosses are 8,9,10-ish
            bossCostIncreaseWeight = bossCostIncreaseWeight - 15
        end
        if i == 5 and costOfBoss[4] == 11 then
            -- Moderate boost if 4th boss is 11
            bossCostIncreaseWeight = bossCostIncreaseWeight - 20
        end

        -- Determine cost increase based on weight
        if bossCostIncreaseWeight <= 97 then bossCostIncrease = 2 end
        if bossCostIncreaseWeight <= 90 then bossCostIncrease = 1 end
        if bossCostIncreaseWeight <= 5 then bossCostIncrease = 0 end

        costOfBoss[i] = costOfBoss[i - 1] + bossCostIncrease

        -- Prevent three bosses in a row being the same cost
        if i >= 3 then
            if costOfBoss[i] == costOfBoss[i - 2] then
                costOfBoss[i] = costOfBoss[i] + 1
            end
        end

        -- Prevent non-starting bosses being 8
        if i ~= 1 and costOfBoss[i] == 8 then
            costOfBoss[i] = 9
        end

        -- Cap costs
        if costOfBoss[i] > 14 then costOfBoss[i] = 14 end
        if i == 2 and costOfBoss[i] > 11 then costOfBoss[i] = 11 end
        if i == 3 and costOfBoss[i] > 13 then costOfBoss[i] = 13 end
        if i == 4 and costOfBoss[i] > 13 then costOfBoss[i] = 13 end

        -- Ensure last two cards are not duplicates
        if i == 5 then
            if costOfBoss[i] <= costOfBoss[i - 1] then
                costOfBoss[i] = costOfBoss[i - 1] + 1
                if costOfBoss[i] > 14 then costOfBoss[i] = 14 end
            end
        end
    end

    infBag.DCDBall.takeObject({
        callback = "afterBagRemoved",
        callback_owner = Global,
        params = infiniteBagPlacementList["Cube Boss Stack"],
        smooth = false
    })

    pullSvsFromContainer(costOfBoss)
end
function findCostNewDCDB()
    local costOfBoss = {}

    -- Build the pool of remaining costs for positions 2–5 (9–14)
    local costPool = {9, 10, 11, 12, 13, 14}

    -- Randomly pick 4 costs for positions 2–5 (no duplicates)
    local chosenCosts = {}
    for i = 1, 4 do
        local idx = math.random(1, #costPool)
        table.insert(chosenCosts, costPool[idx])
        table.remove(costPool, idx)
    end

    -- Sort ascending so the stack always increases from boss 2 onward
    table.sort(chosenCosts)

    -- Assign positions 2–5 ONLY
    for i = 2, 5 do
        costOfBoss[i] = chosenCosts[i - 1]
    end

    -- Spawn the boss stack container
    infBag.DCDBall.takeObject({
        callback = "afterBagRemoved",
        callback_owner = Global,
        params = infiniteBagPlacementList["Cube Boss Stack"],
        smooth = false
    })

    -- Pull bosses (starter handled randomly inside)
    pullSvsFromContainer(costOfBoss)

    for _, data in pairs(bossZoneTable) do
        getObjectFromGUID(data.guid).clearButtons()
    end
end
function pullSvsFromContainer(costOfBoss)
	function waitForDCDBStack()
		wait(1)
		local shuffleRFGZone = destroyPileZone.rfgZone.getObjects()
			for i, object in ipairs(shuffleRFGZone) do
				if object.type  == "Deck" then
					object.shuffle()
					object.shuffle()
				end
			end
		wait(2)
		findSvsInStack(costOfBoss)
		return 1
	end
	startLuaCoroutine(Global, "waitForDCDBStack")
end
function displayRemainingBossValue()
	zTable.zBossStack.clearButtons()
	local currentNumberofSV = 0
	local amountCheck = zTable.zBossStack.getObjects()
	for _, founddeck in ipairs(amountCheck) do
		if founddeck.type == "Deck" then
			currentNumberofSV = founddeck.getQuantity() + currentNumberofSV
		elseif founddeck.type == "Card" then
			currentNumberofSV = currentNumberofSV + 1
		end
	end
	if currentNumberofSV > 0 then
		zTable.zBossStack.createButton({rotation={0,180,0}, position={0,0.11,0.85}, font_size=220, label=currentNumberofSV, width=280, height=240,  click_function='none'})
	else
		zTable.zBossStack.clearButtons()
	end
end
function findSvsInStack(costOfBoss)
    local stackToSearch = destroyPileZone.rfgZone.getObjects()

    for _, object in ipairs(stackToSearch) do
        if object.type == "Deck" then
            local supervillainStack = object
            local cardsInDeck = supervillainStack.getObjects()
            local currentBossOrder = {}
            local params = {}

            -- 1) PICK RANDOM STARTER BOSS (POSITION 1)
            local starterCandidates = {}

            for _, card in ipairs(cardsInDeck) do
                local master = objScripts_Score
                    .getTable("masterCardTable")[card.nickname]

                if master and master.isStartBoss == true then
                    table.insert(starterCandidates, card)
                end
            end

            if #starterCandidates == 0 then
                printToAll("ERROR: No starter bosses found!", {1,0,0})
                return
            end

            local starterCard =
                starterCandidates[math.random(1, #starterCandidates)]

            currentBossOrder[1] = starterCard.nickname
            params.position = {
                zTable.zBossStack.getPosition().x,
                10,
                zTable.zBossStack.getPosition().z
            }
            params.guid = starterCard.guid
            supervillainStack.takeObject(params)

            -- 2) PICK BOSSES 2–5 BY COST (ASCENDING)
            for m = 2, 5 do
                for _, card in ipairs(cardsInDeck) do
                    local master = objScripts_Score
                        .getTable("masterCardTable")[card.nickname]

                    if master
                        and master.isStartBoss ~= true
                        and master.cost == costOfBoss[m]
                        and card.nickname ~= currentBossOrder[m - 1]
                    then
                        currentBossOrder[m] = card.nickname
                        params.position = {
                            zTable.zBossStack.getPosition().x,
                            10 - m,
                            zTable.zBossStack.getPosition().z
                        }
                        params.guid = card.guid
                        supervillainStack.takeObject(params)
                        break
                    end
                end
            end
        end
    end

    Wait.frames(shuffleMainDeck, 120)
    addRightClickFunctionalityToKickStack()
    addRightClickFunctionalityToWeaknessStack()
    printToAll("Game Ready")
    gameLoading = 0
end
function consoleLogTable(tableToConsoleLog)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(tableToConsoleLog) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(tableToConsoleLog) do
            if (cache[tableToConsoleLog] == nil) or (cur_index >= cache[tableToConsoleLog]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,tableToConsoleLog)
                    table.insert(stack,v)
                    cache[tableToConsoleLog] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            tableToConsoleLog = stack[#stack]
            stack[#stack] = nil
            depth = cache[tableToConsoleLog] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end
--WhiteList of objects to not destroy
function registerZones()
--Registers Player Scripting Zones
	playerZone = {
        ["Green"] = {deckZone=getObjectFromGUID("4482a6"), discardZoneAll=getObjectFromGUID('8b9a08'), scoreZone=getObjectFromGUID("021a21"),
					 discardO=getObjectFromGUID("391f51"), discardE=getObjectFromGUID("89f005"), discardSP=getObjectFromGUID("48ebbe"),
					 discardH=getObjectFromGUID("67bc24"), discardV=getObjectFromGUID("c58245"), discardS=getObjectFromGUID("11c23a"),
					 playZoneRot={0,0,0}, VPbag=getObjectFromGUID("9ada49")},
        ["Red"] = {deckZone=getObjectFromGUID("fb2e00"), discardZoneAll=getObjectFromGUID('d6f8e4'), scoreZone=getObjectFromGUID("0e74b6"),
				   discardO=getObjectFromGUID("c09c91"), discardE=getObjectFromGUID("458f71"), discardSP=getObjectFromGUID("8eb7d5"),
				   discardH=getObjectFromGUID("83492e"), discardV=getObjectFromGUID("def7de"), discardS=getObjectFromGUID("fe12d8"),
				   playZoneRot={0,180,0}, VPbag=getObjectFromGUID("c98019")},
		["Yellow"] = {deckZone=getObjectFromGUID("d6fb8b"), discardZoneAll=getObjectFromGUID('3bddb6'), scoreZone=getObjectFromGUID("73ee7d"),
					  discardO=getObjectFromGUID("d21567"), discardE=getObjectFromGUID("6d955b"), discardSP=getObjectFromGUID("42429a"),
					  discardH=getObjectFromGUID("41c123"), discardV=getObjectFromGUID("0a562c"), discardS=getObjectFromGUID("6e0766"),
					  playZoneRot={0,0,0}, VPbag=getObjectFromGUID("568734")},
        ["White"] = {deckZone=getObjectFromGUID("8afdb7"), discardZoneAll=getObjectFromGUID('e52008'), scoreZone=getObjectFromGUID("d3e083"),
					 discardO=getObjectFromGUID("b49fa2"), discardE=getObjectFromGUID("377193"), discardSP=getObjectFromGUID("46871e"),
					 discardH=getObjectFromGUID("a9a422"), discardV=getObjectFromGUID("9ba8d1"), discardS=getObjectFromGUID("61df81"),
					 playZoneRot={0,180,0}, VPbag=getObjectFromGUID("0b5d8b")},
        ["Brown"] = {deckZone=getObjectFromGUID("29682d"), discardZoneAll=getObjectFromGUID('77c200'), scoreZone=getObjectFromGUID("15b4bd"),
					 discardO=getObjectFromGUID("dd4636"), discardE=getObjectFromGUID("267b4f"), discardSP=getObjectFromGUID("c06ff2"),
					 discardH=getObjectFromGUID("75463e"), discardV=getObjectFromGUID("336254"), discardS=getObjectFromGUID("229407"),
					 playZoneRot={0,180,0}, VPbag=getObjectFromGUID("aed30a")},
        ["Purple"] = {deckZone=getObjectFromGUID("5acdd7"), discardZoneAll=getObjectFromGUID('a54dce'), scoreZone=getObjectFromGUID("edf1c9"),
					 discardO=getObjectFromGUID("5f6039"), discardE=getObjectFromGUID("93ff78"), discardSP=getObjectFromGUID("226efc"),
					 discardH=getObjectFromGUID("ea0e28"), discardV=getObjectFromGUID("2de380"), discardS=getObjectFromGUID("4dbcd5"),
					 playZoneRot={0,0,0}, VPbag=getObjectFromGUID("bf50a8")},
        ["Orange"] = {deckZone=getObjectFromGUID("37c192"), discardZoneAll=getObjectFromGUID('c7d573'), scoreZone=getObjectFromGUID("59e7a2"),
					 discardO=getObjectFromGUID("9cdb97"), discardE=getObjectFromGUID("a72bb5"), discardSP=getObjectFromGUID("bbbfac"),
					 discardH=getObjectFromGUID("a91396"), discardV=getObjectFromGUID("5e0da8"), discardS=getObjectFromGUID("d6a381"),
					 playZoneRot={0,0,0}, VPbag=getObjectFromGUID("db8bd1")},
        ["Pink"] = {deckZone=getObjectFromGUID("1c592d"), discardZoneAll=getObjectFromGUID('fde50d'), scoreZone=getObjectFromGUID("82bb4b"),
					 discardO=getObjectFromGUID("d8138c"), discardE=getObjectFromGUID("32081f"), discardSP=getObjectFromGUID("c9cad7"),
					 discardH=getObjectFromGUID("cfa083"), discardV=getObjectFromGUID("b00284"), discardS=getObjectFromGUID("61c7f5"),
					 playZoneRot={0,180,0}, VPbag=getObjectFromGUID("d3842a")},
				}
--Registers Destroy Pile Scripting Zones
	destroyPileZone = {hZone=getObjectFromGUID("26f9b9"), vZone=getObjectFromGUID("34c6e3"), spZone=getObjectFromGUID("3acc90"), eZone=getObjectFromGUID("065c55"),
					   lZone=getObjectFromGUID("38359a"), sZone=getObjectFromGUID("045308"), wZone=getObjectFromGUID("e43b04"), oZone=getObjectFromGUID("3c2524"),
					   rfgZone=getObjectFromGUID("b3a4e3"), udmZone=getObjectFromGUID("f2e131"), dZoneRot={0,180,0},}
--Registers Infinite bags for quick reference
	infBag = {
		--1)DC Base Sets
    	DCstart=getObjectFromGUID("f4ab9b"), HUstart=getObjectFromGUID("c6cd5d"), FEstart=getObjectFromGUID("40883f"), TTstart=getObjectFromGUID("d4812f"), DNMstart=getObjectFromGUID("35a87f"),
		INJstart=getObjectFromGUID("07b6ee"),
		--2)Crisis Sets
		C1start=getObjectFromGUID("88ded9"), C2start=getObjectFromGUID("902789"), C3start=getObjectFromGUID("7d7471"), C4start=getObjectFromGUID("559c2c"),
		--3)Rival Sets
		R1start=getObjectFromGUID("1bf66c"), R2start=getObjectFromGUID("9ace82"),  R3start=getObjectFromGUID("e8c67d"), RCstart=getObjectFromGUID("90f6cc"),
		--4)Crossover Sets
		CO1start=getObjectFromGUID("1ddfb7"), CO2start=getObjectFromGUID("fba148"), CO3start=getObjectFromGUID("83c010"), CO4start=getObjectFromGUID("417fca"), CO5start=getObjectFromGUID("bcbc0c"),
		CO6start=getObjectFromGUID("8066ac"), CO7start=getObjectFromGUID("563640"), CO8start=getObjectFromGUID("a196ad"), CO9start=getObjectFromGUID("e9db06"),
		--5)LotR
		FotRstart=getObjectFromGUID("57b413"), T2Tstart=getObjectFromGUID("f91e72"), RotKstart=getObjectFromGUID("f606f7"), UJstart=getObjectFromGUID("ef8609"), DoSstart=getObjectFromGUID("5a6a23"),
		--6)One Off Game Sets
		SFstart=getObjectFromGUID("8a3181"), NSstart=getObjectFromGUID("5c50d2"),
		--7)Cartoon Network Sets
		CNstart=getObjectFromGUID("1ff5b7"), AAstart=getObjectFromGUID("677013"), TTGstart=getObjectFromGUID("1c2149"), RM1start=getObjectFromGUID("45d9f6"), RM2start=getObjectFromGUID("1b76e7"),
		--8) Multiverse Sets
		MVstart=getObjectFromGUID("0e7373"), DCDBall=getObjectFromGUID("96f525"), Promoall=getObjectFromGUID("64990a"),
		--9) Epic Spell Wars Sets
		EA1start=getObjectFromGUID("ec7ee5"), EGBstart=getObjectFromGUID("c809da"), EA2start=getObjectFromGUID("42104e"),
		--10)Rebirth Sets
		RBstart=getObjectFromGUID("22b0bc"),
	}
--Simplified List of Zones
	zTable = {
	--Main Deck Line-Up Row
	zMainDeck=getObjectFromGUID('887020'),zLineUp1=getObjectFromGUID('0c27f0'), zLineUp2=getObjectFromGUID('f4deab'),
	zLineUp3=getObjectFromGUID('f232af'), zLineUp4=getObjectFromGUID('7e8a1c'), zLineUp5=getObjectFromGUID('bc5125'),
	--Event Deck Line-Up Row
	zEventDeck=getObjectFromGUID('1b3c6f'), zEventLineUp1=getObjectFromGUID('231173'), zEventLineUp2=getObjectFromGUID('c5c2e4'),
	zEventLineUp3=getObjectFromGUID('0b4bd6'), zEventLineUp4=getObjectFromGUID('b9d48c'), zEventLineUp5=getObjectFromGUID('548ead'),
	--Invisible Row for Boss Stacks & Setup
	zBoss1=getObjectFromGUID('7b5156'), zBoss2=getObjectFromGUID('f5551a'), zBoss3=getObjectFromGUID('0617c6'),
	zBoss4=getObjectFromGUID('1f46cc'), zBoss5=getObjectFromGUID('fe8cff'),
	--Top Line-up Row
	zOther1=getObjectFromGUID('6a35b3'), zOther2=getObjectFromGUID('c7b7f1'), zWeaknessStack=getObjectFromGUID('84d375'),
	zKickStack=getObjectFromGUID('9a84c9'), zBossStack=getObjectFromGUID('a21b9d'), zCrisisStack=getObjectFromGUID('9705a1'),
	zCharacter=getObjectFromGUID('58b549'),
	}
--Player Board Tables
	playerBoardZones = {
		["White"] = {zone=getObjectFromGUID("f258b9"),},
		["Red"] = {zone=getObjectFromGUID("31204b")},
		["Green"] = {zone=getObjectFromGUID("a2e05a")},
		["Yellow"] = {zone=getObjectFromGUID("a143cd")},
		["Brown"] = {zone=getObjectFromGUID("d78f45"),},
		["Purple"] = {zone=getObjectFromGUID("e6d013")},
		["Orange"] = {zone=getObjectFromGUID("db81b7")},
		["Pink"] = {zone=getObjectFromGUID("12a755")},
	}
	playerBoardStats = {
	["Health"] = {status=true},
	["Meter"] = {status=false},
	["Power"] = {status=true},
	["Move"] = {status=false},
	["Chakara"] = {status=false},
	["White"] = {
			{uiName="Health", uiActive=false, uiTextID="White_Health_Text", uiNumberID="White_Health_Number", uiValue =20, uiLimit =25},
			{uiName="Meter", uiActive=false, uiTextID="White_Meter_Text", uiNumberID="White_Meter_Number", uiValue =0, uiLimit =8},
			{uiName="Power", uiActive=false, uiTextID="White_Power_Text", uiNumberID="White_Power_Number", uiValue =0, uiLimit =99},
			{uiName="Move", uiActive=false, uiTextID="White_Move_Text", uiNumberID="White_Move_Number", uiValue =0, uiLimit =99},
			{uiName="Chakara", uiActive=false, uiTextID="White_Chakara_Text", uiNumberID="White_Chakara_Number", uiValue =0, uiLimit =99},
		},
	["Red"] = {
			{uiName="Health", uiActive=false, uiTextID="Red_Health_Text", uiNumberID="Red_Health_Number", uiValue =20, uiLimit =25},
			{uiName="Meter", uiActive=false, uiTextID="Red_Meter_Text", uiNumberID="Red_Meter_Number", uiValue =0, uiLimit =8},
			{uiName="Power", uiActive=false, uiTextID="Red_Power_Text", uiNumberID="Red_Power_Number", uiValue =0, uiLimit =99},
			{uiName="Move", uiActive=false, uiTextID="Red_Move_Text", uiNumberID="Red_Move_Number", uiValue =0, uiLimit =99},
			{uiName="Chakara", uiActive=false, uiTextID="Red_Chakara_Text", uiNumberID="Red_Chakara_Number", uiValue =0, uiLimit =99},
		},
	["Green"] = {
			{uiName="Health", uiActive=false, uiTextID="Green_Health_Text", uiNumberID="Green_Health_Number", uiValue =20, uiLimit =25},
			{uiName="Meter", uiActive=false, uiTextID="Green_Meter_Text", uiNumberID="Green_Meter_Number", uiValue =0, uiLimit =8},
			{uiName="Power", uiActive=false, uiTextID="Green_Power_Text", uiNumberID="Green_Power_Number", uiValue =0, uiLimit =99},
			{uiName="Move", uiActive=false, uiTextID="Green_Move_Text", uiNumberID="Green_Move_Number", uiValue =0, uiLimit =99},
			{uiName="Chakara", uiActive=false, uiTextID="Green_Chakara_Text", uiNumberID="Green_Chakara_Number", uiValue =0, uiLimit =99},
		},
	["Yellow"] = {
			{uiName="Health", uiActive=false, uiTextID="Yellow_Health_Text", uiNumberID="Yellow_Health_Number", uiValue =20, uiLimit =25},
			{uiName="Meter", uiActive=false, uiTextID="Yellow_Meter_Text", uiNumberID="Yellow_Meter_Number", uiValue =0, uiLimit =8},
			{uiName="Power", uiActive=false, uiTextID="Yellow_Power_Text", uiNumberID="Yellow_Power_Number", uiValue =0, uiLimit =99},
			{uiName="Move", uiActive=false, uiTextID="Yellow_Move_Text", uiNumberID="Yellow_Move_Number", uiValue =0, uiLimit =99},
			{uiName="Chakara", uiActive=false, uiTextID="Yellow_Chakara_Text", uiNumberID="Yellow_Chakara_Number", uiValue =0, uiLimit =99},
		},
	["Brown"] = {
			{uiName="Health", uiActive=false, uiTextID="Brown_Health_Text", uiNumberID="Brown_Health_Number", uiValue =20, uiLimit =25},
			{uiName="Meter", uiActive=false, uiTextID="Brown_Meter_Text", uiNumberID="Brown_Meter_Number", uiValue =0, uiLimit =8},
			{uiName="Power", uiActive=false, uiTextID="Brown_Power_Text", uiNumberID="Brown_Power_Number", uiValue =0, uiLimit =99},
			{uiName="Move", uiActive=false, uiTextID="Brown_Move_Text", uiNumberID="Brown_Move_Number", uiValue =0, uiLimit =99},
			{uiName="Chakara", uiActive=false, uiTextID="Brown_Chakara_Text", uiNumberID="Brown_Chakara_Number", uiValue =0, uiLimit =99},
		},
	["Purple"] = {
			{uiName="Health", uiActive=false, uiTextID="Purple_Health_Text", uiNumberID="Purple_Health_Number", uiValue =20, uiLimit =25},
			{uiName="Meter", uiActive=false, uiTextID="Purple_Meter_Text", uiNumberID="Purple_Meter_Number", uiValue =0, uiLimit =8},
			{uiName="Power", uiActive=false, uiTextID="Purple_Power_Text", uiNumberID="Purple_Power_Number", uiValue =0, uiLimit =99},
			{uiName="Move", uiActive=false, uiTextID="Purple_Move_Text", uiNumberID="Purple_Move_Number", uiValue =0, uiLimit =99},
			{uiName="Chakara", uiActive=false, uiTextID="Purple_Chakara_Text", uiNumberID="Purple_Chakara_Number", uiValue =0, uiLimit =99},
		},
	["Orange"] = {
			{uiName="Health", uiActive=false, uiTextID="Orange_Health_Text", uiNumberID="Orange_Health_Number", uiValue =20, uiLimit =25},
			{uiName="Meter", uiActive=false, uiTextID="Orange_Meter_Text", uiNumberID="Orange_Meter_Number", uiValue =0, uiLimit =8},
			{uiName="Power", uiActive=false, uiTextID="Orange_Power_Text", uiNumberID="Orange_Power_Number", uiValue =0, uiLimit =99},
			{uiName="Move", uiActive=false, uiTextID="Orange_Move_Text", uiNumberID="Orange_Move_Number", uiValue =0, uiLimit =99},
			{uiName="Chakara", uiActive=false, uiTextID="Orange_Chakara_Text", uiNumberID="Orange_Chakara_Number", uiValue =0, uiLimit =99},
		},
	["Pink"] = {
			{uiName="Health", uiActive=false, uiTextID="Pink_Health_Text", uiNumberID="Pink_Health_Number", uiValue =20, uiLimit =25},
			{uiName="Meter", uiActive=false, uiTextID="Pink_Meter_Text", uiNumberID="Pink_Meter_Number", uiValue =0, uiLimit =8},
			{uiName="Power", uiActive=false, uiTextID="Pink_Power_Text", uiNumberID="Pink_Power_Number", uiValue =0, uiLimit =99},
			{uiName="Move", uiActive=false, uiTextID="Pink_Move_Text", uiNumberID="Pink_Move_Number", uiValue =0, uiLimit =99},
			{uiName="Chakara", uiActive=false, uiTextID="Pink_Chakara_Text", uiNumberID="Pink_Chakara_Number", uiValue =0, uiLimit =99},
		},
	}
--Line-Up Zones
	lineupSlots = {
		{slotZone=getObjectFromGUID('0c27f0')}, --Line-Up Slot1
		{slotZone=getObjectFromGUID('f4deab')}, --Line-Up Slot2
		{slotZone=getObjectFromGUID('f232af')}, --Line-Up Slot3
		{slotZone=getObjectFromGUID('7e8a1c')}, --Line-Up Slot4
		{slotZone=getObjectFromGUID('bc5125')}, --Line-Up Slot5
	}
	eventSlots = {
		{slotZone=getObjectFromGUID('1b3c6f')}, -- Events
		{slotZone=getObjectFromGUID('231173')}, -- Event Line Up 1
		{slotZone=getObjectFromGUID('c5c2e4')}, -- Event Line Up 2
		{slotZone=getObjectFromGUID('0b4bd6')}, -- Event Line Up 3
		{slotZone=getObjectFromGUID('b9d48c')}, -- Event Line Up 4
		{slotZone=getObjectFromGUID('548ead')}, -- Event Line Up 5
	}
	legendsEA2Slots = {
    	{slotZone=getObjectFromGUID('231173')},
    	{slotZone=getObjectFromGUID('c5c2e4')},
    	{slotZone=getObjectFromGUID('0b4bd6')},
	}
    cardsInLineUpSlots = {
        {slotZone=getObjectFromGUID('0c27f0')}, -- Line-Up Slot1
        {slotZone=getObjectFromGUID('f4deab')}, -- Line-Up Slot2
        {slotZone=getObjectFromGUID('f232af')}, -- Line-Up Slot3
        {slotZone=getObjectFromGUID('7e8a1c')}, -- Line-Up Slot4
        {slotZone=getObjectFromGUID('bc5125')}, -- Line-Up Slot5
    	{slotZone=getObjectFromGUID('231173')}, -- Event Line Up 1
    	{slotZone=getObjectFromGUID('c5c2e4')}, -- Event Line Up 2
    	{slotZone=getObjectFromGUID('0b4bd6')}, -- Event Line Up 3
    	{slotZone=getObjectFromGUID('b9d48c')}, -- Event Line Up 4
    	{slotZone=getObjectFromGUID('548ead')}, -- Event Line Up 5
        {slotZone=getObjectFromGUID('1b3c6f')}, -- Events
    }
    greenPlayerMcSlots = {
        --Green
            {slotZone=getObjectFromGUID('a14222')}, -- Player Mc Slot1
            {slotZone=getObjectFromGUID('4cf578')}, -- Player Mc Slot2
            {slotZone=getObjectFromGUID('31c824')}, -- Player Mc Slot3
            {slotZone=getObjectFromGUID('557ba9')}, -- Player Mc Slot4
            {slotZone=getObjectFromGUID('3bc904')}, -- Player Mc Slot5
			{slotZone=getObjectFromGUID('a3ea17')}, -- Player Mc Slot6
    }
    yellowPlayerMcSlots = {
        --Yellow
            {slotZone=getObjectFromGUID('2f7c5b')}, -- Player Mc Slot1
            {slotZone=getObjectFromGUID('8c3b36')}, -- Player Mc Slot2
            {slotZone=getObjectFromGUID('cfdb57')}, -- Player Mc Slot3
            {slotZone=getObjectFromGUID('bdbbb2')}, -- Player Mc Slot4
            {slotZone=getObjectFromGUID('082aec')}, -- Player Mc Slot5
			{slotZone=getObjectFromGUID('1cdb8d')}, -- Player Mc Slot6
    }
    redPlayerMcSlots = {
        --Red
            {slotZone=getObjectFromGUID('d30f57')}, -- Player Mc Slot1
            {slotZone=getObjectFromGUID('f54cc6')}, -- Player Mc Slot2
            {slotZone=getObjectFromGUID('ac3332')}, -- Player Mc Slot3
            {slotZone=getObjectFromGUID('e5d470')}, -- Player Mc Slot4
            {slotZone=getObjectFromGUID('f8b075')}, -- Player Mc Slot5
			{slotZone=getObjectFromGUID('df570d')}, -- Player Mc Slot6
    }
    whitePlayerMcSlots = {
        --White
            {slotZone=getObjectFromGUID('7e71c7')}, -- Player Mc Slot1
            {slotZone=getObjectFromGUID('1ac1a2')}, -- Player Mc Slot2
            {slotZone=getObjectFromGUID('425589')}, -- Player Mc Slot3
            {slotZone=getObjectFromGUID('cc9210')}, -- Player Mc Slot4
            {slotZone=getObjectFromGUID('01bc80')}, -- Player Mc Slot5
			{slotZone=getObjectFromGUID('2a099f')}, -- Player Mc Slot6
    }
    playerHiddenInfoZones = {
        ["White"] = {   --White Hidden Zone
            {
                slotZone = getObjectFromGUID('4c8695'), --Hidden Zone Guid
                rotation = {0,180,0},   --Card Orientation
                xCord = 40,     --Hidden Zone Coordinate
                yCord = 3,      --Hidden Zone Coordinate
                zCord = -33},    --Hidden Zone Coordinate
            },
        ["Red"] = {    --Red Hidden Zone
            {
                slotZone = getObjectFromGUID('5a2284'), --Hidden Zone
                rotation = {0,0,180},   --Card Orientation
                xCord = -40,    --Hidden Zone Coordinate
                yCord = 3,      --Hidden Zone Coordinate
                zCord = -33},    --Hidden Zone Coordinate
            },
        ["Green"] = {   --Green Hidden Zone
            {
                slotZone = getObjectFromGUID('f754c6'), --Hidden Zone
                rotation = {0,180,180},   --Card Orientation
                xCord = -40,    --Hidden Zone Coordinate
                yCord = 3,      --Hidden Zone Coordinate
                zCord = 33},     --Hidden Zone Coordinate
            },
        ["Yellow"] = {   --Yellow Hidden Zone
            {
                slotZone = getObjectFromGUID('01e9d1'), --Hidden Zone
                rotation = {0,180,180},   --Card Orientation
                xCord = 40,   --Hidden Zone Coordinate
                yCord = 3,    --Hidden Zone Coordinate
                zCord = 33    --Hidden Zone Coordinate
            },
        }
    }
    playerDeckZones = {}
    playerDeckZones["White"] = {
        {slotZone=getObjectFromGUID('8afdb7')}, --White Deck
    }
    playerDeckZones["Red"] = {
        {slotZone=getObjectFromGUID('fb2e00')}, --Red Deck
    }
    playerDeckZones["Green"] = {
        {slotZone=getObjectFromGUID('4482a6')}, --Green Deck
    }
    playerDeckZones["Yellow"] = {
        {slotZone=getObjectFromGUID('d6fb8b')}, --Yellow Deck
    }
--8 Player Objects
    bagBrown=getObjectFromGUID("aed30a")
    bagPurple=getObjectFromGUID("bf50a8")
    bagOrange=getObjectFromGUID("db8bd1")
    bagPink=getObjectFromGUID("d3842a")
    scoreBrown=getObjectFromGUID("15b4bd")
    scorePurple=getObjectFromGUID("edf1c9")
    scoreOrange=getObjectFromGUID("59e7a2")
    scorePink=getObjectFromGUID("82bb4b")
    displayBrown=getObjectFromGUID("39b9b3")
    displayPurple=getObjectFromGUID("8c4005")
    displayOrange=getObjectFromGUID("dd973a")
    displayPink=getObjectFromGUID("ab805f")
    notecardBrown=getObjectFromGUID("a2a035")
    notecardPurple=getObjectFromGUID("b89a69")
    notecardOrange=getObjectFromGUID("ff81fb")
    notecardPink=getObjectFromGUID("d63896")
--Boss Stack Setup
	bossZoneTable = {
        [1] = {guid="7b5156", level=1}, --Boss Level 1
        [2] = {guid="f5551a", level=2}, --Boss Level 2
        [3] = {guid="0617c6", level=3}, --Boss Level 3
        [4] = {guid="1f46cc", level=4}, --Boss Level 4
        [5] = {guid="fe8cff", level=5}, --Boss Level 5
  }
end
function registerMenu()
	menuToggleSetOptions = { --God Menu for Expansion Setup
		{--DC
		mdValue=false, mdID="mdDC", cValue=false, cID="scDC", mvValue=false, mvID="mvDC",
		bagSet=infBag.DCstart, mdBagID="MainDeck DC", cBagID="Characters DC", bBagID="CM Boss DC", generalID="f4ab9b", 
		wBagID="Weakness DC", kBagID="Kick DC",
		mvRep="MV DC", mvCore="MV_MCs_DC", mvMainID="MV_Picked_DC", mvNotMainID="MV_NotPicked_DC",
		spawnDC=true, mvMain=true, mvPicked=false, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_DC", cg_mdID="cg_md_DC", cg_bID="cg_b_DC",
		imgRep="DC", printName="[0E18A6]DC Base Set[FFFFFF]", standardID="Basic DC",
		},
		{--HU
		mdValue=false, mdID="mdHU", cValue=false, cID="scHU", mvValue=false, mvID="mvHU",
		bagSet=infBag.HUstart, mdBagID="MainDeck HU", cBagID="Characters HU", bBagID="CM Boss HU", generalID="c6cd5d",
		wBagID="Weakness HU", kBagID="Kick HU",
		mvRep="MV HU", mvCore="MV_MCs_HU", mvMainID="MV_Picked_HU", mvNotMainID="MV_NotPicked_HU",
		spawnDC=true,  mvMain=true, mvPicked=false, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_HU", cg_mdID="cg_md_HU", cg_bID="cg_b_HU",
		imgRep="HU", printName="[FF3A3A]Heroes United[FFFFFF]", standardID="Basic HU",
		},
		{--FE
		mdValue=false, mdID="mdFE", cValue=false, cID="scFE", mvValue=false, mvID="mvFE",
		bagSet=infBag.FEstart, mdBagID="MainDeck FE", cBagID="Characters FE", bBagID="CM Boss FE", generalID="40883f",
		wBagID="Weakness FE", kBagID="Kick FE",
		mvRep="MV FE", mvCore="MV_MCs_FE", mvMainID="MV_Picked_FE", mvNotMainID="MV_NotPicked_FE",
		spawnDC=true,  mvMain=true, mvPicked=false, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_FE", cg_mdID="cg_md_FE", cg_bID="cg_b_FE",
		imgRep="FE", printName="[9600B3]Forever Evil[FFFFFF]", standardID="Basic FE",
		},
		{--TT
		mdValue=false, mdID="mdTT", cValue=false, cID="scTT", mvValue=false, mvID="mvTT",
		bagSet=infBag.TTstart, mdBagID="MainDeck TT", cBagID="Characters TT", bBagID="CM Boss TT", generalID="d4812f",
		wBagID="Weakness TT", kBagID="Kick TT",
		mvRep="MV TT", mvCore="MV_MCs_TT", mvMainID="MV_Picked_TT", mvNotMainID="MV_NotPicked_TT",
		spawnDC=true,  mvMain=true, mvPicked=false, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_TT", cg_mdID="cg_md_TT", cg_bID="cg_b_TT",
		imgRep="TT", printName="[F2621B]Teen Titans[FFFFFF]", standardID="Basic TT",
		},
		{--DNM
		mdValue=false, mdID="mdDNM", cValue=false, cID="scDNM", mvValue=false, mvID="mvDNM",
		bagSet=infBag.DNMstart, mdBagID="MainDeck DNM", cBagID="Characters DNM", bBagID="CM Boss DNM", generalID="35a87f",
		wBagID="Weakness DNM", kBagID="Breakthrough DNM",
		mvRep="MV DNM", mvCore="MV_MCs_DNM", mvMainID="MV_Picked_DNM", mvNotMainID="MV_NotPicked_DNM",
		spawnDC=true,  mvMain=true, mvPicked=false, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_DNM", cg_mdID="cg_md_DNM", cg_bID="cg_b_DNM",
		imgRep="DNM", printName="[888888]Dark Nights Metal[FFFFFF]", standardID="Basic DNM",
		},
		{--INJ
		mdValue=false, mdID="mdINJ", cValue=false, cID="scINJ", mvValue=false, mvID="mvINJ",
		bagSet=infBag.INJstart, mdBagID="MainDeck INJ", cBagID="Characters INJ", bBagID="CM Boss INJ", generalID="07b6ee",
		wBagID="Weakness INJ", kBagID="Flying Kick INJ",
		mvRep="MV INJ", mvCore="MV_MCs_INJ", mvMainID="MV_Picked_INJ", mvNotMainID="MV_NotPicked_INJ",
		spawnDC=true, mvMain=true, mvPicked=false, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_INJ", cg_mdID="cg_md_INJ", cg_bID="cg_b_INJ",
		imgRep="INJ", printName="[607282]Injustice - Gods Among US[FFFFFF]", standardID="Basic INJ",
		},
		{--C1
		mdValue=false, mdID="mdC1", cValue=false, cID="scC1", mvValue=false, mvID="mvC1",
		bagSet=infBag.C1start, mdBagID="MainDeck C1", cBagID="Characters C1",  bBagID="CM Boss C1",
		mvRep="MV C1", mvCore="MV_Core_C1",
		spawnDC=true, isDCE=true, spawnCrisis=true, cBagID_Crisis="Characters C1 Crisis",
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_C1", cg_mdID="cg_md_C1", cg_bID="cg_b_C1",
		imgRep="C1", printName="[0068B3]Crisis 1[FFFFFF]", standardID="Basic C1",
		},
		{--C2
		mdValue=false, mdID="mdC2", cValue=false, cID="scC2", mvValue=false, mvID="mvC2",
		bagSet=infBag.C2start, mdBagID="MainDeck C2", cBagID="Characters C2", bBagID="CM Boss C2",
		mvRep="MV C2", mvCore="MV_Core_C2",
		spawnDC=true, isDCE=true, spawnCrisis=true, cBagID_Crisis="Characters C2 Crisis",
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_C2", cg_mdID="cg_md_C2", cg_bID="cg_b_C2",
		imgRep="C2", printName="[1B1B16]Crisis 2[FFFFFF]", standardID="Basic C2",
		},
		{--C3
		mdValue=false, mdID="mdC3", cValue=false, cID="scC3", mvValue=false, mvID="mvC3",
		bagSet=infBag.C3start, mdBagID="MainDeck C3", cBagID="Characters C3", bBagID="CM Boss C3",
		mvRep="MV C3", mvCore="MV_Core_C3",
		spawnDC=true, isDCE=true, spawnCrisis=true, cBagID_Crisis="Characters C3 Crisis",
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_C3", cg_mdID="cg_md_C3", cg_bID="cg_b_C3",
		imgRep="C3", printName="[451AE2]Crisis 3[FFFFFF]", standardID="Basic C3",
		},
		{--C4
		mdValue=false, mdID="mdC4", cValue=false, cID="scC4", mvValue=false, mvID="mvC4",
		bagSet=infBag.C4start, mdBagID="MainDeck C4", cBagID="Characters C4", bBagID="CM Boss C4",
		mvRep="MV C4", mvCore="MV_Core_C4",
		spawnDC=true, isDCE=true, spawnCrisis=true, cBagID_Crisis="Characters C4 Crisis",
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_C4", cg_mdID="cg_md_C4", cg_bID="cg_b_C4",
		imgRep="C4", printName="[B44B14]Crisis 4[FFFFFF]", standardID="Basic C4",
		},
		{--CO1
		mdValue=false, mdID="mdCO1", cValue=false, cID="scCO1", mvValue=false, mvID="mvCO1",
		bagSet=infBag.CO1start, mdBagID="MainDeck CO1", cBagID="Characters CO1", bBagID="CM Boss CO1",
		mvRep="MV CO1", mvCore="MV_Core_CO1",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CO1", cg_mdID="cg_md_CO1", cg_bID="cg_b_CO1",
		imgRep="CO1", printName="[5ABCFE]Crossover 1  - Justice Society of America[FFFFFF]", standardID="Basic CO1",
		},
		{--CO2
		mdValue=false, mdID="mdCO2", cValue=false, cID="scCO2", mvValue=false, mvID="mvCO2",
		bagSet=infBag.CO2start, mdBagID="MainDeck CO2", cBagID="Characters CO2", bBagID="CM Boss CO2",
		mvRep="MV CO2", mvCore="MV_Core_CO2",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CO2", cg_mdID="cg_md_CO2", cg_bID="cg_b_CO2",
		imgRep="CO2", printName="[0D5C10]Crossover 2 - Arrow - The Television Series[FFFFFF]", standardID="Basic CO2",
		},
		{--CO3
		mdValue=false, mdID="mdCO3", cValue=false, cID="scCO3", mvValue=false, mvID="mvCO3",
		bagSet=infBag.CO3start, mdBagID="MainDeck CO3", cBagID="Characters CO3", bBagID="CM Boss CO3",
		mvRep="MV CO3", mvCore="MV_Core_CO3",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CO3", cg_mdID="cg_md_CO3", cg_bID="cg_b_CO3",
		imgRep="CO3", printName="[B62323]Crossover 3 - Legion of Super-Heroes[FFFFFF]", standardID="Basic CO3",
		},
		{--CO4
		mdValue=false, mdID="mdCO4", cValue=false, cID="scCO4", mvValue=false, mvID="mvCO4",
		bagSet=infBag.CO4start, mdBagID="MainDeck CO4", cBagID="Characters CO4",
		mvRep="MV CO4", mvCore="MV_Core_CO4",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cg_cID="cg_c_CO4", cg_mdID="cg_md_CO4",
		imgRep="CO4", printName="[FFE400]Crossover 4 - Watchmen[FFFFFF]", standardID="Basic CO4",
		},
		{--CO5
		mdValue=false, mdID="mdCO5", cValue=false, cID="scCO5", mvValue=false, mvID="mvCO5",
		bagSet=infBag.CO5start, mdBagID="MainDeck CO5", cBagID="Characters CO5", bBagID="CM Boss CO5",
		mvRep="MV CO5", mvCore="MV_Core_CO5",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CO5", cg_mdID="cg_md_CO5", cg_bID="cg_b_CO5",
		imgRep="CO5", printName="[00FFF4]Crossover 5 - Rouges[FFFFFF]", standardID="Basic CO5",
		},
		{--CO6
		mdValue=false, mdID="mdCO6", cValue=false, cID="scCO6", mvValue=false, mvID="mvCO6",
		bagSet=infBag.CO6start, mdBagID="MainDeck CO6", cBagID="Characters CO6", bBagID="CM Boss CO6",
		mvRep="MV CO6", mvCore="MV_Core_CO6",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CO6", cg_mdID="cg_md_CO6", cg_bID="cg_b_CO6",
		imgRep="CO6", printName="[FF8FFA]Crossover 6 - Birds of Prey[FFFFFF]", standardID="Basic CO6",
		},
		{--CO7
		mdValue=false, mdID="mdCO7", cValue=false, cID="scCO7", mvValue=false, mvID="mvCO7",
		bagSet=infBag.CO7start, mdBagID="MainDeck CO7", cBagID="Characters CO7", bBagID="CM Boss CO7",
		mvRep="MV CO7", mvCore="MV_Core_CO7",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CO7", cg_mdID="cg_md_CO7", cg_bID="cg_b_CO7",
		imgRep="CO7", printName="[9861FF]Crossover 7 - New Gods[FFFFFF]", standardID="Basic CO7",
		},
		{--CO8
		mdValue=false, mdID="mdCO8", cValue=false, cID="scCO8", mvValue=false, mvID="mvCO8",
		bagSet=infBag.CO8start, mdBagID="MainDeck CO8", cBagID="Characters CO8", bBagID="CM Boss CO8",
		mvRep="MV CO8", mvCore="MV_Core_CO8",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CO8", cg_mdID="cg_md_CO8", cg_bID="cg_b_CO8",
		imgRep="CO8", printName="[18358C]Crossover 8 - Ninja Batman[FFFFFF]", standardID="Basic CO8",
		},
		{--CO9
		mdValue=false, mdID="mdCO9", cValue=false, cID="scCO9", mvValue=false, mvID="mvCO9",
		bagSet=infBag.CO9start, mdBagID="MainDeck CO9", cBagID="Characters CO9", bBagID="CM Boss CO9",
		mvRep="MV CO9", mvCore="MV_Core_CO9",
		spawnDC=true, isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CO9", cg_mdID="cg_md_CO9", cg_bID="cg_b_CO9",
		imgRep="CO9", printName="[646630]Crossover 9 - Bombshells[FFFFFF]", standardID="Basic CO9",
		},
		{--R1
		mvValue=false, mvID="mvR1",
		bagSet=infBag.R1start, mdBagID="MainDeck R1", cBagID="Characters R1", generalID="1bf66c",
		wBagID="Weakness R1[20]", kBagID="Kick R1[16]",
		mvRep="MV R1", mvCore="MV_Core_R1",
		rivalsKick=false, rivalsWeakness=false, rivalsStarters=false,
		wBagID10="Weakness R1[10]", kBagID8="Kick R1[8]",
		rivalsKick_id="rivalsKickR1", rivalsStarters_id="rivialsStarterR1", rivalsWeakness_id="rivalsWeaknessR1",
		spawnRivals=true,
		cgCharacter=false, cgMain=false, cg_cID="cg_c_R1", cg_mdID="cg_md_R1",
		imgRep="R1", printName="[2B2237]Rivals 1 - Batman vs The Joker[FFFFFF]", standardID="Basic R1",
		},
		{--R2
		mvValue=false, mvID="mvR2",
		bagSet=infBag.R2start, mdBagID="MainDeck R2", cBagID="Characters R2", generalID="9ace82",
		wBagID="Weakness R2[20]", kBagID="Kick R2[16]",
		mvRep="MV R2", mvCore="MV_Core_R2",
		rivalsKick=true, rivalsWeakness=false, rivalsStarters=false,
		wBagID10="Weakness R2[10]", kBagID8="Kick R2[8]",
		rivalsKick_id="rivalsKickR2", rivalsStarters_id="rivialsStarterR2", rivalsWeakness_id="rivalsWeaknessR2",
		spawnRivals=true,
		cgCharacter=false, cgMain=false, cg_cID="cg_c_R2", cg_mdID="cg_md_R2",
		imgRep="R2", printName="[039615]Rivals 2 - Green Lantern vs Sinestro[FFFFFF]", standardID="Basic R2",
		},
		{--R3
		mvValue=false, mvID="mvR3",
		bagSet=infBag.R3start, mdBagID="MainDeck R3", cBagID="Characters R3", generalID="e8c67d",
		wBagID="Weakness R3[20]", kBagID="Kick R3[16]",
		mvRep="MV R3", mvCore="MV_Core_R3",
		rivalsKick=false, rivalsWeakness=true, rivalsStarters=false,
		wBagID10="Weakness R3[10]", kBagID8="Kick R3[8]",
		rivalsKick_id="rivalsKickR3", rivalsStarters_id="rivialsStarterR3", rivalsWeakness_id="rivalsWeaknessR3",
		spawnRivals=true,
		cgCharacter=false, cgMain=false, cg_cID="cg_c_R3", cg_mdID="cg_md_R3",
		imgRep="R3", printName="[FC0505]Rivals 3 - Flash vs Reverse-Flash[FFFFFF]", standardID="Basic R3",
		},
		{--RC
		mvValue=false, mvID="mvRC",
		bagSet=infBag.RCstart, mdBagID="MainDeck RC", cBagID="Characters RC", generalID="90f6cc",
		wBagID="Weakness RC[20]", kBagID="Kick RC[16]",
		mvRep="MV RC", mvMainID="MV_Picked_RC", mvNotMainID="MV_NotPicked_RC",
		rivalsKick=false, rivalsWeakness=false, rivalsStarters=true,
		wBagID10="Weakness RC[10]", kBagID8="Kick RC[8]",
		rivalsKick_id="rivalsKickRC", rivalsStarters_id="rivialsStarterRC", rivalsWeakness_id="rivalsWeaknessRC",
		spawnRivals=true, mvMain=true, mvPicked=false,
		cgCharacter=false, cgMain=false, cg_cID="cg_c_RC", cg_mdID="cg_md_RC",
		imgRep="RC", printName="[0D23CC]Confrontations[FFFFFF]", standardID="Basic RC",
		},
		{--FotR
		bagSet=infBag.FotRstart, mdBagID="MainDeck FotR", cBagID="Characters FotR", generalID="57b413",
		bBagID="CM Boss FotR", bBagID_IM="CM Boss FotR IM", wBagID="Corruption FotR", kBagID="Valor FotR",
		valorLOTR=true, corruptionLOTR=true, startersLOTR=true, mainLOTR=true, cLOTR=true, bLOTR=true,
		mainLOTR_id="mainLOTR_FotR", cLOTR_id="cLOTR_FotR", bLOTR_id="bLOTR_FotR",
		valorLOTR_id="idValorLOTR_FotR", corruptionLOTR_id="idCorruptionLOTR_FotR", startersLOTR_id="idStarterLOTR_FotR",
		spawnLOTR=true, isLOTR=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_FotR", cg_mdID="cg_md_FotR", cg_bID="cg_b_FotR",
		cgIM=false, cg_imID="cg_im_FotR",
		imgRep="FotR", printName="[9DD8FF]Lord of the Rings - The Fellowship of the Ring[FFFFFF]",
		},
		{--2T
		bagSet=infBag.T2Tstart, mdBagID="MainDeck 2T", cBagID="Characters 2T", generalID="f91e72",
		bBagID="CM Boss 2T", bBagID_IM="CM Boss 2T IM", wBagID="Corruption 2T", kBagID="Valor 2T",
		valorLOTR=false, corruptionLOTR=false, startersLOTR=false, mainLOTR=true, cLOTR=true, bLOTR=true,
		mainLOTR_id="mainLOTR_2T", cLOTR_id="cLOTR_2T", bLOTR_id="bLOTR_2T",
		valorLOTR_id="idValorLOTR_2T", corruptionLOTR_id="idCorruptionLOTR_2T", startersLOTR_id="idStarterLOTR_2T",
		spawnLOTR=true, isLOTR=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_2T", cg_mdID="cg_md_2T", cg_bID="cg_b_2T",
		cgIM=false, cg_imID="cg_im_2T",
		imgRep="2T", printName="[D31C06]Lord of the Rings - The Two Towers[FFFFFF]",
		},
		{--RotK
		bagSet=infBag.RotKstart, mdBagID="MainDeck RotK", cBagID="Characters RotK", generalID="f606f7",
		bBagID="CM Boss RotK", bBagID_IM="CM Boss RotK IM", wBagID="Corruption RotK", kBagID="Valor RotK",
		valorLOTR=false, corruptionLOTR=false, startersLOTR=false, mainLOTR=true, cLOTR=true, bLOTR=true,
		mainLOTR_id="mainLOTR_RotK", cLOTR_id="cLOTR_RotK", bLOTR_id="bLOTR_RotK",
		valorLOTR_id="idValorLOTR_RotK", corruptionLOTR_id="idCorruptionLOTR_RotK", startersLOTR_id="idStarterLOTR_RotK",
		spawnLOTR=true, isLOTR=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_RotK", cg_mdID="cg_md_RotK", cg_bID="cg_b_RotK",
		cgIM=false, cg_imID="cg_im_RotK",
		imgRep="RotK", printName="[2F000A]Lord of the Rings - The Return of the King[FFFFFF]",
		},
		{--UJ
		bagSet=infBag.UJstart, mdBagID="MainDeck UJ", cBagID="Characters UJ", generalID="ef8609",
		bBagID="CM Boss UJ", bBagID_IM="CM Boss UJ IM", wBagID="Corruption UJ", kBagID="Valor UJ",
		valorLOTR=false, corruptionLOTR=false, startersLOTR=false, mainLOTR=true, cLOTR=true, bLOTR=true,
		mainLOTR_id="mainLOTR_UJ", cLOTR_id="cLOTR_UJ", bLOTR_id="bLOTR_UJ",
		valorLOTR_id="idValorLOTR_UJ", corruptionLOTR_id="idCorruptionLOTR_UJ", startersLOTR_id="idStarterLOTR_UJ",
		spawnLOTR=true, isLOTR=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_UJ", cg_mdID="cg_md_UJ", cg_bID="cg_b_UJ",
		cgIM=false, cg_imID="cg_im_UJ",
		imgRep="UJ", printName="[F4AE2C]The Hobbit - An Unexpected Journey Cards[FFFFFF]", standardID="Basic UJ",
		},
		{--DoS
		bagSet=infBag.DoSstart, mdBagID="MainDeck DoS", cBagID="Characters DoS", generalID="5a6a23",
		bBagID="CM Boss DoS", bBagID_IM="CM Boss DoS IM", wBagID="Corruption DoS",
		corruptionLOTR=true, mainLOTR=true, cLOTR=true, bLOTR=true,
		mainLOTR_id="mainLOTR_DoS", cLOTR_id="cLOTR_DoS", bLOTR_id="bLOTR_DoS",
		spawnLOTR=true, isLOTR=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_DoS", cg_mdID="cg_md_DoS", cg_bID="cg_b_DoS",
		cgIM=false, cg_imID="cg_im_DoS",
		imgRep="DoS", printName="[7641C1]The Hobbit - The Desolation of Smaug Cards[FFFFFF]",
		},
		{--CN
		bagSet=infBag.CNstart, mdBagID="MainDeck CN", cBagID="Characters CN", generalID="1ff5b7",
		bBagID="CM Nemesis CN", wBagID="Weakness CN", kBagID="Inside Joke CN",
		cartoonJoke=true, cartoonWeakness=true, cartoonStarters=true, cartoonMain=true, cartoonCharacter=true, cartoonNemesis=true,
		cartoonMain_id="cartoonMainCN", cartoonCharacter_id="cartoonCharacterCN", cartoonNemesis_id="cartoonNemesisCN",
		cartoonWeakness_id="cartoonWeaknessCN", cartoonStarters_id="cartoonStarterCN", wBagCartoonID="Weakness Cartoon CN",
		spawnCartoon=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_CN", cg_mdID="cg_md_CN", cg_bID="cg_b_CN",
		imgRep="CN", printName="[FF8222]Cartoon Network - Crossover Crisis[FFFFFF]",
		},
		{--AA
		bagSet=infBag.AAstart, mdBagID="MainDeck AA", cBagID="Characters AA", generalID="677013",
		bBagID="CM Nemesis AA", wBagID="Weakness AA", kBagID="Inside Joke AA",
		cartoonJoke=false, cartoonWeakness=true, cartoonStarters=false, cartoonMain=true, cartoonCharacter=true, cartoonNemesis=true,
		cartoonMain_id="cartoonMainAA", cartoonCharacter_id="cartoonCharacterAA", cartoonNemesis_id="cartoonNemesisAA",
		cartoonWeakness_id="cartoonWeaknessAA", cartoonStarters_id="cartoonStarterAA", wBagCartoonID="Weakness Cartoon AA",
		spawnCartoon=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_AA", cg_mdID="cg_md_AA", cg_bID="cg_b_AA",
		imgRep="AA", printName="[3D68B7]Cartoon Network - Animation Annihilation[FFFFFF]",
		},
		{--TTG
		mdValue= false, mdID="mdTTG", cValue=false, cID="scTTG", mvValue=false, mvID="mvTTG",
		bagSet=infBag.TTGstart, mdBagID="MainDeck TTG", cBagID="Characters TTG", generalID="1c2149",
		bBagID="CM Nemesis TTG", wBagID="Weakness TTG", kBagID="Titans Go! TTG",
		cartoonWeakness=true, cartoonStarters=false, cartoonMain=true, cartoonCharacter=true, cartoonNemesis=true,
		cartoonMain_id="cartoonMainTTG", cartoonCharacter_id="cartoonCharacterTTG", cartoonNemesis_id="cartoonNemesisTTG",
		cartoonWeakness_id="cartoonWeaknessTTG", cartoonStarters_id="cartoonStarterTTG", wBagCartoonID="Weakness Cartoon TTG",
		mvRep="MV TTG", mvCore="MV_Core_TTG",
		isDCE=true, spawnCartoon=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_TTG", cg_mdID="cg_md_TTG", cg_bID="cg_b_TTG",
		imgRep="TTG", printName="[AD1100]Teen Titans Go![FFFFFF]", standardID="Basic TTG",
		},
		{--RM1
		bagSet=infBag.RM1start, mdBagID="MainDeck RM1", cBagID="Characters RM1", generalID="45d9f6",
		bBagID="CM Nemesis RM1", wBagID="MortyWave RM1", kBagID="Portal Gun RM1",
		rmcMortyWaves=true, rmcStarters=true,
		spawnRickMorty=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_RM1", cg_mdID="cg_md_RM1", cg_bID="cg_b_RM1",
		cgLocationID="RickMorty Custom Game Locations RM1",
		imgRep="RM1", printName="[CEBB52]Rick and Morty - Close Rick-Counter of the Rick Kind[FFFFFF]",
		},
		{--RM2
		bagSet=infBag.RM2start, mdBagID="MainDeck RM2", cBagID="Characters RM2", generalID="1b76e7",
		bBagID="CM Nemesis RM2", wBagID="MortyWave RM2", kBagID="Portal Gun RM2",
		rmcMortyWaves=false, rmcStarters=false,
		spawnRickMorty=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_RM2", cg_mdID="cg_md_RM2", cg_bID="cg_b_RM2",
		cgLocationID="RickMorty Custom Game Locations RM2",
		imgRep="RM2", printName="[228EC7]Rick and Morty - The Rickshank Rickdemption[FFFFFF]",
		},
		{--SF
		bagSet=infBag.SFstart, mdBagID="MainDeck SF", cBagID="Characters SF", generalID="8a3181",
		bBagID="CM Location SF", wBagID="Weakness SF", kBagID="Kick SF",
		spawnOther=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_SF", cg_mdID="cg_md_SF", cg_bID="cg_b_SF",
		imgRep="SF", printName="[9A4C18]Street Fighter[FFFFFF]",
		},
		{--NS
		bagSet=infBag.NSstart, mdBagID="MainDeck NS", cBagID="Characters NS", generalID="5c50d2",
		bBagID="CM Archenemy NS", wBagID="Weakness NS", kBagID="Kick NS",
		spawnOther=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_NS", cg_mdID="cg_md_NS", cg_bID="cg_b_NS",
		imgRep="NS", printName="[FF9900]Naruto Shippuden[FFFFFF]",
		},
		{--Promos
		bagSet=infBag.Promoall, mdBagID="MainDeck Promo", cBagID="Characters Promo",
		cgCharacter=false, cgMain=false, cg_cID="cg_c_Promos", cg_mdID="cg_md_Promos",
		spawnOther=true,
		imgRep="Promos", printName="[EBEBEB]Promos[FFFFFF]",
		},
		{--MV
		bagSet=infBag.MVstart, mdBagID="MainDeck MV", cBagID="Characters MV", bBagID="CM Boss MV",
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_MV", cg_mdID="cg_md_MV", cg_bID="cg_b_MV",
		spawnOther=true,
		imgRep="MV", printName="[EDF01D]Multiverse[FFFFFF]",
		},
		{--EA1
		bagSet=infBag.EA1start, mdBagID="MainDeck EA1", cBagID="Characters EA1", generalID="ec7ee5",
		bBagID="Legend EA1", wBagID="Limp Wand EA1", kBagID="Wild Magic EA1",
		mainESW=true, bESW=true, mayhemESW=true, standeeESW=true,
		isESW=true, spawnESW=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_EA1", cg_mdID="cg_md_EA1", cg_bID="cg_b_EA1",
		mdESW_id="esw_MD_EA1", bESW_id="esw_legends_EA1", mESW_id="esw_mayhem_EA1", sESW_id="esw_trophy_EA1",
		mayhemID="Mayhem EA1", standeeID="ESW Trophy Standee EA1", eswMain="ESW - Maindeck No Mayhem - EA1", eswLegend="Legend EA1",
		imgRep="EA1", printName="[1F7096]Epic Spell Wars of the Battle Wizards[1F7096] - [C92D39]ANNIHILAGEDDON", standardID="Basic EA1",
		},
		{--EA2
		bagSet=infBag.EA2start, mdBagID="MainDeck EA2", cBagID="Characters EA2", generalID="42104e",
		bBagID="Legend EA2", wBagID="Limp Wand EA2", kBagID="Wild Magic EA2",
		mainESW=true, bESW=true, mayhemESW=true, standeeESW=true,
		isESW=true, spawnESW=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_EA2", cg_mdID="cg_md_EA2", cg_bID="cg_b_EA2",
		mdESW_id="esw_MD_EA2", bESW_id="esw_legends_EA2", mESW_id="esw_mayhem_EA2", sESW_id="esw_trophy_EA2",
		mayhemID="Mayhem EA2", mayhemMegaID="ESW Mega Mayhem EA2", standeeID="ESW Trophy Standee EA2", eswMain="ESW - Maindeck No Mayhem - EA2", eswLegend="ESW - Legends No Mayhem - EA2",
		imgRep="EA2", printName="[1F7096]Epic Spell Wars of the Battle Wizards - [C92D39]ANNIHILAGEDDON [ED4018]2 - [E9BD17]Xtreme[ED9118]Nacho [ED4018]Legends", standardID="Basic EA2",
		},
		{--EGB
		bagSet=infBag.EGBstart,  mdBagID="MainDeck EGB", cBagID="Characters EGB", generalID="c809da",
		bBagID="Legend EGB",
		bESW=true, mayhemESW=false, standeeESW=true,
		isESW=true, spawnESW=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_EGB", cg_mdID="cg_md_EGB", cg_bID="cg_b_EGB",
		mESW_id="esw_mayhem_EGB", bESW_id="esw_legends_EGB", sESW_id="esw_trophy_EGB",
		mayhemID="MainDeck EGB", standeeID="ESW Trophy Standee EGB", eswLegend="Legend EGB",
		imgRep="EGB", printName="[1F7096]Epic Spell Wars of the Battle Wizards - [C92D39]ANNIHILAGEDDON - [C09000]Gang Bangers",
		},
		{--RB
		mdValue=false, mdID="mdRB", cValue=false, cID="scRB", mvValue=false, mvID="mvRB",
		bagSet=infBag.RBstart, mdBagID="MainDeck RB", cBagID="Characters RB", generalID="22b0bc", bBagID="CM Boss RB",
		wBagID="Weakness RB",
		mvRep="MV RB", mvCore="MV_Core_RB",
		isDCE=true,
		cgCharacter=false, cgMain=false, cgBoss=false, cg_cID="cg_c_RB", cg_mdID="cg_md_RB", cg_bID="cg_b_RB",
		imgRep="RB", printName="[0B7AFF]DC Rebirth[FFFFFF]",
		},
	}
	menuToggleExtras = {
	dceMD = false, dceC = false,
	cgC=false, cgMD=false, cgB=false, cgEvents=false, cgHands=false, cgCrisis=false, cgSplitLocations=false, cg2TWalls=false,
	cgStarters="", cgWeaknessStack="", cgKickStack="",
	cgDWT=0, cgAT=0,
	rivals_kick8=true, rivals_weakness10=true, rivals_selectall=false, rivals_R3extras=false,
	mdBagID_y = 3, cBagID_y = 1.5, kBagID_y=1.5, wBagID_y=2.75, bBagID_y=1.5,
	mvGameModeStandard = true, mvGameLengthStandard = true, mvAddCrisis = false,
	eswDWT="", eswGB = false, eswVP=false, eswWand=true, eswCheese=true, eswBlasting=true, dwtEA1=true, dwtEA2=true, dwtEGB=true, abilityEA1=true, abilityEA2=true,
	ruleRivals=false, ruleLOTR=false, ruleCartoon=false, eventCartoon=true, stackTG=true, ruleRickMorty=false, councilRickMorty=true, rulesESW=false,
	}
	menuToggleRivalsCharacters = {
		["isR1_H"] = {name="isR1_H", isEnabled=false, bag=infBag.R1start, params="Rivals Batman",},  
		["isR1_V"] = {name="isR1_V", isEnabled=false, bag=infBag.R1start, params="Rivals The Joker",},  
		["isR2_H"] = {name="isR2_H", isEnabled=false, bag=infBag.R2start, params="Rivals Green Lantern",},  
		["isR2_V"] = {name="isR2_V", isEnabled=false, bag=infBag.R2start, params="Rivals Sinestro",}, 
		["isR3_H"] = {name="isR3_H", isEnabled=false, bag=infBag.R3start, params="Rivals Flash",},  
		["isR3_V"] = {name="isR3_V", isEnabled=false, bag=infBag.R3start, params="Rivals Reverse-Flash",}, 
		["isRC_S"] = {name="isRC_S", isEnabled=false, bag=infBag.RCstart, params="Rivals Superman",},  
		["isRC_W"] = {name="isRC_W", isEnabled=false, bag=infBag.RCstart, params="Rivals Wonder Woman",},
		["isRC_A"] = {name="isRC_A", isEnabled=false, bag=infBag.RCstart, params="Rivals Aquaman",}, 
		["isRC_Z"] = {name="isRC_Z", isEnabled=false, bag=infBag.RCstart, params="Rivals Zatana Zatara",},
		["isRC_L"] = {name="isRC_L", isEnabled=false, bag=infBag.RCstart, params="Rivals Lex Luthor",}, 
		["isRC_C"] = {name="isRC_C", isEnabled=false, bag=infBag.RCstart, params="Rivals Circe",}, 
		["isRC_O"] = {name="isRC_O", isEnabled=false, bag=infBag.RCstart, params="Rivals Ocean Master",},
		["isRC_F"] = {name="isRC_F", isEnabled=false, bag=infBag.RCstart, params="Rivals Felix Faust",},
	}
end



guidWhiteList = {
	--Buttons
	"f4ab9b", -- DC
	"c6cd5d", -- HU
	"40883f", -- FE
	"d4812f", -- TT
	"35a87f", -- DNM
	"07b6ee", -- INJ
	"88ded9", -- C1
	"902789", -- C2
	"7d7471", -- C3
	"559c2c", -- C4
	"1bf66c", -- R1
	"9ace82", -- R2
	"e8c67d", -- R3
	"e10335", -- R4
	"90f6cc", -- RC
	"1ddfb7", -- CO1
	"fba148", -- CO2
	"83c010", -- CO3
	"417fca", -- CO4
	"bcbc0c", -- CO5
	"8066ac", -- CO6
	"563640", -- CO7
	"a196ad", -- CO8
	"e9db06", -- CO9
	"62b07a", -- CO10
	"0e7373", -- MV
	"64990a", -- Promos
	"22b0bc", -- Rebirth
	"96f525", -- DCDB
	"57b413", -- FotR
	"f91e72", -- 2T
	"f606f7", -- RotK
	"ef8609", -- UJ
	"5a6a23", -- DoS
	"1ff5b7", -- CN
	"677013", -- AA
	"1c2149", -- TTG
	"45d9f6", -- RM1
	"1b76e7", -- RM2
	"8a3181", -- SF
	"5c50d2", -- NS
	"8ad2bf", -- NHL
	"3070fd", -- AT
	"ec7ee5", -- ESW1
	"c809da", -- ESWGB
	"42104e", -- ESW2
	-- Boards
	"4418bd", -- BackTable
	"f2c0c6", -- Destroyed Pile
	"7a5ad3", -- Play Area
	"f2db8b", -- Normal Table
	"2482a4", -- Rebirth Table
	"f2265f", -- 8 Player Normal
	"7853b6", -- 8 Player Rebirth
	"eda22b", -- Rebirth Campaign Log
	--Dice & Tokens
	"2cb54c", -- RPS 1
	"40c789", -- D20
	"c47396", -- D6 ESW
	"ec6362", -- VP Token Bags
	"bb4a21", -- Frozen Token Bag
	"c42f56", -- Time Travel Bag
	"e36c9d", -- Ninjutsu Bag
	"1c64a5", -- INJ KO Bag
	"f0c1c9", -- Freeze Token Bag
	"81b6b6", -- Bribe Stand
	"d8f6d0", -- Bribe Bag
	--Player VP Bags
	"9ada49", -- Green
	"c98019", -- Red
	"568734", -- Yellow
	"0b5d8b", -- White
	"aed30a", -- Brown
	"bf50a8", -- Purple
	"db8bd1", -- Orange
	"d3842a", -- Pink
	--Player Boards
	"f258b9", -- White
	"31204b", -- Red
	"a2e05a", -- Green
	"a143cd", -- Yellow
	"d78f45", -- Brown
	"e6d013", -- Purple
	"db81b7", -- Orange
	"12a755", -- Pink
	-- Player Score Area
	"fb723d", -- Green Notecard
	"21766f", -- Green Score
	"021a21", -- Green Script
	"541aa3", -- Red Notecard
	"89c010", -- Red Score
	"0e74b6", -- Red Script
	"8e61c6", -- Yellow Notecard
	"41a702", -- Yellow Score
	"73ee7d", -- Yellow Script
	"a86144", -- White Notecard
	"b83860", -- White Score
	"d3e083", -- White Script
	"a2a035", -- Brown Notecard
	"39b9b3", -- Brown Score
	"15b4bd", -- Brown Script
	"b89a69", -- Purple Notecard
	"8c4005", -- Purple Score
	"edf1c9", -- Purple Script
	"ff81fb", -- Orange Notecard
	"dd973a", -- Orange Score
	"59e7a2", -- Orange Script
	"d63896", -- Pink Notecard
	"ab805f", -- Pink Score
	"82bb4b", -- Pink Script
	-- Line Up
	"887020", -- Main deck
	"0c27f0", -- Line Up 1
	"f4deab", -- Line Up 2
	"f232af", -- Line up 3
	"7e8a1c", -- Line Up 4
	"bc5125", -- Line Up 5
	-- Stacks
	"6a35b3", -- Other 1
	"c7b7f1", -- Other 2
	"84d375", -- Weakness Stack
	"9a84c9", -- Kick Stack
	"a21b9d", -- Boss Stack
	"9705a1", -- Crisis Stack
	"58b549", -- Character Stack
	-- Boss Setup
	"7b5156", -- Level 1 Boss
	"f5551a", -- Level 2 Boss
	"0617c6", -- Level 3 Boss
	"1f46cc", -- Level 4 Boss
	"fe8cff", -- Level 5 Boss
	"f621ac", -- Set Up
	-- Destroyed Table
	"2ed596", -- Text
	"26f9b9", -- Hero
	"34c6e3", -- Villain
	"3acc90", -- Super Power
	"065c55", -- Equipment
	"38359a", -- Location
	"045308", -- Starter
	"e43b04", -- Weakness
	"3c2524", -- Other
	"b3a4e3", -- Removed From Game
	"f2e131", -- Under Dead Marsh
	-- Event Line Up
	"1b3c6f", -- Events
	"231173", -- Event Line Up 1
	"c5c2e4", -- Event Line Up 2
	"0b4bd6", -- Event Line Up 3
	"b9d48c", -- Event Line Up 4
	"548ead", -- Event Line Up 5
	--Green Player
	"8b9a08", -- Discard Group
	"391f51", -- Other Pile
	"89f005", -- Equipment Pile
	"48ebbe", -- Super Power Pile
	"67bc24", -- Hero Pile
	"c58245", -- Villain Pile
	"11c23a", -- Starter Pile
	"06c521", -- Under Character Pile
	"ae4c7b", -- Score Pile
	"a3ea17", -- Character 6
	"3bc904", -- Character 5
	"557ba9", -- Character 4
	"31c824", -- Character 3
	"4cf578", -- Character 2
	"a14222", -- Character 1
	"4482a6", -- Deck
    "2a35be", -- Ongoing 1
    "1ca129", -- Ongoing 2
    "10eac3", -- Ongoing 3
    "ccc189", -- Ongoing 4
    "abb0f1", -- Ongoing 5
    "063863", -- Ongoing 6
    "a89007", -- Ongoing 7
    "403f99", -- Ongoing 8
	"fad37b", -- Ongoing 9
	"266da3", -- Ongoing 10
	--Red Player
	"d6f8e4", -- Discard Group
	"c09c91", -- Other Pile
	"458f71", -- Equipment Pile
	"8eb7d5", -- Super Power Pile
	"83492e", -- Hero Pile
	"def7de", -- Villain Pile
	"fe12d8", -- Starter Pile
	"84b01c", -- Under Character Pile
	"ce7393", -- Score Pile
	"df570d", -- Character 6
	"f8b075", -- Character 5
	"e5d470", -- Character 4
	"ac3332", -- Character 3
	"f54cc6", -- Character 2
	"d30f57", -- Character 1
	"fb2e00", -- Deck
    "b93cd9", -- Ongoing 1
    "b8227d", -- Ongoing 2
    "807cd3", -- Ongoing 3
    "d72706", -- Ongoing 4
    "cb76cc", -- Ongoing 5
    "750cae", -- Ongoing 6
    "06a4d1", -- Ongoing 7
    "30322e", -- Ongoing 8
	"978efb", -- Ongoing 9
	"1429b5", -- Ongoing 10
	--Yellow Player
	"3bddb6", -- Discard Group
	"d21567", -- Other Pile
	"6d955b", -- Equipment Pile
	"42429a", -- Super Power Pile
	"41c123", -- Hero Pile
	"0a562c", -- Villain Pile
	"6e0766", -- Starter Pile
	"b71a59", -- Under Character Pile
	"8e67e1", -- Score Pile
	"1cdb8d", -- Character 6
	"082aec", -- Character 5
	"bdbbb2", -- Character 4
	"cfdb57", -- Character 3
	"8c3b36", -- Character 2
	"2f7c5b", -- Character 1
	"d6fb8b", -- Deck
    "b7e53c", -- Ongoing 1
    "df7140", -- Ongoing 2
    "26078f", -- Ongoing 3
    "51e83c", -- Ongoing 4
    "59e435", -- Ongoing 5
    "5cc639", -- Ongoing 6
    "0f5ada", -- Ongoing 7
    "6f9039", -- Ongoing 8
	"995677", -- Ongoing 9
	"63e4f1", -- Ongoing 10
	--White Player
	"e52008", -- Discard Group
	"b49fa2", -- Other Pile
	"377193", -- Equipment Pile
	"46871e", -- Super Power Pile
	"a9a422", -- Hero Pile
	"9ba8d1", -- Villain Pile
	"61df81", -- Starter Pile
	"b95b40", -- Under Character Pile
	"a0e1d7", -- Score Pile
	"2a099f", -- Character 6
	"01bc80", -- Character 5
	"cc9210", -- Character 4
	"425589", -- Character 3
	"1ac1a2", -- Character 2
	"7e71c7", -- Character 1
	"8afdb7", -- Deck
    "08e761", -- Ongoing 1
    "eda755", -- Ongoing 2
    "4bb78b", -- Ongoing 3
    "c8a40d", -- Ongoing 4
    "2bb0b1", -- Ongoing 5
    "b566da", -- Ongoing 6
    "5c127f", -- Ongoing 7
    "e81aa4", -- Ongoing 8
	"c3cf36", -- Ongoing 9
	"1eec4d", -- Ongoing 10
	--Brown Player
	"77c200", -- Discard Group
	"dd4636", -- Other Pile
	"267b4f", -- Equipment Pile
	"c06ff2", -- Super Power Pile
	"75463e", -- Hero Pile
	"336254", -- Villain Pile
	"229407", -- Starter Pile
	"3460cc", -- Under Character Pile
	"8ec238", -- Character 1
	"475f9e", -- Character 2
	"ab8940", -- Character 3
	"066a12", -- Character 4
	"735aa6", -- Character 5
	"29682d", -- Deck
    "57c6d7", -- Ongoing 1
    "6b4adc", -- Ongoing 2
    "b97ee7", -- Ongoing 3
    "5fa25a", -- Ongoing 4
    "c522f3", -- Ongoing 5
    "1c9a22", -- Ongoing 6
    "888c48", -- Ongoing 7
    "767fdc", -- Ongoing 8
	--Purple Player
	"a54dce", -- Discard Group
	"5f6039", -- Other Pile
	"93ff78", -- Equipment Pile
	"226efc", -- Super Power Pile
	"ea0e28", -- Hero Pile
	"2de380", -- Villain Pile
	"4dbcd5", -- Starter Pile
	"a4e548", -- Under Character Pile
	"449d58", -- Character 1
	"316d05", -- Character 2
	"d8b80c", -- Character 3
	"bd52f6", -- Character 4
	"31a87d", -- Character 6
	"5acdd7", -- Deck
    "d689ca", -- Ongoing 1
    "1a3ebd", -- Ongoing 2
    "95be0b", -- Ongoing 3
    "2e93c4", -- Ongoing 4
    "225709", -- Ongoing 5
    "872f58", -- Ongoing 6
    "894cf7", -- Ongoing 7
    "1ebebf", -- Ongoing 8
	--Orange Player
	"c7d573", -- Discard Group
	"9cdb97", -- Other Pile
	"a72bb5", -- Equipment Pile
	"bbbfac", -- Super Power Pile
	"a91396", -- Hero Pile
	"5e0da8", -- Villain Pile
	"d6a381", -- Starter Pile
	"dc801c", -- Under Character Pile
	"b9173c", -- Character 1
	"18d394", -- Character 2
	"05e6d9", -- Character 3
	"37d3cc", -- Character 4
	"e9be6f", -- Character 5
	"37c192", -- Deck
    "f1f632", -- Ongoing 1
    "8c70fa", -- Ongoing 2
    "4262d0", -- Ongoing 3
    "a66d53", -- Ongoing 4
    "e4687f", -- Ongoing 5
    "2da0fd", -- Ongoing 6
    "4f1a68", -- Ongoing 7
    "794f58", -- Ongoing 8
	--Pink Player
	"fde50d", -- Discard Group
	"d8138c", -- Other Pile
	"32081f", -- Equipment Pile
	"c9cad7", -- Super Power Pile
	"cfa083", -- Hero Pile
	"b00284", -- Villain Pile
	"61c7f5", -- Starter Pile
	"fbba4c", -- Under Character Pile
	"cbfa1a", -- Character 1
	"95a1bd", -- Character 2
	"625f54", -- Character 3
	"be228e", -- Character 4
	"97a83d", -- Character 6
	"1c592d", -- Deck
    "942bbc", -- Ongoing 1
    "8910d9", -- Ongoing 2
    "4a65ab", -- Ongoing 3
    "805150", -- Ongoing 4
    "d523bb", -- Ongoing 5
    "75d61b", -- Ongoing 6
    "033a9f", -- Ongoing 7
    "0b58b9", -- Ongoing 8
	-- Script buttons
	"0eb2fc", -- Random Starting Player / Check Scores
	"f8250f", -- Clock
}