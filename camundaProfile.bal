
import ballerina/http;

//Camunda Records

type CamundaInputTypeVariable record {
    string name;
    string value;
};

type CamundaOutputTypeVariable record {
    string value;
};

type CamundaOutputType record {
    map<CamundaOutputTypeVariable> variables;
};

type DefinitionID record {
    string evenetType?;
    string ID;
};

type CamundaConfig record {|
    string CAMUNDA_ENGINE_URL;

   

|};

configurable CamundaConfig camundaconfig = ?;
configurable DefinitionID[] camundaID =?;

distinct service class CamundaService {

    *BPSProfile;

    private string engineURL;

    private DefinitionID[] definitionIDs;

    function init() {
        self.engineURL = camundaconfig.CAMUNDA_ENGINE_URL;

        self.definitionIDs = camundaID;
    }

    # Description
    #
    # + workflowRequestType - Parameter Description
    # + return - Return Value Description
    public function workflowInitializer(WorkflowRequestType workflowRequestType) returns any?|error {
        //string evenType = workflowRequestType.eventType;
        //string workflowDefinitionID = "ADD_USER";
        // foreach var item in self.definitionIDs {
        //     if (item["evenetType"] == evenType) {
        //         workflowDefinitionID = item["ID"];
        //         break;
        //     }

        // }
        http:Client clientCamunda = check new (self.engineURL);
        CamundaOutputType camundaPayload = check self.CamundaConvert(workflowRequestType);
        http:Response res = check clientCamunda->post("/" + "Useradd:1:3ff03477-c970-11ed-9db5-9e29762f7844" + "/start", camundaPayload, {});
        return res.statusCode;

    }
    # Description
    # the requrst json payload converts the data format whih except from camunda engine
    # + workflowRequestType - json data format. 
    # + return - requset type json data format.
    #
    private isolated function CamundaConvert(WorkflowRequestType workflowRequestType) returns error|CamundaOutputType {

        string uuid = workflowRequestType.processDefinitionId;

        CamundaOutputType outputType = {
            variables: {}
        };
        outputType.variables["processDefinitionId"] = {
            value: uuid
        };
        foreach CamundaInputTypeVariable inputVariable in workflowRequestType.variables {
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
