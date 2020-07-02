--Made by MrRangerLP

AddCSLuaFile("shared.lua")

ENT.Base 				= "base_gmodentity"
ENT.Type 				= "anim"
ENT.Category 			= "Fun + Games"

ENT.PrintName 			= "Climbgame Box"
ENT.Author				= "MrRangerLP (Meteor)"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.DisableDuplicator 	= true
ENT.DoNotDuplicate 		= true

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end