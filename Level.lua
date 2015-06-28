-- Contains all informations for a Level

cLevel = {}
cLevel.__index = cLevel


function cLevel.new(a_File)
	local self = setmetatable({}, cLevel)

	self.m_Challenges = {}
	self:Load(a_File)
	return self
end


function cLevel:Load(a_File)
	local levelIni = cIniFile()
	levelIni:ReadFile(PLUGIN:GetLocalFolder() .. "/challenges/" .. a_File)

	self.m_LevelName = levelIni:GetValue("General", "LevelName")
	self.m_Description = levelIni:GetValue("General", "Description")

	local amount = levelIni:GetNumValues("Challenges")
	for i = 1, amount do
		local challengeName = levelIni:GetValue("Challenges", i)
		local challengeInfo = LoadBasicInfos(challengeName, levelIni, self.m_LevelName)
		challengeInfo:Load(levelIni)  -- Load the challenge specific values
		self.m_Challenges[challengeName] = challengeInfo
	end
end
