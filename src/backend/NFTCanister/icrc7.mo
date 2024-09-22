import ICRC7 "mo:icrc7-mo";

module {
  public let defaultConfig = func(caller : Principal) : ICRC7.InitArgs {
    ?{
      symbol = ?"KT";
      name = ?"Knowledge Token";
      description = ?"A collection of Knowledge Tokens for e-commerce";
      logo = ?"https://knowledgefound.org/images/lightbulb-large.png";
      supply_cap = ?1000000;
      allow_transfers = ?true;
      max_query_batch_size = ?100;
      max_update_batch_size = ?100;
      default_take_value = ?50;
      max_take_value = ?100;
      max_memo_size = ?256;
      permitted_drift = ?2_000_000_000;
      burn_account = null;
      deployer = caller;
      supported_standards = null;
      tx_window = null;
      override = true;
    };
  };
};
