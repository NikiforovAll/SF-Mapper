public class JsonResourceProvider implements IResourceProvider{
	//TBD: support nested json by providing object flattening 
	private Map<String, Object> sourceMap {get; set;}
	private String objectName;
	private String sourceString; 
	// private Set<String> fields;
	private static final String fieldSeparator;
	private static final String iteratorSign; 
	static{
		fieldSeparator = ':';
		iteratorSign = '[i]';
	}

	/**
	 * JsonResourceProvider description
	 * @param  sourceString
	 */ 
	public JsonResourceProvider(String sourceString){
		this(sourceString, '');
	}
	/**
	 * JsonResourceProvider description
	 * @param  sourceString
	 */ 
	public JsonResourceProvider(String sourceString, String objectName){
		this.objectName = objectName;
		this.sourceString = sourceString;
		sourceMap = null;
	}

	/**
	 * getName description
	 * @return   return description
	 */
	public String getName(){
		return objectName;
	}

	public Boolean build(){
		if(sourceMap == null){
			sourceMap = new Map<String, Object>();
			Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(sourceString);
			for(String keyToCopy : jsonMap.keySet()){
				sourceMap.put(keyToCopy.toLowerCase(), jsonMap.get(keyToCopy));
			}
		}
		return true;
	}
	/**
	 * getValue description
	 * @param  key key description
	 * @return     return description
	 */
	public ResourceProviderResult getValue(String key){
		if(sourceMap == null){
			build();
		}		
		// if(fields == null){
		// 	describeSource();
		// }
		if(String.isBlank(key)){
			return null;
		}
		key = key.toLowerCase();
		ResourceProviderResult resultContainer = new ResourceProviderResult('root');
		getValueFromSource(key, this.sourceMap, resultContainer);
		// system.debug('resultContainer ' + resultContainer);
		
		return resultContainer;
	}

	private ResourceProviderResult getValueFromSource(String key, Map<String, Object> source, ResourceProviderResult resultContainer){
		//TBD: consider to cache, redundant map initialization and calculation of mapToLowerCaseKeys + refactoring + dirty approach, possible performance hit
		String currentKey = key.substringBefore(fieldSeparator);
		Boolean isMultipleAccess = false;
		if(currentKey.contains(iteratorSign)){
			isMultipleAccess = true;
			currentKey = currentKey.replace(iteratorSign, '');
		}
		if(!source.containsKey(currentKey)){
			return null;
		}
		Object currentObject = source.get(currentKey);
		// system.debug('JsonResourceProvider.key ' + key);
		// system.debug('JsonResourceProvider.currentKey ' + currentKey);
		// system.debug('JsonResourceProvider.currentObject ' + currentObject);
		// system.debug('JsonResourceProvider.isMultipleAccess ' + isMultipleAccess);
		//TBD: refactor
		if(isMultipleAccess){
			List<Object> currentModifiedObject;
			isMultipleAccess = true;
			currentModifiedObject = (List<Object>)currentObject;
			for(Object objectToProcess_i : currentModifiedObject){
				if(key.contains(fieldSeparator) && source.get(currentKey) != null){
						ResourceProviderResult currResultContainer_i = new ResourceProviderResult(currentKey);
						resultContainer.addContainerLeaf(currResultContainer_i);
						Map<String, Object>currentModifiedObject_i = (Map<String, Object>)objectToProcess_i;
						Map<String, Object> currentMapToLowerCaseKeys = new Map<String, Object>();
						for(String key_i : currentModifiedObject_i.keySet()){
							currentMapToLowerCaseKeys.put(key_i.toLowerCase(), currentModifiedObject_i.get(key_i));
						}
						getValueFromSource(key.substringAfter(fieldSeparator), currentMapToLowerCaseKeys, currResultContainer_i);
				}else{
					currentObject = tryToSerializeJSONToken(currentObject);
					// system.debug('resultContainer.addDataLeaf_1');
					resultContainer.addDataLeaf(currentObject);
				}
			}
			return resultContainer;
		}else if(key.contains(fieldSeparator) && source.get(currentKey) != null){
			Map<String, Object>currentModifiedObject = (Map<String, Object>)currentObject;
			Map<String, Object> currentMapToLowerCaseKeys = new Map<String, Object>();
			for(String key_i : currentModifiedObject.keySet()){
				currentMapToLowerCaseKeys.put(key_i.toLowerCase(), currentModifiedObject.get(key_i));
			}
			return getValueFromSource(key.substringAfter(fieldSeparator), currentMapToLowerCaseKeys, resultContainer);
		}
		currentObject = tryToSerializeJSONToken(currentObject);
		if(resultContainer.getNodeName() == 'root'){
			// system.debug('resultContainer.setData_1');
			resultContainer.setData(currentObject);
		}else{
			// system.debug('resultContainer.addDataLeaf_2');
			resultContainer.addDataLeaf(currentObject);
		}
		// resultContainer.addDataLeaf(currentObject);
		return resultContainer;
	}

	private Object tryToSerializeJSONToken(Object objectToProcess){
		//TBD: dirty approach 
		Object result = objectToProcess;
		try{
			// if(result instanceof Map<String, Object>){
			result = (Map<String, Object>)result;
			result = JSON.serialize(result);
			// }
		}catch(Exception mapException){
			try{
				// if(result instanceof List<Object>){
				result = (List<Object>)result;
				result = JSON.serialize(result);
				// }
			}catch(Exception arrayException){
			}
		}
		return result; 
	}

}