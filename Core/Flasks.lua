local addonName, pp = ...

pp[flaskPrefix] = {}

-- Lower => Higher priority
flaskData = {
    useFlaskOfThalassianResistance = {
        { key = "FlaskOfThalassianResistance", tierIDs = { 241321, 241320 } };
    },
    useFlaskOfTheMagisters = {
        { key = "FlaskOfTheMagisters", tierIDs = { 241323, 241322 } };
    },
    useFlaskOfTheBloodKnights = {
        { key = "FlaskOfTheBloodKnights", tierIDs = { 241325, 241324 } };
    },
    useFlaskOfTheShatteredSun = {
        { key = "FlaskOfTheShatteredSun", tierIDs = { 241327, 241326 } };
    },
    useViciousThalassianFlaskOfHonor = {
        { key = "ViciousThalassianFlaskOfHonor", tierIDs = { 241335, 241334 } };
    },
}

for _, flaskRoots in pairs(flaskData) do
    for _, flask in ipairs(flaskRoots) do
        for _, id in ipairs(flask.tierIDs) do
            pp[flaskPrefix][id] = pp.PPItem.new(id)
        end
    end
end

function pp.getFlasks()
    local flasks = {}

    for settingsKey, flaskRoots in pairs(flaskData) do
        for _, flaskType in pairs(flaskRoots) do
            for _, id in ipairs(flaskType.tierIDs) do
                if PPDB[flaskPrefix][settingsKey] then
                    table.insert(flasks, 1, pp[flaskPrefix][id])
                end
            end
        end
    end

    return flasks
end