public abstract class EESBConnectorWebService {

    protected final GATEWAY__c GATEWAY;

    @TestVisible
    protected virtual HttpResponse sendPostRequest(String endpoint, String body) {
        new DefaultValidator().validate(String.class, 'body', body);
        new DefaultValidator().validate(String.class, 'endpoint', endpoint);

        HttpRequest request = new HttpRequest();
        request.setHeader(HttpUtils.HEADER.IBM_GATEWAY.CLIENT_SECRET, GATEWAY == null ? '' : GATEWAY.CLIENT_SECRET__c == null ? '' : GATEWAY.CLIENT_SECRET__c);
        request.setHeader(HttpUtils.HEADER.IBM_GATEWAY.CLIENT_ID, GATEWAY == null ? '' : GATEWAY.CLIENT_ID__c == null ? '' : GATEWAY.CLIENT_ID__c);
        request.setHeader(HttpUtils.HEADER.CONTENT_TYPE, HttpUtils.HEADER.JSON);
        request.setEndpoint(endpoint);
        request.setBody(body);
        request.setMethod(HttpUtils.METHOD.POST);
        request.setTimeout(HttpUtils.MAX_TIMEOUT);
        return new Http().send(request);
    }

    protected virtual MetadataBody createRequestMetadata() {
        MetadataBody metadataBody = new MetadataBody();
        metadataBody.transactionId = GlobalUtils.generateGUID();   // transaction UUID
        metadataBody.user = UserInfo.getUserName();                // the user who made the request
        metadataBody.tsCreated = System.currentTimeMillis();       // timestamp when request was created
        metadataBody.tsSent = metadataBody.tsCreated;              // timestamp when request was sent
        metadataBody.source = 'salesforce';                        // the source of the request
        metadataBody.channel = 'api';                              // channel type, eg email, api, etc
        return metadataBody;
    }
}

