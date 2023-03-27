import ballerina/http;
//Camunda Records

type CamundaInputTypeVariable record {
    string name;
    string value;
};

type CamundaInputType record {
    string processDefinitionId;
    CamundaInputTypeVariable[] variables;
};

type CamundaOutputTypeVariable record {
    string value;
};

type CamundaOutputType record {
    map<CamundaOutputTypeVariable> variables;
};

type CamundaConfig record {|
    string CAMUNDA_ENGINE_URL;
    string CAMUNDA_PROCESS_DEFINITION_ID;
|};
configurable CamundaConfig camundaconfig = ?;
distinct service class CamundaService {
    // This denotes that this object implements the `Profile` interface.
    *BPSProfile;

    private string engineURL;
    private string processDefinitionID;

    function init() {
        self.engineURL = camundaconfig.CAMUNDA_ENGINE_URL;
        self.processDefinitionID = camundaconfig.CAMUNDA_PROCESS_DEFINITION_ID;
    }

   

    # Description
    #
    # + requestPayload - Parameter Description
    # + return - Return Value Description
   public function workflowInitializer(json requestPayload) returns any ?|error {
         http:Client clientCamunda =  check new (self.engineURL);
        CamundaOutputType camundaPayload =  check self.CamundaConvert(requestPayload);
        http:Response res = check clientCamunda->post("/" + self.processDefinitionID + "/start", camundaPayload, {});
        return res.statusCode.toString();
      
    }
    # Description
    # the requrst json payload converts the data format whih except from camunda engine
    # + input - json data format. 
    # + return - requset type json data format.
    # 
    private isolated function CamundaConvert(json input) returns error|CamundaOutputType {

        string uuid = check input.processDefinitionId;

        CamundaInputType inputRecord = check input.cloneWithType(CamundaInputType);
        CamundaOutputType outputType = {
            variables: {}
        };
        outputType.variables["processDefinitionId"] = {
            value: uuid
        };
        foreach CamundaInputTypeVariable inputVariable in inputRecord.variables {
            if (inputVariable.name == "Username") {
                outputType.variables[inputVariable.name] = {
                    value: inputVariable.value
                };
            }

        }
        return outputType;
    }
     public function callbackProcessHandler() {
        return;
    }
}