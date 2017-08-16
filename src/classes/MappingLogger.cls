public class MappingLogger {

	public Boolean isActive {get; set;} 
	private List<MappingLog> logs;

	public MappingLogger() {
		this(true);
	}

	public MappingLogger(Boolean isActive){
		this.logs = new List<MappingLog>();
		this.isActive = isActive;
	}

	public void addLog(MappingLog log){
		logs.add(log);
	}
	
	public List<MappingLog> getLogs(){
		return logs;
	}
	
	public enum LogType {
		Error, 
		Warning,
		Info
	}
}