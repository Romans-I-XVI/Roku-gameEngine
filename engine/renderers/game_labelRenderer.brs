sub DrawMultilineLabel(label as object)
    if not label.enabled then return
    opacity = label.opacity
    if opacity = 0 then return
    if label.owner.opacity <> invalid
        if label.owner.opacity = 0 then return
        opacity = label.owner.opacity * opacity
    end if
    x = label.owner.x + label.x
    y = label.owner.y + label.y
    text = label.getText()
    if label.shadowColor <> invalid
        _DrawMultilineLabel(label.drawTo, text, x + label.shadowX, y + label.shadowY, label.font, label.align, label.vertAlign, label.lineHeight, label.shadowColor, opacity)
    end if
    _DrawMultilineLabel(label.drawTo, text, x, y, label.font, label.align, label.vertAlign, label.lineHeight, label.color, opacity)
end sub

sub DrawLabel(label as object)
    if not label.enabled then return
    opacity = label.opacity
    if opacity = 0 then return
    if label.owner.opacity <> invalid
        if label.owner.opacity = 0 then return
        opacity = label.owner.opacity * opacity
    end if
    x = label.owner.x + label.x
    y = label.owner.y + label.y
    text = label.getText()
    if label.shadowColor <> invalid
        _DrawLabel(label.drawTo, text, x + label.shadowX, y + label.shadowY, label.font, label.align, label.shadowColor, opacity)
    end if
    _DrawLabel(label.drawTo, text, x, y, label.font, label.align, label.color, opacity)
end sub

sub _DrawMultilineLabel(draw2d as object, text as string, x as integer, y as integer, font as object, horizAlign as string, vertAlign as string, lineHeight as integer, color as integer, opacity as float)
    textList = text.split("\n")

    if vertAlign = "top"
        for i = 0 to textList.count() - 1
            _DrawLabel(draw2d, textList[i], x, y + lineHeight * i, font, horizAlign, color, opacity)
        end for

    else if vertAlign = "center"
        allLinesHeight = (textList.count() - 1) * lineHeight
        for i = 0 to textList.count() - 1
            _DrawLabel(draw2d, textList[i], x, y + lineHeight * i - allLinesHeight / 2, font, horizAlign, color, opacity)
        end for

    else if vertAlign = "bottom"
        for i = 0 to textList.count() - 1
            _DrawLabel(draw2d, textList[i], x, y - lineHeight * (textList.count() - i), font, horizAlign, color, opacity)
        end for
    end if
end sub

sub _DrawLabel(draw2d as object, text as string, x as integer, y as integer, font as object, alignment as string, color as integer, opacity as float)
    if alignment = "left"
        draw2d.DrawText(text, x, y, addOpacityToHEXColor(color, opacity), font)
    else if alignment = "center"
        draw2d.DrawText(text, x - font.GetOneLineWidth(text, 10000) / 2, y, addOpacityToHEXColor(color, opacity), font)
    else if alignment = "right"
        draw2d.DrawText(text, x - font.GetOneLineWidth(text, 10000), y, addOpacityToHEXColor(color, opacity), font)
    end if
end sub
