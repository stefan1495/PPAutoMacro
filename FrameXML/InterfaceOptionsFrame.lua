local addonName, pp = ...

local panel = CreateFrame("Frame")

local DEFAULT_ICON = 134400

local function getSortedKeys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(keys)
    return keys
end

local function getSelectedKey(dbTable)
    for key, isSelected in pairs(dbTable) do
        if isSelected then
            return key
        end
    end

    return nil
end

local function setSingleSelection(dbTable, selectedKey)
    for key, _ in pairs(dbTable) do
        dbTable[key] = nil
    end

    if selectedKey then
        dbTable[selectedKey] = true
    end
end

local function buildConsumableOptions(consumableData, itemMap)
    local options = {}
    local sortedKeys = getSortedKeys(consumableData)

    for _, settingsKey in ipairs(sortedKeys) do
        local consumableRoot = consumableData[settingsKey]
        local highestTierId = consumableRoot[1].tierIDs[#consumableRoot[1].tierIDs]
        local item = itemMap[highestTierId]

        table.insert(options, {
            settingsKey = settingsKey,
            value = tostring(settingsKey),
            itemId = item.getId(),
            item = item,
            displayName = item.getName() or ("Item #" .. item.getId()),
        })
    end

    return options
end

local function findOptionBySettingsKey(options, settingsKey)
    for _, option in ipairs(options) do
        if option.settingsKey == settingsKey then
            return option
        end
    end

    return nil
end

local function findOptionByValue(options, value)
    for _, option in ipairs(options) do
        if option.value == value then
            return option
        end
    end

    return nil
end

local function setDropdownLabel(dropdownFrame, text)
    UIDropDownMenu_SetText(dropdownFrame, text)
    if dropdownFrame.Text then
        dropdownFrame.Text:SetText(text)
    end
end

local function getOptionIcon(option)
    if option.icon then
        return option.icon
    end

    if C_Item and C_Item.GetItemIconByID then
        option.icon = C_Item.GetItemIconByID(option.itemId) or DEFAULT_ICON
    else
        option.icon = DEFAULT_ICON
    end

    return option.icon
end

local function getOptionText(option, includeIcon)
    local displayName = option.displayName or ("Item #" .. option.itemId)
    if not includeIcon then
        return displayName
    end

    local icon = getOptionIcon(option)
    return "|T" .. icon .. ":16:16:0:0:64:64:4:60:4:60|t " .. displayName
end

local function showItemTooltip(anchorFrame, itemId)
    GameTooltip:SetOwner(anchorFrame, "ANCHOR_RIGHT")
    if GameTooltip.SetItemByID then
        GameTooltip:SetItemByID(itemId)
    else
        GameTooltip:SetHyperlink("item:" .. itemId)
    end
    GameTooltip:Show()
end

local function syncDropdownText(dropdownName, dropdownFrame, options, dbTable)
    local selectedKey = getSelectedKey(dbTable)
    local selectedOption = findOptionBySettingsKey(options, selectedKey)
    if selectedOption then
        dropdownFrame.selectedName = selectedOption.displayName
        setDropdownLabel(dropdownFrame, getOptionText(selectedOption, true))
    else
        dropdownFrame.selectedName = nil
        setDropdownLabel(dropdownFrame, "Select")
    end
end

local function initializeDropdown(dropdownName, dropdownFrame, options, dbTable, onSelectionChanged)
    UIDropDownMenu_SetWidth(dropdownFrame, 260)

    UIDropDownMenu_Initialize(dropdownFrame, function(_, level)
        level = level or 1
        if level ~= 1 then
            return
        end

        local selectedKey = getSelectedKey(dbTable)
        local selectedValue = selectedKey and tostring(selectedKey) or nil

        for _, option in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.displayName
            info.value = option.value
            info.arg1 = option.value
            info.icon = getOptionIcon(option)
            info.func = function(_, selectedValueArg)
                local selectedOption = findOptionByValue(options, selectedValueArg)
                setSingleSelection(dbTable, selectedOption and selectedOption.settingsKey or nil)
                dropdownFrame.selectedName = selectedOption and selectedOption.displayName or nil
                setDropdownLabel(dropdownFrame, selectedOption and getOptionText(selectedOption, true) or "Select")
                onSelectionChanged(selectedOption)
            end
            info.checked = option.value == selectedValue
            UIDropDownMenu_AddButton(info, level)

            local dropdownList = _G["DropDownList" .. level]
            if dropdownList and dropdownList.numButtons then
                local button = _G[dropdownList:GetName() .. "Button" .. dropdownList.numButtons]
                if button then
                    button.ppamItemId = option.itemId

                    if not button.ppamItemTooltipHooked then
                        button.ppamItemTooltipHooked = true
                        button:HookScript("OnEnter", function(selfButton)
                            if selfButton.ppamItemId then
                                showItemTooltip(selfButton, selfButton.ppamItemId)
                            end
                        end)
                        button:HookScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)
                    end
                end
            end
        end
    end)

    dropdownFrame:HookScript("OnShow", function()
        syncDropdownText(dropdownName, dropdownFrame, options, dbTable)
    end)

    dropdownFrame:HookScript("OnEnter", function()
        local selectedKey = getSelectedKey(dbTable)
        local selectedOption = findOptionBySettingsKey(options, selectedKey)
        if selectedOption then
            showItemTooltip(dropdownFrame, selectedOption.itemId)
        end
    end)

    dropdownFrame:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    syncDropdownText(dropdownName, dropdownFrame, options, dbTable)

    for _, option in ipairs(options) do
        option.item.getItem():ContinueOnItemLoad(function()
            option.displayName = option.item.getName() or option.displayName
            option.icon = getOptionIcon(option)
            UIDropDownMenu_Refresh(dropdownFrame)

            if dbTable[option.settingsKey] then
                syncDropdownText(dropdownName, dropdownFrame, options, dbTable)
            end
        end)
    end
end

function panel:OnEvent(event, addOnName)
    if addOnName == "PPAutoMacro" then
        if not PPDB then
            PPDB = {}
        end

        if not PPDB[potionPrefix] then
            PPDB[potionPrefix] = {}
        end

        if not PPDB[flaskPrefix] then
            PPDB[flaskPrefix] = {}
        end

        self:InitializeOptions()
    end
end

panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", panel.OnEvent)

function panel:InitializeOptions()
    self.panel = CreateFrame("Frame")
    self.panel.name = "Potion & Flask Auto Macro"

    local scrollFrame = CreateFrame("ScrollFrame", nil, self.panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetPoint("TOPLEFT", 0, 0)
    scrollChild:SetPoint("TOPRIGHT", 0, 0)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    scrollFrame:HookScript("OnSizeChanged", function(_, width)
        scrollChild:SetWidth(width - 24)
    end)
    -- Title
    local title = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("Top", 0, -5)
    title:SetText("Potion & Flask Auto Macro")

    -- Subtitle
    local subtitle = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 20, -8)
    subtitle:SetText("Here you can configure the behaviour of the Addon.")

    local potionLabel = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormal")
    potionLabel:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 20, -16)
    potionLabel:SetText("Potion to use")

    local potionDropdown = CreateFrame("Frame", nil, scrollChild, "UIDropDownMenuTemplate")
    potionDropdown:SetPoint("TOPLEFT", potionLabel, "BOTTOMLEFT", -16, -6)
    local potionOptions = buildConsumableOptions(potionData, pp[potionPrefix])
    initializeDropdown("potion", potionDropdown, potionOptions, PPDB[potionPrefix], function(selectedOption)
        pp.PPAM_UPDATE(nil, nil)
    end)

    local flaskLabel = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormal")
    flaskLabel:SetPoint("TOPLEFT", potionDropdown, "BOTTOMLEFT", 16, -18)
    flaskLabel:SetText("Flask to use")

    local flaskDropdown = CreateFrame("Frame", nil, scrollChild, "UIDropDownMenuTemplate")
    flaskDropdown:SetPoint("TOPLEFT", flaskLabel, "BOTTOMLEFT", -16, -6)
    local flaskOptions = buildConsumableOptions(flaskData, pp[flaskPrefix])
    initializeDropdown("flask", flaskDropdown, flaskOptions, PPDB[flaskPrefix], function(selectedOption)
        pp.PPAM_UPDATE(nil, nil)
    end)

    self.panel:HookScript("OnShow", function()
        syncDropdownText("potion", potionDropdown, potionOptions, PPDB[potionPrefix])
        syncDropdownText("flask", flaskDropdown, flaskOptions, PPDB[flaskPrefix])
    end)

    scrollChild:SetHeight(260)

    local category, layout = Settings.RegisterCanvasLayoutCategory(self.panel, "PPAutoMacro");
    Settings.RegisterAddOnCategory(category);
    categoryId = category:GetID()
end

SLASH_PPAM1 = "/ppam"
SlashCmdList.PPAM = function(msg, editBox)
    Settings.OpenToCategory(categoryId)
end
