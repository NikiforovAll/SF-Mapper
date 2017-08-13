public class JsonResourceProvider implements IResourceProvider{
	//TBD: support nested json by providing object flattening 
	private Map<String, Object> sourceMap {get; set;}
	private String objectName;
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
		sourceMap = new Map<String, Object>();
		Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(sourceString);
		for(String key : jsonMap.keySet()){
			sourceMap.put(key.toLowerCase(), jsonMap.get(key));
		}
	}

	/**
	 * getName description
	 * @return   return description
	 */
	public String getName(){
		return objectName;
	}
	
	/**
	 * getValue description
	 * @param  key key description
	 * @return     return description
	 */
	public ResourceProviderResult getValue(String key){
		// if(fields == null){
		// 	describeSource();
		// }
		if(String.isBlank(key)){
			return null;
		}
		key = key.toLowerCase();
		List<Object> resultContainer = new List<Object>();
		getValueFromSource(key, this.sourceMap, resultContainer);
		system.debug('resultContainer ' + resultContainer);
		if(resultContainer.size() > 1){
			return new ResourceProviderResult(resultContainer, true);
		}else if(resultContainer.size() == 1){
			return new ResourceProviderResult(resultContainer[0], false);
		}
		return null;
	}

	private List<Object> getValueFromSource(String key, Map<String, Object> source, List<Object> resultContainer){
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
		//TBD: refactor
		if(isMultipleAccess){
			List<Object> currentModifiedObject;
			isMultipleAccess = true;
			currentModifiedObject = (List<Object>)currentObject;
			for(Object objectToProcess_i : currentModifiedObject){
				if(key.contains(fieldSeparator) && source.get(currentKey) != null){
					
						Map<String, Object>currentModifiedObject_i = (Map<String, Object>)objectToProcess_i;
						Map<String, Object> currentMapToLowerCaseKeys = new Map<String, Object>();
						for(String key_i : currentModifiedObject_i.keySet()){
							currentMapToLowerCaseKeys.put(key_i.toLowerCase(), currentModifiedObject_i.get(key_i));
						}
						getValueFromSource(key.substringAfter(fieldSeparator), currentMapToLowerCaseKeys, resultContainer);
				}else{
					currentObject = tryToSerializeJSONToken(currentObject);
					resultContainer.add(currentObject);
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
		resultContainer.add(currentObject);
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