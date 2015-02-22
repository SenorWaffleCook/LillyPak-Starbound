-- copies a table
-- a local table returned by a function stays in scope because wizards
-- should work if any of the keys are also tables, I don't think we're doing that anywhere though
-- it'll blow up if a table contains itself or a table containing itself or a table containing a table containing itself etc - again, let me know if that's an issue
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

-- kludge to get around the eternal pain in my arsehole that is world wrap
function fixedEntityQuery(bl, tr)
	local ents = {}
	if tr[1] < bl[1] then
		local _i, _v
		local index = 1
		local dist = world.distance({0, 0}, bl)
		local halfents = world.entityQuery(bl, {bl[1] + dist[1] - 1, tr[2]})
		for _i, _v in pairs(halfents) do
			ents[index] = _v
			index = index + 1
		end
		halfents = world.entityQuery({0, bl[2]}, tr)
		for _i, _v in pairs(halfents) do
			ents[index] = _v
			index = index + 1
		end
	else
		ents = world.entityQuery(bl, tr)
	end
	return ents
end

-- second verse, same as the first
function fixedObjectQuery(bl, tr)
	local ents = {}
	if tr[1] < bl[1] then
		local _i, _v, _i2, _v2
		local index = 1
		local dist = world.distance({0, 0}, bl)
		local halfents = world.objectQuery(bl, {bl[1] + dist[1] - 1, tr[2]})
		for _i, _v in pairs(halfents) do
			ents[index] = _v
			index = index + 1
		end
		halfents = world.objectQuery({0, bl[2]}, tr)
		for _i, _v in pairs(halfents) do
			local notFound = true
			for _i2, _v2 in pairs(ents) do
				if _v2 == _v then notFound = false end
			end
			if notFound then
				ents[index] = _v
				index = index + 1
			end
		end
	else
		ents = world.objectQuery(bl, tr)
	end
	return ents
end