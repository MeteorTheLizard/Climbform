--Made by MrRangerLP

include("shared.lua")

if SERVER then
	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPISetOwner and true or false

	if not CPPIExists then -- Depending on the load order, CPPI might exist in the files but was not loaded yet so we set the variable at a later time
		hook.Add("InitPostEntity","ent_climbform_box_CPPI",function()
			CPPIExists = MetaE.CPPISetOwner and true or false
		end)
	end

	function ENT:Initialize()
		local Creator = self:GetCreator()
		if IsValid(Creator) then -- Do not allow players to spawn this manually
			self:Remove()
			return
		end

		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local Phys = self:GetPhysicsObject()
		if IsValid(Phys) then
			Phys:EnableMotion(false)
		end

		if CPPIExists then
			self:CPPISetOwner(self.Owner)
		else
			self:SetNWEntity("my_owner",self.Owner) -- TinyCPPI Compatibility
		end
	end

	function ENT:EntityTakeDamage() return true end
	function ENT:PhysgunPickup() return false end
	function ENT:CanTool() return false end
	function ENT:CanProperty() return false end
end