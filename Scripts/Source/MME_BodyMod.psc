Scriptname MME_BodyMod extends Quest Hidden

Function SetNodeScale(Actor akActor, string nodeName, float value, bool isFemale)
	string modName = "MilkModNEW.esp"
	if nodeName == "NPC L Breast"
		float newValue = (value - 1)
		QueueUpdate(akActor, "Breasts", modName, newValue)
		QueueUpdate(akActor, "BreastsSH", modName, newValue)
		QueueUpdate(akActor, "BreastsNewSH", modName, newValue)
		QueueUpdate(akActor, "BreastsNewSH", modName, newValue)
		QueueUpdate(akActor, "BreastGravity", modName, newValue / 1.5)
		QueueUpdate(akActor, "NippleAreola", modName, newValue)
		QueueUpdate(akActor, "AreolaSize", modName, newValue)
		QueueUpdate(akActor, "DoubleMelon", modName, newValue)
		QueueUpdate(akActor, "BreastsFantasy", modName, newValue / 5)
		QueueUpdate(akActor, "NipplePerkiness", modName, newValue)	
		QueueUpdate(akActor, "NipplePerkiness", modName, newValue)
		QueueUpdate(akActor, "NippleLength", modName, newValue / 5 )
	ElseIf nodeName == "NPC Belly"
		float newValue = (value - 2) / 3
		if newValue < 0
			float clampedNewValue = 0
			QueueUpdate(akActor, "PregnancyBelly", modName, clampedNewValue)
		else
			QueueUpdate(akActor, "PregnancyBelly", modName, newValue)
		endif
	endif
EndFunction

Function QueueUpdate(Actor kActor, String morphID, String modKey, float value)
	;Send morph info to NIF
	int queueUpdateEvent = ModEvent.Create("NIF_ExternalModEvent")	
	If (queueUpdateEvent)
		ModEvent.PushForm(queueUpdateEvent, kActor)
		ModEvent.PushString(queueUpdateEvent, morphID)
		ModEvent.PushString(queueUpdateEvent, modKey)
		ModEvent.PushFloat(queueUpdateEvent, value)
		ModEvent.PushInt(queueUpdateEvent, 0)
		ModEvent.Send(queueUpdateEvent)
	EndIf
EndFunction

Function RemoveNiONodeScale(Actor akActor, string nodeName, bool isFemale)
	;string modName = "MilkModEconomy"
	;if akActor == Game.GetPlayer() ;update 1st person view/skeleton (player only)
	;	NiOverride.RemoveNodeTransformScale(akActor, true, isFemale, nodeName, modName)
	;	NiOverride.UpdateNodeTransform(akActor, true, isFemale, nodeName)
	;endif
	;NiOverride.RemoveNodeTransformScale(akActor, false, isFemale, nodeName, modName)
	;NiOverride.UpdateNodeTransform(akActor, false, isFemale, nodeName)
EndFunction