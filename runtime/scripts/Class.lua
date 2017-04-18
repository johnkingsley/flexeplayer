return function (...)
    -- "cls" is the new class
    local cls = {}
    local bases = {...}

    -- copy base class contents into the new class
    for i, base in ipairs(bases) do
        for k, v in pairs(base) do
            cls[k] = v
        end
    end

    -- set the class's __index, and start filling an "is_a" table that contains this class and all of its bases
    -- so you can do an "instance of" check using my_instance.is_a[MyClass]
    cls.__index = cls
    cls.is_a = {
        [cls] = true,
    }
    for i, base in ipairs(bases) do
        for c in pairs(base.is_a) do
            cls.is_a[c] = true
        end
        cls.is_a[base] = true
    end

    local new_fnc = function (class, ...)
        local instance = setmetatable({}, class)

        -- run the _init method if it's there
        local init = instance._init
        if init then
            init(instance, ...)
        end

        return instance
    end
    setmetatable(cls, {
        __call = new_fnc,
    })

    return cls
end
