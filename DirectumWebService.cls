public with sharing class DirectumWebService extends EESBConnectorWebService {

    public DirectumWebService() {
        GATEWAY = GATEWAY__c.getValues('directumCredentials');
    }

    public virtual void createContract(DirectumContractRequestBody contractData) {
        new DefaultValidator().validate(DirectumContractRequestBody.class, 'contractData', contractData);

        Logger logger = new Logger('directum integration');
        HttpResponse response;
        try {
            DirectumContractRequestBodyFull requestBody = new DirectumContractRequestBodyFull();
            requestBody.metadata = createRequestMetadata();
            requestBody.data = contractData;

            String userEmail = UserInfo.getUserEmail();
            requestBody.data.ManagerKO = userEmail;
            requestBody.data.ResponsibleEmployee = userEmail;

            String data = JSON.serialize(requestBody).replace('"pCurrency":', '"Currency":');
            String endpoint = GATEWAY?.URL__c;
            logger.info('POST request to ' + endpoint, data);

            response = sendPostRequest(endpoint, data);

            if (response.getStatusCode() != 200) {
                HttpUtils.throwHttpResponseException(response.getStatusCode(), response.getBody(), DirectumWebService.class, 'createContract');
            }
            OrganizationRequisiteDataService.changeLockOfRecordsByOppId(contractData.RequestID, true);
        } catch (Exception e) {
            logger.fatal('DirectumWebService.createContract method', e.getTypeName() + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
            HttpUtils.throwHttpResponseException(response.getStatusCode(), String.valueOf(e.getMessage()), DirectumWebService.class, 'createContract');
        } finally {
            logger.saveLogs();
        }
    }
}