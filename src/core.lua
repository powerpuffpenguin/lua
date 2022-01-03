--- # begin --- class

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
---@class Object : Class
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

--- Base class for all runtime errors
---@class Error : Object
---@field name string
---@field message string
local Error = class("Error")
--- new Error()
---@param message string
---@return Error
function Error.new(message)
    return Error:__extends(
        nil,
        {
            name = "Error",
            message = message
        }
    )
end
function Error:toString()
    return self.name .. ": " .. self.message
end
local TypeError = class("TypeError")
function TypeError.new(message)
    return Error:__extends(
        nil,
        {
            name = "TypeError",
            message = message
        }
    )
end
local RangeError = class("RangeError")
function RangeError.new(message)
    return Error:__extends(
        nil,
        {
            name = "RangeError",
            message = message
        }
    )
end

--- # end --- class

--- # begin --- try catch finally
--- throw an error, never return
---@param err any
local function throw(err)
    error(err, 0)
end

--- catch metatable
local Catch = {}
--- finally metatable
local Finally = {}
---@class CatchBlock
---@class FinallyBlock

---create code block
local function createBlock(f, mt)
    local block = {
        f = f
    }
    setmetatable(block, mt)
    return block
end
local function getBlock(v)
    local mt = getmetatable(v)
    if mt == Catch then
        return v, Catch
    elseif mt == Finally then
        return v, Finally
    end
end
local function getBlocks(v0, v1)
    local catch, finally
    if v0 then
        local v, mt = getBlock(v0)
        if v then
            if mt == Catch then
                catch = v
            else
                finally = v
            end
        else
            throw(TypeError.new("try function arg2 expected catch or finally block"))
        end
    end
    if v1 then
        local v, mt = getBlock(v1)
        if v then
            if mt == Catch then
                if catch then
                    error(TypeError.new("catch block duplicate"), 0)
                end
                catch = v
            else
                if finally then
                    throw(TypeError.new("finally block duplicate"))
                end
                finally = v
            end
        else
            throw(TypeError.new("try function arg3 expected catch or finally block"))
        end
    end
    return catch, finally
end
--- Run the block in exception capture mode
---@overload fun(block:fun())
---@overload fun(block:fun(),catchOrFinally:CatchBlock|FinallyBlock)
---@param block fun()
---@param arg2 CatchBlock
---@param arg3 FinallyBlock
local function tryCatchFinally(block, arg2, arg3)
    -- get blocks
    if type(block) ~= "function" then
        throw(TypeError.new("try block must be a function"))
    end
    local catch, finally = getBlocks(arg2, arg3)
    -- call block
    local ok, err = pcall(block)
    -- catch block exists
    if not ok then
        if catch then
            ok, err = pcall(catch.f, err)
        end
    end
    -- finally block exists
    if finally then
        local finallyOk, finallyErr = pcall(finally.f)
        if not finallyOk then
            throw(finallyErr)
        end
    end
    -- unhandled error
    if not ok then
        throw(err)
    end
end
--- # end --- try catch finally

return {
    class = class,
    Object = Object,
    Error = Error,
    TypeError = TypeError,
    RangeError = RangeError,
    --- create catch block
    ---@param f fun()
    ---@return CatchBlock
    catch = function(f)
        return createBlock(f, Catch)
    end,
    --- create finally block
    ---@param f fun()
    ---@return FinallyBlock
    finally = function(f)
        return createBlock(f, Finally)
    end,
    try = tryCatchFinally,
    throw = throw
}
