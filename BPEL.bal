
import ballerina/io;
import ballerina/xmldata;
type VariableRecord record {| string name; string value; |};

public function convertBPEL(json datajson) returns xml|error? {



string uuid= check datajson.processDefinitionId;
json[] variableArrayJson = check datajson.variables.ensureType();
VariableRecord[] outputArray = [];
Parameter[] parameterArray = [];
    foreach json variable in variableArrayJson {
        VariableRecord i = check variable.cloneWithType(VariableRecord);
        
        outputArray.push(i);
        parameterArray.push({name:i.name,value:{itemValue:i.value}});
    }

    io:println("Output-Array");
    io:println(parameterArray);

    // Creates an `Invoice` record.
   ProcessRequest data = {
        uuid: uuid,
        eventType:"ADD_ROLE",
        taskInitiator:"admin",
        parameters: {'parameter: parameterArray}
      
    };

    // Converts a `record` representation to its XML representation.
    xml result = check xmldata:toXml(data);
    io:println(result);
    return result;
  
}












// public function main() returns error? {

// Soap12Client soapClient = check new("https://www.w3schools.com/xml/tempconvert.asmx");

//     xml body = xml `<FahrenheitToCelsius xmlns="https://www.w3schools.com/xml/">

//       <Fahrenheit>75</Fahrenheit>

//     </FahrenheitToCelsius>`;

//     var response = soapClient->sendReceive(body);
//     if (response is SoapResponse) {
//         io:println(response["payload"]);
//     } else {
//         io:println(response.message());
//     }
// }
// public function main() {
//     json Data={"processDefinitionId":"b56ab75c-09fa-4e0b-9bac-fb0f8bf2378c","variables":[{"name":"REQUEST ID","value":"42ddbd60-4c90-4d8a-a234-153cc4406656"},{"name":"Role Name","value":"seniorMqwww"},{"name":"User Store Domain","value":"PRIMARY"}]};

// BPMNDataRecord|error user = getUser(Data);
//     io:println(user);
// }


