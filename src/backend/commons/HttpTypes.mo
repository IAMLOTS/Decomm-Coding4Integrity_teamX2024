module HttpTypes {
    //HTTP Outcalls Types
    public type Cycles = Nat;

    public let HTTP_REQUEST_CYCLES_COST : Cycles = 20_949_972_000;

    public type HttpRequestArgs = {
        url : Text;
        max_response_bytes : ?Nat64;
        headers : [HttpHeader];
        body : ?[Nat8];
        method : HttpMethod;
        transform : ?TransformRawResponseFunction;
    };

    public type HttpHeader = {
        name : Text;
        value : Text;
    };

    public type HttpMethod = {
        #get;
        #post;
        #head;
    };

    public type HttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

    public type TransformRawResponseFunction = {
        function : shared query TransformArgs -> async HttpResponsePayload;
        context : Blob;
    };

    public type TransformArgs = {
        response : HttpResponsePayload;
        context : Blob;
    };

    public type CanisterHttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

    public type TransformContext = {
        function : shared query TransformArgs -> async HttpResponsePayload;
        context : Blob;
    };

    public type IC = actor {
        http_request : HttpRequestArgs -> async HttpResponsePayload;
    };

    //Assets.mo Types

    public type HeaderField = (Text, Text);

    public type Chunk = {
        batch_name : Text;
        content : [Nat8];
    };

    public type Asset = {
        encoding : AssetEncoding;
        content_type : Text;
    };

    public type AssetEncoding = {
        modified : Int;
        content_chunks : [[Nat8]];
        total_length : Nat;
        certified : Bool;
    };

    public type HttpRequest = {
        url : Text;
        method : Text;
        body : [Nat8];
        headers : [HeaderField];
    };

    public type HttpResponse = {
        body : [Nat8];
        headers : [HeaderField];
        status_code : Nat16;
        streaming_strategy : ?StreamingStrategy;
    };

    public type StreamingStrategy = {
        #Callback : {
            token : StreamingCallbackToken;
            callback : shared () -> async ();
        };
    };

    public type StreamingCallbackToken = {
        key : Text;
        index : Nat;
        content_encoding : Text;
    };

    public type StreamingCallbackHttpResponse = {
        body : [Nat8];
        token : ?StreamingCallbackToken;
    };
};
