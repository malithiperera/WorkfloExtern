

// public function convertCamunda(json datajson) returns CamundaVaribles|error? {

//  string uuid = check datajson.processDefinitionId;
// json[] variableArrayJson = check datajson.variables.ensureType();
//  VariableRecord[] outputArray = [];
//     foreach json variable in variableArrayJson {
//         VariableRecord i = check variable.cloneWithType(VariableRecord);
      
        
//             outputArray.push(i);
//             // parameterArray.push({name: i.name, value: {itemValue: i.value}});

        

//     }

//     }

//     // Creates an `ProcessRequest` record.
// //     ProcessRequest data = {
// //         uuid: uuid,
// //         eventType: eventType,
// //         taskInitiator: taskInitiator,
// //         parameters: {'parameter: parameterArray}

// //     };

   
// //     // Converts a `record` representation to its XML representation.
// //     xml result = check xmldata:toXml(data);
// //     BPELReturn bpelReturn = {beplRequestbody: result, url: WORKFLOW_URL};
// //     return bpelReturn;

// // }

