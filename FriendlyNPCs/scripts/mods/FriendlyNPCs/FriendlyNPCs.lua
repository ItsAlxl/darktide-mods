local mod = get_mod("FriendlyNPCs")

-- mod.opinions is declared in localization
-- this mod changes DialogueBreedSettings

mod.on_setting_changed = function(id)
    local opinions = mod.opinions[id]
    local target_opinion = mod:get(id)
    for voice_profile, _ in pairs(opinions) do
        opinions[voice_profile] = target_opinion
    end
end

-- initialize
for breed, _ in pairs(mod.opinions) do
    mod.on_setting_changed(breed)
end
