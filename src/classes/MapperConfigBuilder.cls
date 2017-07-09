public class MapperConfigBuilder {
	private String mappingName;
	private Map<String, List<String>> objectMapping;
	private Map<String, FieldMappingRule> fieldMapping;
	private String defaultObjectMapping; 

	public MapperConfigBuilder(String mappingName){
		this.mappingName = mappingName;
		system.debug('this.mappingName' + this.mappingName);
		this.objectMapping = new Map<String, List<String>>();
		this.fieldMapping = new Map<String, FieldMappingRule>();
	}

	/**
	 * adds fields to map to specific object 
	 * @param  objectName 
	 * @param  listToAdd  listToAdd of fields to add
	 * @return
	 */
	public MapperConfigBuilder addObjectMapping(String objectName, List<String> listToAdd){
		List<String> modifiedListToAdd = new List<String>();
		for(String field_i : listToAdd){
			if(String.isNotBlank(field_i)){
				modifiedListToAdd.add(field_i.toLowerCase());
			}
		}
		if(objectMapping.containsKey(objectName)){
			objectMapping.get(objectName).addAll(modifiedListToAdd);
		}else {
			objectMapping.put(objectName, modifiedListToAdd);
		}
		return this;
	}

	/**
	 * allows to add default object to map, right now, only  '*' is supported.
	 * @param  objectName 
	 * @param  wildcard   '*'
	 * @return
	 */
	public MapperConfigBuilder addObjectMapping(String objectName, String wildcard){
		if(wildcard == '*'){
			defaultObjectMapping = objectName;
		}
		return this;
	}

	/**
	 * adds source-destionation field mapping rule. 
	 * @param  source - name of field in source object
	 * @param  rule   -split rule 
	 * @return
	 */
	public MapperConfigBuilder addFieldMapping(String source, FieldMappingRule rule){
		if(String.isNotBlank(source)){
			fieldMapping.put(source.toLowerCase(), rule);
		}
		return this;
	}

	/**
	 * adds source-destionation field mapping rule. 
	 * @param  source - name of field in source object
	 * @param  destination   - name of field in destination object
	 * @return
	 */
	public MapperConfigBuilder addFieldMapping(String objectName, String destination){
		addFieldMapping(objectName, new FieldMappingRule(destination, null));
		return this;
	}

	/**
	 * adds multiple source-destionation field mapping rules. 
	 * @param  fieldMappingMap - 
	 * @return
	 */
	public MapperConfigBuilder addFieldMapping(Map<String, FieldMappingRule> fieldMappingMap){
		for(String key : fieldMappingMap.keySet()){
			addFieldMapping(key, fieldMappingMap.get(key));
		}
		return this;
	}

	/**
	 * adds multiple source-destionation field mapping rules. 
	 * @param  fieldMappingMap - (mapping rule without formatter)
	 * @return
	 */
	public MapperConfigBuilder addFieldMapping(Map<String, String> fieldMappingMap){
		for(String key : fieldMappingMap.keySet()){
			addFieldMapping(key, fieldMappingMap.get(key));
		}
		return this;
	}

	/**
	 * builds mapping config 
	 * @return   returns config to be used in 'SObjectMapper.initialize()' method
	 */
	public IFieldMapping build(){
		Map<String, Set<String>> objectMappingResult = new Map<String, Set<String>>();
		for(String key : objectMapping.keySet()){
			objectMappingResult.put(key, new Set<String>(objectMapping.get(key)));
		}
		FieldMapping result = new FieldMapping(objectMappingResult, fieldMapping);
		result.setDefaultMappingObject(defaultObjectMapping);
		return result;
	}

	/**
	 * returns scheme name, should match with IResourceProvider.getName()
	 * @return
	 */
	public String getName(){
		return mappingName;
	}
}