return function()
    local mainThreadCaller = checkcaller()

    if mainThreadCaller ~= true then
        return false, "checkcaller() should return true from exploit thread"
    end

    local fromGameThread
    local done = false

    local bindable = Instance.new("BindableEvent")
    bindable.Event:Connect(function()
        fromGameThread = checkcaller()
        done = true
    end)

    bindable:Fire()

    local timeout = 1
    local start = os.clock()
    while not done and os.clock() - start < timeout do
        task.wait()
    end

    bindable:Destroy()

    if not done then
        return false, "Thread timeout — unable to verify game thread"
    end

    if fromGameThread ~= false then
        return false, "checkcaller() should return false from game thread"
    end

    return true, "checkcaller() correctly returned true and false in respective threads"
end, nil
