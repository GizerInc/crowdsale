require_relative "GZR_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################

@owner_account = @a[18]
@wallet_account = @a[19]
@redemption_account = @a[20]

###############################################################################

@sl.h1 'Preliminary actions'

##

@sot.txt 'Initiate ownership transfer'

@sot.own :transfer_ownership, @a[18]
@sot.add :accept_ownership, @k[18]

@sot.exp :owner,     @sot.strip0x(@a[18])
@sot.exp :new_owner, @sot.strip0x(@a[18])

@sot.do

###

@sot.change_owner_key @k[18]

###

@sot.txt 'Set wallets'

@sot.own :set_wallet,            @wallet_account
@sot.own :set_redemption_wallet, @redemption_account

@sot.exp :wallet,            @sot.strip0x(@wallet_account)
@sot.exp :redemption_wallet, @sot.strip0x(@redemption_account)

@sot.do

 

###############################################################################

@sl.h1 'Before presale'

###

@sot.txt 'Private sale contributions' # token rate 1150 per eth

@sot.own :private_sale_contribution, @a[1],   10 * @E18 # ok
@sot.own :private_sale_contribution, @a[2],  100 * @E18 # ok
@sot.own :private_sale_contribution, @a[11], 500 * @E18 # ok
@sot.own :private_sale_contribution, @a[12], 400 * @E18 # over the limit

@sot.exp :balance_of, @a[1],   11500 * @E6,  11500 * @E6
@sot.exp :balance_of, @a[2],  115000 * @E6, 115000 * @E6
@sot.exp :balance_of, @a[11], 575000 * @E6, 575000 * @E6
@sot.exp :balance_of, @a[12],      0 * @E6,      0 * @E6

@sot.do

###

@sot.txt 'Early contribution fails'

@sot.snd @k[1], 10

@sot.exp :balance_of,          @a[1], nil, 0
@sot.exp :balances_private,    @a[1], nil, 0
@sot.exp :balances_crowd,      @a[1], nil, 0
@sot.exp :balance_eth_private, @a[1], nil, 0
@sot.exp :balance_eth_crowd,   @a[1], nil, 0

@sot.do

###

@sot.txt 'Attempt to freeze (fails) and some transfers'

@sot.own :freeze_tokens
@sot.exp :tokens_frozen, false

@sot.add :transfer, @k[1], @redemption_account, 1 * @E6
@sot.add :transfer, @k[1], @owner_account,      1 * @E6
@sot.add :transfer, @k[1], @a[2],               1 * @E6

@sot.exp :balance_of,               @a[1], nil, -2 * @E6
@sot.exp :balance_of, @redemption_account, nil,  1 * @E6
@sot.exp :balance_of,      @owner_account, nil,  1 * @E6
@sot.exp :balance_of,               @a[2], nil,  0

@sot.do


###############################################################################

@sl.h1 'Presale'

epoch = @sot.var :date_presale_start
jump_to(epoch, 'presale')

###

@sot.txt 'Some presale contributions'

@sot.snd @k[1], 0.05 # too little
@sot.snd @k[1], 1001 # too much
@sot.snd @k[1], 200
@sot.snd @k[2], 300
@sot.snd @k[3], 400
@sot.snd @k[4], 600
@sot.snd @k[5], 1000
@sot.snd @k[6], 1 # above the limit

@sot.exp :balance_of, @a[1], nil,  200 * 1150 * @E6
@sot.exp :balance_of, @a[2], nil,  300 * 1150 * @E6
@sot.exp :balance_of, @a[3], nil,  400 * 1100 * @E6
@sot.exp :balance_of, @a[4], nil,  600 * 1100 * @E6
@sot.exp :balance_of, @a[5], nil, 1000 * 1075 * @E6
@sot.exp :balance_of, @a[6], 0, 0
@sot.exp :get_balance, @contract_address, 0, 0
@sot.exp :presale_contributor_count, 5, 5

@sot.do

###

@sot.txt 'More private sale contributions'

@sot.own :private_sale_contribution, @a[12], (0.01 * @E18).to_i # too little
@sot.own :private_sale_contribution, @a[12],  100 * @E18 # ok
@sot.own :private_sale_contribution, @a[12],  300 * @E18 # over the limit

@sot.exp :balance_of, @a[12],  115000 * @E6, 115000 * @E6
@sot.exp :tokens_issued_private,  nil, 115000 * @E6
@sot.exp :ether_received_private, nil,    100 * @E18

@sot.do

###

@sot.txt 'Attempt to freeze (fails) and some transfers'

@sot.own :freeze_tokens
@sot.exp :tokens_frozen, false

@sot.add :transfer, @k[1], @redemption_account, 1 * @E6
@sot.add :transfer, @k[1], @owner_account,      1 * @E6
@sot.add :transfer, @k[1], @a[2],               1 * @E6

@sot.exp :balance_of,               @a[1], nil, -2 * @E6
@sot.exp :balance_of, @redemption_account, nil,  1 * @E6
@sot.exp :balance_of,      @owner_account, nil,  1 * @E6
@sot.exp :balance_of,               @a[2], nil,  0

@sot.do

###

@sot.txt 'Burn owner tokens'

@sot.own :burn_owner_tokens
@sot.exp :balance_of, @owner_account, nil,  -2 * @E6

@sot.do

###############################################################################

@sl.h1 'After presale'

epoch = @sot.var :date_presale_end
jump_to(epoch, 'after presale')

###

@sot.txt 'No more contributions accepted after presale end'

@sot.snd @k[1], 1
@sot.own :private_sale_contribution, @a[1], 1 * @E18

@sot.exp :balance_of,          @a[1], nil, 0
@sot.exp :balances_private,    @a[1], nil, 0
@sot.exp :balances_crowd,      @a[1], nil, 0
@sot.exp :balance_eth_private, @a[1], nil, 0
@sot.exp :balance_eth_crowd,   @a[1], nil, 0

@sot.do

###

@sot.txt 'Approve and transferFrom (only to redemption wallet)'

@sot.add :approve, @k[1], @a[15], 10 * @E6
@sot.add :transfer_from, @k[15], @a[1], @redemption_account, 5 * @E6
@sot.add :transfer_from, @k[15], @a[1], @redemption_account, 6 * @E6 # above limit
@sot.add :transfer_from, @k[15], @a[1], @owner_account,      3 * @E6 # fail
@sot.add :transfer_from, @k[15], @a[1], @a[2],               3 * @E6 # fail

@sot.exp :balance_of,               @a[1], nil, -5 * @E6
@sot.exp :balance_of, @redemption_account, nil,  5 * @E6
@sot.exp :balance_of,      @owner_account, nil,  0
@sot.exp :balance_of,               @a[2], nil,  0

@sot.do

###

@sot.txt 'Freeze transfers to redemption account'

@sot.own :freeze_tokens
@sot.exp :tokens_frozen, true

@sot.do

###

@sot.txt 'Transfer to owner still works'

@sot.add :approve, @k[1], @a[15], 0
@sot.add :approve, @k[1], @a[15], 10 * @E6
@sot.add :transfer_from, @k[15], @a[1], @redemption_account, 3 * @E6 # fail

@sot.add :transfer, @k[5], @owner_account, 100 * @E6

@sot.exp :balance_of,               @a[1], nil, 0
@sot.exp :balance_of,               @a[5], nil, -100 * @E6
@sot.exp :balance_of, @redemption_account, nil, 0
@sot.exp :balance_of,      @owner_account, nil, 100 * @E6

@sot.do


###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"

