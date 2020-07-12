--Made by MrRangerLP

include("shared.lua")

if SERVER then
	resource.AddFile("materials/vgui/entities/ent_climbform.vmt")
	resource.AddFile("materials/vgui/entities/ent_climbform.vtf")

	local angle_zero = Angle(0,0,0) -- Let us not take any chances
	local vector_zero = Vector(0,0,0)
	local VectorCache2 = Vector(0,0,25)
	local VectorCache3 = Vector(0,0,500)
	local VectorCache4 = Vector(0,0,50)
	local VectorSetUpCheat = Vector(0,0,20.25)
	local VectorHeadcrabUpPos = Vector(0,0,30.5)
	local ColorFadedGreen = Color(0,200,0)
	local ColorFadedOrange = Color(200,200,0)
	local ColorOrangeIsh = Color(255,191,0)
	local ColorWhite = Color(255,255,255)

	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPISetOwner and true or false
	if not CPPIExists then -- Depending on the load order, CPPI might exist in the files but was not loaded yet so we set the variable at a later time
		hook.Add("InitPostEntity","ent_climbform_box_CPPI",function()
			CPPIExists = MetaE.CPPISetOwner and true or false
		end)
	end

	local SetOwnerCompatible = function(Ent,Ply) -- Convenience function
		if CPPIExists then
			Ent:CPPISetOwner(Ply)
		else
			Ent:SetNWEntity("my_owner",Ply) -- TinyCPPI Compatibility
		end
	end

	local DevCheat = function(Ply) -- Literally what it says. A cheat for developers for debugging and or simply for fun
		if (Ply:KeyDown(IN_USE) or Ply:KeyDown(IN_RELOAD)) and (Ply:SteamID() == "STEAM_0:0:41001543" or (aowl and aowl.CheckUserGroupLevel(Ply,"developers")) or (MMM and Ply.Data.RankPriority >= 99)) then return true end

		return false
	end

	local CheckBoundaries = function(Ent,NewDirVec,Type) -- Check if the requested area has enough space for a new box
		local LastPos = Ent.LastBox:GetPos()

		local Trace = util.TraceEntity({
			start = LastPos,
			endpos = LastPos + NewDirVec + Vector(0,0,NewDirVec.z * 2),
			filter = {Ent.LastBox,Ent.Gamer},
		},Ent.LastBox)

		if Type == 1 then -- Check a new generated direction
			local T = util.TraceEntity({
				start = LastPos + NewDirVec,
				endpos = LastPos + NewDirVec,
				filter = {Ent,Ent.LastBox},
			},Ent.LastBox)

			return Trace.StartSolid or T.Hit or false
		elseif Type == 2 then -- Check whether we are at the height limit
			return Trace.HitWorld or Trace.HitSky or false
		end
	end

	local BoundsMin = Vector(-20.308453,-20.150150,19.010790)
	local BoundsMax = Vector(20.231022,20.161650,22.010790)
	local CheckStepZone = function(Ent) -- Check whether a player is on top of the box
		local GamerPos = Ent.Gamer:GetPos()
		local LastPos = Ent.LastBox:GetPos()

		if GamerPos:WithinAABox(LastPos + BoundsMin,LastPos + BoundsMax) then
			return true
		end

		return false
	end

	local GenDir = function(Ent) -- Generate a new direction
		local HitCeiling = false
		local Obstructed = false
		local NewDir
		local RandDir = math.random(1,4)
		local EntGetUp = Ent.LastBox:GetUp() -- Tiny optimization

		if RandDir == 1 then -- We attempt to generate a random direction
			NewDir = Ent.LastBox:GetForward() * 41 + (EntGetUp * 41)
			Ent.LastDirectionVec = Ent.LastBox:GetForward()
		elseif RandDir == 2 then
			NewDir = -Ent.LastBox:GetForward() * 41 + (EntGetUp * 41)
			Ent.LastDirectionVec = -Ent.LastBox:GetForward()
		elseif RandDir == 3 then
			NewDir = Ent.LastBox:GetRight() * 41 + (EntGetUp * 41)
			Ent.LastDirectionVec = Ent.LastBox:GetRight()
		elseif RandDir == 4 then
			NewDir = -Ent.LastBox:GetRight() * 41 + (EntGetUp * 41)
			Ent.LastDirectionVec = -Ent.LastBox:GetRight()
		end

		HitCeiling = CheckBoundaries(Ent,NewDir,2)
		Obstructed = CheckBoundaries(Ent,NewDir,1)

		if HitCeiling or Obstructed then -- We failed so we try each possibility once
			for I = 1,4 do
				if I == 1 then
					NewDir = Ent.LastBox:GetForward() * 41 + (EntGetUp * 41)
					Ent.LastDirectionVec = Ent.LastBox:GetForward()
				elseif I == 2 then
					NewDir = -Ent.LastBox:GetForward() * 41 + (EntGetUp * 41)
					Ent.LastDirectionVec = -Ent.LastBox:GetForward()
				elseif I == 3 then
					NewDir = Ent.LastBox:GetRight() * 41 + (EntGetUp * 41)
					Ent.LastDirectionVec = Ent.LastBox:GetRight()
				elseif I == 4 then
					NewDir = -Ent.LastBox:GetRight() * 41 + (EntGetUp * 41)
					Ent.LastDirectionVec = -Ent.LastBox:GetRight()
				end

				HitCeiling = CheckBoundaries(Ent,NewDir,2)
				Obstructed = CheckBoundaries(Ent,NewDir,1)

				if not HitCeiling and not Obstructed then -- We did it
					break
				end
			end
		end

		return HitCeiling and 1 or Obstructed and 2 or NewDir
	end

	local SpawnBox = function(Ent,Pos)
		local Box = ents.Create("ent_climbform_box")
		Box:SetPos(Pos)
		Box:SetAngles(angle_zero)
		Box.Owner = Ent.Gamer
		Box:Spawn()

		if IsValid(Box) then
			Box:EmitSound("physics/wood/wood_box_impact_hard" .. math.random(1,3) .. ".wav")

			local BoxCount = #Ent.BoxTable

			-- Unfortunately AFAIK there is no way around of using table.remove and table.insert in this case
			if IsValid(Ent.BoxTable[1]) and BoxCount > 10 then
				Ent.BoxTable[1]:Remove()
				table.remove(Ent.BoxTable,1)
			end

			table.insert(Ent.BoxTable,Box)
			return Box
		else
			Ent:Remove() -- Error defuse everything
		end
	end

	hook.Add("PhysgunDrop","MMM_Climbform_FixAngles",function(_,Ent) -- It should have its' angles "fixed" and be frozen afterwards
		if Ent:GetClass() == "ent_climbform" then
			Ent:SetAngles(angle_zero)

			local Phys = Ent:GetPhysicsObject()
			if IsValid(Phys) then
				Phys:EnableMotion(false)
			end
		end
	end)

	hook.Add("CanPlayerUnfreeze","MMM_Climbform",function(_,Ent) -- It should never be in an unfrozen state
		if Ent:GetClass() == "ent_climbform" then
			return false
		end
	end)

	-- Functions above this line do not need to be defined individually and therefor save some memory
	----------------------------------------------------------------------------------------------------

	local MotivationalSounds = {
		"vo/eli_lab/al_buildastack.wav",
		"vo/eli_lab/al_giveittry.wav",
		"vo/eli_lab/al_havefun.wav",
		"vo/k_lab/al_letsdoit.wav",
		"vo/k_lab/al_moveon01.wav",
		"vo/k_lab/al_moveon02.wav",
		"vo/k_lab/ba_pissinmeoff.wav"
	}

	function ENT:Initialize()
		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:SetPos(self:GetPos() + VectorCache2)
		self:SetAngles(angle_zero)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local Phys = self:GetPhysicsObject()
		if IsValid(Phys) then
			Phys:EnableMotion(false)
		end

		self.GameState = false -- True = finished - False = not finished
		self.IsRemoving = false
		self.ClimbCount = 0
		self.Gamer = nil

		self.LastBox = self
		self.BoxTable = {}

		self.Headcrab = nil
		self.Grenade = nil
		self.DuckEnt = nil

		self.LastDirectionVec = nil -- This is used for the washing machine event

		self.IdleTime = CurTime() -- Used for motivational sounds
	end

	function ENT:Think()
		if not self.Gamer then -- No one has claimed this climbgame yet (The player gets defined in ENT:StartTouch)
			if CurTime() > self.IdleTime + 30 then -- Motivate people around to start playing
				self:EmitSound(MotivationalSounds[math.random(1,#MotivationalSounds)],90)
				self.IdleTime = CurTime()
			end

			return
		end -- All code below will only run when there is an active player


		if not IsValid(self.Gamer) then -- We had a gamer but they left while climbing
			self:Remove() -- Error defuse everything
			return
		end

		-- If we have a headcrab remove it when it gets to far away so it does not annoy other players when roaming
		if IsValid(self.Headcrab) and self.Headcrab:GetPos():DistToSqr(self.Headcrab.SpawnPos) > 122500 then  -- 350*350 = 122500 ( 350 Source units )
			self.Headcrab:Remove()
		end

		-------------------- We start with actual gameplay logic here

		-- If the player is to far away from the last spawned box it means that they failed so we end the game here (also anti-cheat measures)
		-- (41 * 4)*(41 * 4) = 26896 ( 164 Source units distance | 41 being the width of a box from one edge to the opposite )
		if not self.IsRemoving and (self.Gamer:GetPos():DistToSqr(self.LastBox:GetPos()) > 26896 or (not self.Gamer:Alive() or self.Gamer:GetMoveType() == MOVETYPE_NOCLIP or self.Gamer:InVehicle()) or (MMM and IsValid(self.Gamer.RagdollEnt))) then
			self.Gamer:EmitSound("vo/npc/barney/ba_downyougo.wav")

			self.LastBox = self
			self.GameState = true
			self:SetNWBool("Fell",true)
			self:SetNWInt("Climbcount",self.ClimbCount)

			self.IsRemoving = true

			-- Animation to break the boxes starting at the top
			local CachedName = "MMM_Climbform_Destroy_" .. self:EntIndex()
			timer.Create(CachedName,0.1,0,function()
				if not IsValid(self) then
					timer.Remove(CachedName)
					return
				end

				local Count = #self.BoxTable
				if Count < 1 then self:Remove() end -- We finished 'deconstructing' so we remove ourself
				local Ent = self.BoxTable[Count]
				if not IsValid(Ent) then -- Somehow the box does not exist anymore so we have to skip it for the next call
					table.remove(self.BoxTable,Count)
					return
				end

				self.BoxTable[Count]:EmitSound("physics/wood/wood_crate_break" .. math.random(1,5) .. ".wav",75)
				self.BoxTable[Count]:Remove()
				table.remove(self.BoxTable,Count) -- Again I hate to use table.remove etc.. but I do not know if there is a better method as of right now
			end)
		end

		-- If the game finished we do not need to continue
		if self.GameState then return end

		local DevCheatState = DevCheat(self.Gamer) -- Does the player use the devcheat in this call?
		if not DevCheatState and (self.Gamer:Crouching() or not CheckStepZone(self)) then return end -- Only advance when the player is not crouching as it could cause them to get stuck

		local NewDir = GenDir(self) -- Generate a new direction that is not obstructed (if possible)
		if NewDir == 1 or NewDir  == 2 then -- All directions are obstructed so we either reached the ceiling and won or there is no space anywhere
			for _,v in pairs(self.BoxTable) do v:SetColor(ColorFadedOrange) end
			if NewDir == 1 then self.Gamer:EmitSound("vo/npc/barney/ba_ohyeah.wav") end

			self.GameState = true
			self:SetNWBool("GameFinished",true)
			self:SetNWInt("Climbcount",self.ClimbCount)
			self:SetColor(ColorFadedOrange)

			return
		end

		self.ClimbCount = self.ClimbCount + 1
		self:SetNWInt("Climbcount",self.ClimbCount)
		self.LastBox:SetColor(ColorFadedGreen)
		self.LastBox = SpawnBox(self,self.LastBox:GetPos() + NewDir)
		self.Gamer:EmitSound("buttons/button17.wav")

		if self.ClimbCount < 50 then -- Every tiny optimization helps
			if self.ClimbCount == 1 then
				self.Gamer:EmitSound("vo/npc/barney/ba_letsdoit.wav")
			elseif self.ClimbCount == 10 then
				self.Gamer:EmitSound("vo/eli_lab/al_allright01.wav")
			elseif self.ClimbCount == 20 then
				self.Gamer:EmitSound("vo/eli_lab/al_awesome.wav")
			elseif self.ClimbCount == 50 then
				self.Gamer:EmitSound("vo/eli_lab/al_sweet.wav")
			end
		end

		-- Random Events
		if self.ClimbCount > 10 and self.ClimbCount % 10 == 0 and math.random(1,10) < 5 then -- Start triggering at 20+ boxes at every 10th (but not always)
			local RandNE = math.random(1,3)

			if RandNE == 1 then -- Grenade event
				if IsValid(self.Grenade) then self.Grenade:Remove() end
				self.Gamer:EmitSound("vo/npc/barney/ba_grenade02.wav")

				self.Grenade = ents.Create("npc_grenade_frag")
				self.Grenade:SetPos(self.LastBox:GetPos() + VectorCache3)
				self.Grenade:SetAngles(angle_zero)
				self.Grenade:Spawn()
				self.Grenade:Input("SetTimer",nil,nil,3)

				SetOwnerCompatible(self.Grenade,self.Gamer)

				if not DevCheatState then -- Some addons require this to be set in order to take damage from it
					self.Grenade:SetOwner(self.Gamer)
				end

			elseif RandNE == 2 then -- Headcrab event
				if IsValid(self.Headcrab) then self.Headcrab:Remove() end
				self.Gamer:EmitSound("vo/npc/barney/ba_headhumpers.wav")

				self.Headcrab = ents.Create("npc_headcrab")
				self.Headcrab:SetPos(self.LastBox:GetPos() + VectorHeadcrabUpPos)
				self.Headcrab:Spawn()
				self.Headcrab:SetEnemy(self.Gamer) -- I hope this will force the headcrab to engage the player

				SetOwnerCompatible(self.Headcrab,self.Gamer)

				-- Math magic to make the headcrab face the player after spawning
				local GamerPos = self.Gamer:GetPos()
				local HeadcrabPos = self.Headcrab:GetPos()
				self.Headcrab:SetAngles(Angle(0,math.atan2(GamerPos.y - HeadcrabPos.y,GamerPos.x - HeadcrabPos.x) * 57.2958,0))

				self.Headcrab.SpawnPos = HeadcrabPos

				if DevCheatState then
					local Wep = self.Gamer:GetActiveWeapon()
					self.Headcrab:TakeDamage(self.Headcrab:Health(),self.Gamer,IsValid(Wep) and Wep or self.Gamer)
				end

			elseif RandNE == 3 then -- Flying washing machine event
				self.Gamer:EmitSound("vo/npc/barney/ba_duck.wav")

				timer.Simple(3,function()
					if not IsValid(self) or not IsValid(self.LastBox) then return end
					if IsValid(self.DuckEnt) then self.DuckEnt:Remove() end

					self.DuckEnt = ents.Create("prop_physics")
					self.DuckEnt:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
					self.DuckEnt:SetPos(self.LastBox:GetPos() + (self.LastDirectionVec * 400 + VectorCache4))
					self.DuckEnt:Spawn()

					SetOwnerCompatible(self.DuckEnt,self.Gamer)

					if IsValid(self.DuckEnt) then -- We make sure it spawned since it is possible it spawned outside of the world or something and got removed
						local Phys = self.DuckEnt:GetPhysicsObject()
						if IsValid(Phys) then
							Phys:SetVelocity(-(self.LastDirectionVec * 50000))
						end

						-- Math magic to make the washing machine face the player after spawning
						local GamerPos = self.Gamer:GetPos()
						local DuckEntPos = self.DuckEnt:GetPos()
						self.DuckEnt:SetAngles(Angle(0,math.atan2(GamerPos.y - DuckEntPos.y,GamerPos.x - DuckEntPos.x) * 57.2958,0))

						if DevCheatState then
							self.DuckEnt:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
						end

						self.DuckEnt:Ignite(5)
						self.DuckEnt:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1,14) .. ".wav")
					end

					timer.Simple(3,function()
						if IsValid(self) and IsValid(self.DuckEnt) then
							self.DuckEnt:Remove()
						end
					end)
				end)
			end
		end

		if DevCheatState then
			self.Gamer:SetVelocity(vector_zero) -- Prevent movement spazzing
			self.Gamer:SetPos(self.LastBox:GetPos() + VectorSetUpCheat)
			self:NextThink(CurTime() + 0.06) -- Gotta go fast
			return true -- returning true is required for NextThink to work
		end
	end

	function ENT:StartTouch(Ply) -- This is a much better method compared to using FindInSphere in every think call
		self.Gamer = Ply

		if CheckStepZone(self) then -- The player is touching the entity.. good! But, are they on top of it?
			self:SetNWEntity("SharedOwner",Ply)
			self.StartTouch = nil -- For optimizations sake we do not want to run this again once someone claimed it
		else
			self.Gamer = nil
		end
	end

	function ENT:OnRemove()
		if MMM and self.ClimbCount and self.ClimbCount > 20 then -- Rewards (only works in a MeteorsManagementMod environment)
			self.Gamer:AddCoins(self.ClimbCount)
			self.Gamer:EmitSound("ambient/levels/labs/coinslot1.wav")

			net.Start("MMM_BroadcastMSG")
				net.WriteTable({ColorWhite,"[",ColorOrangeIsh,"Climbgame",ColorWhite,"]: You have been rewarded with ",ColorOrangeIsh,tostring(self.ClimbCount),ColorWhite," Coins!"})
			net.Send(self.Gamer)
		end

		for _,v in pairs(self.BoxTable) do
			if IsValid(v) then
				v:Remove()
			end
		end

		if IsValid(self.Grenade) then self.Grenade:Remove() end
		if IsValid(self.Headcrab) then self.Headcrab:Remove() end
		if IsValid(self.DuckEnt) then self.DuckEnt:Remove() end
	end

	function ENT:PhysgunPickup() return not IsValid(self.Gamer) end -- The minigame may only be picked up when it has not started yet
	function ENT:EntityTakeDamage() return true end
	function ENT:CanTool() return false end
end
