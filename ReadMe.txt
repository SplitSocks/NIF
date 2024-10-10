
FOR DEBUGGING ASSITANCE:

Please enable Papayrus Debugging.
Upload the NimorphusTrace logs from your C:\Users\(YOUR USER NAME)\Documents\My Games\Skyrim Special Edition\Logs\Script\User

Please upload these in a response or DM me in discord.


Discord: fullclogdestroyer

 

Nimorphus - An Inflation Framework
 

Welcome to Nimorphus, a flexible inflation framework.


Hard Requirements

    SKSE
    JContainers

 

What It Does

Nimorphus is designed to be fully compatible with any body type without the need for specific morphIDs from other mods. This is mostly a plug-and-play framework. You won’t need to interact with the MCM unless you want to adjust settings.

 

What It Doesn’t Do

    Detect other mods
    Doesn't detect already applied morphs when installed mid game

 

How It Works

    External mod sends event via the structure below.
    Event is received and placed in a queue.
    Tracking for each request updates the data.
    the receiving value will be filtered through Mod Influence, MorphID Ranges and MorphsPerMod.
    Value is applied to character

 

MCM (Mod Configuration Menu)

    Main: Currently empty (I plan to add configurable settings here).
    Registered Actors: Lists all actors modified by the framework. A "reset morphs" option will be added in a future update.
    Mod Influence: Lists all mods tracked by the framework and allows you to adjust the influence. For example, if a mod sends a morph value of 5 and you set the influence to 50%, the value will be adjusted to 2.5.
    Morph Range: Lists all MorphIDs that are affected, allowing you to adjust the minimum and maximum values for each morphID
    MorphsPerMod: UNDER CONSTRUCTION - This will eventually list MorphID headers with sliders of each mod affecting it. This will allow more granular control.
    Morph Exchange: UNDER CONSTRUCTION - Make a morphID affect a different one instead!

 

Included Adjusted Mods

    Baka Fill Her Up - THIS PARTICULAR ONE MAY ONLY WORK FOR NEFARAM MOD LIST
    Milk Mod Economy - Good to go!
    Transformative Elixirs - Good to go!

 

For Modders

Modders can perform any modifications to the morphID in their mod and send the updated value to Nimorphus. My framework will apply the changes, track the mod, and allow users to modify how much influence your mod has on the morphs of the game actors.

 

the int replaceOrUpdate means 0 is Replace the value or 1 is Update it (current value + the new one). 1 will not be used much until I add a method for mods to pull from the framework easily.

Please use the following function to send an event to Nimorphus:

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
EndFunction

 

To call this function, use:

QueueUpdate(akActor, morphID, myModID, morphValue, 0)
I plan to add functionality allowing mods to retrieve existing values. Currently, this uses JContainers. You can add Import NIF_JCDomain to your scripts and use NIF_JCDomain.JMap_getObj(int MAPNAME, string KEY) to return an object. I’ll work on simplifying this process.

 

SPECIAL THANKS:
Skyrim Scripting youtube channel! ❤️
DVA - Dynamic Vampire Appearance - I totally ripped the debugging function and adapted to mine. Thank you! 