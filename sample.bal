import ballerina/http;

import ballerina/io;
import ballerina/mime;


http:Client clientBPEL = check new ("https://0066-2402-d000-a400-6112-c828-967f-36-d2f4.in.ngrok.io");
http:Client clientEPBPMN = check new ("https://a7c7-2402-d000-a400-6112-c828-967f-36-d2f4.in.ngrok.io");
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
        json requestbody = check request.getJsonPayload();
        // json jsonData = check convertBPMN(requestbody);
        string userCredentials = "admin:admin";
        string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
  
        map<string> headers = {"Content-Type": "application/json", "Authorization": basicAuth,"Content-Language": "en-US","Accept":"*/*"};
        http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", requestbody, headers);
        check caller->respond(res);
      
    }



    //bepl endpoint
 resource function post bpeldata(http:Caller caller, http:Request request) returns error? {
     json requestbody = check request.getJsonPayload();

  

        xml|error? xmlData = convertBPEL(requestbody);
        io:print(xmlData);
        string userCredentials = "admin:admin";
        string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
        map<string> headers = {"Content-Type": "application/xml", "Authorization": basicAuth,"Content-Language": "en-US","Accept":"*/*"};
        http:Response res = check clientBPEL->post("/services/create_RoleService", check xmlData,headers);

       if(res.statusCode==500){
 Response data={
           taskDefinitionId: "122", status: res.statusCode.toString()};

        check caller->respond(data.toJson());
       }
       

      }



//camunda endpoint
 resource function post camunda(http:Caller caller, http:Request request) returns error? {
        json requestbody = check request.getJsonPayload();
    }


}







