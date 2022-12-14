Config = {}
AndiyScripts = {}
local second = 1000
local minute = 60 * second
local hour = 60 * minute
Config.Locale = 'en'

AndiyScripts.Drugs = {
	{
		drugid = 1, -- Drug ID Cant be -1 and cant be the same as other drug id
		maxdistancefield = 50, -- How big the field is 
		maxdistanceinteract = 2, -- Max distance to interact with the plant
		pickdrug = 'cannabis', --Plant item
		packdrug = 'marijuana', -- Drug item
		fieldpos = vector3(2220.72, 5582.52, 53.81), -- Where the plants grow
		processpos = vector3(2943.0864257813,4626.5600585938,48.720630645752), -- Where you proccess your plant items
		proccesstime = 10 * second -- Can be second, minute or hour
	},
	--[[{ EXAMPLE FOR NEW DRUG
		drugid = 2,
		maxdistancefield = 50,
		maxdistanceinteract = 2,
		pickdrug = 'cokeleaves',
		packdrug = 'cocaine',
		fieldpos = vector3(2220.72, 5582.52, 53.81),
		processpos = vector3(2943.0864257813,4626.5600585938,48.720630645752),
		proccesstime = 10 * second
	},]]--
}
AndiyScripts.Dealers = {
	{
		dealerid = 1, -- Dealer ID cnat be -1 and cant be the same as other dealer id
		pos = vector3(-2028.3901367188,-369.83755493164,19.096868515015), -- Where dealer is
		maxdistance = 2, -- Max distance to interact with the dealer
		color = {r=60,g=230,b=60,a=255}, -- Color of the marker  https://www.rapidtables.com/web/color/RGB_Color.html
		size = vector3(1.5,1.5,1.0), -- How big the marker is
		type = 1 -- Type of marker https://docs.fivem.net/docs/game-references/markers/
	},
}
AndiyScripts.DealerMenu = {
    --{label = "Name", name = 'item name', value = 'price'},  -- NAme is the actual name the player will see, item name needs to be the same as packdrug above, price its what it sells for
    {label = "Marijuana", name = 'marijuana', value = 50}, 
	--{label = "Kokain", name = 'cocaine', value = 75}, EXAMPLE FOR NEW DRUG TO BE SOLD
}