import Main "canister:backend";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import CertifiedData "mo:base/CertifiedData";
import D "mo:base/Debug";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import CertTree "mo:cert/CertTree";
import ICRC3 "mo:icrc3-mo";
import ICRC37 "mo:icrc37-mo";
import ICRC7 "mo:icrc7-mo";
import Vec "mo:vector";

import Types "../commons/NFTypes";
import User "../main/User";
import ICRC3Default "./icrc3";
import ICRC37Default "./icrc37";
import ICRC7Default "./icrc7";
import Iter "mo:base/Iter";

shared (_init_msg) actor class NFTCanister(
    _args : {
        icrc7_args : ?ICRC7.InitArgs;
        icrc37_args : ?ICRC37.InitArgs;
        icrc3_args : ICRC3.InitArgs;
    }
) = this {

    stable var init_msg = _init_msg;

    stable var icrc7_migration_state = ICRC7.init(
        ICRC7.initialState(),
        #v0_1_0(#id),
        switch (_args.icrc7_args) {
            case (null) ICRC7Default.defaultConfig(init_msg.caller);
            case (?val) val;
        },
        init_msg.caller,
    );

    let #v0_1_0(#data(icrc7_state_current)) = icrc7_migration_state;

    stable var icrc37_migration_state = ICRC37.init(
        ICRC37.initialState(),
        #v0_1_0(#id),
        switch (_args.icrc37_args) {
            case (null) ICRC37Default.defaultConfig(init_msg.caller);
            case (?val) val;
        },
        init_msg.caller,
    );

    let #v0_1_0(#data(icrc37_state_current)) = icrc37_migration_state;

    stable var icrc3_migration_state = ICRC3.init(
        ICRC3.initialState(),
        #v0_1_0(#id),
        switch (_args.icrc3_args) {
            case (null) ICRC3Default.defaultConfig(init_msg.caller);
            case (?val) ?val : ICRC3.InitArgs;
        },
        init_msg.caller,
    );

    let #v0_1_0(#data(icrc3_state_current)) = icrc3_migration_state;

    private var _icrc7 : ?ICRC7.ICRC7 = null;
    private var _icrc37 : ?ICRC37.ICRC37 = null;
    private var _icrc3 : ?ICRC3.ICRC3 = null;

    private func get_icrc7_state() : ICRC7.CurrentState {
        return icrc7_state_current;
    };

    private func get_icrc37_state() : ICRC37.CurrentState {
        return icrc37_state_current;
    };

    private func _get_icrc3_state() : ICRC3.CurrentState {
        return icrc3_state_current;
    };

    private var canister_principal : ?Principal = null;

    private func get_canister() : Principal {
        switch (canister_principal) {
            case (null) {
                canister_principal := ?Principal.fromActor(this);
                Principal.fromActor(this);
            };
            case (?val) {
                val;
            };
        };
    };
    
type Account = {
    id: Text;
    balance: Nat;
};

type NFT = {
    token_id: Nat;
    owner: Account;
    metadata: Text;
};

// Define the arrays with immutable elements
var nfts: [NFT] = [];      // Empty immutable array
var accounts: [Account] = []; // Empty immutable array

public shared func buyNFT(token_id: Nat, buyer_id: Text, price: Nat): async Bool {
    // Find the NFT
    let nftOpt = Array.find<NFT>(nfts, func (nft) : Bool {
        nft.token_id == token_id
    });

    switch (nftOpt) {
        case (?nft) {
            // Find the buyer's account
            let buyerOpt = Array.find<Account>(accounts, func (acc) : Bool {
                acc.id == buyer_id
            });

            switch (buyerOpt) {
                case (?buyerAcc) {
                    // Check if buyer has enough balance
                    if (buyerAcc.balance >= price) {
                        // Update NFT owner
                        let updatedNfts = Array.map<NFT, NFT>(nfts, func (nft) : NFT {
                            if (nft.token_id == token_id) {
                                { nft with owner = buyerAcc } // Updated NFT owner
                            } else {
                                nft // Original NFT unchanged
                            }
                        });
                        nfts := updatedNfts;

                        // Update buyer's balance
                        let updatedAccounts1 = Array.map<Account, Account>(accounts, func (acc) : Account {
                            if (acc.id == buyer_id) {
                                { acc with balance = acc.balance - price } // Updated balance
                            } else {
                                acc // Original account unchanged
                            }
                        });

                        // Update seller's balance
                        let updatedAccounts2 = Array.map<Account, Account>(updatedAccounts1, func (acc) : Account {
                            if (acc.id == nft.owner.id) {
                                { acc with balance = acc.balance + price } // Updated balance
                            } else {
                                acc // Original account unchanged
                            }
                        });
                        accounts := updatedAccounts2;

                        true // Purchase successful
                    } else {
                        false // Insufficient balance
                    }
                };
                case null {
                    false // Buyer not found
                };
            }
        };
        case null {
            false // NFT not found
        };
    }
};


    public shared (msg) func sell_nft(token_id: Nat, seller: Principal, price: Nat) : async Bool {
        // Logic for selling the NFT
        D.print("NFT sold by: " # Principal.toText(seller) # " for price: " # Nat.toText(price));
        return true;
    };


    private func updated_certification(_cert : Blob, _lastIndex : Nat) : Bool {
        D.print("updating the certification " # debug_show (CertifiedData.getCertificate(), ct.treeHash()));
        ct.setCertifiedData();
        D.print("did the certification " # debug_show (CertifiedData.getCertificate()));
        return true;
    };

    private func get_time() : Int {
        Time.now();
    };

    stable let cert_store : CertTree.Store = CertTree.newStore();
    let ct = CertTree.Ops(cert_store);

    private func get_certificate_store() : CertTree.Store {
        D.print("returning cert store " # debug_show (cert_store));
        return cert_store;
    };

    private func get_icrc3_environment() : ICRC3.Environment {
        ?{
            updated_certification = ?updated_certification;
            get_certificate_store = ?get_certificate_store;
        };
    };

    private func get_icrc7_environment() : ICRC7.Environment {
        {
            canister = get_canister;
            get_time = get_time;
            refresh_state = get_icrc7_state;
            add_ledger_transaction = ?icrc3().add_record;
            can_mint = null;
            can_burn = null;
            can_transfer = null;
            can_update = null;
            allow_transfers = ?true;
        };
    };

    private func get_icrc37_environment() : ICRC37.Environment {
        {
            canister = get_canister;
            get_time = get_time;
            refresh_state = get_icrc37_state;
            icrc7 = icrc7();
            can_transfer_from = null;
            can_approve_token = null;
            can_approve_collection = null;
            can_revoke_token_approval = null;
            can_revoke_collection_approval = null;
        };
    };

    private func icrc3() : ICRC3.ICRC3 {
        switch (_icrc3) {
            case (null) {
                let icrc3 = ICRC3.ICRC3(?icrc3_migration_state, Principal.fromActor(this), get_icrc3_environment());
                D.print("Actor is ICRC3: " # debug_show (Principal.fromActor(this)));
                D.print("ensure should be done: " # debug_show (icrc3.supported_block_types()));
                _icrc3 := ?icrc3;
                icrc3;
            };
            case (?icrc3) icrc3;
        };
    };

    private func icrc7() : ICRC7.ICRC7 {
        switch (_icrc7) {
            case (null) {
                let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, Principal.fromActor(this), get_icrc7_environment());
                D.print("Actor is ICRC7 : " # debug_show (Principal.fromActor(this)));
                _icrc7 := ?icrc7;
                icrc7;
            };
            case (?icrc7) icrc7;
        };
    };

    private func icrc37() : ICRC37.ICRC37 {
        switch (_icrc37) {
            case (null) {
                let icrc37 = ICRC37.ICRC37(?icrc37_migration_state, Principal.fromActor(this), get_icrc37_environment());
                D.print("Actor is ICRC37 : " # debug_show (Principal.fromActor(this)));
                _icrc37 := ?icrc37;
                icrc37;
            };
            case (?icrc37) icrc37;
        };
    };

    // ICRC-7 Endpoints
    public shared (msg) func icrc7_mint<system>(tokens : ICRC7.SetNFTRequest) : async [ICRC7.SetNFTResult] {
        let owner = Principal.fromActor(this);
        D.print("Actor is MINTING: " # debug_show (owner));
        D.print("MSG is MINTING : " # debug_show (msg.caller));
        let result = icrc7().set_nfts<system>(icrc7().get_state().owner, tokens, true);
        switch (result) {
            case (#ok(val)) val;
            case (#err(err)) D.trap(err);
        };
    };

    public shared (msg) func icrcX_burn(tokens : ICRC7.BurnNFTRequest) : async ICRC7.BurnNFTBatchResponse {
        switch (icrc7().burn_nfts<system>(msg.caller, tokens)) {
            case (#ok(val)) val;
            case (#err(err)) D.trap(err);
        };
    };

    public query func icrc7_balance_of(account : Types.Account) : async Nat {
        icrc7().balance_of([account])[0];
    };

    public query func icrc7_owner_of(token_id : Nat) : async ?Types.Account {
        icrc7().owner_of([token_id])[0];
    };

    public shared (_msg) func icrc7_transfer(args : Types.TransferArgs) : async [?ICRC7.TransferResult] {
        return icrc7().transfer<system>(icrc7().get_state().owner, [args]); //if you're not using candid, change icrc7().get_state().owner; to msg.caller
    };

    // ICRC-37 Endpoints
    public shared (_msg) func icrc37_approve_tokens(args : Types.ApproveTokenArg) : async Result.Result<Nat, Text> {
        let result = icrc37().approve_tokens<system>(icrc7().get_state().owner, [args]); //if you're not using candid, change icrc7().get_state().owner; to msg.caller
        switch (result[0]) {
            case (? #Ok(id)) #ok(id);
            case (? #Err(err)) #err(debug_show (err));
            case (null) #err("Unexpected null result");
        };
    };

    public shared (msg) func icrc37_transfer_from(args : Types.TransferFromArg) : async Result.Result<Nat, Types.TransferError> {
        let result = icrc37().transfer_from<system>(msg.caller, [args]);
        switch (result[0]) {
            case (? #Ok(id)) #ok(id);
            case (? #Err(err)) #err(err);
            case (null) #err(#GenericError({ error_code = 0; message = "Unexpected null result" }));
        };
    };

    public query func icrc37_is_approved(args : Types.IsApprovedArg) : async Bool {
        icrc37().is_approved([args])[0];
    };

    // ICRC-3 Endpoints
    public func icrc3_get_blocks(start : Nat, length : Nat) : async ICRC3.GetBlocksResult {
        icrc3().get_blocks([{ start; length }]);
    };

    public query func icrc3_get_archives(args : ICRC3.GetArchivesArgs) : async ICRC3.GetArchivesResult {
        icrc3().get_archives(args);
    };

    public shared (_msg) func icrc37_revoke_collection_approvals<system>(args : [ICRC37.Service.RevokeCollectionApprovalArg]) : async [?ICRC37.Service.RevokeCollectionApprovalResult] {
        icrc37().revoke_collection_approvals<system>(icrc7().get_state().owner, args); //if you're not using candid, change icrc7().get_state().owner; to msg.caller
    };

    public shared (_msg) func icrc37_revoke_token_approvals<system>(args : [ICRC37.Service.RevokeTokenApprovalArg]) : async [?ICRC37.Service.RevokeTokenApprovalResult] {
        icrc37().revoke_token_approvals<system>(icrc7().get_state().owner, args); //if you're not using candid, change icrc7().get_state().owner; to msg.caller
    };

    var counter : Nat = 0;
    public shared (msg) func test_create_collection<system>() : async Result.Result<(), Text> {
        let nftData = [
            {
                name = "Image 1";
                description = "A beautiful space image.";
                url = "https://i.ytimg.com/vi/oBUpJ4CqmN0/maxresdefault.jpg";
            },
            {
                name = "Image 2";
                description = "Another stunning image.";
                url = "https://i.ytimg.com/vi/3WpP8ux1zX0/sddefault.jpg";
            },
            {
                name = "Image 3";
                description = "A mesmerizing cosmic view.";
                url = "https://i.ytimg.com/vi/fDMHUdo7m-k/maxresdefault.jpg";
            },
            {
                name = "Image 4";
                description = "An awe-inspiring celestial scene.";
                url = "https://i.ytimg.com/vi/mwbRRk9T5Nw/maxresdefault.jpg";
            },
            {
                name = "Image 5";
                description = "A captivating space phenomenon.";
                url = "https://i.ytimg.com/vi/sZxbRAwYYMw/hqdefault.jpg";
            },
        ];

        let mintRequests = Array.map<{ name : Text; description : Text; url : Text }, ICRC7.SetNFTItemRequest>(
            nftData,
            func(data) {
                let request : ICRC7.SetNFTItemRequest = {
                    token_id = counter;
                    owner = ?{
                        owner = icrc7().get_state().owner;
                        subaccount = null;
                    };
                    metadata = #Class([
                        {
                            name = "icrc7:metadata:uri:image";
                            value = #Text(data.url);
                            immutable = true;
                        },
                        {
                            name = "name";
                            value = #Text(data.name);
                            immutable = true;
                        },
                        {
                            name = "description";
                            value = #Text(data.description);
                            immutable = true;
                        },
                    ]);
                    memo = ?Blob.fromArray([0, 1]);
                    override = true;
                    created_at_time = null;
                };
                counter += 1;
                request;
            },
        );

        D.print("Actor is createCollection  : " # debug_show (Principal.fromActor(this)));
        D.print("MSG is createCollection : " # debug_show (msg.caller));
        let mintResult = await icrc7_mint(mintRequests);
        for (result in mintResult.vals()) {
            switch (result) {
                case (#Ok(?_)) {};
                case (#Ok(null)) {};
                case (#Err(err)) return #err("Failed to mint NFT: " # debug_show (err));
                case (#GenericError { error_code; message }) return #err("Generic error occurred: Code " # Nat.toText(error_code) # " - " # message);
            };
        };
        #ok();
    };

    public shared (_msg) func test_workflow(recipient : Text) : async Result.Result<(), Text> {
        //0. find recipient
        let user = await Main.getUserByName(recipient);
        switch (user) {
            case (null) return #err("No user was found");
            case (?user) {
                let principal = await returnPrincipal(user);
                // 1. Create collection
                let create_result = await test_create_collection();
                switch (create_result) {
                    case (#err(e)) return #err("Failed to create collection: " # e);
                    case (#ok()) {};
                };

                // 2. Check balance
                let balance = await icrc7_balance_of({
                    owner = icrc7().get_state().owner;
                    subaccount = null;
                }); //if you're not using candid, change owner to msg.caller
                if (balance < 2) {
                    return #err("Unexpected balance. Expected 5, got " # Nat.toText(balance));
                };

                // 3. Approve transfer
                let approve_result = await icrc37_approve_tokens({
                    token_id = 0;
                    approval_info = {
                        from_subaccount = null;
                        spender = {
                            owner = principal;
                            subaccount = null;
                        }; //if you're not using candid, insert an IC identity or an obj
                        memo = ?Blob.fromArray([0, 1]);
                        expires_at = null;
                        created_at_time = null;
                    };
                });
                switch (approve_result) {
                    case (#err(e)) return #err("Failed to approve token: " # e);
                    case (#ok(_)) {};
                };

                // 4. Check approval
                let is_approved = await icrc37_is_approved({
                    spender = {
                        owner = principal;
                        subaccount = null;
                    }; //if you're not using candid, insert an IC identity
                    from_subaccount = null;
                    token_id = 0;
                });
                if (not is_approved) {
                    return #err("Token approval failed");
                };

                // 5. Transfer token
                let transfer_result = await icrc7_transfer({
                    from_subaccount = null;
                    to = {
                        owner = principal;
                        subaccount = null;
                    }; //if you're not using candid, insert an IC identity
                    token_id = 1;
                    memo = null;
                    created_at_time = null;
                });

                switch (transfer_result[0]) {
                    case (? #Ok(_)) {};
                    case (? #Err(e)) return #err("Failed to transfer token: " # debug_show (e));
                    case (null) return #err("Unexpected null result from transfer");
                };
                // 6. Check transaction log
                let blocks = await icrc3_get_blocks(0, 10);
                if (blocks.blocks.size() < 3) {
                    // We expect at least 3 transactions: mint, approve, transfer
                    return #err("Unexpected number of transactions in the log");
                };

                #ok();
            };
        };

    };

    public query func get_stats() : async {
        total_supply : Nat;
        total_transactions : Nat;
    } {
        {
            total_supply = icrc7().total_supply();
            total_transactions = icrc3().stats().localLedgerSize;
        };
    };

    public query func icrc7_symbol() : async Text {
        return switch (icrc7().get_ledger_info().symbol) {
            case (?val) val;
            case (null) "";
        };
    };

    public query func icrc7_name() : async Text {
        return switch (icrc7().get_ledger_info().name) {
            case (?val) val;
            case (null) "";
        };
    };

    public query func icrc7_description() : async ?Text {
        return icrc7().get_ledger_info().description;
    };

    public query func icrc7_logo() : async ?Text {
        return icrc7().get_ledger_info().logo;
    };

    public query func icrc7_max_memo_size() : async ?Nat {
        return ?icrc7().get_ledger_info().max_memo_size;
    };

    public query func icrc7_tx_window() : async ?Nat {
        return ?icrc7().get_ledger_info().tx_window;
    };

    public query func icrc7_permitted_drift() : async ?Nat {
        return ?icrc7().get_ledger_info().permitted_drift;
    };

    public query func icrc7_total_supply() : async Nat {
        return icrc7().get_stats().nft_count;
    };

    public query func icrc7_supply_cap() : async ?Nat {
        return icrc7().get_ledger_info().supply_cap;
    };

    public query func icrc37_max_approvals_per_token_or_collection() : async ?Nat {
        return icrc37().max_approvals_per_token_or_collection();
    };

    public query func icrc7_max_query_batch_size() : async ?Nat {
        return icrc7().max_query_batch_size();
    };

    public query func icrc7_max_update_batch_size() : async ?Nat {
        return icrc7().max_update_batch_size();
    };

    public query func icrc7_default_take_value() : async ?Nat {
        return icrc7().default_take_value();
    };

    public query func icrc7_max_take_value() : async ?Nat {
        return icrc7().max_take_value();
    };

    public query func icrc7_atomic_batch_transfers() : async ?Bool {
        return icrc7().atomic_batch_transfers();
    };

    public query func icrc37_max_revoke_approvals() : async ?Nat {
        return ?icrc37().get_ledger_info().max_revoke_approvals;
    };

    public query func icrc7_collection_metadata() : async [(Text, ICRC7.Value)] {

        let ledger_info = icrc7().collection_metadata();
        let ledger_info37 = icrc37().metadata();
        let results = Vec.new<(Text, ICRC7.Value)>();

        Vec.addFromIter(results, ledger_info.vals());
        Vec.addFromIter(results, ledger_info37.vals());

        return Vec.toArray(results);
    };

    public query func icrc7_token_metadata(token_ids : [Nat]) : async [?[(Text, ICRC7.Value)]] {
        return icrc7().token_metadata(token_ids);
    };

    public query func icrc7_tokens(prev : ?Nat, take : ?Nat) : async [Nat] {
        return icrc7().get_tokens_paginated(prev, take);
    };

    public query func icrc7_tokens_of(account : ICRC7.Account, prev : ?Nat, take : ?Nat) : async [Nat] {
        return icrc7().get_tokens_of_paginated(account, prev, take);
    };

    public query func icrc37_get_token_approvals(token_ids : [Nat], prev : ?ICRC37.TokenApproval, take : ?Nat) : async [ICRC37.TokenApproval] {
        return icrc37().get_token_approvals(token_ids, prev, take);
    };

    public query func icrc37_get_collection_approvals(owner : ICRC7.Account, prev : ?ICRC37.CollectionApproval, take : ?Nat) : async [ICRC37.CollectionApproval] {
        return icrc37().get_collection_approvals(owner, prev, take);
    };

    public shared (msg) func icrc37_approve_collection(approvals : [Types.ApproveCollectionArg]) : async [?ICRC37.ApproveCollectionResult] {
        let owner = Principal.fromActor(this);
        D.print("Actor is approving collection: " # debug_show (owner));
        D.print("MSG is approving_collection : " # debug_show (msg.caller));
        icrc37().approve_collection<system>(msg.caller, approvals);
    };

    public func returnPrincipal(user : User.User) : async Principal {
        return Principal.fromActor(user);
    };

    public func returnICRC7Owner() : async Principal {
        return icrc7().get_state().owner;
    };

    private stable var _init = false;

    public shared (_msg) func init() : async () {
        //can only be called once

        //Warning:  This is a test scenario and should not be used in production.
        //This creates an approval for the owner of the canister and this can be garbage
        // collected if the max_approvals is hit. We advise minting with the target owner
        //in the metadata or creating an assign function (see assign)

        if (_init == false) {
            //approve the deployer as a spender on all tokens...
            let current_val = icrc37().get_state().ledger_info.collection_approval_requires_token;
            let _update = icrc37().update_ledger_info([#CollectionApprovalRequiresToken(false)]);
            let result = icrc37().approve_collection<system>(Principal.fromActor(this), [{ approval_info = { from_subaccount = null; spender = { owner = icrc7().get_state().owner; subaccount = null }; memo = null; expires_at = null; created_at_time = null } }]);
            let _update2 = icrc37().update_ledger_info([#CollectionApprovalRequiresToken(current_val)]);

            D.print(
                "initialized" # debug_show (
                    result,
                    {
                        from_subaccount = null;
                        spender = {
                            owner = icrc7().get_state().owner;
                            subaccount = null;
                        };
                        memo = null;
                        expires_at = null;
                        created_at_time = null;
                    },
                )
            );
        };
        _init := true;
    };
};
