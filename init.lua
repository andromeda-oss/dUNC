local tests = {
    closures = {
        "checkcaller",
    },
}

local results = {
    passed = {},
    failed = {},
}

local function create_test(folder, name)
    local url = "https://raw.githubusercontent.com/andromeda-oss/dUNC/main/functions/"
    local file = url .. folder .. "/" .. name .. ".lua"

    local func, req = loadstring(game:HttpGet(file))()
    if type(func) ~= "function" then
        error(`Test file '{folder}/{name}' did not return a function`)
    end

    return func, req
end

local function run_test(folder, name)
    if results.passed[name] or results.failed[name] then return end

    local success, func, req = pcall(create_test, folder, name)
    if not success then
        results.failed[name] = "Load error: " .. tostring(func)
        warn("💥", name, "=> failed to load:", func)
        return
    end

    if type(req) == "table" then
        for _, required in ipairs(req) do
            local required_folder, required_name = required:match("^(.-)/(.-)$")
            if not required_folder or not required_name then
                results.failed[name] = "Invalid requirement format: " .. tostring(required)
                return
            end

            if not results.passed[required_name] and not results.failed[required_name] then
                run_test(required_folder, required_name)
            end

            if results.failed[required_name] then
                results.failed[name] = `Required test '{required}' failed`
                warn("❌", name, "=> blocked by failed requirement:", required)
                return
            end
        end
    end

    local ok, res, reason = pcall(function()
        return func(req)
    end)

    if ok then
        if res then
            results.passed[name] = reason or true
            print("✅", name, "=> working:", reason)
        else
            results.failed[name] = reason or false
            print("❌", name, "=> not working:", reason)
        end
    else
        results.failed[name] = "Runtime error: " .. tostring(res)
        warn("💥", name, "=> error during test:", res)
    end
end

for folder, testList in pairs(tests) do
    for _, name in ipairs(testList) do
        run_test(folder, name)
    end
end
