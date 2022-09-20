local focus = 0
local max_distance = 8
local talk_start = 0
local conv = 0
local fighting = false
local challenger = 0
local afk_limit_time = 30	-- seconds
local afk_time = 0		-- don't change
local battle_turn = 1		-- don't change
local challenger_turn = 0	-- don't change

local pokemons = {
{name = "Rattata", level = 28, extralevel = 12, sex = SEX_MALE, nick = "", ball = "normal"},
{name = "Caterpie", level = 27, extralevel = 17, sex = SEX_MALE, nick = "", ball = "normal"},
{name = "Bulbasaur", level = 31, extralevel = 19, sex = SEX_MALE, nick = "", ball = "normal"},
-- {name = "Onix", level = 40, extralevel = 12, sex = SEX_MALE, nick = "", ball = "normal"},
-- {name = "Golem", level = 38, extralevel = 18, sex = SEX_MALE, nick = "Golemniso", ball = "normal"},
}


local function doSummonGymPokemon(npc)
	battle_turn = battle_turn + 1
	local this = npc
	if #getCreatureSummons(this) >= 1 or focus == 0 then return true end
	local it = pokemons[battle_turn]
	pokeNpc = doSummonCreature(it.name, getThingPos(this))
	local summon = getCreatureSummons(this)[1]
	local balleffect = 69 -- EDITAR AQUI OS EFEITOS DAS BALLS
	if it.ball and pokeballs[it.ball] then
		balleffect = 69 -- EDITAR AQUI OS EFEITOS DAS BALLS
	end
	doSendMagicEffect(getThingPos(pokeNpc), balleffect)

	setPlayerStorageValue(pokeNpc, 990, this)
	setPlayerStorageValue(pokeNpc, 991, "battle")
	setPlayerStorageValue(pokeNpc, 8595, 1)
	registerCreatureEvent(pokeNpc, "Gym1")
    registerCreatureEvent(pokeNpc, "Gym2")
    registerCreatureEvent(pokeNpc, "Gym3")
    registerCreatureEvent(pokeNpc, "Gym4")
    registerCreatureEvent(pokeNpc, "Gym5") 
	setPlayerStorageValue(this, 990, 1)
	-- addEvent(adjustWildPoke, 15, pokeNpc, it.optionalLevel)
	mgo = gymMsgs[math.random(1, #gymMsgs)].go:gsub("doka", getCreatureName(pokeNpc))
	doCreatureSay(this, mgo, 1)
	fighting = true
end

local function doWinDuel(cid, npc)
	if not isCreature(cid) then return true end
	local this = npc
	local a = gymbadges[getCreatureName(this)] + 8
	doCreatureSay(npc, "You won the duel! Congratulations, take this "..getItemNameById(a - 8).." as a prize.", 1)
	local b = getPlayerItemById(cid, true, a)
	if b.uid > 0 then doTransformItem(b.uid, b.itemid - 8) end
	doPlayerSendCancel(cid, "#getBadges# "..getCreatureName(this).." "..getPlayerItemCount(cid, gymbadges[getCreatureName(this)]))
end

function onCreatureSay(cid, type, msg)
	local msg = string.lower(msg)

	if focus == cid then
		talk_start = os.clock()
	end

	if msgcontains(msg, 'hi') and focus == 0 and getDistanceToCreature(cid) <= 4 then
		focus = cid
		talk_start = os.clock()
		conv = 1
		selfSay("Hello "..getCreatureName(cid)..", my name is Blaine and I'm Cinnabar's Gym Leader. How may I help you?")
		return true
	end

	if isDuelMsg(msg) and conv == 1 and focus == cid then

		 -- if not hasPokemon(cid) then
			 -- selfSay("To battle agains't a gym leader you need pokemons.")
		-- return true
		 -- end

		selfSay("You are challenging me to a battle. It will be a "..#pokemons.." pokemon limit battle, let's start?")
		conv = 2

	return true
	end

	if isConfirmMsg(msg) and conv == 2 and focus == cid then
		challenger = focus
		setPlayerStorageValue(cid, 990, 1)
		setPlayerStorageValue(cid, 999, 1)
		if #getCreatureSummons(cid) >= 1 then
		local pk = getCreatureSummons(cid)[1]
		setPlayerStorageValue(pk, 990, 1)
		end
		selfSay("Yea, let's fight!")
		talk_start = os.clock()
		setPlayerStorageValue(getThis(), 990, 1)
		addEvent(doSummonGymPokemon, 5, getThis())
		conv = 3
	return true
	end

	if isNegMsg(msg) and conv == 2 and focus == cid then
		focus = 0
		selfSay("It is better for you to refuse a battle against me!")
	return true
	end

	local function doRemove(npc)
	local it = pokemons[battle_turn]
		local balleffect = pokeballs["normal"].effect
	if it.ball and pokeballs[it.ball] then
		balleffect = pokeballs[it.ball].effect
	end
	doSendMagicEffect(getThingPos(pokeNpc), balleffect)
	doRemoveCreature(pokeNpc)
	end

	if msgcontains(msg, 'bye') and focus == cid then
		selfSay('Bye and do your best trainer!')
		setPlayerStorageValue(focus, 990, -1)
		setPlayerStorageValue(focus, 999, -1)
		if #getCreatureSummons(focus) >= 1 then
		local pk = getCreatureSummons(focus)[1]
		setPlayerStorageValue(pk, 990, -1)
		end
	doSendMagicEffect(getThingPos(pokeNpc), balleffect)
	doRemoveCreature(pokeNpc)
		focus = 0
	return true
	end
end

local afk_warning = false

function checkPoke(player, poke)

end

function onThink()

	if focus == 0 then
		selfTurn(2)
		fighting = false
		challenger = 0
		challenger_turn = 0
		battle_turn = 0
		afk_time = 0
		afk_warning = false
		setPlayerStorageValue(getThis(), 990, -1)
		return true
	else
		if not isCreature(focus) then
			focus = 0
			return true
		end
		if fighting then
			talk_start = os.clock()

			if #getCreatureSummons(challenger) >= 1 then
				if pokeChalenger == nil then
					pokeChalenger = getCreatureName(getCreatureSummons(challenger)[1])
					afk_time = 0
					challenger_turn = challenger_turn + 1
				elseif pokeChalenger == getCreatureName(getCreatureSummons(challenger)[1]) then
					afk_time = 0
				else
					afk_time = 0
					challenger_turn = challenger_turn + 1
					pokeChalenger = getCreatureName(getCreatureSummons(challenger)[1])
				end
			else
					afk_time = afk_time + 0.5
			end

			if afk_time > afk_limit_time then
				setPlayerStorageValue(focus, 990, -1)
		setPlayerStorageValue(focus, 999, -1)
		doRemoveCreature(pokeNpc)
                              	focus = 0
				selfSay("I have waited too long, come back when you are ready!")
			return true
			end

			if not afk_warning and afk_time > afk_limit_time / 2 then
				selfSay("Where's your pokemon? Let's fight!")
				afk_warning = true
			end


			if getPlayerStorageValue(getThis(), 990) == -1 then
				if battle_turn >= #pokemons then
					addEvent(doWinDuel, 1000, focus, getThis())
					setPlayerStorageValue(focus, 990, -1)
					focus = 0
				return true
				end
				setPlayerStorageValue(getThis(), 990, 1)
				addEvent(doSummonGymPokemon, 1000, getThis())
			end

			if challenger_turn >= 7 or challenger_turn > #pokemons then
				selfSay("You lost our duel! Maybe some other time you'll defeat me.")
				setPlayerStorageValue(focus, 990, -1)
				focus = 0
			return true
			end
		end

		local npcpos = getThingPos(getThis())
		local focpos = getThingPos(focus)

		if npcpos.z ~= focpos.z then
			setPlayerStorageValue(focus, 990, -1)
			focus = 0
			selfSay("Bye then.")
			return true
		end

		if (os.clock() - talk_start) > 30 then
			selfSay("Good bye and keep training!")
			setPlayerStorageValue(focus, 990, -1)
			focus = 0
		end

		if getDistanceToCreature(focus) > max_distance then
			setPlayerStorageValue(focus, 990, -1)
		setPlayerStorageValue(focus, 999, -1)
			if #getCreatureSummons(focus) >= 1 then
		local pk = getCreatureSummons(focus)[1]
		setPlayerStorageValue(pk, 990, -1)
		end
		doRemoveCreature(pokeNpc)
			focus = 0
	selfSay("You were strong enough to win this battle!")
		return true
		end

		local dir = doRedirectDirection(getDirectionTo(npcpos, focpos))
		selfTurn(dir)
	end
return true
end
