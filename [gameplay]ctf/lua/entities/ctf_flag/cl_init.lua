include("shared.lua")

function ENT:Draw()
	local model = self:GetModel()

	local func = MG_CTF.PreDrawFunc[model]
	if func then
		func(self)
	end

	self:DrawModel()

	func = MG_CTF.PostDrawFunc[model]
	if func then
		func(self)
	end
end

function ENT:DrawTranslucent()
	local model = self:GetModel()

	local func = MG_CTF.PreDrawFuncTrans[model]
	if func then
		func(self)
	end

	if self:GetColor().a < 255 or self:GetRenderFX() != kRenderFxNone then
		self:DrawModel()
	end

	func = MG_CTF.PostDrawFuncTrans[model]
	if func then
		func(self)
	end
end