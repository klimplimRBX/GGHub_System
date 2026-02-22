return function(ctx)
	local Lighting = ctx.Lighting

	local bloom, colorCorrection, sunRays, blurEffect, skyEffect

	local function resetShaders()
		for _, effect in ipairs(Lighting:GetChildren()) do
			if effect:IsA("PostEffect") or effect.ClassName:find("Effect") or effect:IsA("Sky") then
				effect:Destroy()
			end
		end
		bloom = Instance.new("BloomEffect", Lighting)
		colorCorrection = Instance.new("ColorCorrectionEffect", Lighting)
		sunRays = Instance.new("SunRaysEffect", Lighting)
		blurEffect = Instance.new("BlurEffect", Lighting)
		skyEffect = Instance.new("Sky", Lighting)
		skyEffect.Name = "Sky"
	end

	local function applyDefaultShader()
		resetShaders()
		Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(0, 0, 0)
		Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
		Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0); Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
		Lighting.ExposureCompensation = 0; Lighting.ClockTime = 14; Lighting.GeographicLatitude = 41.733
		Lighting.TimeOfDay = "14:00:00"
		bloom.Enabled = false; colorCorrection.Enabled = false; sunRays.Enabled = false; blurEffect.Enabled = false
		skyEffect.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
		skyEffect.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
		skyEffect.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
		skyEffect.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
		skyEffect.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
		skyEffect.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
	end

	local function applyDaytime()
		resetShaders()
		Lighting.Brightness = 3.93; Lighting.Ambient = Color3.fromRGB(0, 0, 0)
		Lighting.OutdoorAmbient = Color3.fromRGB(145, 128, 95)
		Lighting.ColorShift_Top = Color3.fromRGB(255, 236, 176); Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
		Lighting.ExposureCompensation = 0; Lighting.ClockTime = 14.5; Lighting.GeographicLatitude = 143
		bloom.Enabled = true; bloom.Intensity = 1.25; bloom.Size = 110; bloom.Threshold = 2.15
		colorCorrection.Enabled = true; colorCorrection.Brightness = 0.03; colorCorrection.Contrast = 0.19; colorCorrection.Saturation = 0.12
		sunRays.Enabled = false; blurEffect.Enabled = false
		skyEffect.SkyboxBk = "rbxassetid://6444884337"; skyEffect.SkyboxDn = "rbxassetid://6444884785"
		skyEffect.SkyboxFt = "rbxassetid://6444884337"; skyEffect.SkyboxLf = "rbxassetid://6444884337"
		skyEffect.SkyboxRt = "rbxassetid://6444884337"; skyEffect.SkyboxUp = "rbxassetid://6412503613"
	end

	local function applySunset()
		resetShaders()
		Lighting.Brightness = 3.8; Lighting.Ambient = Color3.fromRGB(172, 172, 172)
		Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
		Lighting.ColorShift_Top = Color3.fromRGB(255, 174, 43); Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
		Lighting.ExposureCompensation = -0.24; Lighting.ClockTime = 7.1; Lighting.GeographicLatitude = 72
		bloom.Enabled = true; bloom.Intensity = 1; bloom.Size = 56; bloom.Threshold = 1.82
		colorCorrection.Enabled = true; colorCorrection.Brightness = 0; colorCorrection.Contrast = 0.1; colorCorrection.Saturation = -0.2
		sunRays.Enabled = true; sunRays.Intensity = 0.18; blurEffect.Enabled = false
		skyEffect.SkyboxBk = "rbxassetid://1009082031"; skyEffect.SkyboxDn = "rbxassetid://1009082487"
		skyEffect.SkyboxFt = "rbxassetid://1009082252"; skyEffect.SkyboxLf = "rbxassetid://1009082137"
		skyEffect.SkyboxRt = "rbxassetid://1009081946"; skyEffect.SkyboxUp = "rbxassetid://1009082428"
	end

	local function applyNight()
		resetShaders()
		Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(0, 0, 0)
		Lighting.OutdoorAmbient = Color3.fromRGB(145, 128, 95)
		Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0); Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
		Lighting.ExposureCompensation = 0; Lighting.ClockTime = 3; Lighting.GeographicLatitude = 41.733
		bloom.Enabled = true; bloom.Intensity = 1; bloom.Size = 90; bloom.Threshold = 2
		colorCorrection.Enabled = true; colorCorrection.Brightness = 0.04; colorCorrection.Contrast = 0.19; colorCorrection.Saturation = 0.12
		sunRays.Enabled = true; sunRays.Intensity = 0.18
		blurEffect.Enabled = true; blurEffect.Size = 0
		skyEffect.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
		skyEffect.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
		skyEffect.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
		skyEffect.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
		skyEffect.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
		skyEffect.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
	end

	local function applyCloudy()
		resetShaders()
		Lighting.Brightness = 5.63; Lighting.Ambient = Color3.fromRGB(0, 0, 0)
		Lighting.OutdoorAmbient = Color3.fromRGB(89, 68, 47)
		Lighting.ColorShift_Top = Color3.fromRGB(207, 114, 0); Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
		Lighting.ExposureCompensation = 0.63; Lighting.ClockTime = 17.63; Lighting.GeographicLatitude = 21.589
		bloom.Enabled = true; bloom.Intensity = 1; bloom.Size = 90; bloom.Threshold = 2
		colorCorrection.Enabled = true; colorCorrection.Brightness = 0.04; colorCorrection.Contrast = 0.15; colorCorrection.Saturation = 0.2
		sunRays.Enabled = true; sunRays.Intensity = 0.004
		blurEffect.Enabled = true; blurEffect.Size = 0
		skyEffect.SkyboxBk = "rbxassetid://2177969403"; skyEffect.SkyboxDn = "rbxassetid://2177972406"
		skyEffect.SkyboxFt = "rbxassetid://2177970251"; skyEffect.SkyboxLf = "rbxassetid://2177969836"
		skyEffect.SkyboxRt = "rbxassetid://2177968823"; skyEffect.SkyboxUp = "rbxassetid://2177971305"
	end

	local function applyShore()
		resetShaders()
		Lighting.Brightness = 1.92; Lighting.Ambient = Color3.fromRGB(109, 117, 135)
		Lighting.OutdoorAmbient = Color3.fromRGB(36, 47, 58)
		Lighting.ColorShift_Top = Color3.fromRGB(226, 75, 0); Lighting.ColorShift_Bottom = Color3.fromRGB(248, 165, 159)
		Lighting.ExposureCompensation = -0.2; Lighting.ClockTime = 17.6; Lighting.GeographicLatitude = 0
		bloom.Enabled = true; bloom.Intensity = 1; bloom.Size = 50; bloom.Threshold = 2.29
		colorCorrection.Enabled = true; colorCorrection.Brightness = 0; colorCorrection.Contrast = 0.2; colorCorrection.Saturation = 0
		sunRays.Enabled = true; sunRays.Intensity = 0.024
		blurEffect.Enabled = false; blurEffect.Size = 4
		skyEffect.SkyboxBk = "rbxassetid://88585370973398"; skyEffect.SkyboxDn = "rbxassetid://128014535205529"
		skyEffect.SkyboxFt = "rbxassetid://85323615042244"; skyEffect.SkyboxLf = "rbxassetid://77415797450913"
		skyEffect.SkyboxRt = "rbxassetid://127566931602371"; skyEffect.SkyboxUp = "rbxassetid://102320981098060"
	end

	return {
		applyDefaultShader = applyDefaultShader,
		applyDaytime = applyDaytime,
		applySunset = applySunset,
		applyNight = applyNight,
		applyCloudy = applyCloudy,
		applyShore = applyShore,
	}
end
