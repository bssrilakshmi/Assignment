public with sharing class CreateAnswerHandler {
	
	public void onAfterInsert(List<OpportunityLineItem> lstOLIs) {
		
		createAnswersAfterInsertingOLI(lstOLIs);
	}
	
	public void createAnswersAfterInsertingOLI(List<OpportunityLineItem> lstOLIs) {
		
		Set<Id> setProduct2Ids = new Set<Id>();
		List<Answer__c> lstAnswers = new List<Answer__c>();
		
		for(OpportunityLineItem objOLI: lstOLIs) {
			
			setProduct2Ids.add(objOLI.Product2Id);
		}
		
		System.debug('---setProduct2Ids--'+setProduct2Ids);
		
		List<Product2> lstProducts = [SELECT Product_Group__c FROM Product2 WHERE Id IN :setProduct2Ids];
		System.debug('---lstProducts--'+lstProducts);
	}
}