public class FieldMapping implements IFieldMapping{

	public Map<String, Set<String>> objectMapping;
	public Map<String, String> fieldMapping; 

	public FieldMapping(Map<String, Set<String>> objectMapping, Map<String, String> fieldMapping) {
		this.objectMapping = objectMapping;
		this.fieldMapping = fieldMapping;
	}

	public FieldMapping(Map<String, Set<String>> objectMapping) {
		this(objectMapping, new Map<String, String>());
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
	public Map<String, String> getFieldMapping(){
		return fieldMapping;
	}
}