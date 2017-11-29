# GZRPRE development test

The test was done using the GizerTokenPresaleTest contract on a local Parity development chain, with the following modifications to the GizerToken contract:

uint public constant MAX_CONTRIBUTION = 1000 ether;
uint public constant PRIVATE_SALE_MAX_ETHER = 1000 ether;
uint public constant CUTOFF_PRESALE_ONE = 2;
uint public constant CUTOFF_PRESALE_TWO = 4;
uint public constant FUNDING_PRESALE_MAX = 2500 ether;

Special accounts used:

18: owner
19: wallet_account
20: redemption_account