Smart contract based on ERC721 standard to emit and sell event tickets.

It allows to create different types of tokens, each of them with a cap and a price. This emulates the different tiers of tickets that can exist for a real world event. It's also possible to define a max amount of tickets to be sold in a single action.

_A proof of concept is running at address 0xabA9428549a59A9c75Fa8334c895E5834442f3B0 of the Görli ETH Testnet. It has 2 types of tickets with caps prices of 1 and 2 ETH, and caps of 50 and 100 tokens._

Functions:
- buyToken: Allows a user to send ETH to the contract, indicating the type and quantity of tickets, and the contract will send these tickets and a refund for the excedent (if it applies).
- courtesyToken: Allows the owner to send tickets for free to anyone. Receives the quantity and the type of tickets, and the address that should receive them.

Proposals of improvements (general):
- Make the contract Burnable, so the tokens may be burned to complete their lifecycle when they are used.
- Implement roles to have a more granular authorization system.
- Build development scripts and connect to a frontend to deploy these contracts dynamically (as it's done in [ez-contract](https://ez-contract.io)).
- Use Chainlink to define prices in FIAT instead of ETH.

Proposals of improvements (based on OpenZeppelin Defender):
- Authorize a Relayer to execute the Burn action, to allow this process to be run by a client connected to the backend.
- Use a Sentinel to detect suspicious actions (like a single address sending many requests to buy tickets).
- Use an Autotask to send ETH to contract owner in response to predefined events (instead of sending ETH to the owner action on each sale).

Developed as a project for Blockdemy - OpenZeppelin Bootcamp in August 2022.
Team 14

- Rafael Ochoa <ochoacabriles>
- Aldo Matus <aldoMatus7>
