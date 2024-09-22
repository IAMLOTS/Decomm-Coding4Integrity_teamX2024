import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import Types "../commons/Types";

actor class Product(
    sellerID : Text,
    name : Text,
    category : Text,
    price : Types.Price,
    shortDesc : Text,
    longDesc : Text,
    isVisible : Bool,
    picture : Text,
    productIDNum : Nat,
) {

    var productSellerID : Text = sellerID;
    var productName : Text = name;
    var productCategory : Text = category;
    var productPrice : Types.Price = price;
    var productShortDesc : Text = shortDesc;
    var productLongDesc : Text = longDesc;
    var prosuctIsVisible : Bool = isVisible;
    var productPicture : Text = picture;
    var productID : Nat = productIDNum;
    var isSold : Bool = false;

    public query func getProductID() : async Nat {
        return productID;
    };

    public query func getSellerID() : async Text {
        return productSellerID;
    };

    public query func getName() : async Text {
        return productName;
    };

    public query func getCategory() : async Text {
        return productCategory;
    };

    public query func getPicture() : async Text {
        return productPicture;
    };

    public query func getPrice() : async Types.Price {
        return productPrice;
    };

    public query func getShortDesc() : async Text {
        return productShortDesc;
    };

    public query func getLongDesc() : async Text {
        return productLongDesc;
    };

    public query func getIsSold() : async Bool {
        return isSold;
    };

    public query func getIsVisible() : async Bool {
        return isVisible;
    };

    public func setName(newName : Text) : async () {
        productName := newName;
    };

    public func setPrice(newPrice : Types.Price) : async () {
        productPrice := newPrice;
    };

    public func setShortDesc(newShortDesc : Text) : async () {
        productShortDesc := newShortDesc;
    };

    public func setLongDesc(newLongDesc : Text) : async () {
        productLongDesc := newLongDesc;
    };

    public func setCategory(newCategory : Text) : async () {
        productCategory := newCategory;
    };

    public func setPicture(picture : Text) : async () {
        productPicture := picture;
    };

    public func updateStatus() : async () {
        isSold := true;
    };

    public func setIsVisible(visiblity : Bool) : async () {
        prosuctIsVisible := visiblity;
    };

    public query func setProductID(productid : Nat) : async () {
        productID := productid;
    };
};
