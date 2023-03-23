
# Description
# the requrst json payload converts the data format whih except from camunda engine
# + input - json data format. 
# + return -requset type json data format.
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
        // else{
        //      outputType.variables[inputVariable.name] = {
        //     value: inputVariable.value
        // };
        // }

    }

    return outputType;
}
