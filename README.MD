SF Mapper
[![Build Status](https://travis-ci.org/NikiforovAll/SF-Mapper.svg?branch=master)](https://travis-ci.org/NikiforovAll/SF-Mapper)
==========================
### [What is SF Mapper?](https://github.com/NikiforovAll/SF-Mapper/wiki)

SF Mapper is a simple library build to solve really common problem - getting rid of code that mapped one source object to another sobjects. This type of code is very often mixed with business logic which makes testing and maintaining boring. So why not provide tool to manage this commonplace problem?

### How do I get started?
First, configure SF Mapper. You do it by specifying IFieldMapping object. For example, in listing below we create Account and Contact from Lead.
```java
SObjectMapper.initialize('Lead',
    new FieldMapping(
        //object mapping 
        new Map<String, Set<String>>{
            'Account' => new Set<String>{'phone', 'company'},
            'Contact' => new Set<String>{'email', 'city'}
        },
        //field mapping
        new Map<String, String>{
            'company' => 'name',
            'city' => 'mailingcity',
            'phone' => 'phone',
            'email' => 'email'
        }
    )
);
```
Note, FieldMapping is *case-sensitive*. So it's probably better idea to use MapperConfigBuilder, that provides fluent interface to build FieldMapping. 
Similar to the code above:
```java
SObjectMapper.initialize(
    new MapperConfigBuilder('Lead')
        .addObjectMapping('Account', new List<String>{'Phone', 'Company'})
        .addObjectMapping('Contact', new List<String>{'Email', 'City'})
        .addFieldMapping('Company', 'Name')
        .addFieldMapping('City', 'MailingCity')
        .addFieldMapping('Phone', 'Phone')
        .addFieldMapping('Email', 'Email')
);
// OR 
SObjectMapper.initialize(
    new MapperConfigBuilder('Lead')
        .addObjectMapping('Account', '*') // default mapping object
        .addObjectMapping('Contact', new List<String>{'Email', 'City'})
        .addFieldMapping('Company', 'Name')
        .addFieldMapping('City', 'MailingCity')
        .addFieldMapping('Phone', 'Phone')
        .addFieldMapping('Email', 'Email')
);
// OR (If you want add field formatting, please see wiki for details)
SObjectMapper.initialize(
    new MapperConfigBuilder('Lead')
        .addObjectMapping('Account', '*') // default mapping object
        .addObjectMapping('Contact', new List<String>{'Email', 'City'})
        .addFieldMapping(new FieldMappingRule('Company','Name', 'Account', new MyCustomIFieldFormatter()))
        .addFieldMapping('City', 'MailingCity')
);
```
Then in your application code, execute the mappings:
```java
Map<String, sObject> result = SObjectMapper.mapObject(lead);
// OR 
Map<String, sObject> result = SObjectMapper.mapObject(
    // anything that implements IResourceProvider (e.g SObjectResourceProvider, JsonResourceProvider)
    new SObjectResourceProvider(lead)
);
// OR 
Map<String, sObject> result = SObjectMapper.mapObject(
    new SObjectResourceProvider(lead, 'Lead') // scheme name
);
```
Also, you can map json to SObjects. 
**For more details please see**: [getting started guide](https://github.com/NikiforovAll/SF-Mapper/wiki/Getting-started).
### What can I map?
You can take as initial resource pretty much everything that implements *IResourceProviderInterface*. 
But SObject to SObjects and JSON to SObjects supported out of the box.  
### Where can I get it?
You can use awesome sf deployment tool [githubsfdeploy](https://github.com/afawcett/githubsfdeploy).

<a href="https://githubsfdeploy.herokuapp.com?owner=NikiforovAll&repo=SF-Mapper">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

### Issues? 
Feel free to [ask](https://github.com/NikiforovAll/SF-Mapper/issues).
