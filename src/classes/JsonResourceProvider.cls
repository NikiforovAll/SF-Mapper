public class JsonResourceProvider implements IResourceProvider{
	//TBD: support nested json by providing object flattening 
	private Map<String, Object> sourceMap {get; set;}
	private String objectName;
	private Set<String> fields;

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
	 * JsonResourceProvider description
	 * @param  sourceObject
	 * @param  describeInfo allows to limit fields to copy 
	 */ 
	public JsonResourceProvider(String sourceString, Set<string> describeInfo) {
		this(sourceString);
		this.fields = describeInfo;
	}

	/**
	 * describeSource description
	 * @return   return description
	 */
	public Set<String> describeSource(){
		if(fields == null){
			fields = sourceMap.keySet();
			system.debug('JsonResourceProvider.describeSource ' + fields);
		}
		return fields;
	}

	/**
	 * getValue description
	 * @param  key key description
	 * @return     return description
	 */
	public Object getValue(String key){
		if(fields == null){
			describeSource();
		}
		if(sourceMap.containsKey(key)){
			return sourceMap.get(key);
		}
		return null;
	}

	/**
	 * getName description
	 * @return   return description
	 */
	public String getName(){
		return objectName;
	}
}