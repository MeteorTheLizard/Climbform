--Made by MrRangerLP

AddCSLuaFile("shared.lua")

ENT.Base 				= "base_gmodentity"
ENT.Type 				= "anim"
ENT.Category 			= "Fun + Games"

ENT.PrintName 			= "Climbgame"
ENT.Author				= "MrRangerLP (Meteor)"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false
ENT.DisableDuplicator 	= true
ENT.DoNotDuplicate 		= true

util.PrecacheModel("models/props_junk/wood_crate001a.mdl")

if CLIENT then
	local AngleConstant1 = Angle(-180,90,-90)
	local AngleConstant2 = Angle(-180,-90,-90)
	local AngleConstant3 = Angle(0,-180,90)
	local AngleConstant4 = Angle(0,0,90)

	local ColorOrangeIsh = Color(255,191,0)
	local ColorWhite = Color(255,255,255)
	local ColorVeryDarkGrey = Color(16,16,16)
	local ColorMisc = Color(33,200,0,255)

	local Me
	local UndecorateNick = UndecorateNick or function(Str) return Str end -- Metastruct and general markup compatibility

	function ENT:TextPosInit()
		self.TextPosAngles = {
			self:GetPos() + (self:GetUp() * 1) + (self:GetForward() * -21), self:GetAngles() + AngleConstant1,
			self:GetPos() + (self:GetUp() * 1) + (self:GetForward() * 21), self:GetAngles() + AngleConstant2,
			self:GetPos() + (self:GetUp() * 1) + (self:GetRight() * -21), self:GetAngles() + AngleConstant3,
			self:GetPos() + (self:GetUp() * 1) + (self:GetRight() * 21), self:GetAngles() + AngleConstant4
		}
	end

	function ENT:Initialize()
		self:TextPosInit()
		self.Text = "Climbgame"
		self.LastPos = self:GetPos()
		self.LastAng = self:GetAngles()
	end

	function ENT:Draw()
		self:DrawModel()

		self.SharedOwner = self:GetNWEntity("SharedOwner")
		self.ClimbCountC = self:GetNWInt("Climbcount")

		if not IsValid(self.SharedOwner) and (self:GetPos() ~= self.LastPos or self:GetAngles() ~= self.LastAng) then -- The entity can still be picked up so we need to update the textpos constantly
			self:TextPosInit()
			self.LastPos = self:GetPos()
			self.LastAng = self:GetAngles()
		end

		if self.Text == "Climbgame" and IsValid(self.SharedOwner) then
			self.Text = UndecorateNick(self.SharedOwner:Nick())
			Me = LocalPlayer() == self.SharedOwner and self.SharedOwner
		end

		for k = 1,#self.TextPosAngles,2 do
			cam.Start3D2D(self.TextPosAngles[k],self.TextPosAngles[k + 1],0.1)
				draw.SimpleTextOutlined(self.Text,"DermaLarge",0,-30,ColorOrangeIsh,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,ColorVeryDarkGrey)

				if self.ClimbCountC > 0 then
					draw.SimpleTextOutlined("Progress: " .. tostring(self.ClimbCountC) .. " " .. "box" .. (self.ClimbCountC > 1 and "es" or ""),"DermaLarge",0,30,ColorMisc,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,ColorVeryDarkGrey)
				end
			cam.End3D2D()
		end
	end

	function ENT:Think()
		if (self:GetNWBool("Fell") or self:GetNWBool("GameFinished")) and IsValid(self.SharedOwner) and self.SharedOwner == Me then
			local Count = self:GetNWInt("Climbcount")
			local CountStr = "" .. tostring(Count) -- For some reason we have to append this to a string, otherwise it will be invisible in the valve chatbox

			if self:GetNWBool("Fell") then
				chat.AddText(ColorWhite,"[",ColorOrangeIsh,"Climbgame",ColorWhite,"]: You managed to climb ",ColorOrangeIsh,CountStr,ColorWhite,Count > 1 and " boxes!" or " box!")
			end

			if self:GetNWBool("GameFinished") then
				chat.AddText(ColorWhite,"[",ColorOrangeIsh,"Climbgame",ColorWhite,"]: You made it to the top in ",ColorOrangeIsh,CountStr,ColorWhite,Count > 1 and " boxes!" or " box!")
			end

			self:SetNextClientThink(CurTime() + 100000) -- We only want this to be displayed once. This method is better than using a variable
			return true
		end
	end
end