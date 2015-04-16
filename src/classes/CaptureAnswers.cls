public with sharing class CaptureAnswers {
	
	public String oppId;
	public List<Answer__c> lstAnswersWrapper {get; set;}
	public List<Product_Group__c> lstProductGroups {get;set;} 
	public Map<Id, Map<String, Question__c>> mapProductGroups {get;set;} 
	public Map<String, String> mapQuestionsByProduct {get;set;} 
	public Set<Id> setProduct2Ids = new Set<Id>();
	public Integer numberOfAnswerRecords {get; set;}
	
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
		
		for(OpportunityLineItem obj: lstOLI) {
		    
		    setProduct2Ids.add(obj.Product2Id);
		}
		
		mapQuestionsByProduct =  new Map<String, String>();
		
		lstAnswersWrapper = [	SELECT Question__c, Question__r.Question__c, Question__r.Type__c, Question__r.Picklist_Value__c, Product__c, Product__r.Name, Opportunity__c, Answer__c
								FROM Answer__c 
								WHERE Opportunity__c = :oppId 
								ORDER BY Product__r.Name, Question__r.Question__c
							];
	}
	
	public List<SelectOption> getPicklistValues() {
		
		List<SelectOption> options = new List<SelectOption>();
        
		Schema.DescribeFieldResult fieldResult = Question__c.Picklist_Value__c.getDescribe();
		List<Schema.PicklistEntry> lstPicklist = fieldResult.getPicklistValues();
        
		for( Schema.PicklistEntry objPicklist : lstPicklist) {
			
			options.add(new SelectOption(objPicklist.getLabel(), objPicklist.getValue()));
		}       
		
		return options;
	}
	
	public void btnSave() {
		
		System.debug('----lstAnswersWrapper------'+lstAnswersWrapper);
		
		Database.update(lstAnswersWrapper);
	}
	
	public void btnCancel() {
		
	}
}