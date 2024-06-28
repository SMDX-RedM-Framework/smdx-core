SMDXShared = SMDXShared or {}

SMDXShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved

SMDXShared.Jobs = {

    ['unemployed'] = {
        label = 'Civilian',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Freelancer', payment = 5 },
        },
    },
    ['vallaw'] = {
        label = 'Valentine Law Enforcement',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Deputy', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['rholaw'] = {
        label = 'Rhodes Law Enforcement',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Deputy', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['blklaw'] = {
        label = 'Blackwater Law Enforcement',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Deputy', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['strlaw'] = {
        label = 'Strawberry Law Enforcement',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Deputy', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['stdenlaw'] = {
        label = 'Saint Denis Law Enforcement',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 10 },
            ['1'] = { name = 'Deputy', payment = 25 },
            ['2'] = { name = 'Sheriff', isboss = true, payment = 50 },
        },
    },
    ['medic'] = {
        label = 'Medic',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Recruit', payment = 5 },
            ['1'] = { name = 'Trainee', payment = 25 },
            ['2'] = { name = 'Doctor',  payment = 50 },
            ['3'] = { name = 'Surgeon', payment = 75 },
            ['4'] = { name = 'Manager', isboss = true, payment = 100 },
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