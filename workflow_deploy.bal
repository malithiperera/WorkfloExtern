public class worlflowDeploy {
    private string workflowDefinitionId;
    private string accessURL;

function init(string workflowDefinitionId, string accessURL) {
        self.workflowDefinitionId = workflowDefinitionId;
        self.accessURL = accessURL;
    }
    
    function getworkflowDefinitionId() returns string {
        return self.workflowDefinitionId;
    }
    function getaccessURL() returns string {
        return self.accessURL;
    }
}
    

    


