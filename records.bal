import ballerina/xmldata;

//BPMN Records
type Variable record {
    string name;
    string|int value;

};

type BPMNDataRecord record {
    string processDefinitionId;
    string businessKey = "myBusinessKey";
    Variable[] variables;

};

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



//Response Type
type Response record {
    int statusCode;
    string statusMessage?;

};

//Camunda Records

type CamundaInputTypeVariable record {
    string name;
    string value;
};

type CamundaInputType record {
    string processDefinitionId;
    CamundaInputTypeVariable[] variables;
};

type CamundaOutputTypeVariable record {
    string value;
};

type CamundaOutputType record {
    map<CamundaOutputTypeVariable> variables;
};