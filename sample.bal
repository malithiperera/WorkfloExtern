import ballerina/http;
import ballerina/mime;
import ballerina/io;

http:Client clientBPEL = check new (BPEL_ENGINE_URL);
http:Client clientEPBPMN = check new (BPMN_ENGINE_URL);
http:Client clientCamunda = check new (CAMUNDA_ENGINE_URL);

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

    resource function post CallbackEndPoint(http:Caller caller, http:Request request) returns error? {

        // json callbackPayload = check request.getJsonPayload();

    }
    resource function post CamundaCall(http:Caller caller, http:Request request) returns error? {
        json datajson = check request.getJsonPayload();
        string uuid = check datajson.processDefinitionId;
        json[] variableArrayJson = check datajson.variables.ensureType();

        string roleName = "";

        foreach json variable in variableArrayJson {
            VariableRecord i = check variable.cloneWithType(VariableRecord);
            if (i.name == "Role Name") {
                roleName = i.value;
                break;
            }

        }
        json jsonContent = {
            "variables": {
                "processDefinitionId": {
                    "value": uuid
                },
                "roleName": {
                    "value": roleName
                }
            }
        };

        //  string basicAuth = BASIC_AUTH_TYPE + <string>(check mime:base64Encode(USER_CREDENTIALS, mime:DEFAULT_CHARSET));

        //     map<string> headers = {"Content-Type": mime:APPLICATION_JSON, "Authorization": basicAuth};
        http:Response|http:ClientError res = clientCamunda->post("/Process_1ujkwkn:2:d4125373-c7a7-11ed-a4b7-9e29762f7844/start", jsonContent);
        if (res is http:Response) {
            io:println(res.statusCode);
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
    http:Response res = check clientBPEL->post(WORKFLOW_URL, bpelReturn.beplRequestbody, headers);

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

