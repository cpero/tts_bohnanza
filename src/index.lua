require("vscode/console")

local Constants = require("src.constants")
local GuidList = require("src.guidList")
local ObjectList = {}

function onLoad(save_state)
    loadObjects()
    print("Bohnanza loaded")
end

function onSave()
end

function loadObjects()
    ObjectList.Decks = {}
    for DeckName, Guid in pairs(GuidList.Decks) do
        ObjectList.Decks[DeckName] = getObjectFromGUID(Guid)
    end

    ObjectList.Players = {}
    for _, Color in ipairs(Constants.AvailableColors) do
        log(Color)
        ObjectList.Players[Color].Hand = getObjectFromGUID(GuidList.Players[Color].Hand)
        ObjectList.Players[Color].PanelLeft = getObjectFromGUID(GuidList.Players[Color].PanelLeft)
        ObjectList.Players[Color].PanelMid = getObjectFromGUID(GuidList.Players[Color].PanelMid)
        ObjectList.Players[Color].PanelRight = getObjectFromGUID(GuidList.Players[Color].PanelRight)
        ObjectList.Players[Color].ScriptLeft = getObjectFromGUID(GuidList.Players[Color].ScriptLeft)
        ObjectList.Players[Color].ScriptMid = getObjectFromGUID(GuidList.Players[Color].ScriptMid)
        ObjectList.Players[Color].ScriptRight = getObjectFromGUID(GuidList.Players[Color].ScriptRight)
    end

    ObjectList.ScriptDiscardDeck = getObjectFromGUID(GuidList.ScriptDiscardDeck)
    ObjectList.ScriptDrawDeck = getObjectFromGUID(GuidList.ScriptDrawDeck)
end