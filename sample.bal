import ballerina/http;
import ballerina/mime;



service / on new http:Listener(LISTINING_PORT) {
    resource function get .(http:Caller caller) returns error? {

        check caller->respond(error("Invalid Request"));
    }

    resource function post .(http:Caller caller, http:Request request) returns error? {

        json requestWorkflowPayload = check request.getJsonPayload();
         CamundaProfile camundaProfile = new CamundaProfile();

        json responsePayload = check camundaProfile.CamundaFunction(requestWorkflowPayload);
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
        http:Client CallbackIS = check new (CALLBACK_END_POINT);


        json callbackPayload = check request.getJsonPayload();
        Callback inputRecord = check callbackPayload.cloneWithType(Callback);
        string processuuid = inputRecord.processDefinitionId;
        json payload = {
            "status": inputRecord.status
        };

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON};
        http:Response res = check CallbackIS->patch(processuuid, payload, headers);
        Response response = {statusCode: res.statusCode};
        check caller->respond(response.statusCode);

    }

}

