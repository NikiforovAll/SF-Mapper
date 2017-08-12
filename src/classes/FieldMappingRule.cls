public class FieldMappingRule {
	public String source {get;set;}
	public String destination {get;set;} 
	public String objectName {get;set;}
	public IFieldFormatter formatter {get; set;}

	public FieldMappingRule(String source, String destination, String objectName, IFieldFormatter formatter) {
		//TBD: check for null poiter exception and cast custom exception
		this.source = source;
		this.destination = destination;
		this.objectName = objectName;
		this.formatter = formatter;
	}
	public FieldMappingRule(String source, String destination, String objectName) {
		this(source, destination, objectName, null);
	}
}