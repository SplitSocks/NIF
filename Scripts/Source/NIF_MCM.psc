ScriptName NIF_MCM extends SKI_ConfigBase

Import NIF_JCDomain

NIF_Main Property NIF_MainRef Auto

; JContainer Variables
int actorResetToggleID
int modInfluenceToggleIDs 
int minMorphIDRangeSliderIDs
int maxMorphIDRangeSliderIDs
int morphModInfluenceToggleIDs
int morphModInfluenceSliderIDs

; Flags for updating
bool modInfluenceUpdate = false
bool morphIDRangeUpdate = false
bool resetActorUpdate = false

; Arrays for updating
int resetActorsUpdateArray
int modInfluenceUpdateArray
int morphRangeUpdateArray
int morphModsUpdateArray

int morphsExchangeInputUpdate

; ========== DEBUGGING ==========
function NimorphusMCMLog(string msg)
    NIF_Mainref.NimorphusLog(NIF_Mainref.Debug_Info, "MCM: "+msg)
endFunction
; ========== END DEBUGGING ==========

Event OnInit()
    parent.oninit()
endEvent

Event OnConfigInit()
    Utility.Wait(1)  ; Allow NIF_MainRef load first.
    ModName = " Nimorphus"
    Pages = new string[7]
    Pages[0] = "Main"
    Pages[1] = "Registered Actors"
    Pages[2] = "Mod Influence"
    Pages[3] = "Morph Range"
    Pages[4] = "ModsPerMorph"
    Pages[5] = "ModsPerMorphPercentage"
    Pages[6] = "Morph Exchange"

    initializeNeededVariables()
EndEvent

event OnConfigOpen()
    initializeNeededVariables()
endEvent

function initializeNeededVariables()
    if !JValue_isExists(morphModsUpdateArray)
        morphModsUpdateArray = JArray_object()
        JValue_retain(morphModsUpdateArray)
        NimorphusMCMLog("morphModsUpdateArray was created " + morphModsUpdateArray)
    endif
    if  !JValue_isExists(resetActorsUpdateArray)
        resetActorsUpdateArray = JArray_object()
        JValue_retain(resetActorsUpdateArray)
        NimorphusMCMLog("resetActorsUpdateArray was created " + resetActorsUpdateArray)
    endif
    if  !JValue_isExists(modInfluenceUpdateArray)
        modInfluenceUpdateArray = JArray_object()
        JValue_retain(modInfluenceUpdateArray)
        NimorphusMCMLog("modInfluenceUpdateArray was created " + modInfluenceUpdateArray)
    endif
    if  !JValue_isExists(morphRangeUpdateArray)
        morphRangeUpdateArray = JArray_object()
        JValue_retain(morphRangeUpdateArray)
        NimorphusMCMLog("morphRangeUpdateArray was created " + morphRangeUpdateArray)
    endif
    if  !JValue_isExists(actorResetToggleID)
        actorResetToggleID = JMap_object()
        JValue_retain(actorResetToggleID)
        NimorphusMCMLog("actorResetToggleID was created " + actorResetToggleID)
    endif
    if  !JValue_isExists(modInfluenceToggleIDs)
        modInfluenceToggleIDs = JMap_object()
        JValue_retain(modInfluenceToggleIDs)
        NimorphusMCMLog("modInfluenceToggleIDs was created " + modInfluenceToggleIDs)
    endif
    if !JValue_isExists(minMorphIDRangeSliderIDs)
        minMorphIDRangeSliderIDs = JMap_object()
        JValue_retain(minMorphIDRangeSliderIDs)
        NimorphusMCMLog("minMorphIDRangeSliderIDs was created " + minMorphIDRangeSliderIDs)
    endif
    if !JValue_isExists(maxMorphIDRangeSliderIDs)
        maxMorphIDRangeSliderIDs = JMap_object()
        JValue_retain(maxMorphIDRangeSliderIDs)
        NimorphusMCMLog("maxMorphIDRangeSliderIDs was created " + maxMorphIDRangeSliderIDs)
    endif
    if !JValue_isExists(morphModInfluenceToggleIDs)
        morphModInfluenceToggleIDs = JMap_object()
        JValue_retain(morphModInfluenceToggleIDs)
        NimorphusMCMLog("morphModInfluenceToggleIDs was created " + morphModInfluenceToggleIDs)
    endif    
    if !JValue_isExists(morphModInfluenceSliderIDs)
        morphModInfluenceSliderIDs = JMap_object()
        JValue_retain(morphModInfluenceSliderIDs)
        NimorphusMCMLog("morphModInfluenceSliderIDs was created " + morphModInfluenceSliderIDs)
    endif
endFunction

event OnConfigClose()
    NimorphusMCMLog("modInfluenceUpdate flag is set to "+modInfluenceUpdate)
    NimorphusMCMLog("morphIDRangeUpdate flag is set to "+morphIDRangeUpdate)
    while Utility.IsInMenuMode()
        Utility.Wait(1.0) ; Wait for 1 second and check again
    endwhile
    ; Update all actors if MorphID ranges or ModInfluence is changed.   
    if modInfluenceUpdate == true
        NimorphusMCMLog("modInfluenceUpdate updates being with total count " + JArray_Count(modInfluenceUpdateArray))
        while JArray_Count(modInfluenceUpdateArray) > 0
            string modInfluenceName = JArray_getStr(modInfluenceUpdateArray, 0)
            NimorphusMCMLog("Mod Influence Update for mod "+modInfluenceName)
            NIF_MainRef.QueueUpdate(None, "", modInfluenceName, 0.0, 0, 1); We only care about the 1 at the end, the rest is ignored. This updates all morphIDs for the specific mod
            JArray_eraseIndex(modInfluenceUpdateArray, 0)
        endWhile
    endif
    if morphIDRangeUpdate == true
        NimorphusMCMLog("morphRangeUpdateArray updates begin with total count "+JArray_Count(morphRangeUpdateArray))
        while JArray_Count(morphRangeUpdateArray) > 0
            string morphID = JArray_getStr(morphRangeUpdateArray, 0)
            NimorphusMCMLog("Morph Range Update for morph "+morphID)
            NIF_MainRef.QueueUpdate(None, morphID, "", 0.0, 0, 2); We only care about the 1 at the end, the rest is ignored.
            JArray_eraseIndex(morphRangeUpdateArray, 0)
        endWhile
    endif
    if resetActorUpdate
        int resetActorCount = JArray_count(resetActorsUpdateArray)        
        int i = 0
        NimorphusMCMLog("OnConfigClose: Count is " + resetActorCount)
        while i < resetActorCount
            string kActorStr = JArray_GetStr(resetActorsUpdateArray, i)
            NIF_MainRef.ResetActorMorphs(kActorStr)
            i += 1
            NimorphusMCMLog("resetActorUpdate: Actor updated: " + kActorStr)
        endWhile
     endif
    modInfluenceUpdate = false
    morphIDRangeUpdate = false
    resetActorUpdate = false
endEvent

Event OnPageReset(string page)
    if page == "Main" 
        MainRender()
    elseif page == "Registered Actors"
        ActorsRendor()
    elseif page == "Mod Influence"
        ModInfluenceRender()
    elseif page == "Morph Range"
        MorphRangeRender()
    elseif page == "ModsPerMorph"
        ModsPerMorphRender()
    elseif page == "ModsPerMorphPercentage"
        ModsPerMorphPercentage()
    elseif page == "Morph Exchange"
        AddHeaderOption("Under Constrcution")
        ;MorphsExchange()
    endif
EndEvent

;--------- Page Functions
Function MainRender()
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("Hello!")
    AddTextOption(" I hope you will enjoy this mod!","")
    AddTextOption(" Please report any errors or bugs you encounter!","")
endfunction

Function ActorsRendor()
    ; Initialize the counter
    int i = 0
    int actorsArray = JFormMap_allKeys(NIF_MainRef.mapActorData)
    int numActors = JArray_count(actorsArray)
    ; Loop through actors and add them to the MCM as menu options
    AddHeaderOption("List of registered Actors")
    AddHeaderOption("Reset actors morphs")
    while i < numActors
        Form kActorForm = JArray_getForm(actorsArray, i) ; Get the actor's key as a string
        Actor kActor = kActorForm as Actor
        if kActor
            string kActorName = kActor.GetDisplayName()
            if i + 1 >= 4
                    AddTextOption(i + 1 + "th", kActorName) ; Use kActorName as the display option
                elseif i + 1 == 1
                    AddTextOption(i + 1 + "st", kActorName) ; Use kActorName as the display option
                elseif i + 1 == 2
                    AddTextOption(i + 1 + "nd", kActorName) ; Use kActorName as the display option
                elseif i + 1 == 3
                    AddTextOption(i + 1 + "rd", kActorName) ; Use kActorName as the display option               
            endif
            ;int actorResetToggle = AddToggleOption("Reset Actor's Morphs", false)
            ;string actorResetToggleStr = actorResetToggle as String
            ;JMap_setForm(actorResetToggleID, actorResetToggleStr, kActorForm)
        endif
        i += 1
    endwhile
    ; Add a message if no actors are found
    if numActors == 0
        AddTextOption("No registered actors found","")
    endif
EndFunction

Function ModInfluenceRender()
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("Toggle to turn off the mods morph changes")
    int i = 0    
    int modsArray = JMap_allKeys(NIF_MainRef.modInfluence)
    int numMods = JArray_count(modsArray)
    ; Loop through mods and add them to the MCM as menu options
    while i < numMods
        string modInfluenceModName = JArray_getStr(modsArray, i)
        int modInfluenceInt = JMap_getInt(NIF_MainRef.modInfluence, modInfluenceModName)
        bool tempBool = (JMap_getInt(NIF_MainRef.modInfluence, modInfluenceModName) == 1)
        int sliderID  = AddToggleOption(modInfluenceModName + " Influence", tempBool)
        string sliderIDStr = sliderID as string
        JMap_setStr(modInfluenceToggleIDs, sliderID, modInfluenceModName)
        i += 1
    endwhile
    ; Add a message if no mods are found
    if numMods == 0
        AddTextOption("No registered mods found", "")
    endif
EndFunction

Function MorphRangeRender()
    AddHeaderOption("Min Values")
    AddHeaderOption("Max Values")
    ; Initialize the first key
    string morphID = JMap_nextKey(NIF_MainRef.morphIDRange, "", "")
    ; Loop through the morphs using JMap_nextKey
    while morphID != ""
        int morphIDRangeArray = JMap_getObj(NIF_MAINref.morphIDRange, morphID) ; Get the JArray from the mapMorphIDRange
        float minValue = JArray_getFlt(morphIDRangeArray, 0) ; Min Value is always 0 index
        float maxValue = JArray_getFlt(morphIDRangeArray, 1) ; Max Value is always 1 index
        ; Add Min Slider            
        int minOption = AddSliderOption(morphID, minValue, "Value {1}")
        string minOptionStr = minOption as string
        JMap_setStr(minMorphIDRangeSliderIDs, minOptionStr, morphID)
        ; Add Max Slider
        int maxOption = AddSliderOption(morphID, maxValue, "Value {1}")
        string maxOptionStr = maxOption as string
        JMap_setStr(maxMorphIDRangeSliderIDs, maxOptionStr, morphID)
        ; Get the next morphID
        morphID = JMap_nextKey(NIF_MainRef.morphIDRange, morphID, "")
    endwhile
EndFunction

Function ModsPerMorphRender()
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("Toggle a mod to affect morph")    
    ; Initialize first morphID key from morphModInfluence map
    int testCount = JMap_count(NIF_MainRef.morphModInfluence)
    NimorphusMCMLog("ModsPerMorph: Starting total morphIDs = " + testCount)    
    string morphID = JMap_nextKey(NIF_MainRef.morphModInfluence, "", "")
    NimorphusMCMLog("ModsPerMorph: Starting with morphID = " + morphID)    
    ; Outer loop to iterate over morphIDs
    while morphID != ""
        ; Log current morphID
        NimorphusMCMLog("ModsPerMorph: Processing morphID = " + morphID)
        ; Add a header for each morph ID
        AddHeaderOption("Morph: " + morphID)        
        ; Retrieve the mod-per-morph influence map for the current morphID
        int modPerMorphMap = JMap_getObj(NIF_MainRef.morphModInfluence, morphID)
        if modPerMorphMap
            ; Initialize the first mod key for the current morphID
            string modInfluenceModName = JMap_nextKey(modPerMorphMap, "", "")            
            ; Inner loop to iterate over mods affecting the current morph
            while modInfluenceModName != ""
                ; Log the mod being processed
                NimorphusMCMLog("ModsPerMorph: Processing mod = " + modInfluenceModName + " for morphID = " + morphID)                
                ; Check if the mod already has an influence toggle for this morph
                bool isModAffectingMorph = (JMap_getInt(modPerMorphMap, modInfluenceModName) == 1)                
                ; Add the toggle for the mod's influence on this specific morph
                int morphModInfluenceToggleID = AddToggleOption("Allow " + modInfluenceModName + " to affect " + morphID, isModAffectingMorph)
                NimorphusMCMLog("ModsPerMorph: morphModInfluenceToggleID INT option = " + morphModInfluenceToggleID )                
                ; Log the values being stored
                string morphModInfluenceValue = (modInfluenceModName + ":" + morphID)
                NimorphusMCMLog("ModsPerMorph: Storing modMorphInfluenceValue: " + morphModInfluenceValue)
                ; Store the toggle ID for future reference
                string modInfluenceToggleIDStr = morphModInfluenceToggleID as string
                JMap_setStr(morphModInfluenceToggleIDs, modInfluenceToggleIDStr, morphModInfluenceValue)                
                ; Move to the next mod influence within the modPerMorphMap
                modInfluenceModName = JMap_nextKey(modPerMorphMap, modInfluenceModName, "")
            endwhile
        else
            NimorphusMCMLog("ModsPerMorph: No mods found for morphID = " + morphID)
        endif        
        ; Move to the next morphID in morphModInfluence
        morphID = JMap_nextKey(NIF_MainRef.morphModInfluence, morphID, "")
    endwhile
    NimorphusMCMLog("ModsPerMorph: ended")    
EndFunction

Function ModsPerMorphPercentage()
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("Adjust the percentage influence of each mod for each MorphID")    
    string morphID = JMap_nextKey(NIF_MainRef.morphModInfluence, "", "")
    while morphID != ""
        ; Add a header for the morphID
        AddHeaderOption("Morph: " + morphID)        
        int modPerMorphMap = JMap_getObj(NIF_MainRef.morphModInfluence, morphID)
        if modPerMorphMap
            string modInfluenceName = JMap_nextKey(modPerMorphMap, "", "")
            while modInfluenceName != ""
                ; Retrieve current percentage value
                float modInfluencePercentage = JMap_getFlt(modPerMorphMap, modInfluenceName)
                ; Add a slider for each mod, default to the stored percentage
                int modInfluenceSlider = AddSliderOption(modInfluenceName + " Influence", modInfluencePercentage, "Value {1}%")
                string sliderIDStr = modInfluenceSlider as string
                JMap_setStr(morphModInfluenceSliderIDs, sliderIDStr, modInfluenceName + ":" + morphID)                
                ; Move to next mod
                modInfluenceName = JMap_nextKey(modPerMorphMap, modInfluenceName, "")
            endwhile
        endif
        morphID = JMap_nextKey(NIF_MainRef.morphModInfluence, morphID, "")
    endwhile
EndFunction

Function MorphsExchange()
    AddHeaderOption("Original Morph ID")
    AddHeaderOption("New Morph ID")
    ; Initialize the counter
    int i = 0
    int allMorphIDs = JMap_allKeys(NIF_MainRef.morphIDRange)
    int allMorphIDsCount = JArray_Count(allMorphIDs)
    ; Loop through the morphs and add sliders for min/max values
    while i < allMorphIDsCount ; for each key in mapMorphID
        string originalMorphID = JArray_getStr(allMorphIDs, i) ; Get the morphID based on the count j
        ; add current morph
        AddTextOption("Current morphID", originalMorphID)
        ; Add input Option            
        int inputOptionID = addInputOption("Enter desired morphID", "Under Construction")
        ;JMap_setInt(morphsExchangeInputUpdate, morphID, inputOptionID)
        i += 1
    endwhile
endFunction

;--------- Sliders for the pages above
Event OnOptionSliderOpen(int a_option)
    string a_optionStr = a_option as string
    ; THIS IS FOR MORPH MIN SLIDERS
    if JMap_hasKey(minMorphIDRangeSliderIDs, a_optionStr)
        string morphID = JMap_getStr(minMorphIDRangeSliderIDs, a_optionStr) ; Get slider Name
        int morphArray = JMap_getObj(NIF_MainRef.morphIDRange, morphID)
        float currentValue = JArray_getFlt(morphArray, 0)
        ; Set the slider range and default values dynamically
        SetSliderDialogStartValue(currentValue)
        SetSliderDialogDefaultValue(-1)
        SetSliderDialogRange(-20.0, 0.0)
        SetSliderDialogInterval(0.1) ; Step value of .5
    endIf
    ; THIS IS FOR MORPH MAX SLIDERS
    if JMap_hasKey(maxMorphIDRangeSliderIDs, a_optionStr)
        string morphID = JMap_getStr(minMorphIDRangeSliderIDs, a_optionStr) ; Get slider Name
        int morphArray = JMap_getObj(NIF_MainRef.morphIDRange, morphID)
        float currentValue = JArray_getFlt(morphArray, 1)
        ; Set the slider range and default values dynamically
        SetSliderDialogStartValue(currentValue)
        SetSliderDialogDefaultValue(1)
        SetSliderDialogRange(0.0, 20.0)
        SetSliderDialogInterval(0.1) ; Step value of .5
    endIf
endevent

Event OnOptionSliderAccept(int a_option, float a_value)
    ; THIS IS FOR MORPH MIN SLIDERS
    string a_optionStr = a_option as string
    if JMap_hasKey(minMorphIDRangeSliderIDs, a_optionStr)
        string morphID = JMap_getStr(minMorphIDRangeSliderIDs, a_optionStr)
        UpdateMorphRange("Min", a_option, a_value, morphID, 0)
    endif
    if JMap_hasKey(maxMorphIDRangeSliderIDs, a_optionStr)
        string morphID = JMap_getStr(maxMorphIDRangeSliderIDs, a_optionStr)
        UpdateMorphRange("Max", a_option, a_value, morphID, 1)
    endif
    if JMap_hasKey(morphModInfluenceSliderIDs, a_optionStr)
        string modMorphID = JMap_getStr(morphModInfluenceSliderIDs, a_optionStr)
        String[] splitResult = StringUtil.Split(modMorphID, ":")
        String modNameSplit = splitResult[0]
        String morphIDSplit = splitResult[1]
        int modPerMorphMap = JMap_getObj(NIF_MainRef.morphModInfluence, morphIDSplit)
        float totalPercentage = 0.0
        float remainingPercentage = 100.0 - a_value
        ; Update this mod’s influence
        JMap_setFlt(modPerMorphMap, modNameSplit, a_value)        
        ; Rebalance the other mods
        string nextMod = JMap_nextKey(modPerMorphMap, "", "")
        while nextMod != ""
            if nextMod != modNameSplit
                float currentInfluence = JMap_getFlt(modPerMorphMap, nextMod)
                float newInfluence = (currentInfluence / totalPercentage) * remainingPercentage
                JMap_setFlt(modPerMorphMap, nextMod, newInfluence)
                SetSliderOptionValue(a_option, newInfluence, "Value {1}%")
            endif
            nextMod = JMap_nextKey(modPerMorphMap, nextMod, "")
        endwhile
    endif
EndEvent

; Helper Function for MorphID Ranges in OnOptionSliderAccept
Function UpdateMorphRange(string optionType, int a_option, float a_value, string morphID, int index)
    NimorphusMCMLog(optionType + " Morph Change begin for " + morphID)
    int morphIDRangeArray = JMap_getObj(NIF_MainRef.morphIDRange, morphID)
    JArray_setFlt(morphIDRangeArray, index, a_value)
    morphIDRangeUpdate = True
    SetSliderOptionValue(a_option, a_value, "Value {1}")
    if JArray_findStr(morphRangeUpdateArray, morphID) == -1
        JArray_addStr(morphRangeUpdateArray, morphID)
        NimorphusMCMLog("Added " + morphID + " to the morphRangeUpdateArray")
    endif
    NimorphusMCMLog("This option set a value " + a_value)
EndFunction

Event OnOptionSelect(int a_option)
    NimorphusMCMLog("OnOptionSelect: Current option is "+a_option)
    string a_optionStr = a_option as string
    ; THIS IS FOR MOD INFLUENCE TOGGLE
    if JMap_hasKey(modInfluenceToggleIDs, a_optionStr)
        string modID = JMap_getStr(modInfluenceToggleIDs, a_option)
        NimorphusMCMLog("OnOptionSelect: Mod found in ModInfluence "+modID)
        bool isInfluenceActive = (JMap_getInt(NIF_MainRef.modInfluence, modID) == 1) ; Get the boolean status of mod influence        
        if isInfluenceActive
            JMap_setInt(NIF_MainRef.modInfluence, modID, 0) ; Set to 0 if it was active
        else
            JMap_setInt(NIF_MainRef.modInfluence, modID, 1) ; Set to 1 if it was inactive
        endif
        SetToggleOptionValue(a_option, !isInfluenceActive) ; Set the toggle option to the opposite of current state
        if JArray_findStr(modInfluenceUpdateArray, modID) == -1
            JArray_addStr(modInfluenceUpdateArray, modID)
        endif
        modInfluenceUpdate = true
    endif
    ; THIS IS FOR RESET ACTOR TOGGLE
    if JMap_hasKey(actorResetToggleID, a_optionStr)
        Form kActorForm = JMap_getForm(actorResetToggleID, a_option)
        if  JArray_findForm(resetActorsUpdateArray, kActorForm) == -1
            JArray_addStr(resetActorsUpdateArray, kActorForm)
        endif
        SetToggleOptionValue(a_option, true)
        resetActorUpdate = true
        NimorphusMCMLog("OnOtionSelect for Actor Reset: resetActorsUpdateArray  " + resetActorsUpdateArray + " Actor reset  " + kActorForm + " ID")
        return ; Exit the loop once we find the correct slider 
    endif
    ; THIS IS FOR MORPH MOD INFLUENCE TOGGLE
    if JMap_haskey(morphModInfluenceToggleIDs, a_optionStr)
        NimorphusMCMLog("OnOptionSelect: morphModInfluenceToggleIDs option is " + a_option)    
        ; Retrieve the modName and morphID stored in morphModInfluenceToggleIDs
        string modMorphID = JMap_getStr(morphModInfluenceToggleIDs, a_optionStr)
        NimorphusMCMLog("OnOptionSelect: Retrieved modMorphID = " + modMorphID)    
        ; Split modMorphID into modName and morphID
        String[] splitResult = StringUtil.Split(modMorphID, ":")        
        if splitResult.Length >= 2
            String splitModName = splitResult[0]
            String splitMorphID = splitResult[1]    
            ; Additional log to check the split result
            NimorphusMCMLog("OnOptionSelect: After split - modName: " + splitModName + ", morphID: " + splitMorphID)    
            int morphModValueMap = JMap_getObj(NIF_MainRef.morphModInfluence, splitMorphID)
            int morphModActive = JMap_getInt(morphModValueMap, splitModName)
            bool isModActive = (morphModActive == 1)    
            ; Toggle the mod influence value
            if isModActive
                JMap_setInt(morphModValueMap, splitModName, 0)
                NimorphusMCMLog("OnOptionSelect: Disabling mod influence for " + splitModName + " on morphID " + splitMorphID)
            else
                JMap_setInt(morphModValueMap, splitModName, 1)
                NimorphusMCMLog("OnOptionSelect: Enabling mod influence for " + splitModName + " on morphID " + splitMorphID)
            endif            
            ; Update the MCM toggle
            SetToggleOptionValue(a_option, !isModActive)            
            morphIDRangeUpdate = True
            ; Add the morphID to the morphRangeUpdateArray if it's not already there
            if JArray_findStr(morphRangeUpdateArray, splitMorphID) == -1
                JArray_addStr(morphRangeUpdateArray, splitMorphID)
                
                NimorphusMCMLog("OnOptionSelect: Added morphID " + splitMorphID + " to morphRangeUpdateArray")
            endif
        else
            NimorphusMCMLog("OnOptionSelect: Split failed, invalid modMorphID format: " + modMorphID)
        endif
    endIf        
endEvent
;--------- Shared
event OnOptionDefault(int option)
endEvent
event OnOptionHighlight(int option)
endevent
Function displayChangedMorphs(string kActor)
EndFunction