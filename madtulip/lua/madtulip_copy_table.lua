function copyTable(source)
	local _copy
	if type(source) == "table" then
		_copy = {}
		for k, v in pairs(source) do
			_copy[copyTable(k)] = copyTable(v)
		end
	else
		_copy = source
	end
	return _copy
end