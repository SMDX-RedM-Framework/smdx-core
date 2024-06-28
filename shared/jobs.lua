SMDXShared = SMDXShared or {}

SMDXShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved

SMDXShared.Jobs = {

    ['unemployed'] = {
        label = 'Arbetslös',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Frilansare', payment = 5 },
        },
    },
    ['vallaw'] = {
        label = 'Valentine | Sheriff',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Rekryt', payment = 10 },
            ['1'] = { name = 'Tjänsteman', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['rholaw'] = {
        label = 'Rhodes | Sheriff',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Rekryt', payment = 10 },
            ['1'] = { name = 'Tjänsteman', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['blklaw'] = {
        label = 'Blackwater | Sheriff',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Rekryt', payment = 10 },
            ['1'] = { name = 'Tjänsteman', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['strlaw'] = {
        label = 'Strawberry | Sheriff',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Rekryt', payment = 10 },
            ['1'] = { name = 'Tjänsteman', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['stdenlaw'] = {
        label = 'Saint Denis | Sheriff',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Rekryt', payment = 10 },
            ['1'] = { name = 'Tjänsteman', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['medic'] = {
        label = 'Doktor',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Rekryt', payment = 5 },
            ['1'] = { name = 'Arbetare', payment = 25 },
            ['2'] = { name = 'Doktor',  payment = 50 },
            ['3'] = { name = 'Kirurg', payment = 75 },
            ['4'] = { name = 'Chef', isboss = true, payment = 100 },
        },
    },
    ['valweaponsmith'] = {
        label = 'Valentine - Vapensmed',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Arbetare', payment = 15 },
            ['1'] = { name = 'Chef', isboss = true, payment = 50 },
        },
    },
    ['rhoweaponsmith'] = {
        label = 'Rhodes - Vapensmed',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Arbetare', payment = 15 },
            ['1'] = { name = 'Chef', isboss = true, payment = 50 },
        },
    },
    ['stdweaponsmith'] = {
        label = 'Saint Denis - Vapensmed',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Arbetare', payment = 15 },
            ['1'] = { name = 'Chef', isboss = true, payment = 50 },
        },
    },
    ['tumweaponsmith'] = {
        label = 'Tumbleweed - Vapensmed',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Arbetare', payment = 15 },
            ['1'] = { name = 'Chef', isboss = true, payment = 50 },
        },
    },
    ['annweaponsmith'] = {
        label = 'Annesburg - Vapensmed',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Arbetare', payment = 15 },
            ['1'] = { name = 'Chef', isboss = true, payment = 50 },
        },
    },

}
