sub game_defineResourcesFunctions(game as object)

	game.loadImageTexture = function(imageObject as object)
		bitmapName = imageObject.bitmapName
		if m.imagesTextures[bitmapName] = invalid
			m.imagesTextures[bitmapName] = {
				bitmap: invalid
				regionsConfig: invalid ' save here data from atlas
				relatedRegions: {}
			}
		end if

		texture = m.imagesTextures[bitmapName]
		texture.relatedRegions[imageObject.id] = {}
		currentRegions = texture.relatedRegions[imageObject.id]

		if texture.bitmap = invalid
			if m.staticBitmaps[bitmapName] = invalid
				bitmapConfig = m.artsConfig.bitmaps[bitmapName]
				texture.bitmap = m.getBitmapFromFs(bitmapConfig.localPath)
			else
				texture.bitmap = m.staticBitmaps[bitmapName]
				'print_info("Use static bitmap - " + bitmapName)
			end if
		end if

		' === atlas required images start ===
		if (isString(imageObject.regionName) or asBoolean(imageObject.isAnimation)) and texture.regionsConfig = invalid
			if m.staticAtlases[bitmapName] = invalid
				bitmapConfig = m.artsConfig.bitmaps[bitmapName]
				atlasConfig = m.formatAsAtlasConfig(bitmapConfig)
				texture.regionsConfig = textureParker_getRegionsConfigFromAtlas(m.getAtlasFromFs(atlasConfig.localPath))
			else
				texture.regionsConfig = m.staticAtlases[bitmapName]
				'print_info("Use static atlas - " + bitmapName)
			end if
		end if

		if isString(imageObject.regionName) ' use one region of bitmap atlas
			regionData = texture.regionsConfig[imageObject.regionName]
			currentRegions.regions = [CreateObject("roRegion", texture.bitmap, regionData.frame.x, regionData.frame.y, regionData.frame.w, regionData.frame.h)]
			currentRegions.spriteSourceSizes = [{ x: regionData.spriteSourceSize.x, y: regionData.spriteSourceSize.y, w: regionData.spriteSourceSize.w, h: regionData.spriteSourceSize.h }]

		else if asBoolean(imageObject.isAnimation) ' means all regions off current bitmap atlas belongs to one animation
			regionNames = []
			for each regionName in texture.regionsConfig
				regionNames.push({ name: regionName, nameForSort: asInteger(regionName) })
			end for

			regionNames.sortBy("nameForSort")

			currentRegions.regions = []
			currentRegions.spriteSourceSizes = []
			for each item in regionNames
				regionData = texture.regionsConfig[item.name]
				currentRegions.regions.push(CreateObject("roRegion", texture.bitmap, regionData.frame.x, regionData.frame.y, regionData.frame.w, regionData.frame.h))
				currentRegions.spriteSourceSizes.push({ x: regionData.spriteSourceSize.x, y: regionData.spriteSourceSize.y, w: regionData.spriteSourceSize.w, h: regionData.spriteSourceSize.h })
			end for
			' === atlas required images end ===

		else if isAssociativeArray(imageObject.frame) ' custom region
			currentRegions.regions = [CreateObject("roRegion", texture.bitmap, imageObject.frame.x, imageObject.frame.y, imageObject.frame.w, imageObject.frame.h)]
			if isAssociativeArray(imageObject.spriteSourceSize)
				currentRegions.spriteSourceSizes = [{ x: imageObject.spriteSourceSize.x, y: imageObject.spriteSourceSize.y, w: imageObject.spriteSourceSize.w, h: imageObject.spriteSourceSize.h }]
			else
				currentRegions.spriteSourceSizes = [{ x: 0, y: 0, w: imageObject.frame.w, h: imageObject.frame.h }]
			end if

		else
			bitmapW = texture.bitmap.getWidth()
			bitmapH = texture.bitmap.getHeight()
			currentRegions.regions = [CreateObject("roRegion", texture.bitmap, 0, 0, bitmapW, bitmapH)]
			currentRegions.spriteSourceSizes = [{ x: 0, y: 0, w: bitmapW, h: bitmapH }]
		end if

		return currentRegions
	end function

	game.unloadImageTexture = sub(imageObject as object)
		bitmapName = imageObject.bitmapName
		if m.imagesTextures[bitmapName] = invalid then return
		m.imagesTextures[bitmapName].relatedRegions.delete(imageObject.id)
		if m.imagesTextures[bitmapName].relatedRegions.count() = 0
			m.imagesTextures.delete(bitmapName)
			'print_info("Bitmap unloaded - " + bitmapName)
		end if
	end sub

	game.loadStaticBitmap = function(name as string, path as dynamic) as object
		'print_info("load static bitmap - " + name)
		if isAssociativeArray(path)
			m.staticBitmaps[name] = CreateObject("roBitmap", path)
		else
			m.staticBitmaps[name] = m.getBitmapFromFs(path)
		end if
		return m.staticBitmaps[name]
	end function

	game.addStaticBitmap = function(name as string, bitmap as object)
		m.staticBitmaps[name] = bitmap
	end function

	game.unloadStaticBitmap = sub(name as string)
		'print_info("unload static bitmap - " + name)
		m.staticBitmaps.delete(name)
	end sub

	game.loadStaticAtlas = sub(name as string, path as dynamic)
		m.staticAtlases[name] = m.getAtlasFromFs(path)
	end sub

	game.unloadStaticAtlas = sub(name as string)
		m.staticAtlases.delete(name)
	end sub

	game.getBitmapFromFs = function(path as string) as object
		if m.filesystem.Exists(path)
			path_object = CreateObject("roPath", path)
			parts = path_object.Split()
			if parts.extension = ".png" or parts.extension = ".jpg" or parts.extension = ".jpeg" or parts.extension = ".webp"
				'print_info("Bitmap loaded  - " + path)
				return CreateObject("roBitmap", path)
			else
				print_info("Bitmap not loaded, file must be of type .png or .jpg or .jpeg or .webp")
				return invalid
			end if

		else
			print_error("Bitmap not loaded, invalid path or object properties provided")
			print_info("Bitmap path " + asString(path) + " not exist")
			return invalid
		end if
	end function

	game.getAtlasFromFs = function(path as string) as string
		if m.filesystem.Exists(path)
			path_object = CreateObject("roPath", path)
			parts = path_object.Split()
			if parts.extension = ".json"
				'print_info("Atlas loaded - " + path)
				return ReadAsciiFile(path)
			else
				print_error("Atlas not loaded, file must be of type .json")
				return ""
			end if
		else
			print_error("Atlas not loaded, invalid path or object properties provided, path - " + asString(path))
			return ""
		end if
	end function

	game.formatAsAtlasConfig = function(config as object) as object
		res = {}
		for each key in config
			res[key] = config[key]
		end for

		keysList = ["serverFullPath", "serverPath", "localPath", "fileName"]

		for each key in keysList
			if isString(res[key])
				res[key] = res[key].Replace(".png", ".json").Replace(".webp", ".json")
			end if
		end for

		return res
	end function

	game.registerFont = function(path as string) as boolean
		if m.filesystem.Exists(path)
			path_object = CreateObject("roPath", path)
			parts = path_object.Split()
			if parts.extension = ".otf" or parts.extension = ".ttf"
				result = m.font_registry.register(path)
				print "[REGISTER FONT] " path " - result - " result
				print "[FONT FAMILIES] " m.font_registry.GetFamilies()
				return true
			else
				print_error("Font must be of type .ttf or .otf")
				return false
			end if
		else
			print_error("Font doesn't exist by path - " + asString(path))
			return false
		end if
	end function

	game.loadLabelTexture = function(labelObject as object) as object
		fontKey = labelObject.fontKey
		if m.labelsTextures[fontKey] = invalid
			m.labelsTextures[fontKey] = {
				font: invalid
				relatedLabels: {}
			}
		end if

		texture = m.labelsTextures[fontKey]
		if texture.font = invalid
			texture.font = m.font_registry.GetFont(labelObject.fontName, labelObject.fontSize, labelObject.italic, labelObject.bold)
			'print_info("Font loaded - " + fontKey)
		end if

		texture.relatedLabels[labelObject.id] = 1

		return texture.font
	end function

	game.unloadLabelTexture = sub(labelObject as object)
		fontKey = labelObject.fontKey
		if m.labelsTextures[fontKey] = invalid then return
		m.labelsTextures[fontKey].relatedLabels.delete(labelObject.id)
		if m.labelsTextures[fontKey].relatedLabels.count() = 0
			m.labelsTextures.delete(fontKey)
			'print_info("Font unloaded - " + fontKey)
		end if
	end sub

	game.getDefaultFont = function() as object
		return m.labelsTextures.default.font
	end function

	game.loadSound = sub(config as object)
		index = asInteger(config.index)
		if index > 0 and m.max_sound_channels < 2 then index = 1

		pauseable = config.pauseable
		if not isBoolean(pauseable) then pauseable = true

		interruptible = config.interruptible
		if not isBoolean(interruptible) then interruptible = true

		maxVolume = config.maxVolume
		if not isInteger(maxVolume) then maxVolume = 100

		m.Sounds[config.soundName] = {
			resource: CreateObject("roAudioResource", config.path)
			index: index
			pauseable: pauseable
			interruptible: interruptible
			maxVolume: maxVolume
		}
	end sub

	game.unloadSound = sub(config)
		m.Sounds.delete(config.soundName)
	end sub

end sub