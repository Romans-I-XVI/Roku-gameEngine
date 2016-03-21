function arrayInsert(array, index, value)
	for i = array.Count() to index+1 step -1
		array[i] = array[i-1]
	end for
	array[index] = value
	return array
end function