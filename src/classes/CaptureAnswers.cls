public with sharing class CaptureAnswers {
	
	public String oppId;
	public List<AnswersWrapper> lstAnswersWrapper {get; set;}
	public List<Product_Group__c> lstProductGroups {get;set;} 
	public Map<Id, Map<String, Question__c>> mapProductGroups {get;set;} 
	public Map<String, String> mapQuestionsByProduct {get;set;} 
	public Set<Id> setProduct2Ids = new Set<Id>();
	
	public class AnswersWrapper {
		
		public String productName {get;set;}
		public String question {get;set;}
		public String questionType {get;set;}
	}
	
	public CaptureAnswers(ApexPages.StandardController controller) {
		
		getQuestions();
	}
	
	public void getQuestions() {
		
		//Get the opportunity id of the record from where the page has been launched.
		oppId = ApexPages.currentPage().getParameters().get('id');
		
		//Get all products associated with that opportunity.
		List<OpportunityLineItem> lstOLI = 	[	SELECT Product2Id 
												FROM OpportunityLineItem 
												WHERE OpportunityId = :oppId
											];
		
		lstAnswersWrapper = new List<AnswersWrapper>();
        AnswersWrapper objAnsWrapper;
        
		for(OpportunityLineItem obj: lstOLI) {
		    
		    setProduct2Ids.add(obj.Product2Id);
		}
		
		mapQuestionsByProduct =  new Map<String, String>();
		
		for(Answer__c objAnswer: 	[	SELECT Question__c, Question__r.Question__c, Question__r.Type__c, Product__c, Product__r.Name, Opportunity__c 
										FROM Answer__c 
										WHERE Opportunity__c = :oppId 
										ORDER BY Product__r.Name
									]) {
			
			/*if(mapQuestionsByProduct.get(objAnswer.Product__r.Name) == null){
                
				mapQuestionsByProduct.put(objAnswer.Product__r.Name , objAnswer.Question__r.Question__c);
			}
			
			mapQuestionsByProduct.put(objAnswer.Product__r.Name , objAnswer.Question__r.Question__c);*/
			
			objAnsWrapper = new AnswersWrapper();
			objAnsWrapper.productName = objAnswer.Product__r.Name;
			objAnsWrapper.question = objAnswer.Question__r.Question__c;
			objAnsWrapper.questionType = objAnswer.Question__r.Type__c;

			lstAnswersWrapper.add(objAnsWrapper);
		}
	}
}