import ballerina/http;
import ballerina/mime;

http:Client clientBPEL = check new (BPEL_ENGINE_URL);
http:Client clientEPBPMN = check new (BPMN_ENGINE_URL);

service / on new http:Listener(LISTINING_PORT) {
    resource function get .(http:Caller caller) returns error? {

        check caller->respond(error("Invalid Request"));
    }

    resource function post .(http:Caller caller, http:Request request) returns error? {

        json requestWorkflowPayload = check request.getJsonPayload();
        string bpsEngine = check requestWorkflowPayload.bpsEngine;
        if (bpsEngine == BPEL_ENGINE) {
            json responsePayload = check BPELFunction(requestWorkflowPayload);
            check caller->respond(responsePayload.toString());

        }
        else if (bpsEngine == BPMN_ENGINE) {
            json responsePayload = check BPMNFunction(requestWorkflowPayload);
            check caller->respond(responsePayload.toString());

        }
        else {
            check caller->respond(error("Invalid BPS Engine"));
        }
    }
}

# Description
#
# + requstbody - Parameter Description
# + return - Return Value Description
public function BPELFunction(json requstbody) returns json|error? {

      


    BPELReturn bpelReturn = check convertBPEL(requstbody) ?: {};
    string basicAuth = BASIC_AUTH_TYPE + <string>(check mime:base64Encode(USER_CREDENTIALS, mime:DEFAULT_CHARSET));

    map<string> headers = {"Content-Type": mime:APPLICATION_XML, "Authorization": basicAuth};
    http:Response res = check clientBPEL->post(BPEL_ENGINE_URL, bpelReturn.beplRequestbody, headers);

    Response response = {statusCode: res.statusCode};
    return response.toJson();

}

# Description
#
# + requestbody - Parameter Description
# + return - Return Value Description
public function BPMNFunction(json requestbody) returns json|error? {

    // json jsonData = check convertBPMN(requestbody);

    string basicAuth = BASIC_AUTH_TYPE + <string>(check mime:base64Encode(USER_CREDENTIALS, mime:DEFAULT_CHARSET));

    map<string> headers = {"Content-Type": mime:APPLICATION_JSON, "Authorization": basicAuth};
    http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", requestbody, headers);
    Response response = {statusCode: res.statusCode};
    return response.toJson();
}

