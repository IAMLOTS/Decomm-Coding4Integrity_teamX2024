# Pretoria South Africa Hackathon

### Corruption Combat Coders

Welcome to the Decomm (decentralized e-commerice) project and to the internet computer development community.

To get started, you might want to explore the project directory structure and the default configuration file. Working with this project in your development environment will not affect any production deployment or identity tokens.

To learn more before you start working with BackEnd and FrontEnd, see the following documentation available online:

- [Quick Start](https://internetcomputer.org/docs/current/developer-docs/setup/deploy-locally)
- [SDK Developer Tools](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [Motoko Programming Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Motoko Language Quick Reference](https://internetcomputer.org/docs/current/motoko/main/language-manual)
- [ckBTC and Bitcoin Integration](https://internetcomputer.org/docs/current/tutorials/developer-journey/level-4/4.3-ckbtc-and-bitcoin)
- [Svelte Front-End Framework](https://svelte.dev/)
- [Tailwind Styling System](https://tailwindcss.com/)
- [Shadcn-Svelte Component Library](https://www.shadcn-svelte.com/)

## The DFINITY Command-Line

---

This project utilizes The DFINITY command-line execution environment (dfx). The primary tool for creating, deploying, and managing, dapps that are developed in for the Internet Computer.

**_Note that currently the dfx tool is not natively supported on windows._**

In order to use dfx on a Windows machine you'll need to download the Windows Subsystem for Linux (WSL). Refer to Microsoft's official guide [here](https://learn.microsoft.com/en-us/windows/wsl/install), and [here](https://learn.microsoft.com/en-us/windows/wsl/setup/environment)

### Installing Node, IC SDK, DFX, and MOPS

Ensure you have Node installed in WSL or your macOS. 

If not you can install it through nvm (node version manager) for both Linux and macOS run the following:

```bash
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# download and install Node.js (you may need to restart the terminal)
nvm install 20

# verifies the right Node.js version is in the environment
node -v # should print `v20.17.0`

# verifies the right npm version is in the environment
npm -v # should print `10.8.2`
```

To install dfx run the following:

```bash
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
```

To verify that the IC SDK is successfully installed, run the following command:

```bash
dfx --version
```

It's recommended to create an identity using dfx. To set an identity and a key run the following command:

```bash
dfx identity new
```

Then use your identity:

```bash
dfx identity use <insert_name>
```

To verify the list of identities available:
```bash
dfx identity list
```

Learn more about dfx identities here - [dfx identity](https://internetcomputer.org/docs/current/references/cli-reference/dfx-identity)

Mops a package manager that needs to be installed on the system rather then on the working directory. In root run this command:

Through curl

```bash
#In the root of your system ~/

curl -fsSL cli.mops.one/install.sh | sh
```

**Note that the installation of mops will take some time. Approximately five minutes, or more depending on your system and network connection.**

## Starting the project

install the relevant packages needed to run both the backend and frontend for the first time by running:

```bash
cd ~/Decomm-Coding4Integrity_teamX2024
npm install
```

## Running the Project

If you want to start working on your project, run the following commands:

**_Note due to source mapping, building the frontend application requires a large amount of memory. Increase the maximum heap size given to Node.js to anything above the default 2GB_**

```bash
//2.5GB
export NODE_OPTIONS="--max-old-space-size=2500"
//3GB
export NODE_OPTIONS="--max-old-space-size=3072"
//4GB
export NODE_OPTIONS="--max-old-space-size=4096"
```


```bash
npm run startdfx
npm run deploy
npm run generate
```

This will build and deploy the project locally.

###### **Note** running npm run generate at the end is optional. It generates decleration files, but is done through npm run deploy. Although, it will be useful if you update the backend/frontend and want to reference a function you will generate rather than deploy as it takes less time.

## Running the project locally with Hot Module Replacement

If you want to test your project locally with Hot Module Replacement (HMR), you can use the following commands:

```bash
# If you ran the command above
npm run dev

# If you are starting the project again and want HMR
cd ~/Decomm-Coding4Integrity_teamX2024
npm run startdfx
npm run deploy
npm run generate
npm run dev
```

Using svelte's native localhost:5173 local server you can now edit your code with HMR without the need to rebuild the files to see changes. This might take a few minutes as packages are being optimized on runtime.

Additionally, if you decide to change some backend code and would like to only build a certain canister run:

```bash
dfx deploy <canister_name>

#To generate decleration files for the frontend:
dfx generate
```

Don't forget to shutdown the dfx network once you finish with coding!

```bash
dfx stop
```

## Deploying to IC

To deploy to the internet computer run the following command:

```bash
npm run deployIC
```

or if you only want to push one canister to the internet computer

```bash
dfx deploy --network ic <canister_name>
```

## Additional Commands

A list of all predefined commands can be found in the package.json file.

Here are some commands that might be useful:

To deposit cycles to a canister run:

```bash
npm run addCyclesIC <amount> <Canister ID>
```

To check the status of a canister run:

```bash
npm run canisterStatus <Canister ID>
```

To rebuild a canisters on the internet computer run:

```bash
npm run rebuildCanister <Canister ID>
```

To get the ID of a canister from the canister name run:

```bash
npm run canisterIDIC <Canister Name>
```

## NFT canister

- Ensure DFX is running.
- deploy the backend canister if you havent already as it's a dependancy.
- deploy the NFT_CANISTER.
- run the test_workflow() function to create a collection, mint NFTs, approve other users to spend the NFT and transfer the NFT. give one of the previously created user's username as an arg.
- check these resources for further information on the ICRC standards:
  * https://internetcomputer.org/docs/current/tutorials/developer-journey/level-5/5.4-NFT-tutorial#overview
  * https://mops.one/icrc3-mo
  * https://mops.one/icrc7-mo
  * https://mops.one/icrc37-mo

### NFT Canister Function Implementation

#### Overview
This Motoko class implements the Internet Computer standards ICRC7, ICRC37, and ICRC3, which provide functionalities for NFT minting, approval, transfer, and transaction management. This canister supports the creation and management of NFTs (Non-Fungible Tokens) in a decentralized environment.

##### Initialization
The canister is initialized with the following optional arguments:
- **icrc7_args**: Initialization arguments for ICRC7.
- **icrc37_args**: Initialization arguments for ICRC37.
- **icrc3_args**: Initialization arguments for ICRC3 (required).

#### Functions

##### ICRC7 Functions

- **icrc7_mint(tokens: ICRC7.SetNFTRequest) : async [ICRC7.SetNFTResult]**
    - **Summary**: Mints new NFTs based on the provided token information.
    - **Arguments**: A list of NFT minting requests.
    - **Returns**: A list of results indicating the success or failure of each minting operation.

- **icrc7_balance_of(account: Types.Account) : async Nat**
    - **Summary**: Retrieves the balance of NFTs for a specified account.
    - **Arguments**: The account to query.
    - **Returns**: The number of NFTs owned by the account.

- **icrc7_owner_of(token_id: Nat) : async ?Types.Account**
    - **Summary**: Retrieves the owner of a specified token.
    - **Arguments**: The ID of the token.
    - **Returns**: The account that owns the token, or null if not found.

- **icrc7_transfer(args: Types.TransferArgs) : async [?ICRC7.TransferResult]**
    - **Summary**: Transfers a token from one account to another.
    - **Arguments**: The transfer arguments, including source, destination, and token ID.
    - **Returns**: The result of the transfer operation.
- **icrc7_symbol() : async Text**
    - **Summary**: Retrieves the symbol of the NFT collection.
    - **Arguments**: None.
    - **Returns**: The symbol as text.

- **icrc7_name() : async Text**
    - **Summary**: Retrieves the name of the NFT collection.
    - **Arguments**: None.
    - **Returns**: The name as text.

- **icrc7_description() : async ?Text**
    - **Summary**: Retrieves the description of the NFT collection.
    - **Arguments**: None.
    - **Returns**: The description as optional text.

- **icrc7_logo() : async ?Text**
    - **Summary**: Retrieves the logo of the NFT collection.
    - **Arguments**: None.
    - **Returns**: The logo as optional text.

- **icrc7_max_memo_size() : async ?Nat**
    - **Summary**: Retrieves the maximum size of memos allowed for NFTs.
    - **Arguments**: None.
    - **Returns**: The maximum memo size as optional Nat.

- **icrc7_tx_window() : async ?Nat**
    - **Summary**: Retrieves the transaction window for NFTs.
    - **Arguments**: None.
    - **Returns**: The transaction window as optional Nat.

- **icrc7_permitted_drift() : async ?Nat**
    - **Summary**: Retrieves the permitted drift value for NFTs.
    - **Arguments**: None.
    - **Returns**: The permitted drift as optional Nat.

- **icrc7_total_supply() : async Nat**
    - **Summary**: Retrieves the total supply of NFTs.
    - **Arguments**: None.
    - **Returns**: The total supply as Nat.

- **icrc7_supply_cap() : async ?Nat**
    - **Summary**: Retrieves the supply cap for the NFT collection.
    - **Arguments**: None.
    - **Returns**: The supply cap as optional Nat.

- **icrc7_collection_metadata() : async [(Text, ICRC7.Value)]**
    - **Summary**: Retrieves metadata for the entire NFT collection.
    - **Arguments**: None.
    - **Returns**: A list of metadata key-value pairs.

- **icrc7_max_query_batch_size() : async ?Nat**
    - **Summary**: Retrieves the maximum batch size for query operations.
    - **Arguments**: None.
    - **Returns**: The maximum query batch size as optional Nat.

- **icrc7_max_update_batch_size() : async ?Nat**
    - **Summary**: Retrieves the maximum batch size for update operations.
    - **Arguments**: None.
    - **Returns**: The maximum update batch size as optional Nat.

- **icrc7_default_take_value() : async ?Nat**
    - **Summary**: Retrieves the default take value for NFT transfers.
    - **Arguments**: None.
    - **Returns**: The default take value as optional Nat.

- **icrc7_max_take_value() : async ?Nat**
    - **Summary**: Retrieves the maximum take value for NFT transfers.
    - **Arguments**: None.
    - **Returns**: The maximum take value as optional Nat.

- **icrc7_atomic_batch_transfers() : async ?Bool**
    - **Summary**: Checks if atomic batch transfers are enabled for NFTs.
    - **Arguments**: None.
    - **Returns**: True if enabled, false otherwise.

##### ICRC37 Functions

- **icrc37_approve_tokens(args: Types.ApproveTokenArg) : async Result.Result<Nat, Text>**
    - **Summary**: Approves a specified token for transfer by another account.
    - **Arguments**: The approval arguments, including token ID, spender, and optional memo.
    - **Returns**: The ID of the approved token or an error message.

- **icrc37_transfer_from(args: Types.TransferFromArg) : async Result.Result<Nat, Types.TransferError>**
    - **Summary**: Transfers a token on behalf of an account, given that the transfer was approved.
    - **Arguments**: The transfer arguments, including source, destination, and token ID.
    - **Returns**: The ID of the transferred token or an error.

- **icrc37_is_approved(args: Types.IsApprovedArg) : async Bool**
    - **Summary**: Checks if a token has been approved for transfer by another account.
    - **Arguments**: The approval check arguments, including token ID and spender.
    - **Returns**: True if approved, false otherwise.

- **icrc37_max_approvals_per_token_or_collection() : async ?Nat**
    - **Summary**: Retrieves the maximum number of approvals allowed per token or collection.
    - **Arguments**: None.
    - **Returns**: The maximum approvals as optional Nat.

- **icrc37_max_revoke_approvals() : async ?Nat**
    - **Summary**: Retrieves the maximum number of revoke approvals allowed.
    - **Arguments**: None.
    - **Returns**: The maximum revoke approvals as optional Nat.

##### ICRC3 Functions

- **icrc3_get_blocks(start: Nat, length: Nat) : async ICRC3.GetBlocksResult**
    - **Summary**: Retrieves a range of blocks from the transaction history.
    - **Arguments**: The starting block index and the number of blocks to retrieve.
    - **Returns**: A list of transaction blocks.

- **icrc3_get_archives(args: ICRC3.GetArchivesArgs) : async ICRC3.GetArchivesResult**
    - **Summary**: Retrieves archived transaction data.
    - **Arguments**: The arguments specifying the archive to retrieve.
    - **Returns**: The archived transaction data.

##### Utility Functions

- **test_create_collection<system>() : async Result.Result<(), Text>**
    - **Summary**: Creates a sample NFT collection for testing purposes.
    - **Arguments**: None.
    - **Returns**: Success or error message.

- **test_workflow(usingCandid: Bool) : async Result.Result<(), Text>**
    - **Summary**: Executes a test workflow including minting, approval, and transfer of NFTs.
    - **Arguments**: A boolean indicating whether to use Candid for identity.
    - **Returns**: Success or error message.

- **get_stats() : async {total_supply: Nat; total_transactions: Nat}**
    - **Summary**: Retrieves statistics on the total NFT supply and the number of transactions.
    - **Arguments**: None.
    - **Returns**: A record containing total NFT supply and total transactions.


## Design Documents

Design documents can be found in the design documents folder in this repository. [View Design Documents](https://github.com/KnowledgeFound/Coding4Integrity-DeComm-Hackathon/tree/master/DesignDocs/)

## Additional Notes:

If you'd like to include the sorting/filtering canister in your code add the following to dfx.json:

```json
    "sortingFiltering": {
      "main": "src/backend/sorting/main.mo",
      "type": "motoko",
      "dependencies": ["backend"]
    }
```

To format the frontend code you can run prettier in the command line:

```bash
npm run format
```