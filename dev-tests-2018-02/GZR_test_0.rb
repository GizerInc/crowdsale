require_relative "GZR_ini"

puts @sot.contract.call.tokens_per_eth
puts @sot.var :tokens_per_eth

output_pp @sot.get_state(true), "state.txt"


