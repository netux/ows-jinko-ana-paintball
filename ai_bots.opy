#!mainFile "ANA_PB.opy"

rule "Remove AI bots to leave space for human players":
    @Event playerJoined
    @Condition getNumberOfPlayers(Team.ALL) - getNumberOfDummyBots(Team.ALL) == getNumberOfSlots(Team.ALL)

    wait() # let the setup playerJoined rule run first, so IsAIBot is set

    TempAIBotBeingRemoved = nextAIBot

    if not TempAIBotBeingRemoved:
        return

    waitUntil(hostPlayer.hasSpawned(), 99999)
    smallMessage(
        hostPlayer,
        "    {0} {1}".format(
            iconString(Icon.BOLT),
            translate({
                Language.ENGLISH: "Removing {0} to leave space for more human players".format(TempAIBotBeingRemoved),
                Language.SPANISH: "Echando a {0} para dejar espacio para más jugadores humanos".format(TempAIBotBeingRemoved)
            })
        )
    )

    removeFromGame(TempAIBotBeingRemoved)
    waitUntil(not entityExists(TempAIBotBeingRemoved), 2)

    # There may be AI Bots in the lobby waiting to join in. Let's remove those too.
    if RULE_CONDITION:
        goto RULE_START
