# lua
lua library

核心功能
* 模擬 class 支持單一派生
* class 支持 setter 和 getter
* 支持 instanceof 和 typeof 識別類型實例
* 支持 try catch finally 模擬

# why

lua 是一個非常靈活的語言，雖然語言本身特性很少，但可以使用 metatable 來構造各種有趣的特性以簡化編碼。

語言本身特性很少這意味着使用 lua 寫代碼會很繁瑣，例如你需要自己實現面向對象常用的功能，實現這些特性通常很容易犯錯且無聊。並且如果每次實現的都不同代碼則很難統一，故本庫就是爲解決此問題實現的一個面向對象的第三方庫。

# install

本庫沒有任何第三方依賴，將 **src/core.lua** 拷貝到 lua 庫目錄即可使用**類**和**異常處理**

此外在 core.lua 的基礎之上，我實現了一些常用的庫也放置在 src 檔案夾下，如果要使用這些功能記得也要將需要的 lua 源碼一起拷貝，最簡單的方法就是把 src 目錄下的所有東西都拷貝到 lua 庫目錄這樣可以使用本庫提供的所有功能

# 類

core 中包含三個和 class 相關的函數

* `function class(className: string): Class` 創建一個新的類型
* `function typeof(self, class: Class): boolean`如果 self 是類型 class 的實例返回 true，否則返回 false
* `function instanceof(self, class: Class): boolean` 如果 self 是 class 繼承鏈上的一個類型的實例返回 true，否則返回 false

typeof 和 instanceof 可用類型識別，這在後續使用 try catch 處理錯誤時或很有用，class 用於創建類型，下面是一個簡單的例子

```
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
```