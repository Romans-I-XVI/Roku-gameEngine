function asBoolean(input as dynamic) as boolean
    if isString(input)
        return LCase(input) = "true"
    else if isInteger(input) or isFloat(input)
        return input <> 0
    else if isBoolean(input)
        return input
    else
        return False
    end if
end function

function asString(input as dynamic) as string
    if isString(input)
        return input
    else if isInteger(input) or isFloat(input) or isDouble(input) or isBoolean(input) or isLongInteger(input)
        return input.ToStr()
    else
        return ""
    end if
end function

function asInteger(input as dynamic) as integer
    if isString(input)
        return input.ToInt()
    else if isInteger(input)
        return input
    else if isFloat(input) or isDouble(input) or isLongInteger(input)
        return Int(input)
    else
        return 0
    end if
end function

function asFloat(input as dynamic) as float
    if isString(input)
        return input.ToFloat()
    else if isInteger(input)
        return (input / 1)
    else if isFloat(input) or isDouble(input) or isLongInteger(input)
        return input
    else
        return 0.0
    end if
end function

function asDouble(input as dynamic) as double
    if isString(input)
        return asFloat(input)
    else if isInteger(input) or isLongInteger(input) or isFloat(input) or isDouble(input)
        return input
    else
        return 0.0
    end if
end function