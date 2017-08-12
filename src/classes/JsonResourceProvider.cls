public class JsonResourceProvider implements IResourceProvider{
	//TBD: support nested json by providing object flattening 
	private Map<String, Object> sourceMap {get; set;}
	private String objectName;
	// private Set<String> fields;

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
	public Object getValue(String key){
		// if(fields == null){
		// 	describeSource();
		// }
		if(String.isBlank(key)){
			return null;
		}
		key = key.toLowerCase();
		return getValueFromSource(key, this.sourceMap);
	}

	private Object getValueFromSource(String key, Map<String, Object> source){
		String currentKey = key.substringBefore(':');
		system.debug('currentKey ' + currentKey);
		if(!source.containsKey(currentKey)){
			return null;
		}
		Object currentObject = source.get(currentKey);
		system.debug('JsonResourceProvider.currentKey ' + currentKey);
		system.debug('JsonResourceProvider.currentObject ' + currentObject);
		
		if(key.contains(':') && source.get(currentKey) != null){
			//TBD: consider to cache, redundant map initialization and calculation of mapToLowerCaseKeys
			Map<String, Object> currentMapToLowerCaseKeys = new Map<String, Object>();
			Map<String, Object> currentMap = (Map<String, Object>)currentObject;
			for(String key_i : currentMap.keySet()){
				currentMapToLowerCaseKeys.put(key_i.toLowerCase(), currentMap.get(key_i));
			}
			return getValueFromSource(key.substringAfter(':'), currentMapToLowerCaseKeys);
		}
		//TBD: dirty approach
		try{
			object foo = (Map<String, Object>)currentObject;
			currentObject = JSON.serialize(foo);
		}catch(Exception ex){
		}	
		return currentObject;
	}

}