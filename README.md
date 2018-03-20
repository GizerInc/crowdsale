# Gizer Token

The GZR token represents a building block to a user’s profile on the Ethereum network. Each token represents an unlockable profile item in an "unknown" state. The user can unlock tokens at any time, resulting in a randomized profile item being unlocked which can be applied to the user’s Global Gaming Identity. The rarity of each item is a set probability. 

Users can collect items for rank, statistics, and customize their avatars to gain prestige within the community. As our network grows, we will encourage game developers and other applications to leverage our Global Gaming Identity.

For more information, visit https://tokensale.gizer.io/


## Feb-25-2018: deployment notes for new contracts

The address of contract GZR (GizerToken.sol) must be added to the list of admins of the GZR721 (GizerItems.sol) contract.

The address used to call mintByAdmin() in GZR must be added to the list of admins of the GZR contract, and the user must have called allow() for that address.

To do:

[ ] much more testing 

[ ] check if bulk minting is desirable  


## Tests of ERC20 contract

Testing of the crowdsale contract was completed on Feb-12-2018, the results can be seen at:

https://github.com/GizerInc/crowdsale/tree/master/dev-tests-2018-02

The main test script is _GZR_test_1.rb_, the resulting log is _sLog_1.log_


## Audit of presale contract

https://github.com/bokkypoobah/GizerCrowdsaleAudit/tree/master/audit
