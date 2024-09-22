import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; thash } "mo:map/Map";

import Types "../commons/HttpTypes";

actor Assets {

    private var nextChunkID : Nat = 0;

    private let chunks : Map.Map<Nat, Types.Chunk> = Map.new<Nat, Types.Chunk>();
    private let assets : Map.Map<Text, Types.Asset> = Map.new<Text, Types.Asset>();

    public func check_unique(name : Text) : async Bool {
        let key = Text.concat("/assets/", name);
        switch (Map.get<Text, Types.Asset>(assets, thash, key)) {
            case null { true };
            case (?_) { false };
        };
    };

    public shared query ({ caller = _ }) func http_request(
        request : Types.HttpRequest
    ) : async Types.HttpResponse {

        if (request.method == "GET") {
            let split : Iter.Iter<Text> = Text.split(request.url, #char '?');
            let key : Text = Iter.toArray(split)[0];

            let asset : ?Types.Asset = Map.get<Text, Types.Asset>(assets, thash, key);

            switch (asset) {
                case (?{ content_type : Text; encoding : Types.AssetEncoding }) {
                    return {
                        body = encoding.content_chunks[0];
                        headers = [
                            ("Content-Type", content_type),
                            ("accept-ranges", "bytes"),
                            ("cache-control", "private, max-age=0"),
                        ];
                        status_code = 200;
                        streaming_strategy = create_strategy(
                            key,
                            0,
                            { content_type; encoding },
                            encoding,
                        );
                    };
                };
                case null {};
            };
        };

        return {
            body = Blob.toArray(Text.encodeUtf8("Permission denied. Could not perform this operation"));
            headers = [];
            status_code = 403;
            streaming_strategy = null;
        };
    };

    private func create_strategy(
        key : Text,
        index : Nat,
        _asset : Types.Asset,
        encoding : Types.AssetEncoding,
    ) : ?Types.StreamingStrategy {
        switch (create_token(key, index, encoding)) {
            case (null) { null };
            case (?token) {
                let self : Principal = Principal.fromActor(Assets);
                let canisterId : Text = Principal.toText(self);
                let canister = actor (canisterId) : actor {
                    http_request_streaming_callback : shared () -> async ();
                };

                return ? #Callback({
                    token;
                    callback = canister.http_request_streaming_callback;
                });
            };
        };
    };

    public shared query ({ caller = _ }) func http_request_streaming_callback(
        st : Types.StreamingCallbackToken
    ) : async Types.StreamingCallbackHttpResponse {

        switch (Map.get<Text, Types.Asset>(assets, thash, st.key)) {
            case (null) throw Error.reject("key not found: " # st.key);
            case (?asset) {
                return {
                    token = create_token(
                        st.key,
                        st.index,
                        asset.encoding,
                    );
                    body = asset.encoding.content_chunks[st.index];
                };
            };
        };
    };

    private func create_token(
        key : Text,
        chunk_index : Nat,
        encoding : Types.AssetEncoding,
    ) : ?Types.StreamingCallbackToken {

        if (chunk_index + 1 >= encoding.content_chunks.size()) {
            null;
        } else {
            ?{
                key;
                index = chunk_index + 1;
                content_encoding = "gzip";
            };
        };
    };

    public shared ({ caller = _ }) func create_chunk(chunk : Types.Chunk) : async {
        chunk_id : Nat;
    } {
        nextChunkID := nextChunkID + 1;
        Map.set(chunks, nhash, nextChunkID, chunk);
        return { chunk_id = nextChunkID };
    };

    public shared ({ caller = _ }) func commit_batch(
        { batch_name : Text; chunk_ids : [Nat]; content_type : Text } : {
            batch_name : Text;
            content_type : Text;
            chunk_ids : [Nat];
        }
    ) : async () {
        var content_chunks : [[Nat8]] = [];

        for (chunk_id in chunk_ids.vals()) {
            let chunk : ?Types.Chunk = Map.get(chunks, nhash, chunk_id);

            switch (chunk) {
                case (?{ content }) {
                    content_chunks := Array.append<[Nat8]>(content_chunks, [content]);
                };
                case null {};
            };
        };

        if (content_chunks.size() > 0) {
            var total_length = 0;
            for (chunk in content_chunks.vals()) total_length += chunk.size();

            Map.set(
                assets,
                thash,
                Text.concat("/assets/", batch_name),
                {
                    content_type = content_type;
                    encoding = {
                        modified = Time.now();
                        content_chunks;
                        certified = false;
                        total_length;
                    };
                },
            );
        };
    };
};
