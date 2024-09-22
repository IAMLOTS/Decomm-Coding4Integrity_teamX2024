import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";

import HttpTypes "../commons/HttpTypes";
import JSON "../commons/json/JSON";

actor class HttpOutcalls<system>() {

    public type Rate = { currency : Text; rate : Text };

    public func getConfirmationDetails(txidHash : Text) : async [Rate] {
        let ic : HttpTypes.IC = actor ("aaaaa-aa");

        let host : Text = "api.coinbase.com";
        let url = "https://" # host # "/v2/exchange-rates?currency=" # txidHash;

        let requestHeaders = [
            { name = "Host"; value = host # ":443" },
        ];

        let transformContext : HttpTypes.TransformContext = {
            function = transform;
            context = Blob.fromArray([]);
        };

        let httpRequest : HttpTypes.HttpRequestArgs = {
            url = url;
            max_response_bytes = null;
            headers = requestHeaders;
            body = null;
            method = #get;
            transform = ?transformContext;
        };

        Cycles.add<system>(HttpTypes.HTTP_REQUEST_CYCLES_COST);

        let httpResponse : HttpTypes.HttpResponsePayload = await ic.http_request(httpRequest);

        let responseBody : Blob = Blob.fromArray(httpResponse.body);
        let decodedResponse = switch (Text.decodeUtf8(responseBody)) {
            case (null) { throw Error.reject("Transaction Not Found!") };
            case (?decoded_text) { decoded_text };
        };
        await parseCurrencyRates(decodedResponse);

    };

    public query func transform(raw : HttpTypes.TransformArgs) : async HttpTypes.CanisterHttpResponsePayload {
        let transformed : HttpTypes.CanisterHttpResponsePayload = {
            status = raw.response.status;
            body = raw.response.body;
            headers = [
                {
                    name = "Content-Security-Policy";
                    value = "default-src 'self'";
                },
                { name = "Referrer-Policy"; value = "strict-origin" },
                { name = "Permissions-Policy"; value = "geolocation=(self)" },
                {
                    name = "Strict-Transport-Security";
                    value = "max-age=63072000";
                },
                { name = "X-Frame-Options"; value = "DENY" },
                { name = "X-Content-Type-Options"; value = "nosniff" },
            ];
        };
        transformed;
    };

    private func parseCurrencyRates(jsonText : Text) : async [Rate] {
        let jsonResponse : JSON.JSON = switch (JSON.parse(jsonText)) {
            case (?jsonResponse) { jsonResponse };
            case (null) { throw Error.reject("Not Valid JSON Response") };
        };
        var rating = Buffer.Buffer<Rate>(0);

        switch (jsonResponse) {
            case (#Object(jsonResponse)) {
                for ((key, value) in jsonResponse.vals()) {
                    if (Text.equal(key, "data")) {
                        switch (value) {
                            case (#Object(data)) {
                                for ((k, v) in data.vals()) {
                                    if (Text.equal(k, "rates")) {
                                        switch (v) {
                                            case (#Object(rates)) {
                                                for ((currency, rate) in rates.vals()) {
                                                    switch (rate) {
                                                        case (#String(rate)) {
                                                            rating.add({
                                                                currency = currency;
                                                                rate = rate;
                                                            });
                                                        };
                                                        case (_) {};
                                                    };
                                                };
                                            };
                                            case (_) {};
                                        };
                                    };
                                };
                            };
                            case (_) {};
                        };
                    };
                };
            };
            case (_) { throw Error.reject("Not Valid JSON Response") };
        };

        // Return the parsed rates
        Buffer.toArray(rating);
    };
};
