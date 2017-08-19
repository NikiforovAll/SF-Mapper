public class MappingLog {
	public MappingLogger.LogType logType {get; set;}
	public String text {get; set;}
	public String shortText {get; set;}
	public String containerId {get; set;}

	public MappingLog(String text, String shortText, MappingLogger.LogType type, String containerId){
		this.text = text;
		this.shortText = shortText;
		this.logType = type;
		this.containerId = containerId;
	}

	public MappingLog(String text, String shortText, MappingLogger.LogType type){
		this(text, shortText, type, '');
	}
	
	public MappingLog(String text, MappingLogger.LogType type){
		this(text, text, type, '');
	}
}