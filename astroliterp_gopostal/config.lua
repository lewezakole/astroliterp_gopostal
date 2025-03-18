Config = {}

Config.NPC = {
    model = 's_m_m_postal_01', -- Tutaj ustawiasz jaki ma być npc tutaj strona gdzie se wybierasz https://docs.fivem.net/docs/game-references/ped-models/
    coords = vector3(-286.6791, -612.3057, 33.5727), -- kordy gdzie ma stac npc z rozpoczeciem pracy
    heading = 270.0 -- gdzie sie lampi ten cwel
}

Config.VehicleSpawn = vector3(-274.7329, -616.2978, 33.2865) -- Miejsce gdzie spawnuje sie fura

Config.MinPackages = 3 -- Minimalna liczba paczek któramoże sie wylosowac
Config.MaxPackages = 6 -- Maksymalna liczba paczek któramoże sie wylosowac

Config.Reward = { min = 100, max = 300 } -- Przedział nagrody za paczke

Config.DeliveryLocations = { -- TUtaj dajesz kordy gdzie mogą wylosować się paczki
    vector3(-88.8450, -27.7714, 66.9334),
    vector3(-251.5812, -700.4357, 35.7308),
}