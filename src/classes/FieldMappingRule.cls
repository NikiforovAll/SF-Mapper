public class FieldMappingRule {
	public String destination {get;set;} 
	public IFieldFormatter formatter {get; set;}

	public FieldMappingRule(String destination, IFieldFormatter formatter) {
		this.destination = destination;
		this.formatter = formatter;
	}
	public FieldMappingRule(String destination) {
		this.destination = destination;
	}
}