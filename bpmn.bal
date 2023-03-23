import ballerina/mime;
import ballerina/http;

public class BPMNProfile {

    final string BPMN_ENGINE_URL = "http://localhost:9763/api/server/v1/workflow/";

    function convertBPMN(json requestbody) returns json|error {
        BPMNDataRecord bpmnPayload = check requestbody.cloneWithType(BPMNDataRecord);
        json jsonData = bpmnPayload.toJson();
        return jsonData;

    }
    public function BPMNFunction(json requestbody) returns json|error? {
        http:Client clientEPBPMN = check new (self.BPMN_ENGINE_URL);
        // json jsonData = check convertBPMN(requestbody);

        string basicAuth = BASIC_AUTH_TYPE + <string>(check mime:base64Encode(USER_CREDENTIALS, mime:DEFAULT_CHARSET));

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON, "Authorization": basicAuth};
        http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", requestbody, headers);
        Response response = {statusCode: res.statusCode};
        return response.toJson();
    }

}
