public class FormatterResult {
	public Boolean isSuccess { get; set; }
	public Object data { get;set; }

	public FormatterResult(Object data, Boolean isSuccess) {
		this.data = data;
		this.isSuccess = isSuccess;
	}
}