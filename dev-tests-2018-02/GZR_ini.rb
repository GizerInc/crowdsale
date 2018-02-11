require "Ethereum.rb"
require "eth"
require_relative "./lib/utils.rb"
require_relative "./lib/Sot.rb"

##

@contract_address = "0x287110C1CC5a8E4Ca3Bc42D993688C7B15312eDE"

##

@token = 'GZR'
@name = 'GizerToken'

@wallet_account     = '0xF895b6041f3953B529910bA5EC50eC9a3320DC5a'
@admin_account      = '0xDF8f647384Ed63AA931B3C509cC07c658bD45d00'
@redemption_account = '0x95f928D6DbF46B9aCa73782485fe912e1a9A3bC6'


@admin_key = Eth::Key.new priv: '27006809b24c2d2bc27e2b3fb929830843ac5ead81b3d8d15d83d60934b46025'

# ini variables

@E6, @E18, @DAY  = 10**6, 10**18, 24 * 60 * 60

# ini simple log

@sl = SimpleLog.new({:verbose => true})
@sl.p Time.now.utc

# test accounts

@acts = JSON.parse(File.read("acc/#{@token}.full.json"))

# variables and mappings

@vars = %w[
at_now
wallet
redemption_wallet
date_ico_start
date_ico_end
date_tokens_unlocked
ether_received
tokens_issued_crowd
tokens_issued_owner
tokens_issued_total
tokens_issued_locked
available_to_mint
tradeable
token_supply_owner
token_supply_crowd
token_supply_total
]

@maps = %w[
get_balance
balance_of
ether_contributed
tokens_received
locked
]

@types = {
  'get_balance' => :ether,
  'at_now'      => :date,
  'tradeable'   => :bool,
}

# ini contract and owner key

@client = Ethereum::HttpClient.new('http://127.0.0.1:8545')
@contract_abi = File.read('abi/abi.txt')
# @contract = Ethereum::Contract.create(client: @client, name: @name, address: @contract_address, abi: @contract_abi)
@owner_key = Eth::Key.new priv: 'b0f1974b7ac16b84be3e1489775ccd76779c9a063121dc5cf6c742cc51fbbf93'

@sot = Sot.new(
  {
  :client  => @client,
  :name    => @name,
  :address => @contract_address,
  :abi     => @contract_abi,
  :own_key => @owner_key,
  :sl      => @sl,
  :acts    => @acts,
  :vars    => @vars,
  :maps    => @maps,
  :types   => @types,
  :test_nr => @test_nr
  }
)
sot = @sot

@a  = @sot.a
@h  = @sot.h
@lk = @sot.lk
@k  = @sot.k

# sot.get_state
#
# sot.call [ 'e:get_balance', @a[300] ]
# sot.call [ 'balance_of', @a[300] ]
#
#output_pp(@sot.get_state(true), 'state.txt')


###############################################################################

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

def jump_to(epoch, label)
  @sot.txt label
  @sot.own :set_test_time, epoch + 1
  @sot.exp :at_now, epoch + 1
  @sot.do
end

