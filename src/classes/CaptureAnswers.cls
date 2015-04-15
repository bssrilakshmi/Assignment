public with sharing class CaptureAnswers {
	
	public List<Product_Group__c> lstProductGroups {get;set;} 
	public Map<Id, List<Question__c>> mapProductGroups {get;set;} 
	public String oppId;
	
	public CaptureAnswers(ApexPages.StandardController controller) {

	}
	
	public void getQuestions() {
		
		oppId = ApexPages.currentPage().getParameters().get('id');
		System.debug('---oppId--'+oppId);
		
	
		List<OpportunityLineItem> lstOLI = [SELECT Product2Id FROM OpportunityLineItem WHERE OpportunityId= :oppId];
		Set<Id> setProduct2Ids = new Set<Id>();
		System.debug('---lstOLI--'+lstOLI);
		
		for(OpportunityLineItem obj: lstOLI) {
		    
		    setProduct2Ids.add(obj.Product2Id);
		}
		
		System.debug('---setProduct2Ids--'+setProduct2Ids);
		
		List<Answer__c> lst1 = [SELECT Question__c, Product__c FROM Answer__c WHERE Product__r.Id IN :setProduct2Ids];
		List<AggregateResult> lst2 = [SELECT Question__c, Product__c FROM Answer__c WHERE Product__r.Id IN :setProduct2Ids GROUP BY Product__c, Question__c];
		
		System.debug('---lst1--'+lst1);
		System.debug('---lst2--'+lst2);
	}
}