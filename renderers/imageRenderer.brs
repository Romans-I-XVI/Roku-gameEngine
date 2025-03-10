sub DrawImage(image as object)
    if image.enabled
        x = image.owner.x + image.offset_x
        y = image.owner.y + image.offset_y
        rgba = (image.color << 8) + int(image.alpha)
        if image.scale_x = 1 and image.scale_y = 1 and image.rotation = 0
            image.draw_to.DrawObject(x, y, image.region, rgba)
        else if image.rotation = 0
            image.draw_to.DrawScaledObject(x, y, image.scale_x, image.scale_y, image.region, rgba)
        else
            image.draw_to.DrawRotatedObject(x, y, -image.rotation, image.region, rgba)
        end if
    end if
end sub
