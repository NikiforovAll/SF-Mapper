public class MapperConfigBuilder {
	private String mappingName;
	private Map<String, List<String>> objectMapping;
	private List<Tuple2> fieldMappingContainer; 
	private Boolean isConventionalMappingIsEnabled;
 

	private List<FieldMappingRule> fieldMapping;

	private String defaultObjectMapping; 

	public MapperConfigBuilder(String mappingName){
		this.mappingName = mappingName;
		// system.debug('this.mappingName' + this.mappingName);
		this.objectMapping = new Map<String, List<String>>();
		this.fieldMapping = new List<FieldMappingRule>();
		this.fieldMappingContainer = new List<Tuple2>();
		this.isConventionalMappingIsEnabled = false;
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
	public MapperConfigBuilder addFieldMapping(FieldMappingRule rule){
		fieldMapping.add(rule);
		return this;
	}

	/**
	 * adds source-destionation field mapping rule. 
	 * @param  source - name of field in source object
	 * @param  destination   - name of field in destination object
	 * @return
	 */
	public MapperConfigBuilder addFieldMapping(String source, String destination){
		fieldMappingContainer.add(new Tuple2(source, destination));
		return this;
	}

	/**
	 * adds multiple source-destionation field mapping rules. 
	 * @param  fieldMappingMap - 
	 * @return
	 */
	public MapperConfigBuilder addFieldMapping(List<FieldMappingRule> fieldMappingList){
		fieldMapping.addAll(fieldMappingList);
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

	public MapperConfigBuilder setConventionalMapping(Boolean isActivated){
		this.isConventionalMappingIsEnabled = isActivated;
		return this;
	}

	/**
	 * builds mapping config 
	 * @return   returns config to be used in 'SObjectMapper.initialize()' method
	 */
	public IFieldMapping build(){
		List<FieldMappingRule> resultList = new List<FieldMappingRule> (this.fieldMapping);
		FieldMapping result = new FieldMapping(resultList);
		Boolean isDefaultObjectMappingEnabled = false;
		if(String.isNotBlank(defaultObjectMapping)){
			result.setDefaultMappingObject(defaultObjectMapping);
			isDefaultObjectMappingEnabled = true;
			result.setDefaultObjectMapping(isDefaultObjectMappingEnabled);
		}
		for(Tuple2 tuple_i : this.fieldMappingContainer){
			String source = tuple_i.val1;
			if(String.isBlank(source)){
				continue;
			}
			String currObjectName = findObjectByField(source, isDefaultObjectMappingEnabled);
			if(String.isNotBlank(currObjectName)){
				resultList.add(new FieldMappingRule(source, tuple_i.val2, currObjectName));
			}
		}
		List<FieldMappingRule> mappingRulesCreatedByDefault = new List<FieldMappingRule>();
		if(this.isConventionalMappingIsEnabled){
			for(String objectName_i : objectMapping.keySet()){
				List<String> destinationMappingList = objectMapping.get(objectName_i);
				for(String sourceField_i : destinationMappingList){
					Boolean isFoundAppropriateMappingRule = false;
					for(FieldMappingRule rule_i : resultList){
						if(rule_i.source.toLowerCase() == sourceField_i.toLowerCase()){
							isFoundAppropriateMappingRule = true;
							break;
						}
					}
					if(!isFoundAppropriateMappingRule){
						String destinationField = sourceField_i;
						if(destinationField.contains(':')){
							List<String> nameTokens = destinationField.split(':');
							destinationField = nameTokens[nameTokens.size() - 1];
						}
						mappingRulesCreatedByDefault.add(new FieldMappingRule(sourceField_i, destinationField, objectName_i));
					}
				}
			}
		}
		resultList.addAll(mappingRulesCreatedByDefault);
		resultList.sort();
		// system.debug('build.mappingRulesCreatedByDefault ' + mappingRulesCreatedByDefault);
		system.debug('build.resultList ' + resultList);
		// system.debug('build.result ' + result);
		return result;
	}

	/**
	 * returns scheme name, should match with IResourceProvider.getName()
	 * @return
	 */
	public String getName(){
		return mappingName;
	}

	private String findObjectByField(String fieldName, Boolean defaultMapping){
		String resultObjectName = '';
		Boolean isFound = false;
		for(String objectName_i : this.objectMapping.keySet()){
			for(String sourceField_i : this.objectMapping.get(objectName_i)){
				if(fieldName.toLowerCase() == sourceField_i.toLowerCase()){
					resultObjectName = objectName_i;
					isFound = true;
					break;
				}
			}
			if(isFound){
				break;
			}
		}
		if(!isFound  && defaultMapping){
			resultObjectName = defaultObjectMapping;
		}
		return resultObjectName;
	}
	private class Tuple2{
		public String val1 {get; set;}
		public String val2 {get; set;}

		public Tuple2(String val1, String val2){
			this.val1 = val1;
			this.val2 = val2;
		}
	}
	
}