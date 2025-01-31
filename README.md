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