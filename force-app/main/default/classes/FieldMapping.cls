public class FieldMapping implements IFieldMapping{

	private Map<String, Set<String>> objectMapping;
	private Map<String, FieldMappingRule> fieldMapping; 
	private String defaultMappingObject;
	private Boolean isDefaultObjectMappingEnabled;
	private List<FieldMappingRule> fieldMappingRuleContainer;

	public FieldMapping(Map<String, Set<String>> objectMapping, Map<String, FieldMappingRule> fieldMapping) {
		this.objectMapping = objectMapping;
		this.fieldMapping = fieldMapping;
		this.fieldMappingRuleContainer = new List<FieldMappingRule>();
		this.isDefaultObjectMappingEnabled = false;
	}

	public FieldMapping(Map<String, Set<String>> objectMapping, Map<String, String> fieldMapping) {
		this.objectMapping = objectMapping;
		Map<String, FieldMappingRule> mappingRuleMap = new Map<String, FieldMappingRule>();
		for(String key : fieldMapping.keySet()){
			String objectName;
			for(String objectName_i : this.objectMapping.keySet()){
				if(objectMapping.get(objectName_i).contains(key)){
					objectName = objectName_i;
				}
			}
			mappingRuleMap.put(key, new FieldMappingRule(key, fieldMapping.get(key), objectName, null));
		}
		this.fieldMapping = mappingRuleMap;
		this.fieldMappingRuleContainer = new List<FieldMappingRule>();
		this.isDefaultObjectMappingEnabled = false;
	}

	public FieldMapping(List<FieldMappingRule> fieldMappingRuleContainer){
		this.fieldMappingRuleContainer = fieldMappingRuleContainer;
		this.objectMapping = new Map<String, Set<String>>();
		this.fieldMapping = new Map<String, FieldMappingRule>();
	}

	public FieldMapping(Map<String, Set<String>> objectMapping) {
		this(objectMapping, new Map<String, FieldMappingRule>());
	}

	/**
	 * getObjectMapping description
	 * @return   return description
	 */
	public Map<String, Set<String>> getObjectMapping(){
		return objectMapping;
	}
	
	/**
	 * getFieldMapping description
	 * @return   return description
	 */
	public Map<String, FieldMappingRule> getFieldMapping(){
		return fieldMapping;
	}
	/**
	 * sets default object name to map. 
	 * @param  objectName objectName description
	 */
	public void setDefaultMappingObject(String objectName){
		defaultMappingObject = objectName;
	}

	/**
	 * gets default object name to map. 
	 * @param  objectName objectName description
	 */
	public String getDefaultMappingObject(){
		return defaultMappingObject;
	}

	/**
	 * addFieldMappingRule description
	 * @param  rule rule description
	 */
	public void addFieldMappingRule(FieldMappingRule rule){
		this.fieldMappingRuleContainer.add(rule);
	}

	/**
	 * addFieldMappingRule description
	 * @param  rule rule description
	 */
	public void addFieldMappingRules(List<FieldMappingRule> ruleList){
		this.fieldMappingRuleContainer.addAll(ruleList);
	}

	/**
	 * getMappingRules description
	 * @return   return description
	 */
	public List<FieldMappingRule> getMappingRules(){
		List<FieldMappingRule> fieldMappingRuleCopy = new List<FieldMappingRule>();
		fieldMappingRuleCopy.addAll(fieldMappingRuleContainer);
		fieldMappingRuleCopy.addAll(this.fieldMapping.values());
		return fieldMappingRuleCopy;
	}

	/**
	 * getObjectNames description
	 * @return   return description
	 */
	public Set<String> getObjectNames(){
		Set<String> objectNameSet = new Set<String>();
		for(FieldMappingRule rule_i : getMappingRules()){
			if(!objectNameSet.contains(rule_i.objectName)){
				objectNameSet.add(rule_i.objectName);
			}
		}
		return objectNameSet;
	}

	/**
	 * setDefaultObjectMapping description
	 * @param  isActivated isActivated description
	 */
	public void setDefaultObjectMapping(Boolean isActivated){
		this.isDefaultObjectMappingEnabled = isActivated;
	}
}