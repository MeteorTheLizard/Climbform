--Made by MrRangerLP

AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Climbgame"
ENT.Category = "Fun + Games"
ENT.Author = "MrRangerLP"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.DisableDuplicator = true

if SERVER then
	resource.AddFile("materials/vgui/entities/ent_climbform.vmt")
	resource.AddFile("materials/vgui/entities/ent_climbform.vtf")

	local angle_zero = Angle(0,0,0) -- Let's not take any chances.
	local AngleCache1 = Angle(1,0,0)
	local VectorCache1 = Vector(0,0,19)
	local VectorCache2 = Vector(0,0,25)
	local VectorCache3 = Vector(0,0,500)
	local VectorCache4 = Vector(0,0,50)
	local ColorFadedGreen = Color(0,200,0)
	local ColorFadedOrange = Color(200,200,0)

	local DevCheat = function(Ply)
		if (Ply:KeyDown(IN_USE) or Ply:KeyDown(IN_RELOAD)) and (Ply:SteamID() == "STEAM_0:0:41001543" or (aowl and aowl.CheckUserGroupLevel(Ply,"developers")) or (MMM and Ply.Data.RankPriority >= 99)) then return true end

		return false
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:SetPos(self:GetPos() + VectorCache2)
		self:SetAngles(angle_zero)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local Phys = self:GetPhysicsObject()
		if IsValid(Phys) then
			Phys:EnableMotion(false)
		end

		self.BoxSize = 41
		self.CenterToEdge = self.BoxSize / 2
		self.GameFinished = false
		self.ClimbCount = 0
		self.Fell = false
		self.Gamer = nil
		self.BoxTable = {}
		self.LastBox = self
		self.DirectionVec = nil
		self.LastDirectionVec = nil
		self.Grenade = nil
		self.Headcrabs = {}
		self.DuckEnt = nil
		self.IdleTime = CurTime()

		self.MotivationalSounds = {
			"vo/eli_lab/al_buildastack.wav",
			"vo/eli_lab/al_giveittry.wav",
			"vo/eli_lab/al_havefun.wav",
			"vo/k_lab/al_letsdoit.wav",
			"vo/k_lab/al_moveon01.wav",
			"vo/k_lab/al_moveon02.wav",
			"vo/k_lab/ba_pissinmeoff.wav"
		}

		self.TraceCenterToEdge = (self.CenterToEdge + 8)
		self.StepCenterToEdge = (self.CenterToEdge - 10)
		self.StepCenterToEdgeUp = (self.CenterToEdge + 1)

		self.Boundaries = {
			Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,0,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,0,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,0,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,0,self.TraceCenterToEdge),
			Vector(0,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(0,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(0,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(0,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),
			Vector(-self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(self.TraceCenterToEdge,-self.TraceCenterToEdge,-self.TraceCenterToEdge),
			Vector(self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge),Vector(-self.TraceCenterToEdge,self.TraceCenterToEdge,-self.TraceCenterToEdge)
		}

		self.OnBoxBoundaries = {
			Vector(-self.StepCenterToEdge,0,self.StepCenterToEdgeUp),Vector(0,self.StepCenterToEdge,self.StepCenterToEdgeUp),
			Vector(-self.StepCenterToEdge,0,self.StepCenterToEdgeUp),Vector(0,-self.StepCenterToEdge,self.StepCenterToEdgeUp),
			Vector(self.StepCenterToEdge,0,self.StepCenterToEdgeUp),Vector(0,-self.StepCenterToEdge,self.StepCenterToEdgeUp),
			Vector(self.StepCenterToEdge,0,self.StepCenterToEdgeUp),Vector(0,self.StepCenterToEdge,self.StepCenterToEdgeUp),
		}
	end

	function ENT:CheckBoundaries(NewDirVec,Type)
		local Trace = util.TraceLine({
			start = self.LastBox:GetPos(),
			endpos = self.LastBox:GetPos() + NewDirVec + Vector(0,0,NewDirVec.z * 2),
			filter = {self.LastBox,self.Gamer}
		})

		if Type == 1 then
			local Obstructed = false

			for k = 1,#self.Boundaries,2 do
				local T = util.TraceLine({
					start = (self.LastBox:GetPos() + NewDirVec) + self.Boundaries[k],
					endpos = (self.LastBox:GetPos() + NewDirVec) + self.Boundaries[k + 1],
					filter = {self,self.LastBox}
				})

				if T.Hit or T.StartSolid then
					Obstructed = true
					break
				end
			end

			return Trace.StartSolid or Obstructed or false
		elseif Type == 2 then
			return Trace.HitWorld or Trace.HitSky or false
		end
	end

	function ENT:CheckStepZone()
		if not IsValid(self.LastBox) then return false end

		for k = 1,#self.OnBoxBoundaries,2 do
			local T = util.TraceLine({
				start = self.LastBox:GetPos() + self.OnBoxBoundaries[k],
				endpos = self.LastBox:GetPos() + self.OnBoxBoundaries[k + 1],
				filter = {self,self.LastBox},
				ignoreworld = true
			})

			if T.Entity == self.Gamer then return true end
		end

		return false
	end

	function ENT:SafeEmitSound(Path,Volume)
		if not IsValid(self.Gamer) then return end
		self.Gamer:EmitSound(Path,Volume)
	end

	function ENT:OnRemove()
		for _,v in pairs(self.BoxTable) do
			if IsValid(v) then
				v:Remove()
			end
		end

		for _,v in pairs(self.Headcrabs) do
			if IsValid(v) then
				v:Remove()
			end
		end

		if IsValid(self.Grenade) then self.Grenade:Remove() end
		if IsValid(self.DuckEnt) then self.DuckEnt:Remove() end

		self:Remove() -- This is required in case it was called by CallError()
	end

	function ENT:CallError()
		self:SafeEmitSound("vo/k_lab/kl_ohdear.wav")
		self:OnRemove()
	end

	function ENT:SpawnBox(Pos)
		local Box = ents.Create("ent_climbform_box")
		Box:SetPos(Pos)
		Box:SetAngles(angle_zero)
		Box.Owner = self.Gamer
		Box:Spawn()

		if IsValid(Box) then
			Box:EmitSound("physics/wood/wood_box_impact_hard" .. math.random(1,3) .. ".wav")

			if IsValid(self.BoxTable[1]) and #self.BoxTable >= 10 then
				self.BoxTable[1]:Remove()
				table.remove(self.BoxTable,1)
			end

			table.insert(self.BoxTable,Box)

			return Box
		else
			self:CallError()
		end
	end

	function ENT:GenDir()
		local RandDir = math.random(1,4)

		if RandDir == 1 then
			self.DirectionVec = self.LastBox:GetForward() * self.BoxSize + ((self.LastBox:GetUp()) * self.BoxSize)
			self.LastDirectionVec = self.LastBox:GetForward()
		elseif RandDir == 2 then
			self.DirectionVec = -(self.LastBox:GetForward()) * self.BoxSize + ((self.LastBox:GetUp()) * self.BoxSize)
			self.LastDirectionVec = -self.LastBox:GetForward()
		elseif RandDir == 3 then
			self.DirectionVec = self.LastBox:GetRight() * self.BoxSize + ((self.LastBox:GetUp()) * self.BoxSize)
			self.LastDirectionVec = self.LastBox:GetRight()
		elseif RandDir == 4 then
			self.DirectionVec = -(self.LastBox:GetRight()) * self.BoxSize + ((self.LastBox:GetUp()) * self.BoxSize)
			self.LastDirectionVec = -self.LastBox:GetRight()
		end
	end

	function ENT:CallStack(BoolOpti)
		if BoolOpti == nil then BoolOpti = false end
		if self.GameFinished then return end

		if not IsValid(self.Gamer) then
			ENT:OnRemove()
			return
		end

		self:GenDir()

		if self.DirectionVec then
			if not BoolOpti and self:CheckBoundaries(self.DirectionVec,1) then
				local FailSafe = 0

				repeat
					self:GenDir()
					FailSafe = FailSafe + 1
				until not self:CheckBoundaries(self.DirectionVec,1) or FailSafe > 50

				if FailSafe > 50 then return end
			end

			if not self:CheckBoundaries(self.DirectionVec,2) then
				self:SafeEmitSound("buttons/button17.wav",90)
				self.LastBox:SetColor(ColorFadedGreen)
				self.ClimbCount = self.ClimbCount + 1

				if self.ClimbCount == 1 then self:SafeEmitSound("vo/npc/barney/ba_letsdoit.wav",90) end
				if self.ClimbCount == 10 then self:SafeEmitSound("vo/eli_lab/al_allright01.wav",90) end
				if self.ClimbCount == 20 then self:SafeEmitSound("vo/eli_lab/al_awesome.wav",90) end
				if self.ClimbCount == 50 then self:SafeEmitSound("vo/eli_lab/al_sweet.wav",90) end

				--Random Events
				local HeadcrabBool = false
				if self.ClimbCount > 15 and self.ClimbCount % 5 == 0 and self.ClimbCount % 10 ~= 0 then -- Start triggering at 20+ boxes every 5th or 10th.
					local RandN = math.random(1,100)

					if RandN > 60 then
						local RandNE = math.random(1,3)

						if RandNE == 1 then -- Grenade event
							self:SafeEmitSound("vo/npc/barney/ba_grenade02.wav")
							self.Grenade = ents.Create("npc_grenade_frag")
							self.Grenade:SetPos(self.LastBox:GetPos() + VectorCache3)
							self.Grenade:SetAngles(AngleCache1)
							self.Grenade:Spawn()
							self.Grenade:Input("SetTimer",nil,nil,3)
						elseif RandNE == 2 then -- Headcrab event
							self:SafeEmitSound("vo/npc/barney/ba_headhumpers.wav",75)
							HeadcrabBool = true
						elseif RandNE == 3 then -- Flying washing machine event
							self:SafeEmitSound("vo/npc/barney/ba_duck.wav",90)

							timer.Simple(3,function()
								if not IsValid(self) or not IsValid(self.LastBox) then return end
								if IsValid(self.DuckEnt) then self.DuckEnt:Remove() end -- Don't have more than one active at the same time!

								self.DuckEnt = ents.Create("prop_physics")
								self.DuckEnt:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
								self.DuckEnt:SetPos(self.LastBox:GetPos() + ((self.LastDirectionVec * 400) + VectorCache4))
								self.DuckEnt:SetAngles(angle_zero)
								self.DuckEnt:Spawn()

								if IsValid(self.DuckEnt) then
									local Phys = self.DuckEnt:GetPhysicsObject()
									if IsValid(Phys) then
										Phys:SetVelocity(-(self.LastDirectionVec * 50000))
									end

									if BoolOpti then
										self.DuckEnt:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
									end

									self.DuckEnt:Ignite(5)
									self.DuckEnt:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1,14) .. ".wav",90)
								end

								timer.Simple(3,function()
									if IsValid(self) and IsValid(self.DuckEnt) then
										self.DuckEnt:Remove()
									end
								end)
							end)
						end
					end
				end

				self.LastBox = self:SpawnBox(self.LastBox:GetPos() + self.DirectionVec)

				if BoolOpti then
					self.Gamer:SetPos(self.LastBox:GetPos() + Vector(0,0,self.CenterToEdge - 0.25))
				end

				self:SetNWInt("Climbcount",self.ClimbCount)

				if HeadcrabBool then
					local Headcrab = ents.Create("npc_headcrab")
					Headcrab:SetPos(self.LastBox:GetPos() + Vector(0,0,self.CenterToEdge + 10))
					Headcrab:Spawn()

					if BoolOpti then
						Headcrab:TakeDamage(Headcrab:Health(),self.Gamer,IsValid(self.Gamer:GetActiveWeapon()) and self.Gamer:GetActiveWeapon() or self.Gamer)
					end

					Headcrab.SpawnPos = Headcrab:GetPos()
					table.insert(self.Headcrabs,Headcrab)
				end
			else
				for k,v in pairs(self.BoxTable) do
					v:SetColor(ColorFadedOrange)
				end

				self:SetColor(ColorFadedOrange)
				self:SafeEmitSound("vo/npc/barney/ba_ohyeah.wav",90)
				self:SetNWBool("GameFinished",true)
				self:SetNWInt("Climbcount",self.ClimbCount)
				self.GameFinished = true
			end
		end
	end

	function ENT:Think()
		local GamerValid = IsValid(self.Gamer)
		if not self.Fell and not IsValid(self.LastBox) then self:CallError() end
		if IsValid(self) then self:SetAngles(angle_zero) end

		if not GamerValid then
			for k,v in pairs(ents.FindInSphere(self.LastBox:GetPos() + VectorCache1,1)) do
				if v:IsPlayer() then
					self:SetNWEntity("SharedOwner",v)
					self.Gamer = v
					break
				end
			end

			if CurTime() > self.IdleTime + 30 then
				self:EmitSound(self.MotivationalSounds[math.random(1,#self.MotivationalSounds)],90)
				self.IdleTime = CurTime()
			end
		else
			for k = #self.Headcrabs,1,-1 do
				if IsValid(self.Headcrabs[k]) then
					if self.Headcrabs[k]:GetPos():Distance(self.Headcrabs[k].SpawnPos) > 250 then
						self.Headcrabs[k]:Remove()
						table.remove(self.Headcrabs,k)
					end
				else
					table.remove(self.Headcrabs,k)
				end
			end

			for k,v in pairs(self.BoxTable) do
				if not IsValid(v) then
					self:CallError()
					break
				end
			end

			if not self.Fell and GamerValid and IsValid(self.LastBox) and (self.Gamer:GetPos():Distance(self.LastBox:GetPos()) > (self.BoxSize * 4) or (self.Gamer:GetMoveType() == MOVETYPE_NOCLIP or self.Gamer:InVehicle())) then
				self:SafeEmitSound("vo/npc/barney/ba_downyougo.wav")
				self.Fell = true
				self:SetNWBool("Fell",true)
				self:SetNWInt("Climbcount",self.ClimbCount)

				if MMM and self.ClimbCount > 20 then --Rewards
					self.Gamer:AddCoins(self.ClimbCount)
					self.Gamer:EmitSound("ambient/levels/labs/coinslot1.wav")
					self.Gamer:ChatPrint("You've been rewarded with: " .. self.ClimbCount .. " coins!")
				end

				timer.Create("DestroyBoxes",0.1,#self.BoxTable,function()
					if not self.BoxTable then return end
					if #self.BoxTable <= 1 then self:OnRemove() end
					if not IsValid(self.BoxTable[#self.BoxTable]) then return end

					self.BoxTable[#self.BoxTable]:EmitSound("physics/wood/wood_crate_break" .. math.random(1,5) .. ".wav",75)
					self.BoxTable[#self.BoxTable]:Remove()
					table.remove(self.BoxTable,#self.BoxTable)
				end)
			end

			if not self.Fell then
				if DevCheat(self.Gamer) then
					self:CallStack(true)
					self:NextThink(CurTime() + 0.06) --Gotta go fast

					return true
				elseif self:CheckStepZone() and not self.Gamer:Crouching() then
					self:CallStack()
				end
			end
		end
	end

	-- The minigame may only be picked up when it hasn't started yet!
	function ENT:PhysgunPickup() return not IsValid(self.Gamer) end
	function ENT:EntityTakeDamage() return true end
	function ENT:CanTool() return false end
end

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
	local UndecorateNick = UndecorateNick or function(Str) return Str end

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

	function ENT:OnRemove() end

	function ENT:Draw()
		self.BaseClass.Draw(self)
		self.SharedOwner = self:GetNWEntity("SharedOwner")
		self.ClimbCountC = self:GetNWInt("Climbcount")

		if not IsValid(self.SharedOwner) and (self:GetPos() ~= self.LastPos or self:GetAngles() ~= self.LastAng) then
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

			if self:GetNWBool("Fell") then
				chat.AddText(ColorWhite,"[",ColorOrangeIsh,"Climbgame",ColorWhite,"]: You managed to climb ",ColorOrangeIsh,Count,ColorWhite,Count > 1 and " Boxes!" or " Box!")
			end

			if self:GetNWBool("GameFinished") then
				chat.AddText(ColorWhite,"[",ColorOrangeIsh,"Climbgame",ColorWhite,"]: You made it to the top in ",ColorOrangeIsh,Count,ColorWhite,Count > 1 and " Boxes!" or " Box!")
			end

			self:SetNextClientThink(CurTime() + 100000) -- We only want this to be displayed once! This method is better than using a variable.
			return true
		end
	end
end
