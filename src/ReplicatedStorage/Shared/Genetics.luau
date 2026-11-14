--!strict
-- BEELOOM genetics (GDD mechanic 1): pure functions, no Roblox API, tested with Lune.
-- The server alone calls cross() (GDD part 11: no cross result is computed on the client).

local Content = if script then require(script.Parent.Content) else require("./Content")

-- A tree: one species + six genes in two copies (13 small integers).
export type Genome = { species: number, genes: { [string]: { number } } }
-- Pollen carries half a genome: one copy of each gene (GDD mechanic 2).
export type Pollen = { species: number, genes: { [string]: number } }
-- Expressed look: species index + one number per gene (color = hue 1..36, aura 0 = none).
export type Phenotype = { [string]: number }
-- Same shape as math.random(m, n). Pass a seeded one in tests.
export type Rng = (number, number) -> number

local Genetics = {}

local speciesIndex: { [string]: number } = {}
for i, s in Content.Species do
	speciesIndex[s.key] = i
end

local function pairKey(a: number, b: number): string
	return math.min(a, b) .. ":" .. math.max(a, b)
end

local hybridOf: { [string]: number } = {}
for i, s in Content.Species do
	if s.hybridOf then
		local a, b = speciesIndex[s.hybridOf[1]], speciesIndex[s.hybridOf[2]]
		assert(a and b, `Content: unknown parent species for hybrid {s.key}`)
		hybridOf[pairKey(a, b)] = i
	end
end

local colorVariants = Content.Genes[1].variants
assert(Content.Genes[1].key == "color", "Content: color must be the first gene")

-- Number of distinct looks a gene can show.
local function lookCount(key: string, n: number): number
	if key == "color" then
		return n * (n + 1) // 2
	elseif key == "aura" then
		return n + 1
	end
	return n
end

Genetics.AppearanceCount = #Content.Species
for _, gene in Content.Genes do
	Genetics.AppearanceCount *= lookCount(gene.key, #gene.variants)
end

-- Pick one copy of each gene at random. Used for pollen and for the mother's half.
function Genetics.makePollen(tree: Genome, rng: Rng?): Pollen
	local roll: Rng = rng or math.random
	local genes = {}
	for _, gene in Content.Genes do
		genes[gene.key] = tree.genes[gene.key][roll(1, 2)]
	end
	return { species = tree.species, genes = genes }
end

-- One seed: half of the mother (carrier tree) + the pollen. Species comes from the mother,
-- unless the two species are compatible: then HybridChance % to get the hybrid.
function Genetics.cross(mother: Genome, pollen: Pollen, rng: Rng?): Genome
	local roll: Rng = rng or math.random
	local egg = Genetics.makePollen(mother, roll)
	local genes = {}
	for _, gene in Content.Genes do
		genes[gene.key] = { egg.genes[gene.key], pollen.genes[gene.key] }
	end
	local species = mother.species
	local hybrid = hybridOf[pairKey(mother.species, pollen.species)]
	if hybrid and roll(1, 100) <= Content.HybridChance then
		species = hybrid
	end
	return { species = species, genes = genes }
end

function Genetics.express(g: Genome): Phenotype
	local p: Phenotype = { species = g.species }
	for _, gene in Content.Genes do
		local a, b = g.genes[gene.key][1], g.genes[gene.key][2]
		local lo, hi = math.min(a, b), math.max(a, b)
		if gene.key == "color" then
			p.color = hi * (hi - 1) // 2 + lo -- unordered pair -> hue 1..36
		elseif gene.key == "aura" then
			p.aura = if a == b then a else 0 -- hidden until two identical copies
		else
			p[gene.key] = lo -- lower index dominant
		end
	end
	return p
end

-- Displayed fruit color: the two copies blend. Convert with Color3.fromRGB on the client.
function Genetics.rgb(g: Genome): { number }
	local a, b = colorVariants[g.genes.color[1]].rgb :: { number }, colorVariants[g.genes.color[2]].rgb :: { number }
	return { (a[1] + b[1]) // 2, (a[2] + b[2]) // 2, (a[3] + b[3]) // 2 }
end

-- Rarity tier index into Content.Rarities, and the score behind it.
function Genetics.rarity(g: Genome): (number, number)
	local p = Genetics.express(g)
	local score = Content.Species[g.species].rarity
	for _, gene in Content.Genes do
		if gene.key == "color" then
			score += colorVariants[g.genes.color[1]].rarity + colorVariants[g.genes.color[2]].rarity
		elseif p[gene.key] > 0 then
			score += gene.variants[p[gene.key]].rarity
		end
	end
	local tier = 1
	for i, r in Content.Rarities do
		if score >= r.minScore then
			tier = i
		end
	end
	return tier, score
end

-- Unique number per look, 0 .. AppearanceCount - 1: the World Registry key (GDD mechanic 10).
function Genetics.appearanceId(p: Phenotype): number
	local id = p.species - 1
	for _, gene in Content.Genes do
		local value = if gene.key == "aura" then p.aura else p[gene.key] - 1
		id = id * lookCount(gene.key, #gene.variants) + value
	end
	return id
end

return Genetics
