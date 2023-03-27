import ballerina/http;
import ballerina/mime;

//callback record

type CallbackCamunda record {
    string processDefinitionId;
    string status;

};

type CallBackConfig record {
    string CALLBACK_END_POINT;

};

configurable CallBackConfig callbackconfig = ?;

service / on new http:Listener(8090) {

    resource function post .(http:Caller caller, http:Request request, string bpsProfile) returns error? {

        json requestWorkflowPayload = check request.getJsonPayload();
        // Extract the "name" parameter from the URL
        if (bpsProfile == "camunda") {
            CamundaService camundaProfile = new CamundaService();

            any workflowInitializer = check camundaProfile.workflowInitializer(requestWorkflowPayload);
            check caller->respond(workflowInitializer.toString());
        }
        else if (bpsProfile == "BPEL") {
            BPELService bpelProfile = new BPELService();
            any workflowInitializer = check bpelProfile.workflowInitializer(requestWorkflowPayload);
            check caller->respond(workflowInitializer.toString());
        }

        else if (bpsProfile == "BPMN") {
            BPMNService bpmnProfile = new BPMNService();
            any workflowInitializer = check bpmnProfile.workflowInitializer(requestWorkflowPayload);
            check caller->respond(workflowInitializer.toString());

        }

    }

    resource function post CallbackEndPoint(http:Caller caller, http:Request request) returns error? {
        http:Client CallbackIS = check new (callbackconfig.CALLBACK_END_POINT);

        json callbackPayload = check request.getJsonPayload();
        CallbackCamunda inputRecord = check callbackPayload.cloneWithType(CallbackCamunda);
        string processuuid = inputRecord.processDefinitionId;
        json payload = {
            "status": inputRecord.status
        };

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON};
        http:Response res = check CallbackIS->patch(processuuid, payload, headers);

        check caller->respond(res.statusCode);

    }

}

