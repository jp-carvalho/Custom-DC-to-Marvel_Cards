<Defaults>
  <Button onClick="Global/playerBoardClicked" colors="#06598b|#06598b|#06598b|#06598b" textColor="#FFFFFF" fontStyle="Bold"/>
  <Text fontSize="20" color="#FFFFFF" Outline="Black" fontStyle="Bold"/>
  <Panel  scale="0.5 0.5" rotation="0 0 0"/>
</Defaults>

<Panel id="textPanel" position="0 0 -10" height="200" width="200">
	<VerticalLayout offsetXY="-60 80">
			<Text id="Yellow_Health_Text" active="false" text="Vida"></Text>
	</VerticalLayout>
	<VerticalLayout offsetXY="-60 45">
			<Text id="Yellow_Meter_Text" active="false" text="Meter"></Text>
	</VerticalLayout>
	<VerticalLayout offsetXY="-60 10">
			<Text id="Yellow_Power_Text" active="false" text="Poder"></Text>
	</VerticalLayout>
	<VerticalLayout offsetXY="-60 -25">
			<Text id="Yellow_Move_Text" active="false" text="Move"></Text>
	</VerticalLayout>
	<VerticalLayout offsetXY="-60 -60">
			<Text id="Yellow_Chakara_Text" active="false" text="Chakara"></Text>
	</VerticalLayout>
</Panel>
<Panel id="numberPanel" position="0 0 -10" height="20" width="50">
	<VerticalLayout offsetXY="60 80">
			<Button id="Yellow_Health_Number" height="20" width="20" active="false" Outline="Black">20</Button>
	</VerticalLayout>
	<VerticalLayout offsetXY="60 45">
			<Button id="Yellow_Meter_Number" height="20" width="20" active="false" Outline="Black">0</Button>
	</VerticalLayout>
	<VerticalLayout offsetXY="60 10">
			<Button id="Yellow_Power_Number" height="20" width="20" active="false" Outline="Black">0</Button>
	</VerticalLayout>
	<VerticalLayout offsetXY="60 -25">
			<Button id="Yellow_Move_Number" height="20" width="20" active="false" Outline="Black">0</Button>
	</VerticalLayout>
	<VerticalLayout offsetXY="60 -60">
			<Button id="Yellow_Chakara_Number" height="20" width="20" active="false" Outline="Black">0</Button>
	</VerticalLayout>
</Panel>