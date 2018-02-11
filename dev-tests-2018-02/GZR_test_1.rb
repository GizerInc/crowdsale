require_relative "GZR_ini"

File.basename(__FILE__) =~ /(\d+)\.rb$/
@sot.test_nr = $1

###############################################################################

def get_token_amount(eth)
  tokens = eth * 1_000 * @E6
  return tokens.to_i
end

###############################################################################

@sl.h1 'Preliminary actions'

###

@sot.txt 'Set wallets'

@sot.own :set_wallet,            @wallet_account
@sot.own :set_redemption_wallet, @redemption_account

@sot.exp :wallet,            @sot.strip0x(@wallet_account)
@sot.exp :redemption_wallet, @sot.strip0x(@redemption_account)

@sot.do


###############################################################################

@sl.h1 'Before crowdsale'

###

@sot.txt 'Some minting (ok) and an early contribution (throws)'

@sot.own :mint_tokens, @a[9],        1_714_112 * @E6 # GZRPRE
@sot.own :mint_tokens, @a[1],          500_000 * @E6
@sot.own :mint_tokens_locked, @a[1],   500_000 * @E6
@sot.own :mint_tokens, @a[2],        1_500_000 * @E6 # fails, over the limit

@sot.snd @k[1], 10 # this contribution gets rejected

@sot.exp :balance_of, @a[9], 1_714_112 * @E6, 1_714_112 * @E6
@sot.exp :balance_of, @a[1], 1_000_000 * @E6, 1_000_000 * @E6
@sot.exp :balance_of, @a[2],         0 * @E6,         0 * @E6
@sot.exp :balance_of, @a[3], 0, 0

@sot.exp :locked, @a[1],   500_000 * @E6, 500_000 * @E6
@sot.exp :locked, @a[9],         0 * @E6,       0 * @E6

@sot.exp :tokens_issued_total, 2_714_112 * @E6, 2_714_112 * @E6
@sot.exp :tradeable, false

@sot.do

#

@sot.txt 'Transfers are not possible'
@sot.add :transfer, @k[1], @a[10], 1 * @E6
@sot.exp :balance_of, @a[1], nil, 0
@sot.do


###############################################################################

@sl.h1 'Crowdsale'

epoch = @sot.var :date_ico_start
jump_to(epoch, 'crowdsale')

#

@sot.txt 'Some contributions and minting'

@sot.snd @k[1], 1_000
@sot.snd @k[2],   100
@sot.snd @k[3], 4_000
@sot.snd @k[4], 2_000 # over the limit

@sot.own :mint_tokens,        @a[4], 1_000_000 * @E6 # ok
@sot.own :mint_tokens_locked, @a[5],         1 * @E6 # over

@sot.exp :balance_of, @a[1], nil, 1_000_000 * @E6
@sot.exp :balance_of, @a[2], nil,   100_000 * @E6
@sot.exp :balance_of, @a[3], nil, 4_000_000 * @E6
@sot.exp :balance_of, @a[4], nil, 1_000_000 * @E6

@sot.exp :tradeable, false

@sot.do

#

@sot.txt 'Another contribution'
@sot.snd @k[3], 111
@sot.exp :balance_of, @a[3], nil, 111_000 * @E6
@sot.do

#

@sot.txt 'Transfer - fails (not tradeable)'
@sot.add :transfer, @k[1], @a[19], 1 * @E6
@sot.exp :balance_of, @a[1], nil, 0
@sot.exp :balance_of, @a[19], 0, 0
@sot.exp :tradeable, false
@sot.do

###############################################################################

@sl.h1 'After Crowdsale'

epoch = @sot.var :date_ico_end
jump_to(epoch, 'after crowdsale')

#

@sot.txt 'Contributions (fail) and minting'

@sot.snd @k[1], 1
@sot.own :mint_tokens,        @a[7],  74_888 * @E6
@sot.own :mint_tokens,        @a[8], 800_000 * @E6
@sot.own :mint_tokens_locked, @a[8], 200_000 * @E6
@sot.own :mint_tokens,        @a[8],       1 * @E6 # over

@sot.exp :balance_of, @a[1],             nil,         0
@sot.exp :balance_of, @a[7],    74_888 * @E6,    74_888 * @E6
@sot.exp :balance_of, @a[8], 1_000_000 * @E6, 1_000_000 * @E6

@sot.exp :locked,     @a[8],   200_000 * @E6,   200_000 * @E6

@sot.exp :tradeable, true
@sot.exp :available_to_mint, 0
@sot.exp :unlocked_tokens, @a[8], nil, 800_000 * @E6

@sot.do

#

@sot.txt 'Transfer multiple - not ok, exceeds unlocked'

@sot.add :transfer_multiple, @k[1], @a[11..13], [600_000 * @E6, 600_000 * @E6, 600_000 * @E6]

@sot.exp :balance_of, @a[1], nil, 0
@sot.exp :balance_of, @a[11], 0, 0
@sot.exp :balance_of, @a[12], 0, 0
@sot.exp :balance_of, @a[13], 0, 0

@sot.do

#

@sot.txt 'Transfer multiple - now ok, exactly unlocked'

@sot.add :transfer_multiple, @k[1], @a[11..13], [400_000 * @E6, 500_000 * @E6, 600_000 * @E6]
@sot.add :transfer, @k[1], @a[19], 1 * @E6 # fails

@sot.exp :balance_of, @a[1],  500_000 * @E6, -1_500_000 * @E6
@sot.exp :balance_of, @a[11], 400_000 * @E6,    400_000 * @E6
@sot.exp :balance_of, @a[12], 500_000 * @E6,    500_000 * @E6
@sot.exp :balance_of, @a[13], 600_000 * @E6,    600_000 * @E6
@sot.exp :balance_of, @a[19], 0, 0

@sot.do

#

@sot.txt 'Transfer from'

@sot.add :approve, @k[8], @a[10], 1_000_000 * @E6 # approves all

@sot.add :transfer_from, @k[10], @a[8], @a[14], 500_000 * @E6 # ok
@sot.add :transfer_from, @k[10], @a[8], @a[15], 300_000 * @E6 # ok
@sot.add :transfer_from, @k[10], @a[8], @a[16], 200_000 * @E6 # locked

@sot.exp :balance_of, @a[8],  200_000 * @E6, -800_000 * @E6
@sot.exp :balance_of, @a[14], 500_000 * @E6,  500_000 * @E6
@sot.exp :balance_of, @a[15], 300_000 * @E6,  300_000 * @E6
@sot.exp :balance_of, @a[16], 0, 0

@sot.do

###############################################################################

@sl.h1 'After Tokens unlocked'

epoch = @sot.var :date_tokens_unlocked
jump_to(epoch, 'after tokens unlocked')

#

@sot.txt 'Transfer from'

@sot.add :transfer_from, @k[10], @a[8], @a[16], 200_000 * @E6 # locked

@sot.exp :balance_of, @a[8],        0 * @E6, -200_000 * @E6
@sot.exp :balance_of, @a[16], 200_000 * @E6,  200_000 * @E6

@sot.do

###############################################################################

@sot.dump
output_pp @sot.get_state(true), "state_#{@sot.test_nr}.txt"
