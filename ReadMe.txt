Nimorphus - An Inflation Framework
<Intro>

Hello.

<Hard Requirements>
JContainers

<What it does>
This framework is designed to be fully compatible with any body type, without requiring specific morphIDs from other mods.
As long as a mod triggers the event detailed below, this framework will handle and process the request. 
If the specified morphID exists in the game, it will be updated via NIOverride. 
If the morphID does not exist, the request will be ignored or fail silently.
Any MorphIDs that don't exsist will be tracked as usual, adding some bloat. 
This is the major downside. 
How big that bloat is depends on if you're crazy enough to have different body mods. 
This could be mitigated if I tracked down all body mods, pulled their IDs and put them in a JSON for parsong. 
I'd rather not.

<What it doesn't do>
As of now, this doesn't work mid game. You need to start over completely or just not care about the morphs starting over. 
Alternatively you can use transformative elixers to a degree to get them where you were initially.

<The Guts>
Freely view the source scripts and let me know what you believe should be changed/added. (I may go git route later)

<MCM>
This is pretty much a plug and play framework. You don't really ever have to look at the MCM unless you want to.

MCM contains 3 pages.
Main:
	Currently empty, teehee
	I plan on adding settings that can be loaded.
Registered Actors:
	Lists all the actors that have been modified via the framework.
	I will be adding a reset morphs option here in the future.
Registered Mods:
	Lists all the mods that have been modified via the framework.
	This also allows you to adjust the influence. If a mod sends a morph value of 5 and you set influence to 50%, the value will be adjusted to 2.5.
Registered Morphs"
	Lists all the MorphIDs affected.
	This also lets you adjust the MIN and MAX value each morph ID.
	This displays all ORIGINAL values. Mod Influence is not calculated here.

<Included Adjusted Mods>
Please let me know if I missed any in the Nefaram Mod List
These mods were modified based off the winning file in Nefaram. I'm not sure if these will work in other lists correclty.
1. Baka Fill Her Up (Pain in the ASS!)
2. Milk Mod Economy (I highly recommend enabling volumetric in their settings)
3. Transformative Elixers

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

I do plan on adding a way for mods to retreive the existing values. As it stands, it ustilizes JContainers.
Currently, you can add Import NIF_JCDomain in your scripts
Ensure you type NIF_JCDomain.JMap_getObj(int MAPNAME, string KEY) to return the object. I'll find a way to make this much simpler.