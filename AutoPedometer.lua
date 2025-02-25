local function AutoPedometer()
	local self = {
		name = "Auto-Pedometer",
    	author = "ninjafriend",
		description = "Temporarily enables the Tracker's pedometer in Mt. Moon and the Underground Tunnels. (Fire Red and Leaf Green only)",
		version = "1.1",
		url = "https://github.com/jtigues/AutoPedometerTrackerExtension",

		-- Temporarily stores the original pedometer isUse function, in case the extension gets disabled
		defaultPedometerFunc = nil,
	}

	-- FireRed repel locations
	local repelLocationsFR = {
		--Mt. Moon
		[114] = true,
		[115] = true,
		[116] = true,
		--Underground Tunnels
		[172] = true, -- All Entrances
		[173] = true,
		[174] = true,
	}

	-- New pedometer inUse function that overrides the Settings option under certain conditions
	local newPedometerFunc = function(...)
		-- Force "enable" if player is located in the proper repel location
		if GameSettings.game == 3 and repelLocationsFR[Program.GameData.mapId or 0] then
			return true
		end

		-- Otherwise, use the default check
		if self.defaultPedometerFunc ~= nil then
			return self.defaultPedometerFunc(...)
		else
			-- Current logic at the time of writing this extension
			local enabledAndAllowed = Options["Display pedometer"] and Program.isValidMapLocation()
			local hasConflict = Battle.inBattle or Battle.battleStarting or GameOverScreen.isDisplayed or LogOverlay.isDisplayed
			return enabledAndAllowed and not hasConflict
		end
	end

	function self.checkForUpdates()
		local versionCheckUrl = "https://api.github.com/repos/jtigues/AutoPedometerTrackerExtension/releases/latest"
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local downloadUrl = "https://github.com/jtigues/AutoPedometerTrackerExtension/releases/latest"

		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, nil)
		return isUpdateAvailable, downloadUrl
	end

	function self.startup()
		self.defaultPedometerFunc = Program.Pedometer.isInUse
		Program.Pedometer.isInUse = newPedometerFunc
	end

	function self.unload()
		if self.defaultPedometerFunc ~= nil then
			Program.Pedometer.isInUse = self.defaultPedometerFunc
		end
	end

	return self
end
return AutoPedometer