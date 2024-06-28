local Translations = {
    error = {
        not_online = 'Spelaren är inte online',
        wrong_format = 'Fel format',
        missing_args = 'Alla argument har inte angetts (x, y, z)',
        missing_args2 = 'Alla argument måste fyllas i!',
        no_access = 'Ingen tillgång till detta kommando',
        company_too_poor = 'Din arbetsgivare är pank',
        item_not_exist = 'Föremålet existerar inte',
        too_heavy = 'Inventariet är för fullt',
        location_not_exist = 'Platsen existerar inte',
        duplicate_license = 'Dubblerad Rockstar-licens hittad',
        no_valid_license  = 'Ingen giltig Rockstar-licens hittad',
        not_whitelisted = 'Du är inte vitlistad för denna server',
        server_already_open = 'Servern är redan öppen',
        server_already_closed = 'Servern är redan stängd',
        no_permission = 'Du har inte behörighet för detta..',
        no_waypoint = 'Ingen waypoint inställd.',
        tp_error = 'Fel vid teleportering.',
    },
    success = {
        server_opened = 'Servern har öppnats',
        server_closed = 'Servern har stängts',
        teleported_waypoint = 'Teleporterad till waypoint.',
    },
    info = {
        received_paycheck = 'Du har fått din lön på $%{value}',
        job_info = 'Jobb: %{value} | Grad: %{value2} | Tjänst: %{value3}',
        gang_info = 'Gäng: %{value} | Grad: %{value2}',
        on_duty = 'Du är nu i tjänst!',
        off_duty = 'Du är nu ledig!',
        checking_ban = 'Hej %s. Vi kontrollerar om du är bannad.',
        join_server = 'Välkommen %s till {Server Name}.',
        checking_whitelisted = 'Hej %s. Vi kontrollerar din tillåtelse.',
        exploit_banned = 'Du har blivit bannad för fusk. Kolla vår Discord för mer information: %{discord}',
        exploit_dropped = 'Du har blivit kickad för exploitation',
        pvp_on = 'PVP : PÅ',
        pvp_off = 'PVP : AV',
    },
    command = {
        tp = {
            help = 'TP till spelare eller koordinater (endast admin)',
            params = {
                x = { name = 'id/x', help = 'ID på spelare eller X-position'},
                y = { name = 'y', help = 'Y-position'},
                z = { name = 'z', help = 'Z-position'},
            },
        },
        pvp = {
            help = 'PvP PÅ/AV)',
        },
        tpm = { help = 'TP till markör (endast admin)' },
        noclip = { help = 'No Clip (endast admin)' },
        addpermission = {
            help = 'Ge spelare rättigheter (endast Gud)',
            params = {
                id = { name = 'id', help = 'ID på spelare' },
                permission = { name = 'permission', help = 'Rättighetsnivå' },
            },
        },
        removepermission = {
            help = 'Ta bort spelares rättigheter (endast Gud)',
            params = {
                id = { name = 'id', help = 'ID på spelare' },
                permission = { name = 'permission', help = 'Rättighetsnivå' },
            },
        },
        openserver = { help = 'Öppna servern för alla (endast admin)' },
        closeserver = {
            help = 'Stäng servern för personer utan rättigheter (endast admin)',
            params = {
                reason = { name = 'reason', help = 'Anledning till stängning (frivilligt)' },
            },
        },
        car = {
            help = 'Spawna fordon (endast admin)',
            params = {
                model = { name = 'model', help = 'Modellnamn på fordonet' },
            },
        },
        dv = { help = 'Radera fordon (endast admin)' },
        spawnwagon = { help = 'Spawna en vagn (endast admin)' },
        spawnhorse = { help = 'Spawna en häst (endast admin)' },
        givemoney = {
            help = 'Ge en spelare pengar (endast admin)',
            params = {
                id = { name = 'id', help = 'Spelarens ID' },
                moneytype = { name = 'moneytype', help = 'Typ av pengar (kontanter, bank, blodpengar)' },
                amount = { name = 'amount', help = 'Belopp av pengar' },
            },
        },
        setmoney = {
            help = 'Sätt spelares penningbelopp (endast admin)',
            params = {
                id = { name = 'id', help = 'Spelarens ID' },
                moneytype = { name = 'moneytype', help = 'Typ av pengar (kontanter, bank, blodpengar)' },
                amount = { name = 'amount', help = 'Belopp av pengar' },
            },
        },
        job = { help = 'Kontrollera ditt jobb' },
        setjob = {
            help = 'Sätt en spelares jobb (endast admin)',
            params = {
                id = { name = 'id', help = 'Spelarens ID' },
                job = { name = 'job', help = 'Jobbnamn' },
                grade = { name = 'grade', help = 'Jobbgrad' },
            },
        },
        gang = { help = 'Kontrollera ditt gäng' },
        setgang = {
            help = 'Sätt en spelares gäng (endast admin)',
            params = {
                id = { name = 'id', help = 'Spelarens ID' },
                gang = { name = 'gang', help = 'Gängnamn' },
                grade = { name = 'grade', help = 'Gänggrad' },
            },
        },
        ooc = { help = 'OOC-chattmeddelande' },
        me = {
            help = 'Visa lokalt meddelande',
            params = {
                message = { name = 'message', help = 'Meddelande att skicka' }
            },
        },
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})