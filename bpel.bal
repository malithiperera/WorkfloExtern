import ballerina/xmldata;
import ballerina/mime;
import ballerina/http;

# Description BPEL Profile Details
public class BPELProfile {
    final string BPEL_ENGINE_URL = "http://localhost:9763/api/server/v1/workflow/";
    final string WORKFLOW_URL = "/services/create_RoleService";

    # Description Convert json payload to BPEL xml body
    # + datajson - json payload
    # + return - BPEL xml body
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

        // Converts a `record` representation to its XML representation.
        xml result = check xmldata:toXml(data);
        BPELReturn bpelReturn = {beplRequestbody: result, url: self.WORKFLOW_URL};
        return bpelReturn;

    }

    # Process and send the BPEL request to the BPEL engine
    #
    # + requstbody - json payload
    # + return - response body
    public function BPELFunction(json requstbody) returns json|error? {

        BPELReturn bpelReturn = check self.convertBPEL(requstbody) ?: {};
        string basicAuth = BASIC_AUTH_TYPE + <string>(check mime:base64Encode(USER_CREDENTIALS, mime:DEFAULT_CHARSET));
        http:Client clientBPEL = check new (self.BPEL_ENGINE_URL);
        map<string> headers = {"Content-Type": mime:APPLICATION_XML, "Authorization": basicAuth};
        http:Response res = check clientBPEL->post(self.WORKFLOW_URL, bpelReturn.beplRequestbody, headers);

        Response response = {statusCode: res.statusCode};
        return response.toJson();

    }
}
