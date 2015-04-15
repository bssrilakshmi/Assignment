public with sharing class CaptureAnswers {
	
	public List<Product_Group__c> lstProductGroups {get;set;} 
	public Map<Id, List<Question__c>> mapProductGroups {get;set;} 
	public String oppId;
	
	public CaptureAnswers(ApexPages.StandardController controller) {

	}
	
	public void getQuestions() {
		
		//Get the opportunity id of the record from where the page has been launched.
		oppId = ApexPages.currentPage().getParameters().get('id');
		System.debug('---oppId--'+oppId);
		
		//Get all products associated with that opportunity.
		List<OpportunityLineItem> lstOLI = [SELECT Product2Id FROM OpportunityLineItem WHERE OpportunityId= :oppId];
		Set<Id> setProduct2Ids = new Set<Id>();
		System.debug('---lstOLI--'+lstOLI);
		
		for(OpportunityLineItem obj: lstOLI) {
		    
		    setProduct2Ids.add(obj.Product2Id);
		}
		
		System.debug('---setProduct2Ids--'+setProduct2Ids);
		
		//Get the Answer for 
		List<Answer__c> lstAnswers = [SELECT Question__c, Product__c, Opportunity__c FROM Answer__c WHERE Opportunity__c = :oppId];
		
		System.debug('---lstAnswers--'+lstAnswers);
	}
}