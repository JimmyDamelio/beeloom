--!strict
-- Game content as data (GDD part 11: "adding an Aura = adding a row").
-- Names and rarity points are placeholders: tune them, the code does not change.
-- Pure Luau, no Roblox types, so the tests run outside Studio (Lune).

export type Variant = { name: string, rarity: number, rgb: { number }? }
export type Gene = { key: string, variants: { Variant }, unlockRank: number }
export type Species = { key: string, name: string, rarity: number, hybridOf: { string }? }

local Content = {}

-- 12 species at launch, including hybrids. A hybrid comes only from crossing its two parents.
-- The compatibility table is secret (GDD part 5): never show it in-game.
Content.Species = {
	{ key = "apple", name = "Apple", rarity = 0 },
	{ key = "pear", name = "Pear", rarity = 0 },
	{ key = "cherry", name = "Cherry", rarity = 0 },
	{ key = "plum", name = "Plum", rarity = 0 },
	{ key = "peach", name = "Peach", rarity = 1 },
	{ key = "orange", name = "Orange", rarity = 1 },
	{ key = "fig", name = "Fig", rarity = 1 },
	{ key = "sun", name = "Sunfruit", rarity = 2 },
	{ key = "moon", name = "Moonfruit", rarity = 2 },
	{ key = "eclipse", name = "Eclipse", rarity = 4, hybridOf = { "sun", "moon" } },
	{ key = "nectarine", name = "Nectarine", rarity = 3, hybridOf = { "peach", "plum" } },
	{ key = "dawn", name = "Dawnfruit", rarity = 4, hybridOf = { "sun", "orange" } },
} :: { Species }

-- Chance (%) that a fruit from two compatible species carries the hybrid (GDD mechanic 1).
Content.HybridChance = 10

-- Six genes carried in two copies. Expression rules (see Genetics.express):
--   color : both copies blend -> 8 variants give 36 hues;
--   aura  : allele 0 = none, shown only with two identical copies -> 11 looks;
--   others: the lower index is dominant, so later (rarer) variants are recessive.
Content.Genes = {
	{
		key = "color",
		unlockRank = 1,
		variants = {
			{ name = "Red", rarity = 0, rgb = { 220, 50, 50 } },
			{ name = "Orange", rarity = 0, rgb = { 240, 140, 40 } },
			{ name = "Yellow", rarity = 0, rgb = { 240, 210, 60 } },
			{ name = "Green", rarity = 0, rgb = { 90, 180, 70 } },
			{ name = "Blue", rarity = 1, rgb = { 60, 110, 220 } },
			{ name = "Purple", rarity = 1, rgb = { 140, 70, 190 } },
			{ name = "White", rarity = 2, rgb = { 240, 240, 235 } },
			{ name = "Black", rarity = 3, rgb = { 40, 35, 45 } },
		},
	},
	{
		key = "size",
		unlockRank = 1,
		variants = {
			{ name = "Small", rarity = 0 },
			{ name = "Medium", rarity = 0 },
			{ name = "Large", rarity = 1 },
			{ name = "Giant", rarity = 3 },
		},
	},
	{
		key = "yield",
		unlockRank = 3,
		variants = {
			{ name = "1 per cycle", rarity = 0 },
			{ name = "2 per cycle", rarity = 0 },
			{ name = "3 per cycle", rarity = 1 },
			{ name = "4 per cycle", rarity = 2 },
		},
	},
	{
		key = "vigor",
		unlockRank = 5,
		variants = {
			{ name = "Slow", rarity = 0 },
			{ name = "Steady", rarity = 0 },
			{ name = "Quick", rarity = 1 },
			{ name = "Rapid", rarity = 2 },
		},
	},
	{
		key = "season",
		unlockRank = 6,
		variants = {
			{ name = "Spring", rarity = 0 },
			{ name = "Summer", rarity = 0 },
			{ name = "Autumn", rarity = 0 },
			{ name = "Winter", rarity = 0 },
		},
	},
	{
		key = "aura",
		unlockRank = 4,
		variants = {
			{ name = "Electric", rarity = 5 },
			{ name = "Lunar", rarity = 5 },
			{ name = "Aquatic", rarity = 5 },
			{ name = "Solar", rarity = 5 },
			{ name = "Frost", rarity = 5 },
			{ name = "Floral", rarity = 5 },
			{ name = "Ember", rarity = 6 },
			{ name = "Crystal", rarity = 6 },
			{ name = "Shadow", rarity = 6 },
			{ name = "Cosmic", rarity = 7 },
		},
	},
} :: { Gene }

-- The 8 rarities are a label computed from the genome, never rolled (GDD mechanic 1).
-- minScore = sum of the rarity points of the expressed traits.
Content.Rarities = {
	{ name = "Common", minScore = 0 },
	{ name = "Uncommon", minScore = 2 },
	{ name = "Rare", minScore = 4 },
	{ name = "Epic", minScore = 6 },
	{ name = "Legendary", minScore = 9 },
	{ name = "Mythic", minScore = 12 },
	{ name = "Divine", minScore = 15 },
	{ name = "Celestial", minScore = 19 },
}

return Content
