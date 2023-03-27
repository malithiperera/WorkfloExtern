type BPSProfile distinct service object {
   

    // Defines the field `name` as a resource method definition.

    public function workflowInitializer(json requestPayload) returns any | error;
    public function callbackProcessHandler();
};
