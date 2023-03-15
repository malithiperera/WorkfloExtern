import ballerina/xmldata;

public function convertBPEL(json datajson) returns BPELReturn|error? {

    string uuid = check datajson.processDefinitionId;
    string eventType = "";
    string taskInitiator = "";

    json[] variableArrayJson = check datajson.variables.ensureType();
    VariableRecord[] outputArray = [];
    Parameter[] parameterArray = [];

    foreach json variable in variableArrayJson {
        VariableRecord i = check variable.cloneWithType(VariableRecord);
        if (i.name == "eventType") {
            eventType = i.value;
            continue;
        }
        else if (i.name == "taskInitiator") {
            taskInitiator = i.value;
            continue;
        }
        else {
            outputArray.push(i);
            parameterArray.push({name: i.name, value: {itemValue: i.value}});

        }

    }

    // Creates an `ProcessRequest` record.
    ProcessRequest data = {
        uuid: uuid,
        eventType: eventType,
        taskInitiator: taskInitiator,
        parameters: {'parameter: parameterArray}

    };

    string bpelServiceUrl = "services/create_RoleService";
    // Converts a `record` representation to its XML representation.
    xml result = check xmldata:toXml(data);
    BPELReturn bpelReturn = {beplRequestbody: result, url: bpelServiceUrl};
    return bpelReturn;

}

