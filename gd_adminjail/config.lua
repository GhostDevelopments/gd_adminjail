Config = {}

-- Groups allowed to use admin commands (Ace Permissions are also checked)
Config.AdminGroups = { "admin", "god" }

-- Jail Settings
Config.JailLocation = vector4(459.55, -1001.56, 24.91, 180.0) -- Inside a cell
Config.ReleaseLocation = vector4(425.1, -979.5, 30.7, 0.0)    -- Outside Mission Row
Config.UseRoutingBuckets = true -- Put jailed players in their own dimension

-- Webhook (Replace with your URL)
Config.Webhook = ""

-- Controls to disable while jailed
Config.DisabledControls = {
    0, 1, 2, 24, 25, 37, 47, 58, 140, 141, 142, 143, 263, 264, 257
}

Config.Commands = {
    jail = "adminjail",
    unjail = "adminjailrelease",
    time = "adminjailtime",
    list = "adminjaillist"
}