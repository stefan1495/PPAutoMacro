local addonName, pp = ...

pp[potionPrefix] = {}

-- Lower => Higher priority
potionData = {
    useLightsPreservation = {
        { key = "LightsPreservation", tierIDs = { 241287, 241286 } };
    },
    usePotionOfRecklessness = {
        { key = "PotionOfRecklessness", tierIDs = { 241289, 241288, 245903, 245902 } };
    },
    useDraughtOfRampantAbandon = {
        { key = "DraughtOfRampantAbandon", tierIDs = { 241293, 241292, 245911 } };
    },
    usePotionOfDevouredDreams = {
        { key = "PotionOfDevouredDreams", tierIDs = { 241295, 241294 } };
    },
    usePotionOfZealotry = {
        { key = "PotionOfZealotry", tierIDs = { 241297, 241296, 245900, 245901 } };
    },
    useAmaniExtract = {
        { key = "AmaniExtract", tierIDs = { 241299, 241298 } };
    },
    useLightfusedManaPotion = {
        { key = "LightfusedManaPotion", tierIDs = { 241301, 241300 } };
    },
    useVoidShroudedTincture = {
        { key = "VoidShroudedTincture", tierIDs = { 241303, 241302 } };
    },
    useSilvermoonHealthPotion = {
        { key = "SilvermoonHealthPotion", tierIDs = { 241305, 241304 } };
    },
    useRefreshingSerum = {
        { key = "RefreshingSerum", tierIDs = { 241307, 241306 } };
    },
    useLightsPotential = {
        { key = "LightsPotential", tierIDs = { 241309, 241308, 245897, 245898 } };
    },
    useEnlightenmentTonic = {
        { key = "EnlightenmentTonic", tierIDs = { 241339, 241338 } };
    },
}

for _, potionRoot in pairs(potionData) do
    for _, potion in ipairs(potionRoot) do
        for _, id in ipairs(potion.tierIDs) do
            pp[potionPrefix][id] = pp.PPItem.new(id)
        end
    end
end

function pp.getPots()
    local pots = {}

    for settingsKey, potionRoot in pairs(potionData) do
        for _, potion in ipairs(potionRoot) do
            for _, id in ipairs(potion.tierIDs) do
                if PPDB[potionPrefix][settingsKey] then
                    table.insert(pots, 1, pp[potionPrefix][id])
                end
            end
        end
    end

    --local _, type = GetInstanceInfo()
    --if PPDB["Potion"]["useShockingDisclosureInDungeons"] and type == "party" then
    --    table.insert(pots, 1, pp["PotionShockingDisclosure1"])
    --    table.insert(pots, 1, pp["PotionShockingDisclosure2"])
    --    table.insert(pots, 1, pp["PotionShockingDisclosure3"])
    --end
    return pots
end
