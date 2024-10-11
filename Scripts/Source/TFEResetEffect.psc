Scriptname TFEResetEffect extends ActiveMagicEffect 
 
import NiOverride
String Property MyKey = "TransformativeElixirs.esp" Auto

actor property mySelf auto

Event OnEffectFinish(Actor Target, Actor Caster)
	UnregisterForUpdate()
endEvent
 
Event OnEffectStart(Actor Target, Actor Caster)
	ResetValues(Target, true)
	UnregisterForUpdate()
	Dispel()
	
endEvent


Function ResetValues(Actor akActor, bool isFemale)
	string npcName = akActor.GetBaseObject().GetName()
	
	; Reset values to zero
	;NiOverride.ClearMorphValue(akActor, "NippleSize")
	;NiOverride.SetMorphValue(akActor, "NippleSize", 0)
	QueueUpdate(akActor, "NippleSize", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "NippleLength")
	;NiOverride.SetMorphValue(akActor, "NippleLength", 0)
	QueueUpdate(akActor, "NippleLength", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "NippleTip")
	;NiOverride.SetMorphValue(akActor, "NippleTip", 0)
	QueueUpdate(akActor, "NippleTip", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "AreolaSize")
	;NiOverride.SetMorphValue(akActor, "AreolaSize", 0)
	QueueUpdate(akActor, "AreolaSize", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "MuscleAbs")
	;NiOverride.SetMorphValue(akActor, "MuscleAbs", 0)
	QueueUpdate(akActor, "MuscleAbs", MyKey, 0, 0)
	
	;NiOverride.ClearMorphValue(akActor, "MuscleButt")
	;NiOverride.SetMorphValue(akActor, "MuscleButt", 0)
	QueueUpdate(akActor, "MuscleButt", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "MuscleLegs")
	;NiOverride.SetMorphValue(akActor, "MuscleLegs", 0)
	QueueUpdate(akActor, "MuscleLegs", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "MuscleArms")
	;NiOverride.SetMorphValue(akActor, "MuscleArms", 0)
	QueueUpdate(akActor, "MuscleArms", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "Waist")
	;NiOverride.SetMorphValue(akActor, "Waist", 0)
	QueueUpdate(akActor, "Waist", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "Arms")
	;NiOverride.SetMorphValue(akActor, "Arms", 0)
	QueueUpdate(akActor, "Arms", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "Belly")
	;NiOverride.SetMorphValue(akActor, "Belly", 0)
	QueueUpdate(akActor, "Belly", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "Thighs")
	;NiOverride.SetMorphValue(akActor, "Thighs", 0)
	QueueUpdate(akActor, "Thighs", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "Breasts")
	;NiOverride.SetMorphValue(akActor, "Breasts", 0)
	QueueUpdate(akActor, "Breasts", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "Butt")
	;NiOverride.SetMorphValue(akActor, "Butt", 0)
	QueueUpdate(akActor, "Butt", MyKey, 0, 0)

	;NiOverride.ClearMorphValue(akActor, "Hips")
	;NiOverride.SetMorphValue(akActor, "Hips", 0)
	QueueUpdate(akActor, "Hips", MyKey, 0, 0)

	; update weight to update character model
	NiOverride.UpdateModelWeight(akActor)
	
	If akActor == mySelf
		Debug.Notification("You feel your body return to normal.")
	Else
		Debug.Notification(npcName + "'s body returns to normal.")
	EndIf
	


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