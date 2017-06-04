Global( "CurrencyLimit", 100 )
Global( "Whishlist", {
	{ "Экстракт мастерства", 0 },
	{ "Экстракт стойкости", 0 },
	{ "Острая рыбка", 0 },
	{ "Горькая настойка", 0 },
	{ "Маленький символ золота", 0 },
	{ "Отличные инструменты", 0 },
	{ "Эссенция судеб", 0 }
} )


function OnQuestionAdded ( params )
	local res = {}
	res["choice"] = 1
	local questions = questionLib.GetQuestions()
	if questions[0] then
		questionLib.SendData(questions[0], res)
	end
end


function OnVendorListUpdated ( params )
	local items = avatar.GetVendorList()
	for k, whish in pairs(Whishlist) do
		if whish[2]>0 then
			for i, item in pairs(items) do
				local itemId = items[i].id
				local name = itemLib.GetItemInfo(itemId).name
				if userMods.FromWString(name)==whish[1] then
					Whishlist[k][2] = Whishlist[k][2] - 1
					local currencies = avatar.GetCurrencies()
					for j, currency in pairs(currencies) do
						if userMods.FromWString(currency:GetInfo().name)=="Эмблема Поединка" and avatar.GetCurrencyValue(currency).value>CurrencyLimit then 
							avatar.Buy(itemId, 1)
							avatar.StopInteract()
							return
						end
					end
				end
			end
		end
	end
end


function OnGroupInvite ( params )
	group.Accept()
end


function OnMatchMakingProgressCompletedChanged ( params )
	matchMaking.ExitBattleEvent()
end


function OnCurrencyLimitReached ( params )
	local units = avatar.GetUnitList()
	for key, value in pairs(units) do
		if object.GetName(value)=="Гээл-Бран Хмурый" then
			avatar.StartInteract(value)
			return
		end
	end
end


function OnCurrencyValueChanged ( params )
	if (userMods.FromWString(params.id:GetInfo().name)=="Эмблема Поединка") and avatar.GetCurrencyValue(params.id).value>CurrencyLimit then
		common.RegisterEventHandler(OnCurrencyLimitReached, "EVENT_SECOND_TIMER")
	end
end


function OnTalkStarted ( params )
	common.UnRegisterEventHandler(OnCurrencyLimitReached, "EVENT_SECOND_TIMER")
	avatar.RequestVendor()
end


function Init()
	common.RegisterEventHandler( OnQuestionAdded, "EVENT_QUESTION_ADDED" )
	common.RegisterEventHandler( OnGroupInvite, "EVENT_GROUP_INVITE" )
	common.RegisterEventHandler( OnMatchMakingProgressCompletedChanged , "EVENT_MATCH_MAKING_EVENT_PROGRESS_COMPLETED_CHANGED")
	common.RegisterEventHandler( OnVendorListUpdated, "EVENT_VENDOR_LIST_UPDATED" )
	common.RegisterEventHandler( OnCurrencyValueChanged, "EVENT_CURRENCY_VALUE_CHANGED" )
	common.RegisterEventHandler( OnTalkStarted, "EVENT_TALK_STARTED")
end


Init()