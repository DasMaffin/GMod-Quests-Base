# GMod Quests
## Requirements
### Icons:
https://steamcommunity.com/sharedfiles/filedetails/?id=3424588083
## ULX Access
- quests.manage - Grants access to the admin interface and ability to create new quests.
- quests.reroll - Grants access to the RerollQuests console command
## ConVars
- quests_startingQuests [num] - The amount of quests available to a player by default. 1 by default
- daily_reroll_time [HH:mm] - The time the quests get reset. 00:00 by default.
## ConCommands:
### ttt_quest_menu
Usage: ttt_quest_menu<br />
No parameters. Just toggles the quest menu on and off.
### AddQuest
Usage: AddQuest [QuestType] [weight] [finishInOneRound] [parameters] [rewards]<br /><br />
There are (by default) up to 3 rewards in the following order:<br />
Pointshop 2 points, Pointshop 2 premium points, Exp for a proprietary skilltree (You can leave it empty or set it 0. It will still work without it).<br /><br />

The weight determines how likely it is to appear. The higher, the more likely.<br />
Formula: (weight/Sum(allQuestsWeights)) * 100 = Chance in %<br />
So if the quest has a weight of 50, all quests (including this) have a total weight of 200, theres a ((50/200) * 100)% chance for the quest to appear (25% in this example).<br />
finishedInOneRound is a bool (0 and 1). If set then the quest resets if not finished after a round passes.
#### Killquest parameters:
[requiredKills] [roleToBeKilled] [roleForKiller]
| Role ID | Role Name  |  
|---------|------------|  
| 0       | Innocent   |  
| 1       | Traitor    |  
| 2       | Detective  |  

e.g.:<br />
- AddQuest KillQuest 50 0 5 0 1 50000 200 25000

WARNING: Some methds return it as number, but we use it as a string, so it may needs to be converted (I personally just tostring the number)

#### WalkerQuest parameters:
[requiredSteps] <br />
e.g.:<br />
- AddQuest WalkerQuest 50 0 50 50000 200 25000

#### SurviveQuest parameters:
[rounds] <br />
e.g.:<br />
- AddQuest SurviveQuest 50 0 5 50000 200 25000

#### KarmaQuest parameters:
[minKarma] [rounds] <br />
e.g.:<br />
- AddQuest KarmaQuest 50 0 1200 5 50000 200 25000


## Development
To add a new quest you must reqister it with:<br />
```lua
QuestManager.questTypes = {
    KillQuest = KillQuest,
    WalkerQuest = WalkerQuest
}
```
e.g. QuestManager.questTypes.CollectQuest = CollectQuest<br />
A quests UI must be registered with `vgui.Register(quest.type .. "HUD", PANEL, "EditablePanel")`<br />
They are not automatically loaded (unlike quests which are), so make sure you include them in the autorun of your extension.

### Hooks
#### Server
#### Client
##### QuestsUpdated
Gets called after the client got a new update for the local player's active quests. This sends a table of Quests as argument.
```lua
hook.Add("QuestsUpdated", "UpdateQuestHUD", function(questsTable)
    -- Update your quests HUD
end)
```
##### QuestNotEnoughArgs
Gets called when the user tries to input a new quest but doesnt deliver all necessary args
```lua
hook.Add("QuestNotEnoughArgs", "uniqueName", function(err)
  -- Display the error here
end)
```
##### AvailableQuestsUpdated
Gets called on the client after the server registered a new quest. Server registers quests on startup as well.
```lua
hook.Add("AvailableQuestsUpdated", "uniqueName", function(quests)
  -- loop over quests and display them
end)
```
##### AddAvailableQuest
The backend listens to this when you want to add a new quest.
```lua
hook.Run("AddAvailableQuest", questBase)
```
##### UpdateAvailableQuest
The backend listens to this when you want to change an existing quests value. Quests are found via their uniqueId, so thats a mandatory field here.
```lua
hook.Run("UpdatAvailableQuest", questBase)`
```
#### questBase
Above when changing data I used questBase as a placeholder for a specific object that needs to be passed. That object looks as follows:
##### base
```lua
questBase = {
    args = {
        type = "questType (e.g. KillQuest)",
        weight = 10,
        finishInOneRound = "0 (Yes this bool is a string dont @ me xd)",
        pointRewards = 10000,
        premPointRewards = 100,
        xpRewards = 1000
    }
}
```
##### killQuest
```lua
killQuest.args = {
    requiredKills = 10,
    roleToBeKilled = "0",
    roleForKiller = "0",
}
```
##### karmaQuest
```lua
karmaQuest.args = {
    minKarma = 10,
    rounds = 10
}
```
##### surviveQuest
```lua
surviveQuest.args = {
    rounds = 10
}
```
##### walkerQuest
```lua
walkerQuest.args = {
    requiredSteps = 10,
}
```
#### UpdateFinishedQuests
#### sendClaimedRewards
### Fields
The fields a quest type has accessible (e.g. for displaying in a UI)
#### Base
- type - the type of a quest as string value (e.g. "KillQuest").
- completed - wether or not the quest has been completed.
- rewardsClaimed - wether or not the rewards have been claimed.
- uniqueId - the (hopefully) unique Id for each quest. 
- weight - the weighted chance of the quest to be selected.
- player - the player this quest is assigned to.
- rewards - A table with the rewards for completing the quest.
    - A new reward has to be manually added to the GiveRewards method.
    - An example could be adding Points for Pointshop 2 by adding the line `ply:PS2_AddStandardPoints(500)`
#### KillQuest
- requiredKills - The kills that are required to complete the quest.
- killedRole -  The role the victim needs to have to advance the quest.
- killerRole - The role you (the killer) needs to have to advance the quest.
- currentKills - The current amount of kills (progress) you have for this specific quest.
#### WalkerQuest
- requiredSteps - The steps required to finish the quest.
- currentSteps - The already walked steps.
