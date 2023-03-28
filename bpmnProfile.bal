import ballerina/http;
import ballerina/mime;
//BPMN Records
type Variable record {
    string name;
    string|int value;

};

type BPMNDataRecord record {
    string processDefinitionId;
    string businessKey = "myBusinessKey";
    Variable[] variables;

};

type BPMNConfig record {
    string USER_CREDENTIALS;
    string BASIC_AUTH_TYPE;
    string BPMN_ENGINE_URL;

};
configurable BPMNConfig bpmnConfig = ?; 
distinct service class BPMNService{
    *BPSProfile;

 final string BPMN_ENGINE_URL = "http://localhost:9763/api/server/v1/workflow/";


    public function callbackProcessHandler() {
        return;
    }

    public function workflowInitializer(WorkflowRequestType workflowRequestType) returns any|error {
        http:Client clientEPBPMN = check new (self.BPMN_ENGINE_URL);
        json bpmnPayload = check self.BPMNConvert(workflowRequestType);

        string basicAuth =bpmnConfig. BASIC_AUTH_TYPE + <string>(check mime:base64Encode(bpmnConfig.USER_CREDENTIALS, mime:DEFAULT_CHARSET));

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON, "Authorization": basicAuth};
        http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", bpmnPayload, headers);
        
        return res.statusCode;
    }
    private function BPMNConvert(WorkflowRequestType workflowRequestType) returns json|error {
           BPMNDataRecord bpmnPayload = check workflowRequestType.cloneWithType(BPMNDataRecord);
        json jsonData = bpmnPayload.toJson();
        return jsonData;
        
    }
}