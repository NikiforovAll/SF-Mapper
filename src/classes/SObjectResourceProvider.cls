public class SObjectResourceProvider implements IResourceProvider{
	private Sobject sourceObject; 
	private String sObjectName;
	private Set<String> fields;

	public SObjectResourceProvider(SObject sourceObject) {
		this.sourceObject = sourceObject;
		if(sourceObject != null){
			this.sObjectName = sourceObject
				.getSObjectType()
				.getDescribe()
				.getName();
		}
	}
	
	/**
	 * SObjectResourceProvider description
	 * @param  sourceObject
	 * @param  describeInfo allows to limit fields to copy 
	 */ 
	public SObjectResourceProvider(SObject sourceObject, Set<string> describeInfo) {
		this(sourceObject);
		this.fields = describeInfo;
	}
	
	/**
	 * describeSource description
	 * @return   return description
	 */
	public Set<String> describeSource(){
		if(fields == null){
			Schema.SObjectType parentType = Schema.getGlobalDescribe().get(sObjectName);
			fields = parentType.getDescribe().fields.getMap().keySet();
			system.debug('SObjectResourceProvider.describeSource ' + fields);
		}
		return fields;
	}

	/**
	 * getValue description
	 * @param  key key description
	 * @return     return description
	 */
	public Object getValue(String key){
		if(fields == null) {
			describeSource();
		}
		if(fields.contains(key)){
			return sourceObject.get(key);
		}
		return null;
	}

	/**
	 * getName description
	 * @return   return description
	 */
	public String getName(){
		return sObjectName;
	}
}