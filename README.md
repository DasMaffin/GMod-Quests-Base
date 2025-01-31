# GMod Quests

## ConCommands:
### AddQuest
Usage: AddQuest <QuestType> [parameters]
#### Killquest parameters:
[requiredKills] [roleToBeKilled] [roleForKiller]

| Role ID | Role Name  |  
|---------|------------|  
| 0       | Innocent   |  
| 1       | Traitor    |  
| 2       | Detective  |  

e.g. AddQuest KillQuest 5 0 1

## Development
### Hooks
#### QuestsUpdated
Gets called on the client after it got a new update for the local player's active quests. This sends a table of Quests as argument.

### Fields
The fields a quest type has accessible (e.g. for displaying in a UI)
## KillQuest
requiredKills - The kills that are required to complete the quest.
killedRole -  The role the victim needs to have to advance the quest.
killerRole - The role you (the killer) needs to have to advance the quest.
currentKills - The current amount of kills (progress) you have for this specific quest.
rewards - A table with the rewards for completing the quest.
- A new reward has to be manually added to the GiveRewards method.
- An example could be adding Points for Pointshop 2 by adding the line `ply:PS2_AddStandardPoints(salary) `