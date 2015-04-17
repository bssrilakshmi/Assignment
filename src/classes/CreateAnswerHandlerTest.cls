/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class CreateAnswerHandlerTest {

    static testMethod void myUnitTest() {
    	
    	List<Product_Group__c> lstProductGroups = new List<Product_Group__c>();
    	List<Product2> lstProducts = new List<Product2>();
    	List<Opportunity> lstOpportunities = new List<Opportunity>();
    	List<OpportunityLineItem> lstOpportunityLineItems = new List<OpportunityLineItem>();
    	List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
    	List<Question__c> lstQuestions = new List<Question__c>();
    	List<Answer__c> lstAnswers = new List<Answer__c>();
    	
    	//Create a dummy account
    	Account acc = new Account(Name='Test Account');
        insert acc;
        
        //Create 2 product groups.
        lstProductGroups.add(new Product_Group__c(Name='PG 1'));
        lstProductGroups.add(new Product_Group__c(Name='PG 2'));
        
        insert lstProductGroups;
        
        //Get the Standard PriceBook and make sure it is active
        Pricebook2 pBook = 	[	SELECT Id, Name 
        						FROM Pricebook2 
        						WHERE IsStandard = true
        					];

        pBook.IsActive = true;
        update pBook;
        
        //Create three products
        lstProducts.add(new Product2(Name='P1', Product_Group__c = lstProductGroups[0].Id));
        lstProducts.add(new Product2(Name='P2', Product_Group__c = lstProductGroups[0].Id));
        lstProducts.add(new Product2(Name='P3', Product_Group__c = lstProductGroups[1].Id));
        
        insert lstProducts;
        
        //Create pricebook entries for the products
        lstPricebookEntry.add(new PricebookEntry(Pricebook2Id=pBook.Id, Product2Id=lstProducts[0].id, UnitPrice=100, IsActive=true));
        lstPricebookEntry.add(new PricebookEntry(Pricebook2Id=pBook.Id, Product2Id=lstProducts[1].id, UnitPrice=200, IsActive=true));
        lstPricebookEntry.add(new PricebookEntry(Pricebook2Id=pBook.Id, Product2Id=lstProducts[2].id, UnitPrice=200, IsActive=true));
        
        insert lstPricebookEntry;
        
        //Create questions.
        lstQuestions.add(new Question__c(Product_Group__c = lstProductGroups[0].Id, Type__c = 'Text', Question__c = 'Question 1 of type text?'));
        lstQuestions.add(new Question__c(Product_Group__c = lstProductGroups[0].Id, Type__c = 'Picklist', Question__c = 'Question 1 of type picklist?'));
        lstQuestions.add(new Question__c(Product_Group__c = lstProductGroups[1].Id, Type__c = 'Text', Question__c = 'Question 1 of type text?'));
        lstQuestions.add(new Question__c(Product_Group__c = lstProductGroups[1].Id, Type__c = 'Radio button', Question__c = 'Question 1 of type radio button?'));
        
        insert lstQuestions;
        
        //Create new opportunities.
        lstOpportunities.add(new Opportunity(Name = 'Opp1', CloseDate = Date.today(), StageName = 'Prospecting'));
        lstOpportunities.add(new Opportunity(Name = 'Opp2', CloseDate = Date.today()+1, StageName = 'Prospecting'));
        
        insert lstOpportunities;
        
        //Create new opportunity line items.		
		lstOpportunityLineItems.add(new OpportunityLineItem(OpportunityId=lstOpportunities[0].id, PriceBookEntryId=lstPricebookEntry[0].id, Quantity=1, TotalPrice=300));
        lstOpportunityLineItems.add(new OpportunityLineItem(OpportunityId=lstOpportunities[0].id, PriceBookEntryId=lstPricebookEntry[1].id, Quantity=1, TotalPrice=300));
        lstOpportunityLineItems.add(new OpportunityLineItem(OpportunityId=lstOpportunities[0].id, PriceBookEntryId=lstPricebookEntry[2].id, Quantity=1, TotalPrice=300));
        lstOpportunityLineItems.add(new OpportunityLineItem(OpportunityId=lstOpportunities[1].id, PriceBookEntryId=lstPricebookEntry[0].id, Quantity=1, TotalPrice=300));
        
        Test.startTest();
        
        insert lstOpportunityLineItems;
        
        List<Answer__c> lstAnswers1 = [SELECT Opportunity__c, Product__c, Question__c, Question__r.Type__c, Answer__c FROM Answer__c WHERE Opportunity__c = :lstOpportunities[0].id];
        List<Answer__c> lstAnswers2 = [SELECT Opportunity__c, Product__c, Question__c, Question__r.Type__c, Answer__c FROM Answer__c WHERE Opportunity__c = :lstOpportunities[1].id];
        
        System.assertEquals(6, lstAnswers1.size());
        System.assertEquals(2, lstAnswers2.size());
        
        ApexPages.StandardController controller;
       	
       	/*Opportunity objOpportunity =	[	SELECT Total_number_of_questions_answered__c, Total_number_of_questions_pending__c 
											FROM Opportunity 
											WHERE Id = :lstOpportunities[0].id
										];*/
										
       	//List<Opportunity> lstOpportunities1 = ;
        CaptureAnswers objCaptureAnswers = new CaptureAnswers(controller);
        
        List<SelectOption> lstSelectOption = objCaptureAnswers.getPicklistValues();
        
        for(Answer__c objAns: lstAnswers1) {
        	
        	if(objAns.Question__r.Type__c == 'Text') {
        		
        		objAns.Answer__c = 'Text type';
        	
        	} else if(objAns.Question__r.Type__c == 'Picklist') {
        		
        		objAns.Answer__c = lstSelectOption[0].getValue();
        	
        	} else if(objAns.Question__r.Type__c == 'Radio button') {
        		
        		objAns.Answer__c = 'Yes';
        	}
        	
        	lstAnswers.add(objAns);
        }
        
        Database.update(lstAnswers);
        
        objCaptureAnswers.btnSave();
        
        List<Answer__c> lstAnswers3 = [SELECT Opportunity__c, Product__c, Question__c, Question__r.Type__c, Answer__c FROM Answer__c WHERE Opportunity__c = :lstOpportunities[0].id];
        
        System.assertEquals('Text type', lstAnswers3[0].Answer__c);
        
        Test.stopTest();
    }
}