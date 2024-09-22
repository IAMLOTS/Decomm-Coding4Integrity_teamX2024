import Main "canister:backend";

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import Types "../commons/Types";
import Product "../main/Product";
import Transaction "../main/Transaction";
import User "../main/User";

actor class sortingFiltering() {
    type ProductTypeShared = Types.Product;
    type Product = Product.Product;
    type TransactionTypeShared = Types.Transaction;
    type Transaction = Transaction.Transaction;
    type UserTypeShared = Types.User;
    type User = User.User;

    stable var productAmountArrayASC : [ProductTypeShared] = [];
    stable var productAmountArrayDESC : [ProductTypeShared] = [];
    stable var productIDArrayASC : [ProductTypeShared] = [];
    stable var productIDArrayDESC : [ProductTypeShared] = [];
    stable var productNameArrayASC : [ProductTypeShared] = [];
    stable var productNameArrayDESC : [ProductTypeShared] = [];

    stable var transactionAmountArrayASC : [TransactionTypeShared] = [];
    stable var transactionAmountArrayDESC : [TransactionTypeShared] = [];
    stable var transactionIDArrayASC : [TransactionTypeShared] = [];
    stable var transactionIDArrayDESC : [TransactionTypeShared] = [];
    stable var transactionBuyerArrayASC : [TransactionTypeShared] = [];
    stable var transactionBuyerArrayDESC : [TransactionTypeShared] = [];

    stable var _amountArrayASC : [UserTypeShared] = [];
    stable var _amountArrayDESC : [UserTypeShared] = [];
    stable var iDArrayASC : [UserTypeShared] = [];
    stable var iDArrayDESC : [UserTypeShared] = [];

    //Product Filtering

    public func productFilterGetAllProductsSubset(pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let reversedTotalProducts = await Main.getAllProducts();
        let totalProducts = Array.size(reversedTotalProducts);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };
        var endIndex = Nat.min(startIndex + pageSize, totalProducts);
        if (startIndex >= totalProducts) {
            let outOfBoundsArray = await productFilteringGetProductTypeListFromNonNullable(reversedTotalProducts);
            return outOfBoundsArray;
        };

        let filteredReversedArray = Iter.toArray(Array.slice(reversedTotalProducts, startIndex, endIndex));
        return await productFilteringGetProductTypeListFromNonNullable(filteredReversedArray);
    };

    public func productFilteringGetAllProductsSubsetArrayArgs(filteredSliced : [ProductTypeShared], pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let totalProducts = Array.size(filteredSliced);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };
        var endIndex = Nat.min(startIndex + pageSize, totalProducts);
        if (startIndex >= totalProducts) {
            return filteredSliced;
        };

        let filteredReversedArray = Iter.toArray(Array.slice(filteredSliced, startIndex, endIndex));
        return filteredReversedArray;
    };

    public func getAllProductTypes(pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let slicedProducts = await productFilterGetAllProductsSubset(pageNumber, pageSize);
        return slicedProducts;
    };

    public func filterBySellerID(sellerID : Text, pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let products = await getAllProductTypes(pageNumber, pageSize);
        let filtered = Iter.filter<ProductTypeShared>(
            products.vals(),
            func(product : ProductTypeShared) : Bool {
                return (Text.equal(product.sellerID, sellerID));
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await productFilteringGetAllProductsSubsetArrayArgs(filteredArray, pageNumber, pageSize);
        };
        return await productFilteringGetAllProductsSubsetArrayArgs([], pageNumber, pageSize);
    };

    public func filterByCategory(category : Text, pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let products = await getAllProductTypes(pageNumber, pageSize);
        let filtered = Iter.filter<ProductTypeShared>(
            products.vals(),
            func(product : ProductTypeShared) : Bool {
                return (Text.equal(product.productCategory, category));
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await productFilteringGetAllProductsSubsetArrayArgs(filteredArray, pageNumber, pageSize);
        };
        return await productFilteringGetAllProductsSubsetArrayArgs([], pageNumber, pageSize);
    };

    public func productFilterByPriceRange(minPrice : Nat, maxPrice : Nat, _currency : Types.Currency, pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let products = await getAllProductTypes(pageNumber, pageSize);
        let filtered = Iter.filter<ProductTypeShared>(
            products.vals(),
            func(product : ProductTypeShared) : Bool {
                // Add currency conversion code if needed
                return product.productPrice.amount >= minPrice and product.productPrice.amount <= maxPrice;
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await productFilteringGetAllProductsSubsetArrayArgs(filteredArray, pageNumber, pageSize);
        };
        return await productFilteringGetAllProductsSubsetArrayArgs([], pageNumber, pageSize);
    };

    public func productFilterByName(name : Text, pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let products = await getAllProductTypes(pageNumber, pageSize);
        let filtered = Iter.filter<ProductTypeShared>(
            products.vals(),
            func(product : ProductTypeShared) : Bool {
                return (Text.equal(product.name, name));
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await productFilteringGetAllProductsSubsetArrayArgs(filteredArray, pageNumber, pageSize);
        };
        return await productFilteringGetAllProductsSubsetArrayArgs([], pageNumber, pageSize);
    };

    // Helper functions
    public func productFilteringGetProductTypeListFromNonNullable(products : [Product.Product]) : async [ProductTypeShared] {
        let productTypeBuffer = Buffer.Buffer<ProductTypeShared>(0);
        for (product in products.vals()) {
            productTypeBuffer.add(await Main.convertProductToType(product));
        };
        return Buffer.toArray(productTypeBuffer);
    };

    //Transaction Filtering
    public func getAllTransactionsSubsetFiltering(pageNumber : Nat, pageSize : Nat) : async [TransactionTypeShared] {
        let reversedTotalTransactions = await Main.getAllTransactions();
        let totalTransactions = Array.size(reversedTotalTransactions);

        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };

        var endIndex = Nat.min(startIndex + pageSize, totalTransactions);
        if (startIndex >= totalTransactions) {
            let outOfBoundsArray = await getTransactionTypeListFromNonNullableFiltering(reversedTotalTransactions);
            return outOfBoundsArray;
        };

        let filteredReversedArray = Iter.toArray(Array.slice(reversedTotalTransactions, startIndex, endIndex));
        return await getTransactionTypeListFromNonNullableFiltering(filteredReversedArray);
    };

    public func getAllTransactionsSubsetArrayArgsFiltering(filteredSliced : [TransactionTypeShared], pageNumber : Nat, pageSize : Nat) : async [TransactionTypeShared] {
        let totalTransactions = Array.size(filteredSliced);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };
        var endIndex = Nat.min(startIndex + pageSize, totalTransactions);
        if (startIndex >= totalTransactions) {
            return filteredSliced;
        };

        let filteredReversedArray = Iter.toArray(Array.slice(filteredSliced, startIndex, endIndex));
        return filteredReversedArray;
    };

    public func getAllTransactionTypes(pageNumber : Nat, pageSize : Nat) : async [TransactionTypeShared] {
        let slicedTransactions = await getAllTransactionsSubsetFiltering(pageNumber, pageSize);
        return slicedTransactions;
    };

    public func filterByBuyerID(buyerID : Text, pageNumber : Nat, pageSize : Nat) : async [TransactionTypeShared] {
        let transactions = await getAllTransactionTypes(pageNumber, pageSize);
        let filtered = Iter.filter<TransactionTypeShared>(
            transactions.vals(),
            func(transaction : TransactionTypeShared) : Bool {
                return (Text.equal(transaction.buyerID, buyerID));
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await getAllTransactionsSubsetArrayArgsFiltering(filteredArray, pageNumber, pageSize);
        };
        return await getAllTransactionsSubsetArrayArgsFiltering([], pageNumber, pageSize);
    };

    public func filterByProductID(productID : Nat, pageNumber : Nat, pageSize : Nat) : async [TransactionTypeShared] {
        let transactions = await getAllTransactionTypes(pageNumber, pageSize);
        let filtered = Iter.filter<TransactionTypeShared>(
            transactions.vals(),
            func(transaction : TransactionTypeShared) : Bool {
                return transaction.productID == productID;
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await getAllTransactionsSubsetArrayArgsFiltering(filteredArray, pageNumber, pageSize);
        };
        return await getAllTransactionsSubsetArrayArgsFiltering([], pageNumber, pageSize);
    };

    public func transactionFilterByPriceRange(minPrice : Nat, maxPrice : Nat, _currency : Types.Currency, pageNumber : Nat, pageSize : Nat) : async [TransactionTypeShared] {
        let transactions = await getAllTransactionTypes(pageNumber, pageSize);
        let filtered = Iter.filter<TransactionTypeShared>(
            transactions.vals(),
            func(transaction : TransactionTypeShared) : Bool {
                //add curr conversion code
                return transaction.paidPrice.amount >= minPrice and transaction.paidPrice.amount <= maxPrice;
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await getAllTransactionsSubsetArrayArgsFiltering(filteredArray, pageNumber, pageSize);
        };
        return await getAllTransactionsSubsetArrayArgsFiltering([], pageNumber, pageSize);
    };

    // // Helper functions
    public func getTransactionTypeListFromNonNullableFiltering(transactions : [Transaction.Transaction]) : async [TransactionTypeShared] {
        let transactionTypeBuffer = Buffer.Buffer<TransactionTypeShared>(0);
        for (transaction in transactions.vals()) {
            transactionTypeBuffer.add(await Main.convertTransactionToType(transaction));
        };
        return Buffer.toArray(transactionTypeBuffer);
    };

    //User Filtering

    public func getAllUsersSubsetFiltering(pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let reversedTotalUsers = await Main.getAllUsers();
        let totalUsers = Array.size(reversedTotalUsers);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };

        var endIndex = Nat.min(startIndex + pageSize, totalUsers);
        if (startIndex >= totalUsers) {
            let outOfBoundsArray = await getUserTypeListFromNonNullableFiltering(reversedTotalUsers);
            return outOfBoundsArray;
        };

        let filteredReversedArray = Iter.toArray(Array.slice(reversedTotalUsers, startIndex, endIndex));
        return await getUserTypeListFromNonNullableFiltering(filteredReversedArray);
    };

    public func getCountOfAllUsers() : async Nat {
        let array = await Main.getAllUsers();
        return array.size();
    };

    public func getAllUsersSubsetArrayArgsFiltering(filteredSliced : [UserTypeShared], pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let totalUsers = Array.size(filteredSliced);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };

        var endIndex = Nat.min(startIndex + pageSize, totalUsers);
        if (startIndex >= totalUsers) {
            return filteredSliced;
        };

        let filteredReversedArray = Iter.toArray(Array.slice(filteredSliced, startIndex, endIndex));
        return filteredReversedArray;
    };

    public func getAllUserTypesFiltering(pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let slicedUsers = await getAllUsersSubsetFiltering(pageNumber, pageSize);
        return slicedUsers;
    };

    public func userFilterByName(name : Text, pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let users = await getAllUserTypesFiltering(pageNumber, pageSize);
        let filtered = Iter.filter<UserTypeShared>(
            users.vals(),
            func(user : UserTypeShared) : Bool {
                return (Text.equal(user.name, name));
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await getAllUsersSubsetArrayArgsFiltering(filteredArray, pageNumber, pageSize);
        };
        return await getAllUsersSubsetArrayArgsFiltering([], pageNumber, pageSize);
    };

    public func filterByProductInCart(productID : Nat, pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let users = await getAllUserTypesFiltering(pageNumber, pageSize);
        let filtered = Iter.filter<UserTypeShared>(
            users.vals(),
            func(user : UserTypeShared) : Bool {
                var found = false;
                for (product in user.buyersCart.vals()) {
                    if (product.productID == productID) {
                        found := true;
                        return found;
                    };
                };
                return found;
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await getAllUsersSubsetArrayArgsFiltering(filteredArray, pageNumber, pageSize);
        };
        return await getAllUsersSubsetArrayArgsFiltering([], pageNumber, pageSize);
    };

    public func filterByProductInStock(productID : Nat, pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let users = await getAllUserTypesFiltering(pageNumber, pageSize);
        let filtered = Iter.filter<UserTypeShared>(
            users.vals(),
            func(user : UserTypeShared) : Bool {
                var found = false;
                for (product in user.sellersStock.vals()) {
                    if (product.productID == productID) {
                        found := true;
                        return found;
                    };
                };
                return found;
            },
        );
        let filteredArray = Iter.toArray(filtered);
        if (Array.size(filteredArray) != 0) {
            return await getAllUsersSubsetArrayArgsFiltering(filteredArray, pageNumber, pageSize);
        };
        return await getAllUsersSubsetArrayArgsFiltering([], pageNumber, pageSize);
    };

    // Helper functions
    public func getUserTypeListFromNonNullableFiltering(users : [User.User]) : async [UserTypeShared] {
        let userTypeBuffer = Buffer.Buffer<UserTypeShared>(0);
        for (user in users.vals()) {
            userTypeBuffer.add(await Main.convertUserToType(user));
        };
        return Buffer.toArray(userTypeBuffer);
    };

    //Product Sorting
    public func productSortingGetAllProductsSubset(pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let reversedTotalProducts = await Main.getAllProducts();
        let totalProducts = Array.size(reversedTotalProducts);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };

        var endIndex = Nat.min(startIndex + pageSize, totalProducts);
        if (startIndex >= totalProducts) {
            let outOfBoundsArray = productFilteringGetProductTypeListFromNonNullable(reversedTotalProducts);
            return await outOfBoundsArray;
        };

        let sortedReversedArray = Iter.toArray(Array.slice(reversedTotalProducts, startIndex, endIndex));
        return await productFilteringGetProductTypeListFromNonNullable(sortedReversedArray);
    };

    public func getCountOfAllProducts() : async Nat {
        let array = await Main.getAllProducts();
        return array.size();
    };

    public func productSortingGetAllProductsSubsetArrayArgs(sortedSliced : [ProductTypeShared], pageNumber : Nat, pageSize : Nat) : async [ProductTypeShared] {
        let totalProducts = Array.size(sortedSliced);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };

        var endIndex = Nat.min(startIndex + pageSize, totalProducts);
        if (startIndex >= totalProducts) {
            return sortedSliced;
        };

        let sortedReversedArray = Iter.toArray(Array.slice(sortedSliced, startIndex, endIndex));
        return sortedReversedArray;
    };

    public func mapSortingArrayProduct(array : [ProductTypeShared], sortField : Text, isAscending : Bool, productArray : [ProductTypeShared]) : async [ProductTypeShared] {
        if (array.size() != productArray.size()) {
            switch (sortField, isAscending) {
                case ("ID", true) {
                    productIDArrayASC := productArray;
                    return productIDArrayASC;
                };
                case ("ID", false) {
                    productIDArrayDESC := productArray;
                    return productIDArrayDESC;
                };
                case ("Price#kt" or "Price#usd" or "Price#gbp" or "Price#eur", true) {
                    productAmountArrayASC := productArray;
                    return productAmountArrayASC;
                };
                case ("Price#kt" or "Price#usd" or "Price#gbp" or "Price#eur", false) {
                    productAmountArrayDESC := productArray;
                    return productAmountArrayDESC;
                };
                case ("Name", true) {
                    productNameArrayASC := productArray;
                    return productNameArrayASC;
                };
                case ("Name", false) {
                    productNameArrayDESC := productArray;
                    return productNameArrayDESC;
                };

                case (_, _) { return productArray };
            };
        } else {
            return array;
        };
    };

    public func updateSortingArrayProduct(array : [ProductTypeShared], sortField : Text, isAscending : Bool, productArray : [ProductTypeShared]) : async [ProductTypeShared] {
        let _productArrayCase : [ProductTypeShared] = switch (sortField, isAscending) {
            case ("ID", true) {
                productIDArrayASC := array;
                return productIDArrayASC;
            };
            case ("ID", false) {
                productIDArrayDESC := array;
                return productIDArrayDESC;
            };
            case ("Price#kt" or "Price#usd" or "Price#gbp" or "Price#eur", true) {
                productAmountArrayASC := array;
                return productAmountArrayASC;
            };
            case ("Price#kt" or "Price#usd" or "Price#gbp" or "Price#eur", false) {
                productAmountArrayDESC := array;
                return productAmountArrayDESC;
            };
            case ("Name", true) {
                productNameArrayASC := array;
                return productNameArrayASC;
            };
            case ("Name", false) {
                productNameArrayDESC := array;
                return productNameArrayDESC;
            };
            case (_, _) {
                return productArray;
            };
        };
    };

    public func getSortedArrayProduct(sortField : Text, isAscending : Bool, productArray : [ProductTypeShared]) : async [ProductTypeShared] {
        let sortedArray : [ProductTypeShared] = switch (sortField, isAscending) {
            case ("ID", true) { productIDArrayASC };
            case ("ID", false) { productIDArrayDESC };
            case ("Price#kt" or "Price#usd" or "Price#gbp" or "Price#eur", true) {
                productAmountArrayASC;
            };
            case ("Price#kt" or "Price#usd" or "Price#gbp" or "Price#eur", false) {
                productAmountArrayDESC;
            };
            case ("Name", true) { productNameArrayASC };
            case ("Name", false) { productNameArrayDESC };
            case (_, _) { productArray };
        };
        return sortedArray;
    };

    private func mergeProduct<T>(left : [T], right : [T], isAscending : Bool, compareFunc : (T, T) -> Bool) : [T] {
        var result = Buffer.Buffer<T>(0);
        var i = 0;
        var j = 0;

        while (i < left.size() and j < right.size()) {
            var shouldAppendLeft : Bool = false;

            if (isAscending) {
                shouldAppendLeft := compareFunc(left[i], right[j]);
            } else {
                shouldAppendLeft := compareFunc(right[j], left[i]);
            };

            if (shouldAppendLeft) {
                result.add(left[i]);
                i += 1;
            } else {
                result.add(right[j]);
                j += 1;
            };
        };

        while (i < left.size()) {
            result.add(left[i]);
            i += 1;
        };

        while (j < right.size()) {
            result.add(right[j]);
            j += 1;
        };

        let comparedArray = Buffer.toArray<T>(result);
        return comparedArray;
    };

    private func mergeSortProduct<T>(array : [ProductTypeShared], isAscending : Bool, compareFunc : (ProductTypeShared, ProductTypeShared) -> Bool) : async [ProductTypeShared] {
        if (Array.size(array) <= 1) {
            return array;
        };

        let mid : Nat = Array.size(array) / 2;
        let left = await mergeSortProduct(Iter.toArray(Array.slice(array, 0, mid)), isAscending, compareFunc);
        let right = await mergeSortProduct(Iter.toArray(Array.slice(array, mid, Array.size(array))), isAscending, compareFunc);

        return mergeProduct(left, right, isAscending, compareFunc);
    };

    public func sortProductTypes(pageNumber : Nat, pageSize : Nat, sortField : Text, isAscending : Bool) : async [ProductTypeShared] {
        let reversedTotalProducts = await productSortingGetProductTypeListFromNonNullable(await Main.getAllProducts());
        let caseArray = await getSortedArrayProduct(sortField, isAscending, reversedTotalProducts);

        if (reversedTotalProducts.size() != caseArray.size()) {
            let sortedMappedCaseArray = await mapSortingArrayProduct(caseArray, sortField, isAscending, reversedTotalProducts);
            let compareFunc = func(t1 : ProductTypeShared, t2 : ProductTypeShared) : Bool {
                switch (sortField) {
                    case ("ID") {
                        return getIdFromProduct(t1) < getIdFromProduct(t2);
                    };
                    case ("Buyer") {
                        return getBuyerIDFromProduct(t1) < getBuyerIDFromProduct(t2);
                    };
                    case ("Price#kt") {
                        return getPaidPricePerCurrencyProduct(t1, #kt) < getPaidPricePerCurrencyProduct(t2, #kt);
                    };
                    case ("Price#eur") {
                        return getPaidPricePerCurrencyProduct(t1, #eur) < getPaidPricePerCurrencyProduct(t2, #eur);
                    };
                    case ("Price#usd") {
                        return getPaidPricePerCurrencyProduct(t1, #usd) < getPaidPricePerCurrencyProduct(t2, #usd);
                    };
                    case ("Price#gbp") {
                        return getPaidPricePerCurrencyProduct(t1, #gbp) < getPaidPricePerCurrencyProduct(t2, #gbp);
                    };
                    case ("Name") {
                        return getNameFromProduct(t1) < getNameFromProduct(t2);
                    };
                    case (_) { false };
                };
            };
            let sortedSlice = await mergeSortProduct(sortedMappedCaseArray, isAscending, compareFunc);
            let replaceValues = await updateSortingArrayProduct(sortedSlice, sortField, isAscending, reversedTotalProducts);
            let slicedProducts = await productSortingGetAllProductsSubsetArrayArgs(replaceValues, pageNumber, pageSize);
            return slicedProducts;
        } else {
            return await productSortingGetAllProductsSubsetArrayArgs(caseArray, pageNumber, pageSize);
        };
    };

    //HELPER FUNCTIONS
    public func productSortingGetProductTypeListFromNonNullable(products : [Product]) : async [ProductTypeShared] {
        let productTypeBuffer = Buffer.Buffer<ProductTypeShared>(0);
        for (product in products.vals()) {
            productTypeBuffer.add(await Main.convertProductToType(product));
        };
        return Buffer.toArray(productTypeBuffer);
    };

    private func getIdFromProduct(product : ProductTypeShared) : Nat {
        return product.productID;
    };

    private func getNameFromProduct(product : ProductTypeShared) : Text {
        return product.name;
    };

    private func getBuyerIDFromProduct(product : ProductTypeShared) : Text {
        return product.sellerID;
    };

    private func getPaidPricePerCurrencyProduct(product : ProductTypeShared, _currency : Types.Currency) : Float {
        //function to get the rate to the wanted currency (maybe use the http call)
        return Float.fromInt(product.productPrice.amount);

    };

    //Transaction Sorting
    public func getAllTransactionsSubsetSorting(pageNumber : Nat, pageSize : Nat) : async [TransactionTypeShared] {
        let reversedTotalTransactions = await Main.getAllTransactions();
        let totalTransactions = Array.size(reversedTotalTransactions);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };

        var endIndex = Nat.min(startIndex + pageSize, totalTransactions);
        if (startIndex >= totalTransactions) {
            let outOfBoundsArray = getTransactionTypeListFromNonNullableSorting(reversedTotalTransactions);
            return await outOfBoundsArray;
        };

        let sortedReversedArray = Iter.toArray(Array.slice(reversedTotalTransactions, startIndex, endIndex));
        return await getTransactionTypeListFromNonNullableSorting(sortedReversedArray);
    };

    public func getCountOfAllTransactions() : async Nat {
        let array = await Main.getAllTransactions();
        return array.size();
    };

    public func getAllTransactionsSubsetArrayArgsSorting(sortedSliced : [TransactionTypeShared], pageNumber : Nat, pageSize : Nat) : async [TransactionTypeShared] {
        let totalTransactions = Array.size(sortedSliced);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };
        var endIndex = Nat.min(startIndex + pageSize, totalTransactions);
        if (startIndex >= totalTransactions) {
            return sortedSliced;
        };

        let sortedReversedArray = Iter.toArray(Array.slice(sortedSliced, startIndex, endIndex));
        return sortedReversedArray;
    };

    public func mapSortingArrayTransaction(array : [TransactionTypeShared], sortField : Text, isAscending : Bool, transactionArray : [TransactionTypeShared]) : async [TransactionTypeShared] {
        if (array.size() != transactionArray.size()) {
            switch (sortField, isAscending) {
                case ("ID", true) {
                    transactionIDArrayASC := transactionArray;
                    return transactionIDArrayASC;
                };
                case ("ID", false) {
                    transactionIDArrayDESC := transactionArray;
                    return transactionIDArrayDESC;
                };
                case ("PricePaid#kt" or "PricePaid#usd" or "PricePaid#gbp" or "PricePaid#eur", true) {
                    transactionAmountArrayASC := transactionArray;
                    return transactionAmountArrayASC;
                };
                case ("PricePaid#kt" or "PricePaid#usd" or "PricePaid#gbp" or "PricePaid#eur", false) {
                    transactionAmountArrayDESC := transactionArray;
                    return transactionAmountArrayDESC;
                };
                case ("Buyer", true) {
                    transactionBuyerArrayASC := transactionArray;
                    return transactionBuyerArrayASC;
                };
                case ("Buyer", false) {
                    transactionBuyerArrayDESC := transactionArray;
                    return transactionBuyerArrayDESC;
                };
                case (_, _) { return transactionArray };
            };
        } else {
            return array;
        };
    };

    public func updateSortingArrayTransaction(array : [TransactionTypeShared], sortField : Text, isAscending : Bool, transactionArray : [TransactionTypeShared]) : async [TransactionTypeShared] {
        let _transactionArrayCase : [TransactionTypeShared] = switch (sortField, isAscending) {
            case ("ID", true) {
                transactionIDArrayASC := array;
                return transactionIDArrayASC;
            };
            case ("ID", false) {
                transactionIDArrayDESC := array;
                return transactionIDArrayDESC;
            };
            case ("PricePaid#kt" or "PricePaid#usd" or "PricePaid#gbp" or "PricePaid#eur", true) {
                transactionAmountArrayASC := array;
                return transactionAmountArrayASC;
            };
            case ("PricePaid#kt" or "PricePaid#usd" or "PricePaid#gbp" or "PricePaid#eur", false) {
                transactionAmountArrayDESC := array;
                return transactionAmountArrayDESC;
            };
            case ("Buyer", true) {
                transactionBuyerArrayASC := array;
                return transactionBuyerArrayASC;
            };
            case ("Buyer", false) {
                transactionBuyerArrayDESC := array;
                return transactionBuyerArrayDESC;
            };
            case (_, _) {
                return transactionArray;
            };
        };
    };

    public func getSortedArrayTransaction(sortField : Text, isAscending : Bool, transactionArray : [TransactionTypeShared]) : async [TransactionTypeShared] {
        let sortedArray : [TransactionTypeShared] = switch (sortField, isAscending) {
            case ("ID", true) { transactionIDArrayASC };
            case ("ID", false) { transactionIDArrayDESC };
            case ("PricePaid#kt" or "PricePaid#usd" or "PricePaid#gbp" or "PricePaid#eur", true) {
                transactionAmountArrayASC;
            };
            case ("PricePaid#kt" or "PricePaid#usd" or "PricePaid#gbp" or "PricePaid#eur", false) {
                transactionAmountArrayDESC;
            };
            case ("Buyer", true) { transactionBuyerArrayASC };
            case ("Buyer", false) { transactionBuyerArrayDESC };
            case (_, _) { transactionArray };
        };
        return sortedArray;
    };

    private func mergeTransaction<T>(left : [T], right : [T], isAscending : Bool, compareFunc : (T, T) -> Bool) : [T] {
        var result = Buffer.Buffer<T>(0);
        var i = 0;
        var j = 0;

        while (i < left.size() and j < right.size()) {
            var shouldAppendLeft : Bool = false;

            if (isAscending) {
                shouldAppendLeft := compareFunc(left[i], right[j]);
            } else {
                shouldAppendLeft := compareFunc(right[j], left[i]);
            };

            if (shouldAppendLeft) {
                result.add(left[i]);
                i += 1;
            } else {
                result.add(right[j]);
                j += 1;
            };
        };

        while (i < left.size()) {
            result.add(left[i]);
            i += 1;
        };

        while (j < right.size()) {
            result.add(right[j]);
            j += 1;
        };

        let comparedArray = Buffer.toArray<T>(result);
        return comparedArray;
    };

    private func mergeSortTransaction<T>(array : [TransactionTypeShared], isAscending : Bool, compareFunc : (TransactionTypeShared, TransactionTypeShared) -> Bool) : async [TransactionTypeShared] {
        if (Array.size(array) <= 1) {
            return array;
        };

        let mid : Nat = Array.size(array) / 2;
        let left = await mergeSortTransaction(Iter.toArray(Array.slice(array, 0, mid)), isAscending, compareFunc);
        let right = await mergeSortTransaction(Iter.toArray(Array.slice(array, mid, Array.size(array))), isAscending, compareFunc);

        return mergeTransaction(left, right, isAscending, compareFunc);
    };

    public func sortTransactionTypes(pageNumber : Nat, pageSize : Nat, sortField : Text, isAscending : Bool) : async [TransactionTypeShared] {
        let reversedTotalTransactions = await getTransactionTypeListFromNonNullableSorting(await Main.getAllTransactions());
        let caseArray = await getSortedArrayTransaction(sortField, isAscending, reversedTotalTransactions);

        if (reversedTotalTransactions.size() != caseArray.size()) {
            let sortedMappedCaseArray = await mapSortingArrayTransaction(caseArray, sortField, isAscending, reversedTotalTransactions);
            let compareFunc = func(t1 : TransactionTypeShared, t2 : TransactionTypeShared) : Bool {
                switch (sortField) {
                    case ("ID") {
                        return getIdFromTransaction(t1) < getIdFromTransaction(t2);
                    };
                    case ("Buyer") {
                        return getBuyerIDFromTransaction(t1) < getBuyerIDFromTransaction(t2);
                    };
                    case ("PricePaid#kt") {
                        return getPaidPricePerCurrencyTransaction(t1, #kt) < getPaidPricePerCurrencyTransaction(t2, #kt);
                    };
                    case ("PricePaid#eur") {
                        return getPaidPricePerCurrencyTransaction(t1, #eur) < getPaidPricePerCurrencyTransaction(t2, #eur);
                    };
                    case ("PricePaid#usd") {
                        return getPaidPricePerCurrencyTransaction(t1, #usd) < getPaidPricePerCurrencyTransaction(t2, #usd);
                    };
                    case ("PricePaid#gbp") {
                        return getPaidPricePerCurrencyTransaction(t1, #gbp) < getPaidPricePerCurrencyTransaction(t2, #gbp);
                    };

                    case (_) { false };
                };
            };
            let sortedSlice = await mergeSortTransaction(sortedMappedCaseArray, isAscending, compareFunc);
            let replaceValues = await updateSortingArrayTransaction(sortedSlice, sortField, isAscending, reversedTotalTransactions);
            let slicedTransactions = await getAllTransactionsSubsetArrayArgsSorting(replaceValues, pageNumber, pageSize);
            return slicedTransactions;
        } else {
            return await getAllTransactionsSubsetArrayArgsSorting(caseArray, pageNumber, pageSize);
        };
    };

    //HELPER FUNCTIONS
    public func getTransactionTypeListFromNonNullableSorting(transactions : [Transaction]) : async [TransactionTypeShared] {
        let transactionTypeBuffer = Buffer.Buffer<TransactionTypeShared>(0);
        for (transaction in transactions.vals()) {
            transactionTypeBuffer.add(await Main.convertTransactionToType(transaction));
        };
        return Buffer.toArray(transactionTypeBuffer);
    };

    private func getIdFromTransaction(transaction : TransactionTypeShared) : Nat {
        return transaction.id;
    };

    private func getBuyerIDFromTransaction(transaction : TransactionTypeShared) : Text {
        return transaction.buyerID;
    };

    private func getPaidPricePerCurrencyTransaction(transaction : TransactionTypeShared, _currency : Types.Currency) : Float {
        //function to get the rate to the wanted currency (maybe use the http call)
        return Float.fromInt(transaction.paidPrice.amount);
    };

    //UserSorting
    public func getAllUsersSubsetSorting(pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let reversedTotalUsers = await Main.getAllUsers();
        let totalUsers = Array.size(reversedTotalUsers);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };
        var endIndex = Nat.min(startIndex + pageSize, totalUsers);
        if (startIndex >= totalUsers) {
            let outOfBoundsArray = getUserTypeListFromNonNullableSorting(reversedTotalUsers);
            return await outOfBoundsArray;
        };

        let sortedReversedArray = Iter.toArray(Array.slice(reversedTotalUsers, startIndex, endIndex));
        return await getUserTypeListFromNonNullableSorting(sortedReversedArray);
    };

    public func getAllUsersSubsetArrayArgsSorting(sortedSliced : [UserTypeShared], pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let totalUsers = Array.size(sortedSliced);
        var startIndex = if (pageNumber > 0) {
            Int.abs((pageNumber - 1) * pageSize);
        } else { 1 };
        var endIndex = Nat.min(startIndex + pageSize, totalUsers);
        if (startIndex >= totalUsers) {
            return sortedSliced;
        };

        let sortedReversedArray = Iter.toArray(Array.slice(sortedSliced, startIndex, endIndex));
        return sortedReversedArray;
    };

    public func getAllUserTypesSorting(pageNumber : Nat, pageSize : Nat) : async [UserTypeShared] {
        let slicedUsers = await getAllUsersSubsetSorting(pageNumber, pageSize);
        return slicedUsers;
    };

    public func mapSortingArray(array : [UserTypeShared], sortField : Text, isAscending : Bool, userArray : [UserTypeShared]) : async [UserTypeShared] {
        if (array.size() != userArray.size()) {
            switch (sortField, isAscending) {
                case ("ID", true) {
                    iDArrayASC := userArray;
                    return iDArrayASC;
                };
                case ("ID", false) {
                    iDArrayDESC := userArray;
                    return iDArrayDESC;
                };

                case (_, _) { return userArray };
            };
        } else {
            return array;
        };
    };

    public func updateSortingArray(array : [UserTypeShared], sortField : Text, isAscending : Bool, userArray : [UserTypeShared]) : async [UserTypeShared] {
        let _userArrayCase : [UserTypeShared] = switch (sortField, isAscending) {
            case ("ID", true) {
                iDArrayASC := array;
                return iDArrayASC;
            };
            case ("ID", false) {
                iDArrayDESC := array;
                return iDArrayDESC;
            };
            case (_, _) {
                return userArray;
            };
        };
    };

    public func getSortedArray(sortField : Text, isAscending : Bool, userArray : [UserTypeShared]) : async [UserTypeShared] {
        let sortedArray : [UserTypeShared] = switch (sortField, isAscending) {
            case ("ID", true) { iDArrayASC };
            case ("ID", false) { iDArrayDESC };
            case (_, _) { userArray };
        };
        return sortedArray;
    };

    private func merge<T>(left : [T], right : [T], isAscending : Bool, compareFunc : (T, T) -> Bool) : [T] {
        var result = Buffer.Buffer<T>(0);
        var i = 0;
        var j = 0;

        while (i < left.size() and j < right.size()) {
            var shouldAppendLeft : Bool = false;

            if (isAscending) {
                shouldAppendLeft := compareFunc(left[i], right[j]);
            } else {
                shouldAppendLeft := compareFunc(right[j], left[i]);
            };

            if (shouldAppendLeft) {
                result.add(left[i]);
                i += 1;
            } else {
                result.add(right[j]);
                j += 1;
            };
        };

        while (i < left.size()) {
            result.add(left[i]);
            i += 1;
        };

        while (j < right.size()) {
            result.add(right[j]);
            j += 1;
        };

        let comparedArray = Buffer.toArray<T>(result);
        return comparedArray;
    };

    private func mergeSort<T>(array : [UserTypeShared], isAscending : Bool, compareFunc : (UserTypeShared, UserTypeShared) -> Bool) : async [UserTypeShared] {
        if (Array.size(array) <= 1) {
            return array;
        };

        let mid : Nat = Array.size(array) / 2;
        let left = await mergeSort(Iter.toArray(Array.slice(array, 0, mid)), isAscending, compareFunc);
        let right = await mergeSort(Iter.toArray(Array.slice(array, mid, Array.size(array))), isAscending, compareFunc);

        return merge(left, right, isAscending, compareFunc);
    };

    public func sortUserTypes(pageNumber : Nat, pageSize : Nat, sortField : Text, isAscending : Bool) : async [UserTypeShared] {
        let reversedTotalUsers = await getUserTypeListFromNonNullableSorting(await Main.getAllUsers());
        let caseArray = await getSortedArray(sortField, isAscending, reversedTotalUsers);

        if (reversedTotalUsers.size() != caseArray.size()) {
            let sortedMappedCaseArray = await mapSortingArray(caseArray, sortField, isAscending, reversedTotalUsers);
            let compareFunc = func(t1 : UserTypeShared, t2 : UserTypeShared) : Bool {
                switch (sortField) {
                    case ("ID") {
                        return getIdFromUser(t1) < getIdFromUser(t2);
                    };

                    case (_) { false };
                };
            };
            let sortedSlice = await mergeSort(sortedMappedCaseArray, isAscending, compareFunc);
            let replaceValues = await updateSortingArray(sortedSlice, sortField, isAscending, reversedTotalUsers);
            let slicedUsers = await getAllUsersSubsetArrayArgsSorting(replaceValues, pageNumber, pageSize);
            return slicedUsers;
        } else {
            return await getAllUsersSubsetArrayArgsSorting(caseArray, pageNumber, pageSize);
        };
    };

    //HELPER FUNCTIONS
    public func getUserTypeListFromNonNullableSorting(users : [User]) : async [UserTypeShared] {
        let userTypeBuffer = Buffer.Buffer<UserTypeShared>(0);
        for (user in users.vals()) {
            userTypeBuffer.add(await Main.convertUserToType(user));
        };
        return Buffer.toArray(userTypeBuffer);
    };

    private func getIdFromUser(user : UserTypeShared) : Text {
        return user.name;
    };
};
