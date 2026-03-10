function buttons_Default()
	self.createButton({rotation={0,0,0}, position={-1.5,0,0}, font_size=120, label="Random\nStarting\nPlayer", width=800, height=400, function_owner=self, click_function='randomSeatedPlayer'})
	self.createButton({rotation={0,0,0}, position={1.5,0,0}, font_size=120, label="Check\nScores", width=800, height=400, function_owner=self, click_function='checkScore'})
	--self.createButton({rotation={0,0,0}, position={-2,0,3}, font_size=120, label="Debug", width=800, height=400, function_owner=self, click_function='debugScoreSwitch'})
end
function buttons_DCDB_Cube()
    self.createButton({rotation={0,0,0}, position={2.25,0,0}, label="Report\nRanked\nGame", width=800, height=400, click_function='recordGame'})
    self.createButton({rotation={0,0,0}, position={0,0,1.5}, label="Check\nScores\n2v2", width=800, height=400, click_function='checkScores2v2'})
    self.createButton({rotation={0,0,0}, position={2.25,0,1.5}, label="Report\nScores\n2v2", width=800, height=400, click_function='reportScores2v2'})
end


function debugScoreSwitch() -- Used to Switch between Scoring Systems
	if Global.getVar("specialSetUp") == "Smaug" or Global.getVar("specialSetUp") == "LotR" then
		Global.setVar("specialSetUp", "Nothing")
		print("Special Set up is currently: " .. Global.getVar("specialSetUp"))
	else
		Global.setVar("specialSetUp", "LotR")
		print("Special Set up is currently: " .. Global.getVar("specialSetUp"))
	end
end
--[[ -- Example Code for checking inside table for odd use cases
function debugIDCheck()
	for i in pairs(masterCardTable) do -- Normal for loop on table
		if masterCardTable[i].vp == 4 then -- masterCardTable["Name"].value we're looking for
			print(i) -- print name
			print(masterCardTable[i].vp) --print value
		end
	end
end
]]--

function randomSeatedPlayer() --Select Random Seated Player
    local seatedPlayers = getSeatedPlayers()
    currentColor = seatedPlayers[math.random(#seatedPlayers)]
	if currentColor ~= nil then
		local name = Player[currentColor].steam_name
		printToAll(name .. " was randomly selected to start first!", stringColorToRGB(currentColor))
	end
end


--Main Score Scripts
scoreRequiredTable = {
	{scoreZone=getObjectFromGUID("021a21"), counter=getObjectFromGUID("21766f"), bag=getObjectFromGUID("9ada49"), underCharacter=getObjectFromGUID("06c521"), color="Green"},
	{scoreZone=getObjectFromGUID("0e74b6"), counter=getObjectFromGUID("89c010"), bag=getObjectFromGUID("c98019"), underCharacter=getObjectFromGUID("84b01c"), color="Red"},
	{scoreZone=getObjectFromGUID("73ee7d"), counter=getObjectFromGUID("41a702"), bag=getObjectFromGUID("568734"), underCharacter=getObjectFromGUID("b71a59"), color="Yellow"},
	{scoreZone=getObjectFromGUID("d3e083"), counter=getObjectFromGUID("b83860"), bag=getObjectFromGUID("0b5d8b"), underCharacter=getObjectFromGUID("b95b40"), color="White"},
	{scoreZone=getObjectFromGUID("15b4bd"), counter=getObjectFromGUID("39b9b3"), bag=getObjectFromGUID("aed30a"), underCharacter=getObjectFromGUID("3460cc"), color="Brown"},
	{scoreZone=getObjectFromGUID("edf1c9"), counter=getObjectFromGUID("8c4005"), bag=getObjectFromGUID("bf50a8"), underCharacter=getObjectFromGUID("a4e548"), color="Purple"},
	{scoreZone=getObjectFromGUID("59e7a2"), counter=getObjectFromGUID("dd973a"), bag=getObjectFromGUID("db8bd1"), underCharacter=getObjectFromGUID("dc801c"), color="Orange"},
	{scoreZone=getObjectFromGUID("82bb4b"), counter=getObjectFromGUID("ab805f"), bag=getObjectFromGUID("d3842a"), underCharacter=getObjectFromGUID("fbba4c"), color="Pink"},
}
function checkScore() -- Runs Score Script in proper order
	removeScoreCardHighlights()
	checkVPbag()
	checkUnderZone()
	checkScoreZone()
	mergeValues()
	addVPforSpecialCards()
	findWinner()
end
function checkVPbag() -- Grab VP Score
    vpBagToScoreList = {} -- Reset Table
	scoreCompareList = {twinsEGB={},  colorsEGB={}, twinsEA2={}, colorsEA2={}, ringRK=false, apokolips=false, newGenesis=false, } --Reset Compare Table
    for i, zone in pairs(scoreRequiredTable) do --Running Loop 8 times since there are max 8 players

		table.insert(vpBagToScoreList, --Varables needed to calculate score
		{vp=0, vptokens=0, dwt=0,
		dwtEGB_1=0, dwtEGB_4=0, dwtEGB_8=0, dwtEGB_9=0, dwtEGB_16=0, dwtEGB_17=0, dwtEGB_19=0, dwtEGB_Twins=0,
		dwtEA2_6=0, dwtEA2_11=0, dwtEA2_Twins=0,
		abilityEA2_8=0, dingler=0, catwomanCO12 = 0,
		color=zone.color,}
		)
		if zone.bag.getQuantity() > 0 then --if Players bag contains more then 1 object
			bagObjects=zone.bag.getData().ContainedObjects --Grab Bag Objects
			for j, tokens in ipairs(bagObjects) do -- running loop on objects in bag
				local master = masterTokenTable[tokens.Nickname]
				if master ~= nil then
					vpBagToScoreList[i].vp = vpBagToScoreList[i].vp + master.vp -- grab vp score
					if master.isDWT == true then -- check if needed to add to dead wizard token counter
						vpBagToScoreList[i].dwt = vpBagToScoreList[i].dwt + 1
					end
					if tokens.Nickname == "VP Token" then -- Generic 1 VP Token
						vpBagToScoreList[i].vptokens = vpBagToScoreList[i].vptokens +1
					elseif tokens.Nickname == "RotK The One Ring" then -- Samwise +3 vp for ring being destroyed
						scoreCompareList.ringRK = true
					elseif tokens.Nickname == "EGB Dead Wizard Token 1" then -- -1 DWT 6 vp if you own +4 creatures
						vpBagToScoreList[i].dwtEGB_1 = vpBagToScoreList[i].dwtEGB_1 + 1
					elseif tokens.Nickname == "EGB Dead Wizard Token 4" then -- -1 vp & +1 limp for each fizzle you own
						vpBagToScoreList[i].dwtEGB_4 = vpBagToScoreList[i].dwtEGB_4 + 1
					elseif tokens.Nickname == "EGB Dead Wizard Token 8" then -- -1 DWT & 6 vp if you own +4 wizards
						vpBagToScoreList[i].dwtEGB_8 = vpBagToScoreList[i].dwtEGB_8 + 1
					elseif tokens.Nickname == "EGB Dead Wizard Token 9" then -- destroy each of your limp wands
						vpBagToScoreList[i].dwtEGB_9 = vpBagToScoreList[i].dwtEGB_9 + 1
					elseif tokens.Nickname == "EGB Dead Wizard Token 10" or tokens.Nickname == "EGB Dead Wizard Token 20" then -- -1 DWT & -3 vp if other player owns token
						vpBagToScoreList[i].dwtEGB_Twins = vpBagToScoreList[i].dwtEGB_Twins + 1
						if scoreCompareList.twinsEGB[vpBagToScoreList[i].color] == nil then -- checks if color is in table
							scoreCompareList.twinsEGB[vpBagToScoreList[i].color] = true -- locks color out of this if statement going forward
							table.insert(scoreCompareList.colorsEGB, vpBagToScoreList[i].color) -- add color to table to be compared later
						end
					elseif tokens.Nickname == "EGB Dead Wizard Token 16" then
						vpBagToScoreList[i].dwtEGB_16 = vpBagToScoreList[i].dwtEGB_16 + 1 -- Blasting Glyph is -4 VP each
					elseif tokens.Nickname == "EGB Dead Wizard Token 17" then
						vpBagToScoreList[i].dwtEGB_17 = vpBagToScoreList[i].dwtEGB_17 + 1 -- -1 DWT & 6 vp if you own +4 Spells
					elseif tokens.Nickname == "EGB Dead Wizard Token 19" then
						vpBagToScoreList[i].dwtEGB_19 = vpBagToScoreList[i].dwtEGB_19 + 1 -- -1 DWT & 6 vp if you own +2 Locations
					elseif tokens.Nickname == "EA2 Dead Wizard Token 6" then
						vpBagToScoreList[i].dwtEA2_6 = vpBagToScoreList[i].dwtEA2_6 + 1 -- Dingler VP penalty is double
					elseif tokens.Nickname == "EA2 Dead Wizard Token 11" then
						vpBagToScoreList[i].dwtEA2_11 = vpBagToScoreList[i].dwtEA2_11 + 1 -- Limp Wands VP penalty is double
					elseif tokens.Nickname == "EA2 Dead Wizard Token 27" or tokens.Nickname == "EA2 Dead Wizard Token 30" then -- -1 DWT & -8 vp if other player owns token
						vpBagToScoreList[i].dwtEA2_Twins = vpBagToScoreList[i].dwtEA2_Twins + 1
						if scoreCompareList.twinsEA2[vpBagToScoreList[i].color] == nil then
							scoreCompareList.twinsEA2[vpBagToScoreList[i].color] = true
							table.insert(scoreCompareList.colorsEA2, vpBagToScoreList[i].color)
						end
					elseif tokens.Nickname == "EA2 Ability 8" then
						vpBagToScoreList[i].abilityEA2_8 = vpBagToScoreList[i].abilityEA2_8 + 1 -- +1 vp for each treasure
					elseif tokens.Nickname == "You're a Dingler!" then
						vpBagToScoreList[i].dingler = vpBagToScoreList[i].dingler + 1 -- -5 vp for being a Dingler
					elseif tokens.Nickname == "CO12 Catwoman" then
						vpBagToScoreList[i].catwomanCO12 =
							vpBagToScoreList[i].catwomanCO12 + 1
					end
				end
			end
		end
	end
	for i, v in ipairs(vpBagToScoreList) do
		if vpBagToScoreList[i].dingler > 0 and vpBagToScoreList[i].dwtEA2_6 > 0 then --If you have EA2 DWT6, double the negative vp lost
			vpBagToScoreList[i].vp = vpBagToScoreList[i].vp + (-5*2^vpBagToScoreList[i].dwtEA2_6*vpBagToScoreList[i].dingler) + (5*vpBagToScoreList[i].dingler)
		end
		if vpBagToScoreList[i].dwtEGB_Twins > 0 then -- EGB DWT 10 & 20 cancel each other out if another player has it
			for j, twinColors in ipairs(scoreCompareList .colorsEGB) do
				if scoreCompareList.colorsEGB[j] ~= vpBagToScoreList[i].color then
					vpBagToScoreList[i].vp = vpBagToScoreList[i].vp + (3*vpBagToScoreList[i].dwtEGB_Twins)
					vpBagToScoreList[i].dwt = vpBagToScoreList[i].dwt - (1*vpBagToScoreList[i].dwtEGB_Twins)
				break
				end
			end
		end
		if vpBagToScoreList[i].dwtEA2_Twins > 0 then -- EA2 DWT 27 & 30 cancel each other out if another player has it
			for j, twinColors in ipairs(scoreCompareList.colorsEA2) do
				if scoreCompareList.colorsEA2[j] ~= vpBagToScoreList[i].color then
					vpBagToScoreList[i].vp = vpBagToScoreList[i].vp + (8*vpBagToScoreList[i].dwtEA2_Twins)
					vpBagToScoreList[i].dwt = vpBagToScoreList[i].dwt - (1*vpBagToScoreList[i].dwtEA2_Twins)
				break
				end
			end
		end
		if vpBagToScoreList[i].dwtEA2_Twins == 2 then
			vpBagToScoreList[i].vp = vpBagToScoreList[i].vp + (8*vpBagToScoreList[i].dwtEA2_Twins)
			vpBagToScoreList[i].dwt = vpBagToScoreList[i].dwt - (1*vpBagToScoreList[i].dwtEA2_Twins)
		end
		--[[ Debug
		if vpBagToScoreList[i].vp ~= 0 then
			printToAll("VP: " .. vpBagToScoreList[i].vp, stringColorToRGB(vpBagToScoreList[i].color))
		end
		--]]
	end
end
function checkUnderZone() -- Grab Under Character Cards for Score
	underToScoreList = {} -- Nil Table to fill, and move forward with
    for i, zone in pairs(scoreRequiredTable) do --Running Loop 8 times since there are max 8 players
		local objectsInUnder = zone.underCharacter.getObjects()	-- Grabs anything in Under Character Zone
        for j, deck in ipairs(objectsInUnder) do
			if deck.type  == "Deck" then --if it finds a Deck object
				table.insert(underToScoreList, {deck=deck, color=zone.color, plan=2, under=true})
				--Table underToScoreList = {object in player color's zone, player's color, plan 1 for card or plan 2 for deck}
			break
			elseif deck.type  == "Card" then --if it finds a Card object
				table.insert(underToScoreList, {deck=deck, color=zone.color, plan=1, under=true})
			break
			end
		end
	end
	underValueList={}
	addScoreValues(underToScoreList, underValueList)
	--[[ Debug
	for i, v in ipairs(underValueList) do
		if underValueList[i].vp ~= 0 then
			printToAll("VP: " .. underValueList[i].vp, stringColorToRGB(underValueList[i].color))
		end
	end
	--]]
end
function checkScoreZone() -- Grabs Score Zone Cards for Score
	scoreToScoreList = {} -- Nil Table to fill, and move forward with
		local missingTables = {
		["Green"] = {hasTable=false},
		["Red"] = {hasTable=false},
		["Yellow"] = {hasTable=false},
		["White"] = {hasTable=false},
		["Pink"] = {hasTable=false},
		["Brown"] = {hasTable=false},
		["Orange"] = {hasTable=false},
		["Purple"] = {hasTable=false}}
    for i, zone in pairs(scoreRequiredTable) do --Running Loop 8 times since there are max 8 players
		zone.counter.Counter.clear()
		local objectsInScore = zone.scoreZone.getObjects()	-- Grabs anything in Score Zone
        for j, deck in ipairs(objectsInScore) do
			if deck.type  == "Deck" then --if it finds a Deck object
				table.insert(scoreToScoreList, {deck=deck, color=zone.color, plan=2, scorePile=true, counter=zone.counter,})
			break
			elseif deck.type  == "Card" then --if it finds a Card object
				table.insert(scoreToScoreList, {deck=deck, color=zone.color, plan=1, scorePile=true, counter=zone.counter,})
			break
			end
		end
    end
	for k, value in pairs(scoreToScoreList) do
		missingTables[value.color].hasTable=true
	end
	for j, zone in pairs(scoreRequiredTable) do
		if missingTables[zone.color].hasTable == false then
			table.insert(scoreToScoreList, {deck={}, color=zone.color, plan=3, scorePile=true, counter=zone.counter,})
		end
	end
	scoreValueList={}
	addScoreValues(scoreToScoreList, scoreValueList)
	--[[ Debug
	for i, v in ipairs(scoreValueList) do
		if scoreValueList[i].vp ~= 0 then
			printToAll("VP: " .. scoreValueList[i].vp, stringColorToRGB(scoreValueList[i].color))
		end
	end
	--]]
end
function addScoreValues(tempScoreValues, tempScoreList) -- Adds general Values to be Scored after totaled & Merges Under with Score Values.
	for i, deck in ipairs(tempScoreValues) do
		table.insert(tempScoreList,
		{vp=0, Boss=0, cards=0, vptokens=0, under=0,
		heroes=0, villains=0, superPowers=0, equipment=0, locations=0, weaknesses=0, starters=0,
		bribes=0, expBribes=0, catwomanCO12 = 0, sevenCostOrHigher = 0,
		allies=0, enemies=0,  maneuvers=0, artifacts=0, archEnemy=0, courages=0,
		wizards=0, creatures=0, spells=0, treasures=0, legends=0, limp=0,
		councils=0, geniusWaves=0, mortyWaves=0,
		zeroCost=0, suicideSquad=0, countOfSuicideSquads=0, greenArrow=0, utilityBelt=0, bizarro=0,
		saintWalker=0, sciencell=0, larfleeze=0, powerRings=0, expPowerRings=0,
		phantomStranger=0, deathstorm=0, elementWoman=0,
		dickGrayson=0, shapeShift=0, tWing=0,
		carterHall=0, elementX=0, metals=0,
		solomonGrundy=0, moriaQueen=0, highFather=0, traverseTimelines=0, timeLineUps=0,
		striderRanger=0, moriaOrcCaptain=0, moriaOrcs=0, elvenBrooch=0, sting=0,
		battlementsWall=0, deadMarshes=0, wargRiders=0, longbottomLeaf=0,
		gimliElfFriend=0, legolasDwarfFriend=0, oliphantCaptain=0, samwise=0, thereIsCourageStill=0,
		orcLeader=0, theContract=0,
		masterLakeTown=0, relightForge=0, corruptionHoarding=0, loot=0,
		agentsOfShadaloo=0, rolentosBaton=0, akumasGi=0, jungleWarrior=0,
		asuma=0, lightningBlade=0, jiraiya=0, ningendo=0,
		rm1C137=0, assemble=0, rm2C137=0, szechuan=0,
		fizzles=0, dragonsBallZ=0, hugeBoner=0, bGlyph=0,
		crayzMIB=0, dCircus=0, viagrus=0, goldygoose=0,
		dwt=0, abilityEA2_8=0, dingler=0,
		dwtEGB_16=0, dwtEA2_6=0, dwtEA2_11=0,
		uniqueHeroes={}, uniqueVillains={}, uniqueSuperPowers={},
		uniqueAllies={}, uniqueEnemies={},  uniqueManeuvers={},
		uniqueOngoings={}, uniqueDefenses={}, uniqueAttacks={}, uniqueUnderCharacter={},
		uniqueTwoCostOrLess={}, uniqueEnemySevenCostOrHigher={},
		uniquePosAttacks={}, uniqueChakra1={}, uniqueChakra2={}, uniquePathOfPain={},
		uniqueBribes={},
		color=deck.color, counter={}, deck={},})
		if deck.scorePile == true then
			for j, under in ipairs(underValueList) do
				if Global.getVar("specialSetUp") == "Smaug" or Global.getVar("specialSetUp") == "LotR" then
					for m, scoreTemp in ipairs(tempScoreList) do
						if underValueList[j].color == tempScoreList[m].color then
							tempScoreList[m] = underValueList[j]
						end
					end
				elseif Global.getVar("specialSetUp") ~= "Smaug" or Global.getVar("specialSetUp") ~= "LotR" then
					for m, scoreTemp in ipairs(tempScoreList) do
						if underValueList[j].color == tempScoreList[m].color then
							tempScoreList[m].under = underValueList[j].under
							tempScoreList[m].uniqueUnderCharacter = underValueList[j].uniqueUnderCharacter
						end
					end
				end
			end
			tempScoreList[i].deck = deck.deck
			tempScoreList[i].counter = deck.counter
		end
		if deck.plan == 1 then
			local card={}
			card.nickname = deck.deck.getName()
			local spot = i
			local underCheck = deck.under
			checkCardsinMasterList(card, tempScoreList, spot, underCheck)
		elseif deck.plan == 2 then
			local cardsInDeck = deck.deck.getObjects()
			for j, card in ipairs(cardsInDeck) do
				local spot = i
				local underCheck = deck.under
				checkCardsinMasterList(card, tempScoreList, spot, underCheck)
			end
		end
	end
end
function checkCardsinMasterList(card, tempScoreList, spot, underCheck)
	local i = spot
	local master = masterCardTable[card.nickname]
	if master ~= nil then
		if card.nickname == "DC Bizarro" then
			tempScoreList[i].bizarro = tempScoreList[i].bizarro + 1
		elseif card.nickname == "DC Suicide Squad" then
			if tempScoreList[i].suicideSquad == 0 then
				tempScoreList[i].suicideSquad = 1
			else
				tempScoreList[i].suicideSquad = tempScoreList[i].suicideSquad + 2
			end
			tempScoreList[i].vp = tempScoreList[i].vp + tempScoreList[i].suicideSquad
			tempScoreList[i].countOfSuicideSquads = tempScoreList[i].countOfSuicideSquads + 1
		elseif card.nickname == "SF Agents of Shadaloo" then
			if tempScoreList[i].agentsOfShadaloo == 0 then
				tempScoreList[i].agentsOfShadaloo = 1
			else
				tempScoreList[i].agentsOfShadaloo = tempScoreList[i].agentsOfShadaloo + 2
			end
			tempScoreList[i].vp = tempScoreList[i].vp + tempScoreList[i].agentsOfShadaloo
		elseif card.nickname == "2T Longbottom Leaf" then
			if tempScoreList[i].longbottomLeaf == 0 then
				tempScoreList[i].longbottomLeaf = 1
			else
				tempScoreList[i].longbottomLeaf = tempScoreList[i].longbottomLeaf + 2
			end
			tempScoreList[i].vp = tempScoreList[i].vp + tempScoreList[i].longbottomLeaf
		elseif card.nickname == "DC Green Arrow" then
			tempScoreList[i].greenArrow = tempScoreList[i].greenArrow + 1
		elseif card.nickname == "DC Utility Belt" then
			tempScoreList[i].utilityBelt = tempScoreList[i].utilityBelt + 1
		elseif card.nickname == "HU Saint Walker" then
			tempScoreList[i].saintWalker = tempScoreList[i].saintWalker + 1
		elseif card.nickname == "HU Sciencell" then
			tempScoreList[i].sciencell = tempScoreList[i].sciencell + 1
		elseif card.nickname == "HU Larfleeze" then
			tempScoreList[i].larfleeze = tempScoreList[i].larfleeze + 1
		elseif card.nickname == "FE Element Woman (DCDB)" then
			tempScoreList[i].elementWoman = tempScoreList[i].elementWoman + 1
			tempScoreList[i].villains = tempScoreList[i].villains + 1
			if 	tempScoreList[i].uniqueVillains[card.nickname] == nil then
				tempScoreList[i].uniqueVillains[card.nickname] = true
			end
			tempScoreList[i].superPowers = tempScoreList[i].superPowers + 1
			if tempScoreList[i].uniqueSuperPowers[card.nickname] == nil then
				tempScoreList[i].uniqueSuperPowers[card.nickname] = true
			end
			tempScoreList[i].equipment = tempScoreList[i].equipment + 1
			tempScoreList[i].vp = tempScoreList[i].vp + master.vp
		elseif card.nickname == "FE Phantom Stranger" then
			tempScoreList[i].phantomStranger = tempScoreList[i].phantomStranger + 1
		elseif card.nickname == "FE Deathstorm" then
			tempScoreList[i].deathstorm = tempScoreList[i].deathstorm + 1
		elseif card.nickname == "TT Dick Grayson" then
			tempScoreList[i].dickGrayson = tempScoreList[i].dickGrayson + 1
		elseif card.nickname == "TT Shapeshift (DCDB)" then
			tempScoreList[i].shapeShift = tempScoreList[i].shapeShift + 1
			tempScoreList[i].villains = tempScoreList[i].villains + 1
			tempScoreList[i].heroes = tempScoreList[i].heroes + 1
			tempScoreList[i].equipment = tempScoreList[i].equipment + 1
			tempScoreList[i].vp = tempScoreList[i].vp + master.vp
		elseif card.nickname == "TT T-Wing" then
			tempScoreList[i].tWing = tempScoreList[i].tWing + 1
		elseif card.nickname == "DNM Carter Hall's Journal" then
			tempScoreList[i].carterHall = tempScoreList[i].carterHall + 1
		elseif card.nickname == "DNM Element X" then
			tempScoreList[i].elementX = tempScoreList[i].elementX + 1
		elseif card.nickname == "CO1 Solomon Grundy" then
			tempScoreList[i].solomonGrundy = tempScoreList[i].solomonGrundy + 1
		elseif card.nickname == "CO2 Moira Queen" then
			tempScoreList[i].moriaQueen = tempScoreList[i].moriaQueen + 1
		elseif card.nickname == "CO7 Highfather" then
			tempScoreList[i].highFather = tempScoreList[i].highFather + 1
		elseif card.nickname == "CO7 Apokolips (Level 3)" then
			tempScoreList[i].vp = tempScoreList[i].vp + master.vp
			--Need Global to Compare
		elseif card.nickname == "CO7 New Genesis (Level 3)" then
			tempScoreList[i].vp = tempScoreList[i].vp + master.vp
			--Need Global to Compare
		elseif card.nickname == "CO10 Traverse Timelines" then
			tempScoreList[i].traverseTimelines = tempScoreList[i].traverseTimelines + 1
		elseif card.nickname == "ARK Black Mask" then
    tempScoreList[i].expBribes = tempScoreList[i].expBribes + 1
		elseif card.nickname == "FotR Strider the Ranger" then
			tempScoreList[i].striderRanger = tempScoreList[i].striderRanger + 1
		elseif card.nickname == "FotR Moria Orc Captain" then
			tempScoreList[i].moriaOrcCaptain = tempScoreList[i].moriaOrcCaptain + 1
		elseif card.nickname == "FotR Moria Orcs" then
			tempScoreList[i].moriaOrcs = tempScoreList[i].moriaOrcs + 1
		elseif card.nickname == "FotR Elven Brooch" then
			tempScoreList[i].elvenBrooch = tempScoreList[i].elvenBrooch + 1
		elseif card.nickname == "FotR Sting" then
			tempScoreList[i].sting = tempScoreList[i].sting + 1
		elseif card.nickname == "2T Battlements on the Wall" then
			tempScoreList[i].battlementsWall = tempScoreList[i].battlementsWall + 1
		elseif card.nickname == "2T Dead Marshes" then
			tempScoreList[i].deadMarshes = tempScoreList[i].deadMarshes + 1
		elseif card.nickname == "2T Warg Riders" then
			tempScoreList[i].wargRiders = tempScoreList[i].wargRiders + 1
		elseif card.nickname == "RotK Gimli, the Elf-Friend" then
			tempScoreList[i].gimliElfFriend = tempScoreList[i].gimliElfFriend + 1
		elseif card.nickname == "RotK Legolas Greenleaf, the Dwarf-Friend" then
			tempScoreList[i].legolasDwarfFriend = tempScoreList[i].legolasDwarfFriend + 1
		elseif card.nickname == "RotK Oliphant Captain" then
			tempScoreList[i].oliphantCaptain = tempScoreList[i].oliphantCaptain + 1
		elseif card.nickname == "RotK Samewise Gamgee, The Hero" then
			tempScoreList[i].samwise = tempScoreList[i].samwise + 1
		elseif card.nickname == "RotK There is Courage Still" then
			tempScoreList[i].thereIsCourageStill = tempScoreList[i].thereIsCourageStill + 1
		elseif card.nickname == "UJ Orc Leader" then
			tempScoreList[i].orcLeader = tempScoreList[i].orcLeader + 1
		elseif card.nickname == "UJ The Contract" then
			tempScoreList[i].theContract = tempScoreList[i].theContract + 1
		elseif card.nickname == "DoS Master of Lake-Town" then
			tempScoreList[i].masterLakeTown = tempScoreList[i].masterLakeTown + 1
		elseif card.nickname == "DoS Re-Lighting the Forge" then
			tempScoreList[i].relightForge = tempScoreList[i].relightForge + 1
		elseif card.nickname == "DoS Corruption (Hoarding)" then
			tempScoreList[i].corruptionHoarding = tempScoreList[i].corruptionHoarding + 1
		elseif card.nickname == "SF Rolento's Baton" then
			tempScoreList[i].rolentosBaton = tempScoreList[i].rolentosBaton + 1
		elseif card.nickname == "SF Akuma's Gi" then
			tempScoreList[i].akumasGi = tempScoreList[i].akumasGi + 1
		elseif card.nickname == "SF Jungle Warrior" then
			tempScoreList[i].jungleWarrior = tempScoreList[i].jungleWarrior + 1
		elseif card.nickname == "NS Asuma" then
			tempScoreList[i].asuma = tempScoreList[i].asuma + 1
		elseif card.nickname == "NS Lightning Blade" then
			tempScoreList[i].lightningBlade = tempScoreList[i].lightningBlade + 1
		elseif card.nickname == "NS Jiraiya" then
			tempScoreList[i].jiraiya = tempScoreList[i].jiraiya + 1
		elseif card.nickname == "NS Ningendo (Path of Pain)" then
			tempScoreList[i].ningendo = tempScoreList[i].ningendo + 1
		elseif card.nickname == "RM1 Rick Sanchez C-137" then
			tempScoreList[i].rm1C137 = tempScoreList[i].rm1C137 + 1
		elseif card.nickname == "RM2 Assemble" then
			tempScoreList[i].assemble = tempScoreList[i].assemble + 1
		elseif card.nickname == "RM2 Rick C-137" then
			tempScoreList[i].rm2C137 = tempScoreList[i].rm2C137 + 1
		elseif card.nickname == "RM2 Szechuan Sauce" then
			tempScoreList[i].szechuan = tempScoreList[i].szechuan + 1
		elseif card.nickname == "EA1 Dragon's Ballz" then
			tempScoreList[i].dragonsBallZ = tempScoreList[i].dragonsBallZ + 1
		elseif card.nickname == "EA1 Huge Boner" then
			tempScoreList[i].hugeBoner = tempScoreList[i].hugeBoner + 1
		elseif card.nickname == "EA2 Dingling Brothers Circus" then
			tempScoreList[i].dCircus = tempScoreList[i].dCircus + 1
		elseif card.nickname == "EA2 Crazy M.I.B: (Man in Box)" then
			tempScoreList[i].crayzMIB = tempScoreList[i].crayzMIB + 1
		elseif card.nickname == "EA2 Viagrus The Hard Lord" then
			tempScoreList[i].viagrus = tempScoreList[i].viagrus + 1
		elseif card.nickname == "EA2 Goldy the Goose" then
			tempScoreList[i].goldygoose = tempScoreList[i].goldygoose + 1
		else
			tempScoreList[i].vp = tempScoreList[i].vp + master.vp
		end
		if master.isStarter == true then
			tempScoreList[i].starters = tempScoreList[i].starters + 1
			if master.isCourage == true then
				tempScoreList[i].courages = tempScoreList[i].courages + 1
			end
			if master.isGWave == true then
				tempScoreList[i].geniusWaves = tempScoreList[i].geniusWaves + 1
			end
			if master.isFizzle == true then
				tempScoreList[i].fizzles = tempScoreList[i].fizzles + 1
			end
			if card.nickname == "EGB Blasting Glyph" then
				tempScoreList[i].bGlyph = tempScoreList[i].bGlyph + 1
			end
		end
		if master.isHero == true then
			tempScoreList[i].heroes = tempScoreList[i].heroes + 1
			if tempScoreList[i].uniqueHeroes[card.nickname] == nil then
				tempScoreList[i].uniqueHeroes[card.nickname] = true
			end
		end
		if master.isAlly == True then
			tempScoreList[i].allies = tempScoreList[i].allies + 1
			if tempScoreList[i].uniqueAllies[card.nickname] == nil then
				tempScoreList[i].uniqueAllies[card.nickname] = true
			end
		end
		if master.isWizard == true then
			tempScoreList[i].wizards = tempScoreList[i].wizards + 1
		end
		if master.isVillain == true then
			tempScoreList[i].villains = tempScoreList[i].villains + 1
			if tempScoreList[i].uniqueVillains[card.nickname] == nil then
				tempScoreList[i].uniqueVillains[card.nickname] = true
			end
		end
		if master.isEnemy == true then
			tempScoreList[i].enemies = tempScoreList[i].enemies + 1
			if tempScoreList[i].uniqueEnemies[card.nickname] == nil then
				tempScoreList[i].uniqueEnemies[card.nickname] = true
			end
		end
		if master.isCreature == true then
			tempScoreList[i].creatures = tempScoreList[i].creatures + 1
		end
		if master.isSuperPower == true then
			tempScoreList[i].superPowers = tempScoreList[i].superPowers + 1
			if tempScoreList[i].uniqueSuperPowers[card.nickname] == nil then
				tempScoreList[i].uniqueSuperPowers[card.nickname] = true
			end
		end
		if master.isManeuver == true then
			tempScoreList[i].maneuvers = tempScoreList[i].maneuvers + 1
			if tempScoreList[i].uniqueManeuvers[card.nickname] == nil then
				tempScoreList[i].uniqueManeuvers[card.nickname] = true
			end
		end
		if master.isSpell == true then
			tempScoreList[i].spells = tempScoreList[i].spells + 1
		end
		if master.isEquipment == true then
			tempScoreList[i].equipment = tempScoreList[i].equipment + 1
		end
		if master.isArtifact == true then
			tempScoreList[i].artifacts = tempScoreList[i].artifacts + 1
		end
		if master.isTreasure == true then
			tempScoreList[i].treasures = tempScoreList[i].treasures + 1
		end
		if master.isLocation == true then
			tempScoreList[i].locations = tempScoreList[i].locations + 1
		end
		if master.isCouncil == true then
			tempScoreList[i].councils = tempScoreList[i].councils + 1
		end
		if master.isBoss == true then
			tempScoreList[i].Boss = tempScoreList[i].Boss + 1
			if master.isEnemy == true then
				tempScoreList[i].archEnemy = tempScoreList[i].archEnemy + 1
			end
		end
		if master.isLoot == true then
			tempScoreList[i].loot = tempScoreList[i].loot + 1
		end
		if master.isLegend == true then
			tempScoreList[i].legends = tempScoreList[i].legends + 1
		end
		if master.isWeakness == true then
			tempScoreList[i].weaknesses = tempScoreList[i].weaknesses + 1
		end
		if master.isMWave == true then
			tempScoreList[i].mortyWaves = tempScoreList[i].mortyWaves + 1
		end
		if master.isLimp == true then
			tempScoreList[i].limp = tempScoreList[i].limp + 1
		end
		if master.isExpPowerRing == true then
			tempScoreList[i].expPowerRings = tempScoreList[i].expPowerRings + 1
		end
		if master.isPowerRing == true then
			tempScoreList[i].powerRings = tempScoreList[i].powerRings + 1
		end
		if master.isMetal == true then
			tempScoreList[i].metals = tempScoreList[i].metals + 1
		end
		if master.isTimeLineUp == true then
			tempScoreList[i].timeLineUps = tempScoreList[i].timeLineUps + 1
		end
		if master.isBribe == true then
 		    tempScoreList[i].bribes = tempScoreList[i].bribes + 1
   		    if tempScoreList[i].uniqueBribes[card.nickname] == nil then
      		         tempScoreList[i].uniqueBribes[card.nickname] = true
    		    end
end
		if master.isPathOfPain == true then
			if tempScoreList[i].uniquePathOfPain[card.nickname] == nil then
				tempScoreList[i].uniquePathOfPain[card.nickname] = true
			end
		end
		if master.isOngoing == true then
			if tempScoreList[i].uniqueOngoings[card.nickname] == nil then
				tempScoreList[i].uniqueOngoings[card.nickname] = true
			end
		end
		if master.isAttack == true then
			if tempScoreList[i].uniqueAttacks[card.nickname] == nil then
				tempScoreList[i].uniqueAttacks[card.nickname] = true
			end
		end
		if master.isDefense == true then
			if tempScoreList[i].uniqueDefenses[card.nickname] == nil then
				tempScoreList[i].uniqueDefenses[card.nickname] = true
			end
		end
		if master.isPositive == true then
			if tempScoreList[i].uniquePosAttacks[card.nickname] == nil then
				tempScoreList[i].uniquePosAttacks[card.nickname] = true
			end
		end
		if master.isChakara == true then
			if master.isTechnique == true or master.isEquipment == true then
				if tempScoreList[i].uniqueChakra1[card.nickname] == nil then
					tempScoreList[i].uniqueChakra1[card.nickname] = true
				end
			elseif master.isAlly == true or master.isEnemy == true or master.isLocation == true then
				if tempScoreList[i].uniqueChakra2[card.nickname] == nil then
					tempScoreList[i].uniqueChakra2[card.nickname] = true
				end
			end
		end
		if master.cost ~= nil then
			if master.cost < 3 then
				if tempScoreList[i].uniqueTwoCostOrLess[card.nickname] == nil then
					tempScoreList[i].uniqueTwoCostOrLess[card.nickname] = true
				end
			end
			if master.cost == 0 then
				tempScoreList[i].zeroCost = tempScoreList[i].zeroCost + 1
			end
			if master.cost < 8 and master.isEnemy == true then
				if tempScoreList[i].uniqueEnemySevenCostOrHigher[card.nickname] == nil then
					tempScoreList[i].uniqueEnemySevenCostOrHigher[card.nickname] = true
				end
			end
			if master.cost >= 7 then
				tempScoreList[i].sevenCostOrHigher =
				tempScoreList[i].sevenCostOrHigher + 1
			end		
		end
		if underCheck == true then
			if tempScoreList[i].uniqueUnderCharacter[card.nickname] == nil then
				tempScoreList[i].uniqueUnderCharacter[card.nickname] = true
			end
			tempScoreList[i].under = tempScoreList[i].under + 1
		end
		tempScoreList[i].cards = tempScoreList[i].cards + 1
	elseif master == nil then
		local name = ""
		local ct = stringColorToRGB(tempScoreList[i].color)
		local colorCall = Global.call("checkIfSeated", tempScoreList[i].color)
		if colorCall == true then
			name = Player[tempScoreList[i].color].steam_name
		else
			name = tempScoreList[i].color
		end
		printToAll(name .. "'s deck contains undefined card: " .. card.nickname, {0.25, 0.25, 0.25})
	end
end
function mergeValues() -- Merging Score Value with VP Bag Value
	for c, values in ipairs(scoreValueList) do
		for b, values in ipairs(vpBagToScoreList) do
			if scoreValueList[c].color == vpBagToScoreList[b].color then
				--EGB DWT 1 = +6 VP if you own 4+ Creatures
				if vpBagToScoreList[b].dwtEGB_1 > 0 then
					if scoreValueList[c].creatures > 3 then
						scoreValueList[c].vp = scoreValueList[c].vp + (6*vpBagToScoreList[b].dwtEGB_1)
						vpBagToScoreList[b].dwt = vpBagToScoreList[b].dwt - 1
					end
				end
				--EGB DWT 4 = -1 VP for each Fizzle you have, also +1 Limp
				if vpBagToScoreList[b].dwtEGB_4 > 0 then
					scoreValueList[c].vp = scoreValueList[c].vp + (-1*scoreValueList[c].fizzles*vpBagToScoreList[b].dwtEGB_4)
					scoreValueList[c].limp = scoreValueList[c].limp + (1*scoreValueList[c].fizzles*vpBagToScoreList[b].dwtEGB_4)
				end
				--EGB DWT 8 = +6 VP if you own 4+ Wizards
				if vpBagToScoreList[b].dwtEGB_8 > 0 then
					if scoreValueList[c].wizards > 3 then
						scoreValueList[c].vp = scoreValueList[c].vp + (6*vpBagToScoreList[b].dwtEGB_8)
						vpBagToScoreList[b].dwt = vpBagToScoreList[b].dwt - 1
					end
				end
				--EGB DWT 9 = +1 VP for each Limp Wand, then Zero Limp Wands
				if vpBagToScoreList[b].dwtEGB_9 > 0 then
					scoreValueList[c].vp = scoreValueList[c].vp + scoreValueList[c].limp
					scoreValueList[c].limp = 0
				end
				--EGB DWT 17 = +6 VP if you own 4+ Spells
				if vpBagToScoreList[b].dwtEGB_17 > 0 then
					if scoreValueList[c].spells > 3 then
						scoreValueList[c].vp = scoreValueList[c].vp + (6*vpBagToScoreList[b].dwtEGB_17)
						vpBagToScoreList[b].dwt = vpBagToScoreList[b].dwt - 1
					end
				end
				--EGB DWT 19 = +6 VP if you own 2+ Locations
				if vpBagToScoreList[b].dwtEGB_19 > 0 then
					if scoreValueList[c].locations > 1 then
						scoreValueList[c].vp = scoreValueList[c].vp + (6*vpBagToScoreList[b].dwtEGB_19)
						vpBagToScoreList[b].dwt = vpBagToScoreList[b].dwt - 1
					end
				end
				scoreValueList[c].vptokens = vpBagToScoreList[b].vptokens
				scoreValueList[c].dwt = vpBagToScoreList[b].dwt
				scoreValueList[c].abilityEA2_8 = vpBagToScoreList[b].abilityEA2_8
				scoreValueList[c].dingler = vpBagToScoreList[b].dingler
				scoreValueList[c].dwtEGB_16 = vpBagToScoreList[b].dwtEGB_16
				scoreValueList[c].dwtEA2_6 = vpBagToScoreList[b].dwtEA2_6
				scoreValueList[c].dwtEA2_11 = vpBagToScoreList[b].dwtEA2_11
				scoreValueList[c].vp = scoreValueList[c].vp + vpBagToScoreList[b].vp
				scoreValueList[c].catwomanCO12 = vpBagToScoreList[b].catwomanCO12
			break
			end
		end
	end
	--Basic comparisons can be done here.
	--Comparing concils amount between players
	local sort_func = function( a,b ) return a.councils > b.councils end
	table.sort(scoreValueList, sort_func)
	--player with most Concils gets 3vp for each Assumble card they have
	if scoreValueList ~= nil then
		if #scoreValueList == 1 or scoreValueList[1].councils > scoreValueList[2].councils then
			scoreValueList[1].vp = scoreValueList[1].vp + (3*scoreValueList[1].assemble)
		end
	end
	--[[ Debug
	for i, v in ipairs(scoreValueList) do
		if scoreValueList[i].vp ~= 0 then
			printToAll("VP: " .. scoreValueList[i].vp, stringColorToRGB(scoreValueList[i].color))
		end
	end
	--]]
end
function addVPforSpecialCards()
	for i, deck in ipairs(scoreValueList) do
        --Add variable VP cards to that player's total VP
        --Bizarro = 2VP for each Weakness
        if scoreValueList[i].bizarro > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (2*scoreValueList[i].weaknesses*scoreValueList[i].bizarro)
			scoreValueList[i].vp = scoreValueList[i].vp + scoreValueList[i].shapeShift
        end
        --Green Arrow = 5VP if you have more than four Heroes
        if scoreValueList[i].greenArrow > 0 then
            if scoreValueList[i].heroes > 4 then
                scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].greenArrow)
            end
        end
        --Suicide Squad, DCDB Shapeshift
        if scoreValueList[i].countOfSuicideSquads > 0 then
            if scoreValueList[i].shapeShift > 0 then
                scoreValueList[i].vp = scoreValueList[i].vp + scoreValueList[i].countOfSuicideSquads * scoreValueList[i].shapeShift
            end
        end
		--Utility Belt = 5VP if you have more than four Equipment
        if scoreValueList[i].utilityBelt > 0 then
            if scoreValueList[i].equipment > 4 then
                scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].utilityBelt)
            end
        end
        --Saint Walker = 1VP for each unique Hero
        if scoreValueList[i].saintWalker > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueHeroes) do
                c=c+1
            end
			c = c + scoreValueList[i].shapeShift
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].saintWalker)
        end
        --Sciencell = 1VP for each unique Villain
        if scoreValueList[i].sciencell > 0 then
            local c=0
            for a, b in pairs(scoreValueList[i].uniqueVillains) do
                c=c+1
            end
			c = c + scoreValueList[i].shapeShift
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].sciencell)
        end
        --Larfleeze = 1VP for every 7 cards
        if scoreValueList[i].larfleeze > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (math.floor(scoreValueList[i].cards/7)*scoreValueList[i].larfleeze)
        end
        --Power Rings = 1VP for each other Power Ring. Rings that have variable VP counted in expPowerRings. Ones that do not are counted in powerRings and their VP was already added to total when cycling through the deck
        if scoreValueList[i].expPowerRings > 0 then
            local c = scoreValueList[i].expPowerRings * (scoreValueList[i].expPowerRings + scoreValueList[i].powerRings)
            scoreValueList[i].vp = scoreValueList[i].vp + c
        end
        --Phantom Stranger = 10VP minus 1 for each card with cost 0 (min 0)
        if scoreValueList[i].phantomStranger > 0 then
            local c = (10-scoreValueList[i].zeroCost)
            if c > 0 then
                scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].phantomStranger)
            end
        end
        --Deathstorm = 10VP minus 1 for each card over 20 cards total (min 0)
        if scoreValueList[i].deathstorm > 0 then
            if scoreValueList[i].cards > 20 then
                local c = scoreValueList[i].cards - 20
                if c < 10 then
                    scoreValueList[i].vp = scoreValueList[i].vp + ((10 - c)*scoreValueList[i].deathstorm)
                end
            else
                scoreValueList[i].vp = scoreValueList[i].vp + (10*scoreValueList[i].deathstorm)
            end
        end
        --Dick Grayson = 1VP for each unique Ongoing card
        if scoreValueList[i].dickGrayson > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueOngoings) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].dickGrayson)
        end
        --T-Wing = 1VP for each unique card with cost 2 or less
        if scoreValueList[i].tWing > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueTwoCostOrLess) do
                c=c+1
            end
			c = c + scoreValueList[i].shapeShift
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].tWing)
        end
        --Carter Hall's Journal = 5VP if you have more than four Metal Cards
        if scoreValueList[i].carterHall > 0 then
            if scoreValueList[i].metals > 4 then
                scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].carterHall)
            end
        end
        --Element X = 10VP minus 1 for each Weakness
        if scoreValueList[i].elementX > 0 then
            local c = (10-scoreValueList[i].weaknesses)
            if c > 0 then
                scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].elementX)
            end
        end
		--Solomon Grundy = 1VP for each Starter
        if scoreValueList[i].solomonGrundy > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (scoreValueList[i].starters*scoreValueList[i].solomonGrundy)
        end
		--Moria Queen = 1Vp for each unique Card under Character
		if scoreValueList[i].moriaQueen > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueUnderCharacter) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].moriaQueen)
        end
		--Highfather = +3VP if your homeworld was defeated
		if scoreValueList[i].highFather > 0 then
			scoreValueList[i].vp = scoreValueList[i].vp + (3*scoreValueList[i].highFather)
        end
        --Traverse Timelines = 2VP for each TimeLine-Up card
        if scoreValueList[i].traverseTimelines > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (2*scoreValueList[i].timeLineUps*scoreValueList[i].traverseTimelines)
        end
        --Black Mask = 1VP for each Bribe
        if scoreValueList[i].expBribes > 0 then
             local c = 0
             for _, _ in pairs(scoreValueList[i].uniqueBribes) do
        	     c = c + 1
             end
             scoreValueList[i].vp = scoreValueList[i].vp + (c * scoreValueList[i].expBribes)
       end
		-- CO12 Catwoman = 1VP for each card with cost 7 or greater
		if scoreValueList[i].catwomanCO12 > 0 then
			scoreValueList[i].vp =
				scoreValueList[i].vp +
				(scoreValueList[i].sevenCostOrHigher *
				 scoreValueList[i].catwomanCO12)
		end        
        --Strider the Ranger = 5VP if you have more than Five Allies
        if scoreValueList[i].striderRanger > 0 then
            if scoreValueList[i].allies > 5 then
                scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].striderRanger)
            end
        end
        --Moria Orc Captain = 5VP if you have more than Three Moria Orcs
        if scoreValueList[i].moriaOrcCaptain > 0 then
            if scoreValueList[i].moriaOrcs > 2 then
                scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].moriaOrcCaptain)
            end
        end
		--Moria Orcs Add 1 VP foreach
		if scoreValueList[i].moriaOrcs > 0 then
		scoreValueList[i].vp = scoreValueList[i].vp + scoreValueList[i].moriaOrcs
        end
        --Elven Brooch = 5VP if you have more than Five Artifacts
        if scoreValueList[i].elvenBrooch > 0 then
            if scoreValueList[i].artifacts > 5 then
                scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].elvenBrooch)
            end
        end
        --Sting = 5VP if you have more than Five Enemies
        if scoreValueList[i].sting > 0 then
            if scoreValueList[i].enemies > 4 then
                scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].sting)
            end
        end
        --Battlements of the Wall = 5VP if Wall Deck Equal or Greater then Player Count
		if scoreValueList[i].battlementsWall > 0 then
			local z = Global.getTable("zTable")
			local gameEndWall = z.zOther2.getObjects()
			local wallCount = 0
			local numberofPlayers = #getSeatedPlayers()
			for k,v in pairs (gameEndWall) do -- Loop Start for Objects found
				if v.type  == "Deck" then -- if type ged as a Deck
				wallCount = v.getQuantity()
				elseif v.type  == "Card" then
				wallCount = 1
				end
			end
			if wallCount >= numberofPlayers then
				scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].battlementsWall)
			end
		end
		--Dead Marshes = 5VP if you have 5 or more Cards Under
		if scoreValueList[i].deadMarshes > 0 then
			local dp = Global.getTable("destroyPileZone")
			local udm = dp.udmZone.getObjects()
			local udmc=0
			for k,v in pairs (udm) do -- Loop Start for Objects found
				if v.type  == "Deck" then -- if type ged as a Deck
				udmc = v.getQuantity()
				elseif v.type  == "Card" then
				udmc = 1
				end
			end
			if udmc > 4 then
				scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].deadMarshes)
			end
		end
		--Warg Riders = 5VP if you have more than Five Unique Maneuvers
        if scoreValueList[i].wargRiders > 0 then
			local c=0
			for m, v in pairs(scoreValueList[i].uniqueManeuvers) do
			c=c+1
			end
			if c > 4 then
				scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].wargRiders)
			end
        end
		--Gimli Elf-Friend = 1VP for each unique Enemy over 7 cost
        if scoreValueList[i].gimliElfFriend > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueEnemySevenCostOrHigher) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].gimliElfFriend)
        end
        --Legolas Dwarf-Friend = 1VP for each Arch Enemy
        if scoreValueList[i].legolasDwarfFriend > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (scoreValueList[i].archEnemy*scoreValueList[i].legolasDwarfFriend)
        end
		--Oliphant Captain = 1VP for each unique Ally
		if scoreValueList[i].oliphantCaptain > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueAllies) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].oliphantCaptain)
        end
		--Samewise Gamgee, The Hero = 3VP if player has One Ring in token bag
		if scoreValueList[i].samwise > 0 then
			if scoreCompareList.ringRK == true then
				scoreValueList[i].vp = scoreValueList[i].vp + (3*scoreValueList[i].samwise)
			end
        end
        --There is Courage Still = 1VP for every 2 Courages
        if scoreValueList[i].thereIsCourageStill > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (math.floor(scoreValueList[i].courages/2)*scoreValueList[i].thereIsCourageStill)
        end
        --Orc Leader = 5 VP if you have 6 Enemy
        if scoreValueList[i].orcLeader > 0 then
            if scoreValueList[i].enemies > 5 then
                scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].orcLeader)
            end
		end
        --The Contract = 5 VP if you have 5 different Ally
        if scoreValueList[i].theContract > 0 then
			local c=0
			for m, v in pairs(scoreValueList[i].uniqueAllies) do
			c=c+1
			end
			if c > 4 then
				scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].theContract)
			end
        end
        --Master of Lake-Town = 5VP if you have 5 or more cards Under Character
		if scoreValueList[i].masterLakeTown > 0 then
			if scoreValueList[i].under > 4 then
				scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].masterLakeTown)
			end
        end
        --Re-Lighting the Forge = 1Vp for each Card under Character
		if scoreValueList[i].relightForge > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (scoreValueList[i].under*scoreValueList[i].relightForge)
        end
        --DoS Corruption Stack = -1Vp for each Loot Card
        if scoreValueList[i].corruptionHoarding > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (-1*scoreValueList[i].loot*scoreValueList[i].corruptionHoarding)
        end
        --Rolento's Baton = 1VP for each unique Defense
        if scoreValueList[i].rolentosBaton > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueDefenses) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].rolentosBaton)
        end
        --Akuma's Gi = 1VP for each unique Attack
        if scoreValueList[i].akumasGi > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueAttacks) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].akumasGi)
        end
        --Jungle Warrior = 5VP if you have more than five Super Powers
        if scoreValueList[i].jungleWarrior > 0 then
			local c=0
			for m, v in pairs(scoreValueList[i].uniqueSuperPowers) do
			c=c+1
			end
			if c > 4 then
				scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].jungleWarrior)
			end
        end
        --Asuma = 1VP for each unique Positive Attack
        if scoreValueList[i].asuma > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniquePosAttacks) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].asuma)
        end
        --Lightning Blade = 1VP for each unique Technique and Equipment with a Chakra Ability
        if scoreValueList[i].lightningBlade > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueChakra1) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].lightningBlade)
        end
        --Jiraiya = 1VP for each unique Ally, Enemy, and Location with a Chakra Ability
        if scoreValueList[i].jiraiya > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniqueChakra2) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].jiraiya)
        end
        --Ningendo = 1VP for each different Path of Pain
        if scoreValueList[i].ningendo > 0 then
            local c=0
            for m, v in pairs(scoreValueList[i].uniquePathOfPain) do
                c=c+1
            end
            scoreValueList[i].vp = scoreValueList[i].vp + (c*scoreValueList[i].ningendo)
        end
		--Add 2 VP for each Morty Waves a player has, if player has RM1 Rick Sanchez C-137
        if scoreValueList[i].rm1C137 > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + 2*scoreValueList[i].mortyWaves
        end
		--Add 1 VP for each Genius Waves a player has, if player has RM2 Rick Sanchez C-137
        if scoreValueList[i].rm2C137 > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + 1*scoreValueList[i].geniusWaves
        end
        --Negate VP penalty of Morty Waves for every Genius Waves the player has in their deck
        if scoreValueList[i].mortyWaves > 0 and scoreValueList[i].geniusWaves > 0 then
            if scoreValueList[i].mortyWaves >= scoreValueList[i].geniusWaves then
                scoreValueList[i].vp = scoreValueList[i].vp + scoreValueList[i].geniusWaves
            else
                scoreValueList[i].vp = scoreValueList[i].vp + scoreValueList[i].mortyWaves
            end
        end
        --Szechuan Sauce = 1VP for each Location
        if scoreValueList[i].szechuan > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (scoreValueList[i].locations*scoreValueList[i].szechuan)
        end
        --Huge Boner = 1VP for each Dead Wizard Token
        if scoreValueList[i].hugeBoner > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (scoreValueList[i].dwt*scoreValueList[i].hugeBoner)
        end
        --Dragon's Ball Z = 5VP for each Creature
        if scoreValueList[i].dragonsBallZ > 1 then
            scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].dragonsBallZ)
        end
        --EGB DWT 13 = -4VP for each Blasting Glyph
        if scoreValueList[i].dwtEGB_16 > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (-4*scoreValueList[i].bGlyph*scoreValueList[i].dwtEGB_16)
        end
        --EA2 Ability 8 = 1VP for each Treasure
        if scoreValueList[i].abilityEA2_8 > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (1*scoreValueList[i].treasures*scoreValueList[i].abilityEA2_8)
        end
        --EA2 DWT 11 = -1 vp for each Limp wand
        if scoreValueList[i].dwtEA2_11 > 0 then
			scoreValueList[i].vp = scoreValueList[i].vp + (-1*2^scoreValueList[i].dwtEA2_11*scoreValueList[i].limp) + (1*scoreValueList[i].limp)
        end
		--Crazy MIB = 1VP for each Creature
        if scoreValueList[i].crayzMIB > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (1*scoreValueList[i].creatures*scoreValueList[i].crayzMIB)
        end
		--Dingling Brothers Circus = 10 VP for each Dingler
		if scoreValueList[i].dCircus > 0 then
			scoreValueList[i].vp = scoreValueList[i].vp + (2*scoreValueList[i].dCircus)
			if scoreValueList[i].dwtEA2_6 > 0 then
				scoreValueList[i].vp = scoreValueList[i].vp + (10*2^scoreValueList[i].dwtEA2_6*scoreValueList[i].dingler) + (5*scoreValueList[i].limp)
			elseif scoreValueList[i].dwtEA2_6 == 0 then
				scoreValueList[i].vp = scoreValueList[i].vp + (10*scoreValueList[i].dingler)
			end
		end
        --Viagrus The Hard Lord = 2VP for each Limp Wand
        if scoreValueList[i].viagrus > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (5*scoreValueList[i].viagrus)
			if scoreValueList[i].dwtEA2_11 > 0 then
				scoreValueList[i].vp = scoreValueList[i].vp + (2*2^scoreValueList[i].dwtEA2_11*scoreValueList[i].limp) + (1*scoreValueList[i].limp)
			elseif scoreValueList[i].dwtEA2_11 == 0 then
				scoreValueList[i].vp = scoreValueList[i].vp + (2*scoreValueList[i].limp*scoreValueList[i].viagrus)
			end
        end
        --Goldy The Goose = 2VP for each Legend
        if scoreValueList[i].goldygoose > 0 then
            scoreValueList[i].vp = scoreValueList[i].vp + (2*scoreValueList[i].legends*scoreValueList[i].goldygoose)
        end
	end
	--scoreValueList = { {vp=#, Boss=#, color="ColorName"}, {etc etc}, etc etc}
	for i, deck in pairs(scoreValueList) do
		deck.counter.Counter.setValue(deck.vp)
	end
	--[[ Debug
	for i, v in ipairs(scoreValueList) do
		if scoreValueList[i].vp ~= 0 then
			printToAll("VP: " .. scoreValueList[i].vp, stringColorToRGB(scoreValueList[i].color))
		end
	end
	--]]
end
function findWinner()
    --Sort by vp
    local sort_func = function( a,b ) return a.vp > b.vp end
    table.sort( scoreValueList, sort_func )
    if #scoreValueList == 0 then
        --Error handling for someone pressing the button early
        printToAll("No decks found. Place decks on the scoring area and try again.")
        --Play No Decks Sound
        --playMusic(noDecksFoundSound)
        --Exit Function
		Global.setVar("report2v2", 0)
        return
    end

	if #scoreValueList == 1 or scoreValueList[1].vp > scoreValueList[2].vp then
		--Winner is scoreValueList[1].color
		local name = ""
		if Global.call("checkIfSeated", scoreValueList[1].color) == true then
			name = Player[scoreValueList[1].color].steam_name
		else
			name = scoreValueList[1].color
		end
		printToAll("With a total of " .. scoreValueList[1].vp .. " VP, " .. name .. " is the Winner!", stringColorToRGB(scoreValueList[1].color))
	else
		--Make a new table with only tied VP players
		tieListBoss = {}
		for i=1, #scoreValueList do
			if scoreValueList[1].vp == scoreValueList[i].vp then
				table.insert(tieListBoss, scoreValueList[i])
			end
		end
		--Print tie, VP
		local nameString = ""
		for i=1, #tieListBoss do
			local name = ""
			Global.call("checkIfSeated", scoreValueList[i].color)
			if Global.call("checkIfSeated", scoreValueList[i].color) == true then
					name = Player[tieListBoss[i].color].steam_name
			else
				name = tieListBoss[i].color
			end
			if nameString ~= "" then nameString = nameString .. "," end
			nameString = nameString .. " " .. name
		end
		printToAll(nameString .. " were tied with " .. tostring(tieListBoss[1].vp) .. " VP.", {1,1,1})
		--Sorts them by Boss
		local sort_func = function( a,b ) return a.Boss > b.Boss end
		table.sort( tieListBoss, sort_func )
		if tieListBoss[1].Boss > tieListBoss[2].Boss then
			--Tie Breaker Rule 1
			local name = ""
			if Global.call("checkIfSeated", scoreValueList[1].color) == true then
				name = Player[tieListBoss[1].color].steam_name
			else
				name = tieListBoss[1].color
			end
			printToAll("With a total of " .. tieListBoss[1].Boss .. " Bosses, " .. name .. " is the Winner!", stringColorToRGB(tieListBoss[1].color))
		else
			--Make a new table with only tied Bosses players
			tieListCards = {}
			for i=1, #tieListBoss do
				if tieListBoss[1].Boss == tieListBoss[i].Boss then
					table.insert(tieListCards, tieListBoss[i])
				end
			end
			--print tie, Boss
			local nameString = ""
			for i=1, #tieListCards do
				local name = ""
				if Global.call("checkIfSeated", scoreValueList[i].color) == true then
					name = Player[tieListCards[i].color].steam_name
				else
					name = tieListCards[i].color
				end
				if nameString ~= "" then nameString = nameString .. "," end
				nameString = nameString .. " " .. name
			end
			printToAll(nameString .. " were tied with " .. tostring(tieListCards[1].Boss) .. " Bosses.", {1,1,1})
			--Sorts them by number of cards
			local sort_func = function( a,b ) return a.cards > b.cards end
			table.sort( tieListCards, sort_func )
			if tieListCards[1].cards > tieListCards[2].cards then
				--Tie Breaker Rule 2
				local name = ""
				if Global.call("checkIfSeated", scoreValueList[1].color) == true then
					name = Player[tieListCards[1].color].steam_name
				else
					name = tieListCards[1].color
				end
				if Global.getVar("dcdbCubeGame") == 1 then
					printToAll("The player among them with the most recently defeated SV wins the game.")
				else
					printToAll("With more total Cards " .. tieListCards[1].cards .. ", " .. name .. " is the Winner!", stringColorToRGB(tieListBoss[1].color))
				end
			else
				--Tie Breaker Rule 3
				if Global.getVar("dcdbCubeGame") == 1 then
					printToAll("The player who played last in turn order wins the tiebreaker(s).")
				else
					printToAll("Same number of cards... That's it. I'm done breaking ties. Better play again to find a winner, or whatever.", {1,1,1})
				end
			end
		end
	end
end

function clearVPBags() -- Clears VP Bags of all Objects
	for i, v in ipairs(scoreRequiredTable) do
		v.bag.reset()
	end
end
function clearCounters()
	for i, zone in pairs(scoreRequiredTable) do
		zone.counter.Counter.clear()
	end
end
function removeScoreCardHighlights() -- Remove Highlights on Note Cards & Counters
	local scoreCardToHighlight = {
		["Green"] = getObjectFromGUID('fb723d'),
		["Red"] = getObjectFromGUID('541aa3'),
		["Yellow"] = getObjectFromGUID('8e61c6'),
		["White"] = getObjectFromGUID('a86144'),
		["Brown"] = getObjectFromGUID('a2a035'),
		["Purple"] = getObjectFromGUID('b89a69'),
		["Orange"] = getObjectFromGUID('ff81fb'),
		["Pink"] = getObjectFromGUID('d63896'),
	}
	local scoreCounterToHighlight = {
		["Green"] = getObjectFromGUID('21766f'),
		["Red"] = getObjectFromGUID('89c010'),
		["Yellow"] = getObjectFromGUID('41a702'),
		["White"] = getObjectFromGUID('b83860'),
		["Brown"] = getObjectFromGUID('39b9b3'),
		["Purple"] = getObjectFromGUID('8c4005'),
		["Orange"] = getObjectFromGUID('dd973a'),
		["Pink"] = getObjectFromGUID('ab805f'),
	}
	for i, v in pairs(scoreCardToHighlight) do
		v.highlightOff()
	end
	for i, v in pairs(scoreCardToHighlight) do
		v.highlightOff()
	end
end
--[[
    --Highlight 1st Place Counter In Gold
    if playerObjects[1] ~= nil then
        scoreCardToHighlight = nil
        if playerObjects[1].playerColor == "White" then
            scoreCardToHighlight = getObjectFromGUID('a86144')
            scoreCounterToHighlight = getObjectFromGUID('b83860')
        elseif playerObjects[1].playerColor == "Red" then
            scoreCardToHighlight = getObjectFromGUID('541aa3')
            scoreCounterToHighlight = getObjectFromGUID('89c010')
        elseif playerObjects[1].playerColor == "Green" then
            scoreCardToHighlight = getObjectFromGUID('fb723d')
            scoreCounterToHighlight = getObjectFromGUID('21766f')
        elseif playerObjects[1].playerColor == "Yellow" then
            scoreCardToHighlight = getObjectFromGUID('8e61c6')
            scoreCounterToHighlight = getObjectFromGUID('41a702')
        end
        scoreCardToHighlight.highlightOn({0.83,0.69,0.22})
        scoreCounterToHighlight.highlightOn({0.83,0.69,0.22})
    end
    --Highlight 2nd Place Counter In Silver
    if playerObjects[2] ~= nil then
        scoreCardToHighlight = nil
        if playerObjects[2].playerColor == "White" then
            scoreCardToHighlight = getObjectFromGUID('a86144')
            scoreCounterToHighlight = getObjectFromGUID('b83860')
        elseif playerObjects[2].playerColor == "Red" then
            scoreCardToHighlight = getObjectFromGUID('541aa3')
            scoreCounterToHighlight = getObjectFromGUID('89c010')
        elseif playerObjects[2].playerColor == "Green" then
            scoreCardToHighlight = getObjectFromGUID('fb723d')
            scoreCounterToHighlight = getObjectFromGUID('21766f')
        elseif playerObjects[2].playerColor == "Yellow" then
            scoreCardToHighlight = getObjectFromGUID('8e61c6')
            scoreCounterToHighlight = getObjectFromGUID('41a702')
        end
        scoreCardToHighlight.highlightOn({0.75,0.75,0.75})
        scoreCounterToHighlight.highlightOn({0.75,0.75,0.75})
    end




--]]

masterTokenTable = {
	["VP Token"] = {vp=1,},
	["KO'd Token"] = {vp=-3,},
	["RotK The One Ring"] = {vp=5,},
	--CO12 Hush
	["CO12 Catwoman"] = {vp=0},
	--EA1
	["EA1 Dead Wizard Token 1"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 2"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 3"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 4"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 5"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 6"] = {vp=-7, isDWT=true,},
	["EA1 Dead Wizard Token 7"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 8"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 9"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 10"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 11"] = {vp=-5, isDWT=true,},
	["EA1 Dead Wizard Token 12"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 13"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 14"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 15"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 16"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 17"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 18"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 19"] = {vp=-3, isDWT=true,},
	["EA1 Dead Wizard Token 20"] = {vp=-3, isDWT=true,},
	--EGB
	["EGB Dead Wizard Token 1"] = {vp=-6, isDWT=true,}, -- -1 DWT 6 vp if you own +4 creatures
	["EGB Dead Wizard Token 2"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 3"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 4"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 5"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 6"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 7"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 8"] = {vp=-6, isDWT=true,}, -- -1 DWT & 6 vp if you own +4 wizards
	["EGB Dead Wizard Token 9"] = {vp=-3, isDWT=true,}, -- destroy each of your limp wands
	["EGB Dead Wizard Token 10"] = {vp=-3, isDWT=true,}, -- -1 DWT & 3 vp if other player owns dwt20
	["EGB Dead Wizard Token 11"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 12"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 13"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 14"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 15"] = {vp=-9, isDWT=true,},
	["EGB Dead Wizard Token 16"] = {vp=-3, isDWT=true,}, -- Blasting Glyph is -4 VP each
	["EGB Dead Wizard Token 17"] = {vp=-6, isDWT=true,}, -- -1 DWT & 6 vp if you own +4 Spells
	["EGB Dead Wizard Token 18"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 19"] = {vp=-6, isDWT=true,}, -- -1 DWT & 6 vp if you own +2 Locations
	["EGB Dead Wizard Token 20"] = {vp=-3, isDWT=true,}, -- -1 DWT & 3 vp if other player owns dwt10
	["EGB Dead Wizard Token 21"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 22"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 23"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 24"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 25"] = {vp=-6, isDWT=true,},
	["EGB Dead Wizard Token 26"] = {vp=-6, isDWT=true,},
	["EGB Dead Wizard Token 27"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 28"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 29"] = {vp=-3, isDWT=true,},
	["EGB Dead Wizard Token 30"] = {vp=-3, isDWT=true,},
	--EA2
	["EA2 Ability 8"] = {vp=-0,},
	["EA2 Dead Wizard Token 1"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 2"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 3"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 4"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 5"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 6"] = {vp=-3, isDWT=true,}, -- Dingler VP penalty is double
	["EA2 Dead Wizard Token 7"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 8"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 9"] = {vp=-7, isDWT=true,},
	["EA2 Dead Wizard Token 10"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 11"] = {vp=-3, isDWT=true,}, -- Limp Wands VP penalty is double
	["EA2 Dead Wizard Token 12"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 13"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 14"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 15"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 16"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 17"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 18"] = {vp=-6, isDWT=true,},
	["EA2 Dead Wizard Token 19"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 20"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 21"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 22"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 23"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 24"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 25"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 26"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 27"] = {vp=-8, isDWT=true,}, -- -1 DWT & 8 vp if other player owns dwt30
	["EA2 Dead Wizard Token 28"] = {vp=-3, isDWT=true,},
	["EA2 Dead Wizard Token 29"] = {vp=-8, isDWT=true,},
	["EA2 Dead Wizard Token 30"] = {vp=-8, isDWT=true,}, -- -1 DWT & 8 vp if other player owns dwt27
	["You're a Dingler!"] = {vp=-5,},
}
masterCardTable = {
	--[[
	Template
	["name"] = {vp=0 isBlank=true, cost=0, id=0},
	]]

	--1)1) Base Set
	--Other
	["DC Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["DC Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["DC Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Heroes
	["DC Blue Beetle"] = {vp=2, isHero=true, isDefense=true, cost=6, id=7732},
	["DC Catwoman"] = {vp=1, isHero=true, cost=2, id=6374},
	["DC Dark Knight"] = {vp=1, isHero=true, cost=5, id=9827},
	["DC Emerald Knight"] = {vp=1, isHero=true, cost=5, id=7193},
	["DC Green Arrow"] = {vp=0, isHero=true, cost=5, id=3364},
	["DC High-Tech Hero"] = {vp=1, isHero=true, cost=3, id=6872},
	["DC Jo'nn J'onzz"] = {vp=2, isHero=true, cost=6, id=1422},
	["DC Kid Flash"] = {vp=1, isHero=true, cost=2, id=9932},
	["DC King of Atlantis"] = {vp=1, isHero=true, cost=5, id=8046},
	["DC Man of Steel"] = {vp=3, isHero=true, cost=8, id=1576},
	["DC Mera"] = {vp=1, isHero=true, cost=3, id=4356},
	["DC Princess Diana of Themyscira"] = {vp=2, isHero=true, cost=7, id=5578},
	["DC Robin"] = {vp=1, isHero=true, cost=3, id=1677},
	["DC Supergirl"] = {vp=1, isHero=true, cost=4, id=8545},
	["DC Swamp Thing"] = {vp=1, isHero=true, cost=4, id=5979},
	["DC The Fastest Man Alive"] = {vp=1, isHero=true, cost=5, id=6015},
	["DC Zatanna Zatara"] = {vp=1, isHero=true, cost=4, id=6912}, 
	--Villains
	["DC Bane"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=5050},
	["DC Bizarro"] = {vp=0, isVillain=true, cost=7, id=7156},
	["DC Cheetah"] = {vp=1, isVillain=true, cost=2, id=3447},
	["DC Clayface"] = {vp=1, isVillain=true, cost=4, id=7401},
	["DC Doomsday"] = {vp=2, isVillain=true, cost=6, id=6855},
	["DC Gorilla Grodd"] = {vp=2, isVillain=true, cost=5, id=5629},
	["DC Harley Quinn"] = {vp=1, isVillain=true, isAttack=true, cost=2, id=7217},
	["DC Lobo"] = {vp=2, isVillain=true, cost=7, id=5005},
	["DC Poison Ivy"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=9583},
	["DC Scarecrow"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=8397},
	["DC Solomon Grundy"] = {vp=2, isVillain=true, cost=6, id=6070},
	["DC Starro"] = {vp=2, isVillain=true, isAttack=true, cost=7, id=7330},
	["DC Suicide Squad"] = {vp=0, isVillain=true, cost=4, id=9516},
	["DC The Penguin"] = {vp=1, isVillain=true, cost=3, id=4397},
	["DC The Riddler"] = {vp=1, isVillain=true, cost=3, id=1723},
	["DC Two-Face"] = {vp=1, isVillain=true, cost=2, id=1319},
	--Super Powers
	["DC Bulletproof"] = {vp=1, isSuperPower=true, isDefense=true, cost=4, id=4830},
	["DC Heat Vision"] = {vp=2, isSuperPower=true, cost=6, id=9007},
	["DC Kick"] = {vp=1, isSuperPower=true, cost=3, id=9883},
	["DC Super Speed"] = {vp=1, isSuperPower=true, isDefense=true, cost=3, id=4007},
	["DC Super Strength"] = {vp=2, isSuperPower=true, cost=7, id=5698},
	["DC X-Ray Vision"] = {vp=1, isSuperPower=true, cost=3, id=1785},
	--Equipment
	["DC Aquaman's Trident"] = {vp=1, isEquipment=true, cost=3, id=8914},
	["DC Batmobile"] = {vp=1, isEquipment=true, cost=2, id=1001},
	["DC Green Arrow's Bow"] = {vp=1, isEquipment=true, cost=4, id=4803},
	["DC Lasso of Truth"] = {vp=1, isEquipment=true, isDefense=true, cost=2, id=9914},
	["DC Nth Metal"] = {vp=1, isEquipment=true, cost=3, id=1120},
	["DC Power Ring"] = {vp=1, isEquipment=true, isPowerRing=true, cost=3, id=1737},
	["DC The Bat Signal"] = {vp=1, isEquipment=true, cost=5, id=3877},
	["DC The Cape and Cowl"] = {vp=1, isEquipment=true, isDefense=true, cost=4, id=4439},
	["DC Utility Belt"] = {vp=0, isEquipment=true, cost=5, id=7618},
	--Locations
	["DC Arkham Asylum"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=7037},
    	["MARVEL Ravencroft Institute"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=7037},
        ["MARVEL Instituto Ravencroft"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=7037},
	["DC Fortress of Solitude"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=9435},
	["DC The Batcave"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=5956},
	["DC The Watchtower"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=1617},
    	["MARVEL Avenger's Mansion"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=1617},
        ["MARVEL Mansão dos Vingadores"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=1617},
	["DC Titans Tower"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=8226},
	--Super Villains
	["DC Atrocitus"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=6446},
	["DC Black Manta"] = {vp=4, isVillain=true, isBoss=true, cost=8, id=6162},
	["DC Brainiac"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=4193},
	["DC Captain Cold"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=9162},
	["DC Darkseid"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=6880},
	["DC Deathstroke"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=5640},
	["DC Lex Luthor"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=6926},
	["DC Parallax"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=5470},
	["DC Ra's Al Ghul"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=8, id=8938},
	["DC Sinestro"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=1822},
	["DC The Anti-Monitor"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=4289},
	["DC The Joker"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=7717},
	--Oversized Character Cards
	["DC Aquaman"] = {vp=0, isCharacter=true, id=3422},
	["DC Batman"] = {vp=0, isCharacter=true, id=2144},
	["DC Cyborg"] = {vp=0, isCharacter=true, id=8350},
	["DC Green Lantern"] = {vp=0, isCharacter=true, id=5394},
	["DC Martian Manhunter"] = {vp=0, isCharacter=true, id=4366},
	["DC Superman"] = {vp=0, isCharacter=true, id=1930},
	["DC The Flash"] = {vp=0, isCharacter=true, id=5652},
	["DC Wonder Woman"] = {vp=0, isCharacter=true, id=7168},
	--1)2) Heroes United
	--Other
	["HU Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["HU Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["HU Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Heroes
	["HU Crimson Whirlwind"] = {vp=1, isHero=true, cost=5, id=7416},
	["HU Daughter of Gotham City"] = {vp=1, isHero=true, cost=3, id=9385},
	["HU Deadman"] = {vp=1, isHero=true, cost=4, id=3860},
	["HU Hawkgirl"] = {vp=1, isHero=true, cost=2, id=8164},
	["HU Hero of the Future"] = {vp=1, isHero=true, cost=4, id=6186},
	["HU Jason Blood"] = {vp=2, isHero=true, cost=7, id=8571},
	["HU Katana"] = {vp=1, isHero=true, isDefense=true, cost=2, id=6046},
	["HU Kyle Rayner"] = {vp=2, isHero=true, cost=7, id=7644},
	["HU Plastic Man"] = {vp=1, isHero=true, cost=3, id=5848},
	["HU Raven"] = {vp=1, isHero=true, cost=3, id=8883},
	["HU Saint Walker"] = {vp=0, isHero=true, cost=5, id=6008},
	["HU Sonic Siren"] = {vp=1, isHero=true, cost=4, id=7379},
	["HU Superboy"] = {vp=1, isHero=true, cost=5, id=4835},
	["HU Warrior Princess"] = {vp=2, isHero=true, cost=6, id=7102},
	["HU Winged Warrior"] = {vp=2, isHero=true, cost=6, id=7091},
	["HU Wonder of the Knight"] = {vp=1, isHero=true, cost=5, id=6934},
	["HU World's Mightiest Mortal"] = {vp=3, isHero=true, cost=8, id=3911},
	--Villains
	["HU Black Lantern Corps"] = {vp=2, isVillain=true, cost=6, id=6754},
	["HU Brother Blood"] = {vp=2, isVillain=true, cost=6, id=4041},
	["HU Deadshot"] = {vp=1, isVillain=true, isAttack=true, cost=2, id=1413},
	["HU Dr. Sivana"] = {vp=1, isVillain=true, cost=4, id=7593},
	["HU Granny Goodness"] = {vp=1, isVillain=true, cost=5, id=6943},
	["HU Jervis Tetch"] = {vp=1, isVillain=true, cost=3, id=4199},
	["HU Killer Croc"] = {vp=1, isVillain=true, cost=4, id=1260},
	["HU Larfleeze"] = {vp=0, isVillain=true, cost=7, id=1358},
	["HU Manhunter"] = {vp=1, isVillain=true, cost=3, id=1578},
	["HU Mr. Zsasz"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=7807},
	["HU Ocean Master"] = {vp=1, isVillain=true, cost=2, id=1336},
	["HU Parasite"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=3480},
	["HU Red Lantern Corps"] = {vp=1, isVillain=true, cost=5, id=8161},
	["HU Talon"] = {vp=1, isVillain=true, cost=1, id=1008},
	["HU The Demon Etrigan"] = {vp=2, isVillain=true, cost=7, id=1278},
	--Super Powers
	["HU Canary Cry"] = {vp=1, isSuperPower=true, isDefense=true, cost=4, id=1443},
	["HU Force Field"] = {vp=1, isSuperPower=true, isDefense=true, isOngoing=true, cost=3, id=1757},
	["HU Kick"] = {vp=1, isSuperPower=true, cost=3, id=9883},
	["HU Power of The Green"] = {vp=1, isSuperPower=true, cost=3, id=9273},
	["HU Shazam!"] = {vp=2, isSuperPower=true, cost=7, id=8004},
	["HU Starbolt"] = {vp=1, isSuperPower=true, cost=5, id=4595},
	["HU Teleportation"] = {vp=1, isSuperPower=true, cost=7, id=5847},
	["HU Whirlwind"] = {vp=1, isSuperPower=true, cost=2, id=3450},
	--Equipment
	["HU Batarang"] = {vp=1, isEquipment=true, cost=2, id=1245},
	["HU Blue Lantern Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, cost=5, id=4371},
	["HU Green Lantern Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, isDefense=true, cost=5, id=5382},
	["HU Helmet of Fate"] = {vp=1, isEquipment=true, isDefense=true, cost=3, id=7652},
	["HU Indigo Tribe Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, cost=5, id=8012},
	["HU Legion Flight Ring"] = {vp=1, isEquipment=true, cost=2, id=4853},
	["HU Mind Control Hat"] = {vp=2, isEquipment=true, isAttack=true, cost=7, id=2081},
	["HU Orange Lantern Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, cost=5, id=7121},
	["HU Red Lantern Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, cost=5, id=9166},
	["HU Sciencell"] = {vp=0, isEquipment=true, cost=6, id=5502},
	["HU Skeets"] = {vp=1, isEquipment=true, isDefense=true, cost=4, id=3517},
	["HU Soultaker Sword"] = {vp=1, isEquipment=true, cost=4, id=3101},
	["HU Star Sapphire Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, cost=5, id=9741},
	["HU White Lantern Power Battery"] = {vp=2, isEquipment=true, cost=7, id=9070},
	["HU Yellow Lantern Corps Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, isAttack=true, cost=5, id=7910},
	--Locations
	["HU Apokolips"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=6508},
	["HU Gotham City"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=2054},
	["HU Metropolis"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=8759},
	["HU New Genesis"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=1736},
	["HU Oa"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=8421},
	--Super Villains
	["HU Amazo"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=5833},
	["HU Arkillo"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=1963},
	["HU Black Adam"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=8177},
	["HU Graves"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=8060},
	["HU Hector Hammond"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=7300},
	["HU H'el"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=8278},
	["HU Helspont"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=6868},
	["HU Mongul"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=9438},
	["HU Mr. Freeze"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=4716},
	["HU Nekron"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=9204},
	["HU Trigon"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=6681},
	["HU Vandal Savage"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=8, id=1610},
	--Oversized Character Cards
	["HU Batgirl"] = {vp=0, isCharacter=true, id=9773},
	["HU Black Canary"] = {vp=0, isCharacter=true, id=7760},
	["HU Booster Gold"] = {vp=0, isCharacter=true, id=1152},
	["HU Hawkman"] = {vp=0, isCharacter=true, id=4064},
	["HU Nightwing"] = {vp=0, isCharacter=true, id=9016},
	["HU Red Tornado"] = {vp=0, isCharacter=true, id=9402},
	["HU Shazam"] = {vp=0, isCharacter=true, id=5212},
	["HU Starfire"] = {vp=0, isCharacter=true, id=8856},
	--1)3) Forever Evil
	--Other
	["FE Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["FE Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["FE Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Heroes
	["FE Amanda Waller"] = {vp=1, isHero=true, cost=4, id=8153},
	["FE Catwoman"] = {vp=1, isHero=true, isAttack=true, cost=3, id=5962},
	["FE Commissioner Gordon"] = {vp=1, isHero=true, isDefense=true, cost=2, id=5074},
	["FE Dr. Light"] = {vp=1, isHero=true, isAttack=true, cost=3, id=5033},
	["FE Element Woman"] = {vp=1, isHero=true, cost=4, id=9249},
	["FE Firestorm"] = {vp=2, isHero=true, cost=6, id=8460},
	["FE Pandora"] = {vp=2, isHero=true, cost=7, id=4187},
	["FE Phantom Stranger"] = {vp=0, isHero=true, cost=5, id=1571},
	["FE Power Girl"] = {vp=2, isHero=true, cost=5, id=4709},
	["FE Stargirl"] = {vp=1, isHero=true, isDefense=true, cost=4, id=8676},
	["FE Steel"] = {vp=1, isHero=true, cost=3, id=8620},
	["FE Steve Trevor"] = {vp=0, isHero=true, cost=1, id=1452},
	["FE Vibe"] = {vp=1, isHero=true, cost=2, id=1728},
	--Villains
	["FE Atomica"] = {vp=1, isVillain=true, cost=3, id=4630},
	["FE Deathstorm"] = {vp=0, isVillain=true, cost=4, id=7983},
	["FE Despero"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=9301},
	["FE Emperor Penguin"] = {vp=0, isVillain=true, cost=1, id=8455},
	["FE Giganta"] = {vp=1, isVillain=true, cost=4, id=6273},
	["FE Grid"] = {vp=1, isVillain=true, cost=2, id=4899},
	["FE Johnny Quick"] = {vp=1, isVillain=true, cost=2, id=8297},
	["FE Man-Bat"] = {vp=1, isVillain=true, isDefense=true, cost=3, id=4863},
	["FE Owlman"] = {vp=2, isVillain=true, cost=6, id=3567},
	["FE Power Ring"] = {vp=2, isVillain=true, isPowerRing=true, cost=6, id=9921},
	["FE Royal Flush Gang"] = {vp=0, isVillain=true, cost=5, id=4913},
	["FE Superwoman"] = {vp=3, isVillain=true, cost=7, id=8419},
	["FE The Blight"] = {vp=1, isVillain=true, cost=4, id=7265},
	["FE Ultraman"] = {vp=3, isVillain=true, cost=8, id=1096},
	--Super Powers
	["FE Bizarro Power"] = {vp=-1, isSuperPower=true, isAttack=true, cost=6, id=4390},
	["FE Constructs of Fear"] = {vp=2, isSuperPower=true, isAttack=true, cost=7, id=5505},
	["FE Expert Marksman"] = {vp=1, isSuperPower=true, cost=3, id=2104},
	["FE Giant Growth"] = {vp=1, isSuperPower=true, cost=2, id=9097},
	["FE Insanity"] = {vp=1, isSuperPower=true, isDefense=true, cost=2, id=6963},
	["FE Invulnerable"] = {vp=1, isSuperPower=true, isDefense=true, cost=3, id=7020},
	["FE Kick"] = {vp=1, isSuperPower=true, cost=3, id=9883},
	["FE Power Drain"] = {vp=1, isSuperPower=true, isAttack=true, cost=4, id=9716},
	["FE Super Intellect"] = {vp=1, isSuperPower=true, cost=4, id=5429},
	["FE Transmutation"] = {vp=1, isSuperPower=true, cost=5, id=9706},
	["FE Ultra Strength"] = {vp=3, isSuperPower=true, cost=9, id=6593},
	["FE Word of Power"] = {vp=0, isSuperPower=true, cost=1, id=3067},
	--Equipment
	["FE Broadsword"] = {vp=2, isEquipment=true, isAttack=true, cost=6, id=7922},
	["FE Cold Gun"] = {vp=1, isEquipment=true, cost=2, id=8549},
	["FE Cosmic Staff"] = {vp=1, isEquipment=true, isDefense=true, cost=5, id=4707},
	["FE Firestorm Matrix"] = {vp=2, isEquipment=true, cost=7, id=8084},
	["FE Mallet"] = {vp=1, isEquipment=true, cost=4, id=5973},
	["FE Man-Bat Serum"] = {vp=1, isEquipment=true, cost=3, id=8199},
	["FE Pandora's Box"] = {vp=1, isEquipment=true, cost=2, id=8638},
	["FE Power Armor"] = {vp=3, isEquipment=true, isDefense=true, cost=8, id=1887},
	["FE Secret Society Communicator"] = {vp=1, isEquipment=true, cost=4, id=1820},
	["FE Sledgehammer"] = {vp=1, isEquipment=true, cost=3, id=4929},
	["FE Venom Injector"] = {vp=0, isEquipment=true, cost=1, id=8133},
	--Locations
	["FE Belle Reve"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=5193},
	["FE Blackgate Prison"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4302},
	["FE Central City"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=3055},
	["FE Earth-3"] = {vp=1, isLocation=true, isOngoing=true, cost=6, id=6434},
		["DA Baxter Building"] = {vp=1, isLocation=true, isOngoing=true, cost=6, id=6434},
		["DA Edifício Baxter"] = {vp=1, isLocation=true, isOngoing=true, cost=6, id=6434},
	["FE Happy Harbor"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=6053},
	["FE S.T.A.R. Labs"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=8886},
	--Super Heroes
	["FE Aquaman"] = {vp=6, isHero=true, isBoss=true, cost=11, id=8863},
	["FE Batman"] = {vp=6, isHero=true, isBoss=true, cost=11, id=4734},
	["FE Constantine"] = {vp=5, isHero=true, isBoss=true, cost=10, id=9548},
	["FE Cyborg"] = {vp=5, isHero=true, isBoss=true, cost=10, id=7046},
	["FE Green Arrow"] = {vp=5, isHero=true, isBoss=true, isOngoing=true, cost=9, id=8085},
	["FE Green Lantern"] = {vp=6, isHero=true, isBoss=true, cost=11, id=1069},
	["FE Martian Manhunter"] = {vp=6, isHero=true, isBoss=true, cost=12, id=9912},
	["FE Shazam!"] = {vp=6, isHero=true, isBoss=true, cost=12, id=9411},
	["FE Superman"] = {vp=6, isHero=true, isBoss=true, cost=13, id=7331},
	["FE Swamp Thing"] = {vp=5, isHero=true, isBoss=true, cost=9, id=5268},
	["FE The Flash"] = {vp=4, isHero=true, isBoss=true, isStartBoss=true, cost=8, id=8213},
	["FE Wonder Woman"] = {vp=6, isHero=true, isBoss=true, cost=11, id=9044},
	--Oversized Character Cards
	["FE Bane"] = {vp=0, isCharacter=true, id=7382},
	["FE Bizarro"] = {vp=0, isCharacter=true, id=3910},
	["FE Black Adam"] = {vp=0, isCharacter=true, id=3525},
	["FE Black Manta"] = {vp=0, isCharacter=true, id=6936},
	["FE Deathstroke"] = {vp=0, isCharacter=true, id=7114},
	["FE Harley Quinn"] = {vp=0, isCharacter=true, id=6998},
	["FE Lex Luthor"] = {vp=0, isCharacter=true, id=7612},
	["FE Sinestro"] = {vp=0, isCharacter=true, id=8933},
	["FE The Joker"] = {vp=0, isCharacter=true, id=3470},
	--1)4) Teen Titans
	--Other
	["TT Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["TT Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["TT Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Heroes
	["TT Aqualad"] = {vp=1, isHero=true, isOngoing=true, cost=3, id=4487},
	["TT Arsenal"] = {vp=1, isHero=true, cost=1, id=8736},
	["TT Bumblebee"] = {vp=1, isHero=true, isOngoing=true, cost=2, id=6355},
	["TT Bunker"] = {vp=1, isHero=true, cost=4, id=7363},
	["TT Cassie Sandsmark"] = {vp=1, isHero=true, cost=5, id=5957},
	["TT Conner Kent"] = {vp=2, isHero=true, cost=6, id=4625},
	["TT Daughter of Trigon"] = {vp=2, isHero=true, cost=7, id=8834},
	["TT Dick Grayson"] = {vp=0, isHero=true, cost=6, id=7943},
	["TT Garfield Logan"] = {vp=1, isHero=true, isOngoing=true, cost=5, id=1024},
	["TT Hawk & Dove"] = {vp=1, isHero=true, cost=4, id=2111},
	["TT Jaime Reyes"] = {vp=1, isHero=true, isDefense=true, cost=4, id=5808},
	["TT Jericho"] = {vp=1, isHero=true, isAttack=true, cost=3, id=5941},
	["TT Koriand'r"] = {vp=1, isHero=true, cost=5, id=7558},
	["TT Miss Martian"] = {vp=1, isHero=true, cost=3, id=9885},
	["TT Ravager"] = {vp=1, isHero=true, cost=2, id=1767},
	["TT Solstice"] = {vp=1, isHero=true, cost=2, id=9694},
	["TT Static"] = {vp=1, isHero=true, cost=4, id=7267},
	["TT Tim Drake"] = {vp=2, isHero=true, cost=6, id=7297},
	["TT Vic Stone"] = {vp=2, isHero=true, cost=7, id=6301},
	--Villains
	["TT Cinderblock"] = {vp=1, isVillain=true, cost=3, id=4158},
	["TT Gizmo"] = {vp=1, isVillain=true, cost=2, id=4500},
	["TT Grant Wilson"] = {vp=1, isVillain=true, cost=5, id=4387},
	["TT H.I.V.E. Agent"] = {vp=1, isVillain=true, cost=1, id=9953},
	["TT Inertia"] = {vp=2, isVillain=true, isOngoing=true, cost=6, id=4126},
	["TT Jinx"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=4075},
	["TT Lady Vic"] = {vp=1, isVillain=true, isOngoing=true, cost=4, id=9940},
	["TT Mad Mod"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=1316},
	["TT Mammoth"] = {vp=1, isVillain=true, isDefense=true, cost=5, id=6650},
	["TT Match"] = {vp=2, isVillain=true, isAttack=true, cost=7, id=4654},
	["TT Phobia"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=9000},
	["TT Plasmus"] = {vp=1, isVillain=true, cost=3, id=6799},
	["TT Shimmer"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=1616},
	["TT Sons of Trigon"] = {vp=2, isVillain=true, isAttack=true, cost=7, id=3594},
	["TT Zoo Keeper"] = {vp=1, isVillain=true, isDefense=true, isOngoing=true, cost=2, id=5859},
	--Super Powers
	["TT Acrobatic Agility"] = {vp=1, isSuperPower=true, isDefense=true, cost=1, id=6956},
	["TT Azarath Metrion Zinthos"] = {vp=1, isSuperPower=true, isOngoing=true, cost=5, id=1513},
	["TT Demonic Influence"] = {vp=1, isSuperPower=true, cost=5, id=9602},
	["TT Energy Absorption"] = {vp=1, isSuperPower=true, cost=4, id=7566},
	["TT Geokinesis"] = {vp=1, isSuperPower=true, isAttack=true, cost=4, id=7492},
	["TT Kick"] = {vp=1, isSuperPower=true, cost=3, id=9883},
	["TT Molecular Vibration"] = {vp=1, isSuperPower=true, isOngoing=true, cost=3, id=4488},
	["TT Shapeshift"] = {vp=1, isSuperPower=true, cost=2, id=6366},
	["TT Speed Force"] = {vp=2, isSuperPower=true, cost=7, id=1866},
	["TT Tactile Telekinesis"] = {vp=2, isSuperPower=true, isOngoing=true, cost=6, id=6409},
	["TT Teen Titans Go!"] = {vp=3, isSuperPower=true, cost=8, id=7966},
	--Equipment
	["TT Birdarang"] = {vp=1, isEquipment=true, cost=1, id=8600},
	["TT Cloak of Raven"] = {vp=1, isEquipment=true, cost=5, id=4903},
	["TT Colony Suit"] = {vp=1, isEquipment=true, cost=2, id=9794},
	["TT Cybernetic Enhancement"] = {vp=1, isEquipment=true, cost=3, id=8425},
	["TT Detonator"] = {vp=1, isEquipment=true, isOngoing=true, cost=3, id=4563},
	["TT Flight Wings"] = {vp=1, isEquipment=true, cost=4, id=9834},
	["TT Lasso of Lightning"] = {vp=1, isEquipment=true, cost=5, id=9421},
	["TT Magic Bracers"] = {vp=1, isEquipment=true, isDefense=true, cost=2, id=2060},
	["TT Reach Scarab"] = {vp=2, isEquipment=true, isDefense=true, cost=7, id=8729},
	["TT Silent Armor"] = {vp=1, isEquipment=true, cost=6, id=4826},
	["TT T-Wing"] = {vp=0, isEquipment=true, cost=6, id=7316},
	--Locations
	["TT Azarath"] = {vp=1, isLocation=true, isAttack=true, isOngoing=true, cost=5, id=8132},
		["TU The Concaverse"] = {vp=1, isLocation=true, isAttack=true, isOngoing=true, cost=5, id=8132},
		["TU O Concaverso"] = {vp=1, isLocation=true, isAttack=true, isOngoing=true, cost=5, id=8132},
	["TT Cadmus Labs"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=6376},
	["TT New Titans Tower"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=8241},
	["TT Tamaran"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=7093},
	["TT The Colony"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=9684},
	["TT Titans Memorial"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=3123},
	--Super Villains
	["TT Blackfire"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=4486},
	["TT Brother Blood"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=2078},
	["TT Cheshire"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=7263},
	["TT Clock King"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=5672},
	["TT Dr. Light"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=6847},
	["TT Harvest"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=8516},
	["TT Psimon"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=9631},
	["TT Slade Wilson"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=8, id=7846},
	["TT Superboy Prime"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=6375},
	["TT Terra"] = {vp=5, isVillain=true, isBoss=true, isOngoing=true, cost=10, id=3955},
	["TT The Brain & Monsieur Mallah"] = {vp=5, isVillain=true, isBoss=true, isDefense=true, cost=10, id=6066},
	["TT Trigon"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=9948},
	--Oversized Character Cards
	["TT Beast Boy"] = {vp=0, isCharacter=true, id=8441},
	["TT Blue Beetle"] = {vp=0, isCharacter=true, id=6952},
	["TT Kid Flash"] = {vp=0, isCharacter=true, id=5207},
	["TT Raven"] = {vp=0, isCharacter=true, id=7728},
	["TT Red Robin"] = {vp=0, isCharacter=true, id=8366},
	["TT Skitter"] = {vp=0, isCharacter=true, id=9617},
	["TT Starfire"] = {vp=0, isCharacter=true, id=4924},
	["TT Superboy"] = {vp=0, isCharacter=true, id=3495},
	["TT Wondergirl"] = {vp=0, isCharacter=true, id=5997},
	--1)5) Dark Night Metal
	--Other
	["DNM Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["DNM Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["DNM Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	["DNM Breakthrough"] = {vp=0, cost=3, id=9145},
	["DNM The Batman Who Laughs"] = {vp=0, id=8154},
	--Heroes
	["DNM Aquaman"] = {vp=1, isHero=true, cost=2, id=7410},
	["DNM Cyborg One Million"] = {vp=2, isHero=true, isMetal=true, cost=5, id=8520},
	["DNM Detective Chimp"] = {vp=1, isHero=true, cost=2, id=4052},
	["DNM Doctor Fate"] = {vp=1, isHero=true, cost=3, id=5487},
	["DNM Dream"] = {vp=2, isHero=true, cost=6, id=6978},
	["DNM Hal Jordan"] = {vp=1, isHero=true, cost=4, id=6083},
	["DNM Kendra Saunders"] = {vp=2, isHero=true, isMetal=true, cost=4, id=3017},
	["DNM Mister Terrific"] = {vp=2, isHero=true, cost=5, id=2085},
	["DNM Plastic Man"] = {vp=1, isHero=true, cost=3, id=6084},
	["DNM Steel"] = {vp=1, isHero=true, isMetal=true, cost=3, id=6941},
	["DNM Superman"] = {vp=2, isHero=true, cost=6, id=3841},
	["DNM The Flash"] = {vp=1, isHero=true, isDefense=true, cost=4, id=8307},
	["DNM Wonder Woman"] = {vp=3, isHero=true, cost=7, id=9247},
	--Villains
	["DNM Baby Darkseid"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=4102},
	["DNM Black Adam"] = {vp=2, isVillain=true, t2="2", isDefense=true, cost=6, id=4023},
	["DNM Black Manta"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=2013},
	["DNM Carter Hall"] = {vp=2, isVillain=true, isMetal=true, isAttack=true, cost=7, id=3061},
	["DNM Clayface"] = {vp=1, isVillain=true, cost=3, id=8037},
	["DNM Court of Owls"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=8257},
	["DNM Deathstroke"] = {vp=1, isVillain=true, isMetal=true, isDefense=true, cost=4, id=9630},
	["DNM Lady Blackhawk"] = {vp=2, isVillain=true, isMetal=true, cost=4, id=9205},
	["DNM Onimar Synn"] = {vp=2, isVillain=true, isMetal=true, cost=5, id=9064},
	["DNM Ra's Al Ghul"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=3164},
	["DNM Rabid Robin"] = {vp=2, isVillain=true, cost=2, id=8624},
	["DNM Starro"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=2064},
	["DNM Strigydae"] = {vp=1, isVillain=true, cost=3, id=5921},
	--Super Powers
	["DNM Ankh Portal"] = {vp=1, isSuperPower=true, cost=5, id=3698},
	["DNM Brutal Chase"] = {vp=1, isSuperPower=true, cost=4, id=3012},
	["DNM Escape"] = {vp=1, isSuperPower=true, isDefense=true, cost=2, id=5607},
	["DNM Fair Play"] = {vp=1, isSuperPower=true, cost=3, id=6087},
	["DNM Flight"] = {vp=2, isSuperPower=true, cost=2, id=4057},
	["DNM Fulcum Abominus"] = {vp=2, isSuperPower=true, cost=2, id=5048},
	["DNM Hypertime"] = {vp=2, isSuperPower=true, cost=6, id=3014},
	["DNM Mecha Construct"] = {vp=1, isSuperPower=true, cost=5, id=8054},
	["DNM Power Channeling"] = {vp=3, isSuperPower=true, cost=6, id=4087},
	["DNM Search the Depths"] = {vp=1, isSuperPower=true, cost=3, id=7084},
	["DNM Speed Force"] = {vp=1, isSuperPower=true, isDefense=true, cost=3, id=1097},
	["DNM War Cry"] = {vp=1, isSuperPower=true, cost=4, id=7924},
	["DNM X-Ray Vision"] = {vp=1, isSuperPower=true, cost=4, id=2703},
	--Equipment
	["DNM Anti-Monitor's Antenna"] = {vp=1, isEquipment=true, isOngoing=true, cost=5, id=8741},
	["DNM Batmanium"] = {vp=4, isEquipment=true, isMetal=true, cost=5, id=1023},
	["DNM Carter Hall's Journal"] = {vp=0, isEquipment=true, cost=4, id=6497},
	["DNM Dionesium"] = {vp=1, isEquipment=true, isMetal=true, cost=4, id=8045},
	["DNM Eighth Metal Sunblade"] = {vp=3, isEquipment=true, isMetal=true, cost=8, id=9045},
	["DNM Electrum"] = {vp=1, isEquipment=true, isMetal=true, cost=3, id=9801},
	["DNM Element X"] = {vp=0, isEquipment=true, isMetal=true, cost=10, id=8106},
	["DNM Multiverse Map"] = {vp=2, isEquipment=true, cost=2, id=3068},
	["DNM Nth Metal Mace"] = {vp=4, isEquipment=true, isMetal=true, isDefense=true, cost=9, id=6085},
	["DNM Phantom Zone Projector"] = {vp=1, isEquipment=true, isDefense=true, cost=3, id=4050},
	["DNM Phoenix Cannon"] = {vp=2, isEquipment=true, cost=3, id=9067},
	["DNM Promethium"] = {vp=1, isEquipment=true, isMetal=true, cost=2, id=6081},
	["DNM T-Spheres"] = {vp=1, isEquipment=true, cost=4, id=5934},
	--Locations
	["DNM Challenger Mountain"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=9764},
	["DNM Forge of Worlds"] = {vp=2, isLocation=true, isOngoing=true, cost=7, id=9075},
	["DNM Oblivion Bar"] = {vp=1, isLocation=true, isDefense=true, isOngoing=true, cost=5, id=7085},
	["DNM The Dark Multiverse"] = {vp=2, isLocation=true, isOngoing=true, cost=5, id=6821},
	["DNM Tomb of Hath-Set"] = {vp=2, isLocation=true, isOngoing=true, cost=5, id=5912},
	--Super-Villains
	["DNM Barbatos"] = {vp=10, isVillain=true, isBoss=true, cost=14, id=9127},
	["DNM The Dawnbreaker"] = {vp=8, isVillain=true, isBoss=true, cost=11, id=6891},
	["DNM The Devastator"] = {vp=8, isVillain=true, isBoss=true, cost=9, id=1649},
	["DNM The Drowned"] = {vp=8, isVillain=true, isBoss=true, cost=11, id=5497},
	["DNM The Merciless"] = {vp=7, isVillain=true, isBoss=true, cost=9, id=6318},
	["DNM The Murder Machine"] = {vp=6, isVillain=true, isBoss=true, cost=9, id=8426},
	["DNM The Red Death"] = {vp=9, isVillain=true, isBoss=true, cost=11, id=8163},
	--Oversized Character Cards
	["DNM Aquaman (Character)"] = {vp=0, isCharacter=true, id=1386},
	["DNM Batman"] = {vp=0, isCharacter=true, id=5148},
	["DNM Cyborg"] = {vp=0, isCharacter=true, id=9423},
	["DNM Deathstroke (Character)"] = {vp=0, isCharacter=true, id=6437},
	["DNM Doctor Fate (Character)"] = {vp=0, isCharacter=true, id=1485},
	["DNM Hal Jordan (Character)"] = {vp=0, isCharacter=true, id=6248},
	["DNM Kendra Saunders (Character)"] = {vp=0, isCharacter=true, id=6271},
	["DNM Mister Terrific (Character)"] = {vp=0, isCharacter=true, id=2415},
	["DNM Plasticman (Character)"] = {vp=0, isCharacter=true, id=9345},
	["DNM Superman (Character)"] = {vp=0, isCharacter=true, id=1825},
	["DNM The Flash (Character)"] = {vp=0, isCharacter=true, id=8264},
	["DNM Wonder Woman (Character)"] = {vp=0, isCharacter=true, id=3416},
	--1)6) Injustice
	--Other
	["INJ Light Punch"] = {vp=0, isStarter=true, cost=0,},
	["INJ Heavy Punch"] = {vp=0, isStarter=true, isAttack=true, cost=0,},
	["INJ Defend"] = {vp=0, isStarter=true, isDefense=true, cost=0,},
	["INJ Vulnerability"] = {vp=0, isStarter=true, cost=0,},
	["INJ Weakness"] = {vp=-1, isWeakness=true, cost=0, },
	["INJ Flying Kick"] = {vp=1, isAttack=true, cost=3,},
	--Heroes
	["INJ Cyborg (Earth-1)"] = {vp=1, isHero=true, cost=4,},
	["INJ Injustice Batgirl"] = {vp=1, isHero=true, isDefense=true, cost=4,},
	["INJ Injustice Batwoman"] = {vp=1, isHero=true, cost=4,},
	["INJ Injustice Black Canary"] = {vp=1, isHero=true, isAttack=true, cost=3,},
	["INJ Injustice Black Lightning"] = {vp=1, isHero=true, isDefense=true, cost=2,},
	["INJ Injustice Captain Atom"] = {vp=1, isHero=true, cost=5,},
	["INJ Injustice Catwoman"] = {vp=1, isHero=true, cost=3,},
	["INJ Injustice Deathstroke"] = {vp=2, isHero=true, isAttack=true, cost=5,},
	["INJ Injustice Doctor Fate"] = {vp=3, isHero=true, isAttack=true, cost=7,},
	["INJ Injustice Huntress"] = {vp=1, isHero=true, cost=3,},
	["INJ Injustice Martian Manhunter"] = {vp=2, isHero=true, cost=5,},
	["INJ Injustice Nightwing"] = {vp=2, isHero=true, isDefense=true, cost=6,},
	["INJ Injustice Swamp Thing"] = {vp=2, isHero=true, cost=6,},
	["INJ Injustice The Atom"] = {vp=1, isHero=true, cost=2,},
	["INJ Injustice Zatanna"] = {vp=1, isHero=true, cost=4,},
	--Villains
	["INJ Injustice Aquaman"] = {vp=3, isVillain=true, isAttack=true, cost=7,},
	["INJ Injustice Atom Smasher"] = {vp=2, isVillain=true, cost=5,},
	["INJ Injustice Bane"] = {vp=1, isVillain=true, cost=3,},
	["INJ Injustice Bizarro"] = {vp=2, isVillain=true, isAttack=true, cost=5,},
	["INJ Injustice Cyborg"] = {vp=1, isVillain=true, cost=4,},
	["INJ Injustice Deadshot"] = {vp=1, isVillain=true, isAttack=true, cost=3,},
	["INJ Injustice Giganta"] = {vp=2, isVillain=true, cost=6,},
	["INJ Injustice Kalibak"] = {vp=2, isVillain=true, isAttack=true, cost=6,},
	["INJ Injustice Killer Frost"] = {vp=1, isVillain=true, isAttack=true, cost=4,},
	["INJ Injustice Parasite"] = {vp=1, isVillain=true, cost=4,},
	["INJ Injustice Raven"] = {vp=2, isVillain=true, cost=5,},
	["INJ Injustice Regime Soldiers"] = {vp=1, isVillain=true, cost=2,},
	["INJ Injustice Robin"] = {vp=1, isVillain=true, isDefense=true, cost=2,},
	["INJ Injustice Solomon Grundy"] = {vp=2, isVillain=true, isAttack=true, cost=6,},
	["INJ Injustice Victor Zsasz"] = {vp=1, isVillain=true, cost=3,},
	--Super Powers
	["INJ Atlas Torpedo"] = {vp=1, isSuperPower=true, cost=3,},
	["INJ Bolt of Zeus"] = {vp=2, isSuperPower=true, cost=6,},
	["INJ Construct Axe of Terror"] = {vp=1, isSuperPower=true, isAttack=true, cost=4,},
	["INJ Dark Transmission"] = {vp=1, isSuperPower=true, cost=3,},
	["INJ Demigoddess's Might"] = {vp=1, isSuperPower=true, cost=2,},
	["INJ Flash Freeze"] = {vp=1, isSuperPower=true, cost=3,},
	["INJ Flying Ground Slam"] = {vp=2, isSuperPower=true, cost=6,},
	["INJ Frostbite"] = {vp=1, isSuperPower=true, cost=4,},
	["INJ Heat Vision"] = {vp=2, isSuperPower=true, isAttack=true, cost=5,},
	["INJ Mind Games"] = {vp=1, isSuperPower=true, cost=3,},
	["INJ Running Man Stance"] = {vp=1, isSuperPower=true, cost=5,},
	["INJ Soaring Hawk"] = {vp=1, isSuperPower=true, cost=2,},
	["INJ Somersault"] = {vp=1, isSuperPower=true, isDefense=true, cost=3,},
	["INJ Speed Dodge"] = {vp=1, isSuperPower=true, isDefense=true, cost=4,},
	["INJ Speed Force"] = {vp=2, isSuperPower=true, isDefense=true, cost=7,},
	["INJ Super Breath"] = {vp=1, isSuperPower=true, cost=3,},
	["INJ Super-Strength"] = {vp=1, isSuperPower=true, isAttack=true, cost=4,},
	["INJ Turbine Smash"] = {vp=1, isSuperPower=true, cost=4,},
	--Equipment
	["INJ 5-U-93-R Pill"] = {vp=1, isEquipment=true, cost=5,},
	["INJ Batarangs"] = {vp=1, isEquipment=true, isDefense=true, cost=4,},
	["INJ Batmobile"] = {vp=1, isEquipment=true, cost=2,},
	["INJ Bow and Arrow"] = {vp=1, isEquipment=true, isAttack=true, cost=4,},
	["INJ Cat Claws"] = {vp=1, isEquipment=true, isAttack=true, cost=3,},
	["INJ Chattering Teeth"] = {vp=1, isEquipment=true, isAttack=true, cost=2,},
	["INJ Energy Shield"] = {vp=1, isEquipment=true, isDefense=true, isOngoing=true, cost=3,},
	["INJ Escrima Sticks"] = {vp=1, isEquipment=true, cost=4,},
	["INJ Giant Mallet"] = {vp=1, isEquipment=true, cost=4,},
	["INJ Grapnel Launcher"] = {vp=1, isEquipment=true, cost=3,},
	["INJ Green Lantern Power Ring"] = {vp=2, isEquipment=true, isPowerRing=true, cost=6,},
	["INJ Knife"] = {vp=1, isEquipment=true, cost=3,},
	["INJ Lasso of Truth"] = {vp=3, isEquipment=true, cost=7,},
	["INJ Nth Metal Mace"] = {vp=2, isEquipment=true, isDefense=true, cost=6,},
	["INJ Power Armor"] = {vp=1, isEquipment=true, cost=4,},
	["INJ Quiver of Arrows"] = {vp=1, isEquipment=true, cost=3,},
	["INJ Sinestro Corps Power Ring"] = {vp=2, isEquipment=true, isPowerRing=true, cost=6,},
	["INJ Sword and Shield"] = {vp=1, isEquipment=true, isAttack=true, isDefense=true, cost=5,},
	["INJ Wing Ding"] = {vp=1, isEquipment=true, isDefense=true, cost=4,},
	--Super-Heroes
	["INJ Aquaman (Earth-1)"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["INJ Batman (Earth-1)"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["INJ Beast Boy"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["INJ Green Arrow (Earth-1)"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["INJ Green Lantern (Earth-1)"] = {vp=5, isHero=true, isBoss=true, cost=10,},
	["INJ Injustice Batman"] = {vp=7, isHero=true, isBoss=true, cost=14,},
	["INJ Injustice Green Lantern (John Stewart)"] = {vp=4, isHero=true, isBoss=true, isStartBoss=true, cost=8,},
	["INJ Injustice Green Lantern Corps"] = {vp=5, isHero=true, isBoss=true, cost=10,},
	["INJ Injustice Hawkman"] = {vp=6, isHero=true, isBoss=true, isAttack=true, cost=11,},
	["INJ Injustice The Flash"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["INJ Injustice Martian Manhunter (Nemesis)"] = {vp=5, isHero=true, isBoss=true, isAttack=true, cost=9,},
	["INJ Superman (Earth-1)"] = {vp=6, isHero=true, isBoss=true, cost=12,},
	["INJ Wonder Woman (Earth-1)"] = {vp=6, isHero=true, isBoss=true, isDefense=true, cost=11,},
	--Super-Villains
	["INJ Injustice Ares"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["INJ Injustice Black Adam"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["INJ Injustice Darkseid"] = {vp=6, isVillain=true, isBoss=true, cost=12,},
	["INJ Injustice Doomsday"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=12,},
	["INJ Injustice Lex Luthor"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["INJ Injustice Lobo"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["INJ Injustice Shazam!"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["INJ Injustice Sinestro"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["INJ Injustice Superman"] = {vp=7, isVillain=true, isBoss=true, cost=14,},
	["INJ Injustice The Joker"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=8,},
	["INJ Injustice The Spectre"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["INJ Injustice Trigon"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	--Clash Cards
	["INJ Blindsided"] = {vp=0,},
	["INJ Cover Fire"] = {vp=0,},
	["INJ Enemy of my Enemy"] = {vp=0,},
	["INJ Favor of the Gods"] = {vp=0,},
	["INJ Finishing Move"] = {vp=0,},
	["INJ From the Shadows"] = {vp=0,},
	["INJ Have a Blast!"] = {vp=0,},
	["INJ Home Surgery"] = {vp=0,},
	["INJ Mobilize"] = {vp=0,},
	["INJ Nasty Surprise"] = {vp=0,},
	["INJ Overload"] = {vp=0,},
	["INJ Savage Beatdown"] = {vp=0,},
	["INJ System Failure"] = {vp=0,},
	["INJ Total Anarchy"] = {vp=0,},
	["INJ Traitor Among Us"] = {vp=0,},
	--Super Moves
	["INJ Arsenal Assault"] = {vp=0,},
	["INJ Beware My Power"] = {vp=0,},
	["INJ Coordinates Received"] = {vp=0,},
	["INJ Dark as Night"] = {vp=0,},
	["INJ Deadly Sin"] = {vp=0,},
	["INJ Endless Whiteout"] = {vp=0,},
	["INJ Justice Javelin"] = {vp=0,},
	["INJ Kryptonian Crush"] = {vp=0,},
	["INJ Let's Be Serious"] = {vp=0,},
	["INJ Mallet Bomb"] = {vp=0,},
	["INJ Nine Lives"] = {vp=0,},
	["INJ Sinestro's Might"] = {vp=0,},
	["INJ Speed Zone"] = {vp=0,},
	["INJ The Dark Knight"] = {vp=0,},
	["INJ The Power of Nth"] = {vp=0,},
	["The Power of Shazam!"] = {vp=0,},
	--Oversized Character Cards
	["INJ Injustice Batman (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Catwoman (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Green Arrow"] = {vp=0, isCharacter=true,},
	["INJ Injustice Harley Quinn"] = {vp=0, isCharacter=true,},
	["INJ Injustice Hawkgirl"] = {vp=0, isCharacter=true,},
	["INJ Injustice Killer Frost (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Lex Luthor (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Nightwing (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Raven (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Shazam! (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Sinestro (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Superman (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice The Flash (Character)"] = {vp=0, isCharacter=true,},
	["INJ Injustice Wonder Woman"] = {vp=0, isCharacter=true,},
	["INJ Injustice Yellow Lantern"] = {vp=0, isCharacter=true,},
	["INJ The Batman Who Laughs"] = {vp=0, isCharacter=true,},
	["INJ The Joker (Earth-1)"] = {vp=0, isCharacter=true,},
	--1)7) Justice League Dark
	--Other
	["JLD Punch"] = {vp=0, isStarter=true, cost=0,},
	["JLD Vulnerability"] = {vp=0, isStarter=true, cost=0,},
	["JLD Sealed Defense"] = {vp=0, isStarter=true, cost=0,},
	["JLD Defend"] = {vp=1, isStarter=true, cost=0,}, -- Transformed
	["JLD Incantation"] = {vp=0, isStarter=true, cost=0,},
	["JLD Weakness"] = {vp=-2, isWeakness=true, cost=0, },
	["JLD Mystic Ritual"] = {vp=1, cost=3,},
	--Heroes
	["JLD Billy Batson"] = {vp=1, isHero=true, cost=2,},
	["JLD Black Alice"] = {vp=1, isHero=true, cost=3,},
	["JLD Deadman"] = {vp=1, isHero=true, isAttack=true, cost=5,},
	["JLD Detective Chimp"] = {vp=1, isHero=true, cost=5,},
	["JLD Doctor Mist"] = {vp=2, isHero=true, isAttack=true, cost=6,},
	["JLD Dr. Kirk Langstrom"] = {vp=1, isHero=true, cost=4,},
	["JLD Hellblazer"] = {vp=2, isHero=true, cost=6,},
	["JLD Jason Blood, Soul Bound"] = {vp=2, isHero=true, isDefense=true, cost=7,},
	["JLD Kent Nelson"] = {vp=2, isHero=true, cost=6,},
	["JLD Khalid Nassour"] = {vp=1, isHero=true, cost=4,},
	["JLD Madame Xanadu"] = {vp=1, isHero=true, cost=3,},
	["JLD Mary Bromfield"] = {vp=1, isHero=true, cost=4,},
	["JLD Nightmare Nurse"] = {vp=1, isHero=true, cost=3,},
	["JLD Ragman, Redeemer"] = {vp=1, isHero=true, cost=5,},
	["JLD Raven, Rachel"] = {vp=1, isHero=true, cost=4,},
	["JLD Shade, The Changing Man"] = {vp=1, isHero=true, isDefense=true, cost=4,},
	["JLD Traci 13"] = {vp=1, isHero=true, isDefense=true, cost=2,},
	["JLD Wonder Woman"] = {vp=2, isHero=true, cost=7,},
	["JLD Zach Zatara"] = {vp=2, isHero=true, cost=3,},
	["JLD Zatanna Zatara"] = {vp=2, isHero=true, cost=7,},
	--Villains
	["JLD Arion The Sorcerer"] = {vp=2, isVillain=true, cost=7,},
	["JLD Circe, Witch of Aeaea"] = {vp=1, isVillain=true, cost=5,},
	["JLD Ember"] = {vp=1, isVillain=true, cost=3,},
	["JLD Enchantress, Dzamor"] = {vp=2, isVillain=true, cost=6,},
	["JLD Felix Faust, Power Hungry"] = {vp=1, isVillain=true, cost=4,},
	["JLD Floronic Man, Woodrue"] = {vp=2, isVillain=true, cost=6,},
	["JLD Fuseli"] = {vp=1, isVillain=true, cost=2,},
	["JLD Jinx"] = {vp=1, isVillain=true, cost=4,},
	["JLD Klarion"] = {vp=2, isVillain=true, cost=6,},
	["JLD Mister E"] = {vp=1, isVillain=true, isDefense=true, cost=5,},
	["JLD Nergal"] = {vp=2, isVillain=true, isAttack=true, cost=7,},
	["JLD Nick Necro"] = {vp=1, isVillain=true, cost=3,},
	["JLD Papa Midnite"] = {vp=1, isVillain=true, cost=4,},
	["JLD Solomon Grundy"] = {vp=1, isVillain=true, isDefense=true, cost=4,},
	["JLD Tannarak"] = {vp=0, isVillain=true, cost=5,},
	["JLD Teekl"] = {vp=1, isVillain=true, cost=3,},
	["JLD The Demons Three"] = {vp=1, isVillain=true, cost=3,},
	["JLD Witchmarked Black Orchid"] = {vp=1, isVillain=true, isAttack=true, cost=4,},
	["JLD Witchmarked Manitou Dawn"] = {vp=1, isVillain=true, cost=3,},
	["JLD Witchmarked Witchfire"] = {vp=1, isVillain=true, cost=2,},
	--Super Powers
	["JLD Ankh Portal"] = {vp=1, isSuperPower=true, cost=4,},
	["JLD Chains of Fate"] = {vp=2, isSuperPower=true, isDefense=true, cost=6,},
	["JLD Channel The Green"] = {vp=1, isSuperPower=true, cost=3,},
	["JLD Eldritch Magic"] = {vp=1, isSuperPower=true, cost=4,},
	["JLD Leather Wings"] = {vp=1, isSuperPower=true, cost=2,},
	["JLD Magical Portal"] = {vp=1, isSuperPower=true, cost=2,},
	["JLD Magical Shield"] = {vp=1, isSuperPower=true, isDefense=true, isOngoing=true, cost=5,},
	["JLD Noitanivid"] = {vp=1, isSuperPower=true, cost=4,},
	["JLD Polymorph"] = {vp=2, isSuperPower=true, isAttack=true, cost=6,},
	["JLD Possession"] = {vp=1, isSuperPower=true, isAttack=true, cost=3,},
	["JLD Protection Spell"] = {vp=1, isSuperPower=true, isDefense=true, cost=2,},
	["JLD Raeppasid"] = {vp=1, isSuperPower=true, isDefense=true, cost=4,},
	["JLD Sealing Spell"] = {vp=1, isSuperPower=true, cost=3,},
	["JLD Rip Asunder"] = {vp=1, isSuperPower=true, isAttack=true, cost=7,},
	["JLD Sigil of Fate"] = {vp=2, isSuperPower=true, cost=7,},
	["JLD Soul Siphon"] = {vp=1, isSuperPower=true, cost=5,},
	["JLD Witchmark of Hecate"] = {vp=1, isSuperPower=true, cost=4,},
	["JLD Word of Power"] = {vp=2, isSuperPower=true, cost=4,},
	--Equipment
	["JLD Ace of Winchesters"] = {vp=1, isEquipment=true, cost=2,},
	["JLD Ancient Tomes"] = {vp=1, isEquipment=true, cost=2,},
	["JLD Boots of Delphi"] = {vp=1, isEquipment=true, cost=5,},
	["JLD Breastplate of Hoku"] = {vp=1, isEquipment=true, isDefense=true, cost=6,},
	["JLD Cloak of Cyra"] = {vp=1, isEquipment=true, cost=4,},
	["JLD Dreamstone"] = {vp=2, isEquipment=true, isAttack=true, cost=6,},
	["JLD Eight-Dimensional Map"] = {vp=1, isEquipment=true, cost=3,},
	["JLD Gauntlets of Myrath"] = {vp=1, isEquipment=true, cost=5,},
	["JLD Heart of Darkness"] = {vp=1, isEquipment=true, cost=5,},
	["JLD Helmet of Fate"] = {vp=2, isEquipment=true, cost=7,},
	["JLD Houdini Key"] = {vp=1, isEquipment=true, cost=3,},
	["JLD Man-Bat Serum"] = {vp=1, isEquipment=true, cost=4,},
	["JLD Moonblade, New Moon"] = {vp=1, isEquipment=true, cost=4,},
	["JLD Scarab Necklace"] = {vp=2, isEquipment=true, cost=6,},
	["JLD Skeleton Key"] = {vp=1, isEquipment=true, cost=3,},
	["JLD Staff of Merlin"] = {vp=1, isEquipment=true, cost=5,},
	["JLD Suit of Souls"] = {vp=1, isEquipment=true, cost=4,},
	["JLD Sword of Night"] = {vp=1, isEquipment=true, isDefense=true, cost=3,},
	--Locations
	["JLD Aeaea"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	["JLD Hall of Justice Archives"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	["JLD House of Mystery"] = {vp=1, isLocation=true, isOngoing=true, cost=4,},
	["JLD House of Secrets"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	["JLD Limbo Town"] = {vp=1, isLocation=true, isOngoing=true, cost=4,},
	["JLD Myrra"] = {vp=1, isLocation=true, isOngoing=true, cost=3,},
	["JLD Nanda Parbat"] = {vp=2, isLocation=true, isOngoing=true, cost=6,},
	["JLD Oblivion Bar"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	["JLD Tower of Fate"] = {vp=1, isLocation=true, isOngoing=true, cost=6,},
	["JLD Tree of Wonder"] = {vp=2, isLocation=true, isOngoing=true, cost=6,},
	--Transformed Heroes
	["JLD Mary Marvel, New Champion"] = {vp=1, isHero=true, cost=6,},
	["JLD Ragman, Soul Powered"] = {vp=2, isHero=true, cost=7,},
	["JLD Shazam!, Champion of Magic"] = {vp=1, isHero=true, cost=4,},
	["JLD Witchmarked Wonder Woman"] = {vp=2, isHero=true, cost=9,},
	--Transformed Villains
	["JLD Arion, Risen"] = {vp=3, isVillain=true, cost=8,},
	["JLD Black Adam, Corrupted Champion"] = {vp=2, isVillain=true, cost=8,},
	["JLD Dark Raven"] = {vp=-3, isVillain=true, cost=6,},
	["JLD Eclipso, Possessor"] = {vp=2, isVillain=true, cost=7,},
	["JLD Etrigan, Soul Bound"] = {vp=2, isVillain=true, cost=9,},
	["JLD Felix Faust, Unbound"] = {vp=2, isVillain=true, cost=7,},
	["JLD June Moon, Freelancer"] = {vp=1, isVillain=true, isDefense=true, cost=4,},
	["JLD Man-Bat, Mutated Scientist"] = {vp=2, isVillain=true, cost=6,},
	["JLD Mary Marvel, Corrupted"] = {vp=2, isVillain=true, cost=5,},
	["JLD New Avatar of The Green"] = {vp=2, isVillain=true, cost=8,},
	["JLD Witchmarked Circe"] = {vp=2, isVillain=true, cost=7,},
	--Transformed Equipment
	["JLD Moonblade, Full Moon"] = {vp=2, isEquipment=true, isAttack=true, cost=6,},
	["JLD The Books of Magic"] = {vp=2, isEquipment=true, cost=5,},
	--Super-Villains
	["JLD Anton Arcane"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["JLD Brother Night"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["JLD Doctor Destiny"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["JLD Enchantress"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=8,},
	["JLD Hecate"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=8,},
	["JLD Lord Satanus"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["JLD Lords of Order"] = {vp=7, isVillain=true, isBoss=true, cost=12,},
	["JLD Merlin"] = {vp=7, isVillain=true, isBoss=true, cost=12,},
	["JLD Mordru"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["JLD Morgaine Le Fey"] = {vp=6, isVillain=true, isBoss=true, cost=9,},
	["JLD Neron"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["JLD Queen of Fables"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["JLD The Otherkind"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["JLD Upside Down Man"] = {vp=8, isVillain=true, isBoss=true, isLastBoss=true, cost=13,},
	["JLD Xanadoth, Lord of Chaos"] = {vp=8, isVillain=true, isBoss=true, isLastBoss=true, cost=13,},
	--Oversized Character Cards
	["JLD Deadman (Character)"] = {vp=0, isCharacter=true,},
	["JLD Detective Chimp (Character)"] = {vp=0, isCharacter=true,},
	["JLD Doctor Fate"] = {vp=0, isCharacter=true,},
	["JLD John Constantine"] = {vp=0, isCharacter=true,},
	["JLD Madame Xanadu (Character)"] = {vp=0, isCharacter=true,},
	["JLD Man-Bat"] = {vp=0, isCharacter=true,},
	["JLD Ragman"] = {vp=0, isCharacter=true,},
	["JLD Swamp Thing"] = {vp=0, isCharacter=true,},
	["JLD Wonder Woman (Character)"] = {vp=0, isCharacter=true,},
	["JLD Zatanna Zatara (Character)"] = {vp=0, isCharacter=true,},
	--1)7)A) Justice League Dark Expansion
	--Villains 
	["JLDX Blackbriar Thorn, Druid"] = {vp=1, isVillain=true, cost=4,},
	--Super Powers
	["JLDX Born On A Monday"] = {vp=1, isSuperPower=true, cost=3,},
	--Transformed Villains
	["JLDX Blackbriar Thorn, Elemental"] = {vp=1, isVillain=true, cost=6,},
	--Super-Heroes
	["JLDX Avatar of the Red"] = {vp=6, isHero=true, isBoss=true, cost=9,},
	["JLDX Avatar of the Rot"] = {vp=7, isHero=true, isBoss=true, cost=12,},
	["JLDX Giovanni Zatara"] = {vp=5, isHero=true, isBoss=true, isStartBoss=true, cost=8,},
	["JLDX Nightmaster"] = {vp=6, isHero=true, isBoss=true, cost=10,},
	["JLDX Ragman"] = {vp=6, isHero=true, isBoss=true, cost=9,},
	--Oversized Character Cards
	["JLDX Enchantress"] = {vp=0, isCharacter=true,},
	["JLDX Floronic Man"] = {vp=0, isCharacter=true,},
	["JLDX Klarion"] = {vp=0, isCharacter=true,},
	["JLDX Papa Midnite"] = {vp=0, isCharacter=true,},
	["JLDX Solomon Grundy"] = {vp=0, isCharacter=true,},
	["JLDX Witchmarked Circe"] = {vp=0, isCharacter=true,},
	--1)8) Arkham Asylum
	-- Other
	["ARK Punch"] = {vp=0, isStarter=true, cost=0,},
	["ARK Vulnerability"] = {vp=0, isStarter=true, cost=0,},
	-- Equipment
	["ARK Batcycle"] = {vp=1, isEquipment=true, cost=4,},
	["ARK Bazooka"] = {vp=1, isEquipment=true, cost=4, isBribe=true,},
	["ARK Crowbar"] = {vp=1, isEquipment=true, cost=3,},
	["ARK Death Trap"] = {vp=1, isEquipment=true, isAttack=true, cost=4,},
	["ARK Dual Weapons"] = {vp=1, isEquipment=true, cost=2,},
	["ARK Fear Toxin"] = {vp=2, isEquipment=true, isAttack=true, isBribe=true, cost=5,},
	["ARK Freeze Gun"] = {vp=2, isEquipment=true, isAttack=true, cost=6,},
	["ARK Giant Mallet"] = {vp=1, isEquipment=true, isBribe=true, cost=3,},
	["ARK Laughing Gas"] = {vp=1, isEquipment=true, cost=4,},
	["ARK Riddler Cane"] = {vp=1, isEquipment=true, isDefense=true, cost=3,},
	["ARK Scarface"] = {vp=2, isEquipment=true, cost=6,},
	["ARK Time Bomb"] = {vp=1, isEquipment=true, isDefense=true, cost=5,},
	-- Heroes
	["ARK Bat-Cow"] = {vp=1, isHero=true, cost=2,},
	["ARK Batwing"] = {vp=2, isHero=true, cost=6,},
	["ARK Carlos Alvarez"] = {vp=1, isHero=true, isBribe=true, cost=3,},
	["ARK Crispus Allen"] = {vp=1, isHero=true, isDefense=true, cost=4,},
	["ARK GCPD Officer"] = {vp=1, isHero=true, isBribe=true, cost=2,},
	["ARK Gotham Girl"] = {vp=2, isHero=true, isBribe=true, cost=7,},
	["ARK Harvey Bullock"] = {vp=1, isHero=true, isAttack=true, isBribe=true, cost=3,},
	["ARK Leslie Thompkins"] = {vp=1, isHero=true, cost=4,},
	["ARK Prison Guard"] = {vp=1, isHero=true, isBribe=true, cost=1,},
	["ARK Ragman"] = {vp=1, isHero=true, cost=4,},
	["ARK Rene Montoya"] = {vp=2, isHero=true, cost=6,},
	["ARK Spoiler"] = {vp=1, isHero=true, isAttack=true, isBribe=true, cost=5,},
	["ARK The Signal"] = {vp=1, isHero=true, cost=5,},
	["ARK Titus"] = {vp=1, isHero=true, isDefense=true, cost=3,},
	-- Hostages
	["ARK Aaron Cash"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Alfred Pennyworth"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Bruce Wayne"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Calendar Man"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Carmine Falcone"] = {vp=0, isHostage=true, isDefense=true, isOngoing=true, cost=2,},
	["ARK Congresswoman Alejo"] = {vp=0, isHostage=true, isDefense=true, isOngoing=true, cost=2,},
	["ARK Holly Robinson"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Hugo Strange"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Jeremiah Arkham"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Julia Pennyworth"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Lucious Fox"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Mayor Akins"] = {vp=0, isHostage=true, isDefense=true, isOngoing=true, cost=2,},
	["ARK Oliver Queen"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Sal Maroni"] = {vp=0, isHostage=true, isDefense=true, isOngoing=true, cost=2,},
	["ARK Silver St. Cloud"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	["ARK Vicki Vale"] = {vp=0, isHostage=true, isOngoing=true, cost=2,},
	-- Locations
	["ARK Ace Chemical Plant"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	["ARK Arkham Asylum"] = {vp=2, isLocation=true, isOngoing=true, cost=6,},
    	["RC The Raft"] = {vp=2, isLocation=true, isOngoing=true, cost=6,},
        ["RC A Balsa"] = {vp=2, isLocation=true, isOngoing=true, cost=6,},
	["ARK Iceberg Lounge"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
		["RC Savage Land"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
		["RC Terra Selvagem"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	-- Super Powers
	["ARK ...Tails You Die"] = {vp=1, isSuperPower=true, cost=4,},
	["ARK Arms Deal"] = {vp=1, isSuperPower=true, cost=3,},
	["ARK Cannibalism"] = {vp=1, isSuperPower=true, isBribe=true, cost=3,},
	["ARK Criminally Insane"] = {vp=1, isSuperPower=true, isBribe=true, cost=3,},
	["ARK Heads You Live..."] = {vp=1, isSuperPower=true, cost=4,},
	["ARK Homicidal Mania"] = {vp=1, isSuperPower=true, isBribe=true, cost=5,},
	["ARK Hulking Strength"] = {vp=2, isSuperPower=true, isBribe=true, cost=6,},
	["ARK Hypnotic Pheromones"] = {vp=1, isSuperPower=true, isDefense=true, cost=4,},
	["ARK Let Chance Decide"] = {vp=1, isSuperPower=true, isBribe=true, cost=2,},
	["ARK Mind Control"] = {vp=1, isSuperPower=true, cost=5,},
	["ARK Unleash the Inmates"] = {vp=3, isSuperPower=true, isBribe=true, cost=7,},
	-- Villains
	["ARK Bane"] = {vp=2, isVillain=true, cost=7,},
	["ARK Black Mask"] = {vp=0, isVillain=true, isExpBribe=true, cost=7,},
	["ARK Firefly"] = {vp=1, isVillain=true, isAttack=true, isBribe=true, cost=4,},
	["ARK Jervis Tetch (Mad Hatter)"] = {vp=1, isVillain=true, isBribe=true, cost=4,},
	["ARK Killer Moth"] = {vp=1, isVillain=true, cost=3,},
	["ARK Kite Man"] = {vp=1, isVillain=true, isBribe=true, cost=5,},
	["ARK Magpie"] = {vp=1, isVillain=true, isBribe=true, cost=3,},
	["ARK Man-Bat"] = {vp=1, isVillain=true, cost=4,},
	["ARK Professor Pyg"] = {vp=2, isVillain=true, cost=6,},
	["ARK Punchline"] = {vp=1, isVillain=true, isDefense=true, cost=5,},
	["ARK Ratcatcher"] = {vp=1, isVillain=true, isBribe=true, cost=2,},
	["ARK Solomon Grundy"] = {vp=1, isVillain=true, isDefense=true, cost=4,},
	["ARK Ventriloquist"] = {vp=1, isVillain=true, cost=2,},
	["ARK Henchmen"] = {vp=1, isVillain=true, cost=3,},
	-- Super Heroes (Bosses)
	["ARK Azrael"] = {vp=5, isHero=true, isBoss=true, cost=10,},
	["ARK Batgirl"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["ARK Batman"] = {vp=7, isHero=true, isBoss=true, cost=14,},
	["ARK Batwoman"] = {vp=5, isHero=true, isBoss=true, cost=10,},
	["ARK Catwoman"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["ARK Huntress"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["ARK James Gordon"] = {vp=4, isHero=true, isStartBoss=true, isBoss=true, cost=8,},
	["ARK Nightwing"] = {vp=6, isHero=true, isBoss=true, cost=12,},
	["ARK Orphan"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["ARK Red Hood"] = {vp=5, isHero=true, isBoss=true, cost=10,},
	["ARK Red Robin"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["ARK Robin"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	-- Oversized Character Cards
	["ARK Poison Ivy"] = {vp=0, isCharacter=true,},
	["ARK Scarecrow"] = {vp=0, isCharacter=true,},
	["ARK The Joker"] = {vp=0, isCharacter=true,},
	["ARK Two Face"] = {vp=0, isCharacter=true,},
	["ARK Harley Quinn"] = {vp=0, isCharacter=true,},
	["ARK Killer Croc"] = {vp=0, isCharacter=true,},
	["ARK Mr. Freeze"] = {vp=0, isCharacter=true,},
	["ARK The Penguin"] = {vp=0, isCharacter=true,},
	["ARK Catwoman Promo"] = {vp=0, isCharacter=true,},
--1)8)A AA Shadows Expansion
	--Equipment
	["SHD Flaming Blade"] = {vp=1, isEquipment=true, cost=5,},
	["SHD Gas Canister"] = {vp=1, isEquipment=true, cost=3, isOngoing=true, isBribe=true,},
	["SHD Soultaker Sword"] = {vp=2, isEquipment=true, cost=6,},
	--Heroes
	["SHD Geo-force"] = {vp=2, isHero=true, cost=6, isBribe=true,},
	["SHD Grace Choi"] = {vp=1, isHero=true, cost=4, isOngoing=true, isBribe=true,},
	["SHD Jim Corrigan"] = {vp=1, isHero=true, cost=3, isBribe=true,},
	["SHD Thunder"] = {vp=1, isHero=true, cost=5, isOngoing=true, isDefense=true,},
	--Locations
	["SHD Lazarus Pit"] = {vp=2, isLocation=true, isOngoing=true, cost=6,},
	["SHD Santa Prisca"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
    	["TV Madripoor"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
        ["TV Madripoor"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	--Super Powers
	["SHD Break the Bat"] = {vp=1, isSuperPower=true, cost=5, isAttack=true,},
	["SHD Hired Hit"] = {vp=1, isSuperPower=true, cost=4, isBribe=true,},
	--Villains
	["SHD Anarky"] = {vp=2, isVillain=true, cost=5, isAttack=true,},
	["SHD Cluemaster"] = {vp=1, isVillain=true, cost=2, isOngoing=true, isBribe=true,},
	["SHD Punch & Jewelee"] = {vp=1, isVillain=true, cost=4, isOngoing=true, isBribe=true,},
	["SHD Victor Zsasz"] = {vp=1, isVillain=true, cost=3, isBribe=true,},
	-- Super Heroes (Bosses)
	["SHD Black Spider"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["SHD Bronze Tiger"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["SHD Cheshire"] = {vp=5, isVillain=true, isBoss=true, isOngoing=true, cost=10,},
	["SHD Deadshot"] = {vp=4, isVillain=true, isStartBoss=true, isBoss=true, isOngoing=true, cost=8,},
	["SHD KGBeast"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["SHD King Snake"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["SHD Lady Clay"] = {vp=6, isVillain=true, isBoss=true, cost=12,},
	["SHD Lady Shiva"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["SHD Orphan (David Cain)"] = {vp=6, isVillain=true, isBoss=true, cost=11, isAttack=true,},
	["SHD Talia Al Ghul"] = {vp=6, isVillain=true, isBoss=true, cost=12,},
	["SHD Ra's Al Ghul"] = {vp=7, isVillain=true, isBoss=true, cost=14,},
	["SHD Bane"] = {vp=7, isVillain=true, isBoss=true, cost=14,},
	["SHD Black Lightning"] = {vp=6, isHero=true, isBoss=true, cost=12,},
	["SHD Katana"] = {vp=5, isHero=true, isBoss=true, cost=10,},
	["SHD Metamorpho"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["SHD Nightwing"] = {vp=7, isHero=true, isBoss=true, cost=14,},
	["SHD The Creeper"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["SHD The Signal"] = {vp=4, isHero=true, isStartBoss=true, isBoss=true, cost=8, isDefense=true,},
	--Oversized Character Cards
	["SHD Ra's Al Ghul MC"] = {vp=0, isCharacter=true,},
	["SHD Bane MC"] = {vp=0, isCharacter=true,},
	["SHD Batgirl (Cassandra Cain)"] = {vp=0, isCharacter=true,},
	["SHD Batman"] = {vp=0, isCharacter=true,},
	["SHD Nightwing"] = {vp=0, isCharacter=true,},
	["SHD Red Hood"] = {vp=0, isCharacter=true,},
	["SHD Robin"] = {vp=0, isCharacter=true,},
	["SHD Oracle"] = {vp=0, isCharacter=true,},
--2)1) Crisis 1
	--Other
	["C1 A Death in the Family"] = {vp=0,},
	["C1 Alternate Reality"] = {vp=0,},
	["C1 Arkham Breakout"] = {vp=0,},
	["C1 Atlantis Attacks"] = {vp=0,},
	["C1 Collapsing Parallel Worlds"] = {vp=0,},
	["C1 Dimension Shift"] = {vp=0,},
	["C1 Electromagnetic Pulse"] = {vp=0,},
	["C1 Final Countdown"] = {vp=0,},
	["C1 Identity Crisis"] = {vp=0,},
	["C1 Kryptonite Meteor"] = {vp=0,},
	["C1 Legion of Doom"] = {vp=0,},
	["C1 Rise of the Rot"] = {vp=0,},
	["C1 Untouchable Villain"] = {vp=0,},
	["C1 Wave of Terror"] = {vp=0,},
	["C1 World Domination"] = {vp=0,},
	--Heroes
	["C1 Animal Man"] = {vp=1, isHero=true, cost=4, id=7516},
	["C1 Captain Atom"] = {vp=2, isHero=true, cost=6, id=2167},
	["C1 John Constantine"] = {vp=1, isHero=true, cost=5, id=8902},
	--Villains
	["C1 Avatar of the Rot"] = {vp=3, isVillain=true, cost=7, id=9672},
	["C1 Killer Frost"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=3920},
	["C1 Psycho Pirate"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=8709},
	["C1 Strife"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=8124},
	--Super Powers
	["C1 Flight"] = {vp=1, isSuperPower=true, isDefense=true, cost=2, id=5262},
	["C1 Magic"] = {vp=1, isSuperPower=true, cost=5, id=7327},
	["C1 Power of the Red"] = {vp=1, isSuperPower=true, cost=4, id=7794},
	--Equipment
	["C1 Bo Staff"] = {vp=1, isEquipment=true, cost=3, id=5736},
	["C1 Magician's Corset"] = {vp=1, isEquipment=true, cost=5, id=9426},
	["C1 Quiver of Arrows"] = {vp=1, isEquipment=true, cost=1, id=6241},
	["C1 Signature Trenchcoat"] = {vp=1, isEquipment=true, cost=4, id=2037},
	--Locations
	["C1 House of Mystery"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=5570},
		["IW1 Brimstone Dimension"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=5570},
		["IW1 Dimensão de Enxofre"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=5570},
	["C1 The Rot"] = {vp=1, isLocation=true, isOngoing=true, cost=1, id=5469},
	--Super Villains
	["C1 Atrocitus"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=9098},
	["C1 Black Manta"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=7571},
	["C1 Brainiac"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=7002},
	["C1 Captain Cold"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=1070},
	["C1 Crisis Anti-Monitor"] = {vp=0, isVillain=true, isBoss=true, cost=13, id=5722},
	["C1 Darkseid"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=8688},
	["C1 Deathstroke"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=7627},
	["C1 Hades"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=4850},
	["C1 Lex Luthor"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=8388},
	["C1 Parallax"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=3976},
	["C1 Ra's Al Ghul"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=9, id=5876},
	["C1 Sinestro"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=4908},
	["C1 The Joker"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=9835},
	--Oversized Character Cards
	["C1 Aquaman"] = {vp=0, isCharacter=true, id=9931},
	["C1 Batman"] = {vp=0, isCharacter=true, id=7009},
	["C1 Cyborg"] = {vp=0, isCharacter=true, id=4937},
	["C1 Green Lantern"] = {vp=0, isCharacter=true, id=5277},
	["C1 Martian Manhunter"] = {vp=0, isCharacter=true, id=8566},
	["C1 Superman"] = {vp=0, isCharacter=true, id=7639},
	["C1 The Flash"] = {vp=0, isCharacter=true, id=8396},
	["C1 Wonderwoman"] = {vp=0, isCharacter=true, id=3947},
	["C1 Animal Man (Character)"] = {vp=0, isCharacter=true, id=7227},
	["C1 Constantine"] = {vp=0, isCharacter=true, id=9229},
	["C1 Green Arrow"] = {vp=0, isCharacter=true, id=5057},
	["C1 Robin"] = {vp=0, isCharacter=true, id=1559},
	["C1 Swamp Thing"] = {vp=0, isCharacter=true, id=8024},
	["C1 Zatanna Zatara"] = {vp=0, isCharacter=true, id=3545},
	--2)2) Crisis 2
	--Other
	["C2 Corrupted Companion"] = {vp=0,},
	["C2 Demonic Summoning"] = {vp=0,},
	["C2 Draining The Emotional Spectrum"] = {vp=0,},
	["C2 Frozen City"] = {vp=0,},
	["C2 Heroic Sacrifice"] = {vp=0,},
	["C2 Hunting Down The Lanterns"] = {vp=0,},
	["C2 Immortal Villain"] = {vp=0,},
	["C2 Manhunter Invasion"] = {vp=0,},
	["C2 Missing Heroes"] = {vp=0,},
	["C2 Reshaping Our World"] = {vp=0,},
	["C2 Rise of the Dead"] = {vp=0,},
	["C2 Seven Deadly Sins Unleashed"] = {vp=0,},
	["C2 Shifting Loyalties"] = {vp=0,},
	["C2 Super-Villains United"] = {vp=0,},
	["C2 Villains in Disguise"] = {vp=0,},
	--Heroes
	["C2 Ganthet"] = {vp=3, isHero=true, cost=8, id=3542},
	["C2 Indigo Tribe"] = {vp=2, isHero=true, cost=7, id=8764},
	["C2 Star Sapphire"] = {vp=1, isHero=true, cost=4, id=6613},
	["C2 The Atom"] = {vp=1, isHero=true, cost=1, id=1055},
	["C2 White Lantern Corps"] = {vp=2, isHero=true, cost=6, id=3086},
	--Villains
	["C2 Black Lantern Aquaman"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=9302},
	["C2 Black Lantern Batman"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=6329},
	["C2 Black Lantern Blue Beetle"] = {vp=2, isVillain=true, isAttack=true, cost=7, id=9096},
	["C2 Black Lantern Green Arrow"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=1349},
	["C2 Black Lantern Martian Manhunter"] = {vp=3, isVillain=true, isAttack=true, cost=8, id=1879},
	["C2 Black Lantern Wonder Woman"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=5094},
	--Super Powers
	["C2 Channeling The Emotional Spectrum"] = {vp=1, isSuperPower=true, cost=3, id=8990},
	["C2 Crystal Shield"] = {vp=1, isSuperPower=true, isDefense=true, cost=4, id=5857},
	["C2 Possession"] = {vp=2, isSuperPower=true, cost=6, id=1173},
	["C2 Rage Blood"] = {vp=1, isSuperPower=true, cost=5, id=9676},
	--Equipment
	["C2 Black Lantern Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, cost=5, id=7525},
	["C2 Escrima Sticks"] = {vp=1, isEquipment=true, cost=2, id=1087},
	["C2 Nth Metal Mace"] = {vp=1, isEquipment=true, cost=3, id=1063},
	["C2 Skull of Batman"] = {vp=2, isEquipment=true, cost=6, id=7925},
	["C2 White Lantern Power Ring"] = {vp=0, isEquipment=true, isExpPowerRing=true, cost=5, id=9986},
	--Locations
	["C2 Atlantis"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=7099},
	["C2 Mogo"] = {vp=2, isLocation=true, isDefense=true, isOngoing=true, cost=7, id=5047},
	--Super Villains
	["C2 Amazo"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=5807},
	["C2 Arkillo"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=4379},
	["C2 Black Adam"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=6077},
	["C2 Black Hand"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=5303},
	["C2 Black Lantern Superman"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=5616},
	["C2 Crisis Nekron"] = {vp=0, isVillain=true, isBoss=true, cost=15, id=3516},
	["C2 Doomsday"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=9042},
	["C2 Graves"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=4031},
	["C2 Hector Hammond"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=9041},
	["C2 H'el"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=8351},
	["C2 Helspont"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=9335},
	["C2 Mongul"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=6362},
	["C2 Mr. Freeze"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=5811},
	["C2 Trigon"] = {vp=5, isVillain=true, isBoss=true, cost=13, id=1870},
	["C2 Vandal Savage"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=9, id=2179},
	--Oversized Character Cards
	["C2 Batgirl"] = {vp=0, isCharacter=true, id=6290},
	["C2 Black Canary"] = {vp=0, isCharacter=true, id=8748},
	["C2 Booster Gold"] = {vp=0, isCharacter=true, id=5900},
	["C2 Hawkman"] = {vp=0, isCharacter=true, id=5115},
	["C2 Nightwing"] = {vp=0, isCharacter=true, id=9573},
	["C2 Red Tornado"] = {vp=0, isCharacter=true, id=7162},
	["C2 Shazam!"] = {vp=0, isCharacter=true, id=6417},
	["C2 Starfire"] = {vp=0, isCharacter=true, id=7537},
	["C2 Indigo-1"] = {vp=0, isCharacter=true, id=8659},
	["C2 Kyle Rayner"] = {vp=0, isCharacter=true, id=1500},
	["C2 Red Lantern Supergirl"] = {vp=0, isCharacter=true, id=3529},
	["C2 Saint Walker"] = {vp=0, isCharacter=true, id=6916},
	["C2 Star Sapphire (Character)"] = {vp=0, isCharacter=true, id=5572},
	["C2 White Lantern Deadman"] = {vp=0, isCharacter=true, id=7928},
	--2)3) Crisis 3
	--Other
	["C3 A City Destroyed"] = {vp=0,},
	["C3 Abandon All Hope"] = {vp=0,},
	["C3 Exposed"] = {vp=0,},
	["C3 Hunted by The Crime Syndicate"] = {vp=0,},
	["C3 Lost in Time"] = {vp=0,},
	["C3 Murder Machine"] = {vp=0,},
	["C3 Permanent Eclipse"] = {vp=0,},
	["C3 Powerless"] = {vp=0,},
	["C3 Psychic Static"] = {vp=0,},
	["C3 Releasing The Prisoners"] = {vp=0,},
	["C3 The Justice League is Dead"] = {vp=0,},
	["C3 The Penalty is Death"] = {vp=0,},
	["C3 This World is Ours"] = {vp=0,},
	["C3 Trinity War"] = {vp=0,},
	["C3 Villains in Control"] = {vp=0,},
	["C3 A Friend in Need"] = {vp=0,},
	["C3 Break The Code"] = {vp=0,},
	["C3 Collector"] = {vp=0,},
	["C3 Heroes and Their Toys"] = {vp=0,},
	["C3 Solo Mission"] = {vp=0,},
	["C3 The Best Defense"] = {vp=0,},
	["C3 Traitor!"] = {vp=0,},
	["C3 Well-Focused"] = {vp=0,},
	["C3 Winner Among Thieves"] = {vp=0,},
	--Heroes
	["C3 Black Orchid"] = {vp=1, isHero=true, isDefense=true, cost=4, id=9507},
	["C3 Frankenstein"] = {vp=2, isHero=true, cost=7, id=1480},
	["C3 Madame Xanadu"] = {vp=1, isHero=true, cost=3, id=1511},
	["C3 Nightmare Nurse"] = {vp=1, isHero=true, cost=5, id=9677},
	--Villains
	["C3 Black Mask"] = {vp=1, isVillain=true, cost=2, id=6977},
	["C3 Copperhead"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=8716},
	["C3 Joker's Daughter"] = {vp=2, isVillain=true, cost=7, id=7901},
	["C3 Shadow Thief"] = {vp=1, isVillain=true, cost=3, id=7483},
	--Super Powers
	["C3 Cat-Like Reflexes"] = {vp=1, isSuperPower=true, cost=3, id=2058},
	["C3 Chlorokinesis"] = {vp=1, isSuperPower=true, isAttack=true, cost=4, id=6877},
	["C3 Iced Over"] = {vp=1, isSuperPower=true, cost=6, id=9305},
	["C3 Savagery"] = {vp=1, isSuperPower=true, cost=1, id=5462},
	--Equipment
	["C3 Boomerang"] = {vp=0, isEquipment=true, cost=7, id=5360},
	["C3 Porthole to Nowhere"] = {vp=1, isEquipment=true, isDefense=true, cost=4, id=5317},
	["C3 Sniper Rifle"] = {vp=1, isEquipment=true, isAttack=true, cost=5, id=6792},
	["C3 Tarot Cards"] = {vp=2, isEquipment=true, cost=6, id=7753},
	--Locations
	["C3 Level 7"] = {vp=1, isLocation=true, isAttack=true, isOngoing=true, cost=7, id=9365},
	["C3 Nanda Parbat"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=6564},
	--Super Villains
	["C3 Atomica"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=6583},
	["C3 Blight"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=12, id=7903},
	["C3 Crisis Mazahs!"] = {vp=7, isVillain=true, isBoss=true, cost=14, id=6576},
	["C3 Deathstorm"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=3108},
	["C3 Felix Faust"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=6316},
	["C3 Grid"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=3081},
	["C3 Johnny Quick"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=1692},
	["C3 Nick Necro"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=8747},
	["C3 Owlman"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=7153},
	["C3 Power Ring"] = {vp=6, isVillain=true, isBoss=true, isPowerRing=true, cost=12, id=7824},
	["C3 Sea King"] = {vp=6, isVillain=true, isBoss=true, isOngoing=true, cost=11, id=7395},
	["C3 Superwoman"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=4581},
	["C3 The Outsider"] = {vp=5, isVillain=true, isBoss=true, isStartBoss=true, cost=9, id=4144},
	["C3 Ultraman"] = {vp=7, isVillain=true, isBoss=true, cost=14, id=7133},
	--Oversized Character Cards
	["C3 Bane"] = {vp=0, isCharacter=true, id=4535},
	["C3 Bizarro"] = {vp=0, isCharacter=true, id=4040},
	["C3 Black Adam"] = {vp=0, isCharacter=true, id=9882},
	["C3 Black Manta"] = {vp=0, isCharacter=true, id=6219},
	["C3 Deathstroke"] = {vp=0, isCharacter=true, id=3986},
	["C3 Harley Quinn"] = {vp=0, isCharacter=true, id=8068},
	["C3 Lex Luthor"] = {vp=0, isCharacter=true, id=3961},
	["C3 Sinestro"] = {vp=0, isCharacter=true, id=5058},
	["C3 Captain Boomerang"] = {vp=0, isCharacter=true, id=6447},
	["C3 Cheetah"] = {vp=0, isCharacter=true, id=5951},
	["C3 Deadshot"] = {vp=0, isCharacter=true, id=1367},
	["C3 Killer Frost"] = {vp=0, isCharacter=true, id=5604},
	["C3 King Shark"] = {vp=0, isCharacter=true, id=9937},
	["C3 Poison Ivy"] = {vp=0, isCharacter=true, id=4022},
	--2)4) Crisis 4
	--Other
	["C4 Depowered"] = {vp=0,},
	["C4 Inflated Ego"] = {vp=0,},
	["C4 Insecure"] = {vp=0,},
	["C4 Malfunction"] = {vp=0,},
	["C4 Out of Control"] = {vp=0,},
	["C4 Sudden Loss"] = {vp=0,},
	["C4 Survivor's Guilt"] = {vp=0,},
	["C4 Trial by Combat"] = {vp=0,},
	["C4 Unappreciated"] = {vp=0,},
	["C4 Unrequited Love"] = {vp=0,},
	["C4 Villainous Lineage"] = {vp=0,},
	["C4 Weakened Heart"] = {vp=0,},
	--Heroes
	["C4 Damian Wayne"] = {vp=1, isHero=true, cost=5, id=5286},
	["C4 Donna Troy"] = {vp=2, isHero=true, isDefense=true, cost=6, id=9723},
	["C4 Omen"] = {vp=2, isHero=true, isOngoing=true, cost=6, id=8216},
	["C4 Wally West"] = {vp=1, isHero=true, isOngoing=true, cost=4, id=1791},
	--Villains
	["C4 Blank"] = {vp=1, isVillain=true, isOngoing=true, cost=1, id=6259},
	["C4 Mara Al Ghul"] = {vp=2, isVillain=true, isOngoing=true, cost=7, id=6984},
	["C4 Nightstorm"] = {vp=1, isVillain=true, isAttack=true, isOngoing=true, cost=3, id=6810},
	["C4 Plague"] = {vp=2, isVillain=true, isAttack=true, isOngoing=true, cost=6, id=4656},
	["C4 Stone"] = {vp=1, isVillain=true, isAttack=true, isOngoing=true, cost=5, id=5281},
	--Super Powers
	["C4 Titans Together"] = {vp=1, isSuperPower=true, isOngoing=true, cost=5, id=7223},
	["C4 Vigilant Guard"] = {vp=1, isSuperPower=true, isDefense=true, cost=2, id=8918},
	["C4 Warm Embrace"] = {vp=1, isSuperPower=true, cost=5, id=4214},
	--Equipment
	["C4 Ancient Map"] = {vp=1, isEquipment=true, isOngoing=true, cost=4, id=3112},
	["C4 Biometric Exo-Suit"] = {vp=1, isEquipment=true, isOngoing=true, cost=2, id=3549},
	["C4 Birthday Cake"] = {vp=1, isEquipment=true, cost=4, id=8727},
	["C4 Waterbearer"] = {vp=1, isEquipment=true, cost=3, id=3950},
	--Locations
	["C4 Infinity Island"] = {vp=2, isLocation=true, isOngoing=true, cost=7, id=9499},
	--Super Villains
	["C4 Blackfire"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=5649},
	["C4 Brother Blood"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=6033},
	["C4 Cheshire"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=4402},
	["C4 Clock King"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=3367},
	["C4 Crisis Dr. Light"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=7489},
	["C4 Crisis Superboy Prime"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=7550},
	["C4 Crisis Trigon"] = {vp=6, isVillain=true, isBoss=true, cost=15, id=3547},
	["C4 Crisis Troia"] = {vp=6, isVillain=true, isBoss=true, cost=10, id=1419},
	["C4 Harvest"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=7514},
	["C4 Psimon"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=8634},
	["C4 Slade Wilson"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=9, id=9473},
	["C4 Terra"] = {vp=5, isVillain=true, isBoss=true, isOngoing=true, cost=11, id=7942},
	["C4 The Brain & Monsieur Mallah"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=6791},
	--Oversized Character Cards
	["C4 Beast Boy"] = {vp=0, isCharacter=true, id=5764},
	["C4 Blue Beetle"] = {vp=0, isCharacter=true, id=8271},
	["C4 Kid Flash"] = {vp=0, isCharacter=true, id=7424},
	["C4 Raven"] = {vp=0, isCharacter=true, id=3460},
	["C4 Red Robin"] = {vp=0, isCharacter=true, id=8130},
	["C4 Starfire"] = {vp=0, isCharacter=true, id=8656},
	["C4 Superboy"] = {vp=0, isCharacter=true, id=5443},
	["C4 Wonder Girl"] = {vp=0, isCharacter=true, id=4708},
	["C4 Arsenal"] = {vp=0, isCharacter=true, id=4774},
	["C4 Donna Troy (Character)"] = {vp=0, isCharacter=true, id=8599},
	["C4 Nightwing"] = {vp=0, isCharacter=true, id=5186},
	["C4 Omen (Character)"] = {vp=0, isCharacter=true, id=5034},
	["C4 Tempest"] = {vp=0, isCharacter=true, id=1991},
	["C4 The Flash"] = {vp=0, isCharacter=true, id=7715},
	--2)5) Crisis 5
	--Equipment
	["C5 Batcycle"] = {vp=2, isEquipment=true, cost=5,},
	["C5 Alfred Box"] = {vp=2, isEquipment=true, cost=6,},
	["C5 Chainsaw of Truth"] = {vp=2, isEquipment=true, cost=7,},
	["C5 Black Lantern Power Ring"] = {vp=3, isEquipment=true, isPowerRing=true, cost=8,},
	["C5 Cloak of Erasure"] = {vp=3, isEquipment=true, isOngoing=true, isDefense=true, cost=9,},
	--Heroes
	["C5 Black Lantern Arsenal"] = {vp=2, isHero=true, cost=5,},
	["C5 Black Lantern Jonah Hex"] = {vp=2, isHero=true, cost=5,},
	["C5 Raven"] = {vp=2, isHero=true, isDefense=true, cost=6,},
	["C5 Jarro"] = {vp=2, isHero=true, isDefense=true, cost=7,},
	["C5 Jay Garrick"] = {vp=2, isHero=true, cost=7,},
	["C5 Mister Miracle"] = {vp=3, isHero=true, isDefense=true, cost=8,},
	--Locations
	["C5 Crypt of Heroes"] = {vp=2, isLocation=true, isOngoing=true, cost=7,},
	--Super Powers
	["C5 Reverse Polarity"] = {vp=2, isSuperPower=true, cost=5,},
	["C5 Godly Ascension"] = {vp=3, isSuperPower=true, cost=8,},
	--Villains
	["C5 Batom"] = {vp=2, isVillain=true, cost=4,},
	["C5 Pararobins"] = {vp=0, isVillain=true, cost=5,},
	["C5 Black Monday"] = {vp=3, isVillain=true, cost=5,},
	["C5 Batmobeast"] = {vp=3, isVillain=true, cost=6,},
	["C5 Joker Dragon"] = {vp=3, isVillain=true, cost=6,},
	["C5 Quietus"] = {vp=3, isVillain=true, cost=6,},
	--Super Villains
	["C5 Bat Mage"] = {vp=6, isVillain=true, isBoss=true, cost=9,},
	["C5 Bathomet"] = {vp=6, isVillain=true, isBoss=true, cost=9,},
	["C5 B. Rex"] = {vp=6, isVillain=true, isBoss=true, cost=9,},
	["C5 The Batman Who Frags"] = {vp=6, isVillain=true, isBoss=true, cost=9,},
	["C5 Baby Batman"] = {vp=7, isVillain=true, isBoss=true, cost=11,},
	["C5 Castle Bat"] = {vp=7, isVillain=true, isBoss=true, cost=11,},
	["C5 Darkfather"] = {vp=7, isVillain=true, isBoss=true, cost=11,},
	["C5 The Mindhunter"] = {vp=7, isVillain=true, isBoss=true, cost=11,},
	--Oversized Character Cards
	["C5 Aquaman"] = {vp=0, isCharacter=true,},
	["C5 Batman"] = {vp=0, isCharacter=true,},
	["C5 Cyborg"] = {vp=0, isCharacter=true,},
	["C5 Hawkgirl"] = {vp=0, isCharacter=true,},
	["C5 Nightwing"] = {vp=0, isCharacter=true,},
	["C5 Superboy Prime"] = {vp=0, isCharacter=true,},
	["C5 Superman"] = {vp=0, isCharacter=true,},
	["C5 Doctor Fate"] = {vp=0, isCharacter=true,},
	["C5 The Flash"] = {vp=0, isCharacter=true,},
	["C5 Harley Quinn"] = {vp=0, isCharacter=true,},
	["C5 Swamp Thing"] = {vp=0, isCharacter=true,},
	["C5 Wally West"] = {vp=0, isCharacter=true,},
	["C5 Wonder Woman"] = {vp=0, isCharacter=true,},
	--2)A)1 Crossover Crisis 1
	--Other
	["CC1 Black Reign"] = {vp=0,},
	["CC1 Injustice For All"] = {vp=0,},
	["CC1 Princes of Darkness"] = {vp=0,},
	["CC1 The King of Tears Ritual"] = {vp=0,},
	--Heroes
	["CC1 Sand"] = {vp=1, isHero=true, isDefense=true, cost=4,},
	--Villains
	["CC1 Killer Wasp"] = {vp=1, isVillain=true, isAttack=true, cost=4,},
	["CC1 Tigress"] = {vp=2, isVillain=true, isAttack=true, cost=6,},
	--Super Powers
	["CC1 Nine Lives"] = {vp=1, isSuperPower=true, cost=5,},
	--Equipment
	["CC1 Starheart"] = {vp=1, isEquipment=true, cost=4,},
	--Super Villains
	["CC1 Crisis Johnny Sorrow"] = {vp=7, isVillain=true, isBoss=true, cost=16,},
	["CC1 Black Adam"] = {vp=6, isVillain=true, isBoss=true, cost=13,},
	["CC1 Eclipso"] = {vp=7, isVillain=true, isBoss=true, cost=14,},
	["CC1 Gentleman Ghost"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["CC1 Icicle"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=8,},
	["CC1 Mordru"] = {vp=7, isVillain=true, isBoss=true, cost=14,},
	["CC1 Obsidian"] = {vp=6, isVillain=true, isBoss=true, cost=12,},
	["CC1 Rag Doll"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["CC1 Solomon Grundy"] = {vp=5, isVillain=true, isBoss=true, isDefense=true, cost=10,},
	--Oversized Character Cards
	["CC1 Crisis Doctor Fate"] = {vp=0, isCharacter=true,},
	["CC1 Crisis Green Lantern"] = {vp=0, isCharacter=true,},
	["CC1 Crisis Mr. Terrific"] = {vp=0, isCharacter=true,},
	["CC1 Crisis Power Girl"] = {vp=0, isCharacter=true,},
	["CC1 Crisis Stargirl"] = {vp=0, isCharacter=true,},
	["CC1 Crisis The Flash"] = {vp=0, isCharacter=true,},
	["CC1 Crisis Wildcat"] = {vp=0, isCharacter=true,},
	--3)1) Rivals 1 - Batman VS The Joker
	--Other
	["R1 Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["R1 Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["R1 Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Heroes
	["R1 Alfred Pennyworth"] = {vp=1, isHero=true, cost=2, id=3896},
	["R1 Batwoman"] = {vp=1, isHero=true, cost=3, id=7521},
	["R1 Black Canary"] = {vp=2, isHero=true, cost=6, id=4894},
	["R1 Catwoman"] = {vp=1, isHero=true, cost=4, id=4480},
	["R1 Commissioner Gordon"] = {vp=1, isHero=true, cost=3, id=3035},
	["R1 Huntress"] = {vp=1, isHero=true, cost=4, id=4083},
	["R1 Lucius Fox"] = {vp=1, isHero=true, isDefense=true, cost=2, id=6016},
	["R1 Nightwing"] = {vp=1, isHero=true, cost=5, id=2118},
	["R1 Oracle"] = {vp=1, isHero=true, cost=4, id=5295},
	["R1 Red Hood"] = {vp=1, isHero=true, cost=3, id=4936},
	["R1 Red Robin"] = {vp=2, isHero=true, cost=6, id=8860},
	["R1 Robin"] = {vp=1, isHero=true, cost=5, id=6165},
	["R1 Superman"] = {vp=3, isHero=true, cost=7, id=4615},
	["R1 Vicky Vale"] = {vp=1, isHero=true, cost=2, id=9866},
	--Villains
	["R1 Bane"] = {vp=1, isVillain=true, cost=4, id=4124},
	["R1 Clayface"] = {vp=1, isVillain=true, cost=3, id=7852},
	["R1 Harley Quinn"] = {vp=1, isVillain=true, cost=3, id=4448},
	["R1 Hugo Strange"] = {vp=2, isVillain=true, cost=6, id=9515},
	["R1 Killer Croc"] = {vp=1, isVillain=true, cost=4, id=8207},
	["R1 Mr. Freeze"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=9073},
	["R1 Poison Ivy"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=8125},
	["R1 Ra's Al Ghul"] = {vp=2, isVillain=true, cost=7, id=2122},
	["R1 Scarecrow"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=5113},
	["R1 Talia Al Ghul"] = {vp=1, isVillain=true, cost=5, id=5622},
	["R1 The Penguin"] = {vp=1, isVillain=true, cost=2, id=6407},
	["R1 The Riddler"] = {vp=1, isVillain=true, cost=2, id=6656},
	["R1 Two-Face"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=9718},
	["R1 Victor Zsasz"] = {vp=1, isVillain=true, cost=2, id=7511},
	--Super Powers
	["R1 Billionaire"] = {vp=1, isSuperPower=true, cost=5, id=6204},
	["R1 Homicidal Maniac"] = {vp=1, isSuperPower=true, cost=3, id=4867},
	["R1 Insanity"] = {vp=1, isSuperPower=true, isDefense=true, cost=2, id=1709},
	["R1 Kick"] = {vp=1, isSuperPower=true, cost=3, id=9883},
	["R1 Killing Joke"] = {vp=3, isSuperPower=true, cost=7, id=4856},
	["R1 Maniacal Laugh"] = {vp=1, isSuperPower=true, cost=4, id=8782},
	["R1 Master Martial Artist"] = {vp=1, isSuperPower=true, cost=4, id=7212},
	["R1 World's Greatest Detective"] = {vp=2, isSuperPower=true, isDefense=true, cost=6, id=9494},
	--Equipment
	["R1 Batarang"] = {vp=1, isEquipment=true, isDefense=true, cost=4, id=4406},
	["R1 Batmobile"] = {vp=1, isEquipment=true, cost=3, id=9093},
	["R1 Grappling Hook"] = {vp=1, isEquipment=true, cost=3, id=8605},
	["R1 Joy Buzzer"] = {vp=1, isEquipment=true, cost=2, id=7671},
	["R1 Laughing Gas"] = {vp=2, isEquipment=true, isAttack=true, cost=6, id=6655},
	["R1 The Bat-Signal"] = {vp=3, isEquipment=true, cost=7, id=7857},
	["R1 Utility Belt"] = {vp=1, isEquipment=true, cost=5, id=7640},
	--Locations
	["R1 Abandoned Amusement Park"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=6140},
	["R1 Arkham Asylum"] = {vp=1, isLocation=true, isOngoing=true, cost=6, id=1412},
	["R1 The Batcave"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=5817},
	["R1 Wayne Manor"] = {vp=1, isLocation=true, isOngoing=true, cost=6, id=3139},
	--Oversized Character Cards
	["R1 Batman (Level 1)"] = {vp=4, isHero=true, isCharacter=true, cost=9, id=5267},
	["R1 Batman (Level 2)"] = {vp=6, isHero=true, isCharacter=true, cost=12, id=1638},
	["R1 Batman (Level 3)"] = {vp=0, isHero=true, isCharacter=true, cost=15, id=8677},
	["R1 The Joker (Level 1)"] = {vp=4, isVillain=true, isCharacter=true, cost=9, id=7197},
	["R1 The Joker (Level 2)"] = {vp=6, isVillain=true, isCharacter=true, cost=12, id=5752},
	["R1 The Joker (Level 3)"] = {vp=0, isVillain=true, isCharacter=true, cost=15, id=8846},
	--3)2) Rivals 2 - Green Lantern vs Sinestro
	--Other
	["R2 Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["R2 Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["R2 Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	["R2 Hard-Light Construct"] = {vp=0, cost=3, id=0},
	--Heroes
	["R2 Arisia"] = {vp=1, isHero=true, cost=3, id=5209},
	["R2 B'dg"] = {vp=1, isHero=true, cost=2, id=6733},
	["R2 Boodikka"] = {vp=1, isHero=true, cost=4, id=4816},
	["R2 Brother Wrath"] = {vp=1, isHero=true, cost=3, id=4019},
	["R2 Carol Ferris"] = {vp=1, isHero=true, cost=5, id=4511},
	["R2 Chaselon"] = {vp=1, isHero=true, isDefense=true, cost=4, id=7874},
	["R2 Ganthet and Sayd"] = {vp=2, isHero=true, cost=7, id=8382},
	["R2 Guy Gardner"] = {vp=2, isHero=true, cost=6, id=7739},
	["R2 Iolande"] = {vp=1, isHero=true, cost=3, id=8452},
	["R2 John Stewart"] = {vp=2, isHero=true, cost=7, id=1545},
	["R2 Kilowog"] = {vp=1, isHero=true, cost=4, id=5224},
	["R2 Kyle Rayner"] = {vp=2, isHero=true, isAttack=true, cost=6, id=9971},
	["R2 Saint Walker"] = {vp=1, isHero=true, cost=5, id=4764},
	["R2 Salaak"] = {vp=1, isHero=true, cost=2, id=1327},
	["R2 Tomar-Tu"] = {vp=1, isHero=true, isDefense=true, cost=4, id=5388},
	["R2 Two-Six"] = {vp=1, isHero=true, isDefense=true, cost=3, id=4192},
	--Villains
	["R2 Arkillo"] = {vp=2, isVillain=true, cost=6, id=7329},
	["R2 Bedovian"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=7185},
	["R2 Bekka"] = {vp=2, isVillain=true, cost=7, id=4612},
	["R2 Despotellis"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=4516},
	["R2 Karu-Sil"] = {vp=1, isVillain=true, cost=4, id=4267},
	["R2 Kryb"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=3493},
	["R2 Lyssa Drak"] = {vp=1, isVillain=true, cost=4, id=1522},
	["R2 Maash"] = {vp=1, isVillain=true, isAttack=true, cost=2, id=9163},
	["R2 Manhunter Army"] = {vp=1, isVillain=true, cost=5, id=2109},
	["R2 Nax"] = {vp=1, isVillain=true, cost=3, id=5482},
	["R2 Parallax"] = {vp=2, isVillain=true, isAttack=true, cost=7, id=5824},
	["R2 Rigen Kale"] = {vp=1, isVillain=true, cost=3, id=8749},
	["R2 Romat-Ru"] = {vp=1, isVillain=true, cost=4, id=5544},
	["R2 Slushh"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=9242},
	["R2 Soranik Natu"] = {vp=2, isVillain=true, isDefense=true, cost=6, id=4743},
	["R2 Tri-Eye"] = {vp=1, isVillain=true, cost=2, id=7677},
	--Super Powers
	["R2 Construct Beasts"] = {vp=1, isSuperPower=true, cost=2, id=6664},
	["R2 Construct Jet"] = {vp=1, isSuperPower=true, cost=4, id=1580},
	["R2 Construct Missiles"] = {vp=1, isSuperPower=true, cost=5, id=8463},
	["R2 Construct Shields"] = {vp=1, isSuperPower=true, cost=4, id=5096},
	["R2 Construct Slam"] = {vp=1, isSuperPower=true, cost=3, id=7044},
	["R2 Construct Train"] = {vp=1, isSuperPower=true, isDefense=true, cost=5, id=7210},
	["R2 Fear"] = {vp=2, isSuperPower=true, cost=6, id=8379},
	["R2 Willpower"] = {vp=2, isSuperPower=true, isDefense=true, cost=7, id=5660},
	--Equipment
	["R2 Book of Parallax"] = {vp=2, isEquipment=true, cost=7, id=1888},
	["R2 Green Lantern Power Battery"] = {vp=2, isEquipment=true, cost=6, id=1600},
	["R2 Green Lantern Power Ring"] = {vp=1, isEquipment=true, isPowerRing=true, isDefense=true, cost=5, id=6406},
	["R2 Interceptor"] = {vp=1, isEquipment=true, cost=5, id=8313},
	["R2 Sinestro Corps Power Rings"] = {vp=1, isEquipment=true, isPowerRing=true, isAttack=true, cost=4, id=7365},
	["R2 Sinestro Power Battery"] = {vp=1, isEquipment=true, cost=5, id=9404},
	--Locations
	["R2 Mogo"] = {vp=1, isLocation=true, isOngoing=true, cost=6, id=5400},
	["R2 New Korugar"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=5589},
	["R2 Oa"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=7408},
		["R2 Midtown High School"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=7408},
		["R2 Colégio Midtown"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=7408},
	["R2 Ranx"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=5357},
	--Oversized Character Cards
	["R2 Green Lantern (Level 1)"] = {vp=4, isHero=true, isCharacter=true, cost=9, id=9521},
	["R2 Green Lantern (Level 2)"] = {vp=6, isHero=true, isCharacter=true, cost=12, id=1544},
	["R2 Green Lantern (Level 3)"] = {vp=0, isHero=true, isCharacter=true, cost=15, id=9274},
	["R2 Sinestro (Level 1)"] = {vp=4, isVillain=true, isCharacter=true, cost=9, id=3513},
	["R2 Sinestro (Level 2)"] = {vp=6, isVillain=true, isCharacter=true, cost=12, id=8671},
	["R2 Sinestro (Level 3)"] = {vp=0, isVillain=true, isCharacter=true, cost=15, id=1141},
	--3)3) Rivals 3 - The Flash vs Reverse-Flash
	--Other
	["R3 Punch"] = {vp=0, isStarter=true, cost=0,},
	["R3 Vulnerability"] = {vp=0, isStarter=true, cost=0,},
	["R3 Weakness"] = {vp=-1, isWeakness=true, isOngoing=true, cost=0,},
	["R3 Super-Speed"] = {vp=-0, cost=3,},
	--Heroes
	["R3 Director Singh"] = {vp=1, isHero=true, cost=2,},
	["R3 Elongated Man"] = {vp=1, isHero=true, cost=3,},
	["R3 Firestorm"] = {vp=1, isHero=true, cost=5,},
	["R3 Frost (Caitlin Snow)"] = {vp=1, isHero=true, isAttack=true, cost=4,},
	["R3 Impulse"] = {vp=1, isHero=true, cost=2,},
	["R3 Iris West"] = {vp=1, isHero=true, cost=4,},
	["R3 Jesse Quick"] = {vp=1, isHero=true, cost=4,},
	["R3 Kid Flash (Wallace West)"] = {vp=2, isHero=true, cost=5,},
	["R3 Kid Flash (Wally West)"] = {vp=3, isHero=true, cost=7,},
	["R3 Max Mercury"] = {vp=2, isHero=true, cost=6,},
	["R3 The Flash (Jay Garrick)"] = {vp=2, isHero=true, cost=6,},
	["R3 Vibe"] = {vp=1, isHero=true, cost=4,},
	["R3 Xs"] = {vp=1, isHero=true, cost=3,},
	--Villains
	["R3 Abra Kadabra"] = {vp=1, isVillain=true, cost=4,},
	["R3 Captain Cold"] = {vp=0, isVillain=true, cost=4,},
	["R3 Doctor Alchemy"] = {vp=1, isVillain=true, cost=4,},
	["R3 Girder"] = {vp=1, isVillain=true, cost=3,},
	["R3 Godspeed"] = {vp=2, isVillain=true, cost=6,},
	["R3 Golden Glider"] = {vp=0, isVillain=true, cost=3,},
	["R3 Gorilla Grodd"] = {vp=1, isVillain=true, cost=4,},
	["R3 Heat Wave"] = {vp=0, isVillain=true, cost=3,},
	["R3 Mirror Master"] = {vp=0, isVillain=true, cost=3,},
	["R3 Negative Flash"] = {vp=2, isVillain=true, cost=5,},
	["R3 Rag Doll"] = {vp=1, isVillain=true, cost=2,},
	["R3 Reverse-Flash (Daniel West)"] = {vp=1, isVillain=true, isDefense=true, cost=5,},
	["R3 The Black Flash"] = {vp=3, isVillain=true, isAttack=true, cost=7,},
	["R3 The Thinker"] = {vp=1, isVillain=true, cost=4,},
	["R3 The Top"] = {vp=1, isVillain=true, cost=3,},
	["R3 Trickster"] = {vp=0, isVillain=true, cost=2,},
	["R3 Turtle"] = {vp=1, isVillain=true, cost=4,},
	["R3 Weather Wizard"] = {vp=0, isVillain=true, isAttack=true, cost=4,},
	["R3 Zoom"] = {vp=4, isVillain=true, cost=8,},
	--Super Powers
	["R3 Accelerated Healing"] = {vp=1, isSuperPower=true, cost=3,},
	["R3 Arm Tornado"] = {vp=2, isSuperPower=true, cost=5,},
	["R3 Disorienting Speed"] = {vp=1, isSuperPower=true, isAttack=true, cost=4,},
	["R3 Flash Time"] = {vp=1, isSuperPower=true, cost=4,},
	["R3 Hard Stop"] = {vp=2, isSuperPower=true, cost=6,},
	["R3 Infinite Mass Punch"] = {vp=3, isSuperPower=true, cost=7,},
	["R3 Phasing"] = {vp=1, isSuperPower=true, isDefense=true, cost=3,},
	["R3 Run On Water"] = {vp=1, isSuperPower=true, cost=2,},
	["R3 Sonic Snap"] = {vp=1, isSuperPower=true,isAttack=true, cost=5,},
	["R3 Speed Clone"] = {vp=1, isSuperPower=true, cost=3,},
	["R3 Think Fast"] = {vp=1, isSuperPower=true, cost=4,},
	["R3 Time Travel"] = {vp=2, isSuperPower=true, cost=6,},
	["R3 Vibrating Hand"] = {vp=2, isSuperPower=true, cost=5,},
	--Equipment
	["R3 Cosmic Treadmill"] = {vp=3, isEquipment=true, cost=6,},
	["R3 Lightning Rod"] = {vp=3, isEquipment=true, cost=7,},
	["R3 Speedster Suit"] = {vp=1, isEquipment=true, isDefense=true, cost=5,},
	["R3 The Flash Ring"] = {vp=1, isEquipment=true, cost=4,},
	["R3 Weather Wand"] = {vp=2, isEquipment=true, cost=6,},
	--Locations
	["R3 Central City PD"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["R3 S.T.A.R. Labs"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["R3 The Flash Museum"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["R3 The Negative Speed Force"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["R3 The Speed Force"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	--Oversized Character Cards
	["R3 Reverse-Flash (Level 1)"] = {vp=4, isVillain=true, isCharacter=true, cost=9,},
	["R3 Reverse-Flash (Level 2)"] = {vp=6, isVillain=true, isCharacter=true, cost=12,},
	["R3 Reverse-Flash (Level 3)"] = {vp=0, isVillain=true, isCharacter=true, cost=15,},
	["R3 The Flash (Level 1)"] = {vp=4, isHero=true, isCharacter=true, cost=9,},
	["R3 The Flash (Level 2)"] = {vp=6, isHero=true, isCharacter=true, cost=12,},
	["R3 The Flash (Level 3)"] = {vp=0, isHero=true, isCharacter=true, cost=15,},
	--3)4) Rivals 4 - Shazam! vs Black Adam
	--Other
	["R4 Punch"] = {vp=0, isStarter=true, cost=0,},
	["R4 Vulnerability"] = {vp=0, isStarter=true, cost=0,},
	["R4 Weakness"] = {vp=-1, isWeakness=true, isOngoing=true, cost=0,},
	["R4 Weakness (DCDB)"] = {vp=-1, isWeakness=true, cost=0,},
	--Heroes
	["R4 Atom Smasher"] = {vp=1, isHero=true, cost=3,},
	["R4 Cyclone"] = {vp=1, isHero=true, isBlock=true, blockValue=2, cost=4,},
	["R4 Darla Dudley"] = {vp=1, isHero=true, cost=2,},
	["R4 Doctor Fate"] = {vp=3, isHero=true, cost=8,},
	["R4 Eugene Choi"] = {vp=1, isHero=true, isDefense=true, cost=2,},
	["R4 Freddy Freeman"] = {vp=1, isHero=true, cost=4,},
	["R4 Hawkgirl"] = {vp=1, isHero=true, isDefense=true, cost=5,},
	["R4 Hawkman"] = {vp=2, isHero=true, cost=6,},
	["R4 Hippolyta"] = {vp=2, isHero=true, isBlock=true, blockValue=3, cost=5,},
	["R4 Isis"] = {vp=2, isHero=true, isDefense=true, cost=5,},
	["R4 Mary Marvel"] = {vp=1, isHero=true, cost=4,},
	["R4 Osiris"] = {vp=1, isHero=true, isConfrontation=true, cost=5,},
	["R4 Pedro Pena"] = {vp=1, isHero=true, cost=3,},
	["R4 Rosa & Victor Vasquez"] = {vp=1, isHero=true, cost=3,},
	["R4 Stargirl"] = {vp=1, isHero=true, cost=4,},
	["R4 Tawky Tawny"] = {vp=1, isHero=true, isDefense=true, cost=4,},
	["R4 The Wizard"] = {vp=2, isHero=true, cost=7,},
	--Villains
	["R4 Death"] = {vp=2, isVillain=true, cost=7,},
	["R4 Dr. Sivana"] = {vp=1, isVillain=true, cost=4,},
	["R4 Envy"] = {vp=1, isVillain=true, cost=3,},
	["R4 Famine"] = {vp=1, isVillain=true, cost=5,},
	["R4 Felix Faust"] = {vp=2, isVillain=true, isConfrontation=true, cost=5,},
	["R4 Gluttony"] = {vp=1, isVillain=true, isConfrontation=true, cost=3,},
	["R4 Greed"] = {vp=1, isVillain=true, cost=3,},
	["R4 Lust"] = {vp=1, isVillain=true, isAttack=true, cost=3,},
	["R4 Mister Mind"] = {vp=1, isVillain=true, cost=4,},
	["R4 Pestilence"] = {vp=2, isVillain=true, isAttack=true, isConfrontation=true, cost=6,},
	["R4 Pride"] = {vp=2, isVillain=true, cost=4,},
	["R4 Psycho-Pirate"] = {vp=1, isVillain=true, isAttack=true, isDefense=true, cost=3,},
	["R4 Sabbac"] = {vp=2, isVillain=true, isAttack=true, cost=6,},
	["R4 Sloth"] = {vp=1, isVillain=true, cost=3,},
	["R4 The Monster Society"] = {vp=1, isVillain=true, cost=5,},
	["R4 War"] = {vp=1, isVillain=true, cost=5,},
	["R4 Wrath"] = {vp=1, isVillain=true, cost=4,},
	--Super Powers
	["R4 Courage of Achilles"] = {vp=2, isSuperPower=true, cost=6,},
	["R4 Courage of Mehen"] = {vp=2, isSuperPower=true, cost=7,},
	["R4 Power of Aten"] = {vp=2, isSuperPower=true, cost=6,},
	["R4 Power of Zeus"] = {vp=1, isSuperPower=true, isAttack=true, cost=5,},
	["R4 Speed of Mercury"] = {vp=2, isSuperPower=true, cost=7,},
	["R4 Stamina of Atlas"] = {vp=1, isSuperPower=true, cost=4,},
	["R4 Stamina of Shu"] = {vp=1, isSuperPower=true, cost=2,},
	["R4 Strength of Amon"] = {vp=1, isSuperPower=true, cost=4,},
	["R4 Strength of Hercules"] = {vp=1, isSuperPower=true, cost=3,},
	["R4 Swiftness of Horus"] = {vp=1, isSuperPower=true, cost=3,},
	["R4 Wisdom of Solomon"] = {vp=1, isSuperPower=true, cost=2,},
	["R4 Wisdom of Zehuti"] = {vp=1, isSuperPower=true, cost=5,},
	["R4 Word of Power"] = {vp=0, isSuperPower=true, cost=3,},
	--Equipment
	["R4 Amulet of Isis"] = {vp=1, isEquipment=true, cost=5,},
	["R4 Book of Champions"] = {vp=1, isEquipment=true, cost=4,},
	["R4 Encyclopedia of Magical Monsters"] = {vp=1, isEquipment=true, cost=4,},
	["R4 Magical Subway"] = {vp=1, isEquipment=true, cost=3,},
	["R4 Wizard Staff"] = {vp=2, isEquipment=true, isDefense=true, cost=7,},
	--Locations
	["R4 Khandaq"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["R4 Rock of Eternity"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	--Oversized Character Cards
	["R4 Black Adam (Level 1)"] = {vp=4, isVillain=true, isCharacter=true, cost=9,},
	["R4 Black Adam (Level 2)"] = {vp=6, isVillain=true, isCharacter=true, cost=12,},
	["R4 Black Adam (Level 3)"] = {vp=0, isVillain=true, isCharacter=true, cost=15,},
	["R4 Shazam! (Level 1)"] = {vp=4, isHero=true, isCharacter=true, cost=9,},
	["R4 Shazam! (Level 2)"] = {vp=6, isHero=true, isCharacter=true, cost=12,},
	["R4 Shazam! (Level 3)"] = {vp=0, isHero=true, isCharacter=true, cost=15,},
	--3)5) Rivals 5 - Superman vs Lex Luthor
	-- Equipment
	["R5 Hologram Projector"] = {vp=1, isEquipment=true, cost=2,},
	["R5 Brainiac Drone"] = {vp=1, isEquipment=true, cost=3,},
	["R5 Kryptonite"] = {vp=1, isEquipment=true, cost=4,},
	["R5 Power Armor"] = {vp=1, isEquipment=true, cost=4,},
	["R5 Superman Robot"] = {vp=2, isEquipment=true, cost=5,},
	["R5 Steel's Hammer"] = {vp=2, isEquipment=true, cost=6,},
	["R5 Skull Ship"] = {vp=2, isEquipment=true, cost=7,},
	-- Heroes
	["R5 Cat Grant"] = {vp=1, isHero=true, cost=2,},
	["R5 Jimmy Olsen"] = {vp=1, isHero=true, cost=2,},
	["R5 Krypto"] = {vp=1, isHero=true, cost=4,},
	["R5 Lois Lane"] = {vp=1, isHero=true, cost=4,},
	["R5 Superboy"] = {vp=1, isHero=true, cost=5,},
	["R5 Steel"] = {vp=2, isHero=true, cost=5,},
	["R5 Jon Kent"] = {vp=2, isHero=true, cost=6,},
	["R5 Power Girl"] = {vp=2, isHero=true, cost=6,},
	["R5 Supergirl"] = {vp=2, isHero=true, cost=7,},
	-- Other
	["R5 Men of Tomorrow"] = {vp=0, cost=3,},
	-- Locations
	["R5 Fortress of Solitude"] = {vp=2, isLocation=true, isOngoing=true, cost=5,},
		["R5 Sanctum Sanctorium"] = {vp=2, isLocation=true, isOngoing=true, cost=5,},
		["R5 Sanctum Sanctorium"] = {vp=2, isLocation=true, isOngoing=true, cost=5,},
	["R5 Metropolis"] = {vp=2, isLocation=true, isOngoing=true, cost=5,},
    	["R5 Daily Bugle"] = {vp=2, isLocation=true, isOngoing=true, cost=5,},
        ["R5 Clarim Diário"] = {vp=2, isLocation=true, isOngoing=true, cost=5,},
	["R5 Stryker's Island Penitentiary"] = {vp=2, isLocation=true, isOngoing=true, cost=6,},
	-- Super Powers
	["R5 Corrupt Dealing"] = {vp=1, isSuperPower=true, cost=2,},
	["R5 Super Hearing"] = {vp=1, isSuperPower=true, cost=3,},
	["R5 Heat Vision"] = {vp=1, isSuperPower=true, cost=4,},
	["R5 Nefarious Planning"] = {vp=1, isSuperPower=true, cost=4,},
	["R5 Flight"] = {vp=2, isSuperPower=true, cost=7,},
	-- Villains
	["R5 Eve Teschmacher"] = {vp=1, isVillain=true, cost=2,},
	["R5 Atomic Skull"] = {vp=1, isVillain=true, cost=3,},
	["R5 Bruno Mannheim"] = {vp=1, isVillain=true, cost=3,},
	["R5 Mercy Graves"] = {vp=1, isVillain=true, cost=3,},
	["R5 Silver Banshee"] = {vp=1, isVillain=true, cost=3,},
	["R5 Lena Luthor"] = {vp=1, isVillain=true, cost=4,},
	["R5 Livewire"] = {vp=1, isVillain=true, cost=4,},
	["R5 Cyborg Superman"] = {vp=1, isVillain=true, cost=5,},
	["R5 Bizarro"] = {vp=2, isVillain=true, cost=5,},
	["R5 Eradicator"] = {vp=2, isVillain=true, cost=5,},
	["R5 Mr. Mxyzptlk"] = {vp=2, isVillain=true, cost=6,},
	["R5 Doomsday"] = {vp=2, isVillain=true, cost=7,},
	-- Oversized Character Cards
	["R5 Superman (Level 2)"] = {vp=6, isCharacter=true,},
	["R5 Lex Luthor (Level 3)"] = {vp=0, isCharacter=true,},
	["R5 Lex Luthor (Level 1)"] = {vp=4, isCharacter=true,},
	["R5 Superman (Level 3)"] = {vp=0, isCharacter=true,},
	["R5 Superman (Level 1)"] = {vp=4, isCharacter=true,},
	["R5 Lex Luthor (Level 2)"] = {vp=6, isCharacter=true,},
	--3)A) Confrontations
	--Other
	["RC Enhanced Strength"] = {vp=0, isStarter=true, cost=0, id=0},
	["RC Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["RC Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["RC Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--heroes
	["RC Animal Man"] = {vp=1, isHero=true, cost=4, id=6353},
	["RC Ares"] = {vp=3, isHero=true, cost=7, id=9972},
	["RC Blue Devil"] = {vp=1, isHero=true, isDefense=true, cost=4, id=9933},
	["RC Deadman"] = {vp=1, isHero=true, cost=3, id=6429},
	["RC Doctor Fate"] = {vp=2, isHero=true, cost=6, id=4629},
	["RC Donna Troy"] = {vp=1, isHero=true, isDefense=true, cost=5, id=2138},
	["RC Hephaestus"] = {vp=1, isHero=true, cost=5, id=9490},
	["RC Hera"] = {vp=1, isHero=true, cost=5, id=9544},
	["RC Hermes"] = {vp=1, isHero=true, cost=5, id=3583},
	["RC Jimmy Olsen"] = {vp=1, isHero=true, cost=2, id=7205},
	["RC John Constantine"] = {vp=1, isHero=true, cost=4, id=7005},
	["RC Krypto"] = {vp=1, isHero=true, isDefense=true, cost=3, id=5000},
	["RC Lana Lang"] = {vp=1, isHero=true, cost=3, id=5442},
	["RC Lois Lane"] = {vp=1, isHero=true, cost=4, id=8254},
	["RC Madame Xanadu"] = {vp=1, isHero=true, cost=4, id=5896},
	["RC Mera"] = {vp=1, isHero=true, cost=4, id=8534},
	["RC Orion"] = {vp=2, isHero=true, cost=6, id=6028},
	["RC Poseidon"] = {vp=2, isHero=true, cost=6, id=5231},
	["RC Ragman"] = {vp=1, isHero=true, cost=3, id=7178},
	["RC Steel"] = {vp=1, isHero=true, cost=3, id=1840},
	["RC Steve Trevor"] = {vp=1, isHero=true, isDefense=true, cost=3, id=9268},
	["RC Superboy"] = {vp=1, isHero=true, cost=4, id=4043},
	["RC Supergirl"] = {vp=1, isHero=true, cost=5, id=9077},
	["RC Swamp Thing"] = {vp=2, isHero=true, cost=7, id=1461},
	["RC Tempest"] = {vp=1, isHero=true, cost=3, id=6213},
	["RC The Others"] = {vp=1, isHero=true, isDefense=true, cost=3, id=6352},
	["RC Toymaster"] = {vp=1, isHero=true, cost=5, id=4417},
	["RC Tula"] = {vp=1, isHero=true, cost=2, id=7321},
	["RC Ya'wara"] = {vp=1, isHero=true, cost=2, id=1491},
	--Villains
	["RC Amazo"] = {vp=1, isVillain=true, cost=4, id=5713},
	["RC Apollo"] = {vp=3, isVillain=true, cost=7, id=7155},
	["RC Artemis"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=8546},
	["RC Atlan"] = {vp=1, isVillain=true, cost=4, id=2101},
	["RC Bizarro"] = {vp=1, isVillain=true, cost=6, id=9439},
	["RC Black Manta"] = {vp=1, isVillain=true, cost=3, id=6914},
	["RC Blackbriar Thorn"] = {vp=1, isVillain=true, cost=3, id=3500},
	["RC Cheetah"] = {vp=1, isVillain=true, cost=4, id=8217},
	["RC Chimera"] = {vp=1, isVillain=true, cost=4, id=8797},
	["RC Doctor Destiny"] = {vp=1, isVillain=true, isDefense=true, cost=3, id=4534},
	["RC Doomsday"] = {vp=1, isVillain=true, cost=5, id=4747},
	["RC Eclipso"] = {vp=1, isVillain=true, cost=6, id=1920},
	["RC Enchantress"] = {vp=1, isVillain=true, cost=4, id=1221},
	["RC Etrigan"] = {vp=1, isVillain=true, cost=5, id=6693},
	["RC Faora"] = {vp=1, isVillain=true, cost=5, id=9032},
	["RC First Born"] = {vp=2, isVillain=true, cost=6, id=4700},
	["RC Giganta"] = {vp=1, isVillain=true, isDefense=true, cost=3, id=5897},
	["RC King Shark"] = {vp=1, isVillain=true, cost=2, id=7624},
	["RC Klarion"] = {vp=1, isVillain=true, cost=5, id=6266},
	["RC Magog"] = {vp=2, isVillain=true, cost=7, id=7215},
	["RC Metallo"] = {vp=1, isVillain=true, cost=4, id=6606},
	["RC Nereus"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=4838},
	["RC Parasite"] = {vp=1, isVillain=true, cost=3, id=5677},
	["RC Silver Banshee"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=7399},
	["RC Siren"] = {vp=1, isVillain=true, cost=3, id=6783},
	["RC Strife"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=2041},
	["RC The Creeper"] = {vp=1, isVillain=true, cost=2, id=9396},
	["RC The Trench"] = {vp=1, isVillain=true, cost=2, id=3899},
	["RC Zod"] = {vp=1, isVillain=true, cost=5, id=1395},
	--Super Powers
	["RC Cold Breath"] = {vp=2, isSuperPower=true, cost=6, id=1178},
	["RC Dark Arts"] = {vp=1, isSuperPower=true, cost=4, id=9965},
	["RC Flight"] = {vp=1, isSuperPower=true, cost=3, id=8243},
	["RC Illusions"] = {vp=1, isSuperPower=true, cost=5, id=8409},
	["RC Impervious"] = {vp=2, isSuperPower=true, isDefense=true, cost=7, id=9917},
	["RC Mystic Control"] = {vp=1, isSuperPower=true, isAttack=true, cost=4, id=1584},
	["RC Pots!"] = {vp=1, isSuperPower=true, cost=2, id=8912},
	["RC Scientific Genius"] = {vp=2, isSuperPower=true, cost=7, id=4319},
	["RC Strength of the Gods"] = {vp=1, isSuperPower=true, cost=4, id=8968},
	["RC Tegrof!"] = {vp=1, isSuperPower=true, isAttack=true, cost=5, id=4550},
	["RC Telepathy"] = {vp=1, isSuperPower=true, cost=3, id=1856},
	["RC Water Control"] = {vp=1, isSuperPower=true, isDefense=true, cost=4, id=9799},
	--Equipment
	["RC Amazo Virus"] = {vp=2, isEquipment=true, cost=7, id=7059},
	["RC Black Diamond"] = {vp=1, isEquipment=true, cost=5, id=7236},
	["RC Book of Magic"] = {vp=2, isEquipment=true, cost=7, id=7607},
	["RC Crown of Atlantis"] = {vp=1, isEquipment=true, cost=4, id=8127},
	["RC Dead King's Sceptor"] = {vp=1, isEquipment=true, isAttack=true, cost=4, id=4960},
	["RC Globe of Transportation"] = {vp=1, isEquipment=true, cost=6, id=3998},
	["RC Kryptonite"] = {vp=1, isEquipment=true, isAttack=true, cost=5, id=9314},
	["RC Magic Bracelets"] = {vp=1, isEquipment=true, cost=3, id=9666},
	["RC Phantom Zone Projector"] = {vp=1, isEquipment=true, cost=3, id=5073},
	["RC Power Armor"] = {vp=1, isEquipment=true, cost=4, id=9487},
	["RC Trident of Lucifer"] = {vp=1, isEquipment=true, cost=5, id=4105},
	["RC Trident of Neptune"] = {vp=1, isEquipment=true, cost=2, id=1100},
	--Locations
	["RC Amnesty Bay"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4403},
    	["CW Muir Island"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4403},
        ["CW Ilha Muir"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4403},
	["RC Daily Planet"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4033},
	["RC Lex Corp"] = {vp=1, isLocation=true, isOngoing=true, cost=6, id=1167},
	["RC Olympus"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=8381},
	["RC The Deep"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=7546},
	["RC Themyscira"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=6131},
	--Oversized Character Cards
	["RC Aquaman (Level 1)"] = {vp=4, isHero=true, isCharacter=true, cost=9, id=8514},
	["RC Aquaman (Level 2)"] = {vp=6, isHero=true, isCharacter=true, cost=12, id=6360},
	["RC Aquaman (Level 3)"] = {vp=0, isHero=true, isCharacter=true, cost=15, id=4419},
	["RC Superman (Level 1)"] = {vp=4, isHero=true, isCharacter=true, cost=9, id=7243},
	["RC Superman (Level 2)"] = {vp=6, isHero=true, isCharacter=true, cost=12, id=5356},
	["RC Superman (Level 3)"] = {vp=0, isHero=true, isCharacter=true, cost=15, id=6529},
	["RC Wonder Woman (Level 1)"] = {vp=4, isHero=true, isCharacter=true, cost=9, id=1433},
	["RC Wonder Woman (Level 2)"] = {vp=6, isHero=true, isCharacter=true, cost=12, id=9713},
	["RC Wonder Woman (Level 3)"] = {vp=0, isHero=true, isCharacter=true, cost=15, id=7179},
	["RC Zatanna Zatara (Level 1)"] = {vp=4, isHero=true, isCharacter=true, cost=9, id=8752},
	["RC Zatanna Zatara (Level 2)"] = {vp=6, isHero=true, isCharacter=true, cost=12, id=7569},
	["RC Zatanna Zatara (Level 3)"] = {vp=0, isHero=true, isCharacter=true, cost=15, id=8093},
	["RC Circe (Level 1)"] = {vp=4, isVillain=true, isCharacter=true, cost=9, id=1749},
	["RC Circe (Level 2)"] = {vp=6, isVillain=true, isCharacter=true, cost=12, id=8459},
	["RC Circe (Level 3)"] = {vp=0, isVillain=true, isCharacter=true, cost=15, id=2129},
	["RC Felix Faust (Level 1)"] = {vp=4, isVillain=true, isCharacter=true, cost=9, id=7822},
	["RC Felix Faust (Level 2)"] = {vp=6, isVillain=true, isCharacter=true, cost=12, id=9978},
	["RC Felix Faust (Level 3)"] = {vp=0, isVillain=true, isCharacter=true, cost=15, id=1354},
	["RC Lex Luthor (Level 1)"] = {vp=4, isVillain=true, isCharacter=true, cost=9, id=4725},
	["RC Lex Luthor (Level 2)"] = {vp=6, isVillain=true, isCharacter=true, cost=12, id=8815},
	["RC Lex Luthor (Level 3)"] = {vp=0, isVillain=true, isCharacter=true, cost=15, id=7042},
	["RC Ocean Master (Level 1)"] = {vp=4, isVillain=true, isCharacter=true, cost=9, id=5214},
	["RC Ocean Master (Level 2)"] = {vp=6, isVillain=true, isCharacter=true, cost=12, id=8779},
	["RC Ocean Master (Level 3)"] = {vp=0, isVillain=true, isCharacter=true, cost=15, id=9425},
	--4)1) Crossover 1 - Justice Society of America
	--Heroes
	["CO1 Citizen Steel"] = {vp=1, isHero=true, cost=5, id=9191},
	["CO1 Dr. Mid-Nite"] = {vp=1, isHero=true, cost=4, id=6666},
	["CO1 Liberty Belle"] = {vp=1, isHero=true, isDefense=true, cost=3, id=5755},
	--Villains
	["CO1 Per Degaton"] = {vp=1, isVillain=true, cost=5, id=1671},
	["CO1 Scythe"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=8500},
	--Super Powers
	["CO1 Girl Power"] = {vp=1, isSuperPower=true, isDefense=true, cost=5, id=2045},
	["CO1 Mystic Bolts"] = {vp=2, isSuperPower=true, cost=6, id=6766},
	--Equipment
	["CO1 Hourglass"] = {vp=1, isEquipment=true, cost=4, id=5645},
	["CO1 T-Spheres"] = {vp=2, isEquipment=true, cost=6, id=6097},
	--Locations
	["CO1 Monument Point"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=1030},
		["CO1 Wakanda"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=1030},
		["CO1 Wakanda"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=1030},
	--Super Villains
	["CO1 Eclipso"] = {vp=7, isVillain=true, isBoss=true, cost=14, id=5945},
	["CO1 Gentleman Ghost"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=9924},
	["CO1 Gog"] = {vp=7, isVillain=true, isBoss=true, cost=15, id=9811},
	["CO1 Icicle"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=7964},
	["CO1 Kobra"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=4562},
	["CO1 Mordru The Merciless"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=4740},
	["CO1 Solomon Grundy"] = {vp=0, isVillain=true, isBoss=true, isStartBoss=true, cost=8, id=6879},
	["CO1 Ultra-Humanite"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=9341},
	--Oversized Character Cards
	["CO1 Alan Scott"] = {vp=0, isCharacter=true, id=4559},
	["CO1 Doctor Fate"] = {vp=0, isCharacter=true, id=4767},
	["CO1 Jay Garrick"] = {vp=0, isCharacter=true, id=5596},
	["CO1 Mister Terrific"] = {vp=0, isCharacter=true, id=1664},
	["CO1 Power Girl"] = {vp=0, isCharacter=true, id=9021},
	["CO1 Stargirl"] = {vp=0, isCharacter=true, id=1790},
	["CO1 Wildcat"] = {vp=0, isCharacter=true, id=3552},
	--4)2) Crossover 2 - Arrow - The Television Series
	--Heroes
	["CO2 Detective Lance"] = {vp=2, isHero=true, cost=6, id=1517},
	["CO2 Laurel Lance"] = {vp=1, isHero=true, cost=2, id=8692},
	["CO2 Moira Queen"] = {vp=0, isHero=true, cost=3, id=9092},
	["CO2 Shado"] = {vp=1, isHero=true, isDefense=true, cost=4, id=9549},
	--Villains
	["CO2 Bronze Tiger"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=5217},
	["CO2 Huntress"] = {vp=1, isVillain=true, cost=5, id=6557},
	["CO2 Mr. Blank"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=1964},
	--Super Powers
	["CO2 Mirakuru"] = {vp=1, isSuperPower=true, cost=5, id=9970},
	["CO2 Promise to a Friend"] = {vp=1, isSuperPower=true, isOngoing=true, cost=3, id=4318},
	["CO2 You Have Failed This City"] = {vp=1, isSuperPower=true, isAttack=true, cost=5, id=8407},
	--Equipment
	["CO2 Arrow's Bow"] = {vp=1, isEquipment=true, cost=3, id=4669},
	["CO2 Collapsible Staff"] = {vp=1, isEquipment=true, cost=4, id=7484},
	["CO2 Explosive Arrow"] = {vp=1, isEquipment=true, isAttack=true, cost=2, id=1764},
	--Locations
	["CO2 Verdant"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=6086},
	--Super Villains
	["CO2 Brother Blood"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=6591},
	["CO2 China White"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=6400},
	["CO2 Count Vertigo"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=9780},
	["CO2 Deadshot"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=4194},
	["CO2 Edward Fyers"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=8, id=9252},
	["CO2 Isabel Rochev"] = {vp=7, isVillain=true, isBoss=true, cost=14, id=4498},
	["CO2 Malcolm Merlyn"] = {vp=6, isVillain=true, isBoss=true, isDefense=true, cost=12, id=5870},
	["CO2 Slade Wilson"] = {vp=7, isVillain=true, isBoss=true, cost=15, id=1595},
	--Oversized Character Cards
	["CO2 Felicity Smoak"] = {vp=0, isCharacter=true, id=6272},
	["CO2 John Diggle"] = {vp=0, isCharacter=true, id=1315},
	["CO2 Oliver Queen"] = {vp=0, isCharacter=true, id=8690},
	["CO2 Roy Harper"] = {vp=0, isCharacter=true, id=6182},
	["CO2 Sara Lance"] = {vp=0, isCharacter=true, id=8386},
	--4)3) Crossover 3 - Legion of Super-Heroes
	--Heroes
	["CO3 Dawnstar"] = {vp=1, isHero=true, cost=2, id=5424},
	["CO3 Dream Girl"] = {vp=1, isHero=true, cost=3, id=5850},
	["CO3 Mon-El"] = {vp=2, isHero=true, isDefense=true, cost=6, id=1132},
	["CO3 Starman"] = {vp=1, isHero=true, cost=5, id=6299},
	--Villains
	["CO3 Computo"] = {vp=1, isVillain=true, cost=2, id=3400},
	["CO3 Cosmic King"] = {vp=1, isVillain=true, cost=4, id=6638},
	["CO3 Universo"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=7801},
	--Super Powers
	["CO3 Electricity"] = {vp=1, isSuperPower=true, cost=4, id=8431},
	["CO3 Magnetism"] = {vp=2, isSuperPower=true, cost=6, id=2002},
	["CO3 Telepathy"] = {vp=1, isSuperPower=true, cost=5, id=4089},
	--Equipment
	["CO3 Legion Flight Ring"] = {vp=1, isEquipment=true, isDefense=true, cost=3, id=7008},
	["CO3 Lightning Rod"] = {vp=1, isEquipment=true, cost=4, id=8989},
	["CO3 Time Sphere"] = {vp=1, isEquipment=true, cost=5, id=1809},
	--Locations
	["CO3 Legion Headquarters"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=6972},
	--Super Villains
	["CO3 Emerald Empress"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=11, id=3940},
	["CO3 Lightning Lord"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=13, id=5139},
	["CO3 Mano"] = {vp=5, isVillain=true, isBoss=true, isAttack=true, cost=9, id=8377},
	["CO3 Persuader"] = {vp=7, isVillain=true, isBoss=true, isAttack=true, cost=15, id=5269},
	["CO3 Saturn Queen"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=8, id=7314},
	["CO3 Tharok"] = {vp=5, isVillain=true, isBoss=true, isAttack=true, cost=10, id=4229},
	["CO3 Time Trapper"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=12, id=8948},
	["CO3 Validus"] = {vp=7, isVillain=true, isBoss=true, isAttack=true, cost=14, id=1983},
	--Oversized Character Cards
	["CO3 Brainiac 5"] = {vp=0, isCharacter=true, id=7470},
	["CO3 Chameleon Boy"] = {vp=0, isCharacter=true, id=8002},
	["CO3 Cosmic Boy"] = {vp=0, isCharacter=true, id=4678},
	["CO3 Lightning Lad"] = {vp=0, isCharacter=true, id=9641},
	["CO3 Phantom Girl"] = {vp=0, isCharacter=true, id=3411},
	["CO3 Saturn Girl"] = {vp=0, isCharacter=true, id=6119},
	--4)4) Crossover 4 - Watchmen
	--Heroes
	["CO4 Hollis Mason"] = {vp=2, isHero=true, cost=6, id=3449},
	["CO4 Sally Juspeczyk"] = {vp=1, isHero=true, cost=4, id=1142},
	--Villains
	["CO4 Moloch The Mystic"] = {vp=2, isVillain=true, cost=7, id=9289},
	["CO4 Rioters"] = {vp=2, isVillain=true, cost=6, id=8908},
	--Super Powers
	["CO4 Disintergration"] = {vp=3, isSuperPower=true, cost=8, id=5511},
	["CO4 Duplication"] = {vp=2, isSuperPower=true, cost=7, id=6707},
	["CO4 Reconstruction"] = {vp=2, isSuperPower=true, cost=6, id=8050},
	--Equipment
	["CO4 Nite Owl Mask"] = {vp=1, isEquipment=true, cost=4, id=9652},
	["CO4 Rorschach Mask"] = {vp=1, isEquipment=true, cost=5, id=1876},
	["CO4 The Owlship"] = {vp=2, isEquipment=true, cost=4, id=8390},
	--Locations
	["CO4 New York City"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=5586},
	--Others
	["CO4 Keane Act"] = {vp=0, cost=9},
	["CO4 Rioting"] = {vp=0, cost=9},
	["CO4 Cancer Scare"] = {vp=0, cost=11},
	["CO4 Nixon"] = {vp=0, cost=11},
	["CO4 Alien Invasion"] = {vp=0, cost=14},
	["CO4 The Nuclear Clock"] = {vp=0, cost=14},
	["CO4 Death by a Thousand Cuts"] = {vp=0, cost=22},
	["CO4 Demonstration of Power"] = {vp=0, cost=21},
	["CO4 Subversion of Heroes"] = {vp=0, cost=23},
	["CO4 Technological Breakthrough"] = {vp=0, cost=25},
	["CO4 Turn The World Against Itself"] = {vp=0, cost=24},
	["CO4 Equipped for Mayhem"] = {vp=0,},
	["CO4 Move the Heroes like Pawns"] = {vp=0,},
	["CO4 Outright Villainy"] = {vp=0,},
	["CO4 Power up for Progress"] = {vp=0,},
	["CO4 Loyal"] = {vp=0,},
	["CO4 Secret Mastermind"] = {vp=0,},
	--Oversized Character Cards
	["CO4 Dr. Manhattan"] = {vp=0, isCharacter=true, id=5711},
	["CO4 Nite Owl"] = {vp=0, isCharacter=true, id=8590},
	["CO4 Ozymandias"] = {vp=0, isCharacter=true, id=9056},
	["CO4 Rorschach"] = {vp=0, isCharacter=true, id=3892},
	["CO4 Silk Spectre"] = {vp=0, isCharacter=true, id=6875},
	["CO4 The Comedian"] = {vp=0, isCharacter=true, id=9854},
	--4)5) Crossover 5 - Rogues
	--Heroes
	["CO5 Captain Boomerang Jr."] = {vp=0, isHero=true, cost=5, id=4301},
	["CO5 Iris West"] = {vp=0, isHero=true, cost=2, id=8198},
	["CO5 James Jesse"] = {vp=0, isHero=true, cost=4, id=6617},
	["CO5 Patty Spivot"] = {vp=0, isHero=true, cost=3, id=1189},
	["CO5 Pied Piper"] = {vp=0, isHero=true, isDefense=true, cost=6, id=5164},
	--Villains
	["CO5 Abra Kadabra"] = {vp=0, isVillain=true, cost=7, id=9122},
	["CO5 Dr. Alchemy"] = {vp=0, isVillain=true, cost=2, id=7001},
	["CO5 Girder"] = {vp=0, isVillain=true, isDefense=true, cost=4, id=6123},
	["CO5 Magenta"] = {vp=0, isVillain=true, cost=5, id=4996},
	["CO5 Tar Pit"] = {vp=0, isVillain=true, cost=3, id=5922},
	["CO5 The Top"] = {vp=0, isVillain=true, isAttack=true, cost=6, id=9605},
	--Super Powers
	["CO5 Engulfing Flames"] = {vp=0, isSuperPower=true, cost=5, id=9446},
	["CO5 Lightning Strike"] = {vp=0, isSuperPower=true, cost=6, id=3845},
	["CO5 Mirror Images"] = {vp=0, isSuperPower=true, cost=5, id=7929},
	["CO5 Phasing"] = {vp=0, isSuperPower=true, cost=7, id=3032},
	["CO5 Tornado"] = {vp=0, isSuperPower=true, isAttack=true, cost=4, id=4125},
	--Equipment
	["CO5 Air-Walk Shoes"] = {vp=0, isEquipment=true, cost=3, id=9518},
	["CO5 Bag of Tricks"] = {vp=0, isEquipment=true, cost=6, id=5843},
	["CO5 Cold Gun"] = {vp=0, isEquipment=true, cost=3, id=9705},
	["CO5 Loot!"] = {vp=0, isEquipment=true, cost=4, id=1466},
	["CO5 Mirror Gun"] = {vp=0, isEquipment=true, cost=4, id=8740},
	--Locations
	["CO5 Iron Heights"] = {vp=0, isLocation=true, isDefense=true, isOngoing=true, cost=4, id=4703},
	["CO5 Rogues Safe House"] = {vp=0, isLocation=true, isOngoing=true, cost=4, id=4848},
	--Super-Heroes
	["CO5 Bart Allen"] = {vp=7, isHero=true, isBoss=true, cost=14, id=4431},
	["CO5 Hawkman"] = {vp=6, isHero=true, isBoss=true, cost=11, id=3887},
	["CO5 Jay Garrick"] = {vp=5, isHero=true, isBoss=true, cost=10, id=9648},
	["CO5 Jesse Quick"] = {vp=5, isHero=true, isBoss=true, cost=9, id=6938},
	["CO5 Max Mercury"] = {vp=6, isHero=true, isBoss=true, cost=12, id=5463},
	["CO5 The Flash (Return from the Speed Force)"] = {vp=7, isHero=true, isBoss=true, cost=15, id=7361},
	["CO5 The Flash"] = {vp=0, isHero=true, isBoss=true, isStartBoss=true, cost=8, id=4583},
	["CO5 Wally West"] = {vp=6, isHero=true, isBoss=true, cost=13, id=9682},
	--Oversized Character Cards
	["CO5 Captain Cold"] = {vp=0, isCharacter=true, id=6393},
	["CO5 Golden Glider"] = {vp=0, isCharacter=true, id=7724},
	["CO5 Heatwave"] = {vp=0, isCharacter=true, id=4170},
	["CO5 Mirror Master"] = {vp=0, isCharacter=true, id=9156},
	["CO5 Trickster"] = {vp=0, isCharacter=true, id=3520},
	["CO5 Weather Wizard"] = {vp=0, isCharacter=true, id=1365},
	--4)6) Crossover 6 - Birds of Prey
	--Heroes
	["CO6 Hawkfire"] = {vp=1, isHero=true, isOngoing=true, cost=4, id=1360},
	["CO6 Lady Blackhawk"] = {vp=1, isHero=true, cost=3, id=8919},
	["CO6 Maggie Sawyer"] = {vp=1, isHero=true, cost=2, id=1005},
	["CO6 Manhunter"] = {vp=1, isHero=true, isOngoing=true, cost=5, id=7104},
	["CO6 Misfit"] = {vp=1, isHero=true, cost=3, id=8069},
	["CO6 Strix"] = {vp=1, isHero=true, cost=4, id=5208},
	["CO6 Vixen"] = {vp=2, isHero=true, cost=7, id=3852},
	--Villains
	["CO6 Black Alice"] = {vp=2, isVillain=true, cost=5, id=4463},
	["CO6 Cheshire"] = {vp=2, isVillain=true, isOngoing=true, cost=7, id=7007},
	["CO6 Cupid"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=7203},
	["CO6 Knockout"] = {vp=2, isVillain=true, cost=6, id=6064},
	["CO6 Roulette"] = {vp=1, isVillain=true, cost=2, id=8440},
	["CO6 Scandal Savage"] = {vp=2, isVillain=true, isDefense=true, isOngoing=true, cost=7, id=1396},
	--Super Powers
	["CO6 Canary Cry"] = {vp=1, isSuperPower=true, cost=5, id=6212},
	["CO6 Eidetic Memory"] = {vp=1, isSuperPower=true, isOngoing=true, cost=4, id=6187},
	["CO6 Martial Arts Expert"] = {vp=1, isSuperPower=true, isOngoing=true, cost=3, id=1853},
	["CO6 Master Thief"] = {vp=2, isSuperPower=true, cost=6, id=7673},
	--Equipment
	["CO6 Aerie One"] = {vp=1, isEquipment=true, isDefense=true, cost=3, id=4272},
	["CO6 Computer Console"] = {vp=2, isEquipment=true, isOngoing=true, cost=6, id=8865},
	["CO6 Crossbow"] = {vp=1, isEquipment=true, isAttack=true, cost=3, id=4839},
	["CO6 Soultaker Sword"] = {vp=1, isEquipment=true, isOngoing=true, cost=5, id=9688},
	["CO6 Whip"] = {vp=1, isEquipment=true, cost=4, id=7904},
	--Locations
	["CO6 Clocktower"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=3943},
	--Super-Heroes
	["CO6 Cheetah"] = {vp=5, isVillain=true, isBoss=true, isOngoing=true, cost=10, id=7837},
	["CO6 Harley Quinn"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=8, id=6418},
	["CO6 Lady Shiva"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=5856},
	["CO6 Livewire"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=9313},
	["CO6 Nocturna"] = {vp=7, isVillain=true, isBoss=true, cost=14, id=1830},
	["CO6 Poison Ivy"] = {vp=6, isVillain=true, isBoss=true, cost=12, id=9432},
	["CO6 Talia Al Ghul"] = {vp=7, isVillain=true, isBoss=true, cost=15, id=6587},
	["CO6 The Calculator"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=7466},
	--Oversized Character Cards
	["CO6 Batwoman"] = {vp=0, isCharacter=true, id=4274},
	["CO6 Black Canary"] = {vp=0, isCharacter=true, id=4237},
	["CO6 Catwoman"] = {vp=0, isCharacter=true, id=4365},
	["CO6 Huntress"] = {vp=0, isCharacter=true, id=8136},
	["CO6 Katana"] = {vp=0, isCharacter=true, id=9790},
	["CO6 Oracle"] = {vp=0, isCharacter=true, id=6827},
	--4)7) Crossover 7 - New Gods
	--Heroes
	["CO7 Big Barda"] = {vp=1, isHero=true, cost=5, id=1995},
	["CO7 Forever People"] = {vp=1, isHero=true, isOngoing=true, cost=4, id=1467},
	["CO7 Highfather"] = {vp=3, isHero=true, cost=8, id=5696},
	["CO7 Himon"] = {vp=1, isHero=true, cost=4, id=9749},
	["CO7 Metron"] = {vp=2, isHero=true, cost=6, id=8821},
	["CO7 Mister Miracle"] = {vp=1, isHero=true, cost=5, id=9545},
	["CO7 Orion"] = {vp=2, isHero=true, cost=7, id=5663},
	["CO7 Takion"] = {vp=2, isHero=true, cost=6, id=7188},
	--Villains
	["CO7 Darkseid"] = {vp=3, isVillain=true, cost=8, id=5524},
	["CO7 Desaad"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=1646},
	["CO7 Female Furies"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=1893},
	["CO7 Granny Goodness"] = {vp=2, isVillain=true, cost=6, id=4068},
	["CO7 Kalibak"] = {vp=3, isVillain=true, cost=7, id=7693},
	["CO7 Kanto"] = {vp=1, isVillain=true, cost=4, id=5266},
	["CO7 Mantis"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=4047},
	["CO7 Steppenwolf"] = {vp=1, isVillain=true, cost=5, id=7900},
	--Super Powers
	["CO7 Anti-Life Equation"] = {vp=1, isSuperPower=true, cost=5, id=5414},
	["CO7 Die For Darkseid"] = {vp=1, isSuperPower=true, cost=4, id=6031},
	["CO7 Escape Artist"] = {vp=1, isSuperPower=true, isDefense=true, cost=3, id=9065},
	["CO7 Omega Beams"] = {vp=2, isSuperPower=true, isAttack=true, cost=6, id=8270},
	--Equipment
	["CO7 Aero-Discs"] = {vp=1, isEquipment=true, cost=4, id=5140},
	["CO7 Astro-Harness"] = {vp=2, isEquipment=true, isDefense=true, cost=6, id=1997},
	["CO7 Beta Club"] = {vp=1, isEquipment=true, cost=3, id=1560},
	["CO7 Boom Tube"] = {vp=1, isEquipment=true, cost=4, id=9691},
	["CO7 Mobius Chair"] = {vp=0, isEquipment=true, cost=5, id=8190},
	["CO7 Mother Box"] = {vp=2, isEquipment=true, cost=7, id=5975},
	--Homeworlds
	["CO7 Apokolips (Level 1)"] = {vp=6, isBoss=true, isStartBoss=true, cost=9, id=6937},
	["CO7 Apokolips (Level 2)"] = {vp=7, isBoss=true, cost=12, id=9675},
	["CO7 Apokolips (Level 3)"] = {vp=8, isBoss=true, cost=15, id=5827},
	["CO7 New Genesis (Level 1)"] = {vp=6, isBoss=true, isStartBoss=true, cost=9, id=7337},
	["CO7 New Genesis (Level 2)"] = {vp=7, isBoss=true, cost=12, id=1477},
	["CO7 New Genesis (Level 3)"] = {vp=8, isBoss=true, cost=15, id=7311},
	--Oversized Character Cards
	["CO7 Big Barda (Character)"] = {vp=0, isCharacter=true, id=9283},
	["CO7 Darkseid (Character)"] = {vp=0, isCharacter=true, id=7493},
	["CO7 Granny Goodness (Character)"] = {vp=0, isCharacter=true, id=8064},
	["CO7 Kalibak (Character)"] = {vp=0, isCharacter=true, id=5931},
	["CO7 Mister Miracle (Character)"] = {vp=0, isCharacter=true, id=1954},
	["CO7 Orion (Character)"] = {vp=0, isCharacter=true, id=6826},
	--4)8) Crossover 8 - Batman Ninja
	--Heroes
	["CO8 Alfred Pennyworth"] = {vp=1, isHero=true, cost=3, id=1037},
	["CO8 Eian"] = {vp=1, isHero=true, cost=5, id=7743},
	["CO8 Monkichi"] = {vp=1, isHero=true, cost=1, id=9578},
	["CO8 Monmi"] = {vp=1, isHero=true, cost=1, id=1065},
	["CO8 Ninja Clan"] = {vp=1, isHero=true, cost=4, id=4675},
	--Villains
	["CO8 Bane"] = {vp=2, isVillain=true, isAttack=true, cost=6, id=2301},
	["CO8 Gorilla Army"] = {vp=1, isVillain=true, isAttack=true, cost=2, id=6748},
	["CO8 Gorilla Grodd"] = {vp=2, isVillain=true, cost=7, id=8897},
	["CO8 Harley Quinn"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=3610},
	["CO8 The Joker Patrol"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=4001},
	--Super Powers
	["CO8 Batman God"] = {vp=1, isSuperPower=true, cost=9, id=8447},
	["CO8 Colony of Bats"] = {vp=1, isSuperPower=true, cost=3, id=7067},
	["CO8 Million Monkey Maneuver"] = {vp=2, isSuperPower=true, cost=6, id=5300},
	--Equipment
	["CO8 Batcycle Armor"] = {vp=1, isEquipment=true, isDefense=true, cost=5, id=1665},
	["CO8 Bat-Glider"] = {vp=1, isEquipment=true, cost=2, id=4222},
	["CO8 Katana"] = {vp=1, isEquipment=true, isDefense=true, isOngoing=true, cost=4, id=1081},
	["CO8 Samurai Armor"] = {vp=1, isEquipment=true, cost=4, id=8175},
	["CO8 Warhorse"] = {vp=1, isEquipment=true, cost=3, id=8822},
	--Locations
	["CO8 Feudal Japan"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=2229},
	--Oversized Character Cards
	["CO8 Batman"] = {vp=0, isCharacter=true, id=9871},
	["CO8 Catwoman"] = {vp=0, isCharacter=true, id=9606},
	["CO8 Gorilla Grodd"] = {vp=0, isCharacter=true, id=8395},
	["CO8 Nightwing"] = {vp=0, isCharacter=true, id=1901},
	["CO8 Red Hood"] = {vp=0, isCharacter=true, id=9787},
	["CO8 Red Robin"] = {vp=0, isCharacter=true, id=6363},
	["CO8 Robin"] = {vp=0, isCharacter=true, id=3907},
	--Oversized Super-Villains
	["CO8 Deathstroke"] = {vp=0, isVillain=true, isBoss=true, cost=10},
	["CO8 Poison Ivy"] = {vp=0, isVillain=true, isBoss=true, cost=10},
	["CO8 The Joker"] = {vp=10, isVillain=true, isBoss=true, cost=20},
	["CO8 The Penguin"] = {vp=0, isVillain=true, isBoss=true, cost=10},
	["CO8 Two-Face"] = {vp=0, isVillain=true, isBoss=true, cost=10},
	--4)9) Crossover 9 - Bombshells
	--Heroes
	["CO9 Barda Free"] = {vp=2, isHero=true, isAttack=true, cost=5,},
	["CO9 Batgirl"] = {vp=2, isHero=true, isAttack=true, cost=6,},
	["CO9 Black Canary"] = {vp=1, isHero=true, isAttack=true, cost=3,},
	["CO9 Catwoman"] = {vp=1, isHero=true, isAttack=true, cost=4,},
	["CO9 Doctor Kimiyo Hoshi"] = {vp=1, isHero=true, isAttack=true, cost=4,},
	["CO9 Hawkgirl"] = {vp=1, isHero=true, isAttack=true, cost=4,},
	["CO9 Huntress"] = {vp=1, isHero=true, isAttack=true, isDefense=true, cost=3,},
	["CO9 Katana"] = {vp=1, isHero=true, isAttack=true, cost=5,},
	["CO9 Lois Lane"] = {vp=1, isHero=true, isAttack=true, cost=3,},
	["CO9 Maggie Sawyer"] = {vp=1, isHero=true, isAttack=true, cost=2,},
	["CO9 Miri Marvel"] = {vp=3, isHero=true, isAttack=true, cost=7,},
	["CO9 Raven"] = {vp=2, isHero=true, isAttack=true, cost=6,},
	["CO9 The Batgirls"] = {vp=1, isHero=true, isAttack=true, cost=3,},
	["CO9 Vixen"] = {vp=1, isHero=true, isAttack=true, cost=5,},
	--Villains
	["CO9 Alexander Luthor"] = {vp=1, isVillain=true, cost=5,},
	["CO9 Cheetah"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["CO9 Harley Quinn"] = {vp=1, isVillain=true, isAttack=true, cost=3,},
	["CO9 Hugo Strange"] = {vp=2, isVillain=true, isDefense=true, cost=6,},
	["CO9 Poison Ivy"] = {vp=2, isVillain=true, isAttack=true, cost=5,},
	["CO9 Ravager"] = {vp=1, isVillain=true, isAttack=true, cost=2,},
	["CO9 Whisper A'Daire"] = {vp=2, isVillain=true, isAttack=true, cost=7,},
	--Super Powers
	["CO9 Heat Vision"] = {vp=1, isSuperPower=true, cost=5,},
	["CO9 Water Control"] = {vp=2, isSuperPower=true, cost=6,},
	--Equipment
	["CO9 Cosmic Staff"] = {vp=1, isEquipment=true, isDefense=true, cost=5,},
	["CO9 Lil' Slugger"] = {vp=1, isEquipment=true, isDefense=true, cost=4,},
	["CO9 Magic Bracers"] = {vp=1, isEquipment=true, isDefense=true, cost=5,},
	--Locations
	["CO9 Atlantis"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	["CO9 London"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
    	["CO9 Latveria"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
        ["CO9 Latvéria"] = {vp=1, isLocation=true, isOngoing=true, cost=5,},
	--Super-Villains
	["CO9 Baroness Paula Von Gunther"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["CO9 General Faora"] = {vp=7, isVillain=true, isBoss=true, cost=15,},
	["CO9 Killer Frost"] = {vp=7, isVillain=true, isBoss=true, isAttack=true, cost=14,},
	["CO9 Mechanical Gods"] = {vp=6, isVillain=true, isBoss=true, cost=13,},
	["CO9 Nereus"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["CO9 Tenebrae Soldiers"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["CO9 The Joker's Daughter"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, isAttack=true, isOngoing=true, cost=8,},
	["CO9 The Titan"] = {vp=6, isVillain=true, isBoss=true, isDefense=true, cost=12,},
	--Oversized Character Cards
	["CO9 Batwoman"] = {vp=0, isCharacter=true,},
	["CO9 Commander Waller"] = {vp=0, isCharacter=true,},
	["CO9 Mera"] = {vp=0, isCharacter=true,},
	["CO9 Stargirl"] = {vp=0, isCharacter=true,},
	["CO9 Supergirl"] = {vp=0, isCharacter=true,},
	["CO9 Wonder Woman"] = {vp=0, isCharacter=true,},
	["CO9 Zatana"] = {vp=0, isCharacter=true,},
	--4)10) Crossover 10 - Flashpoint
	--Heroes
	["CO10 Flashpoint Britannia"] = {vp=-2, isHero=true, isTimeLineUp=true, cost=5,},
	["CO10 Flashpoint Canterbury Cricket"] = {vp=-2, isHero=true, isOngoing=true, isTimeLineUp=true, cost=5,},
	["CO10 Flashpoint Captain Thunder Kids"] = {vp=-3, isHero=true, isTimeLineUp=true, cost=7,},
	["CO10 Flashpoint Citizen Cold"] = {vp=-2, isHero=true, isTimeLineUp=true, cost=6,},
	["CO10 Flashpoint Kid Flash"] = {vp=-3, isHero=true, isDefense=true, isTimeLineUp=true, cost=7,},
	["CO10 Flashpoint Mera"] = {vp=-2, isHero=true, isDefense=true, isTimeLineUp=true, cost=6,},
	["CO10 The Resistance"] = {vp=-2, isHero=true, isTimeLineUp=true, cost=8,},
	--Villains
	["CO10 Flashpoint Atlanteans"] = {vp=-2, isVillain=true, isTimeLineUp=true, cost=6,},
	["CO10 Flashpoint Deathstroke"] = {vp=-2, isVillain=true, isTimeLineUp=true, cost=5,},
	["CO10 Flashpoint Martha Wayne"] = {vp=-2, isVillain=true, isOngoing=true, isTimeLineUp=true, cost=6,},
	["CO10 Flashpoint Subject Zero"] = {vp=-3, isVillain=true, isTimeLineUp=true, cost=7,},
	["CO10 Flashpoint Vulko"] = {vp=-3, isVillain=true, isTimeLineUp=true, cost=6,},
	["CO10 The Furies"] = {vp=-2, isVillain=true, isTimeLineUp=true, cost=8,},
	--Super Powers
	["CO10 Brutal Persuasion"] = {vp=-2, isSuperPower=true, isTimeLineUp=true, cost=5,},
	["CO10 Chronokinesis"] = {vp=-2, isSuperPower=true, isTimeLineUp=true, cost=7,},
	["CO10 Counter Attack"] = {vp=-2, isSuperPower=true, isDefense=true, isTimeLineUp=true, cost=6,},
	["CO10 Heroic Escape"] = {vp=-2, isSuperPower=true, isTimeLineUp=true, cost=5,},
	["CO10 No More"] = {vp=-3, isSuperPower=true, isTimeLineUp=true, cost=7,},
	["CO10 Speed Force"] = {vp=-3, isSuperPower=true, isOngoing=true, isTimeLineUp=true, cost=6,},
	["CO10 Traverse Timelines"] = {vp=0, isSuperPower=true, isTimeLineUp=true, cost=6,},
	--Equipment
	["CO10 Atlantean Speargun"] = {vp=-2, isEquipment=true, isTimeLineUp=true, cost=5,},
	["CO10 Cosmic Treadmill"] = {vp=-3, isEquipment=true, isOngoing=true, isTimeLineUp=true, cost=6,},
	["CO10 Energy-Resistant Armor"] = {vp=-2, isEquipment=true, isDefense=true, isOngoing=true, isTimeLineUp=true, cost=5,},
	["CO10 Geo-Pulse Prison"] = {vp=-2, isEquipment=true, isAttack=true, isTimeLineUp=true, cost=7,},
	["CO10 Queen Mera's Helm"] = {vp=-3, isEquipment=true, isDefense=true, isTimeLineUp=true, cost=7,},
	["CO10 Trident of Atlan"] = {vp=-2, isEquipment=true, isAttack=true, isTimeLineUp=true, cost=8,},
	--Locations
	["CO10 New Themyscira"] = {vp=-3, isLocation=true, isOngoing=true, isTimeLineUp=true, cost=6,},
	--Super-Villains
	["CO10 Flashpoint Emperor Aquaman"] = {vp=6, isVillain=true, isBoss=true, cost=12,},
	["CO10 Flashpoint Enchantress"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["CO10 Flashpoint Gorilla Grodd"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["CO10 Flashpoint Penthesilea"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=8,},
	["CO10 Flashpoint Prince Orm"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["CO10 Flashpoint Queen Diana"] = {vp=6, isVillain=true, isBoss=true, cost=13,},
	["CO10 Reverse-Flash"] = {vp=7, isVillain=true, isBoss=true, cost=14,},
	["CO10 The Flash"] = {vp=7, isVillain=true, isBoss=true, cost=15,},
	--Oversized Character Cards
	["CO10 Emperor Aquaman"] = {vp=0, isCharacter=true,},
	["CO10 Flashpoint Batman"] = {vp=0, isCharacter=true,},
	["CO10 Flashpoint Captain Thunder"] = {vp=0, isCharacter=true,},
	["CO10 Flashpoint Cyborg"] = {vp=0, isCharacter=true,},
	["CO10 Flashpoint Green Lantern"] = {vp=0, isCharacter=true,},
	["CO10 Flashpoint Superman"] = {vp=0, isCharacter=true,},
	["CO10 Flashpoint The Flash"] = {vp=0, isCharacter=true,},
	["CO10 Queen Diana"] = {vp=0, isCharacter=true,},
	--4)11) Crossover 11 - Dark Knights Rising
	--Equipment
	["CO11 Corrupted Power Ring"] = {vp=1, isEquipment=true, isPowerRing=true, cost=3,},
	["CO11 Calling Card"] = {vp=1, isEquipment=true, cost=4,},
	["CO11 Helmet of Fate"] = {vp=2, isEquipment=true, cost=4,},
	["CO11 Alfred Protocol"] = {vp=2, isEquipment=true, cost=6,},
	--Heroes
	["CO11 Robin"] = {vp=1, isHero=true, cost=3,},
	["CO11 The Signal"] = {vp=1, isHero=true, cost=4,},
	["CO11 Green Arrow"] = {vp=2, isHero=true, cost=4,},
	["CO11 Nightwing"] = {vp=1, isHero=true, cost=5,},
	["CO11 Red Tornado"] = {vp=2, isHero=true, cost=5,},
	["CO11 Martian Manhunter"] = {vp=2, isHero=true, cost=6,},
	--Super Powers
	["CO11 Summon Dead Waters"] = {vp=1, isSuperPower=true, cost=3,},
	["CO11 Speed Force Bats"] = {vp=2, isSuperPower=true, cost=3,},
	["CO11 Devastating Strength"] = {vp=1, isSuperPower=true, cost=4,},
	--Villains
	["CO11 Killer Croc"] = {vp=1, isVillain=true, isDefense=true, cost=3,},
	["CO11 Harley Quinn"] = {vp=1, isVillain=true, cost=4,},
	["CO11 Poison Ivy"] = {vp=1, isVillain=true, cost=5,},
	["CO11 The Joker"] = {vp=2, isVillain=true, isAttack=true, cost=6,},
	--Super Heroes
	["CO11 Batman"] = {vp=4, isHero=true, isStartBoss=true, isBoss=true, cost=8,},
	["CO11 Aquaman"] = {vp=6, isHero=true, isBoss=true, cost=9,},
	["CO11 Cyborg"] = {vp=6, isHero=true, isBoss=true, cost=9,},
	["CO11 Green Lantern"] = {vp=6, isHero=true, isBoss=true, cost=9,},
	["CO11 Kendra Saunders"] = {vp=6, isHero=true, isBoss=true, cost=9,},
	["CO11 Doctor Fate"] = {vp=7, isHero=true, isBoss=true, cost=11,},
	["CO11 Superman"] = {vp=7, isHero=true, isBoss=true, cost=11,},
	["CO11 Wonder Woman"] = {vp=9, isHero=true, isBoss=true, cost=14,},
	--Oversized Character Cards
	["CO11 Batman (Earth-1)"] = {vp=0, isCharacter=true,},
	["CO11 Batman (Earth-32)"] = {vp=0, isCharacter=true,},
	["CO11 Batman (Earth-11)"] = {vp=0, isCharacter=true,},
	["CO11 Batman (Earth-12)"] = {vp=0, isCharacter=true,},
	["CO11 Batman (Earth-44)"] = {vp=0, isCharacter=true,},
	["CO11 Batman (Earth-52)"] = {vp=0, isCharacter=true,},
	--4)12) Crossover 12 - Hush
	--Equipment
	["CO12 Grapnel Gun"] = {vp=1, isEquipment=true, cost=4,},
	["CO12 Kryptonite Ring"] = {vp=1, isEquipment=true, isDefense=true, cost=5,},
	["CO12 Motorcycle"] = {vp=1, isEquipment=true, cost=4,},
	--Heroes
	["CO12 Harold Allnut"] = {vp=1, isHero=true, cost=2,},
	--Super Powers
	["CO12 Track Down"] = {vp=1, isSuperPower=true, cost=4,},
	--Super-Villains
	["CO12 Killer Croc"] = {vp=4, isVillain=true, isStartBoss=true, isBoss=true, cost=8,},
	["CO12 Poison Ivy"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["CO12 Harley Quinn"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["CO12 Clayface"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["CO12 The Joker"] = {vp=6, isVillain=true, isAttack=true, isBoss=true, cost=11,},
	--Super-Heroes
	["CO12 Superman"] = {vp=5, isHero=true, isDefense=true, isBoss=true, cost=10,},
	--Oversized Character Cards
	["CO12 Catwoman"] = {vp=0, isCharacter=true,},
	["CO12 Huntress"] = {vp=0, isCharacter=true,},
	["CO12 Nightwing"] = {vp=0, isCharacter=true,},
	--5)1) Fellowship of the Rings
	--Other
	["FotR Corruption"] = {vp=-1, isCorruption=true, cost=0},
	["FotR Courage"] = {vp=0, isStarter=true, isCourage=true, cost=0},
	["FotR Despair"] = {vp=0, isStarter=true, cost=0},
	["FotR Impossible Mode"] = {vp=0,},
	--Allies
	["FotR Bilbo Baggins"] = {vp=1, isAlly=true, cost=2},
	["FotR Boromir, Captain of the White Tower"] = {vp=2, isAlly=true, cost=6},
	["FotR Elendil"] = {vp=2, isAlly=true, cost=5},
	["FotR Frodo Baggins the Ringbearer"] = {vp=1, isAlly=true, cost=4},
	["FotR Galadriel, Lady of Light"] = {vp=2, isAlly=true, cost=7},
	["FotR Gandalf the Grey"] = {vp=3, isAlly=true, cost=7},
	["FotR Gimli, Son of Gloin the Dwarf"] = {vp=1, isAlly=true, cost=4},
	["FotR Haldir"] = {vp=1, isAlly=true, cost=2},
	["FotR Legolas Greenleaf"] = {vp=1, isAlly=true, cost=5},
	["FotR Lord Elrond"] = {vp=2, isAlly=true, cost=7},
	["FotR Merry"] = {vp=1, isAlly=true, cost=3},
	["FotR Pippin"] = {vp=1, isAlly=true, cost=2},
	["FotR Samewise Gamgee"] = {vp=1, isAlly=true, cost=3},
	["FotR Strider the Ranger"] = {vp=0, isAlly=true, cost=6},
	--Enemies
	["FotR Black Riders"] = {vp=2, isEnemy=true, isAttack=true, cost=6},
	["FotR Moria Orc Captain"] = {vp=0, isEnemy=true, cost=2},
	["FotR Moria Orcs"] = {vp=1, isEnemy=true, cost=3},
	["FotR Orc Overseer"] = {vp=1, isEnemy=true, cost=4},
	["FotR Ringwraiths"] = {vp=2, isEnemy=true, isAttack=true, cost=7},
	["FotR Twilight Ringwraith"] = {vp=1, isEnemy=true, cost=5},
	["FotR Uruk-Hai Grunt"] = {vp=1, isEnemy=true, isAttack=true, cost=3},
	["FotR Uruk-Hai Scout"] = {vp=1, isEnemy=true, cost=2},
	["FotR Uruk-Hai"] = {vp=1, isEnemy=true, isAttack=true, cost=4},
	--Maneuvers
	["FotR Council of Elrond"] = {vp=1, isManeuver=true, cost=5},
	["FotR Don't Tempt Me, Frodo!"] = {vp=1, isManeuver=true, isDefense=true, cost=3},
	["FotR Drums in the Deep"] = {vp=2, isManeuver=true, cost=6},
	["FotR Hope Remains"] = {vp=1, isManeuver=true, isDefense=true, cost=5},
	["FotR It Comes in Pints?"] = {vp=1, isManeuver=true, cost=4},
	["FotR My Captain, My King"] = {vp=1, isManeuver=true, cost=3},
	["FotR One Does Not Simply Walk into Mordor"] = {vp=2, isManeuver=true, cost=6},
	["FotR Put It Out, You Fools!"] = {vp=1, isManeuver=true, isDefense=true, cost=3},
	["FotR Recover Your Strength"] = {vp=1, isManeuver=true, cost=2},
	["FotR Ride like the Wind"] = {vp=0, isManeuver=true, isDefense=true, cost=0},
	["FotR Samewise's Bravery"] = {vp=0, isManeuver=true, cost=0},
	["FotR Second Breakfast"] = {vp=0, isManeuver=true, cost=0},
	["FotR Seduced by the Ring"] = {vp=1, isManeuver=true, cost=4},
	["FotR Still Sharp"] = {vp=1, isManeuver=true, cost=5},
	["FotR That Was Close!"] = {vp=1, isManeuver=true, isDefense=true, cost=3},
	["FotR These Are for You"] = {vp=2, isManeuver=true, cost=5},
	["FotR Valor"] = {vp=1, isManeuver=true, cost=3},
	["FotR You Shall Not Pass!"] = {vp=1, isManeuver=true, isDefense=true, cost=2},
	--Artifacts
	["FotR Aragorn's Sword"] = {vp=0, isArtifact=true, cost=0},
	["FotR Book of Mazarbul"] = {vp=1, isArtifact=true, cost=4},
	["FotR Boromir's Shield"] = {vp=1, isArtifact=true, isDefense=true, cost=4},
	["FotR Boromir's Sword"] = {vp=0, isArtifact=true, cost=0},
	["FotR Bow of the Galadhrim"] = {vp=0, isArtifact=true, cost=0},
	["FotR Elven Brooch"] = {vp=0, isArtifact=true, cost=3},
	["FotR Evenstar Pendant"] = {vp=2, isArtifact=true, cost=6},
	["FotR Flaming Brand"] = {vp=1, isArtifact=true, cost=5},
	["FotR Gandalf's Fireworks"] = {vp=1, isArtifact=true, cost=4},
	["FotR Gandalf's Staff"] = {vp=0, isArtifact=true, cost=0},
	["FotR Gimli's Axe"] = {vp=0, isArtifact=true, cost=0},
	["FotR Horn of Gondor"] = {vp=1, isArtifact=true, cost=3},
	["FotR Light of Earendil"] = {vp=1, isArtifact=true, cost=2},
	["FotR Mirror of Galadriel"] = {vp=1, isArtifact=true, cost=3},
	["FotR Mithril Vest"] = {vp=2, isArtifact=true, isDefense=true, cost=7},
	["FotR Pipeweed"] = {vp=0, isArtifact=true, cost=1},
	["FotR Seeing Stones"] = {vp=1, isArtifact=true, cost=4},
	["FotR Shards of Narsil"] = {vp=2, isArtifact=true, cost=7},
	["FotR Sting"] = {vp=0, isArtifact=true, cost=4},
	["FotR the One Ring"] = {vp=0, isArtifact=true, isDefense=true, cost=0},
	--Locations
	["FotR Hobbiton"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["FotR Isengard"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["FotR Lothlorien"] = {vp=2, isLocation=true, isOngoing=true, cost=7},
	["FotR Rivendell"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["FotR The Mines of Moria"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["FotR The Prancing Pony"] = {vp=1, isLocation=true, isDefense=true, isOngoing=true, cost=4},
	--Fortunes
	["FotR A Gift"] = {vp=0, cost=0},
	["FotR Cast It into the Fire!"] = {vp=0, cost=0},
	["FotR Eagle Escape"] = {vp=0, cost=0},
	["FotR Finding the Ring"] = {vp=0, cost=0},
	["FotR Raging River"] = {vp=0, cost=0},
	--Archenemies
	["FotR Cave Troll"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["FotR Lurtz"] = {vp=10, isEnemy=true, isBoss=true, cost=14},
	["FotR Moria Swarm"] = {vp=5, isEnemy=true, isBoss=true, cost=8},
	["FotR Nazgûl"] = {vp=4, isEnemy=true, isBoss=true, isStartBoss=true, cost=8},
	["FotR Saruman"] = {vp=8, isEnemy=true, isBoss=true, cost=12},
	["FotR The Balrog"] = {vp=8, isEnemy=true, isBoss=true, cost=10},
	["FotR The Witch-King"] = {vp=8, isEnemy=true, isBoss=true, cost=11},
	["FotR Troop of Uruk-Hai"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["FotR Ulaire Cantea"] = {vp=7, isEnemy=true, isBoss=true, cost=10},
	["FotR Ulaire Nelya"] = {vp=7, isEnemy=true, isBoss=true, cost=10},
	["FotR Ulaire Ostea"] = {vp=5, isEnemy=true, isBoss=true, isAttack=true, cost=9},
	["FotR Watcher in the Water"] = {vp=5, isEnemy=true, isBoss=true, isAttack=true, cost=9},
	--Impossible
	["FotR Cave Troll (Impossible Mode)"] = {vp=5, isEnemy=true, isBoss=true, isAttack=true, cost=10},
	["FotR Lurtz (Impossible Mode)"] = {vp=12, isEnemy=true, isBoss=true, isOngoing=true, cost=15},
	["FotR Nazgûl (Impossible Mode)"] = {vp=4, isEnemy=true, isBoss=true, isStartBoss=true, isAttack=true, cost=9},
	["FotR Saruman (Impossible Mode)"] = {vp=8, isEnemy=true, isBoss=true, cost=13},
	["FotR The Balrog (Impossible Mode)"] = {vp=8, isEnemy=true, isBoss=true, cost=11},
	["FotR The Witch-King (Impossible Mode)"] = {vp=8, isEnemy=true, isBoss=true, isAttack=true, cost=12},
	["FotR Ulaire Ostea (Impossible Mode)"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["FotR Watcher in the Water (Impossible Mode)"] = {vp=5, isEnemy=true, isBoss=true, isAttack=true, cost=10},
	--Oversized Character Cards
	["FotR Aragorn"] = {vp=0, isCharacter=true,},
	["FotR Arwen"] = {vp=0, isCharacter=true,},
	["FotR Boromir"] = {vp=0, isCharacter=true,},
	["FotR Fordo"] = {vp=0, isCharacter=true,},
	["FotR Gandalf"] = {vp=0, isCharacter=true,},
	["FotR Gimli"] = {vp=0, isCharacter=true,},
	["FotR Legolas"] = {vp=0, isCharacter=true,},
	["FotR Merry & Pippin"] = {vp=0, isCharacter=true,},
	["FotR Samwise"] = {vp=0, isCharacter=true,},
	--5)2) The Two Towers
	--Other
	["2T Corruption"] = {vp=-1, isCorruption=true, cost=0},
	["2T Courage"] = {vp=0, isStarter=true, isCourage=true, cost=0},
	["2T Despair"] = {vp=0, isStarter=true, cost=0},
	["2T Impossible Mode"] = {vp=0,},
	--Allies
	["2T Aragorn, Isildur's Heir"] = {vp=2, isAlly=true, cost=6},
	["2T Éomer and the Riders of Rohan"] = {vp=2, isAlly=true, cost=5},
	["2T Éowyn, Noblewoman"] = {vp=1, isAlly=true, cost=3},
	["2T Faramir"] = {vp=1, isAlly=true, cost=5},
	["2T Frodo Baggins, the Courageous"] = {vp=1, isAlly=true, cost=4},
	["2T Gandalf the White"] = {vp=3, isAlly=true, cost=7},
	["2T Gimli the Axe-Wielder"] = {vp=1, isAlly=true, cost=5},
	["2T Haldir and the Elven Archers"] = {vp=1, isAlly=true, cost=4},
	["2T King Théoden, Lord of the Mark"] = {vp=2, isAlly=true, cost=6},
	["2T Legolas, the Archer"] = {vp=1, isAlly=true, isDefense=true, cost=3},
	["2T Meriadoc Brandybuck"] = {vp=1, isAlly=true, cost=2},
	["2T Peregrin Took"] = {vp=1, isAlly=true, cost=2},
	["2T Raw Recruits of Rohan"] = {vp=0, isAlly=true, cost=1},
	["2T Samwise the Brave"] = {vp=1, isAlly=true, cost=3},
	["2T Treebeard"] = {vp=3, isAlly=true, cost=7},
	--Enemies
	["2T Dunlendings"] = {vp=1, isEnemy=true, cost=2},
	["2T Gollum / Sméagol"] = {vp=1, isEnemy=true, cost=4},
	["2T Gríma Wormtongue"] = {vp=1, isEnemy=true, cost=4},
	["2T Uruk-Hai Abductors"] = {vp=1, isEnemy=true, cost=5},
	["2T Uruk-Hai Cannon-Fodder"] = {vp=1, isEnemy=true, cost=3},
	["2T Uruk-Hai Chest-Thumpers"] = {vp=1, isEnemy=true, cost=2},
	["2T Uruk-Hai Laddermen"] = {vp=2, isEnemy=true, cost=6},
	["2T Uruk-Hai Pikemen"] = {vp=1, isEnemy=true, cost=3},
	["2T Uruk-Hai Shield-Bearers"] = {vp=1, isEnemy=true, cost=4},
	["2T Uruk-Hai Siege Crew"] = {vp=2, isEnemy=true, cost=7},
	["2T Warg Riders"] = {vp=0, isEnemy=true, cost=5},
	--Maneuvers
	["2T A New Power is Rising"] = {vp=2, isManeuver=true, cost=6},
	["2T A Number Beyond Reckoning"] = {vp=1, isManeuver=true, isAttack=true, cost=3},
	["2T Dark Have Been My Dreams"] = {vp=0, isManeuver=true, cost=0},
	["2T Go On... Call For Help"] = {vp=1, isManeuver=true, isAttack=true, isDefense=true, cost=5},
	["2T I Fear Neither Death Nor Pain"] = {vp=0, isManeuver=true, cost=0},
	["2T Ill News is an Ill Guest"] = {vp=1, isManeuver=true, isAttack=true, cost=4},
	["2T It's Getting Heavier"] = {vp=0, isManeuver=true, cost=0},
	["2T Leave Now and Never Come Back!"] = {vp=1, isManeuver=true, cost=5},
	["2T Our Friends Are Out There"] = {vp=0, isManeuver=true, cost=0},
	["2T Something is Out There"] = {vp=0, isManeuver=true, cost=0},
	["2T The Ring is Treacherous"] = {vp=1, isManeuver=true, isAttack=true, cost=4},
	["2T The Turn of the Tide"] = {vp=0, isManeuver=true, cost=0},
	["2T The Wolves of Isengard Will Return"] = {vp=1, isManeuver=true, cost=2},
	["2T There is Always Hope"] = {vp=0, isManeuver=true, cost=0},
	["2T There's Some Good in this World"] = {vp=0, isManeuver=true, isDefense=true, cost=0},
	["2T Valor"] = {vp=1, isManeuver=true, cost=3},
	["2T Very Dangerous Over Short Distances"] = {vp=0, isManeuver=true, cost=0},
	["2T What Do You Smell?"] = {vp=1, isManeuver=true, cost=2},
	--Artifacts
	["2T Battlements on the Wall"] = {vp=0, isArtifact=true, cost=6},
	["2T Breaching Bomb"] = {vp=1, isArtifact=true, cost=5},
	["2T Brego"] = {vp=1, isArtifact=true, cost=5},
	["2T Chainmail"] = {vp=1, isArtifact=true, isDefense=true, cost=3},
	["2T Elvish Cloak"] = {vp=1, isArtifact=true, cost=4},
	["2T Elvish Rope"] = {vp=1, isArtifact=true, cost=2},
	["2T Entdraught"] = {vp=1, isArtifact=true, cost=4},
	["2T Longbottom Leaf"] = {vp=0, isArtifact=true, cost=3},
	["2T Shadowfax"] = {vp=3, isArtifact=true, cost=7},
	["2T The Best Salt in All the Shire"] = {vp=1, isArtifact=true, isDefense=true, cost=2},
	["2T The One Ring"] = {vp=2, isArtifact=true, isDefense=true, isOngoing=true, cost=0},
	--Locations
	["2T Dead Marshes"] = {vp=0, isLocation=true, isOngoing=true, cost=5},
	["2T Edoras"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["2T Fangorn Forest"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["2T The Hornburg"] = {vp=2, isLocation=true, isOngoing=true, cost=3},
	["2T The Tower of Barad-dûr"] = {vp=2, isLocation=true, isOngoing=true, cost=7},
	["2T The Tower of Orthanc"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	--Fortunes
	["2T First Light of the Fifth Day"] = {vp=0, cost=0},
	["2T Gandalf Defeats the Balrog"] = {vp=0, cost=0},
	["2T The Ents are Going to War"] = {vp=0, cost=0},
	["2T The White Wizard Approaches!"] = {vp=0, cost=0},
	--Wall
	["2T All is Lost"] = {vp=0,},
	["2T Breached"] = {vp=0, isOngoing=true,},
	["2T Breaking Through"] = {vp=0,},
	["2T Devastation"] = {vp=0,},
	["2T Endless Enemies"] = {vp=0,},
	["2T Explosion"] = {vp=0,},
	["2T Flood"] = {vp=0,},
	["2T Hopelessness"] = {vp=0,},
	["2T The Calm Before the Storm"] = {vp=0,},
	["2T The Face of Fear"] = {vp=0,},
	--Archenemies
	["2T Corrupted King Théoden"] = {vp=4, isEnemy=true, isBoss=true, isStartBoss=true, cost=8},
	["2T Flying Nazgûl"] = {vp=7, isEnemy=true, isBoss=true, cost=11},
	["2T Grishnákh"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["2T Mauhúr"] = {vp=6, isEnemy=true, isBoss=true, cost=10},
	["2T Saruman, Lord Of Isengard"] = {vp=10, isEnemy=true, isBoss=true, cost=14},
	["2T Sharku"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["2T Snaga"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["2T Uglúk"] = {vp=6, isEnemy=true, isBoss=true, cost=10},
	["2T Uruk-Hai Army"] = {vp=7, isEnemy=true, isBoss=true, cost=11},
	["2T Uruk-Hai Battering Ram"] = {vp=8, isEnemy=true, isBoss=true, cost=12},
	["2T Uruk-Hai General"] = {vp=7, isEnemy=true, isBoss=true, cost=11},
	["2T Uruk-Hai Torch Bearer"] = {vp=8, isEnemy=true, isBoss=true, cost=12},
	--Impossible
	["2T Corrupted King Théoden (Impossible Mode)"] = {vp=4, isEnemy=true, isBoss=true, isStartBoss=true, isAttack=true, cost=9},
	["2T Mauhúr (Impossible Mode)"] = {vp=6, isEnemy=true, isBoss=true, cost=11},
	["2T Saruman, Lord Of Isengard (Impossible Mode)"] = {vp=10, isEnemy=true, isBoss=true, cost=15},
	["2T Snaga (Impossible Mode)"] = {vp=5, isEnemy=true, isBoss=true, cost=10},
	["2T Uglúk (Impossible Mode)"] = {vp=6, isEnemy=true, isBoss=true, cost=11},
	["2T Uruk-Hai Battering Ram (Impossible Mode)"] = {vp=8, isEnemy=true, isBoss=true, cost=13},
	["2T Uruk-Hai General (Impossible Mode)"] = {vp=7, isEnemy=true, isBoss=true, cost=12},
	["2T Uruk-Hai Torch Bearer (Impossible Mode)"] = {vp=8, isEnemy=true, isBoss=true, cost=13},
	--Oversized Character Cards
	["2T Aragorn"] = {vp=0, isCharacter=true,},
	["2T Éowyn"] = {vp=0, isCharacter=true,},
	["2T Fordo Baggins"] = {vp=0, isCharacter=true,},
	["2T Gandalf"] = {vp=0, isCharacter=true,},
	["2T Gimli"] = {vp=0, isCharacter=true,},
	["2T King Théoden"] = {vp=0, isCharacter=true,},
	["2T Legolas Greenleaf"] = {vp=0, isCharacter=true,},
	["2T Merry & Pippin"] = {vp=0, isCharacter=true,},
	["2T Samwise Gamgee"] = {vp=0, isCharacter=true,},
	--5)3) Return of the King
	--Other
	["RotK Corruption"] = {vp=-1, isCorruption=true, cost=0},
	["RotK Courage"] = {vp=0, isStarter=true, isCourage=true, cost=0},
	["RotK Despair"] = {vp=0, isStarter=true, cost=0},
	["RotK Impossible Mode"] = {vp=0,},
	--Allies
	["RotK Aragorn, the King"] = {vp=3, isAlly=true, cost=7},
	["RotK Arwen, the Queen"] = {vp=1, isAlly=true, isDefense=true, cost=4},
	["RotK Elrond, the Seer"] = {vp=3, isAlly=true, cost=7},
	["RotK Éomer, the Lieutenant"] = {vp=1, isAlly=true, cost=4},
	["RotK Éowyn, the Audacious"] = {vp=1, isAlly=true, cost=4},
	["RotK Faramir, the Valiant"] = {vp=2, isAlly=true, cost=6},
	["RotK Frodo Baggins, the Conflicted"] = {vp=2, isAlly=true, cost=3},
	["RotK Gandalf, the Wizard"] = {vp=3, isAlly=true, cost=8},
	["RotK Gimli, the Elf-Friend"] = {vp=0, isAlly=true, cost=5},
	["RotK Legolas Greenleaf, the Dwarf-Friend"] = {vp=0, isAlly=true, cost=5},
	["RotK Merry, Esquire of Rohan"] = {vp=1, isAlly=true, cost=2},
	["RotK Pippin, Knight of Gondor"] = {vp=1, isAlly=true, cost=2},
	["RotK Samewise Gamgee, The Hero"] = {vp=0, isAlly=true, cost=3},
	["RotK Théoden, the General"] = {vp=2, isAlly=true, cost=6},
	--Enemies
	["RotK Bellowing Orc"] = {vp=1, isEnemy=true, cost=4},
	["RotK Cirith Ungol Guards"] = {vp=1, isEnemy=true, cost=5},
	["RotK Corsairs of Umbar"] = {vp=1, isEnemy=true, cost=2},
	["RotK Gollum, the Villain"] = {vp=1, isEnemy=true, cost=3},
	["RotK Haradrim Archer"] = {vp=1, isEnemy=true, isAttack=true, cost=4},
	["RotK Oliphant Captain"] = {vp=0, isEnemy=true, cost=5},
	["RotK Orc Archer"] = {vp=1, isEnemy=true, isAttack=true, cost=3},
	["RotK Orc Axeman"] = {vp=1, isEnemy=true, cost=2},
	["RotK Orc Sergeant"] = {vp=2, isEnemy=true, cost=6},
	["RotK Shagrat"] = {vp=2, isEnemy=true, isAttack=true, cost=6},
	["RotK The Mouth of Sauron"] = {vp=2, isEnemy=true, cost=7},
	--Maneuvers
	["RotK But I Can Carry You"] = {vp=0, isManeuver=true, cost=0},
	["RotK But Not This Day"] = {vp=0, isManeuver=true, isDefense=true, cost=0},
	["RotK Courage For Our Friends"] = {vp=1, isManeuver=true, cost=2},
	["RotK Courage is the Best Defense"] = {vp=1, isManeuver=true, isDefense=true, cost=3},
	["RotK Death is Just Another Path"] = {vp=1, isManeuver=true, cost=2},
	["RotK For Frodo"] = {vp=2, isManeuver=true, cost=6},
	["RotK Go Back to the Abyss"] = {vp=1, isManeuver=true, cost=3},
	["RotK Hail the Victorious Dead"] = {vp=1, isManeuver=true, cost=4},
	["RotK I Am No Man"] = {vp=0, isManeuver=true, cost=0},
	["RotK I Did What I Judged to be Right"] = {vp=0, isManeuver=true, cost=0},
	["RotK I Just Want to Look At It"] = {vp=0, isManeuver=true, cost=0},
	["RotK I Offer You My Service"] = {vp=0, isManeuver=true, cost=0},
	["RotK Just a Fool's Hope"] = {vp=0, isManeuver=true, cost=0},
	["RotK No More Despair"] = {vp=0, isManeuver=true, cost=0},
	["RotK Side By Side With a Friend"] = {vp=0, isManeuver=true, cost=0},
	["RotK That Still Only Counts as One"] = {vp=0, isManeuver=true, isAttack=true, cost=4},
	["RotK The Filth of Saruman is Washing Away"] = {vp=1, isManeuver=true, cost=3},
	["RotK There is Courage Still"] = {vp=0, isManeuver=true, cost=4},
	["RotK Valor"] = {vp=1, isManeuver=true, cost=3},
	["RotK You Have Failed"] = {vp=1, isManeuver=true, isAttack=true, cost=5},
	--Artifacts
	["RotK Anduril"] = {vp=3, isArtifact=true, cost=8},
	["RotK Beacon of Gondor"] = {vp=0, isArtifact=true, cost=1},
	["RotK Glamdring"] = {vp=2, isArtifact=true, cost=6},
	["RotK Guard of the Citadel Uniform"] = {vp=1, isArtifact=true, isDefense=true, cost=4},
	["RotK Hobbit-Sized Armor"] = {vp=1, isArtifact=true, isDefense=true, cost=5},
	["RotK Lembas Bread"] = {vp=1, isArtifact=true, isDefense=true, cost=2},
	["RotK Palantir"] = {vp=1, isArtifact=true, cost=4},
	["RotK Siege Weapons"] = {vp=1, isArtifact=true, isOngoing=true, cost=3},
	["RotK Sting, the Spider's Bane"] = {vp=2, isArtifact=true, cost=7},
	["RotK The Broken Horn of Gondor"] = {vp=1, isArtifact=true, cost=5},
	["RotK The Crown of the King"] = {vp=2, isArtifact=true, cost=6},
	["RotK The White Tree of Gondor"] = {vp=1, isArtifact=true, cost=4},
	--Locations
	["RotK Minas Morgul"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["RotK Minas Tirith"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["RotK Mount Doom"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	["RotK Osgiliath"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	["RotK The Plains of Gorgoroth"] = {vp=2, isLocation=true, isOngoing=true, cost=5},
	["RotK The Tower of Cirith Ungol"] = {vp=1, isLocation=true, isDefense=true, isOngoing=true, cost=5},
	--Fortunes
	["RotK A Vision of the Future"] = {vp=0, cost=0},
	["RotK The Dead Men of Dunharrow Arrive"] = {vp=0, cost=0},
	["RotK The Giant Eagles Save the Day"] = {vp=0, cost=0},
	["RotK The Reforging of Andúril"] = {vp=0, cost=0},
	--Archenemies
	["RotK Gorbag"] = {vp=7, isEnemy=true, isBoss=true, isAttack=true, cost=11},
	["RotK Gothmog"] = {vp=7, isEnemy=true, isBoss=true, cost=11},
	["RotK Grond"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["RotK Guritz"] = {vp=6, isEnemy=true, isBoss=true, cost=10},
	["RotK Lord Denethor"] = {vp=6, isEnemy=true, isBoss=true, cost=10},
	["RotK Oliphant"] = {vp=7, isEnemy=true, isBoss=true, cost=11},
	["RotK Saruman, the Defeated"] = {vp=4, isEnemy=true, isBoss=true, isStartBoss=true, cost=8},
	["RotK Shelob"] = {vp=8, isEnemy=true, isBoss=true, cost=12},
	["RotK Siege Troll"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["RotK Squadron of Nazgûl"] = {vp=8, isEnemy=true, isBoss=true, cost=12},
	["RotK The Eye of Sauron"] = {vp=11, isEnemy=true, isBoss=true, isOngoing=true, cost=25},
	["RotK The Witch-King of Angmar"] = {vp=9, isEnemy=true, isBoss=true, cost=14},
	--Impossible
	["RotK Gothmog (Impossible Mode)"] = {vp=7, isEnemy=true, isBoss=true, cost=12},
	["RotK Grond (Impossible Mode)"] = {vp=5, isEnemy=true, isBoss=true, cost=10},
	["RotK Lord Denethor (Impossible Mode)"] = {vp=6, isEnemy=true, isBoss=true, cost=11},
	["RotK Saruman, the Defeated (Impossible Mode)"] = {vp=4, isEnemy=true, isBoss=true, isStartBoss=true, cost=9},
	["RotK Shelob (Impossible Mode)"] = {vp=8, isEnemy=true, isBoss=true, cost=13},
	["RotK Squadron of Nazgûl (Impossible Mode)"] = {vp=8, isEnemy=true, isBoss=true, cost=14},
	["RotK The Eye of Sauron (Impossible Mode)"] = {vp=11, isEnemy=true, isBoss=true, isOngoing=true, cost=16},
	["RotK The Witch-King of Angmar (Impossible Mode)"] = {vp=9, isEnemy=true, isBoss=true, cost=15},
	--Oversized Character Cards
	["RotK Aragorn"] = {vp=0, isCharacter=true,},
	["RotK Éowyn"] = {vp=0, isCharacter=true,},
	["RotK Faramir"] = {vp=0, isCharacter=true,},
	["RotK Gandalf"] = {vp=0, isCharacter=true,},
	["RotK Gimli & Legolas Greenleaf"] = {vp=0, isCharacter=true,},
	["RotK King Théoden"] = {vp=0, isCharacter=true,},
	["RotK Merry"] = {vp=0, isCharacter=true,},
	["RotK Pippin"] = {vp=0, isCharacter=true,},
	["RotK Samwise Gamgee & Frodo Baggins"] = {vp=0, isCharacter=true,},
	--5)4) Unexpected Journey
	--Other
	["UJ Corruption"] = {vp=-1, isCorruption=true, cost=0},
	["UJ Courage"] = {vp=0, isStarter=true, isCourage=true, cost=0},
	["UJ Despair"] = {vp=0, isStarter=true, cost=0},
	["UJ Impossible Mode"] = {vp=0,},
	--Allies
	["UJ Balin the Dwarf"] = {vp=1, isAlly=true, cost=2},
	["UJ Bifur the Dwarf"] = {vp=1, isAlly=true, cost=2},
	["UJ Bilbo Baggins"] = {vp=1, isAlly=true, cost=5},
	["UJ Bofur the Dwarf"] = {vp=1, isAlly=true, cost=2},
	["UJ Bombur the Dwarf"] = {vp=1, isAlly=true, cost=2},
	["UJ Dori the Dwarf"] = {vp=1, isAlly=true, cost=3},
	["UJ Dwalin the Dwarf"] = {vp=1, isAlly=true, cost=2},
	["UJ Eagles"] = {vp=1, isAlly=true, isDefense=true, cost=3},
	["UJ Elrond"] = {vp=2, isAlly=true, cost=6},
	["UJ Fíli the Dwarf"] = {vp=1, isAlly=true, isAttack=true, cost=3},
	["UJ Galadriel"] = {vp=2, isAlly=true, cost=6},
	["UJ Gandalf the Grey"] = {vp=2, isAlly=true, cost=7},
	["UJ Glóin the Dwarf"] = {vp=1, isAlly=true, cost=3},
	["UJ Kíli the Dwarf"] = {vp=1, isAlly=true, isAttack=true, cost=3},
	["UJ Nori the Dwarf"] = {vp=1, isAlly=true, cost=3},
	["UJ Óin the Dwarf"] = {vp=1, isAlly=true, cost=3},
	["UJ Ori the Dwarf"] = {vp=1, isAlly=true, cost=3},
	["UJ Radagast"] = {vp=1, isAlly=true, cost=4},
	["UJ Reinforcements"] = {vp=1, isAlly=true, isDefense=true, cost=4},
	["UJ Saruman the White"] = {vp=2, isAlly=true, cost=6},
	["UJ The Company"] = {vp=1, isAlly=true, cost=4},
	["UJ Thorin Oakenshield"] = {vp=2, isAlly=true, cost=5},
	--Enemies
	["UJ Goblin Captors"] = {vp=2, isEnemy=true, isAttack=true, cost=6},
	["UJ Goblin Patrol"] = {vp=1, isEnemy=true, isAttack=true, cost=3},
	["UJ Goblin Runner"] = {vp=1, isEnemy=true, cost=3},
	["UJ Goblin Scout"] = {vp=1, isEnemy=true, cost=2},
	["UJ Goblin Soldier"] = {vp=1, isEnemy=true, cost=2},
	["UJ Gollum"] = {vp=1, isEnemy=true, isAttack=true, cost=5},
	["UJ Orc Leader"] = {vp=0, isEnemy=true, cost=4},
	["UJ Orc Pack"] = {vp=2, isEnemy=true, cost=6},
	["UJ Orc Rider"] = {vp=1, isEnemy=true, cost=5},
	["UJ Stone Giants"] = {vp=3, isEnemy=true, isAttack=true, cost=8},
	["UJ Wargs"] = {vp=1, isEnemy=true, cost=4},
	["UJ Witch-King"] = {vp=2, isEnemy=true, cost=7},
	--Maneuvers
	["UJ A Short Rest"] = {vp=1, isManeuver=true, isDefense=true, cost=5},
	["UJ Escape!"] = {vp=6, isManeuver=true, isLoot=true, cost=11},
	["UJ Magic"] = {vp=1, isManeuver=true, cost=4},
	["UJ Riddle Game"] = {vp=1, isManeuver=true, cost=4},
	["UJ Stick to the Path"] = {vp=1, isManeuver=true, cost=3},
	["UJ That Will Do It"] = {vp=6, isManeuver=true, isLoot=true, cost=11},
	["UJ Valor"] = {vp=1, isManeuver=true, cost=3},
	["UJ What Have I Got In My Pocket"] = {vp=6, isManeuver=true, isLoot=true, cost=11},
	["UJ Wizard Council"] = {vp=1, isManeuver=true, cost=6},
	["UJ Wizard Voice"] = {vp=2, isManeuver=true, cost=7},
	["UJ You've Got to be Joking"] = {vp=6, isManeuver=true, isLoot=true, cost=11},
	--Artifacts
	["UJ Dwarven Sling"] = {vp=1, isArtifact=true, cost=4},
	["UJ Flaming Pine Cone"] = {vp=2, isArtifact=true, cost=6},
	["UJ Glamdring \"The Foehammer\""] = {vp=5, isArtifact=true, isLoot=true, cost=9},
	["UJ Healing Potion"] = {vp=1, isArtifact=true, isDefense=true, cost=2},
	["UJ Lantern"] = {vp=1, isArtifact=true, cost=3},
	["UJ Morgul Blade"] = {vp=2, isArtifact=true, cost=6},
	["UJ Orcrist \"The Goblin-Cleaver\""] = {vp=5, isArtifact=true, isLoot=true, cost=9},
	["UJ Pints"] = {vp=1, isArtifact=true, cost=3},
	["UJ Pipe-Weed"] = {vp=1, isArtifact=true, cost=2},
	["UJ Ponies"] = {vp=1, isArtifact=true, cost=4},
	["UJ Rhosgobel Rabbit Sled"] = {vp=1, isArtifact=true, cost=3},
	["UJ Sting"] = {vp=5, isArtifact=true, isLoot=true, cost=9},
	["UJ The Contract"] = {vp=0, isArtifact=true, cost=4},
	["UJ The Key to Erebor"] = {vp=2, isArtifact=true, cost=7},
	["UJ The Map"] = {vp=2, isArtifact=true, cost=7},
	["UJ The Oaken Shield"] = {vp=2, isArtifact=true, isDefense=true, isOngoing=true, cost=6},
	["UJ The One Ring"] = {vp=2, isArtifact=true, isDefense=true, isOngoing=true, cost=0},
	["UJ Troll Hoard"] = {vp=5, isArtifact=true, isLoot=true, cost=9},
	["UJ Wizard Staff"] = {vp=1, isArtifact=true, cost=2},
	--Locations
	["UJ Bag End"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["UJ Dol Guldur"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["UJ Goblin Town"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["UJ Rhosgobel"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["UJ The Last Homely Home"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	--Archenemies
	["UJ Azog"] = {vp=7, isEnemy=true, isBoss=true, cost=14},
	["UJ Great Goblin"] = {vp=0, isEnemy=true, isBoss=true, cost=11},
	["UJ The Trolls"] = {vp=0, isEnemy=true, isBoss=true, isStartBoss=true, cost=9},
	--Impossible
	["UJ Azog (Impossible Mode)"] = {vp=7, isEnemy=true, isBoss=true, cost=15},
	["UJ Great Goblin (Impossible Mode)"] = {vp=0, isEnemy=true, isBoss=true, cost=12},
	["UJ The Trolls (Impossible Mode)"] = {vp=0, isEnemy=true, isBoss=true, isStartBoss=true, cost=10},
	--Oversized Character Cards
	["UJ Balin the Dwarf (Character)"] = {vp=0, isCharacter=true,},
	["UJ Bilbo Baggins (Character)"] = {vp=0, isCharacter=true,},
	["UJ Dwalin the Dwarf (Character)"] = {vp=0, isCharacter=true,},
	["UJ Gandalf"] = {vp=0, isCharacter=true,},
	["UJ Glóin the Dwarf (Character)"] = {vp=0, isCharacter=true,},
	["UJ Óin the Dwarf (Character)"] = {vp=0, isCharacter=true,},
	["UJ Radagast"] = {vp=0, isCharacter=true,},
	["UJ Thorin Oakenshield (Character)"] = {vp=0, isCharacter=true,},
	--5)5) The Desolation of Smaug
	--Other
	["DoS Corruption (Hoarding)"] = {vp=0, isCorruption=true, cost=0},
	--Allies
	["DoS Beorn"] = {vp=3, isAlly=true, cost=9},
	["DoS Captain of Mirkwood"] = {vp=1, isAlly=true, cost=5},
	["DoS Defender of Lake-Town"] = {vp=3, isAlly=true, cost=10},
	["DoS King Under the Mountain"] = {vp=3, isAlly=true, cost=8},
	["DoS Master of Lake-Town"] = {vp=0, isAlly=true, cost=4},
	["DoS Prince of Mirkwood"] = {vp=2, isAlly=true, cost=7},
	["DoS The Burglar"] = {vp=2, isAlly=true, cost=6},
	--Enemies
	["DoS Alfrid"] = {vp=1, isEnemy=true, isAttack=true, cost=4},
	["DoS Bolg"] = {vp=3, isEnemy=true, cost=9},
	["DoS Fimbul The Hunter"] = {vp=2, isEnemy=true, cost=6},
	["DoS Giant Spiders"] = {vp=3, isEnemy=true, isAttack=true, cost=10},
	["DoS Lake-Town Guards"] = {vp=1, isEnemy=true, cost=5},
	["DoS Orc Archer"] = {vp=2, isEnemy=true, isAttack=true, cost=7},
	["DoS Thranduil"] = {vp=3, isEnemy=true, isAttack=true, cost=8},
	--Maneuvers
	["DoS A Tender Moment"] = {vp=1, isManeuver=true, cost=5},
	["DoS A Warm Send-Off"] = {vp=1, isManeuver=true, cost=4},
	["DoS Barrel of Fun"] = {vp=2, isManeuver=true, isOngoing=true, cost=6},
	["DoS Escape the Flames"] = {vp=2, isManeuver=true, isDefense=true, cost=7},
	["DoS Hide and Seek"] = {vp=3, isManeuver=true, isDefense=true, cost=8},
	["DoS Re-Lighting the Forge"] = {vp=0, isManeuver=true, cost=10},
	["DoS What Have We Done"] = {vp=3, isManeuver=true, isAttack=true, cost=9},
	--Artifacts
	["DoS A Sea of Baubles"] = {vp=7, isArtifact=true, isLoot=true, cost=13},
	["DoS A Small Cup"] = {vp=7, isArtifact=true, isLoot=true, cost=13},
	["DoS Black Arrow"] = {vp=3, isArtifact=true, cost=9},
	["DoS Durin's Line Tapestry"] = {vp=3, isArtifact=true, cost=8},
	["DoS Lake-Town Ballista"] = {vp=2, isArtifact=true, cost=7},
	["DoS Mountains of Gold"] = {vp=7, isArtifact=true, isLoot=true, cost=13},
	["DoS River Barrels"] = {vp=1, isArtifact=true, cost=6},
	["DoS Runestone"] = {vp=1, isArtifact=true, isDefense=true, cost=4},
	["DoS The Arkenstone"] = {vp=7, isArtifact=true, isLoot=true, isOngoing=true, cost=13},
	["DoS The Barge"] = {vp=1, isArtifact=true, cost=5},
	["DoS The Golden Statue"] = {vp=3, isArtifact=true, cost=10},
	--Locations
	["DoS Erebor"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	["DoS House of Beorn"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	["DoS Lake-Town"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	["DoS Mirkwood Forest"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	--Archenemies
	["DoS Smaug the Magnificent"] = {vp=0, isEnemy=true, isBoss=true, cost=15},
	["DoS Smaug the Terrible"] = {vp=8, isEnemy=true, isBoss=true, cost=20},
	--Impossible
	["DoS Smaug the Magnificent (Impossible Mode)"] = {vp=0, isEnemy=true, isBoss=true, cost=16},
	["DoS Smaug the Terrible (Impossible Mode)"] = {vp=8, isEnemy=true, isBoss=true, cost=21},
	--Oversized Character Cards
	["DoS Bard the Bowman"] = {vp=0, isCharacter=true,},
	["DoS Bifur the Dwarf"] = {vp=0, isCharacter=true,},
	["DoS Bofur the Dwarf"] = {vp=0, isCharacter=true,},
	["DoS Bombur the Dwarf"] = {vp=0, isCharacter=true,},
	["DoS Fíli the Dwarf"] = {vp=0, isCharacter=true,},
	["DoS Kíli the Dwarf"] = {vp=0, isCharacter=true,},
	["DoS Legolas Greenleaf"] = {vp=0, isCharacter=true,},
	["DoS Tauriel"] = {vp=0, isCharacter=true,},
	--6)1) Street Fighter
	--Other
	["SF Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["SF Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["SF Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Heroes
	["SF Cammy, Delta Red"] = {vp=1, isHero=true, cost=2},
	["SF Dudley"] = {vp=1, isHero=true, cost=5},
	["SF Fei Long, Hong Kong Action Hero"] = {vp=2, isHero=true, cost=6},
	["SF Hot-Blooded Sumo"] = {vp=1, isHero=true, cost=3},
	["SF Jungle Warrior"] = {vp=0, isHero=true, cost=5}, -- 5 VP for 5 different Super Powers
	["SF Ken Masters"] = {vp=1, isHero=true, cost=4},
	["SF Mystic Yogi"] = {vp=1, isHero=true, cost=4},
	["SF Red Cyclone"] = {vp=1, isHero=true, cost=5},
	["SF Rose"] = {vp=1, isHero=true, cost=2},
	["SF Sakura"] = {vp=1, isHero=true, isDefense=true, cost=3},
	["SF Soldier of Justice"] = {vp=2, isHero=true, cost=6},
	["SF Strongest Woman in the World"] = {vp=2, isHero=true, cost=7},
	["SF Tireless Warrior"] = {vp=3, isHero=true, cost=8},
	--Villains
	["SF Agents of Shadaloo"] = {vp=0, isVillain=true, cost=4},
	["SF Balrog"] = {vp=1, isVillain=true, isAttack=true, cost=3},
	["SF Gill"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["SF Hugo"] = {vp=1, isVillain=true, cost=3},
	["SF Juri"] = {vp=1, isVillain=true, isAttack=true, cost=2},
	["SF M. Bison"] = {vp=3, isVillain=true, isAttack=true, cost=7},
	["SF Master of the Fist"] = {vp=2, isVillain=true, isAttack=true, cost=6},
	["SF Rolento"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["SF Sagat"] = {vp=2, isVillain=true, cost=6},
	["SF Seth"] = {vp=3, isVillain=true, cost=8},
	["SF Sodom"] = {vp=1, isVillain=true, cost=5},
	["SF Urien"] = {vp=1, isVillain=true, isDefense=true, cost=3},
	["SF Vega"] = {vp=2, isVillain=true, cost=6},
	--Super Powers
	["SF Dash Straight"] = {vp=1, isSuperPower=true, isDefense=true, cost=4},
	["SF Electric Thunder"] = {vp=3, isSuperPower=true, isDefense=true, cost=7},
	["SF Flying Barcelona"] = {vp=1, isSuperPower=true, cost=3},
	["SF Galactic Tornado"] = {vp=2, isSuperPower=true, cost=6},
	["SF Gohadoken"] = {vp=1, isSuperPower=true, cost=4},
	["SF Hadoken"] = {vp=2, isSuperPower=true, cost=6},
	["SF Hundred Hand Slap"] = {vp=1, isSuperPower=true, cost=3},
	["SF Hyakuretsukyaku"] = {vp=1, isSuperPower=true, cost=3},
	["SF Kick"] = {vp=1, isSuperPower=true, cost=3, id=9883},
	["SF Psycho Crusher"] = {vp=3, isSuperPower=true, cost=8},
	["SF Rolling Thunder"] = {vp=1, isSuperPower=true, isDefense=true, cost=1},
	["SF Shinku Hadoken"] = {vp=1, isSuperPower=true, cost=4},
	["SF Shippu Jinraikayu"] = {vp=1, isSuperPower=true, cost=4},
	["SF Sonic Boom"] = {vp=1, isSuperPower=true, cost=3},
	["SF Tiger Shot"] = {vp=2, isSuperPower=true, cost=6},
	["SF Yoga Teleport"] = {vp=1, isSuperPower=true, cost=2},
	--Equipment
	["SF Akuma's Gi"] = {vp=0, isEquipment=true, cost=4}, --1 VP for Each unique Atk card
	["SF Balrog's Gloves"] = {vp=1, isEquipment=true, isAttack=true, cost=2},
	["SF Chun-Li's Bracelets"] = {vp=1, isEquipment=true, isDefense=true, cost=3},
	["SF Rolento's Baton"] = {vp=0, isEquipment=true, cost=5}, -- 1 VP for Each unique Def card
	["SF Ryu's Headband"] = {vp=1, isEquipment=true, cost=2},
	["SF Sagat's Eyepatch"] = {vp=1, isEquipment=true, cost=3},
	["SF Tanden Engine"] = {vp=2, isEquipment=true, cost=7},
	["SF Vega's Claw & Mask"] = {vp=2, isEquipment=true, cost=6},
	--Locations
	["SF USA"] = {vp=5, isLocation=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=7},
	["SF Hong Kong"] = {vp=6, isLocation=true, isBoss=true, isOngoing=true, cost=8},
	["SF Japan"] = {vp=6, isLocation=true, isBoss=true, isOngoing=true, cost=9},
	["SF India"] = {vp=6, isLocation=true, isBoss=true, isOngoing=true, cost=10},
	["SF Brazil"] = {vp=7, isLocation=true, isBoss=true, isOngoing=true, cost=10},
	["SF Russia"] = {vp=7, isLocation=true, isBoss=true, isOngoing=true, cost=10},
	["SF United Kingdom"] = {vp=7, isLocation=true, isBoss=true, isOngoing=true, cost=11},
	["SF Thailand"] = {vp=8, isLocation=true, isBoss=true, isOngoing=true, cost=12},
	["SF Jamaica"] = {vp=6, isLocation=true, isBoss=true, isOngoing=true, cost=10},
	["SF Mexico"] = {vp=7, isLocation=true, isBoss=true, isOngoing=true, cost=11},
	--Ultras
	["SF Bloody High Claw"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Gyro Drive Smasher"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Hosenka"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Lightning Cannonball"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Metsu Hadoken"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Phycho Punisher"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Rekkashingeki"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Shinryuken"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Sonic Hurricane"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Tiger Destruction"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Ultimate Atomic Buster"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Ultimate Killer Head Ram"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Violent Buffalo"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Wrath of the Raging Demon"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Yoga Catastrophe"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Raging Slash"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	["SF Sobat Festival"] = {vp=2, isAttack=true, isDefense=true, cost=6},
	--Oversized Character Cards
	["Akuma"] = {vp=0, isCharacter=true,},
	["Balrog"] = {vp=0, isCharacter=true,},
	["Blanka"] = {vp=0, isCharacter=true,},
	["Cammy"] = {vp=0, isCharacter=true,},
	["Chun-Li"] = {vp=0, isCharacter=true,},
	["Dhalsim"] = {vp=0, isCharacter=true,},
	["E. Honda"] = {vp=0, isCharacter=true,},
	["Fei Long"] = {vp=0, isCharacter=true,},
	["Guile"] = {vp=0, isCharacter=true,},
	["Ken"] = {vp=0, isCharacter=true,},
	["M. Bison"] = {vp=0, isCharacter=true,},
	["Ryu"] = {vp=0, isCharacter=true,},
	["Sagat"] = {vp=0, isCharacter=true,},
	["Vega"] = {vp=0, isCharacter=true,},
	["Zangief"] = {vp=0, isCharacter=true,},
	["Dee Jay"] = {vp=0, isCharacter=true,},
	["T. Hawk"] = {vp=0, isCharacter=true,},
	--6)2) Naruto Shippuden
	--Other
	["NS Handsign"] = {vp=0, cost=1},
	["NS Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["NS Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["NS Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Allies
	["NS Asuma"] = {vp=0, isAlly=true, isChakara=true, cost=5},
	["NS Choji"] = {vp=1, isAlly=true, isChakara=true, cost=2},
	["NS Hinata"] = {vp=1, isAlly=true, cost=3},
	["NS Ino"] = {vp=1, isAlly=true, cost=4},
	["NS Jiraiya"] = {vp=0, isAlly=true, cost=7},
	["NS Kakashi"] = {vp=2, isAlly=true, cost=6},
	["NS Kiba"] = {vp=1, isAlly=true, cost=3},
	["NS Killer Bee"] = {vp=3, isAlly=true, cost=8},
	["NS Might Guy"] = {vp=2, isAlly=true, isPositive=true, cost=6},
	["NS Naruto"] = {vp=1, isAlly=true, cost=4},
	["NS Neji"] = {vp=1, isAlly=true, isPositive=true, cost=3},
	["NS Rock Lee"] = {vp=1, isAlly=true, isPositive=true, cost=3},
	["NS Sai"] = {vp=1, isAlly=true, isDefense=true, cost=2},
	["NS Sakura"] = {vp=1, isAlly=true, isPositive=true, cost=2},
	["NS Shikamaru"] = {vp=1, isAlly=true, isDefense=true, cost=4},
	["NS Tsunade"] = {vp=3, isAlly=true, cost=7},
	["NS Yamato"] = {vp=1, isAlly=true, cost=5},
	--Enemies
	["NS Chinkushodo (Path of Pain)"] = {vp=1, isEnemy=true, isPathOfPain=true, cost=4},
	["NS Danzo"] = {vp=2, isEnemy=true, isAttack=true, cost=7},
	["NS Dark Naruto"] = {vp=1, isEnemy=true, isDefense=true, cost=5},
	["NS Gakido (Path of Pain)"] = {vp=1, isEnemy=true, isPathOfPain=true, isDefense=true, cost=3},
	["NS Gedo Statue"] = {vp=2, isEnemy=true, isAttack=true, cost=6},
	["NS Jigokudou (Path of Pain)"] = {vp=1, isEnemy=true, isPathOfPain=true, cost=2},
	["NS Jugo"] = {vp=1, isEnemy=true, cost=4},
	["NS Kabuto"] = {vp=3, isEnemy=true, isChakara=true, cost=8},
	["NS Karin"] = {vp=1, isEnemy=true, cost=3},
	["NS Ningendo (Path of Pain)"] = {vp=0, isEnemy=true, isPathOfPain=true, cost=2},
	["NS Shurado (Path of Pain)"] = {vp=1, isEnemy=true, isPathOfPain=true, isAttack=true, cost=4},
	["NS Suigetsu"] = {vp=1, isEnemy=true, isChakara=true, cost=5},
	["NS Tendo (Path of Pain)"] = {vp=2, isEnemy=true, isPathOfPain=true, isPositive=true, cost=7},
	["NS Zabuza"] = {vp=0, isEnemy=true, isChakara=true, cost=6},
	--Techniques
	["NS Byakugan"] = {vp=1, isTechnique=true, cost=2},
	["NS Eight Gates"] = {vp=1, isTechnique=true, isPositive=true, cost=4},
	["NS Gentle Step Twin Lion Fist"] = {vp=1, isTechnique=true, isAttack=true, cost=4},
	["NS Kick"] = {vp=1, isTechnique=true, cost=3, id=9883},
	["NS Lightning Blade"] = {vp=0, isTechnique=true, cost=6},
	["NS Medical Jutsu"] = {vp=2, isTechnique=true, isChakara=true, cost=6},
	["NS Rasengan"] = {vp=2, isTechnique=true, isAttack=true, isChakara=true, cost=7},
	["NS Rasenshuriken"] = {vp=2, isTechnique=true, cost=6},
	["NS Reanimation"] = {vp=1, isTechnique=true, isPositive=true, cost=7},
	["NS Sexy Jutsu"] = {vp=1, isTechnique=true, cost=2},
	["NS Shadow Clone"] = {vp=1, isTechnique=true, isChakara=true, cost=5},
	["NS Shadow Stitching"] = {vp=1, isTechnique=true, isDefense=true, cost=3},
	["NS Sharingan"] = {vp=1, isTechnique=true, isDefense=true, cost=4},
	["NS Tailed Beast Bomb"] = {vp=3, isTechnique=true, isChakara=true, cost=7},
	--Equipment
	["NS Chakra Blade"] = {vp=1, isEquipment=true, isAttack=true, cost=3},
	["NS Executioner's Blade"] = {vp=3, isEquipment=true, cost=7},
	["NS Katsuyu Clone"] = {vp=1, isEquipment=true, isPositive=true, cost=4},
	["NS Kunai"] = {vp=1, isEquipment=true, isAttack=true, cost=3},
	["NS Paper Bomb"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
	["NS Poison Fog"] = {vp=1, isEquipment=true, isAttack=true, cost=2},
	["NS Scroll"] = {vp=1, isEquipment=true, isChakara=true, cost=5},
	["NS Seal"] = {vp=1, isEquipment=true, cost=2},
	["NS Shark Skin"] = {vp=2, isEquipment=true, isPositive=true, cost=6},
	["NS Shuriken"] = {vp=1, isEquipment=true, cost=3},
	--Locations
	["NS Hidden Cloud Village"] = {vp=1, isLocation=true, isOngoing=true, isChakara=true, cost=6},
	["NS Hidden Leaf Village"] = {vp=1, isLocation=true, isOngoing=true, isChakara=true, cost=6},
	["NS Hidden Rain Village"] = {vp=1, isLocation=true, isOngoing=true, isChakara=true, cost=6},
	["NS Hidden Sand Village"] = {vp=1, isLocation=true, isOngoing=true, isChakara=true, cost=6},
	["NS Mount Myoboku"] = {vp=2, isLocation=true, isOngoing=true, cost=7},
	--Archenemies
	["NS Deidara"] = {vp=4, isEnemy=true, isBoss=true, cost=8},
	["NS Hidan"] = {vp=5, isEnemy=true, isBoss=true, cost=10},
	["NS Itachi"] = {vp=6, isEnemy=true, isBoss=true, isPositive=true, cost=11},
	["NS Kakuzu"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["NS Kisame"] = {vp=6, isEnemy=true, isBoss=true, cost=11},
	["NS Konan"] = {vp=6, isEnemy=true, isBoss=true, cost=12},
	["NS Nagato"] = {vp=6, isEnemy=true, isBoss=true, cost=11},
	["NS Orochimaru"] = {vp=4, isEnemy=true, isBoss=true, isStartBoss=true, isOngoing=true, cost=8},
	["NS Sasori"] = {vp=5, isEnemy=true, isBoss=true, cost=10},
	["NS Sasuke"] = {vp=5, isEnemy=true, isBoss=true, cost=9},
	["NS Tobi"] = {vp=7, isEnemy=true, isBoss=true, cost=13},
	["NS Zetsu"] = {vp=6, isEnemy=true, isBoss=true, cost=12},
	--Oversized Character Cards
	["Hinata"] = {vp=0, isCharacter=true,},
	["Jiraiya"] = {vp=0, isCharacter=true,},
	["Kakashi"] = {vp=0, isCharacter=true,},
	["Killer Bee"] = {vp=0, isCharacter=true,},
	["Mecha-Naruto"] = {vp=0, isCharacter=true,},
	["Minato"] = {vp=0, isCharacter=true,},
	["Naruto"] = {vp=0, isCharacter=true,},
	["Sakura"] = {vp=0, isCharacter=true,},
	["Shikamaru"] = {vp=0, isCharacter=true,},
	--6)3) NHL
	--Other
	["NHL Pass"] = {vp=0, isStarter=true,},
	["NHL Tangled on the Boards"] = {vp=0, isStarter=true,},
	["NHL Slapshot"] = {vp=0,},
	["NHL Penalty"] = {vp=0, isPenalty=true,},
	--Attacker
	["NHL Adam Henrique"] = {vp=0, isAttacker=true, cost=3},
	["NHL Alex Ovechkin"] = {vp=0, isAttacker=true, cost=7},
	["NHL Bobby Ryan"] = {vp=0, isAttacker=true, cost=2},
	["NHL Claude Giroux"] = {vp=0, isAttacker=true, cost=5},
	["NHL Corey Perry"] = {vp=0, isAttacker=true, cost=6},
	["NHL Evander Kane"] = {vp=0, isAttacker=true, cost=3},
	["NHL Henrik Sedin"] = {vp=0, isAttacker=true, cost=4},
	["NHL Henrik Zetterberg"] = {vp=0, isAttacker=true, cost=6},
	["NHL Jeff Skinner"] = {vp=0, isAttacker=true, cost=2},
	["NHL Joe Thornton"] = {vp=0, isAttacker=true, cost=3},
	["NHL John Tavares"] = {vp=0, isAttacker=true, cost=4},
	["NHL Jonathan Toews"] = {vp=0, isAttacker=true, cost=6},
	["NHL Matt Duchene"] = {vp=0, isAttacker=true, cost=5},
	["NHL Max Pacioretty"] = {vp=0, isAttacker=true, cost=4},
	["NHL Nathan MacKinnon"] = {vp=0, isAttacker=true, cost=3},
	["NHL Nicklas Backstrom"] = {vp=0, isAttacker=true, cost=5},
	["NHL Patrice Bergeron"] = {vp=0, isAttacker=true, cost=5},
	["NHL Pavel Datsyuk"] = {vp=0, isAttacker=true, cost=7},
	["NHL Phil Kessel"] = {vp=0, isAttacker=true, cost=6},
	["NHL Scott Hartnell"] = {vp=0, isAttacker=true, cost=4},
	["NHL Sidney Crosby"] = {vp=0, isAttacker=true, cost=7},
	["NHL Steven Stamkos"] = {vp=0, isAttacker=true, cost=3},
	["NHL Taylor Hall"] = {vp=0, isAttacker=true, cost=4},
	["NHL Teuvo Teräväinen"] = {vp=0, isAttacker=true, cost=2},
	["NHL Tyler Seguin"] = {vp=0, isAttacker=true, cost=4},
	["NHL Zach Parise"] = {vp=0, isAttacker=true, cost=5},
	--Defender
	["NHL Alex Goligoski"] = {vp=0, isDefender=true, isDefense=true, cost=2},
	["NHL Alex Pietrangelo"] = {vp=0, isDefender=true, isDefense=true, cost=5},
	["NHL Alexander Edler"] = {vp=0, isDefender=true, isDefense=true, cost=3},
	["NHL Andrei Markov"] = {vp=0, isDefender=true, isDefense=true, cost=2},
	["NHL Cam Fowler"] = {vp=0, isDefender=true, isDefense=true, cost=3},
	["NHL Drew Doughty"] = {vp=0, isDefender=true, isDefense=true, cost=5},
	["NHL Dion Phaneuf"] = {vp=0, isDefender=true, isDefense=true, cost=4},
	["NHL Duncan Keith"] = {vp=0, isDefender=true, isDefense=true, cost=6},
	["NHL Erik Karlsson"] = {vp=0, isDefender=true, isDefense=true, cost=7},
	["NHL Jack Johnson"] = {vp=0, isDefender=true, isDefense=true, cost=3},
	["NHL Jay Bouwmeester"] = {vp=0, isDefender=true, isDefense=true, cost=4},
	["NHL Justin Schultz"] = {vp=0, isDefender=true, isDefense=true, cost=3},
	["NHL Keith Yandle"] = {vp=0, isDefender=true, isDefense=true, cost=4},
	["NHL Marc-Ėdouard Vlasic"] = {vp=0, isDefender=true, isDefense=true, cost=3},
	["NHL Mark Giordano"] = {vp=0, isDefender=true, isDefense=true, cost=4},
	["NHL Niklas Kronwall"] = {vp=0, isDefender=true, isDefense=true, cost=5},
	["NHL Olli Maatta"] = {vp=0, isDefender=true, isDefense=true, cost=4},
	["NHL Ryan McDonagh"] = {vp=0, isDefender=true, isDefense=true, cost=5},
	["NHL Ryan Suter"] = {vp=0, isDefender=true, isDefense=true, cost=6},
	["NHL Shea Weber"] = {vp=0, isDefender=true, isDefense=true, cost=6},
	["NHL Tyler Myers"] = {vp=0, isDefender=true, isDefense=true, cost=2},
	["NHL Victor Hedman"] = {vp=0, isDefender=true, isDefense=true, cost=3},
	["NHL Zdeno Chara"] = {vp=0, isDefender=true, isDefense=true, cost=7},
	--Maneuver
	["NHL Backcheck"] = {vp=0, isManeuver=true, cost=2},
	["NHL Body Check"] = {vp=0, isManeuver=true, cost=5},
	["NHL Breakaway"] = {vp=0, isManeuver=true, cost=4},
	["NHL Challenge"] = {vp=0, isManeuver=true, cost=4},
	["NHL Cross-Check"] = {vp=0, isManeuver=true, cost=7},
	["NHL Drop Pass"] = {vp=0, isManeuver=true, cost=3},
	["NHL Fake Shot"] = {vp=0, isManeuver=true, cost=4},
	["NHL Forecheck"] = {vp=0, isManeuver=true, cost=2},
	["NHL High-Sticking"] = {vp=0, isManeuver=true, cost=3},
	["NHL Interference"] = {vp=0, isManeuver=true, cost=5},
	["NHL Power Play"] = {vp=0, isManeuver=true, cost=6},
	["NHL Wrap Around"] = {vp=0, isManeuver=true, cost=3},
	--Skill
	["NHL Coordination"] = {vp=0, isSkill=true, cost=3},
	["NHL Enforce"] = {vp=0, isSkill=true, cost=5},
	["NHL Face-Off Specialist"] = {vp=0, isSkill=true, cost=4},
	["NHL Fast Learner"] = {vp=0, isSkill=true, cost=7},
	["NHL Good Skater"] = {vp=0, isSkill=true, cost=2},
	["NHL Misconduct"] = {vp=0, isSkill=true, cost=4},
	["NHL One Timer"] = {vp=0, isSkill=true, cost=3},
	["NHL Penalty Killer"] = {vp=0, isSkill=true, cost=5},
	["NHL Speed"] = {vp=0, isSkill=true, cost=3},
	["NHL Stick-Handling"] = {vp=0, isSkill=true, cost=4},
	["NHL Strength"] = {vp=0, isSkill=true, cost=2},
	["NHL Teamwork"] = {vp=0, isSkill=true, cost=6},
	--Goalie
	["NHL Carey Price"] = {vp=0, isGoalie=true, isBoss=true, cost=11},
	["NHL Cory Schneider"] = {vp=0, isGoalie=true, isBoss=true, cost=9},
	["NHL Henrik Lundqvist"] = {vp=0, isGoalie=true, isBoss=true, cost=11},
	["NHL Jonathan Bernier"] = {vp=0, isGoalie=true, isBoss=true, cost=9},
	["NHL Jonathan Quick"] = {vp=0, isGoalie=true, isBoss=true, cost=12},
	["NHL Marc-Andre Fleury"] = {vp=0, isGoalie=true, isBoss=true, cost=10},
	["NHL Pekka Rinne"] = {vp=0, isGoalie=true, isBoss=true, cost=10},
	["NHL Roberto Luongo"] = {vp=0, isGoalie=true, isBoss=true, cost=9},
	["NHL Tuukka Rask"] = {vp=0, isGoalie=true, isBoss=true, cost=12},
	--Oversized Character Cards
	["NHL Alex Ovechkin (Character)"] = {vp=0, isCharacter=true,},
	["NHL Claude Giroux (Character)"] = {vp=0, isCharacter=true,},
	["NHL Dion Phaneuf (Character)"] = {vp=0, isCharacter=true,},
	["NHL Henrik Sedin (Character)"] = {vp=0, isCharacter=true,},
	["NHL Henrik Zetterberg (Character)"] = {vp=0, isCharacter=true,},
	["NHL Jonathan Toews (Character)"] = {vp=0, isCharacter=true,},
	["NHL Sidney Crosby (Character)"] = {vp=0, isCharacter=true,},
	["NHL Zdeno Chara (Character)"] = {vp=0, isCharacter=true,},
	--6)4) Attack on Titans
	--Other
	["AoT Courage"] = {vp=0, isStarter=true, cost=0},
	["AoT Thrust"] = {vp=0, isStarter=true, cost=0},
	["AoT Wound"] = {vp=0, isWound=true, isOngoing=true, cost=0},
	--Ally
	["AoT Bertholdt Hoover"] = {vp=1, isAlly=true, cost=5},
	["AoT Christa Lenz"] = {vp=1, isAlly=true, isDefense=true, cost=4},
	["AoT Cis"] = {vp=1, isAlly=true, cost=2},
	["AoT Commander Pyxis"] = {vp=2, isAlly=true, isDefense=true, cost=7},
	["AoT Eld"] = {vp=1, isAlly=true, cost=5},
	["AoT Gunther Schultz"] = {vp=1, isAlly=true, cost=3},
	["AoT Hannes"] = {vp=1, isAlly=true, isDefense=true, cost=3},
	["AoT Ian Dietrich"] = {vp=1, isAlly=true, cost=3},
	["AoT Jean Kirschtein"] = {vp=2, isAlly=true, cost=6},
	["AoT Jurgen"] = {vp=1, isAlly=true, cost=2},
	["AoT Keith Shadis"] = {vp=1, isAlly=true, cost=4},
	["AoT Kitts Woerman"] = {vp=1, isAlly=true, cost=3},
	["AoT Marco Bodt"] = {vp=1, isAlly=true, isDefense=true, cost=2},
	["AoT Miche Zacharius"] = {vp=1, isAlly=true, cost=4},
	["AoT Nanaba"] = {vp=1, isAlly=true, cost=4},
	["AoT Ness"] = {vp=1, isAlly=true, cost=3},
	["AoT Oruo Bozad"] = {vp=1, isAlly=true, cost=5},
	["AoT Petra"] = {vp=1, isAlly=true, cost=5},
	["AoT Reiner Bravn"] = {vp=2, isAlly=true, isDefense=true, cost=6},
	["AoT Thomas Wagner"] = {vp=1, isAlly=true, cost=2},
	["AoT Ymir"] = {vp=1, isAlly=true, cost=3},
	--Titans
	["AoT Titan(4-Meter)"] = {vp=2, isTitan=true, cost=2},
	["AoT Titan(5-Meter)"] = {vp=2, isTitan=true, cost=2},
	["AoT Titan(6-Meter)"] = {vp=3, isTitan=true, cost=3},
	["AoT Titan(7-Meter)"] = {vp=3, isTitan=true, cost=3},
	["AoT Titan(8-Meter)"] = {vp=4, isTitan=true, cost=4},
	["AoT Titan(9-Meter)"] = {vp=4, isTitan=true, cost=4},
	["AoT Titan(10-Meter)"] = {vp=5, isTitan=true, cost=5},
	--Maneuver
	["AoT Escape"] = {vp=1, isManeuver=true, isDefense=true, cost=4},
	["AoT Heroic Sacrifice"] = {vp=1, isManeuver=true, cost=4},
	["AoT Kill Shot"] = {vp=2, isManeuver=true, cost=7},
	["AoT Long-Distance Scouting Formation"] = {vp=1, isManeuver=true, cost=2},
	["AoT Pay Tribute"] = {vp=2, isManeuver=true, cost=6},
	["AoT Reel In"] = {vp=1, isManeuver=true, cost=2},
	["AoT Resupply"] = {vp=1, isManeuver=true, cost=3},
	["AoT Surprise Attack"] = {vp=1, isManeuver=true, cost=5},
	["AoT Swing Away"] = {vp=1, isManeuver=true, isDefense=true, cost=3},
	--Equipment
	["AoT 3D Gear"] = {vp=0, isEquipment=true, cost=2},
	["AoT Cannon"] = {vp=2, isEquipment=true, cost=6},
	["AoT Cloak"] = {vp=1, isEquipment=true, isDefense, cost=5},
	["AoT Flintlock Rifle"] = {vp=1, isEquipment=true, cost=3},
	["AoT Food"] = {vp=1, isEquipment=true, cost=3},
	["AoT Fuel Cannisters"] = {vp=1, isEquipment=true, cost=4},
	["AoT Horse"] = {vp=1, isEquipment=true, cost=2},
	["AoT Signal Flare"] = {vp=1, isEquipment=true, isDefense=true, cost=2},
	["AoT Swords"] = {vp=1, isEquipment=true, cost=4},
	["AoT Titan Trap"] = {vp=2, isEquipment=true, cost=7},
	--Locations
	["AoT Armory"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["AoT Forest of Giant Trees"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["AoT Hospital"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["AoT Old Survey Corps HQ"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["AoT Shiganshina"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	["AoT Training Grounds"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	--Titans on Attack
	["AoT Breakthrough"] = {vp=0,},
	["AoT Charge"] = {vp=0,},
	["AoT Crush"] = {vp=0,},
	["AoT Eat"] = {vp=0,},
	["AoT Grab"] = {vp=0,},
	["AoT Injure"] = {vp=0,},
	["AoT Reinforcements"] = {vp=0,},
	["AoT Scare"] = {vp=0,},
	["AoT Smile"] = {vp=0,},
	["AoT Steaming"] = {vp=0,},
	["AoT Titans on Attack"] = {vp=0,},
	--Boss Titans
	["AoT Armored Titan"] = {vp=9, isTitan=true, isBoss=true, cost=13,},
	["AoT Bean"] = {vp=7, isTitan=true, isBoss=true, cost=9,},
	["AoT Bearded Titan"] = {vp=7, isTitan=true, isBoss=true, cost=8,},
	["AoT Colossal Titan"] = {vp=7, isTitan=true, isBoss=true, cost=12,},
	["AoT Deviant Titan (10)"] = {vp=8, isTitan=true, isBoss=true, cost=10,},
	["AoT Deviant Titan (11)"] = {vp=8, isTitan=true, isBoss=true, cost=11,},
	["AoT Deviant Titan (12)"] = {vp=8, isTitan=true, isBoss=true, cost=12,},
	["AoT Female Titan"] = {vp=9, isTitan=true, isBoss=true, cost=15,},
	["AoT Smiling Titan"] = {vp=6, isTitan=true, isBoss=true, isStartBoss=true, cost=6,},
	["AoT Sonny"] = {vp=7, isTitan=true, isBoss=true, cost=7,},
	--Oversized Character Cards
	["AoT Armin"] = {vp=0, isCharacter=true,},
	["AoT Conny"] = {vp=0, isCharacter=true,},
	["AoT Eren"] = {vp=0, isCharacter=true,},
	["AoT Erwin"] = {vp=0, isCharacter=true,},
	["AoT Hange"] = {vp=0, isCharacter=true,},
	["AoT Levi"] = {vp=0, isCharacter=true,},
	["AoT Mikasa"] = {vp=0, isCharacter=true,},
	["AoT Sasha"] = {vp=0, isCharacter=true,},
	--7)1) Cartoon Network Crossover Crisis
	--Others
	["CN Inside Joke"] = {vp=0, cost=2},
	["CN Pratfall"] = {vp=0, isStarter=true, cost=0},
	["CN Punchies"] = {vp=0, isStarter=true, cost=0, id=8867},
	--Events
	["CN Ally Or Enemy"] = {vp=0,},
	["CN Clever Disguise"] = {vp=0,},
	["CN Compulsive Singing Disorder"] = {vp=0,},
	["CN Cowardice"] = {vp=0,},
	["CN Dancing Machine"] = {vp=0,},
	["CN Gravity Is Your Enemy"] = {vp=0,},
	["CN Hold Your Breath"] = {vp=0,},
	["CN Honk!"] = {vp=0,},
	["CN Invention Gone Haywire"] = {vp=0,},
	["CN Left Arm Twins"] = {vp=0,},
	["CN My Mom!"] = {vp=0,},
	["CN My Name's Not _____!"] = {vp=0,},
	["CN Quartz-Parchment-Shears"] = {vp=0,},
	["CN Red Hot Lava"] = {vp=0,},
	["CN Rescue The Princess"] = {vp=0,},
	["CN Save Christmas"] = {vp=0,},
	["CN Sleepover"] = {vp=0,},
	["CN With One Arm tied Behind My Back"] = {vp=0,},
	["CN Wouldn't Hurt A Fly"] = {vp=0,},
	["CN Zoo Powers Go!"] = {vp=0,},
	--Weakness
	["CN Afraid of Clowns"] = {vp=0, isWeakness=true, cost=0},
	["CN Allergic"] = {vp=0, isWeakness=true, cost=0},
	["CN Belson Bucks"] = {vp=0, isWeakness=true, cost=0},
	["CN Bullied"] = {vp=0, isWeakness=true, cost=0},
	["CN Cowardice Weakness"] = {vp=0, isWeakness=true, cost=0},
	["CN Dave Guy"] = {vp=0, isWeakness=true, cost=0},
	["CN Flung Forward in Time"] = {vp=0, isWeakness=true, cost=0},
	["CN I Don't Get It"] = {vp=0, isWeakness=true, cost=0},
	["CN Interfering Sister"] = {vp=0, isWeakness=true, cost=0},
	["CN Jealousy"] = {vp=0, isWeakness=true, cost=0},
	["CN Laziness"] = {vp=0, isWeakness=true, cost=0},
	["CN Lost Valhallen's Guitar"] = {vp=0, isWeakness=true, cost=0},
	["CN Mistaken Identity"] = {vp=0, isWeakness=true, cost=0},
	["CN No More Cookie Cat"] = {vp=0, isWeakness=true, cost=0},
	["CN One-Track Mind"] = {vp=0, isWeakness=true, cost=0},
	["CN Out of Chairs"] = {vp=0, isWeakness=true, cost=0},
	["CN Paralyzed With Fear"] = {vp=0, isWeakness=true, cost=0},
	["CN Repeated Rejection"] = {vp=0, isWeakness=true, cost=0},
	["CN Short"] = {vp=0, isWeakness=true, cost=0},
	["CN Singled Out"] = {vp=0, isWeakness=true, cost=0},
	["CN Stripped of Magical Powers"] = {vp=0, isWeakness=true, cost=0},
	["CN Toy You Can't Play With"] = {vp=0, isWeakness=true, cost=0},
	["CN Unleash The Destroyer of Worlds"] = {vp=0, isWeakness=true, cost=0},
	["CN Vanity"] = {vp=0, isWeakness=true, cost=0},
	["CN Wounded"] = {vp=0, isWeakness=true, cost=0},
	--Heroes
	["CN Amethyst"] = {vp=1, isHero=true, cost=4},
	["CN Anais Watterson"] = {vp=1, isHero=true, cost=2},
	["CN Bmo"] = {vp=1, isHero=true, cost=1},
	["CN Clarence"] = {vp=2, isHero=true, cost=7},
	["CN Courage"] = {vp=1, isHero=true, cost=3},
	["CN Darwin Watterson"] = {vp=1, isHero=true, isDefense=true, cost=3},
	["CN Dee Dee"] = {vp=1, isHero=true, cost=3},
	["CN Dexter"] = {vp=1, isHero=true, cost=3},
	["CN Finn"] = {vp=2, isHero=true, cost=6},
	["CN Garnet"] = {vp=1, isHero=true, cost=4},
	["CN Gumball Watterson"] = {vp=1, isHero=true, cost=5},
	["CN Jack"] = {vp=2, isHero=true, isDefense=true, cost=6},
	["CN Jake"] = {vp=2, isHero=true, cost=6},
	["CN Jeff"] = {vp=1, isHero=true, isDefense=true, cost=3},
	["CN Johnny Bravo"] = {vp=1, isHero=true, isAttack=true, cost=4},
	["CN Major Glory"] = {vp=2, isHero=true, cost=6},
	["CN Marceline"] = {vp=1, isHero=true, isDefense=true, cost=5},
	["CN Margaret"] = {vp=1, isHero=true, cost=3},
	["CN Mordecai"] = {vp=1, isHero=true, cost=2},
	["CN Muriel Bagge"] = {vp=1, isHero=true, cost=2},
	["CN Nature Kate"] = {vp=1, isHero=true, cost=4},
	["CN Nicole Watterson"] = {vp=1, isHero=true, isDefense=true, cost=1},
	["CN Pearl"] = {vp=1, isHero=true, cost=4},
	["CN Penny Fitzgerald"] = {vp=1, isHero=true, cost=2},
	["CN Princess Bubblegum"] = {vp=1, isHero=true, cost=5},
	["CN Richard Watterson"] = {vp=1, isHero=true, cost=7},
	["CN Rigby"] = {vp=1, isHero=true, cost=2},
	["CN Skips"] = {vp=1, isHero=true, cost=3},
	["CN Steven Universe"] = {vp=1, isHero=true, isDefense=true, cost=5},
	["CN Sumo"] = {vp=1, isHero=true, cost=5},
	["CN Suzy"] = {vp=1, isHero=true, cost=2},
	--Villains
	["CN Coach"] = {vp=1, isVillain=true, isAttack=true, cost=3},
	["CN Demongo"] = {vp=1, isVillain=true, cost=3},
	["CN Earl of Lemongrab"] = {vp=1, isVillain=true, cost=4},
	["CN Eustace Bagge"] = {vp=2, isVillain=true, isAttack=true, cost=6},
	["CN Freaky Fred"] = {vp=1, isVillain=true, isAttack=true, cost=2},
	["CN Gene"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["CN Gunter"] = {vp=1, isVillain=true, cost=5},
	["CN Jamie"] = {vp=1, isVillain=true, isAttack=true, cost=3},
	["CN Lapis Lazuli"] = {vp=1, isVillain=true, cost=4},
	["CN Le Quack"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["CN Mad Jack"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["CN Magic Man"] = {vp=2, isVillain=true, cost=7},
	["CN Miss Simian"] = {vp=1, isVillain=true, isAttack=true, cost=2},
	["CN Onion"] = {vp=1, isVillain=true, cost=4},
	["CN Peridot"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["CN Ringo"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["CN Rob"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["CN The Hammer"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	--Super Powers
	["CN Bubble"] = {vp=1, isSuperPower=true, isDefense=true, cost=5},
	["CN Death Kwon Do"] = {vp=2, isSuperPower=true, isAttack=true, cost=7},
	["CN Friendship"] = {vp=1, isSuperPower=true, cost=3},
	["CN Gem Fusion"] = {vp=2, isSuperPower=true, cost=6},
	["CN Irresistable"] = {vp=1, isSuperPower=true, cost=2},
	["CN Joy Virus"] = {vp=1, isSuperPower=true, cost=5},
	["CN Jungle Boy Strength"] = {vp=1, isSuperPower=true, cost=4},
	["CN Leaping Parry"] = {vp=1, isSuperPower=true, isDefense=true, cost=4},
	["CN Shapeshifting"] = {vp=2, isSuperPower=true, cost=6},
	["CN Stretching"] = {vp=1, isSuperPower=true, cost=2},
	["CN Super Science!"] = {vp=1, isSuperPower=true, cost=3},
	["CN Wizard Powers"] = {vp=1, isSuperPower=true, isDefense=true, cost=3},
	--Equipment
	["CN Backwards Belt"] = {vp=2, isEquipment=true, cost=7},
	["CN Bacon Pancakes"] = {vp=1, isEquipment=true, cost=3},
	["CN Benson's Clipboard"] = {vp=1, isEquipment=true, isDefense=true, cost=2},
	["CN Card Wars Cards"] = {vp=1, isEquipment=true, cost=4},
	["CN Clarence Dollars"] = {vp=1, isEquipment=true, cost=4},
	["CN Courage's Computer"] = {vp=2, isEquipment=true, cost=6},
	["CN Hair Cement"] = {vp=1, isEquipment=true, cost=3},
	["CN Jack's Sword"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
	["CN Legendary Glass of Time"] = {vp=1, isEquipment=true, isDefense=true, cost=3},
	["CN Mystery Pinata"] = {vp=1, isEquipment=true, isDefense=true, cost=5},
	["CN Robotic Exoskeleton"] = {vp=1, isEquipment=true, cost=2},
	["CN Rose's Light Cannon"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
	["CN The Slab"] = {vp=1, isEquipment=true, isDefense=true, cost=5},
	["CN Time Machine"] = {vp=1, isEquipment=true, isDefense=true, cost=2},
	--Locations
	["CN Beach City"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["CN Dome of Doom"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["CN Elmore"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["CN Nowhere, Kansas"] = {vp=1, isLocation=true, isOngoing=true, cost=3},
	["CN Pop's Moon Palace"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["CN Secret Laboratory"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["CN The Land of Ooo"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	["CN The Park"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	--Nemesis
	["CN Aku"] = {vp=6, isBoss=true, cost=12},
	["CN Iacedrom & Ygbir"] = {vp=5, isBoss=true, cost=9},
	["CN Ice King"] = {vp=4, isBoss=true, isStartBoss=true, cost=8},
	["CN Jasper"] = {vp=5, isBoss=true, cost=10},
	["CN Joshua"] = {vp=5, isBoss=true, cost=9},
	["CN Katz"] = {vp=5, isBoss=true, cost=10},
	["CN King Ramses"] = {vp=6, isBoss=true, cost=11},
	["CN King Raymond"] = {vp=5, isBoss=true, cost=10},
	["CN Mandark Astronomanov"] = {vp=6, isBoss=true, cost=11},
	["CN Tina Rex"] = {vp=6, isBoss=true, cost=12},
	--Oversized Character Cards
	["CN Clarence (Character)"] = {vp=0, isCharacter=true,},
	["CN Courage (Character)"] = {vp=0, isCharacter=true,},
	["CN Dee Dee (Character)"] = {vp=0, isCharacter=true,},
	["CN Dexter (Character)"] = {vp=0, isCharacter=true,},
	["CN Finn & Jake"] = {vp=0, isCharacter=true,},
	["CN Jack (Character)"] = {vp=0, isCharacter=true,},
	["CN Johnny Bravo (Character)"] = {vp=0, isCharacter=true,},
	["CN Mordecai & Rigby"] = {vp=0, isCharacter=true,},
	["CN Steven Universe (Character)"] = {vp=0, isCharacter=true,},
	["CN The Wattersons"] = {vp=0, isCharacter=true,},
	--7)2) Cartoon Network Crossover Crisis - Animation Annihilation
	--Others
	["AA Inside Joke"] = {vp=0, cost=2},
	["AA Pratfall"] = {vp=0, isStarter=true, cost=0},
	["AA Punchies"] = {vp=0, isStarter=true, cost=0, id=8867},
	--Events
	["AA Award Show"] = {vp=0,},
	["AA Crossover Special"] = {vp=0,},
	["AA Extra Ingredient"] = {vp=0,},
	["AA Fan Fiction"] = {vp=0,},
	["AA Ham It Up"] = {vp=0,},
	["AA List Off"] = {vp=0,},
	["AA Share the Wealth"] = {vp=0,},
	["AA Staredown"] = {vp=0,},
	--Weakness
	["AA Afraid of the Dark"] = {vp=0, isWeakness=true, cost=0},
	["AA Burning Anger"] = {vp=0, isWeakness=true, cost=0},
	["AA Clumsy"] = {vp=0, isWeakness=true, cost=0},
	["AA Cooties"] = {vp=0, isWeakness=true, cost=0},
	["AA Flustered"] = {vp=0, isWeakness=true, cost=0},
	["AA Greedy"] = {vp=0, isWeakness=true, cost=0},
	["AA Grounded"] = {vp=0, isWeakness=true, cost=0},
	["AA Gullible"] = {vp=0, isWeakness=true, cost=0},
	["AA Left Out"] = {vp=0, isWeakness=true, cost=0},
	["AA Lonely"] = {vp=0, isWeakness=true, cost=0},
	["AA Panicked Mob"] = {vp=0, isWeakness=true, cost=0},
	["AA The Ugliest Weenie"] = {vp=0, isWeakness=true, cost=0},
	--Heroes
	["AA Belly Bag"] = {vp=1, isHero=true, cost=2},
	["AA Billy"] = {vp=1, isHero=true, isDefense=true, cost=2},
	["AA Blossom"] = {vp=1, isHero=true, cost=4},
	["AA Bubbles"] = {vp=1, isHero=true, isDefense=true, cost=4},
	["AA Buttercup"] = {vp=1, isHero=true, cost=4},
	["AA Cake"] = {vp=2, isHero=true, cost=6},
	["AA Chicken"] = {vp=1, isHero=true, cost=3},
	["AA Cow"] = {vp=1, isHero=true, cost=3},
	["AA Double D"] = {vp=1, isHero=true, isAttack=true, cost=4},
	["AA Ed"] = {vp=1, isHero=true, isAttack=true, cost=3},
	["AA Eddy"] = {vp=1, isHero=true, isAttack=true, cost=5},
	["AA Fionna"] = {vp=2, isHero=true, cost=6},
	["AA Fred Fredburger"] = {vp=1, isHero=true, cost=4},
	["AA Giant Realistic Flying Tiger"] = {vp=1, isHero=true, cost=5},
	["AA Grim"] = {vp=1, isHero=true, cost=5},
	["AA Irwin"] = {vp=0, isHero=true, cost=2},
	["AA Johnny"] = {vp=1, isHero=true, isDefense=true, cost=1},
	["AA Lord Monochromicorn"] = {vp=1, isHero=true, cost=3},
	["AA Lumpy Space Prince"] = {vp=1, isHero=true, cost=3},
	["AA Mandy"] = {vp=1, isHero=true, cost=4},
	["AA Mr. Gus"] = {vp=1, isHero=true, isDefense=true, cost=5},
	["AA Pizza Steve"] = {vp=1, isHero=true, cost=3},
	["AA Plank"] = {vp=1, isHero=true, cost=3},
	["AA Prince Gumball"] = {vp=1, isHero=true, cost=2},
	["AA Professor Utonium"] = {vp=1, isHero=true, isDefense=true, cost=3},
	["AA Uncle Grandpa"] = {vp=2, isHero=true, cost=7},
	--Villains
	["AA Black Sheep"] = {vp=1, isVillain=true, cost=3},
	["AA Eris"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["AA Funny Face Head"] = {vp=1, isVillain=true, cost=2},
	["AA Fuzzy Lumpkins"] = {vp=1, isVillain=true, isAttack=true, cost=3},
	["AA General Skarr"] = {vp=1, isVillain=true, cost=3},
	["AA Him"] = {vp=2, isVillain=true, cost=6},
	["AA Hoss Delgado"] = {vp=2, isVillain=true, cost=5},
	["AA Jimmy"] = {vp=1, isVillain=true, cost=2},
	["AA Kevin"] = {vp=1, isVillain=true, isDefense=true, cost=4},
	["AA Marshall Lee"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["AA Math Homework Man"] = {vp=2, isVillain=true, cost=7},
	["AA Nacho Cheese"] = {vp=1, isVillain=true, cost=3},
	["AA Princess Morbucks"] = {vp=1, isVillain=true, cost=2},
	["AA Sarah"] = {vp=1, isVillain=true, isDefense=true, cost=3},
	["AA Sow"] = {vp=1, isVillain=true, isAttack=true, cost=3},
	["AA Teacher"] = {vp=1, isVillain=true, cost=5},
	["AA The Gangreen Gang"] = {vp=1, isVillain=true, cost=4},
	--Super Powers
	["AA ¡Supercow Al Rescate!"] = {vp=1, isSuperPower=true, isDefense=true, cost=3},
	["AA Body Doubles"] = {vp=1, isSuperPower=true, cost=5},
	["AA Danger Sense"] = {vp=1, isSuperPower=true, isDefense=true, cost=2},
	["AA Evil Laugh"] = {vp=1, isSuperPower=true, cost=4},
	["AA Good Morning!"] = {vp=1, isSuperPower=true, cost=4},
	["AA Ice Block"] = {vp=1, isSuperPower=true, isAttack=true, cost=4},
	["AA Light Construct"] = {vp=1, isSuperPower=true, isAttack=true, cost=2},
	["AA Scam Artist"] = {vp=1, isSuperPower=true, cost=3},
	["AA Spinoff"] = {vp=1, isSuperPower=true, cost=4},
	["AA Who's Got the Power?"] = {vp=1, isSuperPower=true, cost=7},
	--Equipment
	["AA Canadian Squirt Gun"] = {vp=1, isEquipment=true, cost=2},
	["AA Chemical X"] = {vp=1, isEquipment=true, cost=3},
	["AA Crystal Sword"] = {vp=1, isEquipment=true, cost=5},
	["AA Flapjack Sword"] = {vp=1, isEquipment=true, cost=3},
	["AA Grim's Trunk"] = {vp=1, isEquipment=true, cost=4},
	["AA Jawbreaker"] = {vp=2, isEquipment=true, cost=6},
	["AA Laser Hammer"] = {vp=1, isEquipment=true, cost=5},
	["AA Powerpuff Hotline"] = {vp=1, isEquipment=true, cost=4},
	["AA Pork Butt Catapult"] = {vp=1, isEquipment=true, isAttack=true, cost=2},
	["AA The Reaper's Scythe"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
	["AA Wish Star Sword"] = {vp=2, isEquipment=true, cost=7},
	--Locations
	["AA Cow and Chicken's House"] = {vp=1, isLocation=true, isOngoing=true, cost=6},
	["AA Edtropolis"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["AA Endsville"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["AA Marshmallowy Mweadows"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["AA The UG-RV"] = {vp=1, isLocation=true, isOngoing=true, cost=6},
	["AA Townsville"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	--Nemesis
	["AA Aunt Grandma"] = {vp=5, isBoss=true, cost=9},
	["AA Ice Queen"] = {vp=5, isBoss=true, cost=10},
	["AA Kanker Sisters"] = {vp=4, isBoss=true, isStartBoss=true, isAttack=true, cost=8},
	["AA Mojo Jojo"] = {vp=5, isBoss=true, cost=10},
	["AA Nergal"] = {vp=6, isBoss=true, cost=12},
	["AA The Red Guy"] = {vp=6, isBoss=true, cost=11},
	--Oversized Character Cards
	["AA Billy & Mandy"] = {vp=0, isCharacter=true,},
	["AA Cow and Chicken"] = {vp=0, isCharacter=true,},
	["AA Ed, Edd n Eddy"] = {vp=0, isCharacter=true,},
	["AA Fionna & Cake"] = {vp=0, isCharacter=true,},
	["AA Professor Utonium (Character)"] = {vp=0, isCharacter=true,},
	["AA The Powerpuff Girls"] = {vp=0, isCharacter=true,},
	["AA Uncle Grandpa (Character)"] = {vp=0, isCharacter=true,},
	--7)3) Teen Titans Go!
	--Other
	["TTG Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["TTG Snack Time"] = {vp=0, isStarter=true, cost=0},
	["TTG Titans Go!"] = {vp=0, isStarter=true, isDefense=true, cost=3},
	--Weakness
	["TTG Busy"] = {vp=0, isWeakness=true, cost=0},
	["TTG Flattened"] = {vp=0, isWeakness=true, cost=0},
	["TTG Hungry"] = {vp=0, isWeakness=true, cost=0},
	["TTG Kittens"] = {vp=0, isWeakness=true, cost=0},
	["TTG Lazy"] = {vp=0, isWeakness=true, cost=0},
	["TTG Mutation"] = {vp=0, isWeakness=true, cost=0},
	["TTG Overeating"] = {vp=0, isWeakness=true, cost=0},
	["TTG Silence"] = {vp=0, isWeakness=true, cost=0},
	["TTG Stranded on an Island"] = {vp=0, isWeakness=true, cost=0},
	["TTG The Naughty List"] = {vp=0, isWeakness=true, cost=0},
	--Events
	["TTG April Fool's Day"] = {vp=0,},
	["TTG Christmas"] = {vp=0,},
	["TTG Cooties"] = {vp=0,},
	["TTG Double-Crossed"] = {vp=0,},
	["TTG Laundry Day"] = {vp=0,},
	["TTG Turned into Babies"] = {vp=0,},
	--Heroes
	["TTG Aqualad"] = {vp=1, isHero=true, cost=5, id=9167},
	["TTG Batman"] = {vp=1, isHero=true, cost=5, id=7219},
	["TTG Beat Box"] = {vp=1, isHero=true, cost=2, id=7258},
	["TTG Bumblebee"] = {vp=1, isHero=true, cost=4, id=4070},
	["TTG Jayna"] = {vp=1, isHero=true, cost=3, id=6261},
	["TTG Kaldur'Ahm"] = {vp=1, isHero=true, isDefense=true, cost=4, id=6917},
	["TTG Kid Flash"] = {vp=1, isHero=true, cost=3, id=5405},
	["TTG Más Y Menos"] = {vp=1, isHero=true, cost=2, id=8218},
	["TTG Miss Martian"] = {vp=2, isHero=true, isDefense=true, cost=5, id=6006},
	["TTG Silkie"] = {vp=1, isHero=true, cost=1, id=6005},
	["TTG Speedy"] = {vp=1, isHero=true, cost=4, id=5210},
	["TTG Sticky Joe"] = {vp=1, isHero=true, cost=2, id=1071},
	["TTG Superboy"] = {vp=1, isHero=true, isDefense=true, cost=4, id=7161},
	["TTG Wally T"] = {vp=1, isHero=true, cost=1, id=9661},
	["TTG Zan"] = {vp=1, isHero=true, cost=3, id=4753},
	--Villains
	["TTG Blackfire"] = {vp=2, isVillain=true, isAttack=true, cost=5, id=6495},
	["TTG Cinderblock"] = {vp=1, isVillain=true, cost=2, id=6037},
	["TTG Dr. Light"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=6949},
	["TTG Killer Moth"] = {vp=1, isVillain=true, isAttack=true, cost=2, id=3370},
	["TTG Kitten"] = {vp=1, isVillain=true, isDefense=true, cost=1, id=6924},
	["TTG Mad Mod"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=5689},
	["TTG Monsieur Mallah"] = {vp=1, isVillain=true, cost=4, id=4370},
	["TTG Mother Mae-Eye"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=7473},
	["TTG Mumbo Jumbo"] = {vp=1, isVillain=true, cost=3, id=7054},
	["TTG Perry"] = {vp=1, isVillain=true, cost=1, id=1088},
	["TTG Plasmus"] = {vp=1, isVillain=true, isAttack=true, cost=3, id=6067},
	["TTG Ravager"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=1987},
	["TTG Slade"] = {vp=1, isVillain=true, isAttack=true, cost=5, id=1414},
	["TTG Terra"] = {vp=1, isVillain=true, cost=4, id=3418},
	["TTG Twin Destroyers of Azarath"] = {vp=1, isVillain=true, cost=2, id=8228},
	--Super Powers
	["TTG Beaver Form"] = {vp=1, isSuperPower=true, cost=2, id=5060},
	["TTG Cheetah Form"] = {vp=1, isSuperPower=true, cost=5, id=7275},
	["TTG Dark Kinesis"] = {vp=1, isSuperPower=true, cost=2, id=5361},
	["TTG Dark Magic"] = {vp=1, isSuperPower=true, cost=3, id=6153},
	["TTG Dark Portal"] = {vp=1, isSuperPower=true, cost=1, id=4771},
	["TTG Dark Shadow"] = {vp=1, isSuperPower=true, cost=2, id=2049},
	["TTG Elephant Form"] = {vp=1, isSuperPower=true, cost=4, id=5699},
	["TTG Eye Beams"] = {vp=1, isSuperPower=true, cost=4, id=1162},
	["TTG Flight"] = {vp=1, isSuperPower=true, cost=4, id=5024},
	["TTG Gorilla Form"] = {vp=1, isSuperPower=true, cost=3, id=6488},
	["TTG Hummingbird Form"] = {vp=1, isSuperPower=true, cost=1, id=4290},
	["TTG Magic Clone"] = {vp=1, isSuperPower=true, cost=4, id=7299},
	["TTG Snake Form"] = {vp=1, isSuperPower=true, isAttack=true, cost=3, id=6242},
	["TTG Starbolts"] = {vp=1, isSuperPower=true, cost=5, id=1086},
	["TTG Super Strength"] = {vp=2, isSuperPower=true, cost=5, id=3857},
	--Equipment
	["TTG Birdarangs"] = {vp=1, isEquipment=true, cost=3, id=8155},
	["TTG Blaster"] = {vp=1, isEquipment=true, cost=2, id=4355},
	["TTG Bo Staff"] = {vp=1, isEquipment=true, cost=5, id=2047},
	["TTG Cape"] = {vp=1, isEquipment=true, cost=1, id=6048},
	["TTG Crystal Prism"] = {vp=1, isEquipment=true, cost=5, id=4002},
	["TTG Dodgeball Launcher"] = {vp=1, isEquipment=true, cost=3, id=9227},
	["TTG Extendable Head"] = {vp=1, isEquipment=true, cost=1, id=6753},
	["TTG Grapple Gun"] = {vp=1, isEquipment=true, isDefense=true, cost=2, id=7010},
	["TTG Jetpack"] = {vp=1, isEquipment=true, cost=4, id=7672},
	["TTG Meatball Launcher"] = {vp=1, isEquipment=true, cost=4, id=6512},
	["TTG Missile Man"] = {vp=1, isEquipment=true, cost=2, id=1253},
	["TTG Spellbook"] = {vp=1, isEquipment=true, cost=4, id=9391},
	["TTG T-Car"] = {vp=1, isEquipment=true, cost=4, id=8250},
	["TTG Titan Robot"] = {vp=1, isEquipment=true, cost=5, id=6526},
	["TTG Titans Communicator"] = {vp=1, isEquipment=true, cost=3, id=4492},
	--Locations
	["TTG Hive Tower"] = {vp=1, isLocation=true, isOngoing=true, cost=3, id=1690},
	["TTG Jump City"] = {vp=1, isLocation=true, isOngoing=true, cost=3, id=6643},
		["TU90 New York City"] = {vp=1, isLocation=true, isOngoing=true, cost=3, id=6643},
		["TU90 Cidade de Nova York"] = {vp=1, isLocation=true, isOngoing=true, cost=3, id=6643},
	["TTG Titans Tower"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=8202},
	["TTG Trash Hole"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4247},
        ["TU90 Yancy Street"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4247},
        ["TU90 Rua Yancy"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4247},
	--Nemesis
	["TTG Billy Numerous"] = {vp=5, isBoss=true, cost=10, id=5844},
	["TTG Brother Blood"] = {vp=5, isBoss=true, cost=10, id=4483},
	["TTG Control Freak"] = {vp=4, isBoss=true, isStartBoss=true, cost=8, id=4276},
	["TTG Gizmo"] = {vp=5, isBoss=true, cost=10, id=6275},
	["TTG Jinx"] = {vp=5, isBoss=true, cost=10, id=8497},
	["TTG Mammoth"] = {vp=5, isBoss=true, cost=10, id=3988},
	["TTG See-More"] = {vp=5, isBoss=true, cost=10, id=9584},
	["TTG The Brain"] = {vp=5, isBoss=true, cost=10, id=7234},
	["TTG Trigon"] = {vp=5, isBoss=true, cost=10, id=9415},
	--Oversized Character Cards
	["TTG Beast Boy"] = {vp=0, isCharacter=true, id=4758},
	["TTG Cyborg"] = {vp=0, isCharacter=true, id=9762},
	["TTG Kid Flash (Character)"] = {vp=0, isCharacter=true, id=1487},
	["TTG Raven"] = {vp=0, isCharacter=true, id=8542},
	["TTG Robin"] = {vp=0, isCharacter=true, id=8556},
	["TTG Starfire"] = {vp=0, isCharacter=true, id=5964},
	["TTG Beast Boy (Sidekick)"] = {vp=0, isCharacter=true, id=9702},
	["TTG Cyborg (Sidekick)"] = {vp=0, isCharacter=true, id=3366},
	["TTG Kid Flash (Sidekick)"] = {vp=0, isCharacter=true, id=1637},
	["TTG Raven (Sidekick)"] = {vp=0, isCharacter=true, id=9054},
	["TTG Robin (Sidekick)"] = {vp=0, isCharacter=true, id=8698},
	["TTG Starfire (Sidekick)"] = {vp=0, isCharacter=true, id=2051},
	--7)3)A) Teen Titans Go! Expansion
	--Equipment
	["TTGX Rocket Launcher"] = {vp=1, isEquipment=true, isAttack=true, cost=5,},
	["TTGX Starfire's Diary"] = {vp=1, isEquipment=true, cost=2,},
	--Heroes
	["TTGX Sparkleface & Butterbean"] = {vp=1, isHero=true, cost=4,},
	--Super Powers
	["TTGX Octopus Form"] = {vp=1, isSuperPower=true, isDefense=true, cost=4,},
	["TTGX Tamaranian Princess"] = {vp=1, isSuperPower=true, cost=2,},
	--Villains
	["TTGX Sandwich Guardian"] = {vp=1, isVillain=true, cost=5,},
	--Nemesis
	["TTGX Cavity Demon"] = {vp=5, isBoss=true, cost=10,},
	["TTGX Giant Robotic Alien"] = {vp=5, isBoss=true, cost=10,},
	--7)4) Rick and Morty 1- Close Rick-Counters of the Rick Kind
	--Other
	["RM1 Beth"] = {vp=0, isStarter=true, cost=0},
	["RM1 Genius Waves"] = {vp=0, isStarter=true, isGWave=true, cost=0},
	["RM1 Jerry"] = {vp=0, isStarter=true, cost=0},
	["RM1 Summer"] = {vp=0, isStarter=true, cost=0},
	["RM1 Morty Waves"] = {vp=-1, isMWave=true, cost=0}, --1 VP if paired with a Genius Wave
	--Ricks
	["RM1 Alien Rick"] = {vp=1, isRick=true, cost=4},
	["RM1 Aqua Rick"] = {vp=1, isRick=true, cost=3},
	["RM1 Color Swap Rick"] = {vp=2, isRick=true, cost=6},
	["RM1 Cowboy Rick"] = {vp=1, isRick=true, isDefense=true, cost=5},
	["RM1 Cronenberg Rick"] = {vp=2, isRick=true, cost=6},
	["RM1 Cyclops Rick"] = {vp=1, isRick=true, cost=3},
	["RM1 Doofus Rick"] = {vp=1, isRick=true, cost=5},
	["RM1 Guard Rick"] = {vp=1, isRick=true, isDefense=true, cost=2},
	["RM1 Rick Sanchez C-137"] = {vp=0, isRick=true, cost=7}, --2 VP for Each Morty Wave
	["RM1 Robot Rick"] = {vp=1, isRick=true, cost=4},
	["RM1 Solicitor Rick"] = {vp=1, isRick=true, cost=2},
	["RM1 Super Weird Rick"] = {vp=1, isRick=true, cost=3},
	["RM1 The Scientist Formerly Known as Rick"] = {vp=1, isRick=true, cost=4},
	--Mortys
	["RM1 Alien Morty"] = {vp=1, isMorty=true, cost=2},
	["RM1 Antenna Morty"] = {vp=1, isMorty=true, cost=5},
	["RM1 Aqua Morty"] = {vp=1, isMorty=true, isAttack=true, cost=4},
	["RM1 Captive Morty"] = {vp=1, isMorty=true, cost=3},
	["RM1 Cowboy Morty"] = {vp=1, isMorty=true, isDefense=true, cost=4},
	["RM1 Cronenberg Morty"] = {vp=1, isMorty=true, cost=4},
	["RM1 Cultist Morty"] = {vp=1, isMorty=true, cost=3},
	["RM1 Cyclops Morty"] = {vp=1, isMorty=true, cost=3},
	["RM1 Evil Morty"] = {vp=2, isMorty=true, cost=6},
	["RM1 Hammerhead Morty"] = {vp=2, isMorty=true, cost=6},
	["RM1 Mask Morty"] = {vp=1, isMorty=true, cost=5},
	["RM1 The One True Morty"] = {vp=2, isMorty=true, cost=7},
	["RM1 Tortured Morty"] = {vp=-1, isMorty=true, isDefense=true, cost=2},
	--Specials
	["RM1 Alien Wasp Trap"] = {vp=2, isSpecial=true, isAttack=true, cost=7},
	["RM1 Fire Trap"] = {vp=2, isSpecial=true, isAttack=true, cost=6},
	["RM1 Flying Saucer-Shaped Pancakes"] = {vp=1, isSpecial=true, cost=4},
	["RM1 Ovenless Brownies"] = {vp=1, isSpecial=true, cost=6},
	["RM1 Phone Sticks"] = {vp=1, isSpecial=true, cost=3},
	["RM1 Poop and Basketballs Trap"] = {vp=1, isSpecial=true, isAttack=true, cost=2},
	["RM1 Portal Gun Reader"] = {vp=1, isSpecial=true, cost=3},
	["RM1 Red X"] = {vp=1, isSpecial=true, isDefense=true, isOngoing=true, cost=3},
	["RM1 Rick Tracer"] = {vp=1, isSpecial=true, cost=5},
	["RM1 Ricks Don't Care About Mortys"] = {vp=1, isSpecial=true, cost=4},
	["RM1 Slow Clap"] = {vp=1, isSpecial=true, cost=2},
	["RM1 Spider Guard"] = {vp=2, isSpecial=true, cost=5},
	["RM1 Tentacle Trap"] = {vp=1, isSpecial=true, isAttack=true, cost=4},
	--Equipment
	["RM1 Freeze Gun"] = {vp=1, isEquipment=true, cost=4},
	["RM1 Laser Pistol"] = {vp=1, isEquipment=true, isAttack=true, cost=4},
	["RM1 Lemonade"] = {vp=1, isEquipment=true, cost=3},
	["RM1 Memory Ripper"] = {vp=1, isEquipment=true, cost=2},
	["RM1 Mind Control Device"] = {vp=1, isEquipment=true, isAttack=true, cost=5},
	["RM1 Morty Dazzlers"] = {vp=1, isEquipment=true, cost=4},
	["RM1 Morty Doll"] = {vp=2, isEquipment=true, isDefense=true, cost=6},
	["RM1 Morty Insurance"] = {vp=1, isEquipment=true, cost=2},
	["RM1 Morty Tickler"] = {vp=1, isEquipment=true, isAttack=true, isOngoing=true, cost=7},
	["RM1 Novelty Coin Collection"] = {vp=1, isEquipment=true, cost=3},
	["RM1 Portal Gun"] = {vp=0, isEquipment=true, cost=3},
	["RM1 Replacement Morty Voucher"] = {vp=1, isEquipment=true, cost=5},
	["RM1 The Good Morty Tract"] = {vp=2, isEquipment=true, cost=6},
	["RM1 Tranquilizer Gun"] = {vp=1, isEquipment=true, isDefense=true, cost=3},
	--Locations
	["RM1 Ass World"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Bird World"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Chair World"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM1 Cromulon Dimension"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Cronenberg World"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Dimension 35-C"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Dimension C-500A"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Doopidoo Dimension"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM1 Dwarf Terrace-9"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Gazorpazorp"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Greasy Grandma World"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Hamster in Butt World"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Hideout Planet"] = {vp=1, isLocation=true, isDefense=true, isOngoing=true, cost=4},
	["RM1 On a Cob Planet"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Pawn Shop Planet"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM1 Phone World"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM1 Pizza World"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM1 Planet Squanch"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Purge Planet"] = {vp=0, isLocation=true, isOngoing=true, cost=4},
	["RM1 Replacement Dimension"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM1 Reverse Height Universe"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	--Nemesis
	["RM1 Evil Rick"] = {vp=6, isRick=true, isBoss=true, cost=12},
	["RM1 Maximums Rickimus"] = {vp=5, isRick=true, isBoss=true, cost=10},
	["RM1 Quantum Rick"] = {vp=5, isRick=true, isBoss=true, cost=10},
	["RM1 Rick Prime"] = {vp=6, isRick=true, isBoss=true, cost=11},
	["RM1 Ricktiminus Sancheziminius"] = {vp=5, isRick=true, isBoss=true, cost=9},
	["RM1 Riq IV"] = {vp=4, isRick=true, isBoss=true, isStartBoss=true,  cost=8},
	["RM1 Zeta Alpha Rick"] = {vp=5, isRick=true, isBoss=true, cost=9},
	--Oversized Character Cards
	["RM1 Angry Rick"] = {vp=0, isCharacter=true,},
	["RM1 Annoyed Rick"] = {vp=0, isCharacter=true,},
	["RM1 Calm Rick"] = {vp=0, isCharacter=true,},
	["RM1 Crazy Rick"] = {vp=0, isCharacter=true,},
	["RM1 Drunk Rick"] = {vp=0, isCharacter=true,},
	["RM1 Happy Rick"] = {vp=0, isCharacter=true,},
	["RM1 Promo Rick"] = {vp=0, isCharacter=true,},
	--7)5) Rick and Morty 2- The Rickshank Rickdemption
	--Other
	["RM2 Beth"] = {vp=0, isStarter=true, cost=0},
	["RM2 Genius Waves"] = {vp=0, isStarter=true, isGWave=true, cost=0},
	["RM2 Jerry"] = {vp=0, isStarter=true, cost=0},
	["RM2 Summer"] = {vp=0, isStarter=true, cost=0},
	["RM2 Morty Waves"] = {vp=-1, isMWave=true, cost=0}, --1 VP if paired with a Genius Wave
	--Ricks
	["RM2 Aqua Rick"] = {vp=1, isRick=true, cost=4},
	["RM2 Black Rick"] = {vp=1, isRick=true, cost=3},
	["RM2 Commander Rick"] = {vp=1, isRick=true, cost=6},
	["RM2 Future Rick"] = {vp=1, isRick=true, cost=3},
	["RM2 Lizard Rick"] = {vp=1, isRick=true, isAttack=true, cost=5},
	["RM2 Rick C-137"] = {vp=1, isRick=true, cost=7}, -- 1 VP for each Genius Wave
	["RM2 Security Specialist Rick"] = {vp=1, isRick=true, isDefense=true, isOngoing=true, cost=2},
	["RM2 Young Rick"] = {vp=1, isRick=true, cost=4},
	--Mortys
	["RM2 Aqua Morty"] = {vp=1, isMorty=true, cost=3},
	["RM2 Big-Head Morty"] = {vp=1, isMorty=true, cost=4},
	["RM2 Bugged-Out Morty"] = {vp=1, isMorty=true, isDefense=true, cost=3},
	["RM2 Eye-Poppin' Morty"] = {vp=1, isMorty=true, cost=2},
	["RM2 Hammerhead Morty"] = {vp=1, isMorty=true, isAttack=true, isDefense=true, cost=5},
	["RM2 Lawyer Morty"] = {vp=1, isMorty=true, isDefense=true, cost=4},
	["RM2 Morty C-137"] = {vp=2, isMorty=true, isAttack=true, cost=7},
	["RM2 Scientist Morty"] = {vp=2, isMorty=true, cost=6},
	--Specials
	["RM2 Currency Manipulation"] = {vp=0, isSpecial=true, isAttack=true, cost=7}, -- 1 VP for each Access Token you own
	["RM2 Daddy's Little Girl"] = {vp=2, isSpecial=true, isDefense=true, cost=4},
	["RM2 Diane Sanchez"] = {vp=1, isSpecial=true, cost=5},
	["RM2 Fold Yourself"] = {vp=1, isSpecial=true, cost=3},
	["RM2 Pill Brûlée"] = {vp=1, isSpecial=true, cost=2},
	["RM2 Szechuan Sauce"] = {vp=1, isSpecial=true, cost=4}, -- 1 VP for each Location you own
	["RM2 Terminate"] = {vp=1, isSpecial=true, cost=3},
	["RM2 Totally Fabricated Origin Story"] = {vp=2, isSpecial=true, cost=6},
	--Equipment
	["RM2 Brainalyzer 9000"] = {vp=1, isEquipment=true, cost=4},
	["RM2 Butt-in-a-Cup"] = {vp=1, isEquipment=true, cost=3},
	["RM2 Conroy"] = {vp=1, isEquipment=true, cost=3},
	["RM2 Dead Flies"] = {vp=1, isEquipment=true, cost=4},
	["RM2 Fake Gun"] = {vp=-2, isEquipment=true, isAttack=true, cost=2},
	["RM2 Freeze Gun"] = {vp=1, isEquipment=true, isAttack=true, cost=5},
	["RM2 Jury-Rigged Portal Gun"] = {vp=1, isEquipment=true, cost=6},
	["RM2 Portal Bomb"] = {vp=1, isEquipment=true, isAttack=true, cost=7},
	["RM2 Portal Gun"] = {vp=0, isEquipment=true, cost=3},
	--Gromflamites
	["RM2 Communications Gromflamite"] = {vp=1, isGromflamite=true, cost=4},
	["RM2 Greedy Gromflamite"] = {vp=2, isGromflamite=true, cost=6},
	["RM2 Gromflamite Employee of the Month"] = {vp=1, isGromflamite=true, isDefense=true, cost=3},
	["RM2 Gromflamite General"] = {vp=2, isGromflamite=true, isAttack=true, cost=7},
	["RM2 Gromflamite Officer"] = {vp=1, isGromflamite=true, cost=5},
	["RM2 Gromflomite Technician"] = {vp=1, isGromflamite=true, cost=2},
	["RM2 Honorable Gromflamite"] = {vp=1, isGromflamite=true, cost=4},
	["RM2 Mission Control Gromflamite"] = {vp=1, isGromflamite=true, isAttack=true, cost=3},
	--Council
	["RM2 Assemble"] = {vp=0, isCouncil=true, cost=2}, -- 3 VP if have most Council Cards ** Not Done
	["RM2 Embezzle"] = {vp=2, isCouncil=true, cost=6},
	["RM2 Gentrify"] = {vp=2, isCouncil=true, cost=7},
	["RM2 Kickback"] = {vp=1, isCouncil=true, cost=4},
	["RM2 Persecute"] = {vp=1, isCouncil=true, cost=3},
	["RM2 Recycle"] = {vp=1, isCouncil=true, cost=4},
	["RM2 Rezone"] = {vp=1, isCouncil=true, cost=3},
	["RM2 Taxation"] = {vp=1, isCouncil=true, cost=5},
	--Locations
	["RM2 Assworld 2.0"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM2 Citadel Militia HQ"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM2 Cronenberg World 2.0"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM2 Family Restaurant"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM2 Jerry's Office"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM2 Mission Control"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM2 Presidential Palace"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM2 Space Prison"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM2 The Citadel of Ricks"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM2 The Dinner Table"] = {vp=1, isLocation=true, isDefense=true, isOngoing=true, cost=4},
	["RM2 The Drive-Thru"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM2 The Garage"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["RM2 The Grave"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM2 The Neighborhood"] = {vp=2, isLocation=true, isOngoing=true, cost=4},
	["RM2 The Underground"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	--Nemesis
	["RM2 Cornrow Rick"] = {vp=6, isRick=true, isBoss=true, cost=11},
	["RM2 Cornvelious Daniel"] = {vp=4, isGromflamite=true, isBoss=true, isStartBoss=true, cost=8},
	["RM2 Earring Rick"] = {vp=5, isRick=true, isBoss=true, cost=10},
	["RM2 Eye Patch Rick"] = {vp=5, isRick=true, isBoss=true, cost=10},
	["RM2 Galactic Federation President"] = {vp=7, isGromflamite=true, isBoss=true, cost=14},
	["RM2 Headband Rick"] = {vp=5, isRick=true, isBoss=true, cost=9},
	["RM2 Rick D-99"] = {vp=6, isRick=true, isBoss=true, cost=11},
	--Oversized Character Cards
	["RM2 Bluffing Rick"] = {vp=0, isCharacter=true,},
	["RM2 Defiant Summer"] = {vp=0, isCharacter=true,},
	["RM2 Heroic Summer"] = {vp=0, isCharacter=true,},
	["RM2 Moron Morty"] = {vp=0, isCharacter=true,},
	["RM2 Promotion Jerry"] = {vp=0, isCharacter=true,},
	["RM2 Rational Morty"] = {vp=0, isCharacter=true,},
	["RM2 Transcendent Rick"] = {vp=0, isCharacter=true,},
	--8)1) Promos
	--Heroes
	["VP 2016 CZE Volunteer"] = {vp=1, isHero=true, cost=4, id=0},
	["VP Embryonicus - Archmagi of the Future"] = {vp=1, isHero=true, cost=5, id=0},
	["CO6 Gypsy"] = {vp=1, isHero=true, isOngoing=true, cost=2, id=1357},
	["CO7 Forager"] = {vp=1, isHero=true, cost=3, id=6931},
	["R3 Avery Ho"] = {vp=1, isHero=true, cost=4,},
	--Villains
	["VP Dungstar The Poo Pope"] = {vp=1, isVillain=true, cost=3},
	["CO7 Black Racer"] = {vp=2, isVillain=true, cost=7},
	--Super Powers
	["VP Extraordinary Stamina"] = {vp=1, isSuperPower=true, isDefense=true, cost=4},
	["JLD Incorporeal"] = {vp=2, isSuperPower=true, isDefense=true, cost=6},
	--Equipment
	["VP Gamer's Lucky Dice"] = {vp=1, isEquipment=true, cost=5},
	["JLD Vestments of Fate"] = {vp=2, isEquipment=true, cost=7},
	--Locations
	["VP Convention Center"] = {vp=0, isLocation=true, isOngoing=true, cost=5, id=0},
	["C1 Gotham City Docks"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4657},
	--Bosses
	["DC Felix Faust"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=7975},
	["C2 Red Lantern Spectre"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=6412},
	["CO5 Reverse-Flash"] = {vp=6, isVillain=true, isBoss=true, cost=12,id=2485},
	["GC Zatanna Zatara"] = {vp=6, isHero=true, isBoss=true, cost=12,},
	["NPP Hawkgirl"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["NPP King Shark"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["NPP Raven"] = {vp=4, isHero=true, isBoss=true, isStartBoss=true, cost=8,},
	["NPP Red Hood"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["NPP Starfire"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["JLDX I Vampire"] = {vp=7, isHero=true, isBoss=true, cost=11,},
	["GC Birds of Prey"] = {vp=5, isHero=true, isBoss=true, isDefense=true, cost=10,},
	["INJ Injustice General Zod"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=11,},
	--Other
	["EA1 Hocus Porkus"] = {vp=2, isFamiliar=true, isAttack=true, cost=7},
	["GC The Juice"] = {vp=2, isFamiliar=true, isAttack=true, cost=7},
	["ESW5 The Last Laugh"] = {vp=2, isFamiliar=true, isAttack=true, cost=7},
	--Oversized Character Cards
	["C2 White Lanern Sinestro"] = {vp=0, isCharacter=true, id=3482},
	["CPP Green Lantern (Jessica Cruz)"] = {vp=0, isCharacter=true,},
	["CPP Lobo"] = {vp=0, isCharacter=true,},
	["CPP Solomon Grundy"] = {vp=0, isCharacter=true,},
	["CPP Supergirl"] = {vp=0, isCharacter=true,},
	["EA1 Abraca-Labrador & Hocus Porkus"] = {vp=0, isCharacter=true,},
	["GC Black Lightning"] = {vp=0, isCharacter=true, id=3063},
	["GC Studd Spellslammer and The Juice!"] = {vp=0, isCharacter=true,},
	["GC Vixen"] = {vp=0, isCharacter=true, id=4349},
	["KS Kickstarter Backer"] = {vp=0, isCharacter=true,},
	["VP Cryptozoic 2015 Volunteer"] = {vp=0, isCharacter=true, id=0},
	["JLD Doctor Fate Lord of Order"] = {vp=0, isCharacter=true,},
	["GC Supergirl"] = {vp=0, isCharacter=true,},
	["CO1 Cyclone"] = {vp=0, isCharacter=true,},
	["ARK Tim Drake"] = {vp=0, isCharacter=true,},
	["GC General Zod"] = {vp=0, isCharacter=true,},
	["GC Brainiac"] = {vp=0, isCharacter=true,},
	["GC Krypto"] = {vp=0, isCharacter=true,},
	["Goosey"] = {vp=0, isCharacter=true,},
	--8)2) Multiverse
	--Heroes
	["MV Alan Scott"] = {vp=3, isHero=true, cost=8, id=9315},
	["MV Batman (Jean-Paul Valley)"] = {vp=2, isHero=true, cost=6,},
	["MV Batman (Thomas Wayne)"] = {vp=1, isHero=true, cost=5, id=1648},
	["MV Blue Beetle"] = {vp=1, isHero=true, cost=3, id=1212},
	["MV Dick Grayson"] = {vp=1, isHero=true, cost=4, id=5036},
	["MV Jay Garrick"] = {vp=2, isHero=true, isDefense=true, cost=6, id=7907},
	["MV Red Son Superman"] = {vp=2, isHero=true, cost=7, id=5658},
	["MV The Question"] = {vp=2, isHero=true, cost=5,},
	["MV Warlord"] = {vp=1, isHero=true, isDefense=true, cost=4, id=7011},
	--Villains
	["MV Brainiac Drones"] = {vp=1, isVillain=true, cost=4, id=7137},
	["MV Catman"] = {vp=2, isVillain=true, cost=6,},
	["MV Count Vertigo"] = {vp=1, isVillain=true, cost=4,},
	["MV Crime Syndicate"] = {vp=2, isVillain=true, cost=7, id=9685},
	["MV Flashpoint Aquaman"] = {vp=1, isVillain=true, cost=5, id=4475},
	["MV Flashpoint Wonder Woman"] = {vp=2, isVillain=true, cost=6, id=5688},
	["MV Parallax"] = {vp=3, isVillain=true, cost=8, id=4726},
	["MV The Extremists"] = {vp=1, isVillain=true, cost=3, id=4593},
	["MV Weaponers of Qward"] = {vp=1, isVillain=true, cost=4, id=1345},
	--Locations
	["MV Bizarro World"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=4900},
	["MV Follywood, Califurnia"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=9114},
	["MV Moscow"] = {vp=1, isLocation=true, isOngoing=true, cost=5, id=4537},
	["MV Skartaris"] = {vp=1, isLocation=true, isDefense=true, isOngoing=true, cost=3, id=7723},
	["MV Vanishing Point"] = {vp=1, isLocation=true, isOngoing=true, cost=4, id=7899},
	--Super-Villains
	["MV Brainiac"] = {vp=5, isVillain=true, isBoss=true, isOngoing=true, isStartBoss=true, cost=10, id=6032},
	["MV Deimos"] = {vp=10, isVillain=true, isBoss=true, cost=23, id=9737},
	["MV Telos"] = {vp=5, isVillain=true, isBoss=true, cost=15, id=9202},
	--Events
	["MV Blackest Night"] = {vp=0,},
	["MV Bombshells"] = {vp=0,},
	["MV Brightest Day"] = {vp=0,},
	["MV Convergence"] = {vp=0,},
	["MV Crisis on Infinite Earths"] = {vp=0,},
	["MV Final Crisis"] = {vp=0,},
	["MV Flashpoint"] = {vp=0,},
	["MV Futures End"] = {vp=0,},
	["MV Infinite Crisis"] = {vp=0,},
	["MV Kingdom Come"] = {vp=0,},
	["MV Rebirth"] = {vp=0,},
	["MV The New 52"] = {vp=0,},
	["MV Zero Hour"] = {vp=0,},
	--Randomizers
	["MV DC"] = {vp=0,},
	["MV HU"] = {vp=0,},
	["MV FE"] = {vp=0,},
	["MV TT"] = {vp=0,},
	["MV DNM"] = {vp=0,},
	["MV INJ"] = {vp=0,},
	["MV C1"] = {vp=0,},
	["MV C2"] = {vp=0,},
	["MV C3"] = {vp=0,},
	["MV C4"] = {vp=0,},
	["MV R1"] = {vp=0,},
	["MV R2"] = {vp=0,},
	["MV R3"] = {vp=0,},
	["MV R4"] = {vp=0,},
	["MV RC"] = {vp=0,},
	["MV CO1"] = {vp=0,},
	["MV CO2"] = {vp=0,},
	["MV CO3"] = {vp=0,},
	["MV CO4"] = {vp=0,},
	["MV CO5"] = {vp=0,},
	["MV CO6"] = {vp=0,},
	["MV CO7"] = {vp=0,},
	["MV CO8"] = {vp=0,},
	["MV CO9"] = {vp=0,},
	["MV TTG"] = {vp=0,},
	["MV RB"] = {vp=0,},
	--Multiverse
	["MV 30th Century Metropolis"] = {vp=0,},
	["MV Dark Multiverse"] = {vp=0,},
	["MV Earth-2"] = {vp=0,},
	["MV Fawcett City"] = {vp=0,},
	["MV Flashpoint Gotham City"] = {vp=0,},
	["MV Gotham City"] = {vp=0,},
	["MV Hub City"] = {vp=0,},
	["MV Injustice Metropolis"] = {vp=0,},
	["MV Metropolis"] = {vp=0,},
	--8)3) DCDB
	--Other
	["DCDB Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["DCDB Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["DCDB Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	["DCDB Kick"] = {vp=1, isSuperPower=true, cost=3, id=9883},
	["DNM Breakthrough (DCDB)"] = {vp=1, cost=3},
	["RC Enhanced Strength (DCDB)"] = {vp=1, isStarter=true, cost=3},
	["R2 Hard-Light Construct (DCDB)"] = {vp=1, cost=3, id=0},
	["R5 Men of Tomorrow (DCDB)"] = {vp=1, cost=3,},
	["R3 Super-Speed (DCDB)"] = {vp=1, cost=3,},
	["R4 Word of Power (DCDB)"] = {vp=1, isSuperPower=true, cost=3,},
	--Heroes
	["DC High-Tech Hero (DCDB)"] = {vp=1, isHero=true, cost=3, id=6872},
	["C1 Captain Atom (DCDB)"] = {vp=2, isHero=true, cost=6, id=2167},
	["FE Element Woman (DCDB)"] = {vp=1, isHero=true, cost=4, id=9249},
	["R1 Commissioner Gordon (DCDB)"] = {vp=1, isHero=true, cost=3, id=3035},
	["R1 Superman (DCDB)"] = {vp=3, isHero=true, cost=7, id=4615},
	["R2 Arisia (DCDB)"] = {vp=1, isHero=true, cost=3, id=5209},
	["R2 Boodikka (DCDB)"] = {vp=1, isHero=true, cost=4, id=4816},
	["R2 Guy Gardner (DCDB)"] = {vp=2, isHero=true, cost=6, id=7739},
	["R2 Saint Walker (DCDB)"] = {vp=1, isHero=true, cost=5, id=4764},
	["RB Krypto (DCDB)"] = {vp=2, isHero=true, isDefense=true, cost=6, id=7952},
	["RC Ares (DCDB)"] = {vp=3, isHero=true, cost=7, id=9972},
	["RC Hephaestus (DCDB)"] = {vp=1, isHero=true, cost=5, id=9490},
	["RC Orion (DCDB)"] = {vp=2, isHero=true, cost=6, id=6028},
	["TT Jericho (DCDB)"] = {vp=1, isHero=true, isAttack=true, cost=3, id=5941},
	--Villains
	["R1 Harley Quinn (DCDB)"] = {vp=1, isVillain=true, cost=3, id=4448},
	["R1 Talia Al Ghul (DCDB)"] = {vp=1, isVillain=true, cost=5, id=5622},
	["R2 Arkillo (DCDB)"] = {vp=2, isVillain=true, cost=6, id=7329},
	["R2 Manhunter Army (DCDB)"] = {vp=1, isVillain=true, cost=5, id=2109},
	["RC Cheetah (DCDB)"] = {vp=1, isVillain=true, cost=4, id=8217},
	["RC Etrigan (DCDB)"] = {vp=1, isVillain=true, cost=5, id=6693},
	["RC King Shark (DCDB)"] = {vp=1, isVillain=true, cost=2, id=7624},
	["RC Klarion (DCDB)"] = {vp=1, isVillain=true, cost=5, id=6266},
	["TT Phobia (DCDB)"] = {vp=1, isVillain=true, isAttack=true, cost=4, id=9000},
	--Super Powers
	["R1 Killing Joke (DCDB)"] = {vp=3, isSuperPower=true, cost=7, id=4856},
	["R1 Master Martial Artist (DCDB)"] = {vp=1, isSuperPower=true, cost=4, id=7212},
	["R2 Construct Shields (DCDB)"] = {vp=1, isSuperPower=true, cost=4, id=5096},
	["R2 Construct Slam (DCDB)"] = {vp=1, isSuperPower=true, cost=3, id=7044},
	["RC Pots! (DCDB)"] = {vp=1, isSuperPower=true, cost=2, id=8912},
	["RC Scientific Genius (DCDB)"] = {vp=2, isSuperPower=true, cost=7, id=4319},
	["RC Strength of the Gods (DCDB)"] = {vp=1, isSuperPower=true, cost=4, id=8968},
	["TT Geokinesis (DCDB)"] = {vp=1, isSuperPower=true, isAttack=true, cost=4, id=7492},
	["TT Shapeshift (DCDB)"] = {vp=1, isSuperPower=true, isPowerRing=true, cost=2, id=6366},
	--Equipment
	["R1 Grappling Hook (DCDB)"] = {vp=1, isEquipment=true, cost=3, id=8605},
	["R1 Utility Belt (DCDB)"] = {vp=1, isEquipment=true, cost=5, id=7640},
	["RB Batmobile (DCDB)"] = {vp=1, isEquipment=true, isDefense=true, isOngoing=true, cost=3, id=3999},
	["RC Magic Bracelets (DCDB)"] = {vp=1, isEquipment=true, cost=3, id=9666},
	["RC Trident of Lucifer (DCDB)"] = {vp=1, isEquipment=true, cost=5, id=4105},
	--Locations
	["C2 Atlantis (DCDB)"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=7099},
    	["C2 Atlantis (DCDB)"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=7099},
        ["C2 Atlantis (DCDB)"] = {vp=2, isLocation=true, isOngoing=true, cost=6, id=7099},
	--Super Villains
	["C1 Ra's Al Ghul (DCDB)"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=9, id=5876},
	["C2 Helspont (DCDB)"] = {vp=5, isVillain=true, isBoss=true, cost=11, id=9335},
	["C2 Vandal Savage (DCDB)"] = {vp=4, isVillain=true, isBoss=true, isOngoing=true, isStartBoss=true, cost=9, id=2179},
	["C3 Johnny Quick (DCDB)"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=1692},
	["C3 Owlman (DCDB)"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=7153},
	["C3 Power Ring (DCDB)"] = {vp=6, isVillain=true, isBoss=true, isPowerRing=true, cost=12, id=7824},
	["C4 Slade Wilson (DCDB)"] = {vp=4, isVillain=true, isBoss=true, isOngoing=true, isStartBoss=true, cost=9, id=9473},
	["CO1 Gentleman Ghost (DCDB)"] = {vp=6, isVillain=true, isBoss=true, cost=13, id=9924},
	["CO1 Mordru The Merciless (DCDB)"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=4740},
	["CO2 Isabel Rochev (DCDB)"] = {vp=7, isVillain=true, isBoss=true, cost=14, id=4498},
	["CO6 The Calculator (DCDB)"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=7466},
	["DC Deathstroke (DCDB)"] = {vp=5, isVillain=true, isBoss=true, cost=9, id=5640},
	["HU Helspont (DCDB)"] = {vp=5, isVillain=true, isBoss=true, cost=10, id=6868},
	["TT Blackfire (DCDB)"] = {vp=6, isVillain=true, isBoss=true, cost=11, id=4486},
	["TTG Control Freak (DCDB)"] = {vp=4, isBoss=true, isVillain=true, isStartBoss=true, cost=8},
	["TTG Billy Numerous (DCDB)"] = {vp=5, isBoss=true, isVillain=true, cost=10},
	["TTG Gizmo (DCDB)"] = {vp=5, isBoss=true, isVillain=true, cost=10,},
	["TTG Jinx (DCDB)"] = {vp=5, isBoss=true, isVillain=true, cost=10,},
	["TTG See-More (DCDB)"] = {vp=5, isBoss=true, isVillain=true, cost=10,},
	["TTGX Cavity Demon (DCDB)"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["TTGX Giant Robotic Alien (DCDB)"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	--Oversized Character Cards
	["CO5 Captain Cold (DCDB)"] = {vp=0, isCharacter=true, id=6393},
	["CO5 Golden Glider (DCDB)"] = {vp=0, isCharacter=true, id=7724},
	["CO5 Heatwave (DCDB)"] = {vp=0, isCharacter=true, id=4170},
	["CO5 Mirror Master (DCDB)"] = {vp=0, isCharacter=true, id=9156},
	["CO5 Trickster (DCDB)"] = {vp=0, isCharacter=true, id=3520},
	["CO5 Weather Wizard (DCDB)"] = {vp=0, isCharacter=true, id=1365},
	["DNM Superman (DCDB)"] = {vp=0, isCharacter=true, id=1825},
	["RB Cyborg (DCDB)"] = {vp=0, isCharacter=true, id=7597},
	["RB Simon Baz (DCDB)"] = {vp=0, isCharacter=true, id=7450},
	["RC Wonder Woman (Level 2)(DCDB)"] = {vp=6, isHero=true, isCharacter=true, cost=12, id=9713},
	--8)4) Legion of Doom
	--Super Villains
	["LoD Black Manta"] = {vp=5, isVillain=true, isBoss=true, cost=9,},
	["LoD Captain Cold"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["LoD Cheetah"] = {vp=6, isVillain=true, isBoss=true, cost=11,},
	["LoD Gorilla Grodd"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	["LoD Lex Luthor"] = {vp=4, isVillain=true, isBoss=true, isStartBoss=true, cost=8,},
	["LoD Scarecrow"] = {vp=5, isVillain=true, isBoss=true, isAttack=true, cost=9,},
	["LoD Solomon Grundy"] = {vp=5, isVillain=true, isBoss=true, cost=10,},
	--8)5) Super Friends
	--Super Heroes
	["SFr Superman"] = {vp=4, isHero=true, isBoss=true, isStartBoss=true, cost=8,},
	["SFr Jayna"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["SFr Robin"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["SFr Zan"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	["SFr Black Vulcan"] = {vp=5, isHero=true, isBoss=true, cost=10,},
	["SFr Hawkman"] = {vp=5, isHero=true, isBoss=true, cost=10,},
	["SFr Batman"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["SFr Green Lantern"] = {vp=6, isHero=true, isBoss=true, cost=11,},
	["SFr Aquaman"] = {vp=6, isHero=true, isBoss=true, cost=12,},
	["SFr Wonder Woman"] = {vp=6, isHero=true, isBoss=true, isDefense=true, cost=12,},
	--8)6) Peacemaker
	--Super Heroes
	["PM Peacemaker"] = {vp=6, isHero=true, isAttack=true, isBoss=true, cost=11,},
	["PM Vigilante"] = {vp=5, isHero=true, isBoss=true, cost=9,},
	--Oversized Character Cards
	["PM Peacemaker (Character)"] = {vp=0, isCharacter=true,},
	["PM Vigilante (Character)"] = {vp=0, isCharacter=true,},
	--9)1) Epic Spell Wars of the Battle Wizards - Annihilageddon
	--Other
	["EA1 Wand"] = {vp=0, isStarter=true, isAttack=true, cost=0},
	["EA1 Glyph"] = {vp=0, isStarter=true, cost=0},
	["EA1 Fizzle"] = {vp=0, isStarter=true, isFizzle=true, cost=0},
	["EA1 Limp Wand"] = {vp=-1, isLimp=true, cost=0},
	["EA1 Wild Magic"] = {vp=1, cost=3},
	--Wizards
	["EA1 Abraca-Labrador"] = {vp=1, isWizard=true, cost=2},
	["EA1 Bossu Fishmonger"] = {vp=1, isWizard=true, cost=4},
	["EA1 Car-Lotta Familiars"] = {vp=1, isWizard=true, isDefense=true, cost=3},
	["EA1 Damsel Distressia"] = {vp=1, isWizard=true, isAttack=true, cost=3},
	["EA1 Destiny's Child"] = {vp=1, isWizard=true, cost=3},
	["EA1 Epando the Brain"] = {vp=1, isWizard=true, isAttack=true, cost=5},
	["EA1 Fingler"] = {vp=3, isWizard=true, cost=6},
	["EA1 Pustualod Rippskull"] = {vp=1, isWizard=true, isAttack=true, cost=4},
	["EA1 Pytho Lzr-Wülf"] = {vp=1, isWizard=true, isAttack=true, cost=5},
	["EA1 Sblendo the Dreamcrusher"] = {vp=1, isWizard=true, cost=4},
	["EA1 Solzar the Wizard Star"] = {vp=2, isWizard=true, isAttack=true, cost=7},
	["EA1 Sugarpuss"] = {vp=2, isWizard=true, cost=6},
	["EA1 Vee-Arr the Virtual Wiz"] = {vp=1, isWizard=true, isDefense=true, cost=5},
	--Creatures
	["EA1 Acid Dragon"] = {vp=1, isCreature=true, cost=3},
	["EA1 BFG"] = {vp=2, isCreature=true, isAttack=true, cost=6},
	["EA1 Boogie Knight"] = {vp=1, isCreature=true, cost=2},
	["EA1 Cthulhu"] = {vp=3, isCreature=true, isAttack=true, cost=7},
	["EA1 Fatality Fighter"] = {vp=1, isCreature=true, isAttack=true, cost=3},
	["EA1 Fruity Rooty"] = {vp=2, isCreature=true, isAttack=true, cost=6},
	["EA1 Genital Harpies"] = {vp=1, isCreature=true, isAttack=true, cost=5},
	["EA1 Lucky's Charms"] = {vp=1, isCreature=true, cost=4},
	["EA1 Not-Live Girls"] = {vp=1, isCreature=true, cost=3},
	["EA1 Sk8 Ratz"] = {vp=1, isCreature=true, isDefense=true, cost=4},
	["EA1 Stabby Steve"] = {vp=1, isCreature=true, isAttack=true, cost=4},
	["EA1 The Twins"] = {vp=1, isCreature=true, cost=5},
	["EA1 The What?!"] = {vp=1, isCreature=true, isAttack=true, cost=5},
	--Spells
	["EA1 Annihilaggedon!"] = {vp=2, isSpell=true, isAttack=true, cost=7},
	["EA1 Dragon Whored"] = {vp=1, isSpell=true, cost=3},
	["EA1 Furry Fury"] = {vp=1, isSpell=true, cost=4},
	["EA1 Goregasm"] = {vp=1, isSpell=true, cost=5},
	["EA1 Inappropriatus Grab-O"] = {vp=1, isSpell=true, cost=2},
	["EA1 Lucky Day"] = {vp=1, isSpell=true, isDefense=true, cost=3},
	["EA1 Mega-Fisting!"] = {vp=1, isSpell=true, isAttack=true, cost=4},
	["EA1 Mist Me Fucker"] = {vp=1, isSpell=true, isDefense=true, cost=4},
	["EA1 Necromancing"] = {vp=2, isSpell=true, cost=6},
	["EA1 Sin-Fection"] = {vp=1, isSpell=true, isAttack=true, cost=3},
	["EA1 Stover-Heated"] = {vp=2, isSpell=true, cost=5},
	["EA1 Vomit Comet"] = {vp=1, isSpell=true, cost=5},
	["EA1 Wizard Babies"] = {vp=2, isSpell=true, isAttack=true, cost=6},
	--Treasures
	["EA1 Battle Sax"] = {vp=1, isTreasure=true, isAttack=true, cost=5},
	["EA1 Deep Shit"] = {vp=1, isTreasure=true, isAttack=true, cost=3},
	["EA1 Dragon's Ballz"] = {vp=0, isTreasure=true, isDefense=true, isOngoing=true, cost=5},
	["EA1 Golden Girls"] = {vp=1, isTreasure=true, isOngoing=true, cost=3},
	["EA1 Huge Boner"] = {vp=0, isTreasure=true, isOngoing=true, cost=3},
	["EA1 Johnny's Rotten Staph"] = {vp=1, isTreasure=true, isAttack=true, cost=4},
	["EA1 Joy-Boy's Bag of Goodies"] = {vp=2, isTreasure=true, cost=6},
	["EA1 Overkill Grill"] = {vp=1, isTreasure=true, isAttack=true, cost=5},
	["EA1 Robotic Tongue"] = {vp=1, isTreasure=true, isDefense=true, cost=2},
	["EA1 Sexcalibur"] = {vp=1, isTreasure=true, cost=4},
	["EA1 The Un-Holy Grail"] = {vp=2, isTreasure=true, isDefense=true, cost=6},
	["EA1 Uncle Andy's Laurels"] = {vp=2, isTreasure=true, cost=7},
	["EA1 Wand of Porkus"] = {vp=1, isTreasure=true, isAttack=true, cost=4},
	--Locations
	["EA1 Annihilageddon Arena"] = {vp=3, isLocation=true, isOngoing=true, cost=7},
	["EA1 Castle Tentakill"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["EA1 Go-Mart"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["EA1 Mt. Skullzfyre"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["EA1 Murdershrrom Marsh"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["EA1 The Pleasure Palace"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	--Legends
	["EA1 Ben-Nanamancer"] = {vp=5, isBoss=true, isLegend=true, cost=9},
	["EA1 Blood Lord Krazztar"] = {vp=5, isBoss=true, isLegend=true, cost=9},
	["EA1 Champion Chafia and Burning Kitty"] = {vp=5, isBoss=true, isLegend=true, cost=10},
	["EA1 Ciggy the Slow Death"] = {vp=5, isBoss=true, isLegend=true, cost=10},
	["EA1 Doctor Extinction"] = {vp=6, isBoss=true, isLegend=true, cost=12},
	["EA1 Lickity-Styx, Demon Wizard"] = {vp=5, isBoss=true, isLegend=true, cost=9},
	["EA1 Magus Jenny Jellybean"] = {vp=6, isBoss=true, isLegend=true, isAttack=true, cost=12},
	["EA1 Much Darker Lord Dark Lord"] = {vp=6, isBoss=true, isLegend=true, cost=11},
	["EA1 One-Eyed, One-Armed, One-Balled Willy"] = {vp=4, isBoss=true, isStartBoss=true, isLegend=true, isAttack=true, cost=8},
	["EA1 Papa Boner"] = {vp=5, isBoss=true, isLegend=true, cost=10},
	["EA1 Skullzor!!! (Guitars Wailing)"] = {vp=6, isBoss=true, isLegend=true, cost=11},
	["EA1 The Cosmic Glyph"] = {vp=5, isBoss=true, isLegend=true, cost=10},
	--Familiars
	["EA1 Goldy!"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA1 Hairy the Eldritch Pube"] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA1 Horny Hank, Party Demon"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA1 Hugchuck, Haggis Hero"] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA1 Kids!"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA1 Lord Squeakers, Esq."] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA1 Poof the Gay Cloud"] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA1 Saint Stinkus"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA1 Sir Phlegm the Blessed"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA1 Sparky, Squire of Fire"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA1 Spoogy the Wizard Penis"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA1 The Dungeon Master"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	--Mayhem
	["EA1 Mayhem! A"] = {vp=0,},
	["EA1 Mayhem! B"] = {vp=0,},
	["EA1 Mayhem! C"] = {vp=0,},
	["EA1 Mayhem! D"] = {vp=0,},
	["EA1 Mayhem! E"] = {vp=0,},
	["EA1 Mayhem! F"] = {vp=0,},
	["EA1 Mayhem! G"] = {vp=0,},
	["EA1 Mayhem! H"] = {vp=0,},
	["EA1 Mayhem! I"] = {vp=0,},
	["EA1 Mayhem! J"] = {vp=0,},
	["EA1 Mayhem! K"] = {vp=0,},
	["EA1 Mayhem! L"] = {vp=0,},
	["EA1 Mayhem! M"] = {vp=0,},
	["EA1 Mayhem! N"] = {vp=0,},
	["EA1 Mayhem! O"] = {vp=0,},
	["EA1 Mayhem! P"] = {vp=0,},
	["EA1 Mayhem! Q"] = {vp=0,},
	["EA1 Mayhem! R"] = {vp=0,},
	["EA1 Mayhem! S"] = {vp=0,},
	["EA1 Mayhem! T"] = {vp=0,},
	["EA1 Mayhem! U"] = {vp=0,},
	["EA1 Mayhem! V"] = {vp=0,},
	["EA1 Mayhem! W"] = {vp=0,},
	["EA1 Mayhem! X"] = {vp=0,},
	["EA1 Mayhem! Y"] = {vp=0,},
	["EA1 Mayhem! Z"] = {vp=0,},
	--Oversized Character Cards
	["EA1 Ball of Cthulhu"] = {vp=0, isCharacter=true,},
	["EA1 Hellish Huffman and his Band of Rage"] = {vp=0, isCharacter=true,},
	["EA1 Joan of Spark"] = {vp=0, isCharacter=true,},
	["EA1 McRavey the Highland Magus"] = {vp=0, isCharacter=true,},
	["EA1 Mr. Lucky & the Charms"] = {vp=0, isCharacter=true,},
	["EA1 Snotia the Viscous Viscountess"] = {vp=0, isCharacter=true,},
	["EA1 The Game Over Lord"] = {vp=0, isCharacter=true,},
	["EA1 Venture the Party Dragon"] = {vp=0, isCharacter=true,},
	--9)2) Epic Spell Wars of the Battle Wizards - Annihilageddon - Gang Bangers Expansion
	--Other
	["EGB Blasting Glyph"] = {vp=0, isStarter=true, isAttack=true, cost=0},
	["EGB Infernal Contract"] = {vp=-1,},
	--Boner Boyz
	["EGB Boner Boyz"] = {vp=0,},
	["EGB Boner Boy"] = {vp=0, isAttack=true,},
	["EGB Da Bone Queen"] = {vp=0, isAttack=true,},
	["EGB Da Grave Robber"] = {vp=0,},
	["EGB Voodoo Dolly"] = {vp=0, isAttack=true,},
	--Freaky Fruits
	["EGB Freaky Fruit"] = {vp=0,},
	["EGB Berries Gone Wild"] = {vp=0, cost=1},
	["EGB Busted Cherries"] = {vp=0, isAttack=true, cost=3},
	["EGB Cheeky Peach"] = {vp=0, isAttack=true, cost=5},
	["EGB Date Grape"] = {vp=0, isAttack=true, cost=5},
	["EGB Lewd Appealer"] = {vp=0, isAttack=true, cost=2},
	["EGB Peeping Tom-ato"] = {vp=0, isAttack=true, cost=4},
	--Kthulhu Kids
	["EGB Kthulhu Kids"] = {vp=0,},
	["EGB Abby Azathoth"] = {vp=0, isAttack=true,},
	["EGB Cuddle Cultist"] = {vp=0,},
	["EGB Harry Hastur"] = {vp=0, isAttack=true,},
	["EGB Kathy Kthulhu"] = {vp=0, isAttack=true,},
	["EGB Nicky Nyarlathotep"] = {vp=0, isAttack=true,},
	["EGB Sammy Shub-Niggurath"] = {vp=0, isAttack=true,},
	--Lil' Goldo
	["EGB Lil' Goldo"] = {vp=0,},
	["EGB Bling the Dwarf"] = {vp=0, isAttack=true,},
	["EGB Bling the Troll"] = {vp=0, isAttack=true,},
	["EGB Lil' Goldo the Dragon"] = {vp=0, isAttack=true,},
	--Merkin Kingdom
	["EGB Merkin Kingdom"] = {vp=0,},
	["EGB Mercules"] = {vp=0,},
	["EGB Merkin"] = {vp=0, isAttack=true,},
	["EGB Merqueen"] = {vp=0,},
	--Rock 'N' Satan
	["EGB Rock 'N' Satan"] = {vp=0,},
	["EGB Beelzebug Beater"] = {vp=0, isAttack=true,},
	["EGB Crossroads Johnson"] = {vp=0, isAttack=true,},
	["EGB Dark Reverend"] = {vp=0, isAttack=true,},
	["EGB Das Evil"] = {vp=0, isAttack=true,},
	["EGB Deedee Deep Cutz"] = {vp=0, isAttack=true,},
	["EGB Gothicus Glum-Grim"] = {vp=0, isAttack=true,},
	["EGB Grody Roadie"] = {vp=0,},
	["EGB Skeeve Sinner"] = {vp=0, isAttack=true,},
	["EGB Styx Blazer"] = {vp=0, isAttack=true,},
	--Sk8 Ratz
	["EGB Sk8 Ratz"] = {vp=0,},
	["EGB Ballzor the Quenchinator"] = {vp=0,},
	["EGB Bubo"] = {vp=0, isAttack=true,},
	["EGB Shreddr the Sk8 Leader"] = {vp=0, isAttack=true,},
	["EGB Sk8 Punk"] = {vp=0, isAttack=true,},
	--Treasures/Legends
	["EGB Annihilageddon Arena Souvenir Cup"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Ball of the Wild Eye"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Car'Lotta Familiar's Cauldron"] = {vp=0, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Death Wand of the Time-Fetus"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Deck of Destiny"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isDefense=true, cost=8},
	["EGB Defensive Suppository Nuke"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isDefense=true, cost=8},
	["EGB Double D'Eagles"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Doubling Swords"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Eldritch Lance"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Electric Nipple Clamps"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB God's Truck Nuts"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Gory Guzzler's Gouger"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Grim Reaper Brand Scythe"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Legendary Lock"] = {vp=3, isTreasure=true, isBoss=true, isLegend=true, cost=6},
	["EGB Lil' Cat, Tiny Kitty of Kittenish Doom"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Lucky's Jackpot Helmet"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isDefense=true, cost=8},
	["EGB Mind Flayer's Whip"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Mind-Control Device"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Monkey Paw Nunchuks"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Plumber Shrooms"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Saint Salty Peter's Limp Rod"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Satan's Stripper Pole"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, isOngoing=true, cost=8},
	["EGB Shield of the Spider-Ass"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isDefense=true, cost=8},
	["EGB Shitty Old Chest"] = {vp=2, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Shoggoth Pop"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Shrink Ray Gun"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Tomb of the Grim Reaper"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isOngoing=true, cost=8},
	["EGB Wand of Jenny"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, cost=8},
	["EGB Wealth Transfer System"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=8},
	["EGB Willy's Long Lost Ball"] = {vp=0, isTreasure=true, isBoss=true, isLegend=true, isOngoing=true, cost=8},
	--Familiars
	["EGB Biggie Black Constrictor"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EGB Bubo's Fleas"] = {vp=1, isFamiliar=true, isDefense=true, cost=4},
	["EGB Mayhem Elemental"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	--Mayhem
	["EGB Mayhem! 1"] = {vp=0,},
	["EGB Mayhem! 2"] = {vp=0,},
	["EGB Mayhem! 3"] = {vp=0,},
	["EGB Mayhem! 4"] = {vp=0,},
	["EGB Mayhem! 5"] = {vp=0,},
	["EGB Mayhem! 6"] = {vp=0,},
	--Oversized Character Cards
	["EGB Papa Boner Da Voodoo King"] = {vp=0, isCharacter=true,},
	["EGB Thai-Foon Master of Mayhem"] = {vp=0, isCharacter=true,},
	--9)3) Epic Spell Wars of the Battle Wizards - Annihilageddon 2 - Xtreme Nacho Legends
	--Other
	["EA2 Cheez Wand"] = {vp=0, isStarter=true, isAttack=true, cost=0},
	["EA2 Weird Wand"] = {vp=0, isStarter=true, isAttack=true, cost=0},
	["EA2 Glyph"] = {vp=0, isStarter=true, cost=0},
	["EA2 Fizzle"] = {vp=0, isStarter=true, isFizzle=true, cost=0},
	["EA2 Limp Wand"] = {vp=-1, isLimp=true, cost=0},
	["EA2 Wild Magic"] = {vp=1, cost=3},
	--Wizards
	["EA2 Bing Ryerson the Insurer"] = {vp=2, isWizard=true, cost=6},
	["EA2 Cruelnipps"] = {vp=1, isWizard=true, isAttack=true, cost=5},
	["EA2 Gummi Archmage"] = {vp=1, isWizard=true, isOngoing=true, cost=2},
	["EA2 Lamby the Sacrificer"] = {vp=1, isWizard=true, isAttack=true, cost=5},
	["EA2 Pimpsbury the Dough Man"] = {vp=1, isWizard=true, isAttack=true, cost=5},
	["EA2 Rex Drawinger"] = {vp=2, isWizard=true, isDefense=true, cost=6},
	["EA2 Slippy Tippy the Peeler"] = {vp=1, isWizard=true, isAttack=true, cost=4},
	["EA2 Splitt-Nut Ground Pounder"] = {vp=1, isWizard=true, isAttack=true, isDefense=true, cost=4},
	["EA2 Twin Wyverns!"] = {vp=1, isWizard=true, isAttack=true, cost=3},
	["EA2 Wee-Woe Warlocks"] = {vp=1, isWizard=true, isDefense=true, cost=4},
	["EA2 Wizardo Wormster"] = {vp=1, isWizard=true, isDefense=true, cost=3},
	["EA2 Wor the Robo-Wizard"] = {vp=2, isWizard=true, cost=7},
	--Creatures
	["EA2 Ballz Brothers"] = {vp=1, isCreature=true, isDefense=true, cost=4},
	["EA2 Beer Holder"] = {vp=2, isCreature=true, cost=6},
	["EA2 Crazy M.I.B: (Man in Box)"] = {vp=0, isCreature=true, cost=5},
	["EA2 Dingler Mount"] = {vp=2, isCreature=true, isAttack=true, isOngoing=true, cost=2},
	["EA2 Generic High Fantasy Orc"] = {vp=1, isCreature=true, cost=4},
	["EA2 Huge Blobies"] = {vp=1, isCreature=true, isOngoing=true, cost=5},
	["EA2 Sexsquatch"] = {vp=2, isCreature=true, cost=7},
	["EA2 Shag-Oth the Fleshpile"] = {vp=2, isCreature=true, isAttack=true, cost=6},
	["EA2 Starving Starving Storkos"] = {vp=1, isCreature=true, cost=3},
	["EA2 Succulent Succubus"] = {vp=1, isCreature=true, cost=3},
	["EA2 Super-Sick Satan"] = {vp=1, isCreature=true, isAttack=true, cost=5},
	["EA2 The Sinquisition"] = {vp=1, isCreature=true, isAttack=true, cost=4},
	--Spells
	["EA2 Brainy Storm"] = {vp=1, isSpell=true, cost=5},
	["EA2 Dinglelishish"] = {vp=2, isSpell=true, cost=6},
	["EA2 Don't Give a Shit"] = {vp=1, isSpell=true, cost=5},
	["EA2 Friendality"] = {vp=2, isSpell=true, cost=7},
	["EA2 Hocus Focused-Fire"] = {vp=1, isSpell=true, isAttack=true, cost=4},
	["EA2 Low Five"] = {vp=4, isSpell=true, cost=2},
	["EA2 Poo-Pal Punishment"] = {vp=1, isSpell=true, isAttack=true, cost=4},
	["EA2 Summon Trash"] = {vp=1, isSpell=true, isAttack=true, cost=4},
	["EA2 Win More... More"] = {vp=2, isSpell=true, isAttack=true, cost=6},
	["EA2 Wish for More Lamps"] = {vp=1, isSpell=true, isDefense=true, cost=5},
	["EA2 Wizard Waste"] = {vp=1, isSpell=true, isOngoing=true, cost=3},
	["EA2 Wolf Cookie Gobbling"] = {vp=1, isSpell=true, isAttack=true, cost=3},
	--Treasures
	["EA2 Ballzor's Ultimate Cup"] = {vp=1, isTreasure=true, isDefense=true, cost=3},
	["EA2 Concentraded Evil"] = {vp=2, isTreasure=true, cost=5},
	["EA2 Dead Fred"] = {vp=1, isTreasure=true, isOngoing=true, cost=1},
	["EA2 Dead Jed"] = {vp=1, isTreasure=true, isOngoing=true, cost=1},
	["EA2 Dead Ned"] = {vp=1, isTreasure=true, isOngoing=true, cost=1},
	["EA2 Dead Red"] = {vp=1, isTreasure=true, isOngoing=true, cost=1},
	["EA2 Dead Zed"] = {vp=1, isTreasure=true, isOngoing=true, cost=1},
	["EA2 Dingleberry Wand"] = {vp=2, isTreasure=true, isAttack=true, cost=6},
	["EA2 Fatculamobile"] = {vp=2, isTreasure=true, cost=6},
	["EA2 Golden Parachute"] = {vp=1, isTreasure=true, isDefense=true, cost=2},
	["EA2 Helm of Horror"] = {vp=1, isTreasure=true, cost=4},
	["EA2 Idol of the Lucky Bitch"] = {vp=1, isTreasure=true, isDefense=true, cost=4},
	["EA2 Mega-Merch: Limited Edition T-Shirt"] = {vp=1, isTreasure=true, cost=4},
	["EA2 Not Live Stripper Pole"] = {vp=2, isTreasure=true, cost=7},
	["EA2 The Witch Wart"] = {vp=1, isTreasure=true, cost=5},
	["EA2 Wand of Poser Punishing"] = {vp=1, isTreasure=true, isAttack=true, cost=5},
	["EA2 Xtremez Nacho Wand"] = {vp=1, isTreasure=true, isAttack=true, cost=3},
	--Locations
	["EA2 Dingling Brothers Circus"] = {vp=2, isLocation=true, isOngoing=true, cost=7},
	["EA2 Hall of Legends... Gift Shop"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["EA2 The Dirty Wand, Wand Polishing"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["EA2 The Limp Tower of Power"] = {vp=3, isLocation=true, isOngoing=true, cost=3},
	["EA2 The Palm of the Creator"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	--Familiars
	["EA2 Buzzy The Chainsaw"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Candy Commandos"] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA2 Conductor Cosmo"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Disposable Suitors"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Dogo The Grim"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Duke Freakout, Esq."] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Gimby The Goblin Gimp"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Hando The Living Hand"] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA2 Legends of Yore"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Leviathan Seed"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Nil, Void God of Infinite Suffering"] = {vp=4, isFamiliar=true, isDefense=true,},
	["EA2 Pal-Centa! Your Feedbag Friend"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Pussy The Whipped"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Ramon Rot, The Bookworm"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Spellboy"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Spoiled Milk and The Terror Tots"] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA2 The Complete Breakfast"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 The Munchies"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 The Scared Stiff Club"] = {vp=2, isFamiliar=true, isDefense=true, isOngoing=true, cost=6},
	["EA2 The Skeeve Jester"] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA2 The Turdlings"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Tiny, The Pet Wizard"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Tomb of Nil"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	["EA2 Weeby Otaku"] = {vp=2, isFamiliar=true, isAttack=true, isDefense=true, cost=6},
	["EA2 Wolf Eye of Wix-Ar"] = {vp=2, isFamiliar=true, isDefense=true, cost=6},
	--Legends Wizards
	["EA2 Bartholomew Blackbart"] = {vp=3, isWizard=true, isBoss=true, isLegend=true, isAttack=true, cost=9},
	["EA2 Dr. Continuum and Lil' Pharty"] = {vp=5, isWizard=true, isBoss=true, isLegend=true, cost=14},
	["EA2 Explozivo the Diarrheamancer"] = {vp=4, isWizard=true, isBoss=true, isLegend=true, isAttack=true, cost=10},
	["EA2 Lady Gore-Orgy, The Delicious Dead"] = {vp=3, isWizard=true, isBoss=true, isLegend=true, isAttack=true, cost=9},
	["EA2 Saint Schadenfreude"] = {vp=7, isWizard=true, isBoss=true, isLegend=true, isAttack=true, cost=19},
	["EA2 The Dingling Brothers"] = {vp=4, isWizard=true, isBoss=true, isLegend=true, isDefense=true, cost=12},
	["EA2 Viagrus The Hard Lord"] = {vp=5, isWizard=true, isBoss=true, isLegend=true, isOngoing=true, cost=13},
	--Legends Creatures
	["EA2 Blistreria, Queen of the Genital Harpies"] = {vp=4, isCreature=true, isBoss=true, isLegend=true, isAttack=true, cost=10},
	["EA2 Goldy the Goose"] = {vp=0, isCreature=true, isBoss=true, isLegend=true, cost=10},
	["EA2 Immortality Kombatant"] = {vp=5, isCreature=true, isBoss=true, isLegend=true, isAttack=true, cost=13},
	["EA2 Lucky Double-Headed Dingler"] = {vp=4, isCreature=true, isBoss=true, isLegend=true, cost=10},
	["EA2 Mr. Bun, Rogue Familiar"] = {vp=6, isCreature=true, isBoss=true, isLegend=true, isAttack=true, cost=17},
	["EA2 Plantasia Snatcher"] = {vp=3, isCreature=true, isBoss=true, isLegend=true, isAttack=true, cost=9},
	["EA2 The Merry Reaper"] = {vp=6, isCreature=true, isBoss=true, isLegend=true, isAttack=true, cost=16},
	--Legends Spells
	["EA2 Deal with The Devil"] = {vp=6, isSpell=true, isBoss=true, isLegend=true, cost=17},
	["EA2 Death for Lunch!"] = {vp=5, isSpell=true, isBoss=true, isLegend=true, cost=14},
	["EA2 Epic Heist"] = {vp=6, isSpell=true, isBoss=true, isLegend=true, cost=16},
	["EA2 Orbital Wiz-Atellite Strike"] = {vp=4, isSpell=true, isBoss=true, isLegend=true, isAttack=true, cost=12},
	["EA2 Party At R'lyeh"] = {vp=4, isSpell=true, isBoss=true, isLegend=true, isAttack=true, cost=11},
	["EA2 Polymorph: Dingler!"] = {vp=4, isSpell=true, isBoss=true, isLegend=true, isAttack=true, cost=12},
	["EA2 Scruffy Twatter's Elder Wand"] = {vp=3, isSpell=true, isBoss=true, isLegend=true, isAttack=true, cost=9},
	["EA2 The Sin-O-Biting"] = {vp=3, isSpell=true, isBoss=true, isLegend=true, cost=9},
	--Legends Treasures
	["EA2 Da Commando's Gatling Wand"] = {vp=5, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=15},
	["EA2 Heart of the Battle Wizard: Limited Edition"] = {vp=3, isTreasure=true, isBoss=true, isLegend=true, cost=9},
	["EA2 Heart of the Battle Wizard: Limited Edition (Sleeved)"] = {vp=5, isTreasure=true, isBoss=true, isLegend=true, cost=9},
	["EA2 My Bodyguard of Legend"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isDefense=true, cost=10},
	["EA2 Papa Boner's Pylon"] = {vp=5, isTreasure=true, isBoss=true, isLegend=true, isOngoing=true, cost=13},
	["EA2 The Limp Wand"] = {vp=4, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=11},
	["EA2 The Ultimate Winner's Wand"] = {vp=7, isTreasure=true, isBoss=true, isLegend=true, isAttack=true, cost=20},
	--Legends Locations
	["EA2 Fatcula's Snack Cart"] = {vp=4, isLocation=true, isBoss=true, isLegend=true, isOngoing=true, cost=10},
	["EA2 Sad Province of the Peet Farm"] = {vp=6, isLocation=true, isBoss=true, isLegend=true, isOngoing=true, cost=8},
	["EA2 The Vortex of Ultimate Fuckery"] = {vp=6, isLocation=true, isBoss=true, isLegend=true, isOngoing=true, cost=18},
	["EA2 Throne of Fuckery"] = {vp=4, isLocation=true, isBoss=true, isLegend=true, isAttack=true, isOngoing=true, cost=11},
	["EA2 Xtreeme Nacho Annihilaggedon Arena"] = {vp=5, isLocation=true, isBoss=true, isLegend=true, isOngoing=true, cost=15},
	--Mayhem
	["EA2 Mayhem! 2A"] = {vp=0,},
	["EA2 Mayhem! 2B"] = {vp=0,},
	["EA2 Mayhem! 2C"] = {vp=0,},
	["EA2 Mayhem! 2D"] = {vp=0,},
	["EA2 Mayhem! 2E"] = {vp=0,},
	["EA2 Mayhem! 2F"] = {vp=0,},
	["EA2 Mayhem! 2G"] = {vp=0,},
	["EA2 Mayhem! 2H"] = {vp=0,},
	["EA2 Mayhem! 2I"] = {vp=0,},
	["EA2 Mayhem! 2J"] = {vp=0,},
	["EA2 Mayhem! 2K"] = {vp=0,},
	["EA2 Mayhem! 2L"] = {vp=0,},
	["EA2 Mayhem! 2M"] = {vp=0,},
	["EA2 Mayhem! 2N"] = {vp=0,},
	["EA2 Mayhem! 2O"] = {vp=0,},
	["EA2 Mayhem! 2P"] = {vp=0,},
	["EA2 Mayhem! 2Q"] = {vp=0,},
	["EA2 Mayhem! 2R"] = {vp=0,},
	["EA2 Mayhem! 2S"] = {vp=0,},
	["EA2 Mayhem! 2T"] = {vp=0,},
	["EA2 Mega Mayhem! MA"] = {vp=0,},
	["EA2 Mega Mayhem! MB"] = {vp=0,},
	["EA2 Mega Mayhem! MC"] = {vp=0,},
	["EA2 Mega Mayhem! MD"] = {vp=0,},
	["EA2 Mega Mayhem! ME"] = {vp=0,},
	["EA2 Mega Mayhem! MF"] = {vp=0,},
	["EA2 Mega Mayhem! MG"] = {vp=0,},
	--Oversized Character Cards
	["EA2 Agony Aunt"] = {vp=0, isCharacter=true,},
	["EA2 Candy Cadaver Your Carnal Corpse"] = {vp=0, isCharacter=true,},
	["EA2 Charmodius Choo-Choo the Extraplanar Express"] = {vp=0, isCharacter=true,},
	["EA2 Dagon the Deep Doom"] = {vp=0, isCharacter=true,},
	["EA2 Damsel Distressia the Fuck You Princess"] = {vp=0, isCharacter=true,},
	["EA2 Gonzo Shroompuss Doctor of Conjurism"] = {vp=0, isCharacter=true,},
	["EA2 Jenny Jellybean and the Relics of Extinction"] = {vp=0, isCharacter=true,},
	["EA2 Killgore Murderfist the Death Dealer"] = {vp=0, isCharacter=true,},
	["EA2 Kimonono Starpop Demon"] = {vp=0, isCharacter=true,},
	["EA2 King Skeeve of the Rotten Wand"] = {vp=0, isCharacter=true,},
	["EA2 La Biblioteca 'Ujer Librarian of th Dead"] = {vp=0, isCharacter=true,},
	["EA2 Maztar Nimbus Eternal the Dogo Daddy"] = {vp=0, isCharacter=true,},
	["EA2 President Asshole"] = {vp=0, isCharacter=true,},
	["EA2 Satano Crunch The Cereal Killer"] = {vp=0, isCharacter=true,},
	["EA2 Skog The Gnarbarian"] = {vp=0, isCharacter=true,},
	["EA2 The Descendant Powerking of Legacy"] = {vp=0, isCharacter=true,},
	["EA2 Token Sak the Weed Smokin' Cheese Demon"] = {vp=0, isCharacter=true,},
	["EA2 Wix-Ar The Witch King"] = {vp=0, isCharacter=true,},
	["EA2 WizardMan! The Bearded Badass"] = {vp=0, isCharacter=true,},
	["EA2 Look'ins Wild Scounts"] = {vp=0, isCharacter=true,},
	--10)1) Rebirth
	--Other
	["RB Helping Hand"] = {vp=0, isStarter=true, cost=0, id=0},
	["RB Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["RB Run"] = {vp=0, isStarter=true, cost=0, id=0},
	["RB Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Heroes
	["RB Aquaman"] = {vp=1, isHero=true, cost=3, id=1049},
	["RB Batman"] = {vp=2, isHero=true, isDefense=true, cost=6, id=9771},
	["RB Black Canary"] = {vp=1, isHero=true, cost=2, id=4478},
	["RB Blue Beetle"] = {vp=1, isHero=true, isDefense=true, cost=5, id=3982},
	["RB Cyborg"] = {vp=1, isHero=true, cost=3, id=8214},
	["RB Doctor Fate"] = {vp=1, isHero=true, cost=5, id=9413},
	["RB Green Arrow"] = {vp=1, isHero=true, cost=4, id=1742},
	["RB Jessica Cruz"] = {vp=1, isHero=true, cost=4, id=9337},
	["RB Lois Lane"] = {vp=1, isHero=true, cost=3, id=7315},
	["RB Simon Baz"] = {vp=1, isHero=true, cost=4, id=1285},
	["RB Superman"] = {vp=2, isHero=true, cost=7, id=9731},
	["RB The Flash"] = {vp=2, isHero=true, cost=6, id=9892},
	["RB Wonder Woman"] = {vp=1, isHero=true, cost=5, id=1759},
	--Villains
	["RB Bane"] = {vp=4, isVillain=true, isAttack=true, cost=6, id=1505},
	["RB Bizarro"] = {vp=4, isVillain=true, isAttack=true, cost=6, id=6208},
	["RB Black Manta"] = {vp=4, isVillain=true, isAttack=true, cost=7, id=4346},
	["RB Cheetah"] = {vp=4, isVillain=true, isAttack=true, cost=6, id=9172},
	["RB Count Vertigo"] = {vp=3, isVillain=true, isAttack=true, cost=5, id=9957},
	["RB Doctor Polaris"] = {vp=4, isVillain=true, isAttack=true, cost=6, id=3436},
	["RB Eradicator"] = {vp=4, isVillain=true, isAttack=true, cost=7, id=6224},
	["RB Giganta"] = {vp=3, isVillain=true, isAttack=true, cost=5, id=3437},
	["RB Major Disaster"] = {vp=3, isVillain=true, isAttack=true, cost=5, id=8893},
	["RB Poison Ivy"] = {vp=4, isVillain=true, isAttack=true, cost=6, id=4234},
	["RB Psimon"] = {vp=4, isVillain=true, isAttack=true, cost=7, id=8173},
	["RB Psycho-Pirate"] = {vp=3, isVillain=true, isAttack=true, cost=5, id=1083},
	["RB Scarecrow"] = {vp=3, isVillain=true, isAttack=true, cost=5, id=8510},
	["RB Solomon Grundy"] = {vp=4, isVillain=true, isAttack=true, cost=7, id=8392},
	["RB The Joker"] = {vp=4, isVillain=true, isAttack=true, cost=7, id=6953},
	--Super Powers
	["RB Blast"] = {vp=1, isSuperPower=true, cost=3, id=6255},
	["RB Bolt of Zeus"] = {vp=1, isSuperPower=true, cost=4, id=7861},
	["RB Constructs"] = {vp=2, isSuperPower=true, cost=6, id=1268},
	["RB Contained"] = {vp=1, isSuperPower=true, cost=3, id=1017},
	["RB Flurry of Fists"] = {vp=1, isSuperPower=true, cost=5, id=3391},
	["RB Hard Water Bubble"] = {vp=1, isSuperPower=true, isDefense=true, cost=2, id=5311},
	["RB Heat Vision"] = {vp=1, isSuperPower=true, cost=5, id=3498},
	["RB Shields Up"] = {vp=2, isSuperPower=true, isDefense=true, cost=5, id=2145},
	["RB Speed Force"] = {vp=2, isSuperPower=true, cost=6, id=1688},
	["RB Super Breath"] = {vp=1, isSuperPower=true, cost=4, id=5154},
	["RB Super Strength"] = {vp=2, isSuperPower=true, cost=7, id=1945},
	["RB Telepathy"] = {vp=1, isSuperPower=true, cost=3, id=6110},
	["RB Vibration"] = {vp=1, isSuperPower=true, isDefense=true, cost=4, id=4588},
	--Equipment
	["RB Batcomputer"] = {vp=1, isEquipment=true, cost=5, id=5537},
	["RB Batmobile"] = {vp=1, isEquipment=true, isDefense=true, isOngoing=true, cost=3, id=3999},
	["RB Batplane"] = {vp=2, isEquipment=true, cost=6, id=6404},
	["RB Flash Helmet"] = {vp=1, isEquipment=true, cost=4, id=1655},
	["RB Grappling Hook"] = {vp=1, isEquipment=true, cost=3, id=5730},
	["RB Holographic Computing"] = {vp=1, isEquipment=true, cost=4, id=5958},
	["RB Jetpack"] = {vp=1, isEquipment=true, cost=2, id=5480},
	["RB Power Battery"] = {vp=2, isEquipment=true, cost=7, id=1910},
	["RB Sonic Cannon"] = {vp=1, isEquipment=true, cost=3, id=6795},
	["RB Super-Suit"] = {vp=1, isEquipment=true, isDefense=true, cost=5, id=5566},
	["RB Trident of Atlantis"] = {vp=1, isEquipment=true, cost=4, id=9904},
	["RB Wonder Woman's Shield"] = {vp=2, isEquipment=true, isOngoing=true, cost=6, id=6668},
	["RB Zodiac Crystals"] = {vp=1, isEquipment=true, cost=5, id=8745},
	--Basics
	["RB Batcycle"] = {vp=1, cost=3},
	["RB Batsignal"] = {vp=1, cost=3},
	["RB Flight"] = {vp=1, cost=3},
	["RB Super Speed"] = {vp=1, isDefense=true, cost=3},
	["RB Tomorrow's Headline"] = {vp=1, cost=2},
	["RB Toss"] = {vp=1, cost=3},
	["RB Withdrawal"] = {vp=1, cost=2},
	--Super Villains
	["RB Amazo"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=10, id=6009},
	["RB Deathstroke"] = {vp=5, isVillain=true, isBoss=true, isAttack=true, cost=8, id=8433},
	["RB Despero"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=9, id=4347},
	["RB Doomsday"] = {vp=5, isVillain=true, isBoss=true, isAttack=true, cost=8, id=9849},
	["RB General Zod"] = {vp=7, isVillain=true, isBoss=true, isAttack=true, cost=11, id=6802},
	["RB Lex Luthor"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=10, id=6625},
	["RB Reverse-Flash"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=9, id=7650},
	["RB Sinestro"] = {vp=7, isVillain=true, isBoss=true, isAttack=true, cost=11, id=6020},
	--Signature Cards
	["RB Aquaman 1 - Talking to the Fishes"] = {vp=0, isStarter=true, cost=0, id=6210},
	["RB Aquaman 2 - Mera"] = {vp=0, isHero=true, cost=0, id=3380},
	["RB Aquaman 3 - King of Atlantis"] = {vp=0, isSuperPower=true, cost=0, id=2056},
	["RB Batman 1 - Detective Work"] = {vp=0, isStarter=true, cost=0, id=6291},
	["RB Batman 2 - Alfred Pennyworth"] = {vp=0, isHero=true, isDefense=true, cost=0, id=1895},
	["RB Batman 3 - Batarang"] = {vp=0, isEquipment=true, cost=0, id=1630},
	["RB Cyborg 1 - Electrified Field"] = {vp=0, isStarter=true, cost=0, id=8663},
	["RB Cyborg 2 - Boom Tube"] = {vp=0, isEquipment=true, cost=0, id=3897},
	["RB Cyborg 3 - Connected"] = {vp=0, isSuperPower=true, cost=0, id=1110},
	["RB Flash 1 - Flash Suit"] = {vp=0, isStarter=true, cost=0, id=5789},
	["RB Flash 2 - Whoosh!"] = {vp=0, isSuperPower=true, cost=0, id=4291},
	["RB Flash 3 - Carry On"] = {vp=0, isSuperPower=true, cost=0, id=3454},
	["RB Jessica 1 - Original Power Ring"] = {vp=0, isStarter=true, isPowerRing=true, cost=0, id=7528},
	["RB Jessica 2 - Willpower"] = {vp=0, isSuperPower=true, cost=0, id=6645},
	["RB Jessica 3 - Teamwork"] = {vp=0, isSuperPower=true, cost=0, id=1058},
	["RB Simon 1 - Sector 2814 Power Ring"] = {vp=0, isStarter=true, isPowerRing=true, cost=0, id=4934},
	["RB Simon 2 - Healing Light"] = {vp=0, isSuperPower=true, cost=0, id=1626},
	["RB Simon 3 - Emerald Sight"] = {vp=0, isSuperPower=true, cost=0, id=8458},
	["RB Superman 1 - Big Blue Boy Scout"] = {vp=0, isStarter=true, cost=0, id=5064},
	["RB Superman 2 - Bulletproof"] = {vp=0, isSuperPower=true, isDefense=true, cost=0, id=5157},
	["RB Superman 3 - A Job For Superman"] = {vp=0, isSuperPower=true, cost=0, id=1391},
	["RB Wonder Woman 1 - Faithful Friend"] = {vp=0, isStarter=true, cost=0, id=1880},
	["RB Wonder Woman 2 - Lasso"] = {vp=0, isEquipment=true, cost=0, id=4761},
	["RB Wonder Woman 3 - Warrior Princess"] = {vp=0, isSuperPower=true, cost=0, id=5700},
	--Scenario Cards
	["RB Learning the Ropes"] = {vp=0,},
	["RB Proving Grounds"] = {vp=0,},
	["RB It's a Trap!"] = {vp=0,},
	["RB Hostage Situation"] = {vp=0,},
	["RB Hoarder"] = {vp=0,},
	["RB Glutton"] = {vp=0,},
	["RB Suspicious"] = {vp=0,},
	["RB Glory Hound"] = {vp=0,},
	["RB Recruit Krypto"] = {vp=0,},
	["RB Krypto"] = {vp=2, isHero=true, isDefense=true, cost=6, id=7952},
	["RB Recruit The Ray"] = {vp=0,},
	["RB The Ray"] = {vp=1, isHero=true, cost=3},
	["RB Repairs"] = {vp=0,},
	["RB This is Going to be Fun!"] = {vp=0,},
	["RB Mister Mxyzptlk"] = {vp=7, isVillain=true, isBoss=true, isAttack=true, cost=12},
	["RB Reborn"] = {vp=0, cost=6},
	["RB Distractions"] = {vp=0,},
	["RB A Shot in the Arm"] = {vp=0,},
	["RB Setting the Stage"] = {vp=0,},
	["RB Counting on You"] = {vp=0,},
	["RB Travel in Pairs"] = {vp=0,},
	["RB Mind-Controlled!"] = {vp=0,},
	["RB Starro"] = {vp=7, isVillain=true, isBoss=true, isAttack=true, cost=13},
	["RB Poisoned Super-Villains"] = {vp=0,},
	["RB Take One for the Team"] = {vp=0,},
	["RB Retaliations"] = {vp=0,},
	["RB Save One for the Team"] = {vp=0,},
	["RB Darkseid Cometh"] = {vp=0,},
	["RB Darkseid"] = {vp=8, isVillain=true, isBoss=true, isAttack=true, cost=16},
	["RB Continuing Adventures - Impossible Mode!"] = {vp=0,},
	["RB Doomsday (Impossible Mode)"] = {vp=0,},
	["RB Deathstroke (Impossible Mode)"] = {vp=0,},
	["RB Reverse-Flash (Impossible Mode)"] = {vp=0,},
	["RB Despero (Impossible Mode)"] = {vp=0,},
	["RB General Zod (Impossible Mode)"] = {vp=0,},
	["RB Lex Luthor (Impossible Mode)"] = {vp=0,},
	["RB Sinestro (Impossible Mode)"] = {vp=0,},
	["RB Amazo (Impossible Mode)"] = {vp=0,},
	["RB Mister Mxyzptlk (Impossible Mode)"] = {vp=0,},
	["RB Starro (Impossible Mode)"] = {vp=0,},
	["RB Darkseid (Impossible Mode)"] = {vp=0,},
	--Oversized Character Cards
	["RB Aquaman (Character)"] = {vp=0, isCharacter=true, id=6860},
	["RB Batman(Character)"] = {vp=0, isCharacter=true, id=7128},
	["RB Cyborg (Character)"] = {vp=0, isCharacter=true, id=7597},
	["RB Jessica Cruz (Character)"] = {vp=0, isCharacter=true, id=6079},
	["RB Simon Baz (Character)"] = {vp=0, isCharacter=true, id=7450},
	["RB Superman (Character)"] = {vp=0, isCharacter=true, id=2165},
	["RB The Flash (Character)"] = {vp=0, isCharacter=true, id=6549},
	["RB Wonder Woman (Character)"] = {vp=0, isCharacter=true, id=5444},
	--10)1)B) Time Heist
	--Oversized Character Cards
	["OS2 Vixen"] = {vp=0, isCharacter=true,},
	["OS2 The Atom"] = {vp=0, isCharacter=true,},
	--10)1)C) Adam's Vengeance
	--Heroes
	["OS3 John Constantine"] = {vp=1, isHero=true, cost=5,},
	["OS3 Mary Marvel"] = {vp=2, isHero=true, isDefense=true, cost=6,},
	--Super Powers
	["OS3 Incantation"] = {vp=1, isSuperPower=true, cost=5,},
	--Oversized Character Cards
	["OS3 Billy Batson/Shazam"] = {vp=0, isCharacter=true,},
	["OS3 Zatanna"] = {vp=0, isCharacter=true,},
	--OF)Hutson)0)1) Marvel
	--Other
	["MA Punch"] = {vp=0, isStarter=true, cost=0, id=8867},
	["MA Vulnerability"] = {vp=0, isStarter=true, cost=0, id=4167},
	["MA Weakness"] = {vp=-1, isWeakness=true, cost=0, id=7071},
	--Heroes
	["MA Tony Stark"] = {vp=1, isHero=true, cost=5},
	["MA The Fantastic 4"] = {vp=2, isHero=true, isDefense=true, cost=7},
	["MA Storm"] = {vp=1, isHero=true, isAttack=true, cost=5},
	["MA Steve Rogers"] = {vp=1, isHero=true, cost=5},
	["MA Star-Lord"] = {vp=1, isHero=true, cost=3},
	["MA Prince of Asgard"] = {vp=2, isHero=true, cost=7},
	["MA Peter Parker"] = {vp=1, isHero=true, cost=5},
	["MA Nick Fury"] = {vp=1, isHero=true, cost=3},
	["MA Natasha Romanoff"] = {vp=1, isHero=true, cost=5},
	["MA Logan Howlett"] = {vp=2, isHero=true, isDefense=true, cost=6},
	["MA Kitty Pryde"] = {vp=1, isHero=true, isDefense=true, cost=1},
	["MA Hawkeye"] = {vp=1, isHero=true, cost=4},
	["MA Doctor Strange"] = {vp=2, isHero=true, cost=7},
	["MA Daredevil"] = {vp=1, isHero=true, cost=3},
	["MA Cyclops"] = {vp=1, isHero=true, cost=4},
	["MA Charles Xavier"] = {vp=2, isHero=true, cost=6},
	["MA Bruce Banner"] = {vp=2, isHero=true, cost=7},
	["MA Ant-Man"] = {vp=1, isHero=true, cost=3},
	--Villains
	["MA Whiplash"] = {vp=1, isVillain=true, cost=4},
	["MA Venom"] = {vp=2, isVillain=true, isAttack=true, cost=7},
	["MA The Enchantress"] = {vp=2, isVillain=true, cost=6},
	["MA Sandman"] = {vp=1, isVillain=true, isDefense=true, cost=4},
	["MA Sabretooth"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["MA Rhino"] = {vp=1, isVillain=true, cost=3},
	["MA Mystique"] = {vp=1, isVillain=true, cost=3},
	["MA M.O.D.O.K."] = {vp=1, isVillain=true, isAttack=true, cost=3},
	["MA Juggernaut"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["MA Hydra Agents"] = {vp=1, isVillain=true, cost=2},
	["MA Doctor Octopus"] = {vp=1, isVillain=true, cost=4},
	["MA Dark Phoenix"] = {vp=3, isVillain=true, isAttack=true, cost=8},
	["MA Crossbones"] = {vp=1, isVillain=true, cost=4},
	--Super Powers
	["MA Wall Climbing"] = {vp=1, isSuperPower=true, cost=2},
	["MA Telepathy"] = {vp=1, isSuperPower=true, cost=5},
	["MA Super-Soldier Serum"] = {vp=1, isSuperPower=true, cost=2},
	["MA Spider-Sense"] = {vp=1, isSuperPower=true, isDefense=true, cost=3},
	["MA Mutant X-Gene"] = {vp=1, isSuperPower=true, cost=2},
	["MA HULK SMASH!!!"] = {vp=2, isSuperPower=true, cost=6},
	["MA Healing Factor"] = {vp=1, isSuperPower=true, isDefense=true, cost=3},
	["MA Kick"] = {vp=1, isSuperPower=true, cost=3, id=9883},
	--Equipment
	["MA Widow's Line"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
	["MA Widow's Bite"] = {vp=1, isEquipment=true, isAttack=true, cost=3},
	["MA Web-Shooter"] = {vp=1, isEquipment=true, isAttack=true, cost=2},
	["MA Vibranium Shield"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
	["MA Repulsor Beams"] = {vp=1, isEquipment=true, cost=2},
	["MA Mjolnir"] = {vp=2, isEquipment=true, isAttack=true, cost=7},
	["MA Iron Man Armor"] = {vp=1, isEquipment=true, cost=4},
	["MA Infinity Stone"] = {vp=0, isEquipment=true, cost=5},
	["MA Infinity Gauntlet"] = {vp=2, isEquipment=true, cost=7},
	["MA Cerebro"] = {vp=1, isEquipment=true, cost=5},
	["MA Arc Reactor"] = {vp=2, isEquipment=true, isDefense=true, cost=6},
	--Locations
	["MA Xavier's School for Gifted Youngsters"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["MA Stark Tower"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["MA Latveria"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["MA Asgard"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	--Super Villains
	["MA Kingpin"] = {vp=4, isVillain=true, isBoss=true, isOngoing=true, cost=8},
	["MA Apocalypse"] = {vp=6, isVillain=true, isBoss=true, cost=11},
	["MA Galactus"] = {vp=6, isVillain=true, isBoss=true, cost=12},
	["MA Abomination"] = {vp=5, isVillain=true, isBoss=true, cost=10},
	["MA Loki"] = {vp=5, isVillain=true, isBoss=true, cost=10},
	["MA Thanos"] = {vp=6, isVillain=true, isBoss=true, cost=12},
	["MA Red Skull"] = {vp=4, isVillain=true, isBoss=true, isAttack=true, cost=8},
	["MA Green Goblin"] = {vp=5, isVillain=true, isBoss=true, isAttack=true, cost=9},
	["MA Magneto"] = {vp=5, isVillain=true, isBoss=true, isAttack=true, cost=10},
	["MA Doctor Doom"] = {vp=5, isVillain=true, isBoss=true, cost=10},
	["MA The Mandarin"] = {vp=5, isVillain=true, isBoss=true, cost=9},
	["MA Ultron"] = {vp=5, isVillain=true, isBoss=true, isDefense=true, cost=10},
	--Main Characters
	["MA Spider-Man"] = {vp=0, isCharacter=true,},
	["MA Professor X"] = {vp=0, isCharacter=true,},
	["MA Wolverine"] = {vp=0, isCharacter=true,},
	["MA Hulk"] = {vp=0, isCharacter=true,},
	["MA Black Widow"] = {vp=0, isCharacter=true,},
	["MA Captain America"] = {vp=0, isCharacter=true,},
	["MA Iron Man"] = {vp=0, isCharacter=true,},
	["MA Thor"] = {vp=0, isCharacter=true,},
	--OF)Hutson)0)2) Teen Titans X
	--Main Characters
	["TTX Miss Martian"] = {vp=0, isCharacter=true,},
	["TTX Static "] = {vp=0, isCharacter=true,},
	--OF)Hutson)0)3) Crossover X1
	--Heroes
	["COX1 GCPD"] = {vp=1, isHero=true, cost=2},
	["COX1 Lucius Fox"] = {vp=1, isHero=true, cost=5},
	["COX1 Spoiler"] = {vp=1, isHero=true, cost=4},
	["COX1 Orphan"] = {vp=1, isHero=true, cost=5},
	["COX1 Ace, The Bat-Hound"] = {vp=1, isHero=true, isDefense=true, cost=3},
	--Villains
	["COX1 The Ventriloquist & Scarface"] = {vp=1, isVillain=true, isAttack=true, cost=3},
	["COX1 Trained Birds"] = {vp=1, isVillain=true, cost=3},
	["COX1 Henchmen"] = {vp=1, isVillain=true, cost=2},
	["COX1 Firefly"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["COX1 Calendar Man"] = {vp=1, isVillain=true, cost=3},
	["COX1 Mad Hatter"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	--Super Powers
	["COX1 Riddle Me This!"] = {vp=1, isSuperPower=true, cost=3},
	["COX1 Cryostasis"] = {vp=1, isSuperPower=true, cost=4},
	["COX1 Reptilian Aspect"] = {vp=2, isSuperPower=true, cost=6},
	["COX1 Squandered Wealth"] = {vp=1, isSuperPower=true, cost=5},
	["COX1 Two-Faced"] = {vp=1, isSuperPower=true, cost=4},
	--Equipment
	["COX1 Trick Umbrella"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
	["COX1 Fear Toxin"] = {vp=2, isEquipment=true, isAttack=true, cost=6},
	["COX1 Two-Headed Coin"] = {vp=1, isEquipment=true, cost=4},
	["COX1 Cryogenic Suit"] = {vp=2, isEquipment=true, cost=6},
	["COX1 Question Mark Cane"] = {vp=1, isEquipment=true, cost=5},
	--Locations
	["COX1 Gotham City Sewers"] = {vp=1, isLocation=true, cost=5},
	["COX1 Crime Alley"] = {vp=1, isLocation=true, cost=4},
	--Super Heroes
	["COX1 Commissioner Gordon"] = {vp=0, isHero=true, isBoss=true, cost=8},
	["COX1 Alfred Pennyworth"] = {vp=5, isHero=true, isBoss=true, cost=9},
	["COX1 Nightwing"] = {vp=5, isHero=true, isBoss=true, cost=10},
	["COX1 Batgirl"] = {vp=6, isHero=true, isBoss=true, isOngoing=true, cost=11},
	["COX1 Red Hood"] = {vp=6, isHero=true, isBoss=true, cost=12},
	["COX1 Red Robin"] = {vp=6, isHero=true, isBoss=true, cost=13},
	["COX1 Robin"] = {vp=7, isHero=true, isBoss=true, cost=14},
	["COX1 The Batman"] = {vp=7, isHero=true, isBoss=true, cost=15},
	--Main Characters
	["COX1 The Penguin"] = {vp=0, isCharacter=true,},
	["COX1 Mr. Freeze"] = {vp=0, isCharacter=true,},
	["COX1 Two-Face"] = {vp=0, isCharacter=true,},
	["COX1 Scarecrow"] = {vp=0, isCharacter=true,},
	["COX1 The Riddler"] = {vp=0, isCharacter=true,},
	["COX1 Killer Croc"] = {vp=0, isCharacter=true,},
	--OF)4) DC Super Hero Girls
	--Other
	["SHG Punch"] = {vp=0, isStarter=true, cost=0},
	["SHG Vulnerability"] = {vp=0, isStarter=true, cost=0},
	["SHG Weakness"] = {vp="-1", isWeakness=true, cost=0},
	["SHG Kick"] = {vp=1, isSuperPower=true, cost=3},
	--Heroes
	["SHG Bumblebee"] = {vp=1, isHero=true, cost=1},
	["SHG Aqualad"] = {vp=1, isHero=true, cost=2},
	["SHG Hawkman"] = {vp=1, isHero=true, cost=2},
	["SHG Batgirl"] = {vp=1, isHero=true, cost=3},
	["SHG The Flash"] = {vp=1, isHero=true, cost=3},
	["SHG Zatanna"] = {vp=1, isHero=true, cost=3},
	["SHG Green Arrow"] = {vp=1, isHero=true, isDefense=true, cost=4},
	["SHG Green Lantern (Hal)"] = {vp=1, isHero=true, cost=4},
	["SHG Green Lantern (Jess)"] = {vp=1, isHero=true, isDefense=true, cost=4},
	["SHG Katana"] = {vp=1, isHero=true, cost=5},
	["SHG Wonder Woman"] = {vp=2, isHero=true, cost=5},
	["SHG Batman"] = {vp=2, isHero=true, isDefense=true, cost=6},
	["SHG Queen Hippolyta"] = {vp=2, isHero=true, cost=6},
	["SHG Supergirl"] = {vp=2, isHero=true, cost=6},
	["SHG Giovani Zatara"] = {vp=2, isHero=true, cost=7},
	["SHG Superman"] = {vp=2, isHero=true, cost=7},
	--Villains
	["SHG Gremlins"] = {vp=1, isVillain=true, cost=2},
	["SHG The Penguin"] = {vp=1, isVillain=true, isAttack=true, cost=2},
	["SHG Catwoman"] = {vp=1, isVillain=true, cost=3},
	["SHG Dark Zatanna"] = {vp=1, isVillain=true, cost=3},
	["SHG Silver Banshee"] = {vp=1, isVillain=true, cost=3},
	["SHG Bizarro"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["SHG Cheetah"] = {vp=1, isVillain=true, cost=4},
	["SHG Fuseli"] = {vp=1, isVillain=true, cost=4},
	["SHG Harley Quinn"] = {vp=1, isVillain=true, isAttack=true, cost=4},
	["SHG Bane"] = {vp=1, isVillain=true, cost=5},
	["SHG Bee"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["SHG Poison Ivy"] = {vp=1, isVillain=true, isAttack=true, cost=5},
	["SHG Giganta"] = {vp=2, isVillain=true, cost=6},
	["SHG Star Sapphire"] = {vp=2, isVillain=true, cost=6},
	["SHG Livewire"] = {vp=2, isVillain=true, cost=7},
	--Super Powers
	["SHG Construct Shield"] = {vp=1, isSuperPower=true, isDefense=true, cost=2},
	["SHG Inventor"] = {vp=1, isSuperPower=true, cost=2},
	["SHG Invulnerable"] = {vp=1, isSuperPower=true, isDefense=true, cost=3},
	["SHG Shrinking"] = {vp=1, isSuperPower=true, cost=3},
	["SHG Teleportation"] = {vp=1, isSuperPower=true, cost=3},
	["SHG Construct Chainsaw"] = {vp=1, isSuperPower=true, cost=4},
	["SHG Magic Blasts"] = {vp=1, isSuperPower=true, cost=4},
	["SHG Stage Magic"] = {vp=1, isSuperPower=true, cost=4},
	["SHG Pacifism"] = {vp=1, isSuperPower=true, cost=5},
	["SHG Heat Vision"] = {vp=1, isSuperPower=true, cost=5},
	["SHG Amazon Physiology"] = {vp=2, isSuperPower=true, cost=6},
	["SHG Execution"] = {vp=2, isSuperPower=true, cost=6},
	["SHG Flight"] = {vp=2, isSuperPower=true, cost=6},
	["SHG Leadership"] = {vp=2, isSuperPower=true, cost=7},
	["SHG Super Strength"] = {vp=2, isSuperPower=true, cost=7},
	--Equipment
	["SHG Batarang"] = {vp=1, isEquipment=true, cost=2},
	["SHG Prototype Suit"] = {vp=1, isEquipment=true, cost=2},
	["SHG Cell Phone"] = {vp=1, isEquipment=true, cost=3},
	["SHG Kitchen Supplies"] = {vp=1, isEquipment=true, cost=3},
	["SHG S.W.B.B.Z.L.M."] = {vp=1, isEquipment=true, cost=3},
	["SHG Bat Scooter"] = {vp=1, isEquipment=true, cost=4},
	["SHG Bumblebee Suit"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
	["SHG Grappling Hook"] = {vp=1, isEquipment=true, cost=4},
	["SHG Soultaker Sword"] = {vp=1, isEquipment=true, cost=4},
	["SHG Mini Rocket Launchers"] = {vp=1, isEquipment=true, cost=5},
	["SHG Sword and Shield"] = {vp=1, isEquipment=true, isAttack=true, isDefense=true, cost=5},
	["SHG Lasso of Truth"] = {vp=2, isEquipment=true, cost=6},
	["SHG Magic Wand"] = {vp=2, isEquipment=true, cost=6},
	["SHG G. Lantern Power Ring"] = {vp=2, isEquipment=true, isPowerRing=true, cost=7},
	["SHG Egg"] = {vp=2, isEquipment=true, cost=7},
	--Locations
	["SHG Burrito Bucket"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["SHG Secret Base"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["SHG Sweet Justice"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["SHG Zee's Penthouse"] = {vp=1, isLocation=true, isOngoing=true, cost=4},
	["SHG Lazarus Pit"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
	["SHG Metropolis High"] = {vp=2, isLocation=true, isOngoing=true, cost=6},
	--Super Villains
	["SHG Lena Luthor"] = {vp=4, isVillain=true, isBoss=true, cost=8},
	["SHG Dex-Starr"] = {vp=5, isVillain=true, isBoss=true, cost=9},
	["SHG Enchantress"] = {vp=5, isVillain=true, isBoss=true, cost=9},
	["SHG Mega Casey Krinsky"] = {vp=5, isVillain=true, isBoss=true, cost=10},
	["SHG Ember"] = {vp=5, isVillain=true, isBoss=true, cost=10},
	["SHG Slade Wilson"] = {vp=5, isVillain=true, isBoss=true, cost=10},
	["SHG Starro"] = {vp=5, isVillain=true, isBoss=true, cost=10},
	["SHG The Joker"] = {vp=6, isVillain=true, isBoss=true, isAttack=true, cost=11},
	["SHG Lex Luthor"] = {vp=6, isVillain=true, isBoss=true, cost=11},
	["SHG Ra's Al Ghul"] = {vp=6, isVillain=true, isBoss=true, cost=11},
	["SHG General Zod"] = {vp=6, isVillain=true, isBoss=true, cost=12},
	["SHG Super-Villain Girls"] = {vp=6, isVillain=true, isBoss=true, cost=12},
	--Oversized Character Cards
	["SHG Babs Gordon"] = {vp=0, isCharacter=true,},
	["SHG Diana Prince"] = {vp=0, isCharacter=true,},
	["SHG Jessica Cruz"] = {vp=0, isCharacter=true,},
	["SHG Kara Danvers"] = {vp=0, isCharacter=true,},
	["SHG Karen Beecher"] = {vp=0, isCharacter=true,},
	["SHG Tatsu Yamashiro"] = {vp=0, isCharacter=true,},
	["SHG Zee Zatara"] = {vp=0, isCharacter=true,},
    --0F)5) Marvel Crossover 1 - Avengers VS X-Men
    --Heroes
    ["MC1 Storm"] = {vp=1, isHero=true, cost=3},
    ["MC1 Gambit"] = {vp=1, isHero=true, cost=3},
    ["MC1 Magneto"] = {vp=2, isHero=true, cost=5},
    ["MC1 Professor Xavier"] = {vp=2, isHero=true, cost=7},
    ["MC1 Havok"] = {vp=1, isHero=true, cost=3},
    ["MC1 Doctor Strange"] = {vp=1, isHero=true, cost=2},
    ["MC1 Black Panther"] = {vp=2, isHero=true, cost=6},
    ["MC1 Red Hulk"] = {vp=1, isHero=true, cost=4},
    ["MC1 Thor"] = {vp=2, isHero=true, cost=6},
    ["MC1 Hawkeye"] = {vp=1, isHero=true, cost=2},
    --Villains
    ["MC1 M.O.D.O.K."] = {vp=1, isVillain=true, cost=3},
    ["MC1 Puff Adder"] = {vp=1, isVillain=true, isOngoing=true, cost=1},
    --Super Powers
    ["MC1 Optic Blast"] = {vp=1, isSuperPower=true, cost=5},
    ["MC1 Repulsor Blast"] = {vp=1, isSuperPower=true, isAttack=true, cost=3},
    ["MC1 Supersonic Speed"] = {vp=1, isSuperPower=true, isOngoing=true, cost=3},
    ["MC1 Phoenix Fire"] = {vp=1, isSuperPower=true, cost=5},
    ["MC1 Kick"] = {vp=1, isSuperPower=true, cost=3},
    --Equipment
    ["MC1 Phoenix Buster"] = {vp=1, isEquipment=true, isDefense=true, cost=4},
    ["MC1 Iron Man Suit"] = {vp=1, isEquipment=true, isOngoing=true, cost=2},
    ["MC1 Hellicarrier"] = {vp=1, isEquipment=true, cost=3},
    ["MC1 Cerebra"] = {vp=1, isEquipment=true, cost=4},
    --Locations
    ["MC1 Utopia"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
    ["MC1 K'un L'un"] = {vp=1, isLocation=true, isOngoing=true, cost=5},
    --Super-Heroes
    ["MC1 Colossus"] = {vp=4, isHero=true, isBoss=true, isStartBoss=true, cost=9},
    ["MC1 Captain America"] = {vp=4, isHero=true, isBoss=true, isStartBoss=true, cost=8},
    ["MC1 Sub-Mariner"] = {vp=5, isHero=true, isBoss=true, cost=11},
    ["MC1 Spider-Man"] = {vp=5, isHero=true, isBoss=true, cost=10},
    ["MC1 Magik"] = {vp=5, isHero=true, isBoss=true, cost=11},
    ["MC1 Scarlet Witch"] = {vp=6, isHero=true, isBoss=true, cost=12},
    ["MC1 Cyclops"] = {vp=6, isHero=true, isBoss=true, cost=13},
    ["MC1 Iron Man"] = {vp=6, isHero=true, isBoss=true, cost=12},
    ["MC1 White Queen"] = {vp=6, isHero=true, isBoss=true, cost=13},
    ["MC1 Iron Fist"] = {vp=5, isHero=true, isBoss=true, cost=10},
    --Oversized Character Cards
    ["MC1 Piotr Rasputin"] = {vp=0, isCharacter=true},
    ["MC1 Namor"] = {vp=0, isCharacter=true},
    ["MC1 Illyana Rasputin"] = {vp=0, isCharacter=true},
    ["MC1 Scott Summers"] = {vp=0, isCharacter=true},
    ["MC1 Emma Frost"] = {vp=0, isCharacter=true},
    ["MC1 Steve Rogers"] = {vp=0, isCharacter=true},
    ["MC1 Daniel Rand"] = {vp=0, isCharacter=true},
    ["MC1 Wanda Maximoff"] = {vp=0, isCharacter=true},
    ["MC1 Hope Summers"] = {vp=0, isCharacter=true},
    ["MC1 Peter Parker"] = {vp=0, isCharacter=true},
    --Others
    ["MC1 Punch"] = {vp=0, isStarter=true, cost=0},
    ["MC1 Vulnerability"] = {vp=0, isStarter=true, cost=0},
    ["MC1 Weakness"] = {vp=-1, isWeakness=true, cost=0},
	--FcD)1) Fracasso Diario Personalizadas
	--Starter
	["FcD Defense"] = {vp=1, isStarter=true, cost=0,}, -- Transformed
	["FcD Weakness"] = {vp=-1, isWeakness=true, cost=0,},
	["FcD Weakness2"] = {vp=-2, isWeakness=true, cost=0,},
	["FcD Punch"] = {vp=0, isStarter=true, cost=0},
	["FcD Vulnerability"] = {vp=0, isStarter=true, cost=0},
	["FcD Sealed Defense"] = {vp=0, isStarter=true, cost=0},
    }
