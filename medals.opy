#!mainFile "ANA_PB.opy"

rule "Send honor medal":
    @SuppressWarnings w_ow2_rule_condition_chase
    @Event eachPlayer
    @Hero ana
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
    @Condition eventPlayer.HonorTarget != null
    @Condition eventPlayer.HonorBar != 0

    eventPlayer.HonorTarget.HonorQueue.append(eventPlayer)
    eventPlayer.HonorTarget.MedalQueue.append(Medal.HONOR)
    eventPlayer.HonorBar = 0

    eventPlayer.MedalQueue = [Medal.SYSTEM_MESSAGE].concat(eventPlayer.MedalQueue)
    smallMessage(eventPlayer, "    {0}  {1}".format(
        iconString(Icon.HAPPY),
        "honores mandados a {0}!".format(eventPlayer.HonorTarget)
    ))
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 200)


rule "sleep hit sys msg":
    @Event playerDealtDamage
    @Hero ana
    @Condition eventAbility == Button.ABILITY_1
    @Condition not eventWasEnvironment

    attacker.MedalQueue = [Medal.SYSTEM_MESSAGE].concat(attacker.MedalQueue)


rule "Jumps":
    @Event eachPlayer
    @Hero ana
    @Condition eventPlayer.isJumping()

    eventPlayer.Jumps +=1
    if eventPlayer.Jumps == 200:
        eventPlayer.MedalQueue.append(Medal.JOLLY_JUMPER)


rule "perfect quickscopes":
    @Event eachPlayer
    @Hero ana
    @Condition eventPlayer.isFiringSecondaryFire()

    eventPlayer.ElimsBeforeQS = eventPlayer.KillStreak
    wait(0.24) # Scope-in time
    waitUntil(eventPlayer.isFiringPrimaryFire(), 0.016) # 1 frame time window
    if eventPlayer.isFiringPrimaryFire():
        wait(0.16) # Scope-out time
        if not eventPlayer.isFiringSecondaryFire() and eventPlayer.KillStreak == eventPlayer.ElimsBeforeQS + 1:
            eventPlayer.MedalQueue.append(Medal.PERFECT_QS)
            eventPlayer.PerfectQuickscopes += 1
            playEffect(eventPlayer, DynamicEffect.WRECKING_BALL_MINEFIELD_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.getPosition()+eventPlayer.getThrottle()*eventPlayer.getSpeed(), 200)


rule "quadfeed kills":
    @Event playerEarnedElimination
    @Hero ana

    attacker.QuadFeedTimes = [t for t in attacker.QuadFeedTimes if getTotalTimeElapsed() - t <= 7.5]
    attacker.QuadFeedTimes.append(getTotalTimeElapsed())
    getAllPlayers().exclude(attacker).QuadFeedTimes = []
    if len(attacker.QuadFeedTimes) >= 4:
        attacker.MedalQueue.append(Medal.QUADFEED)
        attacker.QuadFeedTimes = []
        playEffect(eventPlayer, DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.getPosition()+eventPlayer.getThrottle()*eventPlayer.getSpeed(), 200)
        playEffect(eventPlayer, DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.getPosition()+eventPlayer.getThrottle()*eventPlayer.getSpeed(), 200)


rule "Killstreak effects & announcements":
    @Event playerEarnedElimination
    @Hero ana
    @Condition not eventAbility == Button.ABILITY_1

    if attacker.KillStreak >= ONFIRE_STREAK and attacker.isAlive() and not attacker.IsOnFire:
        attacker.IsOnFire = true
        attacker.MedalQueue.append(Medal.ON_FIRE)
            for i in range(getNumberOfPlayers(Team.ALL) - 1):
            getAllPlayers().exclude(attacker)[i].MedalQueue = [Medal.SYSTEM_MESSAGE].concat(getAllPlayers().exclude(attacker)[i].MedalQueue)
        attacker.setStatusEffect(null, Status.BURNING, 9999)
        attacker.startForcingOutlineFor(getAllPlayers(), true, Color.ORANGE, OutlineVisibility.DEFAULT)
        playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION_SOUND, Color.TEAM_1, attacker, 70 if eventPlayer == localPlayer else 200)
        smallMessage(
            getAllPlayers().exclude(attacker),
            "    {0}  {1}  {0}".format(
                abilityIconString(Hero.TORBJORN, Button.ULTIMATE),
                "{0} está en llamas!".format(attacker)
            )
        )
    elif attacker.KillStreak >= RAMPAGE_STREAK and attacker.isAlive() and not attacker.IsOnRampage:
        attacker.IsOnRampage = true
        attacker.MedalQueue.append(Medal.RAMPAGE)
        attacker.RampageSFX = true
        attacker.startForcingOutlineFor(getAllPlayers(), true, Color.YELLOW, OutlineVisibility.DEFAULT)
        bigMessage(
            getAllPlayers().exclude(attacker),
            "{0}  {1}  {0}".format(
                abilityIconString(Hero.REAPER, Button.ULTIMATE),
                "{0} está arrasando!".format(attacker)
            )
        )
        attacker.RampageVFX = true
        wait(1)
        attacker.RampageVFX = false
    elif attacker.KillStreak >= NUCLEAR_STREAK and not attacker.IsNuclear:
        attacker.IsNuclear = true
        attacker.MedalQueue.append(Medal.NUCLEAR)
        playEffect(getAllPlayers(), DynamicEffect.ANA_BIOTIC_GRENAGE_NO_HEALING_SOUND, Color.WHITE, attacker, 200)
        createInWorldText(
            attacker,
            "                {0} {1} {0}\n{2}".format(
                iconString(Icon.RADIOACTIVE),
                "Racha de asesinatos nuclear!",
                "Presiona [{0}] para pedír una Nano-bomba nuclear".format(buttonString(Button.ULTIMATE))
            ),
            updateEveryTick(localPlayer.getEyePosition() + (100 * (0 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + ((0.69 - 0.2) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))),
            9,
            Clip.NONE,
            WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
            rgb(rainbow(getTotalTimeElapsed() * 500)),
            SpecVisibility.DEFAULT
        )
        bigMessage(
            getAllPlayers().exclude(attacker),
            "{0}  {1}  {0}".format(
                iconString(Icon.RADIOACTIVE),
                "{0} obtuvo una racha de asesinatos Nuclear!".format(attacker)
            )
        )


rule "Killstreak shutdown announcements":
    @Event playerDealtFinalBlow
    @Hero ana
    @Condition not eventWasEnvironment
    @Condition victim.SleepLock < 1 # ?
    @Condition victim.KillStreak >= ONFIRE_STREAK

    attacker.ShutdownVictim = victim

    if victim.KillStreak < RAMPAGE_STREAK:
        attacker.MedalQueue.append(Medal.ON_FIRE_SHUTDOWN)
        attacker.communicate(Comms.GOODBYE)
        smallMessage(
            getAllPlayers().exclude([victim, attacker]),
            "    {0}  {1}".format(
                abilityIconString(Hero.TRACER, Button.ABILITY_2),
                "Se ha terminado la racha de {1} asesinatos de {0}".format(victim, victim.KillStreak)
            )
        )

    elif victim.KillStreak < NUCLEAR_STREAK:
        attacker.MedalQueue.append(Medal.RAMPAGE_SHUTDOWN)
        smallMessage(
            getAllPlayers().exclude([victim, attacker]),
            "    {0}  {1}".format(
                abilityIconString(Hero.TRACER, Button.ABILITY_2),
                "Se ha terminado la arrasada de {1} asesinatos de {0}".format(victim, victim.KillStreak)
            )
        )
        attacker.communicate(Comms.GOODBYE)

    for i in range(getNumberOfPlayers(Team.ALL) - 1):
        getAllPlayers().exclude(attacker)[i].MedalQueue = [Medal.SYSTEM_MESSAGE].concat(getAllPlayers().exclude(attacker)[i].MedalQueue)
    playEffect(getAllPlayers(), DynamicEffect.SOMBRA_TRANSLOCATOR_DISAPPEAR_SOUND, Color.WHITE, victim.getPosition(), 200)
    wait(2)


rule "environment kills":
    @Event playerDied
    @Hero ana
    @Condition eventWasEnvironment
    @Condition eventAbility == Button.ABILITY_1

    attacker.MedalQueue.append(Medal.ENV_KILL)


rule "Environement death":
    @Event playerDied
    @Hero ana
    @Condition eventWasEnvironment

    # wait(CUSTOM_RESPAWN_TIME)
    eventPlayer.MedalQueue = [Medal.SYSTEM_MESSAGE].concat(eventPlayer.MedalQueue)
    smallMessage(eventPlayer, random.choice([
        "    {0}  {1}".format(
            heroIcon(random.choice([Hero.ECHO, Hero.MERCY])),
            "sin alas?"
        ),
        "    {0}  {1}".format(
            heroIcon(random.choice([Hero.PHARAH, Hero.WINSTON])),
            "sin propulsor aéreo?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.SOMBRA),
            "sin translocalizador?"
        ),
        "    {0}  {1}".format(
            heroIcon(random.choice([Hero.HAMMOND, Hero.WIDOWMAKER])),
            "sin grapa?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.KIRIKO),
            "sin teletransporaciones?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.TRACER),
            "sin regresiones?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.LUCIO),
            "sin caminamuros?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.DOOMFIST),
            "sin embates sísmicos?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.DVA),
            "sin armaduras robóticas?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.GENJI),
            "sin saltos dobles?"
        ),
        "    {0}  {1}".format(
            heroIcon(random.choice([Hero.GENJI, Hero.HANZO, Hero.KIRIKO])),
            "sin trepamuros?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.LIFEWEAVER),
            "sin agarre salvavidas?"
        ),
        "    {0}  {1}".format(
            heroIcon(Hero.SOJOURN),
            "sin piernas propulsoras?"
        ),
    ]))


rule "Longshot":
    @Event playerTookDamage
    @Hero ana
    #@Condition attacker.isAlive()
    @Condition distance(attacker, victim) >= LONGSHOT_DISTANCE
    @Condition not eventWasEnvironment
    @Condition attacker.getScore() != NANO_SCORE

    wait() # try removing
    attacker.MedalQueue.append(Medal.LONGSHOT)
    attacker.LongshotCount += 1
    attacker.OofDistance = distance(attacker, victim)
    createInWorldText(
        getAllPlayers(),
        random.choice(["uff", "auch", "caray", "ay", "clonc"]),
        victim,
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rgb(rainbow(getTotalTimeElapsed() * 150)),
        SpecVisibility.NEVER
    )
    victim.OofText = getLastCreatedText()
    if attacker.OofDistance > attacker.LongestLongshot:
        attacker.LongestLongshot = distance(attacker, victim)
    wait() # try removing
    if attacker.LongestLongshot > LongestShotValue:
        LongestShotPlayer = attacker
        LongestShotValue = attacker.LongestLongshot
    if attacker.LongshotCount >= 10:
        attacker.MedalQueue.append(Medal.DEADEYE)
    if eventAbility == Button.ABILITY_1:
        attacker.MedalQueue.append(Medal.SLEEP_SNIPER)
    wait(0.5)
    destroyInWorldText(victim.OofText)


rule "Sandman":
    @Event playerDealtDamage
    @Hero ana
    @Condition eventAbility == Button.ABILITY_1
    @Condition not eventWasEnvironment
    @Condition attacker.isAlive()
    @Condition not victim.hasStatusEffect(Status.ASLEEP)

    attacker.Sandman += 1
    if attacker.Sandman == 3:
        attacker.MedalQueue.append(Medal.SANDMAN)
        attacker.Sandman = 0


rule "MEDALS":
    @Event eachPlayer
    @Hero ana
    @Condition len(eventPlayer.MedalQueue) > 0
    @Condition not MatchEnded

    wait()
    eventPlayer.DisplayMedal = eventPlayer.MedalQueue[0]
    if eventPlayer.DisplayMedal != Medal.SYSTEM_MESSAGE:
        smallMessage(eventPlayer, {
            Medal.HONOR:              "    {0}  {1}".format(
                heroIcon(Hero.ANA),
                "{0} dijo: '{1}'".format(eventPlayer.HonorQueue[0], random.choice(["Muy buena!", "Fuaaaaa", "Caray!", "Wow", "Uff", "Impecable", "{0}{0}{0}".format(iconString(Icon.FIRE))]))
            ),
            Medal.EXECUTED:           "    {0}{1}  {2}".format(
                abilityIconString(Hero.ANA, Button.MELEE),
                iconString(Icon.RECYCLE),
                "Ejecución! Munición restaurada"
            ),
            Medal.PERFECT_QS:         "    {0}  {1}".format(
                abilityIconString(Hero.KIRIKO, Button.JUMP),
                "Mira fantasma"
            ),
            Medal.DEMOTION:           "    {0}  {1}".format(
                abilityIconString(Hero.HAMMOND, Button.CROUCH),
                "Degradación! {0} perdió un punto".format(eventPlayer.DemotionVictim)
            ),
            Medal.STOLEN_KILL:        "    {0}  {1}".format(
                abilityIconString(Hero.ROADHOG, Button.ABILITY_1),
                "Te robaste la presa de {0}".format(eventPlayer.StolenFrom)
            ),
            Medal.COMEBACK:           "    {0}  {1}".format(
                abilityIconString(Hero.MERCY, Button.ULTIMATE),
                "Remontada"
            ),
            Medal.FIRST_BLOOD:        "    {0}  {1}".format(
                abilityIconString(Hero.BRIGITTE, Button.ULTIMATE),
                "Primera sangre"
            ),
            Medal.FIRST_SLEEP:        "    {0}  {1}".format(
                abilityIconString(Hero.BRIGITTE, Button.ULTIMATE),
                "Primera puesta a dormir"
            ),
            Medal.LONGSHOT:           "    {0}  {1}".format(
                heroIcon(Hero.WIDOWMAKER),
                "A larga distancia! {0}m".format(OofString(eventPlayer.OofDistance))
            ),
            Medal.NANOPUNCH:          "    {0}  {1}".format(
                abilityIconString(Hero.RAMATTRA, Button.ABILITY_1),
                "Nanopiña"
            ),
            Medal.ENV_KILL:           "    {0}  {1}".format(
                abilityIconString(Hero.SIGMA, Button.ULTIMATE),
                "Asesinato del ambiente"
            ),
            Medal.ON_FIRE:            "    {0}  {1}".format(
                abilityIconString(Hero.TORBJORN, Button.ULTIMATE),
                "En llamas"
            ),
            Medal.ON_FIRE_SHUTDOWN:   "    {0}  {1}".format(
                abilityIconString(Hero.TRACER, Button.ABILITY_2),
                "Terminaste la racha de {1} asesinatos de {0}".format(eventPlayer.ShutdownVictim, eventPlayer.ShutdownVictim.KillStreakBeforeDeath)
            ),
            Medal.RAMPAGE:            "    {0}  {1}".format(
                abilityIconString(Hero.REAPER, Button.ULTIMATE),
                random.choice(["Estás arrasando!", "Arrasada!"])
            ),
            Medal.RAMPAGE_SHUTDOWN:   "    {0}  {1}".format(
                abilityIconString(Hero.TRACER, Button.ABILITY_2),
                "Terminaste la arrasada de {1} asesinatos de {0}".format(eventPlayer.ShutdownVictim, eventPlayer.ShutdownVictim.KillStreakBeforeDeath)
            ),
            Medal.NUCLEAR:            "    {0}  {1}".format(
                iconString(Icon.RADIOACTIVE),
                "Nuclear"
            ),
            Medal.COUNTERMEASURE:     "    {0}{1}  {2}".format(
                iconString(Icon.NO),
                iconString(Icon.RADIOACTIVE),
                "Contramedida"
            ),
            Medal.CATASTROPHE:        "    {0}  {1}".format(
                abilityIconString(Hero.BASTION, Button.ULTIMATE),
                "Catastrofe"
            ),
            Medal.BUZZKILL:           "    {0}  {1}".format(
                abilityIconString(Hero.DOOMFIST, Button.ABILITY_1),
                "Aguafiestas"
            ),
            Medal.SHOWSTOPPER:        "    {0}  {1}".format(
                iconString(Icon.STOP),
                "Se terminó el show"
            ),
            Medal.QUADFEED:           "    {0}  {1}".format(
                abilityIconString(Hero.JUNKER_QUEEN, Button.ULTIMATE),
                "Llenando el historial"
            ),
            Medal.JOLLY_JUMPER:       "    {0}  {1}".format(
                abilityIconString(Hero.BAPTISTE, Button.CROUCH),
                "Saltador felíz"
            ),
            Medal.COLLATERAL_KILLS:   "    {0}  {1}".format(
                abilityIconString(Hero.ZARYA, Button.ABILITY_2),
                "Asesinatos colaterales"
            ),
            Medal.MUTUAL_SLEEP:       "    {0}  {1}".format(
                abilityIconString(Hero.MERCY, Button.ABILITY_2),
                "Dormida mutua, despertandose..."
            ),
            Medal.LAST_BULLET:        "    {0}  {1}".format(
                iconString(Icon.CLUB),
                "Tiro decisivo"
            ),
            Medal.DREAMCATCHER:       "    {0}  {1}".format(
                abilityIconString(Hero.RAMATTRA, Button.ABILITY_2),
                "Atrapasueños"
            ),
            Medal.NO_SCOPE_NEEDED:    "    {0}  {1}".format(
                abilityIconString(Hero.SOJOURN, Button.ULTIMATE),
                "Sin mira"
            ),
            Medal.DEADEYE:            "    {0}  {1}".format(
                abilityIconString(Hero.MCCREE, Button.ULTIMATE),
                "Ojo muerto"
            ),
            Medal.SLEEP_SNIPER:       "    {0}  {1}".format(
                abilityIconString(Hero.ORISA, Button.SECONDARY_FIRE),
                "Francotirador de dardos"
            ),
            Medal.SANDMAN:            "    {0}{1}  {2}".format(
                abilityIconString(Hero.ANA, Button.ABILITY_1),
                abilityIconString(Hero.ECHO, Button.ULTIMATE),
                "Sr. Arena"
            ),
            Medal.PUNCH_DRUNK:        "    {0}{1}  {2}".format(
                abilityIconString(Hero.ANA, Button.MELEE),
                iconString(Icon.DIZZY),
                "Lleno de puños"
            ),
            Medal.FROM_THE_GRAVE:     "    {0}  {1}".format(
                abilityIconString(Hero.REAPER, Button.ULTIMATE),
                "Desde la tumba"
            ),

            }[eventPlayer.DisplayMedal])
        if DEBUG_MODE:
            eventPlayer.MedalCount += 1
        playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 200)
    elif DEBUG_MODE:
        eventPlayer.SysMsgCount += 1
    del eventPlayer.MedalQueue[0]
    wait(0.5)
    if eventPlayer.DisplayMedal == Medal.HONOR:
        del eventPlayer.HonorQueue[0]
    if RULE_CONDITION:
        goto RULE_START
