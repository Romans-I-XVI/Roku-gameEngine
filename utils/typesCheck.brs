function isNumber(value as dynamic) as boolean
    return isInteger(value) or isFloat(value) or isDouble(value) or isLongInteger(value)
end function

function isList(value as dynamic) as boolean
    return type(value) = "roList" or type(value) = "roXMLList"
end function

function isArray(value as dynamic) as boolean
    return type(value) = "roArray" or type(value) = "roList" or type(value) = "roByteArray" or type(value) = "roXMLList"
end function

function isAssociativeArray(value as dynamic) as boolean
    return isValid(value) and GetInterface(value, "ifAssociativeArray") <> invalid
end function

function isString(value as dynamic) as boolean
    return type(value) = "String" or type(value) = "roString"
end function

function isDateTime(value as dynamic) as boolean
    return type(value) = "roDateTime"
end function

function isFunction(value as dynamic) as boolean
    return type(value) = "Function" or type(value) = "roFunction"
end function

function isBoolean(value as dynamic) as boolean
    return type(value) = "Boolean" or type(value) = "roBoolean"
end function

function isInteger(value as dynamic) as boolean
    return type(value) = "Integer" or type(value) = "roInteger" or type(value) = "roInt"
end function

function isFloat(value as dynamic) as boolean
    return type(value) = "Float" or type(value) = "roFloat"
end function

function isDouble(value as dynamic) as boolean
    return type(value) = "Double" or type(value) = "roDouble"
end function

function isLongInteger(value as dynamic) as boolean
    return type(value) = "LongInteger" or type(value) = "roLongInteger" ' it is impossible to create roLongInteger object though
end function

function isValid(value as dynamic) as boolean
    return Type(value) <> "<uninitialized>" and value <> invalid
end function