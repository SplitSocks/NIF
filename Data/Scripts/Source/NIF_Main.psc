; Special thanks to Skyrim Scripting youtube channel for giving me the confidence to even attempt this.
; Thanks to DVA - Dynamic Vampire Appearance. I lifeted their debugging style as I had no idea how it worked.

ScriptName NIF_Main extends Quest

Import NIF_JCDomain
import NiOverride

; ========== Main Database ==========
; Below is how the data is structured.

int property mapActorData Auto
;Top-level JFormMap (mapActorData): Declared above.
;This is the main JMap that contains all actors.
;    Key: The FormID of the actor as a Form.
;    Value: A retained JMap containing morph data for that specific actor.
;
;Actor-level JMap: Nested
;This JMap contains all morphs for the given actor.;
;    Key: The morphID (as a string) for each morph.
;    Value: A retained JMap containing mod data for that morph.
;
;Morph-level JMap: Nested
;This JMap contains all mods that influence the given morph for that actor.
;    Key: The modName (as a string) for each mod that affects the morph.
;    Value: The morph value (as a float) controlled by that mod.
;
; Example Layout
;   mapActorData -> JMap
;        ActorFormID1 -> JMap (MorphID1 -> MorphJMap, MorphID2 -> MorphJMap, ...)
;        ActorFormID2 -> JMap (MorphID1 -> MorphJMap, MorphID2 -> MorphJMap, ...)
;            MorphJMap -> JMap
;            MorphID1 -> JMap (ModName1 -> modValue, ModName2 -> modValue, ...)
;            MorphID2 -> JMap (ModName1 -> modValue, ModName2 -> modValue, ...)
;                ModName -> modValue (float)

; ========== Morph Range Database ==========
int property morphIDRange Auto
; JMap (morphIDRange): declared above
; This is the JMap that contains all morphID's and a JArray of it's miium and maximum ranges

 ; ========== Mod Influence Database ==========
 int property modInfluence Auto
; JMap (modInfluence): declared above
; This is the JMap that contains all Mods and each value indicates whether this mod is allowed to display the morphs saved in the mapActorData
int property morphModInfluence Auto
; JMap(morphModInfluence) declared above
; This is the JMap that contains all morphID keys with an array of Mod Booleans that affect it.AddNodeOverrideBool

 ; ========== Morph Exchange Database ==========
 int property moprhExchange Auto

int  QueueUpdateArray ; Queue for actor updates
Bool isProcessing = False ; To handle queue processing

form Property PlayerRef Auto; Player Ref

bool isInitialized = false

; ========== DEBUGGING ==========
int Property Debug_Info = 1 AutoReadOnly
int Property Debug_Warn = 8 AutoReadOnly
int Property Debug_Error = 10 AutoReadOnly
GlobalVariable Property Nimorphus_DebugLevel Auto
; Initialize Log State
bool isLogOpen = false

function NimorphusError(string msg)
	Debug.MessageBox("NIMORPHUS ERROR\n\n" + msg + "\n\nFor help, go to Nimoprhus LoversLab support page.")
endFunction

function NimorphusLog(int level, string msg, bool copyTrace = false, bool includeStack = false)
    if (level < Nimorphus_DebugLevel.Value as int)
        return
    endif
    ; Open the log if not already opened
    if (!isLogOpen)
        isLogOpen = Debug.OpenUserLog("NimorphusTrace")
    endif
    ; Log the message based on severity
    int severity = 0
    if (level == Debug_Warn)
        severity = 1
    elseif (level == Debug_Error)
        severity = 2
    endif

    bool result = Debug.TraceUser("NimorphusTrace", "Nimorphus ("+level+")>> " + msg, severity)
	if( !result )
		if( isLogOpen )
			isLogOpen = false
			NimorphusLog(level, msg) ; loop in to fix the un-opened log file
		else
			; fall back to default logging
			Debug.Trace("Nimorphus ("+level+")>> " + msg, severity)
            ;MiscUtil.PrintConsole(msg)
		endif
	endif

    if( result && copyTrace )
		Debug.Trace("Nimorphus ("+level+")>> " + msg, severity)
        ;MiscUtil.PrintConsole(msg)
	endif
	
	if( result && includeStack )
		Debug.TraceStack("Nimorphus ("+level+")>> " + msg, severity)
        ;MiscUtil.PrintConsole(msg)
	endif
endFunction
; ========== END DEBUGGING ==========

; ========== Loading ==========
Event onInit()
    if !isInitialized
        if JContainers.isInstalled()
            loadJContainerReferences()
            isInitialized = true
            NimorphusLog(Debug_Info,"Welcome to Nimorphus - An Inflation Framework")            
        Else
            NimorphusLog(Debug_Info,"JContainers is not installed. This framework requires JContainers to function correctly")
        endIf
    endIf
    RegisterForModEvent("NIF_ExternalModEvent", "QueueUpdateEvent")
EndEvent

event OnPlayerLoadGame()
    onInit()
    NimorphusLog(Debug_Info,"Welcome to Nimorphus - An Inflation Framework")
endevent

; Loads all JConatiners needed
function loadJContainerReferences()
    if mapActorData == 0
        mapActorData = JFormMap_Object()
        JValue_retain(mapActorData)
        NimorphusLog(Debug_Info, mapActorData + " mapActorData")
    endif    
    if QueueUpdateArray == 0
        QueueUpdateArray = JArray_object()
        JValue_retain(QueueUpdateArray)
        NimorphusLog(Debug_Info, QueueUpdateArray + " QueueUpdateArray")
    endif
    if modInfluence == 0
        modInfluence = JMap_object()
        JValue_retain(modInfluence)
        NimorphusLog(Debug_Info, modInfluence + " modInfluence")
    endif
    if morphIDRange == 0
        morphIDRange = JMap_object()
        JValue_retain(morphIDRange)
        NimorphusLog(Debug_Info, morphIDRange + " morphIDArray")
    endif
    if morphModInfluence == 0
        morphModInfluence = JMap_object()
        JValue_retain(morphModInfluence)
        NimorphusLog(Debug_Info, morphModInfluence + " morphModInfluence")
    endif    
endfunction

; ========== Main Process Line ==========
; Listening Event for external mod use only
event QueueUpdateEvent(Form kActor, String morphID, String keyName, float value, int updateType)
    QueueUpdate(kActor, morphID, keyName, value, updateType)
endEvent

; The queue called by the event listner to place the request into queue.
Function QueueUpdate(Form kActor, String morphID, String keyName, float value, int updateType, int processType = 0)
    NimorphusLog(Debug_Info, "QueueUpdate: Started")
    int QueueUpdateArrayInfo = JArray_object()
    JValue_retain(QueueUpdateArrayInfo)
    ; Add specific parameters based on the update type
    if processType == 0 ; Actor-specific morph update
        if kActor == None
            Debug.Notification("Error: Target actor is None. Skipping this event.")
            NimorphusLog(Debug_Error, "Error: Target actor is None. Skipping this event.")
            return
        endif
        JArray_addInt(QueueUpdateArrayInfo, processType, 0)
    elseif processType == 1 ; Global mod influence change
        JArray_addInt(QueueUpdateArrayInfo, processType, 0) ; Placeholder to mark global mod influence change
    elseif processType == 2 ; Global morph range change
        JArray_addInt(QueueUpdateArrayInfo, processType, 0) ; Placeholder to mark global morph range change
    endif
    JArray_addForm(QueueUpdateArrayInfo, kActor, 1)
    JArray_addStr(QueueUpdateArrayInfo, morphID, 2)
    JArray_addStr(QueueUpdateArrayInfo, keyName, 3)
    JArray_addFlt(QueueUpdateArrayInfo, value, 4)
    JArray_addInt(QueueUpdateArrayInfo, updateType, 5)
    JArray_addObj(QueueUpdateArray, QueueUpdateArrayInfo)
    ; If processing isn't already happening, start it
    if !isProcessing
        isProcessing = True
        ProcessQueue()
    endif
    NimorphusLog(Debug_Info, "QueueUpdate Successful: Type " + processType)
EndFunction

; Processes all updates with a .1 wait time and should be adjusted with testing
Function ProcessQueue()
    while JArray_count(QueueUpdateArray) > 0
        int tempQueueArray = JArray_getObj(QueueUpdateArray, 0)
        ; this is used for external mods
        if JArray_getInt(tempQueueArray, 0) == 0
            Actor kActor = JArray_getForm(tempQueueArray, 1) as Actor
            string morphID = JArray_getStr(tempQueueArray, 2)
            string modName = JArray_getStr(tempQueueArray, 3)
            float morphValue = JArray_getFlt(tempQueueArray, 4)
            int updateType = JArray_getInt(tempQueueArray, 5)
            if kactor
                UpdateTrackedMorphs(kActor, morphID, modName, morphValue, updateType)
                NimorphusLog(Debug_Info, "ProcessQueue: updated for " + kActor +" morph ID " +morphID+" mod name "+modName+" for value "+morphValue+" update type "+updateType)
                float processedValue = ApplyMorphValueAdjustments(kActor, morphID, modName)
                NimorphusLog(Debug_Info, "ProcessQueue: processedValue for " + processedValue)
                UpdateNiOverrideActorMorphs(kActor, morphID, modName, processedValue)
                NimorphusLog(Debug_Info, "ProcessQueue: UpdateNiOverrideActorMorphs for " + kActor +" morph ID " +morphID+" mod name "+modName+" for value "+processedValue+" update type "+updateType)
                UpdateActorModelWeight(kActor)
            endif
        ; this is used when the MCM changes mod influence for specific mod
        elseif JArray_getInt(tempQueueArray, 0) == 1
            string modName = JArray_getStr(tempQueueArray, 3)
            ; Start iterating over all actors using JContainers' nextKey
            form kActorForm = JFormMap_nextKey(mapActorData, None)
            while kActorForm != None
                actor kActor = kActorForm as actor
                int actorMorphIDs = GetOrCreateActorsMorphIDs(kActorForm)
                ; Iterate over each morph ID for the actor
                string morphID = JMap_nextKey(actorMorphIDs, "", "")
                while morphID != ""
                    int morphModIDs = GetOrCreateMorphModIDs(actorMorphIDs, morphID)
                    float processedValue = ApplyMorphValueAdjustments(kActor, morphID, modName)
                    UpdateNiOverrideActorMorphs(kActor, morphID, modName, processedValue)
                    UpdateActorModelWeight(kActor)
                    ; Move to the next morphID
                    morphID = JMap_nextKey(actorMorphIDs, morphID, "")
                endwhile
                ; Move to the next actor in the mapActorData
                kActorForm = JFormMap_nextKey(mapActorData, kActorForm)
            endwhile
        ; this is used when the MCM changes morph ranges or the morphMod Toggles are changed
        elseif JArray_getInt(tempQueueArray, 0) == 2
            string morphID = JArray_getStr(tempQueueArray, 2)
            NimorphusLog(Debug_Info, "Begin Process Queue: MorphID = " + morphID)
            ; Get the first key in the JFormMap for actors
            form actorKey = JFormMap_nextKey(mapActorData, None)
            while actorKey != None
                actor kActor = actorKey as Actor
                int actorMorphIDs = GetOrCreateActorsMorphIDs(actorKey)
                ; Get the first key in the JMap for morphs
                string morphKey = JMap_nextKey(actorMorphIDs, "")
                while morphKey != ""
                    ; Get the morph mod IDs for the current actor's morph
                    int morphModIDs = GetOrCreateMorphModIDs(actorMorphIDs, morphID)
                    string modKey = JMap_nextKey(morphModIDs, "")
                    ; Loop through the mods affecting the current morph
                    while modKey != ""
                        float processedValue = ApplyMorphValueAdjustments(kActor, morphID, modKey, 1)
                        UpdateNiOverrideActorMorphs(kActor, morphID, modKey, processedValue)
                        UpdateActorModelWeight(kActor)
                        modKey = JMap_nextKey(morphModIDs, modKey) ; Get the next mod
                    endwhile        
                    morphKey = JMap_nextKey(actorMorphIDs, morphKey) ; Get the next morph
                endwhile   
                actorKey = JFormMap_nextKey(mapActorData, actorKey) ; Get the next actor                
            endwhile            
        endif    
        JArray_eraseIndex(QueueUpdateArray, 0)
    endWhile
    isProcessing = False
EndFunction

Function ResetActorMorphs(string kActorStr)
EndFunction

; ========== Helper Functions ==========
; Function to update tracked morphs, keeping pure values in mapActorData
Function UpdateTrackedMorphs(Actor kActor, String morphID, String modName, float rawValue, int updateType)
    NimorphusLog(Debug_Info, "UpdateTrackedMorphs: Started for " + kActor)
    ; Update the pure value in mapActorData
    if updateType == 0 ; Replace value
        NimorphusLog(Debug_Info, "UpdateTrackedMorphs: Replace updated for " + kActor +" morph ID " +morphID+" mod name "+modName+" for value "+rawValue)
        UpdatePureMorphValue(kActor, morphID, modName, rawValue)
    elseif updateType == 1 ; Update value add
        float currentValue = GetPureMorphValue(kActor, morphID, modName)
        if currentValue == -1000.0
            NimorphusLog(Debug_Info, "UpdateTrackedMorphs: New Update: updated for " + kActor +" morph ID " +morphID+" mod name "+modName+" for value "+rawValue)
            UpdatePureMorphValue(kActor, morphID, modName, rawValue)
        else
            float newValue = currentValue + rawValue
            NimorphusLog(Debug_Info, "UpdateTrackedMorphs: Update: updated for " + kActor +" morph ID " +morphID+" mod name "+modName+" for value "+newValue)
            UpdatePureMorphValue(kActor, morphID, modName, newValue)
        endif
    elseif updateType == 2 ; PlaceHolder
        ;
    elseif updateType == 3 ; PlaceHolder
        ;
    elseif updateType == 4 ; PlaceHolder
        ;
    endif
EndFunction

; Helper function to update pure morph values in mapActorData
Function UpdatePureMorphValue(Actor kActor, String morphID, String modName, float rawValue)
    form kActorForm = kActor as form
    int actorMorphIDs = GetOrCreateActorsMorphIDs(kActorForm)
    int morphModIDs = GetOrCreateMorphModIDs(actorMorphIDs, morphID)    
    ; Store the raw morph value for the mod (without mod influence or morph range)
    JMap_setFlt(morphModIDs, modName, rawValue)
    NimorphusLog(Debug_Info, "Updated pure morph value: " + rawValue + " for mod: " + modName + " on morph: " + morphID)
EndFunction

; Function to retrieve the pure morph value from mapActorData
float Function GetPureMorphValue(Actor kActor, String morphID, String modName)
    form kActorForm = kActor as form
    int actorMorphIDs = GetOrCreateActorsMorphIDs(kActorForm)
    int morphModIDs = GetOrCreateMorphModIDs(actorMorphIDs, morphID)
    ; Get the raw morph value for the mod
    float morphValue = 0.0
    if JMap_hasKey(morphModIDs, modName)
        morphValue = JMap_getFlt(morphModIDs, modName)
    else
        morphValue = -1000.0
    endif
    return morphValue
    NimorphusLog(Debug_Info,"GetPureMorphValue returned "+morphValue)
EndFunction

; Function to retrieve or initialize the data for an actor
int Function GetOrCreateActorsMorphIDs(form actorFormID)
    int actorsMorphIDs = 0
    if JFormMap_hasKey(mapActorData, actorFormID)
        actorsMorphIDs = JFormMap_getObj(mapActorData, actorFormID)
        NimorphusLog(Debug_Info, "GetOrCreateActorsMorphIDs: Found Int for actorsMorphIDs " + actorsMorphIDs)
    else
        actorsMorphIDs = JMap_object()
        JFormMap_setObj(mapActorData, actorFormID, actorsMorphIDs)
        JValue_retain(actorsMorphIDs) ; Retain the newly created JMap
        NimorphusLog(Debug_Info, "GetOrCreateActorsMorphIDs: New Int for actorsMorphIDs " + actorsMorphIDs)
    endif
    return actorsMorphIDs
EndFunction

; Function to retrieve or initialize the morph data for an actor
int Function GetOrCreateMorphModIDs(int actorMorphIDs, String morphID)
    int morphModIDs = 0
    if JMap_hasKey(actorMorphIDs, morphID)
        morphModIDs = JMap_getObj(actorMorphIDs, morphID)
        NimorphusLog(Debug_Info, "GetOrCreateActorsMorphIDs: Found Int for morphModIDs " + morphModIDs)
    else
        morphModIDs = JMap_object()
        JMap_setObj(actorMorphIDs, morphID, morphModIDs)
        JValue_retain(morphModIDs)
        NimorphusLog(Debug_Info, "GetOrCreateActorsMorphIDs: New Int for morphModIDs " + morphModIDs)
    endif
    return morphModIDs
endFunction

; Function to apply mod influence and morph range without changing the raw values in mapActorData
float Function ApplyMorphValueAdjustments(Actor kActor, String morphID, String modName, int requestType = 0)
    float pureValue = GetPureMorphValue(kActor, morphID, modName) ; Get the pure value if it exists
    NimorphusLog(Debug_Info, "ApplyMorphValueAdjustments: pureValue if exists " + pureValue)
    if pureValue == -1000.0 ; If it doesn't exist a -1000 is returned and the function returns 0
        ; If it's -1000, the value doesn't exist in the map and need not be touched
        NimorphusLog(Debug_Warn, "ApplyMorphValueAdjustments: for " + kActor+ " for morph "+morphID+" for mod "+modName)
        return 0
    endif
    float adjustedValue
    ; 1. Apply global mod influence
    bool modInfluenceActive = GetModInfluence(modName)
    NimorphusLog(Debug_Info, "ApplyMorphValueAdjustments: modInfluenceActive returned " + modInfluenceActive)
    float modInfluenceAdjustedValue            
    if !modInfluenceActive
        return 0
    endif
    ; 2. Apply mod-specific influence on the morph (morphModInfluence)
    bool morphModInfluenceActive = GetMorphModInfluence(morphID, modName)
    NimorphusLog(Debug_Info, "ApplyMorphValueAdjustments: morphModInfluenceActive returned " + morphModInfluenceActive)
    if !morphModInfluenceActive
        return 0
    endif
    ; 3. Apply morph range adjustment
    NimorphusLog(Debug_Info, "ApplyMorphValueAdjustments: sent value " + pureValue)
    adjustedValue = GetMorphValueAdjustedbyRange(kActor, morphID, pureValue)
    NimorphusLog(Debug_Info, "ApplyMorphValueAdjustments: value returned " + adjustedValue)
    return adjustedValue
EndFunction

float Function GetMorphValueAdjustedbyRange(Actor kActor, String morphID, float pureValue)
    NimorphusLog(Debug_Info, "GetMorphValueAdjustedbyRange: Starting value returned " + pureValue)
    float clampedValue = 0.0
    float minMorphValue = -0.5
    float maxMorphValue = 2.5
    int morphIDRangeArray = 0    
    if JMap_hasKey(morphIDRange, morphID)
        morphIDRangeArray = JMap_getObj(morphIDRange, morphID)
        NimorphusLog(Debug_Info, "GetMorphValueAdjustedbyRange: morphRangeArray retrieved " + morphIDRangeArray)
        ; Ensure the min/max morph values are correctly retrieved
        minMorphValue = JArray_getFlt(morphIDRangeArray, 0)
        NimorphusLog(Debug_Info, "GetMorphValueAdjustedbyRange: minMorphValue retrieved " + minMorphValue)
        maxMorphValue = JArray_getFlt(morphIDRangeArray, 1)
        NimorphusLog(Debug_Info, "GetMorphValueAdjustedbyRange: maxMorphValue retrieved " + maxMorphValue)
    else
        ; Create the array if it doesn't exist with default values
        morphIDRangeArray = JArray_object()
        JValue_retain(morphIDRangeArray)
        ; Set default MinRange and MaxRange values
        minMorphValue = -1.0
        maxMorphValue = 1.0
        JArray_addFlt(morphIDRangeArray, minMorphValue)
        JArray_addFlt(morphIDRangeArray, maxMorphValue)
        JMap_setObj(morphIDRange, morphID, morphIDRangeArray)
        NimorphusLog(Debug_Info, "GetMorphValueAdjustedbyRange: morphRangeArray created and retained with defaults " + morphIDRangeArray)
    endif
    ; Clamp the value based on the min and max range
    if pureValue > maxMorphValue
        clampedValue = maxMorphValue
    elseif pureValue < minMorphValue
        clampedValue = minMorphValue
    else
        clampedValue = pureValue
    endif
    NimorphusLog(Debug_Info, "GetMorphValueAdjustedbyRange: clampedValue returned " + clampedValue)
    return clampedValue
endFunction

bool Function GetMorphModInfluence(String morphID, String modName)
    bool morphModInfluenceActive = false
    ; Check if the morphID and modName are valid (non-empty)
    if morphID == "" || modName == ""
        NimorphusLog(Debug_Error, "GetMorphModInfluence: Invalid morphID or modName (empty string)")
        return false ; Return false if the morphID or modName is invalid
    endif
    ; Check if the morphID exists in the main morphModInfluence map
    if JMap_hasKey(morphModInfluence, morphID)
        ; Retrieve the nested map for this morphID
        int modInfluenceMap = JMap_getObj(morphModInfluence, morphID)        
        ; Check if the modName has an influence value for this morph
        if JMap_hasKey(modInfluenceMap, modName)
            int modInfluenceValue = JMap_getInt(modInfluenceMap, modName)
            morphModInfluenceActive = (modInfluenceValue == 1) ; True if mod influence is 1
            NimorphusLog(Debug_Info, "GetMorphModInfluence: Found influence for mod " + modName + " on morphID " + morphID + " with value " + modInfluenceValue)
        else
            ; If no influence is set, default to true
            JMap_setInt(modInfluenceMap, modName, 1) ; Set default influence to true (1)
            morphModInfluenceActive = true
            NimorphusLog(Debug_Info, "GetMorphModInfluence: No specific influence for mod " + modName + " on morphID " + morphID + ". Defaulting to true.")
        endif
    else
        ; If morphID doesn't exist, create a new nested map for this morph
        int modInfluenceMap = JMap_object() ; Create new map for mods under this morphID
        JValue_retain(modInfluenceMap) ; Retain the map to prevent garbage collection
        
        ; Set default influence for the mod to true (1)
        JMap_setInt(modInfluenceMap, modName, 1)
        JMap_setObj(morphModInfluence, morphID, modInfluenceMap) ; Store the nested map
        morphModInfluenceActive = true
        NimorphusLog(Debug_Info, "GetMorphModInfluence: Created new influence map for morphID " + morphID + " and set default influence for mod " + modName)
    endif
    ; Log and return the result
    NimorphusLog(Debug_Info, "GetMorphModInfluence result: " + morphModInfluenceActive + " for morphID " + morphID + " and modName " + modName)
    return morphModInfluenceActive
EndFunction

; Function to retreive mod influence. 
bool Function GetModInfluence(String modName)
    if JMap_hasKey(modInfluence, modName)
        bool returnBool
        if JMap_getInt(modInfluence, modName) == 1 
            returnBool = true
        else
            returnBool = false
        endif
        NimorphusLog(Debug_Info, "GetModInfluence: value returned " + returnBool)
        return returnBool
    else
        SetModInfluence(modName, true) ; Set mod influence to TRUE if it doesn't exist
        NimorphusLog(Debug_Info, "GetModInfluence: value returned true")
        return true
    endif
EndFunction

; helper function to set mod influcne
Function SetModInfluence(String modName, bool isActive)
    int influenceValue = isActive as int ; Converts bool to int (True becomes 1, False becomes 0)
    JMap_setInt(modInfluence, modName, influenceValue) ; Directly set or update the value
EndFunction

; ====== This updates the actual actor(s)
; Update the actor's morph without updating the model weight
Function UpdateNiOverrideActorMorphs(Actor kActor, String morphID, String keyName, float newValue)
    if kActor
        ; Update the actor's body morph using NiOverride
        NiOverride.SetBodyMorph(kActor, morphID, keyName, newValue)
        NimorphusLog(Debug_Info, "UpdateNiOverrideActorMorphs: Actor "+kactor+" with morph ID "+morphID+" from mod "+keyName+" with value "+ newValue)
    else
        NimorphusLog(Debug_Error, "Failed to cast " + kActor + " to Actor in UpdateNiOverrideActorMorphs function.")
    endif
EndFunction

; Update the model weight separately when all changes are done
Function UpdateActorModelWeight(Actor kActor)
    if kActor
        NiOverride.UpdateModelWeight(kActor) ; Forces a refresh of the actor's appearance
        NimorphusLog(Debug_Info, "Model weight updated for Actor "+kActor)
    else
        NimorphusLog(Debug_Error, "Failed to cast " + kActor + " to Actor in UpdateActorModelWeight function.")
    endif
EndFunction