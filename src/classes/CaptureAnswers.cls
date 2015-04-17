public with sharing class CaptureAnswers {
	
	public String oppId;
	public List<Product2> lstProduct2AndAnswers {get; set;}
	public List<Product_Group__c> lstProductGroups {get;set;} 
	public List<String> lstProductName {get; set;}
	public List<Integer> lstNoOfQuestionsAnswered {get; set;}
	public Map<Id, Map<String, Question__c>> mapProductGroups {get;set;} 
	public Map<String, String> mapQuestionsByProduct {get;set;} 
	public Set<Id> setProduct2Ids = new Set<Id>();
	public Integer numberOfAnswerRecords;
	public List<AggregateResult> lstCount {get; set;}
	public Integer totalNoOfQuestionsAnswered {get; set;}
	public Integer totalNoOfQuestionsPending {get; set;}
	public List<Answer__c> lstAnswer = new List<Answer__c>();
	
	public CaptureAnswers(ApexPages.StandardController controller) {
		
		getQuestions();
		getNoOfQuestions();
	}
	
	public void getQuestions() {
		
		//Get the opportunity id of the record from where the page has been launched.
		oppId = ApexPages.currentPage().getParameters().get('id');
		
		//Get all products associated with that opportunity.
		List<OpportunityLineItem> lstOLI = 	[	SELECT Product2Id 
												FROM OpportunityLineItem 
												WHERE OpportunityId = :oppId
											];
		
		for(OpportunityLineItem obj: lstOLI) {
		    
		    setProduct2Ids.add(obj.Product2Id);
		}
		
		lstProduct2AndAnswers = [	SELECT Name, 
									(	SELECT Question__c, Question__r.Question__c, Question__r.Type__c, Question__r.Picklist_Value__c, Product__c, Product__r.Name, Opportunity__c, Answer__c 
										FROM Answers__r 
										WHERE Opportunity__c = :oppId ORDER BY Question__r.Question__c
									) 
									FROM Product2 
									WHERE Id 
									IN:setProduct2Ids
							];
	}
	
	//Get the picklist field on Question object.
	public List<SelectOption> getPicklistValues() {
		
		List<SelectOption> lstSelectOption = new List<SelectOption>();
        
		Schema.DescribeFieldResult fieldResult = Question__c.Picklist_Value__c.getDescribe();
		List<Schema.PicklistEntry> lstPicklist = fieldResult.getPicklistValues();
        
		for( Schema.PicklistEntry objPicklist : lstPicklist) {
			
			lstSelectOption.add(new SelectOption(objPicklist.getLabel(), objPicklist.getValue()));
		}       
		
		return lstSelectOption;
	}
	
	//Save the answer records on click of save button.
	public void btnSave() {
		
		for (Product2 objProduct : lstProduct2AndAnswers) {
			
			for(Answer__c objAnswer : objProduct.Answers__r) {
				
				lstAnswer.add(objAnswer);
			}
		}
		
		Database.update(lstAnswer);
		
		getNoOfQuestions();
	}
	
	//Get the no. of questions answered and unanswered for the opportunity.
	public void getNoOfQuestions() {
		
		Opportunity objOpportunity =	[	SELECT Total_number_of_questions_answered__c, Total_number_of_questions_pending__c 
											FROM Opportunity 
											WHERE Id = :oppId
										];
		
		totalNoOfQuestionsAnswered = (Integer)objOpportunity.Total_number_of_questions_answered__c;
		totalNoOfQuestionsPending = (Integer)objOpportunity.Total_number_of_questions_pending__c;
	}
}