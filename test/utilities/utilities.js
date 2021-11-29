let VESTING_SCHEDULE = [
    {
        percent:0.07, // PERCENT TOKENS
        name:"0: Angel",
        vesting: 300, // 10 months *30
        lock:21,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    },
    {
        percent:0.08,
        name:"1: Seed",
        lock:14,
        vesting: 240,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    },
    {
        percent:0.1,
        name:"2: Strategic",
        vesting: 210, //7 Months * 30
        lock:7,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    },
    {
        percent:0.1,
        name:"3: Private",
        vesting: 210, // 7 months * 30
        lock:1,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    },
    {
        percent:0.07,
        name:"4: Team",
        vesting: 540,
        lock: 180,
        wallets:[
            {
                amount:100000,
                address:''
            }
        ]
    },
    {
        percent:0.0225,
        name:"5: Early Advisor",
        vesting: 360,
        lock: 28,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    },
    {
        percent:0.0225,
        name:"6: Future Advisor",
        vesting: 360,
        lock: 28,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    },
    {
        percent:0.015,
        name:"7: GOV Genius Reward",
        vesting: 720,
        lock:3,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    },
    {
        percent:0.1,
        name:"8: Marketting",
        vesting: 720,
        lock: 1,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    },
    {
        percent:0.1,
        name:"9: Ecosystem",
        vesting: 1080,
        lock: 4,
        wallets:[
            {
                amount:100000,
                address:''
            }

        ]
    }

];
module.exports = {
    VESTING_SCHEDULE
};