
type InputTypeVariable record {
    string name;
    string value;
};

type InputType record {
    string processDefinitionId;
    InputTypeVariable[] variables;
};

type OutputTypeVariable record {
    string value;
};

type OutputType record {
    map<OutputTypeVariable> variables;
};

public function CamundaConvert(json input) returns error|OutputType {

    string uuid = check input.processDefinitionId;

    InputType inputRecord = check input.cloneWithType(InputType);
    OutputType outputType = {
        variables: {}
    };
    outputType.variables["processDefinitionId"] = {
        value: uuid
    };
    foreach InputTypeVariable inputVariable in inputRecord.variables {
        if (inputVariable.name == "Role Name") {
            outputType.variables["roleName"] = {
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
