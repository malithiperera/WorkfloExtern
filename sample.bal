import ballerina/http;

import ballerina/io;
import ballerina/mime;


http:Client clientBPEL = check new ("https://0066-2402-d000-a400-6112-c828-967f-36-d2f4.in.ngrok.io");

service / on new http:Listener(8090) {
    resource function get .() returns string|error? {

        // http:Response res = check clientEP->get("/api/workflow/testmap");
        // io:print(res);

        // return res.getTextPayload();
    }

    resource function post .(http:Caller caller, http:Request request) returns error? {
        json res = check request.getJsonPayload();
        io:println(res);
        check caller->respond(res.toString());
    }

    resource function get bpmndata() returns string|error? {

        // http:Response res = check clientEP->get("/api/workflow/testmap/see");
        // io:print(res);

        // return res.getTextPayload();
    }
    



    //bpmn endpoint 
     resource function post bpmndata(http:Caller caller, http:Request request) returns error? {
        // json requestbody = check request.getJsonPayload();
        // json jsonData = check convertBPMN(requestbody);
        // string userCredentials = "admin:admin";
        // string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
  
        // map<string> headers = {"Content-Type": "application/json", "Authorization": basicAuth,"Content-Language": "en-US","Accept":"*/*"};
        // http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", jsonData, headers);
        // check caller->respond(res);
      
    }



    //bepl endpoint
 resource function post bpeldata(http:Caller caller, http:Request request) returns error? {
        // json requestbody = check request.getJsonPayload();
        json requestbody = {
    "processDefinitionId": "b56ab75c-09fa-4e0b-9bac-fb0f8bf2378c",
    "variables": [
        {
            "name": "REQUEST ID",
            "value": "42ddbd60-4c90-4d8a-a234-153cc4406656"
        },
        {
            "name": "Role Name",
            "value": "Fera"
        },
        {
            "name": "User Store Domain",
            "value": "PRIMARY"
        }
    ]
};

        xml|error? xmlData = convertBPEL(requestbody);
        io:print(xmlData);
        string userCredentials = "admin:admin";
        string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
        map<string> headers = {"Content-Type": "application/xml", "Authorization": basicAuth,"Content-Language": "en-US","Accept":"*/*"};
        http:Response res = check clientBPEL->post("/services/create_RoleService", check xmlData,headers);
        io:print(res.statusCode);

      }



//camunda endpoint
 resource function post camunda(http:Caller caller, http:Request request) returns error? {
        json requestbody = check request.getJsonPayload();
    }


}







