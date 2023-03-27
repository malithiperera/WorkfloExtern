import ballerina/xmldata;
import ballerina/http;
import ballerina/mime;

type BPELConfig record {|
string USER_CREDENTIALS;
string BASIC_AUTH_TYPE;
string BPEL_ENGINE_URL;
string WORKFLOW_URL;
    
|};

configurable BPELConfig bpelconfig = ?;

//BPEL Records
// Defines a record type with annotations.

type VariableRecord record {|
    string name;
    string value;
|};

@xmldata:Namespace {
    prefix: "p",
    uri: "http://schema.bpel.mgt.workflow.carbon.wso2.org/"
}
type ProcessRequest record {
    string uuid;
    string eventType?;
    string taskInitiator?;
    Parameters parameters?;
};

type Item record {
    string itemCode;
    int count;
};

type Parameter record {
    @xmldata:Attribute
    string name?;
    Value value;
};

type Value record {
    string itemValue;
};

type Parameters record {
    Parameter[] 'parameter;
};

type variable record {
    string name;
    string value;
};

type BPELReturn record {
    string url?;
    xml beplRequestbody?;
};


distinct service class BPELService{
    *BPSProfile;



    public function callbackProcessHandler() {
        return;
    }

    public function workflowInitializer(json requestPayload) returns any|error {
         BPELReturn bpelReturn = check self.ConvertBPEL(requestPayload);
        string basicAuth = bpelconfig.BASIC_AUTH_TYPE + <string>(check mime:base64Encode(bpelconfig.USER_CREDENTIALS, mime:DEFAULT_CHARSET));
        http:Client clientBPEL = check new (bpelconfig.BPEL_ENGINE_URL);
        map<string> headers = {"Content-Type": mime:APPLICATION_XML, "Authorization": basicAuth};
        http:Response res = check clientBPEL->post(bpelconfig.WORKFLOW_URL, bpelReturn.beplRequestbody, headers);

       
        return  res.statusCode;

        
    }
    private function ConvertBPEL(json datajson) returns BPELReturn|error {
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
        BPELReturn bpelReturn = {beplRequestbody: result, url: bpelconfig.WORKFLOW_URL};
        return bpelReturn;

    }

        
    
}
