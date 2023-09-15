#!mainFile "ANA_PB.opy"

rule "Remove AI bots to leave space for human players":
    @Event eachPlayer
    @Condition getNumberOfPlayers(Team.ALL) - getNumberOfDummyBots(Team.ALL) == getNumberOfSlots(Team.ALL)
    @Condition eventPlayer == nextAIBot

    wait(0, Wait.ABORT_WHEN_FALSE) # let the setup playerJoined rule run first, so IsAIBot is set

    TempAIBotBeingRemoved = nextAIBot
    TempAIBotBeingRemovedName = "{0}".format(TempAIBotBeingRemoved)

    if not TempAIBotBeingRemoved:
        return

    waitUntil(hostPlayer.hasSpawned(), 99999)
    smallMessage(
        hostPlayer,
        "    {0} {1}".format(
            iconString(Icon.BOLT),
            "Echando a {0} para dejar espacio para más jugadores humanos".format(TempAIBotBeingRemovedName)
        )
    )

    removeFromGame(TempAIBotBeingRemoved)
    waitUntil(not entityExists(TempAIBotBeingRemoved), 2)

    # There may be AI Bots in the lobby waiting to join in. Let's remove those too.
    if RULE_CONDITION:
        goto RULE_START
