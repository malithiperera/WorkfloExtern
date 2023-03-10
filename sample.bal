import ballerina/http;

import ballerina/io;
import ballerina/mime;

http:Client clientBPEL = check new ("https://8d0a-2402-d000-a500-54cb-51cf-346e-ddd5-d90a.in.ngrok.io");
http:Client clientEPBPMN = check new ("https://a7c7-2402-d000-a400-6112-c828-967f-36-d2f4.in.ngrok.io");

service / on new http:Listener(8090) {
    resource function get .() returns string|error? {

        return "Invalid request";
    }

    resource function post .(http:Caller caller, http:Request request) returns error? {

        json datajson = check request.getJsonPayload();
        string bpsEngine = check datajson.bpsEngine;
        if (bpsEngine == "BPEL") {
            json responsePayload = check BPELFunction(datajson);

            io:println(responsePayload);
            check caller->respond(responsePayload.toString());

        }
        else if (bpsEngine == "BPMN") {
            json responsePayload = check BPMNFunction(datajson);

            io:println(responsePayload);
            check caller->respond(responsePayload.toString());

        }
        else {
            io:println("invalid bps engine");
        }
    }
}

# Description
#
# + requstbody - Parameter Description
# + return - Return Value Description
public function BPELFunction(json requstbody) returns json|error? {

    xml|error? xmlData = convertBPEL(requstbody);
    io:print(xmlData);

    string userCredentials = "admin:admin";
    string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
    map<string> headers = {"Content-Type": "application/xml", "Authorization": basicAuth, "Content-Language": "en-US", "Accept": "*/*"};
    http:Response res = check clientBPEL->post("/services/create_RoleService", check xmlData, headers);

    Response response = {statusCode: res.statusCode, statusMessage: "created successfully"};
    return response.toJson();

}

# Description
#
# + requestbody - Parameter Description
# + return - Return Value Description
public function BPMNFunction(json requestbody) returns json|error? {

    // json jsonData = check convertBPMN(requestbody);
    string userCredentials = "admin:admin";
    string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));

    map<string> headers = {"Content-Type": "application/json", "Authorization": basicAuth, "Content-Language": "en-US", "Accept": "*/*"};
    http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", requestbody, headers);
    Response response = {statusCode: res.statusCode, statusMessage: "created successfully"};
    return response.toJson();
}

