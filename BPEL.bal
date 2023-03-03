
import ballerina/io;
import ballerina/xmldata;


public function convertBPEL(json datajson) returns xml|error? {

//     json datajson={
//     "processDefinitionId": "b56ab75c-09fa-4e0b-9bac-fb0f8bf2378c",
//     "variables": [
//         {
//             "name": "REQUEST ID",
//             "value": "42ddbd60-4c90-4d8a-a234-153cc4406656"
//         },
//         {
//             "name": "Role Name",
//             "value": "ResManager"
//         },
//         {
//             "name": "User Store Domain",
//             "value": "PRIMARY"
//         }
//     ]
// };

string uuid= check datajson.processDefinitionId;
// Variable[] variable= check datajson.variables;


    // Creates an `Invoice` record.
   ProcessRequest data = {
        uuid: uuid,
        eventType:"ADD_ROLE",
        taskInitiator:"admin",
        parameters: {'parameter: [
            {
                        name:"roleName",
                        value:{
                            itemValue:"admin"
                        }
                    },
                    {
                        name:"users",
                        value:{
                            itemValue:"admin"
                        }
                    }
        ]}
      
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


