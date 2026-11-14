-- Run: lune run tests/genetics.test.luau
local process = require("@lune/process")
local Content = require("../src/ReplicatedStorage/Shared/Content")
local Genetics = require("../src/ReplicatedStorage/Shared/Genetics")

math.randomseed(42)
local failures = 0
local function check(name: string, fn: () -> ())
	local ok, err = pcall(fn)
	print((if ok then "ok   " else "FAIL ") .. name .. (if ok then "" else "\n     " .. tostring(err)))
	if not ok then
		failures += 1
	end
end

local function species(key: string): number
	for i, s in Content.Species do
		if s.key == key then
			return i
		end
	end
	error("no species " .. key)
end

-- Tree with every gene at {1,1} (aura {0,0}) unless overridden.
local function tree(speciesKey: string, genes: { [string]: { number } }?): Genetics.Genome
	local g = {}
	for _, gene in Content.Genes do
		g[gene.key] = (genes and genes[gene.key]) or (if gene.key == "aura" then { 0, 0 } else { 1, 1 })
	end
	return { species = species(speciesKey), genes = g }
end

-- Share of N children (mother x pollen drawn from father) for which pred is true.
local function share(mother, father, pred: (Genetics.Genome) -> boolean, n: number?): number
	local count, total = 0, n or 20000
	for _ = 1, total do
		if pred(Genetics.cross(mother, Genetics.makePollen(father))) then
			count += 1
		end
	end
	return count / total
end

local function near(x: number, target: number)
	assert(math.abs(x - target) < 0.015, `got {x}, expected ~{target}`)
end

check("46 variants at launch (GDD part 5)", function()
	local n = #Content.Species
	for _, gene in Content.Genes do
		n += #gene.variants
	end
	assert(n == 46, `got {n}`)
end)

check("1 216 512 looks, each with a unique Registry id", function()
	assert(Genetics.AppearanceCount == 1216512, `got {Genetics.AppearanceCount}`)
	-- Enumerate every possible genome look and check ids are unique and in range.
	local seen, count = {}, 0
	local function walk(i: number, genes)
		local gene = Content.Genes[i]
		if not gene then
			for s = 1, #Content.Species do
				local id = Genetics.appearanceId(Genetics.express({ species = s, genes = genes }))
				assert(id >= 0 and id < Genetics.AppearanceCount and not seen[id], `bad id {id}`)
				seen[id] = true
				count += 1
			end
			return
		end
		local n = #gene.variants
		if gene.key == "color" then
			for a = 1, n do
				for b = a, n do
					genes.color = { a, b }
					walk(i + 1, genes)
				end
			end
		else
			local first = if gene.key == "aura" then 0 else 1
			for a = first, n do
				genes[gene.key] = { a, a }
				walk(i + 1, genes)
			end
		end
	end
	walk(1, {})
	assert(count == 1216512, `enumerated {count}`)
end)

check("each child gene = one copy from the mother + the pollen's copy", function()
	local mother = tree("apple", { color = { 1, 2 }, size = { 1, 2 }, yield = { 1, 2 }, vigor = { 1, 2 }, season = { 1, 2 }, aura = { 1, 2 } })
	local father = tree("pear", { color = { 3, 4 }, size = { 3, 4 }, yield = { 3, 4 }, vigor = { 3, 4 }, season = { 3, 4 }, aura = { 3, 4 } })
	for _ = 1, 2000 do
		local pollen = Genetics.makePollen(father)
		local child = Genetics.cross(mother, pollen)
		assert(child.species == species("apple"), "species must come from the mother")
		for key, pair in child.genes do
			assert(pair[1] == 1 or pair[1] == 2, `{key}: mother copy {pair[1]}`)
			assert(pair[2] == pollen.genes[key], `{key}: pollen copy {pair[2]}`)
		end
	end
end)

check("hidden aura: two carriers give ~25% visible aura", function()
	local carrier = tree("apple", { aura = { 2, 0 } })
	assert(Genetics.express(carrier).aura == 0, "one copy must stay hidden")
	near(share(carrier, carrier, function(c)
		return Genetics.express(c).aura == 2
	end), 0.25)
end)

check("a child can show a trait no parent shows (recessive Giant)", function()
	local parent = tree("apple", { size = { 1, 4 } })
	assert(Genetics.express(parent).size == 1, "parent shows Small")
	near(share(parent, parent, function(c)
		return Genetics.express(c).size == 4
	end), 0.25)
end)

check("Sunfruit x Moonfruit gives Eclipse ~10%, unrelated species never", function()
	near(share(tree("sun"), tree("moon"), function(c)
		return c.species == species("eclipse")
	end), 0.10)
	near(share(tree("moon"), tree("sun"), function(c)
		return c.species == species("eclipse")
	end), 0.10)
	assert(share(tree("apple"), tree("pear"), function(c)
		return c.species ~= species("apple")
	end) == 0, "apple x pear must stay apple")
end)

check("color blends: same hue and rgb whatever the copy order", function()
	local a, b = tree("apple", { color = { 1, 8 } }), tree("apple", { color = { 8, 1 } })
	assert(Genetics.express(a).color == Genetics.express(b).color, "hue")
	local rgb = Genetics.rgb(a)
	assert(rgb[1] == (220 + 40) // 2 and rgb[2] == (50 + 35) // 2 and rgb[3] == (50 + 45) // 2, "rgb")
end)

check("rarity is computed: plain Apple Common, top genome Celestial", function()
	assert(Genetics.rarity(tree("apple")) == 1, "plain apple")
	local tier, score = Genetics.rarity(tree("eclipse", { color = { 8, 8 }, size = { 4, 4 }, aura = { 10, 10 } }))
	assert(Content.Rarities[tier].name == "Celestial", `tier {tier}, score {score}`)
	-- A hidden aura (one copy) adds nothing.
	local hidden = Genetics.rarity(tree("apple", { aura = { 10, 0 } }))
	assert(hidden == 1, "hidden aura must not count")
end)

print(if failures == 0 then "\nAll tests passed." else `\n{failures} test(s) failed.`)
process.exit(if failures == 0 then 0 else 1)
