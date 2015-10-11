local PackageName, Major, Minor, Patch = "ZoneHelper", 1, 0, 0
local PkgMajor, PkgMinor = PackageName, tonumber(string.format("%02d%02d%02d", Major, Minor, Patch))
local Pkg = Apollo.GetPackage(PkgMajor)
if Pkg and (Pkg.nVersion or 0) >= PkgMinor then
  return -- no upgrade needed
end


-- Set a reference to the actual package or create an empty table
local ZoneHelper = Pkg and Pkg.tPackage or {}

ZoneHelper.CodeEnumContinents = {
  -- Raids
  R_Datascape = 52,             -- Datascape
  R_GeneticArchives = 67,       -- Genetic Archives
  R_CoreY83 = 91,               -- Initialization Core Y-83
  -- Dungeons
  D_Stormtalon = 13,            -- Stormtalon's Lair
  D_Skullcano = 14,             -- Scullcano
  D_KelVoreth = 15,             -- Ruins of Kel Voreth
  D_Swordmaiden = 48,           -- Sanctuary of the Swordmaiden
  D_UltProtogames = 69,         -- Ultimate Protogames
  D_ProtogamesAcadamy = 90,     -- Protogames Academy
  --SoloDungeons
  SD_OmniCore = 80,             -- OMNICore-1
  -- Adventures
  A_Seige = 16,                 -- Galeras Adventure
  A_MalgraveTrail = 17,         -- Malgrave Adventure
  A_WarOfTheWilds = 23,         -- Northern Wastes Adventure
  A_Hycrest = 24,               -- Hycrest Adventure
  A_Algoroc = 25,               -- Algoroc Adventure
  A_Crimelords = 26,            -- Whitevale Adventure
  A_Riot = 27,                  -- Astrovoid Prison Adventure
  A_Ellevar = 28,               -- Ellevar Adventure
  A_Farside = 74,               -- Farside Adventure (???)
  A_Bay = 84,                   -- Levian Bay Backup
  -- Continents
  C_Alizar = 6,
  C_Olyssia = 8,
  C_Farside = 19,
  C_Isigrol = 33,
  -- StartingAreas
  SA_TheGamblersRuin = 22,      -- Exiles Ark Ship
  SA_TheDestiny = 30,           -- Dominion Ark Ship
  SA_DestinyCryo = 76,          -- Dominion Cryo Recovery
  -- DailyZones
  DZ_NorthernWastes = 32,       -- Northern Wastes
  DZ_CrimsonBadlands = 61,      -- Crimson Isle Pocket Cap
  DZ_StarComm = 72,             -- Levian Bay Pocket Cap
  --Shiphands
  SH_Infestation = 18,          -- X82CargoShip
  SH_OutpostM13 = 38,           -- Asteroid Mining
  SH_VoidHunter = 50,           -- Void Hunter (???)
  SH_RageLogic = 51,            -- Rage Logic
  SH_SpaceMadness = 58,         -- Space Madness
  SH_DeepSpace = 60,            -- Deep Space Exploration
  SH_Gauntlet = 62,             -- The Gauntlet
  SH_FragmentZero = 83,
  -- Expeditions
  EX_Graylight = 42,            -- Graylight Grapplefest
  EX_KelVoreth = 43,            -- Kel Voreth Underforge
  EX_MeltingPot = 44,           -- The Melting Pot
  EX_Mayday = 45,               -- Mayday
  EX_CreeperCave = 46,          -- Creeper Cave
  EX_SpiderTomb = 47,           -- Spider Tomb
  EX_EldanLab = 75,             -- Abandoned Eldan Test Lab
  --PvP
  PVP_Arena = 39,
  PVP_Walatiki = 40,            -- Smash and Grab
  PVP_Bloodsworn = 53,          -- Halls of the Bloodsworn
  PVP_Warplot = 54,             -- Warplot Battleground
  PVP_WarplotSkymap = 55,       -- Warplot Skymap
  PVP_Cannon = 56,              -- ???
  PVP_Sabotage = 57,            -- Sabotage
  --Misc
  M_Housing = 7,                -- Inside House
  M_HousingSkymap = 36,
  -- World Dungeons
  WD_GrimvaultCore = 73,        -- Grimvaule Core
  WD_ExoLabXC42 = 85,           -- Exo-Lab XC42 (R12)
  -- Story
  ST_Drusera1 = 63,
  ST_Drusera2 = 64,
  ST_Drusera3 = 65,
  ST_Drusera4 = 68,
  ST_Drusera5 = 71,
  -- Quest
  Q_TheDustStalker = 87,
  -- Unknown Ares
  U_HalonRing = 9,
  U_Protopia = 10,
  U_QuestTestIsland = 11,
  U_InitiateIsland = 12,
  U_HousingAlgorocNeighborhood = 20,  -- ???
  U_EternityIslands = 30,
  U_PellicaneTestWorld = 34,
  U_RandyLand = 41,
  U_Coralus = 49,
  U_Arcterra = 92
}

ZoneHelper.ContinentInfo = {
  [6] = {
    name = "Alizar",
    commonName = "Alizar",
    zones = { 1, 2, 5, 14, 16, 17, 27, 219, 223, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 462, 474},
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [7] = {
    name = "Housing",
    commonName = "Housing",
    zones = { 4 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [8] = {
    name = "Olyssia",
    commonName = "Olyssia",
    zones = { 6, 7, 12, 15, 22, 26, 57, 58, 59, 78, 312, 313, 314, 315, 316, 317, 318, 319, 320, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 356, 357, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 456, 457, 458, 459, 460, 461},
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [9] = {
    name = "Halon Ring",
    commonName = "Halon Ring",
    zones = { 8, 48, 49, 224, 225, 226, 227, 228, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [10] = {
    name = "Protopia",
    commonName = "Wildwood",
    zones = { 10 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [11] = {
    name = "QuestTestIsland",
    commonName = "???",
    zones = {},
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [12] = {
    name = "InitiateIsland",
    commonName = "Initiate Island",
    zones = { 18 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [13] = {
    name = "StormtalonLair",
    commonName = "Stormtalon's Lair",
    shortName = "STL",
    zones = { 19 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = true,
    raid = false,
    outdoors = false,
    size = 5
  },
  [14] = {
    name = "Skullcano",
    commonName = "Skullcano Island",
    shortName = "SC",
    zones = { 20 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = true,
    raid = false,
    outdoors = false,
    size = 5
  },
  [15] = {
    name = "Kel Voreth",
    commonName = "Ruins of Kel Voreth",
    shortName = "KV",
    zones = { 21 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = true,
    raid = false,
    outdoors = false,
    size = 5
  },
  [16] = {
    name = "Galeras Adventure",
    commonName = "The Siege of Tempest Refuge",
    shortName = "Seige",
    zones = { 23 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [17] = {
    name = "Malgrave Adventure",
    commonName = "The Malgrave Trail",
    shortName = "Malgrave Trail",
    zones = { 24 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = 5
  },
  [18] = {
    name = "X82CargoShip",
    commonName = "Shiphand: Salvage Rights",
    zones = { 25 },
    instance = true,
    shiphand = true,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [19] = {
    name = "Farside",
    commonName = "Farside",
    zones = { 28, 46, 50, 74, 75, 76, 87, 88, 309, 310, 311 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [20] = {
    name = "Housing Algoroc Neighborhood",
    commonName = "Algoroc Neighborhood",
    zones = { 29 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [22] = {
    name = "Exile Ark Ship",
    commonName = "The Gambler's Ruin",
    zones = { 31, 151, 156, 157, 158, 159 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [23] = {
    name = "Northern Wastes Adventure",
    commonName = "War of the Wilds",
    shortName = "WotW",
    zones = { 32, 354 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [24] = {
    name = "Hycrest Adventure",
    commonName = "The Hycrest Insurrection",
    shortName = "Hycrest",
    zones = { 33, 189, 355 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [25] = {  -- Not in game
    name = "Algoroc Adventure",
    commonName = "Algoroc Adventure",
    shortName = "Algoroc",
    zones = { 34 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [26] = {
    name = "Whitevale Adventure",
    commonName = "Crimelords of Whitevale",
    shortName = "Crimelords",
    zones = { 35, 197, 198, 199, 200 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [27] = {
    name = "Astrovoid Prison Adventure",
    commonName = "Riot in the Void",
    shortName = "Riot",
    zones = { 36, 135, 194, 195, 196 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [28] = {  -- Not in game
    name = "Ellevar Adventure",
    commonName = "Ellevar Adventure",
    shortname = "Ellevar",
    zones = { 37 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [30] = {
    name = "Dominion Ark Ship",
    commonName = "The Destiny",
    zones = { 184, 185, 186, 187, 188 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [31] = {
    name = "Eternity Islands",
    commonName = "Isle of Eternity",
    zones = { 40, 124 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [32] = {
    name = "Northern Wastes",
    commonName = "Northern Wastes",
    zones = { 41, 220, 221, 222 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [33] = {
    name = "Isigrol",
    commonName = "Isigrol",
    zones = { 42, 53, 70, 71, 155, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 273, 274, 275, 276, 277, 281, 282, 283, 284, 285, 286, 291, 292, 293, 294, 295, 296, 298, 299, 300, 301, 302, 303, 304, 305, 306, 321, 323, 324, 325, 326, 328, 329, 464 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [34] = {  -- Not in game
    name = "Pellicane Test World",
    commonName = "Pellicane Test World",
    zones = { 47 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [36] = {
    name = "Housing Skymap",
    commonName = "Housing Skymap",
    zones = { 60 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [38] = {
    name = "Shiphand: Asteroid Mining",
    commonName = "Shiphand: Outpost M-13",
    zones = { 63, 64, 65, 67, 68 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [39] = {
    name = "PvP_Arena",
    commonName = "Arena",
    zones = { 66 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = true,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 10
  },
  [40] = {
    name = "PvP Smash and Grab",
    commonName = "Walatiki Temple",
    zones = { 69 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = true,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 20
  },
  [41] = {
    name = "RandyLand",
    commonName = "Randyland",
    zones = { 77 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [42] = {
    name = "Expedition: Graylight Grapplefest",
    commonName = "Expedition: Graylight Grapplefest",
    zones = { 79 },
    instance = false,
    shiphand = false,
    expedition = true,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 3
  },
  [43] = {
    name = "Expedition: Kel Voreth Underforge",
    commonName = "Expedition: Kel Voreth Underforge",
    zones = { 80 },
    instance = true,
    shiphand = false,
    expedition = true,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 3
  },
  [44] = {
    name = "Expedition: The Melting Pot",
    commonName = "Expedition: The Melting Pot",
    zones = { 81 },
    instance = true,
    shiphand = false,
    expedition = true,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 3
  },
  [45] = {
    name = "Expedition: Mayday",
    commonName = "Expedition: Mayday",
    zones = { 82 },
    instance = true,
    shiphand = false,
    expedition = true,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 3
  },
  [46] = {
    name = "Expedition: Creepy Cave",
    commonName = "Expedition: Creepy Cave",
    zones = { 83 },
    instance = true,
    shiphand = false,
    expedition = true,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 3
  },
  [47] = {
    name = "Expedition: Spider Tomb",
    commonName = "Expedition: Spider Tomb",
    zones = { 84 },
    instance = true,
    shiphand = false,
    expedition = true,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 3
  },
  [48] = {
    name = "Sanctuary of the Swordmaiden",
    commonName = "Sanctuary of the Swordmaiden",
    shortName = "SSM",
    zones = { 85 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = true,
    raid = false,
    outdoors = false,
    size = 5
  },
  [49] = {
    name = "Coralus",
    commonName = "Coralus",
    zones = { 89 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [50] = {
    name = "Shiphand: Void Hunter",
    commonName = "Shiphand: Void Hunter",
    zones = { 90, 91, 92 },
    instance = true,
    shiphand = true,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [51] = {
    name = "Shiphand: Rage Logic",
    commonName = "Shiphand: Rage Logic",
    zones = { 93, 94, 95, 96, 97 },
    instance = true,
    shiphand = true,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [52] = {
    name = "Datascape",
    commonName = "The Datascape",
    zones = { 98, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = true,
    outdoors = false,
    size = 20
  },
  [53] = {
    name = "Halls of the Bloodsworn",
    commonName = "Halls of the Bloodsworn",
    zones = { 99 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = true,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 30
  },
  [54] = {
    name = "PvP: Warplot Battleground",
    commonName = "Warplot Battleground",
    zones = { 100 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = true,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = 80
  },
  [55] = {
    name = "PvP: Warplot Sky Map",
    commonName = "Warplot Sky Map",
    zones = { 101 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = true,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = 40
  },
  [56] = {   -- Not in Game
    name = "PvP: Cannon",
    commonName = "PvP: Cannon",
    zones = { 102 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = true,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 40
  },
  [57] = {
    name = "PvP: Sabotage",
    commonName = "Daggerstone Pass",
    zones = { 103 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = true,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = 30
  },
  [58] = {
    name = "Shiphand: Space Madness",
    commonName = "Shiphand: Space Madness",
    zones = { 121 },
    instance = true,
    shiphand = true,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [60] = {
    name = "Shiphand: Deep Space Exploration",
    commonName = "Shiphand: Deep Space Exploration",
    zones = { 141, 142, 143, 144 },
    instance = true,
    shiphand = true,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [61] = {
    name = "Crimson Isle Pocket Cap",
    commonName = "Crimson Badlands",
    zones = { 131, 287, 288, 289, 290 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [62] = {
    name = "Shiphand: The Gauntlet",
    commonName = "Shiphand: The Gauntlet",
    zones = { 132, 133, 134 },
    instance = true,
    shiphand = true,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [63] = {
    name = "Drusera World Story 1",
    commonName = "Exo-Lab Prime",
    zones = { 137 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 1
  },
  [64] = {
    name = "Drusera World Story 2",
    commonName = "Exo-Lab X39",
    zones = { 138 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 1
  },
  [65] = {
    name = "Drusera World Story 3",
    commonName = "The Hidden Dark",
    zones = { 139 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 1
  },
  [67] = {
    name = "Genetic Archives",
    commonName = "Genetic Archives",
    shortName = "GA",
    zones = { 148, 149, 150 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = true,
    outdoors = false,
    size = 20
  },
  [68] = {
    name = "Drusera World Story 4",
    commonName = "The Golden Fields",
    zones = { 153 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 1
  },
  [69] = {
    name = "Ultimate Protogames",
    commonName = "Ultimate Protogames",
    shortName = "Protogames",
    zones = { 160, 162, 163, 164, 165, 167, 169, 170, 173, 174, 176, 177, 180, 181, 182 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = true,
    raid = false,
    outdoors = false,
    size = 5
  },
  [71] = {
    name = "Drusera World Story 5",
    commonName = "The Terminus Complex",
    zones = { 191 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 1
  },
  [72] = {
    name = "Levian Bay Pocket Cap",
    commonName = "Star-Comm Basin",
    zones = { 192 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [73] = {
    name = "Grimvault Core",
    commonName = "The Core",
    zones = { 201 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = true,
    size = -1
  },
  [74] = {  -- Not in game
    name = "",
    commonName = "Farside Adventure",
    zones = { 202 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [75] = {
    name = "Expedition: Abandoned Eldan Test Lab",
    commonName = "Abandoned Eldan Test Lab",
    zones = { 203 },
    instance = true,
    shiphand = false,
    expedition = true,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 3
  },
  [76] = {
    name = "",
    commonName = "The Destiny Cryo-Recovery",
    zones = { 207, 208 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [80] = {
    name = "",
    commonName = "OMNICore-1",
    zones = { 214, 215, 216, 217 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 1
  },
  [82] = {  -- Not in game
    name = "",
    commonName = "Stygian Thicket",
    zones = { 252, 253 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [83] = {
    name = "",
    commonName = "Shiphand: Fragment Zero",
    zones = { 277, 278, 279, 280 },
    instance = true,
    shiphand = true,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [84] = {
    name = "Levian Bay Backup",
    commonName = "Bay of Betrayal",
    zones = { 307, 349, 350, 351, 352 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = true,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = 5
  },
  [85] = {
    name = "Exo-Lab XC42",
    commonName = "Exo-Lab XC42",
    zones = { 327 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [87] = {  -- Exile Quest
    name = "The Dust Stalker",
    commonName = "The Dust Stalker",
    zones = { 406 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  },
  [90] = {
    name = "",
    commonName = "Protogames Academy",
    zones = { 470, 471, 472, 473 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = true,
    raid = false,
    outdoors = false,
    size = 5
  },
  [91] = {
    name = "",
    commonName = "Initialization Core Y-83",
    zones = { 475 },
    instance = true,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = true,
    outdoors = false,
    size = 20
  },
  [92] = {
    name = "",
    commonName = "Arcterra",
    zones = { 476 },
    instance = false,
    shiphand = false,
    expedition = false,
    pvp = false,
    adventure = false,
    dungeon = false,
    raid = false,
    outdoors = false,
    size = -1
  }
}

ZoneHelper.ZoneContinent = {
  [1] = 6,
  [2] = 6,
  [4] = 7,
  [5] = 6,
  [6] = 8,
  [7] = 8,
  [8] = 9,
  [10] = 10,
  [12] = 8,
  [14] = 6,
  [15] = 8,
  [16] = 6,
  [17] = 6,
  [18] = 12,
  [19] = 13,
  [20] = 14,
  [21] = 15,
  [22] = 8,
  [23] = 16,
  [24] = 17,
  [25] = 18,
  [26] = 8,
  [27] = 6,
  [28] = 19,
  [29] = 20,
  [31] = 22,
  [32] = 23,
  [33] = 24,
  [34] = 25,
  [35] = 26,
  [36] = 27,
  [37] = 28,
  [40] = 31,
  [41] = 32,
  [42] = 33,
  [46] = 19,
  [47] = 34,
  [48] = 9,
  [49] = 9,
  [50] = 19,
  [53] = 33,
  [57] = 8,
  [58] = 8,
  [59] = 8,
  [60] = 36,
  [63] = 38,
  [64] = 38,
  [65] = 38,
  [66] = 39,
  [67] = 38,
  [68] = 38,
  [69] = 40,
  [70] = 33,
  [71] = 33,
  [72] = 14,
  [73] = 14,
  [74] = 19,
  [75] = 19,
  [76] = 19,
  [77] = 41,
  [78] = 8,
  [79] = 42,
  [80] = 43,
  [81] = 44,
  [82] = 45,
  [83] = 46,
  [84] = 47,
  [85] = 48,
  [87] = 19,
  [88] = 19,
  [89] = 49,
  [90] = 50,
  [91] = 50,
  [92] = 50,
  [93] = 51,
  [94] = 51,
  [95] = 51,
  [96] = 51,
  [97] = 51,
  [98] = 52,
  [99] = 53,
  [100] = 54,
  [101] = 55,
  [102] = 56,
  [103] = 57,
  [104] = 52,
  [105] = 52,
  [106] = 52,
  [107] = 52,
  [108] = 52,
  [109] = 52,
  [110] = 52,
  [111] = 52,
  [112] = 52,
  [113] = 52,
  [114] = 52,
  [115] = 52,
  [116] = 52,
  [117] = 52,
  [118] = 52,
  [119] = 52,
  [120] = 52,
  [121] = 58,
  [124] = 31,
  [131] = 61,
  [132] = 62,
  [133] = 62,
  [134] = 62,
  [135] = 27,
  [137] = 63,
  [138] = 64,
  [139] = 65,
  [141] = 60,
  [142] = 60,
  [143] = 60,
  [144] = 60,
  [148] = 67,
  [149] = 67,
  [150] = 67,
  [151] = 22,
  [153] = 68,
  [155] = 33,
  [156] = 22,
  [157] = 22,
  [158] = 22,
  [159] = 22,
  [160] = 69,
  [162] = 69,
  [163] = 69,
  [164] = 69,
  [165] = 69,
  [167] = 69,
  [169] = 69,
  [170] = 69,
  [173] = 69,
  [174] = 69,
  [176] = 69,
  [177] = 69,
  [180] = 69,
  [181] = 69,
  [182] = 69,
  [184] = 30,
  [185] = 30,
  [186] = 30,
  [187] = 30,
  [188] = 30,
  [189] = 24,
  [191] = 71,
  [192] = 72,
  [194] = 27,
  [195] = 27,
  [196] = 27,
  [197] = 26,
  [198] = 26,
  [199] = 26,
  [200] = 26,
  [201] = 73,
  [202] = 74,
  [203] = 75,
  [204] = 69,
  [205] = 69,
  [207] = 76,
  [208] = 76,
  [214] = 80,
  [215] = 80,
  [216] = 80,
  [217] = 80,
  [219] = 6,
  [220] = 32,
  [221] = 32,
  [222] = 32,
  [223] = 6,
  [224] = 9,
  [225] = 9,
  [226] = 9,
  [227] = 9,
  [228] = 9,
  [232] = 9,
  [233] = 9,
  [234] = 9,
  [235] = 9,
  [236] = 9,
  [237] = 9,
  [238] = 9,
  [239] = 9,
  [240] = 9,
  [241] = 9,
  [242] = 9,
  [243] = 9,
  [244] = 9,
  [245] = 9,
  [246] = 9,
  [247] = 9,
  [248] = 9,
  [249] = 9,
  [250] = 9,
  [251] = 9,
  [252] = 82,
  [253] = 82,
  [254] = 33,
  [255] = 33,
  [256] = 33,
  [257] = 33,
  [258] = 33,
  [259] = 33,
  [260] = 33,
  [261] = 33,
  [262] = 33,
  [263] = 33,
  [264] = 33,
  [265] = 33,
  [266] = 33,
  [267] = 33,
  [268] = 33,
  [269] = 33,
  [270] = 33,
  [271] = 33,
  [273] = 33,
  [274] = 33,
  [275] = 33,
  [276] = 33,
  [277] = 83,
  [278] = 83,
  [279] = 83,
  [280] = 83,
  [281] = 33,
  [282] = 33,
  [283] = 33,
  [284] = 33,
  [285] = 33,
  [286] = 33,
  [287] = 61,
  [288] = 61,
  [289] = 61,
  [290] = 61,
  [291] = 33,
  [292] = 33,
  [293] = 33,
  [294] = 33,
  [295] = 33,
  [296] = 33,
  [298] = 33,
  [299] = 33,
  [300] = 33,
  [301] = 33,
  [302] = 33,
  [303] = 33,
  [304] = 33,
  [305] = 33,
  [306] = 33,
  [307] = 84,
  [309] = 19,
  [310] = 19,
  [311] = 19,
  [312] = 8,
  [313] = 8,
  [314] = 8,
  [315] = 8,
  [316] = 8,
  [317] = 8,
  [318] = 8,
  [319] = 8,
  [320] = 8,
  [321] = 33,
  [322] = 33,
  [323] = 33,
  [324] = 33,
  [325] = 33,
  [326] = 33,
  [327] = 85,
  [328] = 33,
  [329] = 33,
  [330] = 8,
  [331] = 8,
  [332] = 8,
  [333] = 8,
  [334] = 8,
  [335] = 8,
  [336] = 8,
  [337] = 8,
  [338] = 8,
  [339] = 8,
  [340] = 8,
  [341] = 8,
  [342] = 8,
  [343] = 8,
  [344] = 8,
  [345] = 8,
  [346] = 8,
  [349] = 84,
  [350] = 84,
  [351] = 84,
  [352] = 84,
  [353] = 17,
  [354] = 23,
  [355] = 24,
  [356] = 8,
  [357] = 8,
  [359] = 8,
  [360] = 8,
  [361] = 8,
  [362] = 8,
  [363] = 8,
  [364] = 8,
  [365] = 8,
  [366] = 8,
  [367] = 8,
  [368] = 8,
  [369] = 8,
  [370] = 8,
  [371] = 8,
  [372] = 8,
  [373] = 8,
  [374] = 8,
  [375] = 8,
  [376] = 8,
  [377] = 8,
  [378] = 8,
  [379] = 8,
  [380] = 8,
  [381] = 8,
  [382] = 8,
  [383] = 8,
  [384] = 8,
  [385] = 8,
  [386] = 8,
  [387] = 8,
  [388] = 8,
  [389] = 8,
  [390] = 8,
  [391] = 8,
  [395] = 6,
  [396] = 6,
  [397] = 6,
  [398] = 6,
  [399] = 6,
  [400] = 6,
  [401] = 6,
  [402] = 6,
  [403] = 6,
  [404] = 6,
  [405] = 6,
  [406] = 87,
  [407] = 6,
  [408] = 6,
  [409] = 6,
  [410] = 6,
  [411] = 6,
  [412] = 6,
  [413] = 6,
  [414] = 6,
  [415] = 6,
  [416] = 6,
  [417] = 6,
  [418] = 6,
  [419] = 6,
  [420] = 6,
  [421] = 6,
  [422] = 6,
  [423] = 6,
  [424] = 6,
  [425] = 6,
  [426] = 6,
  [427] = 6,
  [428] = 6,
  [429] = 6,
  [430] = 6,
  [431] = 6,
  [432] = 6,
  [433] = 6,
  [434] = 6,
  [435] = 6,
  [436] = 6,
  [437] = 6,
  [438] = 6,
  [439] = 6,
  [440] = 6,
  [441] = 6,
  [442] = 6,
  [443] = 6,
  [444] = 6,
  [445] = 6,
  [446] = 6,
  [447] = 6,
  [448] = 6,
  [449] = 6,
  [450] = 6,
  [451] = 6,
  [452] = 6,
  [453] = 6,
  [454] = 6,
  [455] = 6,
  [456] = 8,
  [457] = 8,
  [458] = 8,
  [459] = 8,
  [460] = 8,
  [461] = 8,
  [462] = 6,
  [464] = 33,
  [470] = 90,
  [471] = 90,
  [472] = 90,
  [473] = 90,
  [474] = 6,
  [475] = 91,
  [476] = 92
}

function ZoneHelper:new(args)
  local new = { }

  if args then
    for key, val in pairs(args) do
      new[key] = val
    end
  end
  return setmetatable(new, ZoneHelper)
end

function ZoneHelper:OnLoad()
  --Event_FireGenericEvent("OneVersion_ReportAddonInfo", "ZoneHelper", Major, Minor, Patch, 0, true)
end

function ZoneHelper:IsZoneRaid(zoneid)
  local c = ZoneHelper.ZoneContinent[zoneid]
  if not c then
    return false
  end
  return self:IsContinentRaid(c)
end

function ZoneHelper:IsZoneDungeon(zoneid)
  local c = ZoneHelper.ZoneContinent[zoneid]
  if not c then
    return false
  end
  return self:IsContinentDungeon(c)
end

function ZoneHelper:IsZoneAdventure(zoneid)
  local c = ZoneHelper.ZoneContinent[zoneid]
  if not c then
    return false
  end
  return self:IsContinentAdventure(c)
end

function ZoneHelper:IsZoneShiphand(zoneid)
  local c = ZoneHelper.ZoneContinent[zoneid]
  if not c then
    return false
  end
  return self:IsContinentShiphand(c)
end

function ZoneHelper:IsZoneExpedition(zoneid)
  local c = ZoneHelper.ZoneContinent[zoneid]
  if not c then
    return false
  end
  return self:IsContinentExpedition(c)
end

function ZoneHelper:IsZonePVP(zoneid)
  local c = ZoneHelper.ZoneContinent[zoneid]
  if not c then
    return false
  end
  return self:IsContinentPVP(c)
end

-- Dungeons, Solo Dungeons, Raids, Adventures, Shiphand, Instanced Content
function ZoneHelper:IsZoneInstance(zoneid)
  local c = ZoneHelper.ZoneContinent[zoneid]
  if not c then
    return false
  end
  return self:IsContinentInstance(c)
end

function ZoneHelper:IsContinentRaid(continentId)
  local z = ZoneHelper.ContinentInfo[continentId]
  if not z then
    return false
  else
    return z.raid
  end
  return false
end

function ZoneHelper:IsContinentDungeon(continentId)
  local z = ZoneHelper.ContinentInfo[continentId]
  if not z then
    return false
  else
    return z.dungeon
  end
  return false
end

function ZoneHelper:IsContinentAdventure(continentId)
  local z = ZoneHelper.ContinentInfo[continentId]
  if not z then
    return false
  else
    return z.adventure
  end
  return false
end

function ZoneHelper:IsContinentShiphand(continentId)
  local z = ZoneHelper.ContinentInfo[continentId]
  if not z then
    return false
  else
    return z.shiphand
  end
  return false
end

function ZoneHelper:IsContinentExpedition(continentId)
  local z = ZoneHelper.ContinentInfo[continentId]
  if not z then
    return false
  else
    return z.expedition
  end
  return false
end

function ZoneHelper:IsContinentPVP(continentId)
  local z = ZoneHelper.ContinentInfo[continentId]
  if not z then
    return false
  else
    return z.pvp
  end
  return false
end

-- Dungeons, Solo Dungeons, Raids, Adventures, and Shiphands
function ZoneHelper:IsContinentInstance(continentId)
  local z = ZoneHelper.ContinentInfo[continentId]
  if not z then
    return false
  else
    return z.instance
  end
  return false
end

--/eval vardump(GameLib.GetCurrentZoneMap())
Apollo.RegisterPackage(ZoneHelper, PkgMajor, PkgMinor, {})
