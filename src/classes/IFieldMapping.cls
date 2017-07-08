public interface IFieldMapping {
	Map<String, Set<String>> getObjectMapping();
	Map<String, FieldMappingRule> getFieldMapping();
	String getDefaultMappingObject();
}