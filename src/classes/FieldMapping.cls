public class FieldMapping implements IFieldMapping{

	public Map<String, Set<String>> objectMapping;
	public Map<String, FieldMappingRule> fieldMapping; 
	public String defaultMappingObject;

	public FieldMapping(Map<String, Set<String>> objectMapping, Map<String, FieldMappingRule> fieldMapping) {
		this.objectMapping = objectMapping;
		this.fieldMapping = fieldMapping;
	}

	public FieldMapping(Map<String, Set<String>> objectMapping, Map<String, String> fieldMapping) {
		this.objectMapping = objectMapping;
		Map<String, FieldMappingRule> mappingRuleMap = new Map<String, FieldMappingRule>();
		for(String key : fieldMapping.keySet()){
			mappingRuleMap.put(key, new FieldMappingRule(fieldMapping.get(key), null));
		}
		this.fieldMapping = mappingRuleMap;
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

	public void setDefaultMappingObject(String objectName){
		defaultMappingObject = objectName;
	}

	public String getDefaultMappingObject(){
		return defaultMappingObject;
	}
}