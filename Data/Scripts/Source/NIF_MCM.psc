ScriptName NIF_MCM extends SKI_ConfigBase

; TODO
; Setup a map for mod influence and morphID ranges. On ConfigClose commit all changes wanted so user can keep changing. stuff
; Need to add a reset morphs button for when you just go a bit too crazy!

Import NIF_JCDomain
Import StringUtil

NIF_Main Property NIF_MainRef Auto
int Property modInfluenceSliderIDs Auto
int Property minMorphIDRangeSliderIDs Auto
int property maxMorphIDRangeSliderIDs Auto
int property allRegisteredMods Auto

int menuIDActorSelect
int menuIDActorSelectIndex = 0
string[] menuIDActorNamesArray
string menuIDActorSelectDisplayName
string selectedActorFormIDallRegisteredMods
int selectedActorInt


Event OnInit()
    parent.oninit()
endEvent

Event OnConfigInit()
    Utility.Wait(1)  ; Allow NIF_MainRef load first.
    ModName = " Nefaram Inflation Framework"
    Pages = new string[4]
    Pages[0] = "Main"
    Pages[1] = "Registered Actors"
    Pages[2] = "Registered Mods"
    Pages[3] = "Registered Morphs"
EndEvent

event OnConfigOpen()
    MiscUtil.PrintConsole(modInfluenceSliderIDs + " modInfluenceSliderIDs")
    MiscUtil.PrintConsole(minMorphIDRangeSliderIDs + " minMorphIDRangeSliderIDs")
    MiscUtil.PrintConsole(maxMorphIDRangeSliderIDs + " maxMorphIDRangeSliderIDs")
    MiscUtil.PrintConsole(allRegisteredMods + " allRegisteredMods")

    if  !JValue_isExists(modInfluenceSliderIDs)
        modInfluenceSliderIDs = JMap_object()
        JValue_retain(modInfluenceSliderIDs)
        MiscUtil.PrintConsole(modInfluenceSliderIDs + " new modInfluenceSliderIDs")
    endif
    if !JValue_isExists(minMorphIDRangeSliderIDs)
        minMorphIDRangeSliderIDs = JMap_object()
        JValue_retain(minMorphIDRangeSliderIDs)
        MiscUtil.PrintConsole(minMorphIDRangeSliderIDs + " new minMorphIDRangeSliderIDs")
    endif
    if !JValue_isExists(maxMorphIDRangeSliderIDs)
        maxMorphIDRangeSliderIDs = JMap_object()
        JValue_retain(maxMorphIDRangeSliderIDs)
        MiscUtil.PrintConsole(maxMorphIDRangeSliderIDs + " new  maxMorphIDRangeSliderIDs")
    endif
    if !JValue_isExists(allRegisteredMods)        
        allRegisteredMods = JMap_allKeys(NIF_MainRef.modInfluence)
        JValue_retain(allRegisteredMods)
        MiscUtil.PrintConsole(allRegisteredMods + " new allRegisteredMods")
    endif
endEvent

event OnConfigClose()
    
endEvent

Event OnPageReset(string page)
    if page == "Main" 
        MainRender()
    elseif page == "Registered Actors"
        ActorsRendor()
    elseif page == "Registered Mods"
        ModsRender()
    elseif page == "Registered Morphs"
        MorphsRender()
    elseif page == "Morphs per Mod"
        MorphsModRender()
    endif
EndEvent


;--------- Page Functions

Function MainRender()
    SetCursorFillMode(TOP_TO_BOTTOM)
endfunction

Function ActorsRendor()
    SetCursorFillMode(TOP_TO_BOTTOM)
    ; Initialize the counter
    int i = 0
    int allRegisteredActors = JMap_allKeys(NIF_MainRef.mapActorMorphID)
    int numActors = JArray_Count(allRegisteredActors)    
    ; Loop through actors and add them to the MCM as menu options
    while i < numActors
        string kActorString = JArray_getStr(allRegisteredActors, i) ; Get the actor's key as a string
        int kActorInt = kActorString as int ; Convert the string to an integer (FormID)
        Form kActorForm = Game.GetForm(kActorInt) ; Get the form using the FormID
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
        endif
        i += 1
    endwhile
    ; Add a message if no actors are found
    if numActors == 0
        AddTextOption("No registered actors found", "")
    endif
    JValue_clear(allRegisteredActors)
EndFunction

Function ModsRender()
    SetCursorFillMode(TOP_TO_BOTTOM)
    ; Initialize the counter
    ; Ensure we don’t exceed 50 mods for now
    JValue_clear(allRegisteredMods)
    allRegisteredMods = JMap_allKeys(NIF_MainRef.modInfluence)
    int i = 0    
    int numMods = JArray_Count(allRegisteredMods)
    ; Loop through mods and add them to the MCM as menu options
    while i < numMods
        string modInfluenceModName = JArray_getStr(allRegisteredMods, i)
        float modInfluenceFloat = JMap_getFlt(NIF_MainRef.modInfluence, modInfluenceModName)
        int sliderID  = AddSliderOption(modInfluenceModName + " Influence", modInfluenceFloat, "{0}%")
        JMap_setInt(modInfluenceSliderIDs, modInfluenceModName, sliderID)
        i += 1
    endwhile
    ; Add a message if no mods are found
    if numMods == 0
        AddTextOption("No registered mods found", "")
    endif
EndFunction

Function MorphsRender()
    AddTextOption("Min Values","")
    AddTextOption("Max Values","")
    float minValue
    float maxValue
    ; Initialize the counter
    int i = 0
    int allMorphIDs = JMap_allKeys(NIF_MainRef.morphIDRange)
    int allMorphIDsCount = JArray_Count(allMorphIDs)
    ; Loop through the morphs and add sliders for min/max values
    while i < allMorphIDsCount ; for each key in mapMorphID
        string morphID = JArray_getStr(allMorphIDs, i) ; Get the morphID based on the count j
        int arrayMorphIDRange = JMap_getObj(NIF_MainRef.morphIDRange, morphID) ; Get the JArray from the mapMorphIDRange
        minValue = JArray_getFlt(arrayMorphIDRange, 0) ; Min Value is always 0 index
        maxValue = JArray_getFlt(arrayMorphIDRange, 1) ; Max Value is always 1 index
        ; Add Min Slider            
        int minOption = AddSliderOption(morphID, minValue, "Min Moprh Value {1}")
        JMap_setInt(minMorphIDRangeSliderIDs, morphID, minOption)
        ; Add Max Slider
        int maxOption = AddSliderOption(morphID, maxValue, "Max morph Value {1}")
        JMap_setInt(maxMorphIDRangeSliderIDs, morphID, maxOption)
        i += 1
    endwhile
EndFunction

Function MorphsModRender()
endFunction

;--------- Sliders for the pages above
Event OnOptionSliderOpen(int a_option)
    MiscUtil.PrintConsole(a_option + " a_option")
    ; THIS IS FOR MOD INFLUENCE SLIDERS
    int i = 0
    int maxModCount = JArray_count(allRegisteredMods)
    while i < maxModCount
        string modInfluenceModName = JMap_getNthKey(modInfluenceSliderIDs, i)
        int sliderID = JMap_getInt(modInfluenceSliderIDs, modInfluenceModName)
        MiscUtil.PrintConsole(sliderID + " sliderID was found under ModInfluenceSliders")
        if sliderID == a_option       
            float currentModInfluence = JMap_getFlt(NIF_MainRef.modInfluence, modInfluenceModName)
            ; Set the slider range and default values dynamically
            SetSliderDialogStartValue(currentModInfluence)
            SetSliderDialogDefaultValue(currentModInfluence)
            SetSliderDialogRange(0.0, 100.0) ; Assuming it's 0-100% influence
            SetSliderDialogInterval(1.0) ; Step value of 1%
            return ; Exit the loop once we find the correct slider
        endif
        i += 1
    endwhile
    ; THIS IS FOR MORPH MIN SLIDERS
    int countMinMorphIDs = JMap_Count(minMorphIDRangeSliderIDs)
    int j = 0
    while j < countMinMorphIDs
        string minModMorphID = JMap_getNthKey(minMorphIDRangeSliderIDs, j) ; Get slider Name
        int sliderID = JMap_getInt(minMorphIDRangeSliderIDs, minModMorphID) ; Get slider INT based on name
        MiscUtil.PrintConsole(sliderID + " sliderID was found under Min Sliders")
        if sliderID == a_option ; Is the int the same as a_option?
            MiscUtil.PrintConsole(sliderID + " sliderID")
            int morphArray = JMap_getObj(NIF_MainRef.morphIDRange, minModMorphID)
            float currentMinMorphValue = JArray_getFlt(morphArray, 0)
            ; Set the slider range and default values dynamically
            SetSliderDialogStartValue(currentMinMorphValue)
            SetSliderDialogDefaultValue(currentMinMorphValue)
            SetSliderDialogRange(-20.0, 0.0)
            SetSliderDialogInterval(0.1) ; Step value of .5
            return ; Exit the loop once we find the correct slider
        endif
        j += 1
    endwhile
    ; THIS IS FOR MORPH MAX SLIDERS
    int k = 0
    int countMaxMorphIDs = JMap_Count(maxMorphIDRangeSliderIDs)
    while k < countMaxMorphIDs
        string maxModMorphID = JMap_getNthKey(maxMorphIDRangeSliderIDs, k) ; Get slider Name
        int sliderID = JMap_getInt(maxMorphIDRangeSliderIDs, maxModMorphID) ; Get slider INT based on name
        MiscUtil.PrintConsole(sliderID + " sliderID was found under Max Sliders")
        if sliderID == a_option ; Is the int the same as a_option?
            MiscUtil.PrintConsole(sliderID + " sliderID")
            int morphArray = JMap_getObj(NIF_MainRef.morphIDRange, maxModMorphID)
            float currentMaxMorphValue = JArray_getFlt(morphArray, 1)
            ; Set the slider range and default values dynamically
            SetSliderDialogStartValue(currentMaxMorphValue)
            SetSliderDialogDefaultValue(currentMaxMorphValue)
            SetSliderDialogRange(0.0, 20.0)
            SetSliderDialogInterval(0.1) ; Step value of .5
            return ; Exit the loop once we find the correct slider
        endif
        k += 1
    endwhile
endevent

Event OnOptionSliderAccept(int a_option, float a_value) ; NEED TO ADD A QUEUE TO UPDATE AFTER CONFIG CLOSE SO USERS CAN MAKE MULTIPLE CHANGES
    Miscutil.PrintConsole("Started on accept")
    int i = 0
    int maxCount = JMap_count(modInfluenceSliderIDs)
    while i < maxCount
        string sliderIDModName = JMap_getNthKey(modInfluenceSliderIDs, i)
        int sliderID = JMap_getInt(modInfluenceSliderIDs, sliderIDModName)
        string modInfluenceModName
        if sliderID == a_option
            modInfluenceModName = JArray_getStr(allRegisteredMods, i)
            NIF_MainRef.QueueModInfluenceUpdate(modInfluenceModName, a_value)
            MiscUtil.PrintConsole("Sent ModInfluence Update")
        endif
        i += 1        
    endwhile
    int countMinMorphIDs = JMap_Count(minMorphIDRangeSliderIDs)
    int j = 0
    while j < countMinMorphIDs
        string minModMorphID = JMap_getNthKey(minMorphIDRangeSliderIDs, k) ; Get slider Name
        int sliderID = JMap_getInt(minMorphIDRangeSliderIDs, minModMorphID) ; Get slider INT based on name
        if sliderID == a_option ; Is the int the same as a_option?
            NIF_MainRef.QueueMorphIDRangeUpdate(minModMorphID, a_value, 0)
            MiscUtil.PrintConsole("Sent Morph ID Range Update")
        endIf
        j = 1
    endWhile
    int k = 0
    int countMaxMorphIDs = JMap_Count(maxMorphIDRangeSliderIDs)
    while k < countMaxMorphIDs
        string maxModMorphID = JMap_getNthKey(maxMorphIDRangeSliderIDs, k) ; Get slider Name
        int sliderID = JMap_getInt(maxMorphIDRangeSliderIDs, maxModMorphID) ; Get slider INT based on name        
        if sliderID == a_option ; Is the int the same as a_option?
            NIF_MainRef.QueueMorphIDRangeUpdate(maxModMorphID, a_value, 1)
            MiscUtil.PrintConsole("Sent Morph ID Range Update")
        endif
        k += 1
    endWhile
EndEvent

;--------- Menus for the pages above
Event OnOptionMenuOpen(int a_option)
    if a_option == 105234
        ; code
    elseif a_option == menuIDActorSelect
        ; This event is triggered when any menu is opened
        int i = 0
        int allRegisteredActors = JMap_allKeys(NIF_MainRef.mapActorMorphID)
        menuIDActorNamesArray = JArray_asStringArray(allRegisteredActors)
        SetMenuDialogOptions(menuIDActorNamesArray)
        if menuIDActorSelectIndex > -1
            SetMenuDialogStartIndex(menuIDActorSelectIndex)
        endif       
    endif
    ;SetMenuOptionValue(int a_option, string a_value, bool a_noUpdate)
endEvent

Event OnOptionMenuAccept(int a_option, int a_index)
    if a_option == menuIDActorSelect
        menuIDActorSelectIndex = a_index
        string menuIDActorNamesArrayIndex = menuIDActorNamesArray[a_index]
        menuIDActorSelectDisplayName = menuIDActorNamesArrayIndex
        SetMenuOptionValue(a_option, menuIDActorSelectDisplayName)
    endif
endEvent

;--------- Shared
event OnOptionDefault(int option)
endEvent
event OnOptionHighlight(int option)
endevent
Function displayChangedMorphs(string kActor)
EndFunction