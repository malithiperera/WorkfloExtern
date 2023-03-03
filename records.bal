import ballerina/xmldata;



//BPMN Records
type Variable record {
    string name;
    string|int value;
   
};
type BPMNDataRecord record {
    string processDefinitionId;
    string  businessKey="myBusinessKey";
    Variable[] variables;
    
};



//BPEL Records
// Defines a record type with annotations.
@xmldata:Namespace {
    prefix: "p",
    uri: "http://schema.bpel.mgt.workflow.carbon.wso2.org"
}
type ProcessRequest record {
    string uuid;
    string eventType?;
    string taskInitiator?;
   Parameters[] parameters?;
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
    Parameter[] parameters;
};

type variable record {
    string name;
    string value;
};






//Camunda Records
type Camunda record{
   string[] variables;

};
