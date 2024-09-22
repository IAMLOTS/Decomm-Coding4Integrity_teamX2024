import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Types "../commons/Types";

actor class User(
    name : Text,
    buyersCart : [Types.Product],
    sellersStock : [Types.Product],
    purchases : [Types.Transaction],
    soldItems : [Types.Transaction],
    wallet : [Types.Price],
) {

    stable var userName : Text = name;
    stable var userBuyersCart : [Types.Product] = buyersCart;
    stable var userSellersStock : [Types.Product] = sellersStock;
    stable var userPurchases : [Types.Transaction] = purchases;
    stable var userSoldItems : [Types.Transaction] = soldItems;
    stable var userWallet : [Types.Price] = wallet;

    var buyersCartBuffer = Buffer.fromArray<Types.Product>(userBuyersCart);
    var sellersStockBuffer = Buffer.fromArray<Types.Product>(userSellersStock);
    var purchasesBuffer = Buffer.fromArray<Types.Transaction>(userPurchases);
    var soldItemsBuffer = Buffer.fromArray<Types.Transaction>(userSoldItems);
    var _walletBuffer = Buffer.fromArray<Types.Price>(userWallet);

    public query func getName() : async Text {
        return userName;
    };

    public query func getSellersStock() : async [Types.Product] {
        return userSellersStock;
    };

    public query func getPurchases() : async [Types.Transaction] {
        return userPurchases;
    };

    public query func getSoldItems() : async [Types.Transaction] {
        return userSoldItems;
    };

    public query func getWallet() : async [Types.Price] {
        return userWallet;
    };

    public func setName(newName : Text) : async () {
        userName := newName;
    };

    public func setBuyersCart(newBuyersCart : [Types.Product]) : async () {
        userBuyersCart := newBuyersCart;
    };

    public func setSellersStock(newSellersStock : [Types.Product]) : async () {
        userSellersStock := newSellersStock;
    };

    public func setPurchases(newPurchases : [Types.Transaction]) : async () {
        userPurchases := newPurchases;
    };

    public func setSoldItems(newSoldItems : [Types.Transaction]) : async () {
        userSoldItems := newSoldItems;
    };

    public func setWallet(newWallet : [Types.Price]) : async () {
        userWallet := newWallet;
    };

    public func listItem(product : Types.Product) : async () {
        sellersStockBuffer.add(product);
        await setSellersStock(Buffer.toArray(sellersStockBuffer));
    };

    public func addToPurchases(transaction : Types.Transaction) : async () {
        purchasesBuffer.add(transaction);
        await setPurchases(Buffer.toArray(purchasesBuffer));
    };

    public func addToSoldItems(transaction : Types.Transaction) : async () {
        soldItemsBuffer.add(transaction);
        await setSoldItems(Buffer.toArray(soldItemsBuffer));
    };

    public func addToWallet(price : Types.Price) : async () {
        var newWallet = Buffer.Buffer<Types.Price>(0);
        for (j in userWallet.vals()) {
            if (price.currency == j.currency) {
                var amount = j.amount +price.amount;
                let p : Types.Price = {
                    currency = price.currency;
                    amount = amount;
                };
                newWallet.add(p);
            } else {
                newWallet.add(j);
            };
        };
        await setWallet(Buffer.toArray(newWallet));
    };

    public func takeFromWallet(price : Types.Price) : async Result.Result<(), Text> {
        var newWallet = Buffer.Buffer<Types.Price>(0);
        for (j in userWallet.vals()) {
            if (price.currency == j.currency) {
                if (j.amount >= price.amount) {
                    var amount = j.amount : Nat - price.amount : Nat;
                    let p : Types.Price = {
                        currency = price.currency;
                        amount = amount;
                    };
                    newWallet.add(p);
                } else {
                    return #err("Insufficient funds");
                };
            } else {
                newWallet.add(j);
            };
        };
        await setWallet(Buffer.toArray(newWallet));
        #ok(());
    };

    public func addToCart(product : Types.Product) : async () {
        buyersCartBuffer.add(product);
        userBuyersCart := Buffer.toArray(buyersCartBuffer);
        Debug.print("User " # userName # " added product to cart: " # debug_show (product.productID));
    };

    public func removeFromCart(productID : Nat) : async () {
        let beforeSize = buyersCartBuffer.size();
        buyersCartBuffer.filterEntries(
            func(index : Nat, p : Types.Product) : Bool {
                p.productID != productID;
            }
        );
        userBuyersCart := Buffer.toArray(buyersCartBuffer);
        let removed = buyersCartBuffer.size() < beforeSize;
        Debug.print("User " # userName # " removed product from cart: " # debug_show (productID) # " Success: " # debug_show (removed));
    };

    public func clearCart() : async () {
        buyersCartBuffer.clear();
        userBuyersCart := [];
        Debug.print("User " # userName # " cleared cart");
    };

    public query func getBuyersCart() : async [Types.Product] {
        Debug.print("Retrieved cart for user " # userName # ": " # debug_show (userBuyersCart.size()) # " items");
        return userBuyersCart;
    };
};
