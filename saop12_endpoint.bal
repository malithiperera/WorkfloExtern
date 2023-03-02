


import ballerina/http;
import ballerina/mime;


# Object for the SOAP 1.2 client endpoint.
#
# + soap12Client - The HTTP client created to send SOAP 1.2 requests.
public  client class Soap12Client {

     http:Client soap12Client;

    public function init(string url, http:ClientConfiguration config ={httpVersion: "1.1"}) returns error? {
        self.soap12Client = check new http:Client (url, config = config);
    }

    # Sends SOAP 1.2 request and expects a response.
    #
    # + soapAction - SOAP action
    # + body - SOAP request body as an `XML` or `mime:Entity[]` to work with SOAP attachments
    # + options - SOAP options. E.g., headers, WS-addressing parameters, usernameToken parameters
    # + return - If successful, returns the response object. Else, returns an error.
     remote function sendReceive(xml|mime:Entity[] body,  string? soapAction = (),  Options? options = ())
    returns @tainted SoapResponse|error {
        return sendReceive(SOAP12, body, self.soap12Client, soapAction = soapAction, options = options);
    }

    # Sends robust SOAP 1.2 requests and possibly receives an error.
    #
    # + soapAction - SOAP action
    # + body - SOAP request body as an `XML` or `mime:Entity[]` to work with SOAP attachments
    # + options - SOAP options. E.g., headers, WS-addressing parameters, usernameToken parameters
    # + return - If successful, returns `nil`. Else, returns an error.
     remote function sendRobust(xml|mime:Entity[] body,  string? soapAction = (),  Options? options = ())
    returns error? {
        return sendRobust(SOAP12, body, self.soap12Client, soapAction = soapAction, options = options);
    }

    # Fire and forget requests. Sends the request without the possibility of any response from the
    # service (even an error).
    #
    # + soapAction - SOAP action
    # + body - SOAP request body as an `XML` or `mime:Entity[]` to work with SOAP attachments
    # + options - SOAP options. E.g., headers, WS-addressing parameters, usernameToken parameters
     remote function sendOnly(xml|mime:Entity[] body,  string? soapAction = (),  Options? options = ()) {
        error? sendOnlyResult = sendOnly(SOAP12, body, self.soap12Client, soapAction = soapAction, options = options);
        if sendOnlyResult is error {

        }
    }
}
