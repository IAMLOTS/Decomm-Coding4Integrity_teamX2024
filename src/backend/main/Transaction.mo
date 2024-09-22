import Nat "mo:base/Nat";
import Text "mo:base/Text";

import Types "../commons/Types";

actor class Transaction(id : Nat, productID : Nat, buyerID : Text, paidPrice : Types.Price) {
    var transactionID : Nat = id;
    var transactionProductID : Nat = productID;
    var transactionBuyerID : Text = buyerID;
    var transactionPaidPrice : Types.Price = paidPrice;

    public query func getID() : async Nat {
        return transactionID;
    };

    public query func getProductID() : async Nat {
        return transactionProductID;
    };

    public query func getBuyerID() : async Text {
        return transactionBuyerID;
    };

    public query func getPaidPrice() : async Types.Price {
        return transactionPaidPrice;
    };

    public func setProductID(newProductID : Nat) : async () {
        transactionProductID := newProductID;
    };

    public func setBuyerID(newBuyerID : Text) : async () {
        transactionBuyerID := newBuyerID;
    };

    public func setPaidPrice(newPaidPrice : Types.Price) : async () {
        transactionPaidPrice := newPaidPrice;
    };
};
