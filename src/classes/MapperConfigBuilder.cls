public class MapperConfigBuilder {
	private String mappingName;
	private Map<String, List<String>> objectMapping;
	private Map<String, FieldMappingRule> fieldMapping;
	private String defaultObjectMapping; 
	public MapperConfigBuilder(String mappingName){
		this.mappingName = mappingName;
		this.objectMapping = new Map<String, List<String>>();
		this.fieldMapping = new Map<String, FieldMappingRule>();
	}

	public MapperConfigBuilder addObjectMapping(String objectName, List<String> listToAdd){
		if(objectMapping.containsKey(objectName)){
			objectMapping.get(objectName).addAll(listToAdd);
		}else {
			objectMapping.put(objectName, listToAdd);
		}
		return this;
	}

	public MapperConfigBuilder addObjectMapping(String objectName, String wildcard){
		if(wildcard == '*'){
			defaultObjectMapping = objectName;
		}
		return this;
	}

	public MapperConfigBuilder addFieldMapping(String source, FieldMappingRule rule){
		fieldMapping.put(source, rule);
		return this;
	}

	public MapperConfigBuilder addFieldMapping(String objectName, String destination){
		addFieldMapping(objectName, new FieldMappingRule(destination, null));
		return this;
	}

	public MapperConfigBuilder addFieldMapping(Map<String, FieldMappingRule> fieldMappingMap){
		for(String key : fieldMappingMap.keySet()){
			addFieldMapping(key, fieldMappingMap.get(key));
		}
		return this;
	}

	public MapperConfigBuilder addFieldMapping(Map<String, String> fieldMappingMap){
		for(String key : fieldMappingMap.keySet()){
			addFieldMapping(key, fieldMappingMap.get(key));
		}
		return this;
	}

	public IFieldMapping build(){
		Map<String, Set<String>> objectMappingResult = new Map<String, Set<String>>();
		for(String key : objectMapping.keySet()){
			objectMappingResult.put(key, new Set<String>(objectMapping.get(key)));
		}
		FieldMapping result = new FieldMapping(objectMappingResult, fieldMapping);
		result.setDefaultMappingObject(defaultObjectMapping);
		return result;
	}

	public String getName(){
		return mappingName;
	}
}