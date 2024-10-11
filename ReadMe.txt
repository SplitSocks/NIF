https://github.com/SplitSocks/NIF

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

These mods were modified based on the winning file in Nefaram and may not work correctly in other lists:

    Baka Fill Her Up
    Milk Mod Economy - Utilized Nefarm winn
    Transformative Elixirs - This should work regardless if utilized in other lists.


For Modders

Modders can perform any modifications to the morphID in their mod and send the updated value to Nimorphus. My framework will apply the changes, track the mod, and allow users to modify how much influence your mod has on the morphs of the game actors.

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
    ;Debug.Notification("Sent QueueUpdate event from " + modKey)
EndFunction


To call this function, use:

QueueUpdate(akActor, morphID, myModID, morphValue, 1)


 plan to add functionality allowing mods to retrieve existing values. Currently, this uses JContainers. You can add Import NIF_JCDomain to your scripts and use NIF_JCDomain.JMap_getObj(int MAPNAME, string KEY) to return an object. I’ll work on simplifying this process.


Updates:

10/6/24 I am currently rewriting a few bits of the code that will assist with better min/max morph IDs and allow turning off a mod's value update to force "compatibility."