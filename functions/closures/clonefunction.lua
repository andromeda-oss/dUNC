return function()
    if type(clonefunction) ~= "function" then
        return false, "clonefunction API is not available"
    end

    local called = false
    local function dummy_function(a, b)
        called = true
        return a + b
    end

    local cloned_function = clonefunction(dummy_function)

    -- Basic behavior test
    local result = cloned_function(2, 3)
    if result ~= 5 then
        return false, "Cloned function did not return correct result"
    end

    -- Check that it's not the same function
    if cloned_function == dummy_function then
        return false, "Cloned function is identical to original"
    end

    -- Check environment match
    if getfenv(cloned_function) ~= getfenv(dummy_function) then
        return false, "Cloned function does not have the same environment"
    end

    -- Hook the original, ensure clone is unaffected
    local original_called = false
    local function hook()
        original_called = true
        return 999
    end

    local old = dummy_function
    dummy_function = hook

    local clone_result = cloned_function(10, 20)
    if clone_result ~= 30 then
        return false, "Clone was affected by hooking the original"
    end

    if not called then
        return false, "Original function was not called during clone setup"
    end

    return true, "clonefunction works correctly"
end, nil
