local core = require("src.core")

-- create a new class,named Animal
local Animal = core.class("Animal")
-- create a constructor
function Animal:new()
    -- You need to call the __extends function to create an instance, this function will set some necessary information for the instance
    return Animal:__extends(
        nil, -- super instance, if nil will set Object.new
        nil -- instance, if nil will use {}
    )
end
-- Define static members
Animal.Race = "Earth"

-- Define function
function Animal:eat()
    print("animal eat")
end
function Animal:speak()
    print("animal speak")
end

-- Derive a subclass from Animal
local Cat = core.class("Cat")
function Cat:new()
    local position = {
        x = 0,
        y = 0
    }
    local setter = {}
    function setter:position(p)
        print("new position: (" .. p.x .. "," .. p.y .. ")")
        position.x = p.x
        position.y = p.y
    end
    local getter = {}
    function getter:position()
        return position
    end
    return Cat:__extends(
        Animal.new(), -- Construct the parent class
        {
            __setter = setter,
            __getter = getter
        }
    )
end
-- Override the parent class function
function Animal:speak()
    local p = self.position
    print("cat speak at (" .. p.x .. "," .. p.y .. ")")
end

Animal:new():eat()
local c1 = Cat.new()
local c2 = Cat.new()
c1:eat()
c1.position = {x = 5, y = 10}
c1:speak()
c2:speak()
