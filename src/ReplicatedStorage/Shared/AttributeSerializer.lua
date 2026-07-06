local HttpService = game:GetService("HttpService")

local AttributeSerializer = {}

function AttributeSerializer.DeepCopy(Original)
	local Copy = {}
	for k, v in pairs(Original) do
		if typeof(v) == "table" then
			Copy[k] = AttributeSerializer.DeepCopy(v)
		else
			Copy[k] = v
		end
	end
	return Copy
end

function AttributeSerializer.Serialize(Value)
	if typeof(Value) == "table" then
		return "table".. HttpService:JSONEncode(AttributeSerializer.DeepCopy(Value))
	end
	return Value
end

function AttributeSerializer.Deserialize(Value)
	if typeof(Value) == "string" then
		if string.sub(Value, 1, 5) == "table" then
			Value = string.sub(Value, 6)
			return HttpService:JSONDecode(Value)
		else
			return Value
		end
	else
		return Value
	end
end

return AttributeSerializer