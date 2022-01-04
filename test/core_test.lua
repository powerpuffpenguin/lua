local test = require("test.luaunit")
local core = require("src.core")
local Object, Error, TypeError, RangeError = core.Object, core.Error, core.TypeError, core.RangeError
local class, instanceof, typeof = core.class, core.instanceof, core.typeof
local try, catch, finally, throw = core.try, core.catch, core.finally, core.throw

function TestCore_Object()
    local o = Object.new()
    local e = Error.new("test err")
    local et = TypeError.new("test type err")
    local er = RangeError.new("test range err")

    test.assertIsTrue(o:instanceof(Object))
    test.assertIsTrue(o:typeof(Object))
    test.assertIsFalse(o:instanceof(Error))
    test.assertIsTrue(instanceof(o, Object))
    test.assertIsTrue(typeof(o, Object))
    test.assertIsFalse(instanceof(o, Error))

    test.assertIsTrue(e:instanceof(Object))
    test.assertIsFalse(e:typeof(Object))
    test.assertIsTrue(e:instanceof(Error))
    test.assertIsTrue(instanceof(e, Object))
    test.assertIsFalse(typeof(e, Object))
    test.assertIsTrue(instanceof(e, Error))

    test.assertIsTrue(et:instanceof(Object))
    test.assertIsFalse(et:typeof(Object))
    test.assertIsTrue(et:instanceof(Error))
    test.assertIsTrue(et:instanceof(TypeError))
    test.assertIsFalse(et:instanceof(RangeError))
    test.assertIsTrue(et:typeof(TypeError))
    test.assertIsFalse(et:typeof(RangeError))
    test.assertIsTrue(instanceof(et, Object))
    test.assertIsFalse(typeof(et, Object))
    test.assertIsTrue(instanceof(et, Error))
    test.assertIsTrue(instanceof(et, TypeError))
    test.assertIsFalse(instanceof(et, RangeError))
    test.assertIsTrue(typeof(et, TypeError))
    test.assertIsFalse(typeof(et, RangeError))

    test.assertIsTrue(er:instanceof(Object))
    test.assertIsFalse(er:typeof(Object))
    test.assertIsTrue(er:instanceof(Error))
    test.assertIsFalse(er:instanceof(TypeError))
    test.assertIsTrue(er:instanceof(RangeError))
    test.assertIsFalse(er:typeof(TypeError))
    test.assertIsTrue(er:typeof(RangeError))
    test.assertIsTrue(instanceof(er, Object))
    test.assertIsFalse(typeof(er, Object))
    test.assertIsTrue(instanceof(er, Error))
    test.assertIsFalse(instanceof(er, TypeError))
    test.assertIsTrue(instanceof(er, RangeError))
    test.assertIsFalse(typeof(er, TypeError))
    test.assertIsTrue(typeof(er, RangeError))

    test.assertEquals("Object", o:toString())
    test.assertEquals("Error: test err", e:toString())
    test.assertEquals("TypeError: test type err", et:toString())
    test.assertEquals("TypeError: test type err", et:toString())
end

function TestCore_SetGet()
    ---@class Cat : Object
    ---@field x integer
    ---@field get integer
    ---@field set integer
    local Cat = class("Cat")
    local getter = {}
    function getter:x()
        self.get = self.get + 1
        return self._x
    end
    local setter = {}
    function setter:x(v)
        self.set = self.set + 1
        self._x = v
    end
    function Cat.new()
        return Cat:__extends(
            nil,
            {
                get = 0,
                set = 0,
                _x = 0,
                __getter = getter,
                __setter = setter
            }
        )
    end

    local c = Cat.new()
    local c1 = Cat.new()
    test.assertEquals(c:toString(), "Cat")
    local v = c.x
    test.assertEquals(v, 0)
    test.assertEquals(c.get, 1)
    test.assertEquals(c.set, 0)
    test.assertEquals(c1.get, 0)
    test.assertEquals(c1.set, 0)

    v = c.x
    test.assertEquals(v, 0)
    test.assertEquals(c.get, 2)
    test.assertEquals(c.set, 0)
    test.assertEquals(c1.get, 0)
    test.assertEquals(c1.set, 0)

    c1.x = 10
    test.assertEquals(c._x, 0)
    test.assertEquals(c.get, 2)
    test.assertEquals(c.set, 0)
    test.assertEquals(c1.get, 0)
    test.assertEquals(c1.set, 1)
    test.assertEquals(c1._x, 10)

    c1.x = 99
    test.assertEquals(c._x, 0)
    test.assertEquals(c.get, 2)
    test.assertEquals(c.set, 0)
    test.assertEquals(c1.get, 0)
    test.assertEquals(c1.set, 2)
    test.assertEquals(c1._x, 99)

    c.x = 5
    test.assertEquals(c._x, 5)
    test.assertEquals(c.get, 2)
    test.assertEquals(c.set, 1)
    test.assertEquals(c1.get, 0)
    test.assertEquals(c1.set, 2)
    test.assertEquals(c1._x, 99)

    local v = c.x
    test.assertEquals(v, 5)
    test.assertEquals(c._x, 5)
    test.assertEquals(c.get, 3)
    test.assertEquals(c.set, 1)
    test.assertEquals(c1.get, 0)
    test.assertEquals(c1.set, 2)
    test.assertEquals(c1._x, 99)
end

function TestCore_Try()
    local f0 = flase
    local v = 10
    try(
        function()
            try(
                function()
                    throw(Error.new("test err"))
                end,
                finally(
                    function()
                        f0 = true
                    end
                )
            )
        end,
        catch(
            function(e)
                v = v - 1
                if not instanceof(e, Object) or not typeof(e, Error) then
                    throw(e)
                end
            end
        ),
        finally(
            function()
                v = v / 9
            end
        )
    )

    test.assertIsTrue(f0)
    test.assertIsTrue(v == 1)
end
