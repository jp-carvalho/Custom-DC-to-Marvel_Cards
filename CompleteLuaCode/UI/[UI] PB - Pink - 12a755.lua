<Defaults>
  <Button onClick="Global/playerBoardClicked" colors="#06598b|#06598b|#06598b|#06598b" textColor="#FFFFFF" fontStyle="Bold"/>
  <Text fontSize="20" color="#FFFFFF" Outline="Black" fontStyle="Bold"/>
  <Panel  scale="0.5 0.5" rotation="0 0 0"/>
</Defaults>

<Panel id="textPanel" position="0 0 -10" height="200" width="200">
	<VerticalLayout offsetXY="-60 80">
			<Text id="Pink_Health_Text" active="false" text="Vida"></Text>
	</VerticalLayout>
	<VerticalLayout offsetXY="-60 45">
			<Text id="Pink_Meter_Text" active="false" text="Meter"></Text>
	</VerticalLayout>
	<VerticalLayout offsetXY="-60 10">
			<Text id="Pink_Power_Text" active="false" text="Poder"></Text>
	</VerticalLayout>
	<VerticalLayout offsetXY="-60 -25">
			<Text id="Pink_Move_Text" active="false" text="Move"></Text>
	</VerticalLayout>
	<VerticalLayout offsetXY="-60 -60">
			<Text id="Pink_Chakara_Text" active="false" text="Chakara"></Text>
	</VerticalLayout>
</Panel>
<Panel id="numberPanel" position="0 0 -10" height="20" width="50">
	<VerticalLayout offsetXY="60 80">
			<Button id="Pink_Health_Number" height="20" width="20" active="false" Outline="Black">20</Button>
	</VerticalLayout>
	<VerticalLayout offsetXY="60 45">
			<Button id="Pink_Meter_Number" height="20" width="20" active="false" Outline="Black">0</Button>
	</VerticalLayout>
	<VerticalLayout offsetXY="60 10">
			<Button id="Pink_Power_Number" height="20" width="20" active="false" Outline="Black">0</Button>
	</VerticalLayout>
	<VerticalLayout offsetXY="60 -25">
			<Button id="Pink_Move_Number" height="20" width="20" active="false" Outline="Black">0</Button>
	</VerticalLayout>
	<VerticalLayout offsetXY="60 -60">
			<Button id="Pink_Chakara_Number" height="20" width="20" active="false" Outline="Black">0</Button>
	</VerticalLayout>
</Panel>