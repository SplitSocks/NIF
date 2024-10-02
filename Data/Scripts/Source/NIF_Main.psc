ScriptName NIF_Main extends Quest

Import NIF_JCDomain
import NiOverride

int property mapActorMorphID Auto ; JMap of Actors Keys and JMap of Morph ID Keys and Mod Values
int property modInfluence Auto; JMap of morph percentages per mod
int property morphIDRange Auto; JMap morph ID min and max range

int  QueueUpdateArray ; Queue for actor updates
Bool isProcessing = False ; To handle queue processing
int queuedActors
int QueueUpdateArrayModInfluence ; Queue for Mod Influence updates
bool isProcessingModInfluence = False ; to handle queue processing
int QueueUpdateArrayMorphRange ; Queue for Morph ID Range updates
bool isProcessingMorphRange = False ; to handle queue for morph id range processing

form Property PlayerRef Auto; Player Ref

bool isInitialized = false

; ========== Loading ==========
; its onInit, I shouldn't have to explain this part. I don't even know what it does
Event onInit()
    if !isInitialized    
        if JContainers.isInstalled() == false
            MiscUtil.PrintConsole("You didn't install JContainers. Why?")
        Else
            loadJContainerReferences()
            isInitialized = true
            MiscUtil.PrintConsole("Welcom to the Nefaram Inflation Framework")
        endif        
    endif
    RegisterForModEvent("NIF_ExternalModEvent", "onExternalModEvent")
EndEvent

event OnPlayerLoadGame()
    onInit()
    MiscUtil.PrintConsole("Welcom back to the Nefaram Inflation Framework")
endevent

; Loads all JConatiners needed
function loadJContainerReferences()
    if QueueUpdateArray == 0
        QueueUpdateArray = JArray_object()
        JValue_retain(QueueUpdateArray)
    endif
    if queuedActors == 0
        queuedActors = JArray_object()
        JValue_retain(queuedActors)
    endif
    if QueueUpdateArrayModInfluence == 0
        QueueUpdateArrayModInfluence = JArray_object()
        JValue_retain(QueueUpdateArrayModInfluence)
    endif
    if QueueUpdateArrayMorphRange == 0
        QueueUpdateArrayMorphRange = JArray_object()
        JValue_retain(QueueUpdateArrayMorphRange)
    endif
    if mapActorMorphID == 0
        mapActorMorphID = JMap_object()
        JValue_retain(mapActorMorphID)
    endif
    if modInfluence == 0
        modInfluence = JMap_object()
        JValue_retain(modInfluence)
    endif
    if morphIDRange == 0
        morphIDRange = JMap_object()
        JValue_retain(morphIDRange)
    endif  
endfunction


; ========== Main Process Line ==========
; Listener for events from external mods
Event OnExternalModEvent(Form kActor, String morphID, String keyName, float value, int replaceOrUpdate)
    MiscUtil.PrintConsole("Event received from external mod for actor: " + kActor + " with morphID: " + morphID + " from mod " + keyName + " with value " + value)
    ; Ensure the actor is valid before queuing the update
    if kActor != None
        QueueUpdate(kActor, morphID, keyName, value, replaceOrUpdate)
    else
        MiscUtil.PrintConsole("Invalid actor in event.")
    endif
EndEvent

; The queue called by the listner to register mod reqeusts
Function QueueUpdate(Form kActor, String morphID, String keyName, float value, int replaceOrUpdate)
    if kActor == None
        Debug.Notification("Error: Target actor is None. Skipping this event.")
        return
    endif
    int QueueUpdateArrayInfo = JArray_object()
    JValue_retain(QueueUpdateArrayInfo)
    JArray_addform(QueueUpdateArrayInfo, kActor, 0)
    JArray_addStr(QueueUpdateArrayInfo, morphID, 1)
    JArray_addStr(QueueUpdateArrayInfo, keyName, 2)
    JArray_addFlt(QueueUpdateArrayInfo, value, 3)
    JArray_addInt(QueueUpdateArrayInfo, replaceOrUpdate, 4)
    JArray_addObj(QueueUpdateArray, QueueUpdateArrayInfo)
    ; If processing isn't already happening, start it
    if !isProcessing
        isProcessing = True
        ProcessQueue()
    endif
EndFunction

; Processes all updates with a .1 wait time and should be adjusted with testing
Function ProcessQueue()
    ; Check if the queue has entries, Process each entry in the queue
    while JArray_count(QueueUpdateArray) > 0
        int QueueUpdateArrayInfo = JArray_getObj(QueueUpdateArray, 0)
        Actor kActor = JArray_getForm(QueueUpdateArrayInfo, 0) as actor
        String morphID = JArray_getStr(QueueUpdateArrayInfo, 1)
        String keyName = JArray_getStr(QueueUpdateArrayInfo, 2)
        float value = JArray_getFlt(QueueUpdateArrayInfo, 3)
        Int replaceOrUpdate = JArray_getInt(QueueUpdateArrayInfo, 4)
        int updateType = JArray_getInt(QueueUpdateArrayInfo, 5)
        if kActor == None
            MiscUtil.PrintConsole("Error: Invalid actor reference for " + kActor)
            isProcessing = False
            return
        endif
        if morphID != ""
            UpdateTrackedMorphs(kActor, morphID, keyName, value, replaceOrUpdate)       
            MiscUtil.PrintConsole("Updated actor morph ID from mod") 
            if JArray_findForm(queuedActors, kActor) == -1
                MiscUtil.PrintConsole("Added Actor to Array")
                JArray_addForm(queuedActors, kActor)
            endif
        else
            MiscUtil.PrintConsole("Warning: Empty morphID encountered.")
        endif        
        JArray_eraseIndex(QueueUpdateArray,0)
        JValue_release(QueueUpdateArrayInfo)
        Utility.Wait(0.1)
    endwhile
    While JArray_count(queuedActors) > 0
        MiscUtil.PrintConsole("Started Actor update")
        form kActorForm = JArray_getForm(queuedActors, 0)
        Actor kActor = kActorForm as Actor
        UpdateSpecificActorMorphs(kActor)
        JArray_eraseIndex(queuedActors,0)
    EndWhile
    isProcessing = False
EndFunction

; Function to track morph changes per actor and mod
Function UpdateTrackedMorphs(Actor kActor, String morphID, String modName, float morphValue, int replaceOrUpdate)
    int kActorFormID = kActor.GetFormID()
    string kActorStr = kActorFormID
    int mapMorphID = GetOrCreateJMap(mapActorMorphID, kActorStr) ; Get or create the mapMorphID for the given kActor
    int mapModValue = GetOrCreateJMap(mapMorphID, morphID) ; Get or create the mapModValue for given morphID
    if replaceOrUpdate == 0 ; Replace value
        JMap_setFlt(mapModValue, modName, morphValue)
    elseif replaceOrUpdate == 1 ; Update value
        float currentValue = getCurentMorphValueOfSpecificMod(mapModValue, modName) ; This calls the function getCurrentMorphValue in case the morph value is null it will return 0
        float newMorphValue = currentValue + morphValue
        JMap_setFlt(mapModValue, modName, newMorphValue)
    endif
EndFunction

; Helper function for UpdateTrackedMorphs || to retrieve or create and retain a JMap for the given key
int Function GetOrCreateJMap(int parentJMap, String mapKey)
    int returnJMap = 0
    if JMap_hasKey(parentJMap, mapKey)
        returnJMap = JMap_getObj(parentJMap, mapKey)
    else
        returnJMap = JMap_object() ; Create a new JMap
        JValue_retain(returnJMap)  ; Retain the new JMap
        JMap_setObj(parentJMap, mapKey, returnJMap)
    endif
    return returnJMap
EndFunction

; ========== Mod Influence Process Line ==========
Function QueueModInfluenceUpdate(string modName, float a_value)
    int QueueModInfluenceUpdateArrayInfo = JArray_object()
    JValue_retain(QueueModInfluenceUpdateArrayInfo)
    JArray_addStr(QueueModInfluenceUpdateArrayInfo, modName, 0)
    JArray_addFlt(QueueModInfluenceUpdateArrayInfo, a_value, 1)
    JArray_addObj(QueueUpdateArrayModInfluence, QueueModInfluenceUpdateArrayInfo)
    ; If processing isn't already happening, start it
    if !isProcessingModInfluence
        isProcessingModInfluence = True
        ProcessModInflucenQueue()
    endif
endfunction

Function ProcessModInflucenQueue()
    while Utility.IsInMenuMode()
        Utility.Wait(1.0)
    endWhile
    while JArray_count(QueueUpdateArrayModInfluence) > 0
        int QueueModInfluenceUpdateArrayInfo = JArray_getObj(QueueUpdateArrayModInfluence, 0)
        string modName = JArray_getStr(QueueModInfluenceUpdateArrayInfo, 0)
        float modValue = JArray_getFlt(QueueModInfluenceUpdateArrayInfo, 1)    
        if modName != ""
            JMap_setFlt(modInfluence, modName, modValue)            
            MiscUtil.PrintConsole("Updated ModInfluence " + modName)
        else
            MiscUtil.PrintConsole("Warning: Empty modName encountered.")
        endif
        JArray_eraseIndex(QueueUpdateArrayModInfluence,0)
        JValue_release(QueueModInfluenceUpdateArrayInfo)
        Utility.Wait(0.1)
    endwhile
    UpdateAllActorMorphs()
    isProcessingModInfluence = False
endFunction

; ========== MorphIDRange Process Line ==========
Function QueueMorphIDRangeUpdate(string morphID, float a_value, int minOrMax)
    int QueueUpdateArrayMorphRangeArrayInfo = JArray_object()
    JValue_retain(QueueUpdateArrayMorphRangeArrayInfo)
    JArray_addStr(QueueUpdateArrayMorphRangeArrayInfo, morphID, 0)
    JArray_addFlt(QueueUpdateArrayMorphRangeArrayInfo, a_value, 1)
    JArray_addInt(QueueUpdateArrayMorphRangeArrayInfo, minOrMax, 2)
    JArray_addObj(QueueUpdateArrayMorphRange, QueueUpdateArrayMorphRangeArrayInfo)
    ; If processing isn't already happening, start it
    if !isProcessingMorphRange
        isProcessingMorphRange = True
        ProcessMorphIDRangeQueue()
    endif
endFunction

Function ProcessMorphIDRangeQueue()
    while Utility.IsInMenuMode()
        Utility.Wait(1.0)
    endWhile
    while JArray_count(QueueUpdateArrayMorphRange) > 0
        int QueueUpdateArrayMorphRangeArrayInfo = JArray_getObj(QueueUpdateArrayMorphRange, 0)
        string morphID = JArray_getStr(QueueUpdateArrayMorphRangeArrayInfo, 0)
        float morphValue = JArray_getFlt(QueueUpdateArrayMorphRangeArrayInfo, 1)
        int minOrmax = JArray_getInt(QueueUpdateArrayMorphRangeArrayInfo, minOrMax, 2)
        if morphID != ""
            int morphRangeArray = JMap_getObj(morphIDRange, morphID)
            if minorMax == 0
                JArray_setFlt(morphRangeArray, minOrmax, morphValue)
            elseif minOrMax == 1
                JArray_setFlt(morphRangeArray, minOrmax, morphValue)
            endif
            MiscUtil.PrintConsole("Updated MorphID " + morphID)
        else
            MiscUtil.PrintConsole("Warning: Empty modName encountered.")
        endif        
        JArray_eraseIndex(QueueUpdateArrayMorphRange,0)
        JValue_release(QueueUpdateArrayMorphRangeArrayInfo)
        Utility.Wait(0.1)
    endwhile
    UpdateAllActorMorphs()
    isProcessingMorphRange = False
endFunction

; ========== Update Actor Morphs Process Line ==========
Function UpdateAllActorMorphs()
    int i = 0
    int kActorCount = JMap_Count(mapActorMorphID)
    int kActorArray = JMap_allKeys(mapActorMorphID)
    int mapMorphID
    while i < kActorCount        
        string tempActorName = JArray_getStr(kActorArray, i)
        mapMorphID = JMap_getObj(mapActorMorphID, tempActorName)
        int tempActorInt = tempActorName as int ; Get the kActor as int
        Form kActorForm = Game.GetForm(tempActorInt) ; Change to Form
        Actor kActor = kActorForm as Actor ; Change to Actor
        if kActor ; kActor is valid
            int j = 0
            int totalMorphs = JMap_Count(mapMorphID)
            while j < totalMorphs
                string morphIDFound = JMap_getNthKey(mapMorphID, j)
                int mapModMorph = JMap_getObj(mapMorphID, morphIDFound)
                float newValue = GetCombinedMorphValue(kActor, morphIDFound)
                UpdateActorMorphs(kActor, morphIDFound, "NIF ModInfluenceUpdate", newValue)
                j += 1
            endwhile
        endif
        i += 1
    endWhile
endFunction

Function UpdateSpecificActorMorphs(actor kActor)
    int kActorFormID = kActor.GetFormID()
    string kActorStr = kActorFormID
    int mapMorphID = JMap_getObj(mapActorMorphID, kActorStr)
    if kActor ; kActor is valid
        int j = 0
        int totalMorphs = JMap_Count(mapMorphID)
        while j < totalMorphs
            string morphIDFound = JMap_getNthKey(mapMorphID, j)
            float newValue = GetCombinedMorphValue(kActor, morphIDFound)
            UpdateActorMorphs(kActor, morphIDFound, "NIF ModInfluenceUpdate", newValue)
            MiscUtil.PrintConsole("Updated Actor "+kactor+" with morph ID "+morphIDFound)
            j += 1
        endwhile
    endif
endFunction

; Update the actor!
Function UpdateActorMorphs(actor kActor, String morphID, String keyName, float newValue)
    ; Cast the form to Actor to ensure it can be used with NiOverride
    if kActor
        ; Update the actor's body morph using NiOverride
        NiOverride.SetBodyMorph(kActor, morphID, keyName, newValue)
        ; You can optionally update the actor's 3D model to reflect the morph changes
        NiOverride.UpdateModelWeight(kActor) ; Forces a refresh of the actor's appearance
    else
        MiscUtil.PrintConsole("Failed to cast " + kActor + " to Actor in UpdateActorMorphs function.")
    endif
EndFunction

; ========== Helper Functions ==========
; Constrains the morphID by ModInfluence, Morph Range and mod specific morph range
float Function GetCombinedMorphValue(actor kActor, String morphID)
    int kActorFormID = kActor.GetFormID()
    string kActorStr = kActorFormID
    int mapMorphID = JMap_getObj(mapActorMorphID, kActorStr) ; Get the mapMorphID for the given kActor
    int mapModValue = JMap_getObj(mapMorphID, morphID) ; Get the mapModValue for given morphID
    int i = 0 ; Set counter
    int mapModValueCount = JMap_count(mapModValue) ; get length of mapMorphID
    float totalMorphValue = 0.0 ; define totalMprhValue    
    while i < mapModValueCount        
        string modKey = JMap_getNthKey(mapModValue, i) ; Retreive the modName for retreived mapModValue
        float retreivedValue = JMap_getFlt(mapModValue, modKey)
        float constrainedInfluenceValue = getMorphValueConstrainedByModInfluence(modkey, retreivedValue)
        totalMorphValue +=  constrainedInfluenceValue; Add value of the mapModValue to totalMorphValue
        i += 1 ; increment by 1
    endwhile
    float constrainedTotalMorphValue = GetTotalValueAdjustedbyMorphRange(morphID, totalMorphValue)
    return constrainedTotalMorphValue
EndFunction

; Helper function get mod influence and creates an influence if the mod has requested the first time
float Function getModInfluence (string modName)
    float modInfluenceValue = 100.0
    If JMap_hasKey(modInfluence, modName) == true
        modInfluenceValue = JMap_getFlt(modInfluence, modName)
    Else
        JMap_setFlt(modInfluence, modName, modInfluenceValue)
    EndIf
    return modInfluenceValue
endFunction

; Helper function for GetCombinedMorphValue || Adjusts the incoming total value to the morphID Range
float Function GetTotalValueAdjustedbyMorphRange(string morphID, float Value)
    int arrayMorphIDRange
    float morphID_min = -1.0
    float morphID_max = 4.0
    if JMap_hasKey(morphIDRange, morphID)
        arrayMorphIDRange = JMap_getObj(morphIDRange, morphID)
        morphID_min = JArray_getFlt(arrayMorphIDRange, 0)
        morphID_max = JArray_getFlt(arrayMorphIDRange, 1)
    Else ; Create the array if it doesn't exist
        arrayMorphIDRange = JArray_object() ; Create a new JArray
        JValue_retain(arrayMorphIDRange) ; Retain the new JArray
        JArray_addFlt(arrayMorphIDRange, morphID_min) ; Add min to array
        JArray_addFlt(arrayMorphIDRange, morphID_max) ; Add max to array
        JMap_setObj(morphIDRange, morphID, arrayMorphIDRange) ; Store the new array in the JMap
    endif
    if value < morphID_min
        value = morphID_min
    endif
    if value > morphID_max
        value = morphID_max
    endif
    return value
endfunction

; Helper function for GetCombinedMorphValue || Constrain morph value by the mod before adding to total
float Function getMorphValueConstrainedByModInfluence(string modName, float morphValue)
    float foundModInfluence = getModInfluence(modName)
    float adjustedValue = foundModInfluence / 100
    float calculatedValue = adjustedValue * morphValue
    return calculatedValue
endFunction
; Helper Function || get the current float in the map requested, if none received return 0
Float Function getCurentMorphValueOfSpecificMod(int mapModValue, String modName)
    float returnMorphValue
    If JMap_hasKey(mapModValue, modName)
        returnMorphValue = JMap_getFlt(mapModValue, modName)
    Else
        returnMorphValue = 0
    EndIf
    return returnMorphValue
EndFunction