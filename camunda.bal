import ballerina/http;

# Camunda Profile
public class CamundaProfile {
    final string CAMUNDA_ENGINE_URL = "https://340f-2402-d000-a400-6179-f4b7-ab4b-fc4e-652d.in.ngrok.io/engine-rest/process-definition";
    final string CAMUNDA_PROCESS_DEFINITION_ID = "Useradd:1:3ff03477-c970-11ed-9db5-9e29762f7844";


    # Description
    # Camunda workflow requset crate function
    # + datajson - Workflow request payload in json format
    # + return - return the status code of the workflow request
    public function CamundaFunction(json datajson) returns json|error? {

        http:Client clientCamunda = check new (self.CAMUNDA_ENGINE_URL);
        CamundaOutputType camundaPayload = check self.CamundaConvert(datajson);
        http:Response res = check clientCamunda->post("/" + self.CAMUNDA_PROCESS_DEFINITION_ID + "/start", camundaPayload, {});
        return res.statusCode.toString();
    }




    # Description
    # the requrst json payload converts the data format whih except from camunda engine
    # + input - json data format. 
    # + return - requset type json data format.
    # 
    public function CamundaConvert(json input) returns error|CamundaOutputType {

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

}
