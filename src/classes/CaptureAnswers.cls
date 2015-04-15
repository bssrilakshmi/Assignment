public with sharing class CaptureAnswers {
	
	public List<Product_Group__c> lstProductGroups {get;set;} 
	public Map<Id, Map<String, Question__c>> mapProductGroups {get;set;} 
	public String oppId;
	public Map<String, String> mapQuestionsByProduct {get;set;} 
	
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
		
		mapQuestionsByProduct =  new Map<String, String>();
		
		for(Answer__c objAnswer: [SELECT Question__c, Question__r.Question__c, Product__c, Product__r.Name, Opportunity__c FROM Answer__c WHERE Opportunity__c = :oppId]) {
			
			if(mapQuestionsByProduct.get(objAnswer.Product__r.Name) == null){
                
				mapQuestionsByProduct.put(objAnswer.Product__r.Name , objAnswer.Question__r.Question__c);
			}
			
			mapQuestionsByProduct.put(objAnswer.Product__r.Name , objAnswer.Question__r.Question__c);
		}
		
		System.debug('---mapQuestionsByProduct--'+mapQuestionsByProduct);
	}
}