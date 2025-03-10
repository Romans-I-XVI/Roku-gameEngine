sub DrawImage(image as object)
    if not image.enabled or image.opacity = 0 then return
    region = image.regions[image.index]
    if region = invalid then return

    x = image.owner.x + image.x + image.offsetX
    y = image.owner.y + image.y + image.offsetY
    regionOffsetX = image.spriteSourceSizes[image.index].x
    regionOffsetY = image.spriteSourceSizes[image.index].y
    sourceWidth = image.spriteSourceSizes[image.index].w
    sourceHeight = image.spriteSourceSizes[image.index].h

    opacity = image.opacity
    if image.owner.opacity <> invalid
        if image.owner.opacity = 0 then return
        opacity = image.owner.opacity * opacity
    end if
    rgba = addOpacityToHEXColor(image.color, opacity)
    if image.scaleX = 1 and image.scaleY = 1 and image.rotation = 0
        image.drawTo.DrawObject(x + regionOffsetX, y + regionOffsetY, region, rgba)

    else if image.rotation = 0
        transformCenterX = sourceWidth * image.transformCenterX
        transformCenterY = sourceHeight * image.transformCenterY
        region.setScaleMode(image.scaleMode)
        region.SetPreTranslation(regionOffsetX - transformCenterX, regionOffsetY - transformCenterY)
        image.drawTo.DrawScaledObject(x + transformCenterX, y + transformCenterY, image.scaleX, image.scaleY, region, rgba)
        region.SetPreTranslation(0, 0)

    else
        transformCenterX = sourceWidth * image.transformCenterX
        transformCenterY = sourceHeight * image.transformCenterY
        region.setScaleMode(image.scaleMode)
        region.SetPreTranslation(regionOffsetX - transformCenterX, regionOffsetY - transformCenterY)
        image.drawTo.DrawRotatedObject(x + transformCenterX, y + transformCenterY, -image.rotation, region, rgba)
        region.SetPreTranslation(0, 0)
    end if
end sub
