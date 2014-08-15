function class(proto)
    proto = proto or {}
    proto.__index = proto
    function proto.new(self, obj)
        setmetatable(obj, self)
        return obj
    end
    return proto
end
