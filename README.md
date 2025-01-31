# GMod Quests

## ConCommands:
### AddQuest
Usage: AddQuest <QuestType> [parameters]
#### Killquest parameters:
[requiredKills] [roleToBeKilled] [roleForKiller]

## Development
### Hooks
#### QuestsUpdated
Gets called on the client after it got a new update for the local player's active quests. This sends a table of Quests as argument.