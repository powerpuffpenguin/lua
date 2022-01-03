---@class Class
---@field protected __class string
---@field protected __extends fun(super:table,instance:table):table

local function classIndex(class, self, key)
    -- class implemented
    local v = class[key]
    if v then
        return v
    end

    -- getter
    local getter = rawget(self, "__getter")
    if getter then
        local f = getter[key]
        if f then
            return f(self)
        end
    end

    -- get from parent
    local super = rawget(self, "super")
    if super then
        local result = super[key]
        if result then
            return result
        end
    end

    -- special
    if key == "toString" then
        return class["__toString"]
    end
end
local function classNewIndex(self, key, value)
    -- setter
    local current = self
    repeat
        local setter = rawget(self, "__setter")
        if setter then
            local f = setter[key]
            if f then
                return f(self, value)
            end
        end
        current = rawget(self, "super")
    until not current

    rawset(self, key, value)
end

--- The base class provides some common methods for all classes
---@class Object
---@field protected __class string
---@field protected __setter table
---@field protected __getter table
---@field protected super nil
---@field public toString fun():string
local Object

--- Create a type
---@overload fun(className:string):Class
---@param className string
---@return Class
local function class(className)
    local toString = function()
        return className
    end
    local cls = {
        __class = className,
        __toString = toString,
        __tostring = function(self)
            if self then
                return self:toString()
            end
            return className
        end,
        __newindex = classNewIndex
    }
    function cls:__index(key)
        return classIndex(cls, self, key)
    end
    function cls:__extends(super, instance)
        instance = instance or {}
        instance.super = super or Object.new()
        setmetatable(instance, cls)
        return instance
    end
    return cls
end

Object = class("Object")
--- new Object()
---@return Object
function Object.new()
    local instance = {}
    setmetatable(instance, Object)
    return instance
end
--- If self is an instance on the type inheritance chain, return true, otherwise return false
---@param t Class
---@return boolean
function Object:instanceof(t)
    while self do
        if getmetatable(self) == t then
            return true
        end
        self = self.super
    end
    return false
end
--- If self is an instance of the type, return true, otherwise return false
---@param t Class
---@return boolean
function Object:typeof(t)
    return getmetatable(self) == t
end

return {
    class = class,
    Object = Object
}
