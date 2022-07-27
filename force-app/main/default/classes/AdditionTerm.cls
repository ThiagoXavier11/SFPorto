/*
* Author: Henrique Almeida - 14/07/2021
* US: PORTODEL 91
* company: Deloitte
*/
public with sharing class AdditionTerm 
{    
    public static List<Quote> generateDocumentAsync(Set<Id> setQuoteId)
    {
        map<Id, Id> mapQuoteIdAccId = new map<Id, Id>();
        map<Id, String> mapQuoteIdNumber = new map<Id, String>();
        map<Id, Contact> mapCorretorAccIdContact = new map<Id, Contact>();
        map<Id, Contact> mapCustomerAccIdContact = new map<Id, Contact>();
        for(Quote varQuote : [SELECT Id, QuoteNumber, EnvelopeId__c,AccountId from Quote WHERE Id IN :setQuoteId])
        {            
            mapQuoteIdAccId.put(varQuote.Id, varQuote.AccountId);
            mapQuoteIdNumber.put(varQuote.Id, varQuote.QuoteNumber);
        }
        List<Account> lstCustomers = [Select Id, Name, (Select id, Name, Email from Contacts Where RecordType.DeveloperName = 'Representante_Legal') from Account Where Id IN :mapQuoteIdAccId.values()];
        List<AccountContactRelation> lstRelatedAccount = [Select id, Account.Name, Contact.Name, Contact.Email from AccountContactRelation where Contact.RecordType.DeveloperName = 'Representante_Legal' AND AccountId  IN :mapQuoteIdAccId.values()];

        If(!lstCustomers.isEmpty())
        {
            for(Account customer : lstCustomers)
            {
                if(!customer.Contacts.IsEmpty())
                {
                    mapCustomerAccIdContact.put(customer.Id, customer.Contacts[0]);
                }
            }
        }
        If(!lstRelatedAccount.isEmpty())
        {
            for(AccountContactRelation relatedAccount : lstRelatedAccount)
            {
                mapCustomerAccIdContact.put(relatedAccount.AccountId, relatedAccount.Contact);
            }
        }
        
        List<Corretagem__c> lstBrokerage = [SELECT Id, Proposta__c, Corretor__r.Id, Corretor__r.Name, Corretor__r.vlocity_ins__Email__c, Corretor__r.SusepReduzido__c FROM Corretagem__c WHERE Proposta__c =:setQuoteId];
        map<Id, Id> mapQuoteIdCorretorAccId = new map<Id, Id>();
        if(!lstBrokerage.isEmpty())
        {
            for(Corretagem__c corretagem : lstBrokerage)
            {
                mapQuoteIdCorretorAccId.put(corretagem.Proposta__c, corretagem.Corretor__c);
            }
            for(Contact varContact : [SELECT Id, Name, Email, AccountId FROM Contact WHERE AccountId IN :mapQuoteIdCorretorAccId.values() AND RecordType.DeveloperName = 'Contact'])
            {
                mapCorretorAccIdContact.put(varContact.AccountId, varContact); 
            }
        }
        List<Quote> toUpdateQuotes = new List<Quote>();
        for(Id quoteId : setQuoteId)
        {
            system.debug('mapCorretorAccIdContact: '+json.serializePretty(mapCorretorAccIdContact));
            
            map<String, Object> broker = new map<String, Object>();
            broker.put('name', mapCorretorAccIdContact.get(mapQuoteIdCorretorAccId.get(quoteId)).Name);
            broker.put('email', mapCorretorAccIdContact.get(mapQuoteIdCorretorAccId.get(quoteId)).Email);
            broker.put('QuoteNumber', mapQuoteIdNumber.get(quoteId));
            broker.put('QuoteId', quoteId);
            
            map<String, Object> legalResp = new map<String, Object>();
            legalResp.put('name', mapCustomerAccIdContact.get(mapQuoteIdAccId.get(quoteId)).name);
            legalResp.put('email', mapCustomerAccIdContact.get(mapQuoteIdAccId.get(quoteId)).Email);
            
            Pagereference pdf = Page.TermoAditamento;
            pdf.getParameters().put('Id', quoteId);
            system.debug('before-generate-blob');
            Blob body = !Test.isRunningTest() ? pdf.getContentAsPdf() : Blob.valueOf('Fake content');
            String documentBase64 = EncodingUtil.base64Encode(body);
            system.debug('documentBase64-sub: ' + documentBase64);
            toUpdateQuotes.add(createEnvelopesForSub(broker, legalResp, documentBase64));
        }
        return toUpdateQuotes;
    }
    
    private static Quote createEnvelopesForSub(map<String, Object> broker,  map<String, Object> legalResp, String documentBase64)
    {
        IntegCreateEnvelopes integCreateEnvelopes = new IntegCreateEnvelopes();
        system.debug('broker: '+Json.serializePretty(broker));
        system.debug('legalResp: '+Json.serializePretty(legalResp));

        IntegCreateEnvelopes.RequestCreateEnvelopes objRequestCreateEnvelopes = builderRequestEnvelopesForSub(broker, legalResp, documentBase64);
        IntegCreateEnvelopes.ResponseCreateEnvelopes objResponseCreateEnvelopes = integCreateEnvelopes.createEnvelopes(objRequestCreateEnvelopes);
        
        system.debug('RESPONSE: '+Json.serializePretty(objResponseCreateEnvelopes));
        Quote varQuote = new Quote();
        if('sent'.equalsIgnoreCase(objResponseCreateEnvelopes?.status))
        {
            varQuote.Id = (String)broker.get('QuoteId');
            varQuote.EnvelopeId_Addition__c = objResponseCreateEnvelopes.envelopeId;
        }
        return varQuote;
    }
    private static IntegCreateEnvelopes.RequestCreateEnvelopes builderRequestEnvelopesForSub(map<String, Object> broker,  map<String, Object> legalResp, String documentBase64)
    {
        String quoteNumber = (String)broker.get('QuoteNumber');
        CM_User_Integration_DocuSign__mdt cmUserIntegrationDocuSing = CM_User_Integration_DocuSign__mdt.getInstance('Docusign');
        
        IntegCreateEnvelopes.RequestCreateEnvelopes objRequestCreateEnvelopes = new IntegCreateEnvelopes.RequestCreateEnvelopes();
        objRequestCreateEnvelopes.accountId = cmUserIntegrationDocuSing.Account_ID__c;
        objRequestCreateEnvelopes.documents = builderDocument(documentBase64, quoteNumber);
        objRequestCreateEnvelopes.emailSubject = 'Termo de Aditamento  - Porto Seguro saúde';
        objRequestCreateEnvelopes.recipients = builderEnvelopeRecipients(broker, legalResp);
        objRequestCreateEnvelopes.status = 'sent';
        
        system.debug('createEnvelopes Request: ' + JSON.serializePretty(objRequestCreateEnvelopes));
        return objRequestCreateEnvelopes;
    }
    
    private static List<IntegCreateEnvelopes.Documents> builderDocument(String documentBase64, String documentId)
    {
        IntegCreateEnvelopes.Documents objDocuments = new IntegCreateEnvelopes.Documents();
        objDocuments.documentBase64 = documentBase64;
        objDocuments.documentId = documentId;
        objDocuments.fileExtension = 'pdf';
        objDocuments.name = 'termo-de-aditamento.pdf';
        
        List<IntegCreateEnvelopes.Documents> lstDocuments = new List<IntegCreateEnvelopes.Documents>{objDocuments};
        
        return lstDocuments;        
    }
    private static IntegCreateEnvelopes.Recipients builderEnvelopeRecipients(map<String, Object> broker,  map<String, Object> legalResp)
    {
        List<IntegCreateEnvelopes.Signers> lstSigners = new List<IntegCreateEnvelopes.Signers>{createSignatures(1,broker), createSignatures(2,legalResp)};
        IntegCreateEnvelopes.Recipients objRecipients = new IntegCreateEnvelopes.Recipients();    
        objRecipients.Signers = lstSigners;
 
        return objRecipients;        
    }
    public static IntegCreateEnvelopes.Signers createSignatures (Integer index, map<String, Object> actor)
    {
        IntegCreateEnvelopes.signHereTabs signHereTabBroker = new IntegCreateEnvelopes.signHereTabs();
        signHereTabBroker.anchorString = 'ORSF#00'+String.valueOf(index);
        signHereTabBroker.anchorUnits = 'mms';
        signHereTabBroker.anchorXOffset = '0';
        signHereTabBroker.anchorYOffset = '0';
        signHereTabBroker.name = 'Please sign here';
        signHereTabBroker.optional = 'false';
        signHereTabBroker.recipientId = String.valueOf(index);
        signHereTabBroker.scaleValue = 1;
        signHereTabBroker.tabLabel = 'ORSF#00'+String.valueOf(index);
        List<IntegCreateEnvelopes.signHereTabs> lstSignHere = new List<IntegCreateEnvelopes.signHereTabs>{signHereTabBroker};
            
        IntegCreateEnvelopes.Tabs objTabsBroker = new IntegCreateEnvelopes.Tabs();
        objTabsBroker.signHereTabs = lstSignHere;
        
        IntegCreateEnvelopes.Signers brokerSigner = new IntegCreateEnvelopes.Signers();
        brokerSigner.email = (String)actor.get('email');
        brokerSigner.name = (String)actor.get('name');
        brokerSigner.recipientId = String.valueOf(index);
        brokerSigner.routingOrder = String.valueOf(index+1);
        brokerSigner.tabs = objTabsBroker;
        
        return brokerSigner;
    }
}