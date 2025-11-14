local mat
local mat_name
function EFFECT:Init(data)
	local ent = data:GetEntity()
	if !IsValid(ent) then return end

	local pos = ent:GetPos() + Vector(0, 0, 1)

	local mat_names = string.Explode(",", ent:GetEffectNames())

	local new_mat_name = istable(mat_names) and mat_names[2]
	new_mat_name = new_mat_name and string.Trim(new_mat_name) != "" and string.Trim(new_mat_name) or "mg_ctf/star.png"

	local size = data:GetScale()
	local particles = data:GetRadius()
	local lifetime = data:GetMagnitude()
	local range = data:GetHitBox()

	local emitter = ParticleEmitter(pos)
	for i = 1, math.ceil(particles) do

		if !mat_name or mat_name != new_mat_name then
			mat = mat or Material(new_mat_name, "smooth")
			mat_name = new_mat_name
		end
		
		local particle = emitter:Add(mat, pos)
		if particle then
			local mult = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(0, 2))

			particle:SetVelocity(mult * range)
			particle:SetDieTime(1 * lifetime)	
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(size)
			particle:SetEndSize(size)
			particle:SetRoll(math.Rand(-180, 180))
			particle:SetRollDelta(math.Rand(-10, 10))
			particle:SetAirResistance(50)
			particle:SetGravity(Vector(0, 0, -50))
			particle:SetCollide(true)
			particle:SetBounce(1)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end