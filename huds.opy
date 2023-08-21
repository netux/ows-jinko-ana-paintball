#!mainFile "ANA_PB.opy"

rule "toggle stats HUD":
    @Event eachPlayer
    @Hero ana
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.DisplayStats = not eventPlayer.DisplayStats


rule "PLAYER HUDs":
    @Event global

    # SCOREBOARD STUFF
    hudSubtext(
        localPlayer.IsPlayer,
        translate(
            "                                                                                                                www.jinko.dev/discord                  use game code  ▶  1DMTZ"emptySpace,
            "                                                                                                                www.jinko.dev/discord                  usa el código  ▶  1DMTZ"emptySpace
        ),
        HudPosition.LEFT,
        0,
        rgb(rainbow(getTotalTimeElapsed() * 85)),
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    hudSubheader(
        localPlayer.IsPlayer,
        translate(
            "always import code 1DMTZ to play the latest version!",
            "siempre importa el código 1DMTZ para jugar en la última versión!"
        ),
        HudPosition.TOP,
        1,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    hudSubtext(localPlayer.IsPlayer, " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                                                                                                                               ", HudPosition.TOP, 5, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.NEVER) # Makes the scoreboard larger and pushes the honor prompt down
    hudSubheader(localPlayer.IsPlayer, "\n "emptySpace, HudPosition.RIGHT, 0, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER) # Aligns the ScoreBoard Wallpapers horizontally
    hudSubtext(localPlayer.IsPlayer, "{}".format(ScoreboardWallpaperIcon(Icon.WARNING) if any([eventPlayer.getScore() == NANO_SCORE for eventPlayer in getAllPlayers()]) else ScoreboardWallpaperAbility(Hero.KIRIKO, Button.ULTIMATE)), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext([localPlayer.IsPlayer and getNumberOfPlayers(Team.ALL) > 1], "\n{}".format(ScoreboardWallpaperIcon(Icon.WARNING) if len([nanoplayer for nanoplayer in getAllPlayers() if nanoplayer.getScore() == NANO_SCORE]) >= 2 and localPlayer.getScore() == NANO_SCORE else ScoreboardWallpaperAbility(Hero.DVA, Button.ULTIMATE)), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

    # MAIN STATS (with icons)
    hudSubtext(
        localPlayer.IsPlayer,
        "{0} {1}{2}".format(
            "▼" if localPlayer.DisplayStats else "▶",
            translate(
                "use [{0}] to toggle stats".format(buttonString(Button.INTERACT)),
                "usa [{0}] para alternar mostrar estadísticas".format(buttonString(Button.INTERACT)),
            ),
            emptySpace
        ),
        HudPosition.LEFT,
        8,
        customGreen if localPlayer.DisplayStats else rgba(63, 191, 116, 50),
        HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    hudText(
        localPlayer.DisplayStats,
        "{}".format(abilityIconString(Hero.SOJOURN, Button.SECONDARY_FIRE)),
        "{}          " emptySpace.format(
            translate(
                "Scoped Accuracy",
                "Precición con la mira"
            )
        ),
        "{0}%".format(localPlayer.ScopedAccuracy),
        HudPosition.LEFT,
        10,
        rgb(rainbow(getTotalTimeElapsed() * 85)) if localPlayer.ScopedAccuracy == BestScopedAccuracyValue and localPlayer.ScopedShots >= 15 and localPlayer.ScopedAccuracy > 0 else customGreen,
        Color.WHITE,
        rgb(rainbow(getTotalTimeElapsed() * 85)) if localPlayer.ScopedAccuracy == BestScopedAccuracyValue and localPlayer.ScopedShots >= 15 and localPlayer.ScopedAccuracy > 0 else customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    hudText(
        localPlayer.DisplayStats, "{}".format(abilityIconString(Hero.ANA, Button.ULTIMATE)),
        "{}          " emptySpace.format(
            translate(
                "Noscope Accuracy",
                "Precición sin la mira"
            )
        ),
        "{0}%".format(localPlayer.NoscopeAccuracy),
        HudPosition.LEFT, 11, rgb(rainbow(getTotalTimeElapsed() * 85)) if localPlayer.NoscopeAccuracy == BestNoscopeAccuracyValue and localPlayer.NoscopeShots >= 15 and localPlayer.NoscopeAccuracy > 0 else customGreen, Color.WHITE, rgb(rainbow(getTotalTimeElapsed() * 85)) if localPlayer.NoscopeAccuracy == BestNoscopeAccuracyValue and localPlayer.NoscopeShots >= 15 and localPlayer.NoscopeAccuracy > 0 else customGreen, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)
    hudText(
        localPlayer.DisplayStats, "{}".format(abilityIconString(Hero.ANA, Button.ABILITY_1)),
        "{}          " emptySpace.format(
            translate(
                "Sleep Dart Accuracy",
                "Precición con el Dardo Tranquilizante"
            )
        ),
        "{0}%".format(localPlayer.SleepAccuracy),
        HudPosition.LEFT,
        12,
        rgb(rainbow(getTotalTimeElapsed() * 85)) if localPlayer.SleepAccuracy == BestSleepAccuracyValue and localPlayer.SleepShots >= 10 and localPlayer.SleepAccuracy > 0 else customGreen,
        Color.WHITE,
        rgb(rainbow(getTotalTimeElapsed() * 85)) if localPlayer.SleepAccuracy == BestSleepAccuracyValue and localPlayer.SleepShots >= 10 and localPlayer.SleepAccuracy > 0 else customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    hudText(
        [localPlayer.DisplayStats and LongestShotValue >= 40], "{}".format(abilityIconString(Hero.MCCREE, Button.ULTIMATE)),
        "{}          " emptySpace.format(
            translate(
                "Longest longshot",
                "Disparo más largo",
            )
        ),
        "{0}: {1}m".format(LongestShotPlayer, LongestShotValue),
        HudPosition.LEFT,
        13,
        rgb(rainbow(getTotalTimeElapsed() * 85)) if localPlayer.LongestLongshot == LongestShotValue else customGreen,
        Color.WHITE,
        rgb(rainbow(getTotalTimeElapsed() * 85)) if localPlayer.LongestLongshot == LongestShotValue else customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    hudText(
        [localPlayer.DisplayStats and BestKillstreakValue >= ONFIRE_STREAK], "{}".format(abilityIconString(Hero.REAPER, Button.ULTIMATE)),
        "{}          " emptySpace.format(
            translate(
                "Longest killstreak",
                "Racha de asesinatos más larga"
            )
        ),
        "{0} - {1}k".format(BestKillstreakPlayer, BestKillstreakValue),
        HudPosition.LEFT,
        14,
        rgb(rainbow(getTotalTimeElapsed() * 85)) if BestKillstreakPlayer == localPlayer else customGreen,
        Color.WHITE,
        rgb(rainbow(getTotalTimeElapsed() * 85)) if BestKillstreakPlayer == localPlayer else customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )


    # SECONDARY STATS

    # Current killstreak
    hudSubheader(
        [localPlayer.DisplayStats],
        "{0}: {1}{2}          ".format(
            translate(
                "Current killstreak",
                "Racha de asesinatos actual"
            ),
            localPlayer.KillStreak,
            emptySpace
        ),
        HudPosition.LEFT,
        21,
        customGreen if localPlayer.KillStreak < ONFIRE_STREAK
            else Color.ORANGE if localPlayer.KillStreak >= ONFIRE_STREAK and localPlayer.KillStreak < RAMPAGE_STREAK
            else Color.YELLOW if localPlayer.KillStreak >= RAMPAGE_STREAK and localPlayer.KillStreak < NUCLEAR_STREAK
            else rgb(rainbow(getTotalTimeElapsed() * 85)),
        HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )

    # K/D Ratio
    hudSubheader(
        [localPlayer.DisplayStats and localPlayer.Deaths > 0 and localPlayer.getScore() > 0],
        "{0}: {1}{2}          ".format(
            translate(
                "K/D ratio",
                "Relación K/D"
            ),
            KD(localPlayer),
            emptySpace
        ),
        HudPosition.LEFT,
        22,
        customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,
        SpecVisibility.NEVER
    )

    # Shots fired
    hudSubheader(
        [localPlayer.DisplayStats and (localPlayer.ScopedShots + localPlayer.NoscopeShots) > 100],
        "{0}: {1}{2}          ".format(
            translate(
                "Rifle shots",
                "Disparos con el rifle"
            ),
            (localPlayer.ScopedShots + localPlayer.NoscopeShots),
            emptySpace
        ),
        HudPosition.LEFT,
        23,
        customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,
        SpecVisibility.NEVER
    )

    # Jumps
    hudSubheader(
        [localPlayer.DisplayStats and localPlayer.Jumps > 200],
        "{0}: {1}{2}          ".format(
            translate(
                "Jumps",
                "Saltos"
            ),
            localPlayer.Jumps,
            emptySpace
        ),
        HudPosition.LEFT,
        24,
        customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,
        SpecVisibility.NEVER
    )

    # Kills stolen
    hudSubheader(
        [localPlayer.DisplayStats and localPlayer.StolenKills > 0],
        "{0}: {1}{2}          ".format(
            translate(
                "Kills stolen",
                "Asesinatos robados"
            ),
            localPlayer.StolenKills,
            emptySpace
        ),
        HudPosition.LEFT,
        25,
        customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,
        SpecVisibility.NEVER
    )

    # Players demoted
    hudSubheader(
        [localPlayer.DisplayStats and localPlayer.DemotedPlayers > 0],
        "{0}: {1}{2}          ".format(
            translate(
                "Players demoted",
                "Jugadores degradados"
            ),
            localPlayer.DemotedPlayers,
            emptySpace
        ),
        HudPosition.LEFT,
        26,
        customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,
        SpecVisibility.NEVER
    )

    # Perfect Quickscopes
    hudSubheader(
        [localPlayer.DisplayStats and localPlayer.PerfectQuickscopes > 0],
        "{0}: {1}{2}          ".format(
            translate(
                "Perfect Quickscopes",
                "Miras-fantasma perfectas"
            ),
            localPlayer.PerfectQuickscopes,
            emptySpace
        ),
        HudPosition.LEFT,
        27,
        customGreen,
        HudReeval.VISIBILITY_SORT_ORDER_AND_STRING,
        SpecVisibility.NEVER
    )


    progressBarHud(
        [localPlayer.IsPlayer and localPlayer.HonorBar > 0 and localPlayer.HonorBar < 100],
        localPlayer.HonorBar,
        translate(
            "press [{0}] to honor {1}".format(buttonString(Button.ABILITY_2), localPlayer.HonorTarget),
            "presiona [{0}] para honrar a {1}".format(buttonString(Button.ABILITY_2), localPlayer.HonorTarget),
        ),
        HudPosition.TOP,
        10,
        rgb(44,133,81),
        rgb(44,133,81),
        ProgressHudReeval.VISIBILITY_AND_VALUES,
        SpecVisibility.NEVER
    )


rule "SPECTATOR & POTG HUDs":
    @Event global

    #hudText([not localPlayer.IsPlayer and BestScopedAccuracyValue > 0], "{}".format(abilityIconString(Hero.SOJOURN, Button.SECONDARY_FIRE)), "Best Scoped Accuracy          " emptySpace, "{0}: {1}%".format(BestScopedAccuracyPlayer, BestScopedAccuracyValue), HudPosition.LEFT, 10, customGreen, Color.WHITE, customGreen, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
    #hudText([not localPlayer.IsPlayer and BestNoscopeAccuracyValue > 0], "{}".format(abilityIconString(Hero.ANA, Button.ULTIMATE)), "Best Noscope Accuracy          " emptySpace, "{0}: {1}%".format(BestNoscopeAccuracyPlayer, BestNoscopeAccuracyValue), HudPosition.LEFT, 11, customGreen, Color.WHITE, customGreen, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
    #hudText([not localPlayer.IsPlayer and BestSleepAccuracyValue > 0], "{}".format(abilityIconString(Hero.ANA, Button.ABILITY_1)), "Best Sleep Dart Accuracy          " emptySpace, "{0}: {1}%".format(BestSleepAccuracyPlayer, BestSleepAccuracyValue), HudPosition.LEFT, 12, customGreen, Color.WHITE, customGreen, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
    #hudText([not localPlayer.IsPlayer and BestKillstreakValue > 0], "{}".format(abilityIconString(Hero.REAPER, Button.ULTIMATE)), "Longest killstreak          " emptySpace, "{0} - {1}k".format(BestKillstreakPlayer, BestKillstreakValue), HudPosition.LEFT, 13, customGreen, Color.WHITE, customGreen, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
    #hudText([not localPlayer.IsPlayer and LongestShotValue >= 40], "{}".format(abilityIconString(Hero.MCCREE, Button.ULTIMATE)), "Longest longshot          " emptySpace, "{0}: {1}m".format(LongestShotPlayer, LongestShotValue), HudPosition.LEFT, 14, customGreen, Color.WHITE, customGreen, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
    hudSubtext(
        [not localPlayer.IsPlayer],
        translate(
            "\n\n\nana paintball by jinko - code 1DMTZ\n             www.jinko.dev/discord",
            "\n\n\nana paintball por jinko - codigo 1DMTZ\n            www.jinko.dev/discord"
        ),
        HudPosition.TOP,
        100,
        rgb(rainbow(getTotalTimeElapsed() * 85)),
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
