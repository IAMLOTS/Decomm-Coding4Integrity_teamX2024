import ICRC37 "mo:icrc37-mo";

module {
  public let defaultConfig = func(caller : Principal) : ICRC37.InitArgs {
    ?{
      max_approvals_per_token_or_collection = ?10;
      max_revoke_approvals = ?100;
      collection_approval_requires_token = ?false;
      max_approvals = ?1000;
      settle_to_approvals = ?950;
      deployer = caller;
    };
  };
};
