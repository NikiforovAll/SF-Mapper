public class SObjectMapper {
	private static Map<String,IFieldMapping> fieldMappingSource;
	static {
		fieldMappingSource = new Map<String, IFieldMapping>();
	}
	/**
	 * initializes mapping to be used in mapObject static method
	 * @param  objectName
	 * @param  fieldMapping
	 */
	public static void initialize(String objectName, IFieldMapping fieldMapping){
		if(fieldMappingSource.containsKey(objectName)){
			SObjectMapper.fieldMappingSource.remove(objectName);
		}
		SObjectMapper.fieldMappingSource.put(objectName, fieldMapping);
	}

	/**
	 * splits source into sobject map based on config from initialize method 
	 * @param  source
	 * @param  fieldMappingSource
	 * @param  mappedObjects
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(IResourceProvider source, Map<String, SObject> mappedObjects){
		if(!SObjectMapper.fieldMappingSource.containsKey(source.getName())){
			throw new SplitException('Field mapping for this object is empty. Make sure SObjectMapper.initialize was invoked.');
		}
		IFieldMapping fieldMappingSource = SObjectMapper.fieldMappingSource.get(source.getName());
		Map<String, Set<String>> objectMapping = fieldMappingSource.getObjectMapping();
		Map<String, String> fieldMapping = fieldMappingSource.getfieldMapping();
		Map<String, Schema.SObjectType> objectNameToObjectTypeMap = new Map<String,Schema.SObjectType>();
		for(String objectName: objectMapping.keySet()){
			Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
			if(convertType == null){
				throw new SplitException('Cannot find sObject to split.');
			}
			objectNameToObjectTypeMap.put(objectName, convertType);
		}
		
		for(String fieldToCopy : source.describeSource()){
			if(source.getValue(fieldToCopy) == null){
				continue;
			}
			for(String objectName: objectMapping.keySet()){
				if(objectMapping.get(objectName).contains(fieldToCopy)){
					if(!mappedObjects.containsKey(objectName)){
						Schema.SObjectType convertType = objectNameToObjectTypeMap.get(objectName);
						SObject genericObject = convertType.newSObject();
						mappedObjects.put(objectName, genericObject);
					}
					string childObjectFieldName = fieldToCopy;
					if(fieldMapping.containsKey(fieldToCopy)){
						childObjectFieldName = fieldMapping.get(fieldToCopy);
					}
					object valueToWrite = source.getValue(fieldToCopy);
					if(valueToWrite != null){
						try{
							mappedObjects.get(objectName).put(childObjectFieldName, valueToWrite);
						}catch(Exception e){
							//TBD: remove
							if(e.getMessage().contains('String to Decimal')){
								system.debug('Error: String to Decimal conversation: (retry)');
								system.debug('fieldToCopy_i ' + fieldToCopy);
								mappedObjects.get(objectName).put(childObjectFieldName, Decimal.valueOf((String)valueToWrite));								
							}												
						}
					}
				}
			}
		}
		return mappedObjects;
	}

	/**
	 * splits source into sobject map based on config from initialize method 
	 * @param  source
	 * @param  fieldMappingSource
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(IResourceProvider source){
		return mapObject(source, new Map<String, sObject>());
	}

	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source){
		Map<String, SObject> result = SObjectMapper.mapObject(source);
		if(result.values().size() > 1){
			throw new SplitException('map ambiguity condition. Use mapSingleObject(String name) instead.');
		}
		return result.values()[0];
	}

	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, Map<String, sObject> mappedObjects){
		Map<String, SObject> result = SObjectMapper.mapObject(source, mappedObjects);
		if(result.values().size() > 1){
			throw new SplitException('map ambiguity condition. Use mapSingleObject(String name) instead.');
		}
		return result.values()[0];
	}

	/**
	 * splits source into sobject map based on config from initialize method and return entity specified by name parameter 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, String name){
		Map<String, SObject> result = SObjectMapper.mapObject(source);
		if(result.containsKey(name)){
			return result.get(name);
		}else{
			throw new SplitException('Object is not found. Make sure that name is appropriate.');
		}
	}

	/**
	 * splits source into sobject map based on config from initialize method and return entity specified by name parameter 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, String name, Map<String, sObject> mappedObjects){
		Map<String, SObject> result = SObjectMapper.mapObject(source, mappedObjects);
		if(result.containsKey(name)){
			return result.get(name);
		}else{
			throw new SplitException('Object is not found. Make sure that name is appropriate.');
		}
	}
	
	public class SplitException extends Exception{}
}