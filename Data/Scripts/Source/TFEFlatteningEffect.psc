Scriptname TFEFlatteningEffect extends ActiveMagicEffect 
 
GlobalVariable Property TFEMaxBodySize Auto
GlobalVariable Property TFEMinBodySize Auto

import NiOverride
String Property MyKey = "TransformativeElixirs.esp" Auto

actor property mySelf auto

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
	
	; choose node 1
	If chooseFirstNode >= 0 && chooseFirstNode < 23
		node1Name = "Breasts"
	ElseIf chooseFirstNode >= 23 && chooseFirstNode < 46
		node1Name = "Butt"
	ElseIf chooseFirstNode >= 46 && chooseFirstNode < 69 ; nice
		node1Name = "Hips"
	ElseIf chooseFirstNode >= 69 && chooseFirstNode < 92
		node1Name = "Thighs"
	Else
		node1Name = "Breasts"
	EndIf
	
	; choose node 2
	If chooseFirstNode >= 92
		chooseSecondNode = Utility.RandomInt()
		If chooseSecondNode >= 0 && chooseSecondNode < 34
			node2Name = "Butt"
		ElseIf chooseSecondNode >= 34 && chooseSecondNode < 67
			node2Name = "Hips"
		ElseIf chooseSecondNode >= 67
			node2Name = "Thighs"
		EndIf
	EndIf
	
	; choose node 3
	If chooseFirstNode >= 97
		chooseThirdNode = Utility.RandomInt()
		If node2Name == "Butt"
			If chooseThirdNode < 50
				node3Name = "Hips"
			Else
				node3Name = "Thighs"
			EndIf
		ElseIf node2Name == "Hips"
			If chooseThirdNode < 50
				node3Name = "Butt"
			Else
				node3Name = "Thighs"
			EndIf
		ElseIf node2Name == "Thighs"
			If chooseThirdNode < 50
				node3Name = "Butt"
			Else
				node3Name = "Hips"
			EndIf
		EndIf
	EndIf
	
	; get current node 1 value and apply delta
	;node1CurrentValue = NiOverride.GetMorphValue(akActor, node1Name)
	;NiOverride.ClearMorphValue(akActor, node1Name)
	;node1NewValue = node1CurrentValue - delta
	;NiOverride.SetMorphValue(akActor, node1Name, PapyrusUtil.ClampFloat(node1NewValue, TFEMinBodySize.GetValue(), TFEMaxBodySize.GetValue()))
	QueueUpdate(akActor, node1Name, MyKey, delta, 1)

	If akActor == mySelf
		If node1Name == "Butt"
			Debug.Notification("Your " + node1Name + " rapidly shrinks! (-" + delta + ")")
		Else
			Debug.Notification("Your " + node1Name + " rapidly shrink! (-" + delta + ")")
		EndIf
	Else
		If node1Name == "Butt"
			Debug.Notification(npcName + "'s " + node1Name + " rapidly shrinks! (-" + delta + ")")
		Else
			Debug.Notification(npcName + "'s " + node1Name + " rapidly shrink! (-" + delta + ")")
		EndIf
	EndIf
	

	
	
	; get current node 2 value and apply delta if node 2 is not null
	If chooseSecondNode != -1
		;node2CurrentValue = NiOverride.GetMorphValue(akActor, node2Name)
		;NiOverride.ClearMorphValue(akActor, node2Name)
		;node2NewValue = node2CurrentValue - delta
		;NiOverride.SetMorphValue(akActor, node2Name, PapyrusUtil.ClampFloat(node2NewValue, TFEMinBodySize.GetValue(), TFEMaxBodySize.GetValue()))
		QueueUpdate(akActor, node2Name, MyKey, delta, 1)

		If akActor == mySelf
			If node2Name == "Butt"
				Debug.Notification("Your " + node2Name + " rapidly shrinks! (-" + delta + ")")
			Else
				Debug.Notification("Your " + node2Name + " rapidly shrink! (-" + delta + ")")
			EndIf
		Else
			If node2Name == "Butt"
				Debug.Notification(npcName + "'s " + node2Name + " rapidly shrinks! (-" + delta + ")")
			Else
				Debug.Notification(npcName + "'s " + node2Name + " rapidly shrink! (-" + delta + ")")
			EndIf
		EndIf
	EndIf
	
	; get current node 3 value and apply delta if node 3 is not null
	If chooseThirdNode != -1
		;node3CurrentValue = NiOverride.GetMorphValue(akActor, node3Name)
		;NiOverride.ClearMorphValue(akActor, node3Name)
		;node3NewValue = node3CurrentValue - delta
		;NiOverride.SetMorphValue(akActor, node3Name, PapyrusUtil.ClampFloat(node3NewValue, TFEMinBodySize.GetValue(), TFEMaxBodySize.GetValue()))
		QueueUpdate(akActor, node3Name, MyKey, delta, 1)

		If akActor == mySelf
			If node3Name == "Butt"
				Debug.Notification("Your " + node3Name + " rapidly shrinks! (-" + delta + ")")
			Else
				Debug.Notification("Your " + node3Name + " rapidly shrink! (-" + delta + ")")
			EndIf
		Else
			If node3Name == "Butt"
				Debug.Notification(npcName + "'s " + node3Name + " rapidly shrinks! (-" + delta + ")")
			Else
				Debug.Notification(npcName + "'s " + node3Name + " rapidly shrink! (-" + delta + ")")
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