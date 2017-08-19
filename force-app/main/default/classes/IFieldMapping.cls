public interface IFieldMapping {
	// Map<String, Set<String>> getObjectMapping();
	// Map<String, FieldMappingRule> getFieldMapping();
	// Boolean isConventionalMappingActivated();
	String getDefaultMappingObject();
	List<FieldMappingRule> getMappingRules();
	Set<String> getObjectNames();
}