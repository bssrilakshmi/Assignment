public with sharing class CaptureAnswers {
	
	public String oppId;
	public List<AnswersWrapper> lstAnswersWrapper {get; set;}
	public List<Product_Group__c> lstProductGroups {get;set;} 
	public Map<Id, Map<String, Question__c>> mapProductGroups {get;set;} 
	public Map<String, String> mapQuestionsByProduct {get;set;} 
	public Set<Id> setProduct2Ids = new Set<Id>();
	public AnswersWrapper objAnsWrapper = new AnswersWrapper();
	
	public class AnswersWrapper {
		
		public String productName {get;set;}
		public String question {get;set;}
		public String questionType {get;set;}
		public String picklistValue {get;set;}
		public String answer {get;set;}
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
        //AnswersWrapper objAnsWrapper;
        
		for(OpportunityLineItem obj: lstOLI) {
		    
		    setProduct2Ids.add(obj.Product2Id);
		}
		
		mapQuestionsByProduct =  new Map<String, String>();
		
		for(Answer__c objAnswer: 	[	SELECT Question__c, Question__r.Question__c, Question__r.Type__c, Question__r.Picklist_Value__c, Product__c, Product__r.Name, Opportunity__c, Answer__c
										FROM Answer__c 
										WHERE Opportunity__c = :oppId 
										ORDER BY Product__r.Name, Question__r.Question__c
									]) {
			
			/*if(mapQuestionsByProduct.get(objAnswer.Product__r.Name) == null){
                
				mapQuestionsByProduct.put(objAnswer.Product__r.Name , objAnswer.Question__r.Question__c);
			}
			
			mapQuestionsByProduct.put(objAnswer.Product__r.Name , objAnswer.Question__r.Question__c);*/
			
			objAnsWrapper = new AnswersWrapper();
			objAnsWrapper.productName = objAnswer.Product__r.Name;
			objAnsWrapper.question = objAnswer.Question__r.Question__c;
			objAnsWrapper.questionType = objAnswer.Question__r.Type__c;
			objAnsWrapper.picklistValue = objAnswer.Question__r.Picklist_Value__c;
			objAnsWrapper.answer = objAnswer.Answer__c;
			lstAnswersWrapper.add(objAnsWrapper);
		}
	}
	
	public AnswersWrapper getAnswers {
		
		get{
			
			return objAnsWrapper;
		
		} set;
	}
	
	/*public List<SelectOption> getPicklistValues(){
		
		List<SelectOption> lstSelectOptions = new List<SelectOption>();
		
		for(Question__c objQuestion: lstProjects) {
			
			lstSelectOptions.add(new SelectOption(objProject.Name , objProject.Name));
		}
		
		return lstSelectOptions;
	}*/
	
	public List<SelectOption> getPicklistValues() {
		
		List<SelectOption> options = new List<SelectOption>();
        
		Schema.DescribeFieldResult fieldResult = Question__c.Picklist_Value__c.getDescribe();
		List<Schema.PicklistEntry> lstPicklist = fieldResult.getPicklistValues();
        
		for( Schema.PicklistEntry objPicklist : lstPicklist) {
			
			options.add(new SelectOption(objPicklist.getLabel(), objPicklist.getValue()));
		}       
		
		return options;
	}
}