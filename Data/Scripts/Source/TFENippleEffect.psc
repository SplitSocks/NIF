Scriptname TFENippleEffect extends ActiveMagicEffect 

GlobalVariable Property TFEMaxNippleSize Auto
GlobalVariable Property TFEMinNippleSize Auto
 
import NiOverride
String Property MyKey = "TransformativeElixirs.esp" Auto

actor property mySelf auto
string property IncreaseOrDecrease auto

Event OnEffectFinish(Actor Target, Actor Caster)
	UnregisterForUpdate()
endEvent
 
Event OnEffectStart(Actor Target, Actor Caster)
	float changeAmount = GetDelta()
	
	ApplyTransform(Target, changeAmount, true)
	UnregisterForUpdate()
	Dispel()
	
endEvent


Function ApplyTransform(Actor akActor, float delta, bool isFemale)
	string npcName = akActor.GetBaseObject().GetName()

	float node1CurrentValue = 0.0
	float node2CurrentValue = 0.0
	float node3CurrentValue = 0.0
	int chooseFirstNode = Utility.RandomInt()
	int chooseSecondNode = -1
	int chooseThirdNode = -1
	string node1Name = ""
	string node2Name = ""
	string node3Name = ""
	float node1NewValue = 0.0
	float node2NewValue = 0.0
	float node3NewValue = 0.0
	
	If IncreaseOrDecrease == "Increase"
		; choose node 1
		If chooseFirstNode >= 0 && chooseFirstNode < 23
			node1Name = "NippleTip"
		ElseIf chooseFirstNode >= 23 && chooseFirstNode < 46
			node1Name = "NippleLength"
		ElseIf chooseFirstNode >= 46 && chooseFirstNode < 69 ; nice
			node1Name = "AreolaSize"
		ElseIf chooseFirstNode >= 69 && chooseFirstNode < 92
			node1Name = "NippleSize"
		Else
			node1Name = "AreolaSize"
		EndIf
		
		; choose node 2
		If chooseFirstNode >= 92
			chooseSecondNode = Utility.RandomInt()
			If chooseSecondNode >= 0 && chooseSecondNode < 34
				node2Name = "NippleSize"
			ElseIf chooseSecondNode >= 34 && chooseSecondNode < 67
				node2Name = "NippleTip"
			ElseIf chooseSecondNode >= 67
				node2Name = "NippleLength"
			EndIf
		EndIf
		
		; choose node 3
		If chooseFirstNode >= 97
			chooseThirdNode = Utility.RandomInt()
			If node2Name == "NippleSize"
				If chooseThirdNode < 50
					node3Name = "NippleTip"
				Else
					node3Name = "NippleLength"
				EndIf
			ElseIf node2Name == "NippleTip"
				If chooseThirdNode < 50
					node3Name = "NippleSize"
				Else
					node3Name = "NippleLength"
				EndIf
			ElseIf node2Name == "NippleLength"
				If chooseThirdNode < 50
					node3Name = "NippleSize"
				Else
					node3Name = "NippleTip"
				EndIf
			EndIf
		EndIf
		
		; get current node 1 value and apply delta
		node1CurrentValue = NiOverride.GetMorphValue(akActor, node1Name)
		NiOverride.ClearMorphValue(akActor, node1Name)
		node1NewValue = node1CurrentValue + delta
		If node1Name == "NippleLength" || node1Name == "NippleTip"
			NiOverride.SetMorphValue(akActor, node1Name, PapyrusUtil.ClampFloat(node1NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
		Else
			NiOverride.SetMorphValue(akActor, node1Name, PapyrusUtil.ClampFloat(node1NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
		EndIf
		
		If akActor == mySelf
			Debug.Notification("Your " + node1Name + " rapidly expands! (+" + delta + ")")
		Else
			Debug.Notification(npcName + "'s " + node1Name + " rapidly expands! (+" + delta + ")")
		EndIf

		
		
		; get current node 2 value and apply delta if node 2 is not null
		If chooseSecondNode != -1
			node2CurrentValue = NiOverride.GetMorphValue(akActor, node2Name)
			NiOverride.ClearMorphValue(akActor, node2Name)
			node2NewValue = node2CurrentValue + delta
			If node2Name == "NippleLength" || node2Name == "NippleTip"
				NiOverride.SetMorphValue(akActor, node2Name, PapyrusUtil.ClampFloat(node2NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
			Else
				NiOverride.SetMorphValue(akActor, node2Name, PapyrusUtil.ClampFloat(node2NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
			EndIf
						
			If akActor == mySelf
				Debug.Notification("Your " + node2Name + " rapidly expands! (+" + delta + ")")
			Else
				Debug.Notification(npcName + "'s " + node2Name + " rapidly expands! (+" + delta + ")")
			EndIf
		EndIf
		
		; get current node 3 value and apply delta if node 3 is not null
		If chooseThirdNode != -1
			node3CurrentValue = NiOverride.GetMorphValue(akActor, node3Name)
			NiOverride.ClearMorphValue(akActor, node3Name)
			node3NewValue = node3CurrentValue + delta
			If node3Name == "NippleLength" || node3Name == "NippleTip"
				NiOverride.SetMorphValue(akActor, node3Name, PapyrusUtil.ClampFloat(node3NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
			Else
				NiOverride.SetMorphValue(akActor, node3Name, PapyrusUtil.ClampFloat(node3NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
			EndIf
			
			If akActor == mySelf
				Debug.Notification("Your " + node3Name + " rapidly expands! (+" + delta + ")")
			Else
				Debug.Notification(npcName + "'s " + node3Name + " rapidly expands! (+" + delta + ")")
			EndIf
		EndIf
	Else
		; choose node 1
		If chooseFirstNode >= 0 && chooseFirstNode < 23
			node1Name = "NippleTip"
		ElseIf chooseFirstNode >= 23 && chooseFirstNode < 46
			node1Name = "NippleLength"
		ElseIf chooseFirstNode >= 46 && chooseFirstNode < 69 ; nice
			node1Name = "AreolaSize"
		ElseIf chooseFirstNode >= 69 && chooseFirstNode < 92
			node1Name = "NippleSize"
		Else
			node1Name = "AreolaSize"
		EndIf
		
		; choose node 2
		If chooseFirstNode >= 92
			chooseSecondNode = Utility.RandomInt()
			If chooseSecondNode >= 0 && chooseSecondNode < 34
				node2Name = "NippleSize"
			ElseIf chooseSecondNode >= 34 && chooseSecondNode < 67
				node2Name = "NippleTip"
			ElseIf chooseSecondNode >= 67
				node2Name = "NippleLength"
			EndIf
		EndIf
		
		; choose node 3
		If chooseFirstNode >= 97
			chooseThirdNode = Utility.RandomInt()
			If node2Name == "NippleSize"
				If chooseThirdNode < 50
					node3Name = "NippleTip"
				Else
					node3Name = "NippleLength"
				EndIf
			ElseIf node2Name == "NippleTip"
				If chooseThirdNode < 50
					node3Name = "NippleSize"
				Else
					node3Name = "NippleLength"
				EndIf
			ElseIf node2Name == "NippleLength"
				If chooseThirdNode < 50
					node3Name = "NippleSize"
				Else
					node3Name = "NippleTip"
				EndIf
			EndIf
		EndIf
		
		; get current node 1 value and apply delta
		;node1CurrentValue = NiOverride.GetMorphValue(akActor, node1Name)
		;NiOverride.ClearMorphValue(akActor, node1Name)
		;node1NewValue = node1CurrentValue - delta
		;NiOverride.SetMorphValue(akActor, node1Name, PapyrusUtil.ClampFloat(node1NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
		QueueUpdate(akActor, node1Name, MyKey, delta, 1)

		If akActor == mySelf
			Debug.Notification("Your " + node1Name + " rapidly shrinks! (-" + delta + ")")
		Else
			Debug.Notification(npcName + "'s " + node1Name + " rapidly shrinks! (-" + delta + ")")
		EndIf
		

		
		
		; get current node 2 value and apply delta if node 2 is not null
		If chooseSecondNode != -1
			;node2CurrentValue = NiOverride.GetMorphValue(akActor, node2Name)
			;NiOverride.ClearMorphValue(akActor, node2Name)
			;node2NewValue = node2CurrentValue - delta
			;NiOverride.SetMorphValue(akActor, node2Name, PapyrusUtil.ClampFloat(node2NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
			QueueUpdate(akActor, node2Name, MyKey, delta, 1)

			If akActor == mySelf
				Debug.Notification("Your " + node2Name + " rapidly shrinks! (-" + delta + ")")
			Else
				Debug.Notification(npcName + "'s " + node2Name + " rapidly shrinks! (-" + delta + ")")
			EndIf
		EndIf
		
		; get current node 3 value and apply delta if node 3 is not null
		If chooseThirdNode != -1
			;node3CurrentValue = NiOverride.GetMorphValue(akActor, node3Name)
			;NiOverride.ClearMorphValue(akActor, node3Name)
			;node3NewValue = node3CurrentValue - delta
			;NiOverride.SetMorphValue(akActor, node3Name, PapyrusUtil.ClampFloat(node3NewValue, TFEMinNippleSize.GetValue(), TFEMaxNippleSize.GetValue()))
			QueueUpdate(akActor, node3Name, MyKey, delta, 1)

			If akActor == mySelf
				Debug.Notification("Your " + node3Name + " rapidly shrinks! (-" + delta + ")")
			Else
				Debug.Notification(npcName + "'s " + node3Name + " rapidly shrinks! (-" + delta + ")")
			EndIf
		EndIf
	EndIf
	
	; update weight to update character model
	;NiOverride.UpdateModelWeight(akActor)
	
EndFunction 

float Function GetDelta()
	float changeAmount = Utility.RandomFloat(0.1, 0.4)
	
	Return changeAmount
EndFunction

Function QueueUpdate(Actor kActor, String morphID, String modKey, float value, int replaceOrUpdate)
	int queueUpdateEvent = ModEvent.Create("NIF_ExternalModEvent")	
	If (queueUpdateEvent)
		ModEvent.PushForm(queueUpdateEvent, kActor)
		ModEvent.PushString(queueUpdateEvent, morphID)
		ModEvent.PushString(queueUpdateEvent, modKey)
		ModEvent.PushFloat(queueUpdateEvent, value)
		ModEvent.PushInt(queueUpdateEvent, replaceOrUpdate)
		ModEvent.Send(queueUpdateEvent)
	EndIf
	Debug.Notification("Sent QueueUpdate event from " + modKey)
EndFunction