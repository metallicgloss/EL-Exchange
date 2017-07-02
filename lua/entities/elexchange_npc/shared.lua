ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName		= "NPC"
ENT.Author			= "MetallicGloss (ELHostingServices)"
ENT.Category		= "EL-Exchange"
ENT.Spawnable			= true
ENT.AdminSpawnable		= true
ENT.AutomaticFrameAdvance = true
 
function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end
