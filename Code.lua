local addonName, pp = ...
local potionMacroName = "PPAutoPot"
local flaskMacroName = "PPAutoFlask"
local legacyPhialMacroName = "PPAutoPhial"

flaskPrefix = "Flask"
potionPrefix = "Potion"

local function createMacroIfMissing()
    if GetMacroInfo(potionMacroName) == nil then
        CreateMacro(potionMacroName, "INV_Misc_QuestionMark")
    end
    if GetMacroInfo(flaskMacroName) == nil then
        CreateMacro(flaskMacroName, "INV_Misc_QuestionMark")
    end
    -- Keep legacy compatibility for users with existing PPAutoPhial bindings/macros.
    if GetMacroInfo(legacyPhialMacroName) == nil then
        CreateMacro(legacyPhialMacroName, "INV_Misc_QuestionMark")
    end
end

local function buildMacroString(items)
    local resetType = "combat"
    local itemsString = ""
    if next(items) == nil then
        return "#showtooltip"
    else
        if next(items) ~= nil then
            for i, v in ipairs(items) do
                if i == 1 then
                    itemsString = "item:" .. v;
                else
                    itemsString = itemsString .. ", " .. "item:" .. v;
                end
            end
        end
        return "#showtooltip \n/castsequence reset=" .. resetType .. " " .. itemsString
    end
end

local function updateMacro()
    createMacroIfMissing()
    EditMacro(potionMacroName, potionMacroName, nil, buildMacroString(pp.availablePotions))
    EditMacro(flaskMacroName, flaskMacroName, nil, buildMacroString(pp.availableFlasks))
    if GetMacroInfo(legacyPhialMacroName) ~= nil then
        EditMacro(legacyPhialMacroName, legacyPhialMacroName, nil, buildMacroString(pp.availableFlasks))
    end
end

local function addPotionIfAvailable()
    local pots = pp.getPots()
    for _, value in ipairs(pots) do
        if value.getCount() > 0 then
            table.insert(pp.availablePotions, value.getId())
            --we break because all Pots share a cd so we only want the highest power potion
            break ;
        end
    end
end

local function addFlaskIfAvailable()
    local flasks = pp.getFlasks()
    for _, value in ipairs(flasks) do
        if value.getCount() > 0 then
            table.insert(pp.availableFlasks, value.getId())
            --we break because all Pots share a cd so we only want the highest power potion
            break ;
        end
    end
end

local function updateAvailablePots()
    pp.availablePotions = {}
    pp.availableFlasks = {}
    addPotionIfAvailable()
    addFlaskIfAvailable()
end

local onCombat = true
function pp.PPAM_UPDATE(self, event, ...)
    if event == "PLAYER_LOGIN" then
        onCombat = false
    end
    if event == "PLAYER_REGEN_DISABLED" then
        onCombat = true
        return
    end
    if event == "PLAYER_REGEN_ENABLED" then
        onCombat = false
    end

    if onCombat == false then
        updateAvailablePots()
        updateMacro()
    end
end

local PPAutoPotIcon = CreateFrame("Frame")
PPAutoPotIcon:RegisterEvent("BAG_UPDATE")
PPAutoPotIcon:RegisterEvent("PLAYER_LOGIN")
PPAutoPotIcon:RegisterEvent("TRAIT_CONFIG_UPDATED")
PPAutoPotIcon:RegisterEvent("PLAYER_REGEN_ENABLED")
PPAutoPotIcon:RegisterEvent("PLAYER_REGEN_DISABLED")
PPAutoPotIcon:SetScript("OnEvent", pp.PPAM_UPDATE)
