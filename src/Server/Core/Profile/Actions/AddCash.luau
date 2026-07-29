return {
	AddCash = function(replica, action)
		local data = replica.Data

		if typeof(action.Amount) ~= "number" or action.Amount <= 0 then
			return "InvalidAmount"
		end

		replica:Set({ "Currencies", "Cash" }, data.Currencies.Cash + action.Amount)

		return "Added"
	end,
}
