import ballerina/http;
import ballerina/mime;


http:Client clientCamunda = check new (CAMUNDA_ENGINE_URL);
http:Client clientBPEL = check new (BPEL_ENGINE_URL);
http:Client clientEPBPMN = check new (BPMN_ENGINE_URL);
http:Client CallbackIS = check new (CALLBACK_END_POINT);

service / on new http:Listener(LISTINING_PORT) {
    resource function get .(http:Caller caller) returns error? {

        check caller->respond(error("Invalid Request"));
    }

    resource function post .(http:Caller caller, http:Request request) returns error? {

        json requestWorkflowPayload = check request.getJsonPayload();

        json responsePayload = check CamundaFunction(requestWorkflowPayload);
        check caller->respond(responsePayload.toString());
        // string bpsEngine = check requestWorkflowPayload.bpsEngine;
        // if (bpsEngine == BPEL_ENGINE) {
        //     json responsePayload = check BPELFunction(requestWorkflowPayload);
        //     check caller->respond(responsePayload.toString());

        // }
        // else if (bpsEngine == BPMN_ENGINE) {
        //     json responsePayload = check BPMNFunction(requestWorkflowPayload);
        //     check caller->respond(responsePayload.toString());

        // }

    }

    resource function post CallbackEndPoint(http:Caller caller, http:Request request) returns error? {

        json callbackPayload = check request.getJsonPayload();
        Callback inputRecord = check callbackPayload.cloneWithType(Callback);
        string processuuid= inputRecord.processDefinitionId;
        string basicAuth = BASIC_AUTH_TYPE + <string>(check mime:base64Encode(USER_CREDENTIALS, mime:DEFAULT_CHARSET));

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON, "Authorization": basicAuth};
        http:Response res = check CallbackIS->post(processuuid, {"status":inputRecord.status}, headers);
        Response response = {statusCode: res.statusCode};
         check caller->respond(response.statusCode);

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
# Camunda workflow requset crate function
# + datajson - Workflow request payload in json format
# + return - return the status code of the workflow request
public function CamundaFunction(json datajson) returns json|error? {

    CamundaOutputType camundaPayload = check CamundaConvert(datajson);
    http:Response res = check clientCamunda->post("/" + CAMUNDA_PROCESS_DEFINITION_ID + "/start", camundaPayload, {});
    return res.statusCode.toString();
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

