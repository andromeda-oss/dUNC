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

    -- Check that the clone runs and returns the expected value
    local result = cloned_function(2, 3)
    if result ~= 5 then
        return false, "Cloned function returned incorrect result"
    end

    -- Check identity (should not be the same function)
    if cloned_function == dummy_function then
        return false, "Cloned function is identical to original"
    end

    -- Check environment match
    if getfenv(cloned_function) ~= getfenv(dummy_function) then
        return false, "Environments do not match between original and clone"
    end

    -- Test independence from original (simulate a hook on the original)
    local original_called = false
    local function hook()
        original_called = true
        return 999
    end
    dummy_function = hook

    local clone_result = cloned_function(10, 20)
    if clone_result ~= 30 then
        return false, "Clone was affected by the hook on the original"
    end

    -- Confirm the original was indeed called once (to validate the hook is live)
    dummy_function(1, 1)
    if not original_called then
        return false, "Hook on original function was not triggered, invalid test"
    end

    if not called then
        return false, "Original function was never called before cloning, test inconclusive"
    end

    return true, "clonefunction works correctly"
end, nil
