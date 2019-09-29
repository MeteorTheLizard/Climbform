--Made by MrRangerLP

AddCSLuaFile()

ENT.Base				= "base_gmodentity"
ENT.Type				= "anim"
ENT.PrintName			= "Climbgame Box"
ENT.Category			= "Fun + Games"
ENT.Author				= "MrRangerLP"
ENT.Contact				= ""
ENT.Purpose				= ""
ENT.Instructions		= ""
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.DisableDuplicator	= true

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion(false)
		end
		
		if self.CPPIExists then
			if IsValid(self.Owner) then
				self:CPPISetOwner(self.Owner)
			end
		else
			if IsValid(self.Owner) then
				self:SetNWEntity("my_owner",self.Owner) --TinyCPPI Compatibility
			end
		end
	end
	
	function ENT:EntityTakeDamage() return true end
	function ENT:PhysgunPickup() return false end
	function ENT:CanTool() return false end
end

if CLIENT then
	function ENT:Initialize() end
	function ENT:Draw() self.BaseClass.Draw(self) end
	function ENT:Think() end
	function ENT:OnRemove() end
end