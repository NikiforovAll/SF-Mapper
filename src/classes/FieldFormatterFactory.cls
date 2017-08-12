public class FieldFormatterFactory {
	//factory method
	public static Map<Schema.DisplayType, IFieldFormatter> formatterFactory;
	static{
		// also can build factory dynamically from custom settings
		// e.g Type t= Type.forName(className); Type` instance =(Type`) t.newInstance();
		formatterFactory = new Map<Schema.DisplayType, IFieldFormatter>{
			//decimal
			Schema.DisplayType.Double => new StringToDecimalFormatter(),
			Schema.DisplayType.Currency => new StringToDecimalFormatter(),
			Schema.DisplayType.Percent => new StringToDecimalFormatter(),
			//Integer
			Schema.DisplayType.Integer => new StringToIntegerFormatter(),
			//Boolean
			Schema.DisplayType.Boolean => new StringToBooleanFormatter(),
			Schema.DisplayType.Combobox => new StringToBooleanFormatter(),
			//Date
			Schema.DisplayType.Date => new StringToDateFormatter(),
			//DateTime
			Schema.DisplayType.DateTime => new StringToDateTimeFormatter()
		};
		//INFO: string types
		/*
			Schema.DisplayType.base64,
			Schema.DisplayType.Email,
			Schema.DisplayType.MultiPicklist,
			Schema.DisplayType.Phone,
			Schema.DisplayType.Picklist,
			Schema.DisplayType.String,
			Schema.DisplayType.TextArea,
			Schema.DisplayType.URL, 
			
			Schema.DisplayType.ID,
			Schema.DisplayType.Reference
		*/
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
		system.debug('[StringToDecimalFormatter.error]' +  e.getMessage() + '\n');
		system.debug(e.getLineNumber() + '\n');
		system.debug(e.getStackTraceString());
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
			return String.valueOf(field);
		}

	}
	public class StringToDecimalFormatter extends BaseFormatter{
		protected override Object operation(Object field){
			 return Decimal.valueOf((String)field);
		}
	}

	public class StringToIntegerFormatter extends BaseFormatter{
		protected override Object operation(Object field){
			system.debug('field ' + field);
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
			Date resultDate;
			try{
				resultDate = Date.parse((String)field);
			}catch(Exception ex){
				resultDate = Date.valueOf((String)field);
			}
			return resultDate;
		}
	}

	public class StringToDateTimeFormatter extends BaseFormatter{
		protected override Object operation(Object field){
			 return DateTime.valueOf((String)field);
		}
	}
}