Nefaram Inflation Framewoork

<Intro>

Hello, I've created something.

<Hard Requirements>
JContainers

<What it does>
This is a body type agnostic inflation framework. It 100% doesn't give two shits which morphID's a mod calls. As long as the mod sends the event marked at the bottom, this mod will process and request the change. If the morphID exsists in the game, NIoverride will update it; otherwise, it will silently fail.

Any MorphIDs that don't exsist will still be tracked adding some bloat. This is the major downside. How big that bloat is depends on if you're crazy enough to have different body mods. This could be mitigated if I tracked down all body mods, pulled their IDs and put them in a JSON for parsong. I'd rather not.

<The Guts>
Freely view the source scripts and let me know what you believe should be changed/added. (I may go git route later)

<MCM>
This is pretty much a plug and play framework. You don't really ever have to look at the MCM unless you want to.

MCM contains 3 pages.
Main - Main Page with misc options
Morphs - View the morphs of a selected Actor
Mods - View the mods that have called this framework

<Adjusted Mods>
Baka Fill Her Up (Pain in the ASS!)
Milk Mod Economy
Transformative Elixers

I will add more to this later. I'm not exactly sure what other mods adjust these.

<For Modders>
Please perform any and all modifications to the morphID on your mod. Send the value to mine via the below. 
My mod will only apply it, track the mod and allow user to change how much influence your mod affects the morphs of the game actors 
Please use this function for sending an event to my mod.

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
	;Debug.Notification("Sent QueueUpdate event from " + modKey)
EndFunction

Call this function like so: QueueUpdate(akActor, morphID, myModID, morphValue, 1)