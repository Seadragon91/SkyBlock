-- Contains all informations for a Level

cLevel = {}
cLevel.__index = cLevel

function cLevel.new(a_File)
    local self = setmetatable({}, cLevel)
    
    self.challenges = {}
    self.Load(self, a_File)
    return self
end

function cLevel.GetLevelName(self)
    return self.levelName
end

function cLevel.Load(self, a_File)
    local LevelIni = cIniFile()
    LevelIni:ReadFile(PLUGIN:GetLocalFolder() .. "/challenges/" .. a_File)
    
    self.levelName = LevelIni:GetValue("General", "LevelName")
    self.description = LevelIni:GetValue("General", "Description")

    local amount = LevelIni:GetNumValues("Challenges")    
    for i = 1, amount do
        local challengeName = LevelIni:GetValue("Challenges", i)
        self.challenges[challengeName] = cChallengeInfo.new(challengeName, LevelIni, self.levelName)
    end
end
