return {
    checkDead = true,
    locations = { -- Multi location support.
        {coords = vec4(2432.59, 4966.1, 46.81, 51.92), model = 'ig_mrs_thornhill', name = 'Grandma', busy = false},
        {coords = vec4(1974.38, 3820.33, 33.43, 215.01), model = 'cs_nigel', name = 'Grandpa', busy = false},
    },
    cost = 500,
    moneyType = 'bank', -- cash/bank ('cash' will convert to 'money' for ESX, so keep it as 'cash' if you wanna use cash and let the bridge handle it)
    duration = 10000,
}