<VerticalLayout rectAlignment="UpperLeft" offsetXY="200 -2" height="40" width="110">
  <Button id="showQuickGames" onClick="openMainUI" colors="#FFFFFF|#06598b|#004ddb" fontStyle="Bold" fontSize="13">
    Game Selection
  </Button>
</VerticalLayout>
<Defaults>
<ToggleButton colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold"/>
<Text alignment="MiddleCenter" color="white"/>
</Defaults>

<Panel id="Quick Game" height="650" width="920" allowDragging="true" color="#000000F0" returnToOriginalPositionWhenReleased="false" showAnimation="FadeIn" hideAnimation="FadeOut" animationDuration="1" active="false">
	<GridLayout cellSize="225,35" spacing="0" rectAlignment="UpperCenter">
		<ToggleButton id="clickDC"  onClick="quickGamesClicked" isOn="true">Basic Set Up</ToggleButton>
		<ToggleButton id="clickCustomMenu" onClick="quickGamesClicked">Custom Game Set Up</ToggleButton>
		<ToggleButton id="clickRandom" onClick="setupQuickRandom">Random Pick</ToggleButton>
		<ToggleButton id="clickOptions" onClick="quickGamesClicked">Options</ToggleButton>
	</GridLayout>
	<Button id="closeButton" onClick="openMainUI" width="20" height="25" rectAlignment="UpperRight" color="#990000" textColor="#FFFFFF" text="X"></Button>
	<Panel id="dcGameSetup" height="650" width="920" rectAlignment="LowerCenter" active="true">
	<!-- Click a Game to Start -->
		<VerticalScrollView offsetXY="0 -25" height="600" width="920" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b" cellBackgroundImage="" cellBackgroundColor="#00000000">
				<!-- DC Row 1-->
                <Row preferredHeight="150">
					<Cell columnSpan="2"><Button id="DCQuick" onClick="setupQuickGame">
						<Image image="DC" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="HUQuick" onClick="setupQuickGame">
						<Image image="HU" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="FEQuick" onClick="setupQuickGame">
						<Image image="FE" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="TTQuick" onClick="setupQuickGame">
						<Image image="TT" preserveAspect="false" ></Image></Button></Cell>
                </Row>
				<!--DC Row 2-->
                <Row preferredHeight="150" dontUseTableRowBackground="True">
					<Cell columnSpan="2"><Button id="DNMQuick" onClick="setupQuickGame">
						<Image image="DNM" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="INJQuick" onClick="setupQuickGame">
						<Image image="INJ" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="RBQuick" onClick="setupQuickGame">
						<Image image="RB" preserveAspect="false" ></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="DCDBQuick" onClick="setupDCDBCubeGame">
						<Image image="DCDB" preserveAspect="false" ></Image></Button></Cell>
                </Row>
				<!--Rivals Row 1-->
                <Row preferredHeight="150" dontUseTableRowBackground="True">
					<Cell columnSpan="2"><Button id="R1Quick" onClick="setupQuickGame">
						<Image image="R1" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="R2Quick" onClick="setupQuickGame">
						<Image image="R2" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="R3Quick" onClick="setupQuickGame">
						<Image image="R3" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="RCQuick" onClick="setupQuickGame">
						<Image image="RC" preserveAspect="false"></Image></Button></Cell>
                </Row>
				<!--LotR Row-->
				  <Row preferredHeight="150" dontUseTableRowBackground="true">
					<Cell columnSpan="2"><Button id="FotRQuick" onClick="setupQuickGame">
						<Image image="FotR" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="2TQuick" onClick="setupQuickGame">
						<Image image="2T" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="RotKQuick" onClick="setupQuickGame">
						<Image image="RotK" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="UJQuick" onClick="setupQuickGame">
						<Image image="UJ" preserveAspect="false"></Image></Button></Cell>
				  </Row>
				<!--CN Row-->
				  <Row preferredHeight="150" dontUseTableRowBackground="true">
					<Cell columnSpan="2"><Button id="DoSQuick" onClick="setupQuickGame">
						<Image image="DoS" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="CNQuick" onClick="setupQuickGame">
						<Image image="CN" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="AAQuick" onClick="setupQuickGame">
						<Image image="AA" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="TTGQuick" onClick="setupQuickGame">
						<Image image="TTG" preserveAspect="false"></Image></Button></Cell>
				  </Row>
				<!--Adult Swim Row -->
				  <Row preferredHeight="150" dontUseTableRowBackground="true">
					<Cell columnSpan="2"><Button id="RM1Quick" onClick="setupQuickGame">
						<Image image="RM1" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="RM2Quick" onClick="setupQuickGame">
						<Image image="RM2" preserveAspect="false" ></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="EA1Quick" onClick="setupQuickGame">
						<Image image="EA1" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="EA2Quick" onClick="setupQuickGame">
						<Image image="EA2" preserveAspect="false"></Image></Button></Cell>
				  </Row>
				<!--Adult Swim Row -->
				  <Row preferredHeight="150" dontUseTableRowBackground="true">
					<Cell columnSpan="2"><Button id="SFQuick" onClick="setupQuickGame">
						<Image image="SF" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"><Button id="NSQuick" onClick="setupQuickGame">
						<Image image="NS" preserveAspect="false"></Image></Button></Cell>
					<Cell columnSpan="2"></Cell>
					<Cell columnSpan="2"></Cell>
				  </Row>
		</TableLayout>
		</VerticalScrollView>
	</Panel>
	<Panel id="customSetup" height="650" width="920" rectAlignment="LowerCenter" active="false">
		<GridLayout cellSize="200,75" spacing="25" rectAlignment="UpperCenter" offsetXY="140 -75">
			<ToggleButton id="clickDCExpansions" onClick="quickGamesClicked">DC Crisis and Crossovers</ToggleButton>
			<ToggleButton id="clickDCRivals" onClick="quickGamesClicked">DC Rivals Expansion</ToggleButton>
			<ToggleButton id="clickMultiverse"  onClick="quickGamesClicked">DC Multiverse</ToggleButton>
		</GridLayout>
		<GridLayout cellSize="200,75" spacing="25" rectAlignment="UpperCenter" offsetXY="140 -175">
			<ToggleButton id="clickLotR" onClick="quickGamesClicked">Lord of the Rings</ToggleButton>
			<ToggleButton id="clickCartoon" onClick="quickGamesClicked">Cartoon Network</ToggleButton>
			<ToggleButton id="clickRickMorty"  onClick="quickGamesClicked">Rick and Morty</ToggleButton>
		</GridLayout>
		<GridLayout cellSize="200,75" spacing="25" rectAlignment="UpperCenter" offsetXY="140 -275">
			<ToggleButton id="clickESW" onClick="quickGamesClicked">Epic Spell Wars</ToggleButton>
			<ToggleButton id="clickGangBangers" onClick="quickGamesClicked">Gang Bangers</ToggleButton>
			<ToggleButton id="clickFullCustom"  onClick="quickGamesClicked">Everything</ToggleButton>
		</GridLayout>
		<VerticalLayout offsetXY="0 -400" width="675" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="220">
					<Cell columnSpan="1"><Text fontSize="18">
					Please be aware that sets and expansions from different series will have some slight variation on rules, and card types.
					 
					It's recommended that if you decide to mix different series, to establish your homebrew rules before the game starts.
					
					Just because you can mix everything, doesn't mean you should or it'll be more fun.
					</Text></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
	</Panel>
	<Panel id="optionSetup" height="650" width="920" color="#00000000" rectAlignment="LowerCenter" active="false">
		<VerticalLayout offsetXY="0 0" height="550" width="920" color="#00000000" scrollSensitivity="80">
		<TableLayout cellSpacing="0"  rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
		<Row preferredHeight="50">
			<Cell columnSpan="2"><Text fontSize="16">Table Size</Text></Cell>
			<Cell columnSpan="1"><ToggleButton id="4pToggle"  onClick="playerNumberToggleUI" isOn="true">4 Players</ToggleButton></Cell>
			<Cell columnSpan="1"><ToggleButton id="8pToggle"  onClick="playerNumberToggleUI">8 Players</ToggleButton></Cell>
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="2"><Text fontSize="18">Impossible Mode</Text></Cell>
			<Cell columnSpan="1"><ToggleButton id="impossibleToggleON"  onClick="optionImpossibleMode">On</ToggleButton></Cell>
			<Cell columnSpan="1"><ToggleButton id="impossibleToggleOFF"  onClick="optionImpossibleMode" isOn="true">Off</ToggleButton></Cell>
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="2"><Text fontSize="18">Automatic Line-Up Refill</Text></Cell>
			<Cell columnSpan="1"><ToggleButton id="refillToggleON"  onClick="optionLineUpRefill" isOn="true">On</ToggleButton></Cell>
			<Cell columnSpan="1"><ToggleButton id="refillToggleOFF"  onClick="optionLineUpRefill">Off</ToggleButton></Cell>
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="2"><Text fontSize="18">Automatic New Boss Flip</Text></Cell>
			<Cell columnSpan="1"><ToggleButton id="flipBossToggleON"  onClick="optionNewBossFlip" isOn="true">On</ToggleButton></Cell>
			<Cell columnSpan="1"><ToggleButton id="flipBossToggleOFF"  onClick="optionNewBossFlip">Off</ToggleButton></Cell>
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="2"><Text fontSize="18">Remove Objects with New Game</Text></Cell>
			<Cell columnSpan="1"><ToggleButton id="clearTableToggleON"  onClick="optionKeepObjects" isOn="true">On</ToggleButton></Cell>
			<Cell columnSpan="1"><ToggleButton id="clearTableToggleOFF"  onClick="optionKeepObjects">Off</ToggleButton></Cell>
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="2"><Text fontSize="18">Enable Player Board</Text></Cell>
			<Cell columnSpan="2">
				<ToggleButton id="Health" colors="#FFFFFF|#06598b|#004ddb" onClick="playerBoardPrepareSection" fontStyle="Bold" isOn="true">Health</ToggleButton>
				<ToggleButton id="Meter" colors="#FFFFFF|#06598b|#004ddb" onClick="playerBoardPrepareSection" fontStyle="Bold">Meter</ToggleButton>
				<ToggleButton id="Power" colors="#FFFFFF|#06598b|#004ddb" onClick="playerBoardPrepareSection" fontStyle="Bold" isOn="true">Power</ToggleButton>
				<ToggleButton id="Move" colors="#FFFFFF|#06598b|#004ddb" onClick="playerBoardPrepareSection" fontStyle="Bold">Move</ToggleButton>
				<ToggleButton id="Chakara" colors="#FFFFFF|#06598b|#004ddb" onClick="playerBoardPrepareSection" fontStyle="Bold">Chakara</ToggleButton>
			</Cell>
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="2"><Text fontSize="18">Reset Table Now!</Text></Cell>
			<Cell columnSpan="2"><Button id="clearTableToggleNow" colors="#FFFFFF|#06598b|#004ddb" onClick="changeToggleUI" fontStyle="Bold">Activate</Button></Cell>
		</Row>
		</TableLayout>
		</VerticalLayout>
		<VerticalLayout  offsetXY="230 -450" height="200" width="460" rectAlignment="UpperCenter" color="#00000000" scrollSensitivity="80">
		<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
		<Row preferredHeight="50">
			<Cell columnSpan="1"><Text fontSize="18">Character Spawners</Text></Cell>		
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="1">
				<Button id="spawnDCCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold">DC</Button>
				<Button id="spawnCrisisCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold">Crisis</Button>
				<Button id="spawnRivalsCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold">Rivals</Button>
				<Button id="spawnRebirthCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold">Rebirth</Button>
			</Cell>
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="1">
				<Button id="spawnLotRCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold" fontSize="13">Lord of the Rings</Button>
				<Button id="spawnCartoonCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold" fontSize="13">Cartoon Network</Button>
				<Button id="spawnRickandMortyCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold">Rick and Morty</Button>
			</Cell>
		</Row>
		<Row preferredHeight="50">
			<Cell columnSpan="1">
				<Button id="spawnESWCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold" fontSize="13">Epic Spell Wars</Button>
				<Button id="spawnGangBangerCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold" fontSize="13">Gang Bangers</Button>
				<Button id="spawnOtherCharacters" colors="#FFFFFF|#06598b|#004ddb" onClick="spawnCharactersUI" fontStyle="Bold">Other</Button>
			</Cell>
		</Row>
		</TableLayout>
		</VerticalLayout>
	</Panel>
	<Panel id="expansionCustomSetup" height="650" width="920" color="#00000000" rectAlignment="LowerCenter" active="false">
		<HorizontalLayout offsetXY="325 -50" width="250" height="45" rectAlignment="UpperCenter">
			<Dropdown id="menuCustomStarters" itemHeight="20" fontSize="14" value="DC Base Set" onValueChanged="optionsCGStarters" color="#828282" itemBackgroundColors="#828282|#C4C4C4" dropdownBackgroundColor="#828282" fontStyle="Bold" textColor="#000000">
				<Option>------Choose Starter Decks-----</Option>
				<Option selected="true">DC Base Set</Option>
				<Option>Heroes United</Option>
				<Option>Forever Evil</Option>
				<Option>Teen Titans</Option>
				<Option>Dark Nights Metal</Option>
				<Option>Injustice</Option>
				<Option>Rivals 1</Option>
				<Option>Rivals 2</Option>
				<Option>Rivals 3</Option>
				<Option>Confrontations</Option>
				<Option>Fellowship of the Ring</Option>
				<Option>The Two Towers</Option>
				<Option>Return of the King</Option>
				<Option>An Unexpected Journey</Option>
				<Option>Crossover Crisis</Option>
				<Option>Animation Annihilation</Option>
				<Option>Teen Titans Go!</Option>
				<Option>Rick and Morty 1</Option>
				<Option>Rick and Morty 2</Option>
				<Option>Street Fighter</Option>
				<Option>Naruto Shippuden</Option>
				<Option>Epic Spell Wars</Option>
				<Option>DC Rebirth</Option>
			</Dropdown>
		</HorizontalLayout>
		<HorizontalLayout offsetXY="325 -110" width="250" height="45" rectAlignment="UpperCenter">
			<Dropdown id="menuCustomKicks" itemHeight="20" fontSize="14" value="DC Base Set" onValueChanged="optionsCGKicks" color="#828282" itemBackgroundColors="#828282|#C4C4C4" dropdownBackgroundColor="#828282" fontStyle="Bold" textColor="#000000">
				<Option>------Choose Kick Stack-----</Option>
				<Option selected="true">DC Base Set</Option>
				<Option>Heroes United</Option>
				<Option>Forever Evil</Option>
				<Option>Teen Titans</Option>
				<Option>Dark Nights Metal</Option>
				<Option>Injustice</Option>
				<Option>Rivals 1</Option>
				<Option>Rivals 2</Option>
				<Option>Rivals 3</Option>
				<Option>Confrontations</Option>
				<Option>Fellowship of the Ring</Option>
				<Option>The Two Towers</Option>
				<Option>Return of the King</Option>
				<Option>An Unexpected Journey</Option>
				<Option>Crossover Crisis</Option>
				<Option>Animation Annihilation</Option>
				<Option>Teen Titans Go!</Option>
				<Option>Rick and Morty 1</Option>
				<Option>Rick and Morty 2</Option>
				<Option>Street Fighter</Option>
				<Option>Naruto Shippuden</Option>
				<Option>Epic Spell Wars</Option>
			</Dropdown>
		</HorizontalLayout>
		<HorizontalLayout offsetXY="325 -170" width="250" height="45" rectAlignment="UpperCenter">
			<Dropdown id="menuCustomWeaknesses" itemHeight="20" fontSize="14" value="DC Base Set" onValueChanged="optionsCGWeaknesses" color="#828282" itemBackgroundColors="#828282|#C4C4C4" dropdownBackgroundColor="#828282" fontStyle="Bold" textColor="#000000">
				<Option>------Choose Weakness Stack-----</Option>
				<Option selected="true">DC Base Set</Option>
				<Option>Heroes United</Option>
				<Option>Forever Evil</Option>
				<Option>Teen Titans</Option>
				<Option>Dark Nights Metal</Option>
				<Option>Injustice</Option>
				<Option>Rivals 1</Option>
				<Option>Rivals 2</Option>
				<Option>Rivals 3</Option>
				<Option>Confrontations</Option>
				<Option>Fellowship of the Ring</Option>
				<Option>The Two Towers</Option>
				<Option>Return of the King</Option>
				<Option>An Unexpected Journey</Option>
				<Option>Cartoon Network + TTG!</Option>
				<Option>Rick and Morty 1</Option>
				<Option>Rick and Morty 2</Option>
				<Option>Street Fighter</Option>
				<Option>Naruto Shippuden</Option>
				<Option>Epic Spell Wars</Option>
				<Option>DC Rebirth</Option>
			</Dropdown>
		</HorizontalLayout>
		<VerticalLayout offsetXY="63 -50" width="260" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="18">Add Crisis Cards</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="yesAddCrisisCG"  onClick="optionsCGAddCrisis">Yes</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="noAddCrisisCG"  onClick="optionsCGAddCrisis" isOn="true">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="18">Add CN Events</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="yesAddEventsCG"  onClick="optionsCGAddEvents">Yes</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="noAddEventsCG"  onClick="optionsCGAddEvents" isOn="true">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="18">Add Naruto Hand Signs</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="yesAddHandssCG"  onClick="optionsCGAddHands">Yes</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="noAddHandsCG"  onClick="optionsCGAddHands" isOn="true">No</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<Panel id="customCharacters" height="650" width="920" rectAlignment="LowerCenter" active="true">
			<VerticalLayout offsetXY="-262 -50" width="375" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
				<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
					<Row preferredHeight="45">
						<Cell columnSpan="1"><Button id="menuCustomBosses"  onClick="customMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Back</Button></Cell>
						<Cell columnSpan="3"><Text fontSize="18">Add Characters</Text></Cell>
						<Cell columnSpan="1"><Button id="menuCustomMain"  onClick="customMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Next</Button></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_DC"  onClick="optionCGCharacter">DC</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_HU"  onClick="optionCGCharacter">HU</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_FE"  onClick="optionCGCharacter">FE</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_TT"  onClick="optionCGCharacter">TT</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_DNM"  onClick="optionCGCharacter">DNM</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_C1"  onClick="optionCGCharacter">C1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_C2"  onClick="optionCGCharacter">C2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_C3"  onClick="optionCGCharacter">C3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_C4"  onClick="optionCGCharacter">C4</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_R1"  onClick="optionCGCharacter">R1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_R2"  onClick="optionCGCharacter">R2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_R3"  onClick="optionCGCharacter">R3</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_RC"  onClick="optionCGCharacter">RC</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO1"  onClick="optionCGCharacter">CO1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO2"  onClick="optionCGCharacter">CO2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO3"  onClick="optionCGCharacter">CO3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO4"  onClick="optionCGCharacter">CO4</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO5"  onClick="optionCGCharacter">CO5</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO6"  onClick="optionCGCharacter">CO6</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO7"  onClick="optionCGCharacter">CO7</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO8"  onClick="optionCGCharacter">CO8</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_CO9"  onClick="optionCGCharacter">CO9</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_RB"  onClick="optionCGCharacter">RB</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_INJ"  onClick="optionCGCharacter">INJ</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_MV"  onClick="optionCGCharacter">MV</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_Promos"  fontSize="17" onClick="optionCGCharacter">Promos</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_FotR"  onClick="optionCGCharacter">FotR</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_2T"  onClick="optionCGCharacter">2T</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_RotK"  onClick="optionCGCharacter">RotK</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_UJ"  onClick="optionCGCharacter">UJ</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_DoS"  onClick="optionCGCharacter">DoS</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_CN"  onClick="optionCGCharacter">CN</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_AA"  onClick="optionCGCharacter">AA</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_TTG"  onClick="optionCGCharacter">TTG</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_RM1"  onClick="optionCGCharacter">RM1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_RM2"  onClick="optionCGCharacter">RM2</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_SF"  onClick="optionCGCharacter">SF</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_NS"  onClick="optionCGCharacter">NS</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_c_EA1"  onClick="optionCGCharacter">EA1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_EGB"  onClick="optionCGCharacter">EGB</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_c_EA2"  onClick="optionCGCharacter">EA2</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="45">
						<Cell columnSpan="5">
							<Button id="scSelectAll"  onClick="optionCGCharactersSelectAll" colors="#FFFFFF|#06598b|#004ddb" fontSize="20" fontStyle="Bold">Select All</Button>
						</Cell>
					</Row>
				</TableLayout>
			</VerticalLayout>
		</Panel>
		<Panel id="customMain" height="650" width="920" rectAlignment="LowerCenter" active="false">
			<VerticalLayout offsetXY="-262 -50" width="375" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
				<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
					<Row preferredHeight="45">
						<Cell columnSpan="1"><Button id="menuCustomCharacters"  onClick="customMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Back</Button></Cell>
						<Cell columnSpan="3"><Text fontSize="18">Add Main Deck</Text></Cell>
						<Cell columnSpan="1"><Button id="menuCustomBosses"  onClick="customMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Next</Button></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_DC"  onClick="optionCGMainDeck">DC</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_HU"  onClick="optionCGMainDeck">HU</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_FE"  onClick="optionCGMainDeck">FE</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_TT"  onClick="optionCGMainDeck">TT</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_DNM"  onClick="optionCGMainDeck">DNM</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_C1"  onClick="optionCGMainDeck">C1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_C2"  onClick="optionCGMainDeck">C2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_C3"  onClick="optionCGMainDeck">C3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_C4"  onClick="optionCGMainDeck">C4</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_R1"  onClick="optionCGMainDeck">R1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_R2"  onClick="optionCGMainDeck">R2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_R3"  onClick="optionCGMainDeck">R3</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_RC"  onClick="optionCGMainDeck">RC</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO1"  onClick="optionCGMainDeck">CO1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO2"  onClick="optionCGMainDeck">CO2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO3"  onClick="optionCGMainDeck">CO3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO4"  onClick="optionCGMainDeck">CO4</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO5"  onClick="optionCGMainDeck">CO5</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO6"  onClick="optionCGMainDeck">CO6</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO7"  onClick="optionCGMainDeck">CO7</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO8"  onClick="optionCGMainDeck">CO8</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_CO9"  onClick="optionCGMainDeck">CO9</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_RB"  onClick="optionCGMainDeck">RB</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_INJ"  onClick="optionCGMainDeck">INJ</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_MV"  onClick="optionCGMainDeck">MV</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_Promos"  fontSize="17" onClick="optionCGMainDeck">Promos</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_FotR"  onClick="optionCGMainDeck">FotR</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_2T"  onClick="optionCGMainDeck">2T</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_RotK"  onClick="optionCGMainDeck">RotK</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_UJ"  onClick="optionCGMainDeck">UJ</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_DoS"  onClick="optionCGMainDeck">DoS</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_CN"  onClick="optionCGMainDeck">CN</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_AA"  onClick="optionCGMainDeck">AA</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_TTG"  onClick="optionCGMainDeck">TTG</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_RM1"  onClick="optionCGMainDeck">RM1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_RM2"  onClick="optionCGMainDeck">RM2</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_SF"  onClick="optionCGMainDeck">SF</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_NS"  onClick="optionCGMainDeck">NS</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_md_EA1"  onClick="optionCGMainDeck">EA1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_EGB"  onClick="optionCGMainDeck">EGB</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_md_EA2"  onClick="optionCGMainDeck">EA2</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="45">
						<Cell columnSpan="5">
							<Button id="scSelectAll"  onClick="optionCGMainDeckSelectAll" colors="#FFFFFF|#06598b|#004ddb" fontSize="20" fontStyle="Bold">Select All</Button>
						</Cell>
					</Row>
				</TableLayout>
			</VerticalLayout>
		</Panel>
		<Panel id="customBosses" height="650" width="920" rectAlignment="LowerCenter" active="false">
			<VerticalLayout offsetXY="-262 -50" width="375" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
				<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
					<Row preferredHeight="45">
						<Cell columnSpan="1"><Button id="menuCustomMain"  onClick="customMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Back</Button></Cell>
						<Cell columnSpan="3"><Text fontSize="18">Add Boss Cards</Text></Cell>
						<Cell columnSpan="1"><Button id="menuCustomCharacters"  onClick="customMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Next</Button></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_DC"  onClick="optionCGBoss">DC</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_HU"  onClick="optionCGBoss">HU</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_FE"  onClick="optionCGBoss">FE</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_TT"  onClick="optionCGBoss">TT</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_DNM"  onClick="optionCGBoss">DNM</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_C1"  onClick="optionCGBoss">C1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_C2"  onClick="optionCGBoss">C2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_C3"  onClick="optionCGBoss">C3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_C4"  onClick="optionCGBoss">C4</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_CO1"  onClick="optionCGBoss">CO1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_CO2"  onClick="optionCGBoss">CO2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_CO3"  onClick="optionCGBoss">CO3</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_CO5"  onClick="optionCGBoss">CO5</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_CO6"  onClick="optionCGBoss">CO6</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_CO7"  onClick="optionCGBoss">CO7</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_CO8"  onClick="optionCGBoss">CO8</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_CO9"  onClick="optionCGBoss">CO9</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_RB"  onClick="optionCGBoss">RB</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_INJ"  onClick="optionCGBoss">INJ</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_MV"  onClick="optionCGBoss">MV</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_im_FotR"  onClick="optionCGBossIM">FotR IM</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_im_2T"  onClick="optionCGBossIM">2T IM</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_im_RotK"  onClick="optionCGBossIM">RotK IM</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_im_UJ"  onClick="optionCGBossIM">UJ IM</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_im_DoS"  onClick="optionCGBossIM">DoS IM</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_FotR"  onClick="optionCGBoss">FotR</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_2T"  onClick="optionCGBoss">2T</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_RotK"  onClick="optionCGBoss">RotK</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_UJ"  onClick="optionCGBoss">UJ</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_DoS"  onClick="optionCGBoss">DoS</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_CN"  onClick="optionCGBoss">CN</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_AA"  onClick="optionCGBoss">AA</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_TTG"  onClick="optionCGBoss">TTG</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_RM1"  onClick="optionCGBoss">RM1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_RM2"  onClick="optionCGBoss">RM2</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_SF"  onClick="optionCGBoss">SF</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_NS"  onClick="optionCGBoss">NS</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="40">
						<Cell columnSpan="1"><ToggleButton id="cg_b_EA1"  onClick="optionCGBoss">EA1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_EGB"  onClick="optionCGBoss">EGB</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="cg_b_EA2"  onClick="optionCGBoss">EA2</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="45">
						<Cell columnSpan="5">
							<Button id="cg_b_SelectAll"  onClick="optionCGBossSelectAll" colors="#FFFFFF|#06598b|#004ddb" fontSize="20" fontStyle="Bold">Select All</Button>
						</Cell>
					</Row>
				</TableLayout>
			</VerticalLayout>
		</Panel>
		<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
			<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Back
			</Button>
			<Button id="gameChoiceCG"  onClick="spawnCustomGame" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Set Up Game
			</Button>
		</HorizontalLayout>
	</Panel>
	<Panel id="expansionSetupBase" height="650" width="920" rectAlignment="LowerCenter" active="false">
		<HorizontalLayout offsetXY="25 -50" width="284" height="45" rectAlignment="UpperCenter">
			<Dropdown id="baseDropdown" itemHeight="20" fontSize="14" value="DC Base Set" onValueChanged="updateGameChoice" color="#828282" itemBackgroundColors="#828282|#C4C4C4" dropdownBackgroundColor="#828282" fontStyle="Bold" textColor="#000000">
				<Option>--------Choose a Base Set-------</Option>
				<Option selected="true">DC Base Set</Option>
				<Option>Heroes United</Option>
				<Option>Forever Evil</Option>
				<Option>Teen Titans</Option>
				<Option>Dark Nights Metal</Option>
				<Option>Injustice</Option>
				<Option>Teen Titans Go!</Option>
			</Dropdown>
		</HorizontalLayout>
		<HorizontalLayout offsetXY="25 -110" height="190" rectAlignment="UpperCenter">
			<Image id="baseRep" image="DCBS" preserveAspect="true"></Image>
		</HorizontalLayout>
		<HorizontalLayout offsetXY="310 -50" width="284" height="45" rectAlignment="UpperCenter">
			<Dropdown id="expansionDropdown" itemHeight="20" fontSize="14" value="Crisis 1" onValueChanged="updateGameChoice" color="#828282" itemBackgroundColors="#828282|#C4C4C4" dropdownBackgroundColor="#828282" fontStyle="Bold" textColor="#000000">
				<Option>------Choose an Expansion Set-----</Option>
				<Option selected="true">Crisis 1</Option>
				<Option>Crisis 2</Option>
				<Option>Crisis 3</Option>
				<Option>Crisis 4</Option>
				<Option>CO1 - Justice Society of America</Option>
				<Option>CO2 - Arrow The Television Series</Option>
				<Option>CO3 - Legion of Super Heroes</Option>
				<Option>CO4 - Watchmen</Option>
				<Option>CO5 - The Rogues</Option>
				<Option>CO6 - Birds of Prey</Option>
				<Option>CO7 - New God</Option>
				<Option>CO8 - Batman Ninja</Option>
				<Option>CO9 - Bombshells</Option>
			</Dropdown>
		</HorizontalLayout>
		<HorizontalLayout offsetXY="310 -110" height="190" rectAlignment="UpperCenter">
			<Image id="expansionRep" image="DCES" preserveAspect="true"></Image>
		</HorizontalLayout>
		<Panel id="expansionMainCards" height="650" width="920" rectAlignment="LowerCenter" active="false">
			<VerticalLayout offsetXY="-285 -50" width="330" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
				<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
					<Row preferredHeight="50">
						<Cell columnSpan="1"><Button id="menuC"  onClick="dceMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Back</Button></Cell>
						<Cell columnSpan="3"><Text fontSize="18">Add Main Deck Cards</Text></Cell>
						<Cell columnSpan="1"><Button id="menuC"  onClick="dceMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Next</Button></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="mdDC"  onClick="optionDCEMainDeck">DC</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdHU"  onClick="optionDCEMainDeck">HU</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdFE"  onClick="optionDCEMainDeck">FE</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdTT"  onClick="optionDCEMainDeck">TT</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdDNM"  onClick="optionDCEMainDeck">DNM</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="mdC1"  onClick="optionDCEMainDeck">C1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdC2"  onClick="optionDCEMainDeck">C2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdC3"  onClick="optionDCEMainDeck">C3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdC4"  onClick="optionDCEMainDeck">C4</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="mdCO1"  onClick="optionDCEMainDeck">CO1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdCO2"  onClick="optionDCEMainDeck">CO2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdCO3"  onClick="optionDCEMainDeck">CO3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdCO4"  onClick="optionDCEMainDeck">CO4</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdCO5"  onClick="optionDCEMainDeck">CO5</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="mdCO6"  onClick="optionDCEMainDeck">CO6</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdCO7"  onClick="optionDCEMainDeck">CO7</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdCO8"  onClick="optionDCEMainDeck">CO8</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdCO9"  onClick="optionDCEMainDeck">CO9</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="mdRB"  onClick="optionDCEMainDeck">RB</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdINJ"  onClick="optionDCEMainDeck">INJ</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"><ToggleButton id="mdTTG"  onClick="optionDCEMainDeck">TTG</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="5">
							<Button id="mdSelectAll"  onClick="optionDCEMainDeckSelectAll" colors="#FFFFFF|#06598b|#004ddb" fontSize="20" fontStyle="Bold">Select All</Button>
						</Cell>
					</Row>
				</TableLayout>
			</VerticalLayout>
		</Panel>
		<Panel id="expansionCharacters" height="650" width="920" rectAlignment="LowerCenter" active="true">
			<VerticalLayout offsetXY="-285 -50" width="330" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
				<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
					<Row preferredHeight="50">
						<Cell columnSpan="1"><Button id="menuMD"  onClick="dceMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Back</Button></Cell>
						<Cell columnSpan="3"><Text fontSize="18">Add Characters</Text></Cell>
						<Cell columnSpan="1"><Button id="menuMD"  onClick="dceMenuSwitch" colors="#FFFFFF|#06598b|#004ddb" fontSize="18" fontStyle="Bold">Next</Button></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="scDC"  onClick="optionDCECharacter">DC</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scHU"  onClick="optionDCECharacter">HU</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scFE"  onClick="optionDCECharacter">FE</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scTT"  onClick="optionDCECharacter">TT</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scDNM"  onClick="optionDCECharacter">DNM</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="scC1"  onClick="optionDCECharacter">C1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scC2"  onClick="optionDCECharacter">C2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scC3"  onClick="optionDCECharacter">C3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scC4"  onClick="optionDCECharacter">C4</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="scCO1"  onClick="optionDCECharacter">CO1</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scCO2"  onClick="optionDCECharacter">CO2</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scCO3"  onClick="optionDCECharacter">CO3</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scCO4"  onClick="optionDCECharacter">CO4</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scCO5"  onClick="optionDCECharacter">CO5</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="scCO6"  onClick="optionDCECharacter">CO6</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scCO7"  onClick="optionDCECharacter">CO7</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scCO8"  onClick="optionDCECharacter">CO8</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scCO9"  onClick="optionDCECharacter">CO9</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="1"><ToggleButton id="scRB"  onClick="optionDCECharacter">RB</ToggleButton></Cell>
						<Cell columnSpan="1"><ToggleButton id="scINJ"  onClick="optionDCECharacter">INJ</ToggleButton></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"></Cell>
						<Cell columnSpan="1"><ToggleButton id="scTTG"  onClick="optionDCECharacter">TTG</ToggleButton></Cell>
					</Row>
					<Row preferredHeight="50">
						<Cell columnSpan="5">
							<Button id="scSelectAll"  onClick="optionDCECharacterSelectAll" colors="#FFFFFF|#06598b|#004ddb" fontSize="20" fontStyle="Bold">Select All</Button>
						</Cell>
					</Row>
				</TableLayout>
			</VerticalLayout>
		</Panel>
		<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
			<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Back
			</Button>
			<Button id="gameChoice"  onClick="spawnGameChoice" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Set Up Game
			</Button>
		</HorizontalLayout>
	</Panel>
	<Panel id="expansionSetupRivals" height="650" width="920" rectAlignment="LowerCenter" active="false">
		<VerticalLayout offsetXY="-290 -50" width="320" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="16">Main Deck and Characters</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="isR1_H"  onClick="optionsRivalsCharacters">Batman</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="isR1_V"  onClick="optionsRivalsCharacters">The Joker</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="isR2_H"  onClick="optionsRivalsCharacters">Green Lantern</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="isR2_V"  onClick="optionsRivalsCharacters">Sinestro</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="isR3_H"  onClick="optionsRivalsCharacters">Flash</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="isR3_V"  onClick="optionsRivalsCharacters">Reverse-Flash</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="isRC_S"  onClick="optionsRivalsCharacters">Superman</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="isRC_L"  onClick="optionsRivalsCharacters">Lex Luthor</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="isRC_W"  onClick="optionsRivalsCharacters">Wonder Woman</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="isRC_C"  onClick="optionsRivalsCharacters">Circe</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="isRC_A"  onClick="optionsRivalsCharacters">Aquaman</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="isRC_O"  onClick="optionsRivalsCharacters">Ocean Master</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="isRC_Z"  onClick="optionsRivalsCharacters">Zatana Zatara</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="isRC_F"  onClick="optionsRivalsCharacters">Felix Faust</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2">
						<Button id="rivalSelectAll"  onClick="optionRivalsSelectAll" colors="#FFFFFF|#06598b|#004ddb" fontSize="20" fontStyle="Bold">Select All</Button>
					</Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="-40 -50" width="180" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="16">Starter Decks</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="rivialsStarterR1"  onClick="optionsRivalsStarters">R1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="rivialsStarterR2"  onClick="optionsRivalsStarters">R2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="rivialsStarterR3"  onClick="optionsRivalsStarters">R3</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="rivialsStarterRC"  onClick="optionsRivalsStarters" isOn="true">RC</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="16">Weakness Stack</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="rivalsWeaknessR1"  onClick="optionsRivalsWeakness">R1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="rivalsWeaknessR2"  onClick="optionsRivalsWeakness">R2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="rivalsWeaknessR3"  onClick="optionsRivalsWeakness" isOn="true">R3</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="rivalsWeaknessRC"  onClick="optionsRivalsWeakness">RC</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="16">Rule Books</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesRulesRivals" onClick="optionsRivalsRules">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noRulesRivals" onClick="optionsRivalsRules" isOn="true">No</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="130 -50" width="160" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="16">Kick Amount</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="ka8"  onClick="optionsRivalsAmounts" isOn="true">8</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="ka16"  onClick="optionsRivalsAmounts">16</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="16">Weakness Amount</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="wa10"  onClick="optionsRivalsAmounts" isOn="true">10</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="wa20"  onClick="optionsRivalsAmounts">20</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="330 -50" width="240" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="1"><Text fontSize="16">Kick Stack</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="rivalsKickR1"  onClick="optionsRivalsKicks">R1 - Kick</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="rivalsKickR2"  onClick="optionsRivalsKicks" isOn="true">R2 - Hard-Light Construct</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="rivalsKickR3"  onClick="optionsRivalsKicks">R3 - Super-Speed</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="rivalsKickRC"  onClick="optionsRivalsKicks">RC - Enhanced Strength</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
			<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Back
			</Button>
			<Button id="gameChoice"  onClick="setupRivalGame" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Set Up Game
			</Button>
		</HorizontalLayout>
	</Panel>
	<Panel id="expansionSetupMultiverse" height="650" width="920" rectAlignment="LowerCenter" active="false">
		<VerticalLayout offsetXY="-285 -50" width="330" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="5"><Text fontSize="16">Remove Sets from Multiverse</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvDC"  onClick="optionMultiverseSets">DC</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvHU"  onClick="optionMultiverseSets">HU</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvFE"  onClick="optionMultiverseSets">FE</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvTT"  onClick="optionMultiverseSets">TT</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvDNM"  onClick="optionMultiverseSets">DNM</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvC1"  onClick="optionMultiverseSets">C1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvC2"  onClick="optionMultiverseSets">C2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvC3"  onClick="optionMultiverseSets">C3</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvC4"  onClick="optionMultiverseSets">C4</ToggleButton></Cell>
					<Cell columnSpan="1"></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvCO1"  onClick="optionMultiverseSets">CO1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvCO2"  onClick="optionMultiverseSets">CO2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvCO3"  onClick="optionMultiverseSets">CO3</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvCO4"  onClick="optionMultiverseSets">CO4</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvCO5"  onClick="optionMultiverseSets">CO5</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvCO6"  onClick="optionMultiverseSets">CO6</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvCO7"  onClick="optionMultiverseSets">CO7</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvCO8"  onClick="optionMultiverseSets">CO8</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvCO9"  onClick="optionMultiverseSets">CO9</ToggleButton></Cell>
					<Cell columnSpan="1"></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvR1"  onClick="optionMultiverseSets">R1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvR2"  onClick="optionMultiverseSets">R2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvR3"  onClick="optionMultiverseSets">R3</ToggleButton></Cell>
					<Cell columnSpan="1"></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvRC"  onClick="optionMultiverseSets">RC</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvRB"  onClick="optionMultiverseSets">RB</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvINJ"  onClick="optionMultiverseSets">INJ</ToggleButton></Cell>
					<Cell columnSpan="1"></Cell>
					<Cell columnSpan="1"></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvTTG"  onClick="optionMultiverseSets">TTG</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<HorizontalLayout offsetXY="45 -50" width="280" height="45" rectAlignment="UpperCenter">
			<Dropdown id="multiverseDropdown" itemHeight="20" fontSize="14" value="DC Base Set" onValueChanged="updateMultiverseChoice" color="#828282" itemBackgroundColors="#828282|#C4C4C4" dropdownBackgroundColor="#828282" fontStyle="Bold" textColor="#000000">
				<Option>--------Choose a Base Set-------</Option>
				<Option selected="true">DC Base Set</Option>
				<Option>Heroes United</Option>
				<Option>Forever Evil</Option>
				<Option>Teen Titans</Option>
				<Option>Dark Nights Metal</Option>
				<Option>Injustice</Option>
				<Option>Confrontations</Option>
			</Dropdown>
		</HorizontalLayout>
		<HorizontalLayout offsetXY="45 -110" height="190" rectAlignment="UpperCenter">
			<Image id="multiverseRep" image="DCBS" preserveAspect="true"></Image>
		</HorizontalLayout>
		<VerticalLayout offsetXY="330 -50" width="240" color="#00000000" scrollSensitivity="80" rectAlignment="UpperCenter">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="16">Game Mode</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvStandard"  onClick="optionMultiverse" isOn="true">Standard</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvImpossible"  onClick="optionMultiverse">Impossible</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="16">Game Length</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvLengthStandard"  onClick="optionMultiverse" isOn="true">Standard</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvLengthShort"  onClick="optionMultiverse">Short</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="16">Add Crisis on Infinite Earths</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mvInfiniteYes"  onClick="optionMultiverse">Yes</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mvInfiniteNo"  onClick="optionMultiverse" isOn="true">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="14">Chat Command !mv for Bizzaro World, and Vanishing Point</Text></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
			<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Back
			</Button>
			<Button id="multiverseChoice"  onClick="setupMultiverse" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Set Up Game
			</Button>
		</HorizontalLayout>
	</Panel>
	<Panel id="expansionSetupLotR" height="650" width="600" rectAlignment="LowerCenter" active="false">
		<VerticalLayout offsetXY="-300 -50" width="300" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="5"><Text fontSize="18">Remove Main Characters</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="cLOTR_FotR" onClick="optionsLOTRRemoveCharacter">FotR</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cLOTR_2T" onClick="optionsLOTRRemoveCharacter">2T</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cLOTR_RotK" onClick="optionsLOTRRemoveCharacter">RotK</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cLOTR_UJ" onClick="optionsLOTRRemoveCharacter">UJ</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cLOTR_DoS" onClick="optionsLOTRRemoveCharacter">DoS</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="5"><Text fontSize="18">Remove Main Deck Cards</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="mainLOTR_FotR" onClick="optionsLOTRRemoveMain">FotR</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mainLOTR_2T" onClick="optionsLOTRRemoveMain">2T</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mainLOTR_RotK" onClick="optionsLOTRRemoveMain">RotK</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mainLOTR_UJ" onClick="optionsLOTRRemoveMain">UJ</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="mainLOTR_DoS" onClick="optionsLOTRRemoveMain">DoS</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="5"><Text fontSize="18">Remove Bosses</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="bLOTR_FotR" onClick="optionsLOTRRemoveBoss">FotR</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="bLOTR_2T" onClick="optionsLOTRRemoveBoss">2T</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="bLOTR_RotK" onClick="optionsLOTRRemoveBoss">RotK</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="bLOTR_UJ" onClick="optionsLOTRRemoveBoss">UJ</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="bLOTR_DoS" onClick="optionsLOTRRemoveBoss">DoS</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="0 -50" width="260" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Rule Books</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesRulesLotR" onClick="optionsLOTRrules">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noRulesLotR" onClick="optionsLOTRrules" isOn="true">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include DoS Corruptions</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesDoSLotR" onClick="optionsLOTRCorruptionDoS" isOn="true">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noDoSLotR" onClick="optionsLOTRCorruptionDoS">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Impossible Mode</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="impossibleToggleON-LotR" onClick="optionImpossibleMode">On</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="impossibleToggleOFF-LotR" onClick="optionImpossibleMode" isOn="true">Off</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="300 -50" width="300" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Select Starters</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="idStarterLOTR_FotR" onClick="optionsLOTRStarters" isOn="true">FotR</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idStarterLOTR_2T" onClick="optionsLOTRStarters">2T</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idStarterLOTR_RotK" onClick="optionsLOTRStarters">RotK</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idStarterLOTR_UJ" onClick="optionsLOTRStarters">UJ</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Select Corruptions</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="idCorruptionLOTR_FotR" onClick="optionsLOTRCorruption" isOn="true">FotR</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idCorruptionLOTR_2T" onClick="optionsLOTRCorruption">2T</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idCorruptionLOTR_RotK" onClick="optionsLOTRCorruption">RotK</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idCorruptionLOTR_UJ" onClick="optionsLOTRCorruption">UJ</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Select Valors</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="idValorLOTR_FotR" onClick="optionsLOTRValor" isOn="true">FotR</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idValorLOTR_2T" onClick="optionsLOTRValor">2T</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idValorLOTR_RotK" onClick="optionsLOTRValor">RotK</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="idValorLOTR_UJ" onClick="optionsLOTRValor">UJ</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
			<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Back
			</Button>
			<Button id="gameChoice"  onClick="setupLotR" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Set Up Game
			</Button>
		</HorizontalLayout>
	</Panel>
	<Panel id="expansionSetupCN" height="650" width="600" rectAlignment="LowerCenter" active="false">
		<VerticalLayout offsetXY="-300 -50" width="300" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Remove Main Characters</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="cartoonCharacterCN" onClick="optionsCartoonRemoveCharacter">CN</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonCharacterAA" onClick="optionsCartoonRemoveCharacter">AA</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonCharacterTTG" onClick="optionsCartoonRemoveCharacter">TTG</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Remove Main Deck Cards</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="cartoonMainCN" onClick="optionsCartoonRemoveMain">CN</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonMainAA" onClick="optionsCartoonRemoveMain">AA</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonMainTTG" onClick="optionsCartoonRemoveMain">TTG</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Remove Nemesis Cards</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="cartoonNemesisCN" onClick="optionsCartoonRemoveNemesis">CN</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonNemesisAA" onClick="optionsCartoonRemoveNemesis">AA</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonNemesisTTG" onClick="optionsCartoonRemoveNemesis">TTG</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Remove Weakness Cards</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="cartoonWeaknessCN" onClick="optionsCartoonRemoveWeakness">CN</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonWeaknessAA" onClick="optionsCartoonRemoveWeakness">AA</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonWeaknessTTG" onClick="optionsCartoonRemoveWeakness">TTG</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="0 -50" width="260" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Rule Books</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesRulesCartoon" onClick="optionsCartoonRules">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noRulesCartoon" onClick="optionsCartoonRules" isOn="true">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Events</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesEventsCartoon" onClick="optionsCartoonEvents" isOn="true">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noEventsCartoon" onClick="optionsCartoonEvents">No</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="300 -50" width="300" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Select Starters</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="cartoonStarterCN" onClick="optionsCartoonRemoveStarter" isOn="true">CN</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonStarterAA" onClick="optionsCartoonRemoveStarter">AA</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="cartoonStarterTTG" onClick="optionsCartoonRemoveStarter">TTG</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="300 -150" width="300" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="18">Select Inside Jokes</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="jokeCN" onClick="optionsCartoonJoke" isOn="true">CN</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="jokeAA" onClick="optionsCartoonJoke">AA</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="18">Include Titans Go! Stack?</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="yesStackTG" onClick="optionsCartoonTTG" isOn="true">Yes</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="noStackTG" onClick="optionsCartoonTTG">No</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
	<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
		<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
		Back
		</Button>
		<Button id="gameChoice"  onClick="setupCartoon" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
		Set Up Game
		</Button>
	</HorizontalLayout>
	</Panel>
	<Panel id="expansionSetupRickMorty" height="650" width="600" rectAlignment="UpperCenter" active="false">
		<VerticalLayout offsetXY="-300 170" width="300" color="#00000000">
			<Image image="RM1" preserveAspect="true"></Image>
		</VerticalLayout>
		<VerticalLayout offsetXY="-300 -40" width="300" color="#00000000">
			<Image image="RM2" preserveAspect="true"></Image>
		</VerticalLayout>
		<VerticalLayout offsetXY="0 -50" width="260" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Rule Books</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesRulesRickMorty" onClick="optionsRickMortyRules">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noRulesRickMorty" onClick="optionsRickMortyRules" isOn="true">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Council Cards</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesCouncil" onClick="optionsRickMortyCouncil" isOn="true">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noCouncil" onClick="optionsRickMortyCouncil">No</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="300 -50" width="300" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="18">Select Starters</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="rmcStarterRM1" onClick="optionsRickMortyStarter" isOn="true">RM1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="rmcStarterRM2" onClick="optionsRickMortyStarter">RM2</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><Text fontSize="18">Select Morty Waves</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="rmcMortyWavesRM1" onClick="optionsRickMortyWeakness" isOn="true">RM1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="rmcMortyWavesRM2" onClick="optionsRickMortyWeakness">RM2</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
	<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
		<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
		Back
		</Button>
		<Button id="gameChoice"  onClick="setupRickMorty" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
		Set Up Game
		</Button>
	</HorizontalLayout>
	</Panel>
	<Panel id="expansionSetupESW" height="650" width="600" rectAlignment="LowerCenter" active="false">
		<VerticalLayout offsetXY="-300 -50" width="300" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Remove Dead Wizard Tokens</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="esw_dwt_EA1" onClick="optionsESWRemoveDWT">EA1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="esw_dwt_EA2" onClick="optionsESWRemoveDWT">EA2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="esw_dwt_EGB" onClick="optionsESWRemoveDWT">EGB</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Remove Legend Stacks</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="esw_legends_EA1" onClick="optionsESWRemoveLegends">EA1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="esw_legends_EA2" onClick="optionsESWRemoveLegends">EA2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="esw_legends_EGB" onClick="optionsESWRemoveLegends">EGB</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Remove Mayhems!</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="esw_mayhem_EA1" onClick="optionsESWRemoveMayhems">EA1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="esw_mayhem_EA2" onClick="optionsESWRemoveMayhems">EA2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="esw_mayhem_EGB" onClick="optionsESWRemoveMayhems" isOn="true">EGB</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="3"><Text fontSize="18">Remove Trophy Standee</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="1"><ToggleButton id="esw_trophy_EA1" onClick="optionsESWRemovStandee">EA1</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="esw_trophy_EA2" onClick="optionsESWRemovStandee">EA2</ToggleButton></Cell>
					<Cell columnSpan="1"><ToggleButton id="esw_trophy_EGB" onClick="optionsESWRemovStandee">EGB</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="0 -50" width="260" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Remove Main Deck</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="esw_MD_EA1" onClick="optionsESWRemoveMD">EA1</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="esw_MD_EA2" onClick="optionsESWRemoveMD">EA2</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Rule Books</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesRulesESW" onClick="optionsESWrules">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noRulesESW" onClick="optionsESWrules" isOn="true">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Gang Bangers</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesGangBangers" onClick="optionsGangBangers">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noGangBangers" onClick="optionsGangBangers" isOn="true">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include ESW Volunteer Promos</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesESWPromo" onClick="optionsESWPromo">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noESWPromo" onClick="optionsESWPromo" isOn="true">No</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
		<VerticalLayout offsetXY="300 -50" width="300" color="#00000000" scrollSensitivity="80">
			<TableLayout cellSpacing="0" autoCalculateHeight="1" rectAlignment="UpperCenter" rowBackgroundColor="#06598b">
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Remove Abilities</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="esw_ability_EA1" onClick="optionsESWRemoveAbility">EA1</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="esw_ability_EA2" onClick="optionsESWRemoveAbility">EA2</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Basic Wand</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesESWWand" onClick="optionsESWWand" isOn="true">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noESWWand" onClick="optionsESWWand">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Cheese Wand</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesESWCheese" onClick="optionsESWCheese" isOn="true">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noESWCheese" onClick="optionsESWCheese">No</ToggleButton></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="4"><Text fontSize="18">Include Blasting Glyph</Text></Cell>
				</Row>
				<Row preferredHeight="50">
					<Cell columnSpan="2"><ToggleButton id="yesESWBlasting" onClick="optionsESWBlasting" isOn="true">Yes</ToggleButton></Cell>
					<Cell columnSpan="2"><ToggleButton id="noESWBlasting" onClick="optionsESWBlasting">No</ToggleButton></Cell>
				</Row>
			</TableLayout>
		</VerticalLayout>
	<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
		<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
		Back
		</Button>
		<Button id="gameChoice"  onClick="setupESW" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
		Set Up Game
		</Button>
	</HorizontalLayout>
	</Panel>
	<Panel id="expansionSetupGangBangers" height="650" width="920" rectAlignment="LowerCenter" active="false">
		<HorizontalLayout offsetXY="-225 -160" height="280" rectAlignment="UpperCenter">
			<Image id="baseRepESW" image="EGB" preserveAspect="true"></Image>
		</HorizontalLayout>
		<HorizontalLayout offsetXY="225 -100" width="360" height="45" rectAlignment="UpperCenter">
			<Dropdown id="gangbangersDropdown" itemHeight="20" fontSize="14" value="ANNIHILAGEDDON" onValueChanged="updateGameChoiceESW" color="#828282" itemBackgroundColors="#828282|#C4C4C4" dropdownBackgroundColor="#828282" fontStyle="Bold" textColor="#000000">
				<Option>------Choose a Core Set-----</Option>
				<Option selected="true">ANNIHILAGEDDON</Option>
				<Option>ANNIHILAGEDDON 2 - Xtreme Nacho Legends</Option>
			</Dropdown>
		</HorizontalLayout>
		<HorizontalLayout offsetXY="225 -160" height="280" rectAlignment="UpperCenter">
			<Image id="expansionRepESW" image="EGB" preserveAspect="true"></Image>
		</HorizontalLayout>
		<HorizontalLayout spacing="1" offsetXY="0 5" width="900" height="75" rectAlignment="LowerCenter">
			<Button id="clickCustomBack"  onClick="quickGamesClicked" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Back
			</Button>
			<Button id="gameChoice"  onClick="setupGangBangers" colors="#FFFFFF|#06598b|#004ddb" resizeTextForBestFit="True" fontStyle="Bold">
			Set Up Game
			</Button>
		</HorizontalLayout>
	</Panel>
</Panel>
<Panel id="tuckEndTurnContainer" rectAlignment="UpperCenter" offsetXY="0 -90" width="240" height="40" allowDragging="false" color="#00000000" active="true" visibility="">
    <Button
        id="tuckEndTurnButton"
        onClick="tuckRightmostMainLineupAndEndTurn"
        width="360"
        height="60"
        color="#FFFFFF"
        outline="true"
        outlineSize="10"
        fontSize="18"
        fontStyle="Bold"
        textColor="#000000"
        text="Recolher e Passar Turno"
        active="true"/>
</Panel>
