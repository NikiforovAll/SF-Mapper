public class SObjectMapper {
	private static Map<String,IFieldMapping> fieldMappingSource;
	static {
		fieldMappingSource = new Map<String, IFieldMapping>();
	}
	/**
	 * initializes mapping to be used in mapObject static method
	 * @param  objectName
	 * @param  fieldMapping
	 */
	public static void initialize(String objectName, IFieldMapping fieldMapping){
		system.debug('objectName.init  ' + objectName);
		if(fieldMappingSource.containsKey(objectName)){
			SObjectMapper.fieldMappingSource.remove(objectName);
		}
		SObjectMapper.fieldMappingSource.put(objectName, fieldMapping);
	}

	/**
	 * initializes mapping to be used in mapObject static method
	 * @param  fieldMapping
	 */
	public static void initialize(MapperConfigBuilder builder){
		IFieldMapping fieldMapping = builder.build();
		initialize(builder.getName(), fieldMapping);
	}


	public static Boolean isInitialized(String schemeName){
		return fieldMappingSource.containsKey(schemeName);
	}
	/**
	 * splits source into sobject map based on config from initialize method //TBD: need refactoring 
	 * NOTE: in order to support heirarchies you need to pass already built sObjectsContainerList that contains valid structure of paranets containers
	 * //TBD: provide capability to build sObjectsContainerList based on field mapping rules
	 * @param  source
	 * @param  fieldMappingSource
	 * @param  mappedObjects
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static List<SObjectContainer> mapObject(IResourceProvider source, List<SObjectContainer> sObjectsContainerList, String mappingName){
		return mapObject(source, mappingName, sObjectsContainerList, new MappingLogger(false));
	}

	public static List<SObjectContainer> mapObject(List<IResourceProvider> sourceList, String mappingName, List<SObjectContainer> sObjectsContainerList, MappingLogger logger){
		for(IResourceProvider provider_i : sourceList){
			List<SObjectContainer> currList = new List<SObjectContainer>();
			mapObject(provider_i, mappingName, currList, logger);
			sObjectsContainerList.addAll(currList);
		}
		return sObjectsContainerList;
	}
	public static List<SObjectContainer> mapObject(IResourceProvider source, String mappingName, List<SObjectContainer> sObjectsContainerList, MappingLogger logger){
		String describeMappingName = String.isNotBlank(mappingName) ?  mappingName : source.getName();
		if(!SObjectMapper.fieldMappingSource.containsKey(describeMappingName)){
			String errorMessage = 'Field mapping for this object is empty. Make sure SObjectMapper.initialize was invoked.';
			if(logger.isActive){
				logger.addLog(new MappingLog(errorMessage, MappingLogger.LogType.Error));
				system.debug(errorMessage);
				return sObjectsContainerList;
			}else{
				throw new SplitException(errorMessage);
			}
		}
		IFieldMapping fieldMappingSource = SObjectMapper.fieldMappingSource.get(describeMappingName);
		// Map<String, Set<String>> objectMapping = fieldMappingSource.getObjectMapping();
		Set<String> objectNameSet = fieldMappingSource.getObjectNames();
		// Map<String, FieldMappingRule> fieldMapping = fieldMappingSource.getfieldMapping();
		Map<String, Schema.SObjectType> objectNameToObjectTypeMap = new Map<String,Schema.SObjectType>();
		Map<String, Map<String, Schema.SObjectField>> objectNameToFieldInfoMap = new Map<String, Map<String, Schema.SObjectField>>();
		String defaultObjectToMapName = fieldMappingSource.getDefaultMappingObject();
		if(!objectNameSet.contains(defaultObjectToMapName) && String.isNotBlank(defaultObjectToMapName)){
			objectNameSet.add(defaultObjectToMapName);
		}
		try{
			if(!source.build()){
				throw new SplitException('source build failed');
			}
		}catch(Exception e){
			String shortErrorMessage = e.getMessage();
			String errorMessage = shortErrorMessage + e.getStackTraceString();
			if(logger.isActive){
				logger.addLog(new MappingLog(errorMessage, shortErrorMessage, MappingLogger.LogType.Error));
				system.debug(errorMessage);
				return sObjectsContainerList;
			}else{
				throw new SplitException(errorMessage);
			}
			
			logger.addLog(new MappingLog(errorMessage, shortErrorMessage, MappingLogger.LogType.Error));
			system.debug(errorMessage);
		}
		for(String objectName: objectNameSet){
			Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
			if(convertType == null){
				String errorMessage = 'Cannot find sObject to split. [' + objectName + ']';
				if(logger.isActive){
					logger.addLog(new MappingLog(errorMessage, MappingLogger.LogType.Error));
					continue;
				}else{
					throw new SplitException(errorMessage);
				}
			}
			objectNameToObjectTypeMap.put(objectName, convertType);
			objectNameToFieldInfoMap.put(objectName, convertType.getDescribe().fields.getMap());
		}
		for(FieldMappingRule mappingRule : fieldMappingSource.getMappingRules()){
			SObjectMapperManager manager = new SObjectMapperManager();
			manager
				.setFieldToCopy(mappingRule.source)
				.setObjectToMapName(mappingRule.objectName, defaultObjectToMapName)
				.setContainerId(mappingRule.getContainerId(), defaultObjectToMapName)
				.setFieldInfoMap(objectNameToFieldInfoMap)
				.setObjectInfoMap(objectNameToObjectTypeMap)
				.setLogger(logger);
			ResourceProviderResult valueToWrite = source.getValue(manager.fieldToCopy);
			manager.setValueToWrite(valueToWrite);

			if(String.IsBlank(manager.objectToMapName)){
				logger.addLog(new MappingLog('objectToMapName is blank, skipped mapping rule ', MappingLogger.LogType.Warning));
				continue;
			}
			manager
				.setFieldToMap(mappingRule.destination)
				.setFormatter(mappingRule.formatter);

			if(valueToWrite == null || valueToWrite.isEmpty()){
				String errorMessage = 'Value not found' + ' [from ' + manager.fieldToCopy + ' to ' + manager.childObjectFieldName + ']';
				logger.addLog(new MappingLog(errorMessage, errorMessage, MappingLogger.LogType.Warning));
				system.debug(errorMessage);
				continue;
			}
			// system.debug('valueToWrite.isMultipleData() ' + valueToWrite.isMultipleData());
			if(valueToWrite.isMultipleData()){
				String decompositionNode = mappingRule.getDecompositionNode();
				String currContainerParentId = mappingRule.getParentContainerId();
				Boolean manyToManyEnabled = mappingRule.getManyToManyEnabled();
				manager.writeMultipleDataContainer(decompositionNode, currContainerParentId, manyToManyEnabled, sObjectsContainerList);
			}else{
				if(mappingRule.getOneToManyEnabled()){
					String groupName = manager.containerToMapID;
					manager.writeToContainerGroup(groupName, sObjectsContainerList);
				}else{
					String currContainerParentId = mappingRule.getParentContainerId();
					String containerToMapID = manager.containerToMapId;
					manager.writeToSingleContainer(containerToMapID, currContainerParentId, sObjectsContainerList);
				}
			}
		}
		return sObjectsContainerList;
	}

	public static Map<String, SObject> mapObject(IResourceProvider source, Map<String, SObject> mappedObjects, String mappingName){
		//for backwards API compatability
		List<SObjectContainer> result =  mapObject(source, SObjectContainerUtil.transfromSObjectMapToContainerList(mappedObjects), mappingName);
		return SObjectContainerUtil.transfromContainerListToSObjectMap(result);
	}
	/**
	 * splits sobject into sobject map based on config from initialize method 
	 * @param  sObjectTomap
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(SObject sObjectTomap){
		return mapObject(new SObjectResourceProvider(sObjectTomap), new Map<String, sObject>(), '');
	}

	/**
	 * splits sobject into sobject map based on config from initialize method 
	 * @param  sobject
	 * @param  mappedObjects
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(SObject sObjectTomap, Map<String, sObject> mappedObjects){
		return mapObject(new SObjectResourceProvider(sObjectTomap), mappedObjects, '');
	}

	/**
	 * splits source into sobject map based on config from initialize method 
	 * @param  source
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(IResourceProvider source){
		return mapObject(source, new Map<String, sObject>(), '');
	}

	/**
	 * splits source into sobject map based on config from initialize method 
	 * @param  source
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(IResourceProvider source, String mappingName){
		return mapObject(source, new Map<String, sObject>(), mappingName);
	}
	
	/**
	 * splits source into sobject map based on config from initialize method 
	 * @param  source
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(IResourceProvider source, Map<String, sObject> mappedObjects){
		return mapObject(source, mappedObjects, '');
	}


	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(SObject sobjectToMap){
		return mapSingleObject(new SObjectResourceProvider(sobjectToMap));
	}

	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source){
		Map<String, SObject> result = SObjectMapper.mapObject(source);
		if(result.values().size() > 1){
			throw new SplitException('map ambiguity condition. Use mapSingleObject(String name) instead.');
		}
		return result.values()[0];
	}

	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(SObject source, Map<String, sObject> mappedObjects){
		return mapSingleObject(new SObjectResourceProvider(source), mappedObjects);
	}

	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, Map<String, sObject> mappedObjects){
		Map<String, SObject> result = SObjectMapper.mapObject(source, mappedObjects);
		if(result.values().size() > 1){
			throw new SplitException('map ambiguity condition. Use mapSingleObject(String name) instead.');
		}
		return result.values()[0];
	}

	/**
	 * splits source into sobject map based on config from initialize method and return entity specified by name parameter 
	 * @param  source 
	 * @param  name - name of result object (note: note name of mapping config)
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, String name){
		return mapSingleObject(source, new Map<String, SObject>(), name);
	}

	/**
	 * splits source into sobject map based on config from initialize method and return entity specified by name parameter 
	 * @param  source
	 * @param  mappedObjects
	 * @param  name - name of result object (note: note name of mapping config)
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, Map<String, SObject> mappedObjects, String name){
		Map<String, SObject> result = SObjectMapper.mapObject(source, mappedObjects);
		if(result.containsKey(name)){
			return result.get(name);
		}else{
			throw new SplitException('Object is not found. Make sure that name is appropriate.');
		}
	}




	public class SplitException extends Exception{}
}