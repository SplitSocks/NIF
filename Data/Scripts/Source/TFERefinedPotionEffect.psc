Scriptname TFERefinedPotionEffect extends ActiveMagicEffect 

GlobalVariable Property TFEMaxBodySize Auto
GlobalVariable Property TFEMinBodySize Auto
 
import NiOverride
String Property MyKey = "TransformativeElixirs.esp" Auto

actor property mySelf auto
string property RefinementType auto

Event OnEffectFinish(Actor Target, Actor Caster)
	
endEvent
 
Event OnEffectStart(Actor Target, Actor Caster)
	float value = GetDelta()
	QueueUpdate(Target, RefinementType, MyKey, value, 1)		
endEvent


Function ApplyTransform(Actor akActor, float delta, bool isFemale)
	string npcName = akActor.GetBaseObject().GetName()
	float nodeCurrentValue = 0.0
	float nodeNewValue = 0.0	
	nodeCurrentValue = NiOverride.GetMorphValue(akActor, RefinementType)
	NiOverride.ClearMorphValue(akActor, RefinementType)
	nodeNewValue = nodeCurrentValue + delta
	NiOverride.SetMorphValue(akActor, RefinementType, PapyrusUtil.ClampFloat(nodeNewValue, TFEMinBodySize.GetValue(), TFEMaxBodySize.GetValue()))	
	
	If akActor == mySelf
		If RefinementType == "Butt"
			Debug.Notification("Your " + RefinementType + " rapidly expands! (+" + delta + ")")
		Else
			Debug.Notification("Your " + RefinementType + " rapidly expand! (+" + delta + ")")
		EndIf
	Else
		If RefinementType == "Butt"
			Debug.Notification(npcName + "'s " + RefinementType + " rapidly expands! (+" + delta + ")")
		Else
			Debug.Notification(npcName + "'s " + RefinementType + " rapidly expand! (+" + delta + ")")
		EndIf
	EndIf
	
	; update weight to update character model
	;NiOverride.UpdateModelWeight(akActor)
	
EndFunction 

float Function GetDelta()
	float changeAmount = Utility.RandomFloat(0.2, 0.5)
	
	Return changeAmount
EndFunction

Function QueueUpdate(Actor akActor, String morphID, String modKey, float value, int replaceOrUpdate)
	int queueUpdateEvent = ModEvent.Create("NIF_ExternalModEvent")	
	If (queueUpdateEvent)
		ModEvent.PushForm(queueUpdateEvent, akActor)
		ModEvent.PushString(queueUpdateEvent, morphID)
		ModEvent.PushString(queueUpdateEvent, modKey)
		ModEvent.PushFloat(queueUpdateEvent, value)
		ModEvent.PushInt(queueUpdateEvent, replaceOrUpdate)
		ModEvent.Send(queueUpdateEvent)
	EndIf
	MiscUtil.PrintConsole("Sent QueueUpdate event " + akActor + " " + morphID + " " + modKey + " " + value + " " + replaceOrUpdate)
EndFunction