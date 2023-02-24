
// import ballerina/http;
// import ballerina/mime;

// # Object for the SOAP 1.2 client endpoint.
// #
// # + soap12Client - The HTTP client created to send SOAP 1.2 requests.
// public type Soap12Client client object {

//      http:Client soap12Client;

//      function init(string url, http:ClientConfiguration? config = ()) {
//         self.soap12Client = new (url, config = config);
//     }

//     # Sends SOAP 1.2 request and expects a response.
//     #
//     # + soapAction - SOAP action
//     # + body - SOAP request body as an `XML` or `mime:Entity[]` to work with SOAP attachments
//     # + options - SOAP options. E.g., headers, WS-addressing parameters, usernameToken parameters
//     # + return - If successful, returns the response object. Else, returns an error.
//     public remote function sendReceive(xml|mime:Entity[] body, public string? soapAction = (), public Options? options = ())
//     returns @tainted SoapResponse|error {
//         return sendReceive(SOAP12, body, self.soap12Client, soapAction = soapAction, options = options);
//     }

//     # Sends robust SOAP 1.2 requests and possibly receives an error.
//     #
//     # + soapAction - SOAP action
//     # + body - SOAP request body as an `XML` or `mime:Entity[]` to work with SOAP attachments
//     # + options - SOAP options. E.g., headers, WS-addressing parameters, usernameToken parameters
//     # + return - If successful, returns `nil`. Else, returns an error.
//     public remote function sendRobust(xml|mime:Entity[] body, public string? soapAction = (), public Options? options = ())
//     returns error? {
//         return sendRobust(SOAP12, body, self.soap12Client, soapAction = soapAction, options = options);
//     }

//     # Fire and forget requests. Sends the request without the possibility of any response from the
//     # service (even an error).
//     #
//     # + soapAction - SOAP action
//     # + body - SOAP request body as an `XML` or `mime:Entity[]` to work with SOAP attachments
//     # + options - SOAP options. E.g., headers, WS-addressing parameters, usernameToken parameters
//     public remote function sendOnly(xml|mime:Entity[] body, public string? soapAction = (), public Options? options = ()) {
//         sendOnly(SOAP12, body, self.soap12Client, soapAction = soapAction, options = options);
//     }
// };
