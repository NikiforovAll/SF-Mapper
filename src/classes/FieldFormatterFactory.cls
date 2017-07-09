public class FieldFormatterFactory {
	//factory method
	public static Map<Schema.DisplayType, IFieldFormatter> formatterFactory;
	static{
		// also can build factory dynamically from custom settings
		// e.g Type t= Type.forName(className); Type` instance =(Type`) t.newInstance();
		formatterFactory = new Map<Schema.DisplayType, IFieldFormatter>{
			Schema.DisplayType.Double => new StringToDecimalFormatter(),
			Schema.DisplayType.Integer => new StringToIntegerFormatter(),
			Schema.DisplayType.Boolean => new StringToBooleanFormatter(),
			Schema.DisplayType.Date => new StringToDateFormatter(),
			Schema.DisplayType.DateTime => new StringToDateTimeFormatter()
		};
	}

	/**
	 * createFieldFormatter description
	 * @param  displayType displayType description
	 * @return             return description
	 */
	public static IFieldFormatter createFieldFormatter(Schema.DisplayType displayType){
		if(formatterFactory.containsKey(displayType)){
			return formatterFactory.get(displayType);
		}
		return null;
	}

	private static void LogFormatterError(Exception e){
		system.debug('[StringToDecimalFormatter.error]' +  e.getMessage());
		system.debug('\n' + e.getLineNumber());
		system.debug('\n' + e.getStackTraceString());
	}

	//TBD: move to separate files
	public virtual class BaseFormatter implements IFieldFormatter{
		public FormatterResult format(Object field){
			Object res;
			Boolean isSuccess = true;
			try{
				res = operation(field);
			}catch(Exception ex){
				isSuccess = false;
				LogFormatterError(ex);
			}
			return new FormatterResult(res, isSuccess);
		}

		protected virtual Object operation(Object field){
			return field;
		}

	}
	public class StringToDecimalFormatter extends BaseFormatter{
		protected override Object operation(Object field){
			 return Decimal.valueOf((String)field);
		}
	}

	public class StringToIntegerFormatter extends BaseFormatter{
		protected override Object operation(Object field){
			 return Integer.valueOf((String)field);
		}
	}

	public class StringToBooleanFormatter extends BaseFormatter{
		protected override Object operation(Object field){
			 return Boolean.valueOf((String)field);
		}
	}

	
	public class StringToDateFormatter extends BaseFormatter{
		protected override Object operation(Object field){
			 return Date.valueOf((String)field);
		}
	}

	public class StringToDateTimeFormatter extends BaseFormatter{
		protected override Object operation(Object field){
			 return DateTime.valueOf((String)field);
		}
	}
}