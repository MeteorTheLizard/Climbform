--Made by MrRangerLP

--Shared
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
		if phys:IsValid() then
			phys:Wake()
			phys:EnableMotion(false)
		end
		
		if self.CPPIExists then
			if self.Owner then
				if self.Owner:IsValid() then
					self:CPPISetOwner(self.Owner)
				end
			end
		else
			if self.Owner then
				if self.Owner:IsValid() then
					self:SetNWEntity("my_owner",self.Owner) --TinyCPPI Compatibility
				end
			end
		end
	end
	
	function ENT:EntityTakeDamage() return true end
	function ENT:PhysgunPickup() return false end
	function ENT:CanPlayerUnfreeze() return false end
	function ENT:CanTool() return false end
end

if CLIENT then
	function ENT:Initialize() end
	function ENT:OnRemove() end
	function ENT:Draw() self.BaseClass.Draw(self) end
	function ENT:Think() end
	
	function ENT:OnRemove()
		self:EmitSound("physics/wood/wood_crate_break"..math.random(1,5)..".wav",75,100,1,CHAN_AUTO)
	end
end