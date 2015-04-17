public with sharing class CaptureAnswers {
	
	public String oppId;
	public List<Answer__c> lstAnswersWrapper {get; set;}
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
		
		lstAnswersWrapper = [	SELECT Question__c, Question__r.Question__c, Question__r.Type__c, Question__r.Picklist_Value__c, Product__c, Product__r.Name, Opportunity__c, Answer__c
								FROM Answer__c 
								WHERE Opportunity__c = :oppId 
								ORDER BY Product__r.Name, Question__r.Question__c
							];
	}
	
	public List<SelectOption> getPicklistValues() {
		
		List<SelectOption> lstSelectOption = new List<SelectOption>();
        
		Schema.DescribeFieldResult fieldResult = Question__c.Picklist_Value__c.getDescribe();
		List<Schema.PicklistEntry> lstPicklist = fieldResult.getPicklistValues();
        
		for( Schema.PicklistEntry objPicklist : lstPicklist) {
			
			lstSelectOption.add(new SelectOption(objPicklist.getLabel(), objPicklist.getValue()));
		}       
		
		return lstSelectOption;
	}
	
	public void btnSave() {
		
		System.debug('----lstAnswersWrapper------'+lstAnswersWrapper);
		
		Database.update(lstAnswersWrapper);
		getNoOfQuestions();
	}
	
	public void getNoOfQuestions() {
		
		lstProductName = new List<String>();
		lstNoOfQuestionsAnswered = new List<Integer>();
		
		System.debug('----lstProductName------'+lstProductName);
		
		lstCount = new List<AggregateResult>();
		
		lstCount =	[	SELECT Product__r.Name, Count(Id) 
						FROM Answer__c 
						WHERE Opportunity__c = :oppId AND Answer__c !='' 
						GROUP BY Product__r.Name
					];
					
		System.debug('----lstCount------'+lstCount);
		
		for(AggregateResult objAggRes: lstCount) {
			
			lstProductName.add((String)objAggRes.get('Name'));
			lstNoOfQuestionsAnswered.add((Integer)objAggRes.get('expr0'));
		}
		
		totalNoOfQuestionsAnswered = 0;
		
		for(Integer i=0; i<lstNoOfQuestionsAnswered.size(); i++) {
			
			totalNoOfQuestionsAnswered = totalNoOfQuestionsAnswered + lstNoOfQuestionsAnswered.get(i);
		}
		
		System.debug('----totalNoOfQuestionsAnswered------'+totalNoOfQuestionsAnswered);
		
		totalNoOfQuestionsPending = lstAnswersWrapper.size() - totalNoOfQuestionsAnswered;
		System.debug('----totalNoOfQuestionsPending------'+totalNoOfQuestionsPending);
	}
}