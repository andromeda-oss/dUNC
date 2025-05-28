local function create_test(folder, name, callback, skip)
    if skip then return end

    local url = "https://raw.githubusercontent.com/andromeda-oss/dUNC/main/functions/"
    local file = url .. folder .. "/" .. name .. ".lua"

    local func, req = loadstring(game:HttpGet(file))()

    if type(func) ~= "function" then
        error("First return value from test file must be a function")
        return
    end

    callback(func, req)
end

create_test("closures", "checkcaller", function(func, req)
    print(req)
    local result = func()
end, false)