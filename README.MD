SF Mapper
==========================
### [What is SF Mapper?](https://github.com/NikiforovAll/SF-Mapper/wiki)

SF Mapper is a simple library build to solve really common problem - getting rid of code that mapped one source object to another sobjects. This type of code is very often mixed with business logic which makes testing and maintaining boring. So why not provide tool to manage this commonplace problem?

### How do I get started?
First, configure SF Mapper, for example in listing below we create Account and Contact from Lead.
```java
SObjectMapper.initialize('Lead',
    new FieldMapping(
        //object mapping 
        new Map<String, Set<String>>{
            //lowercase
            'Account' => new Set<String>{'phone', 'company'},
            'Contact' => new Set<String>{'email', 'city'}
        },
        //field mapping
        new Map<String, String>{
            //lowercase
            'company' => 'name',
            'city' => 'mailingcity'
        }
    )
);
```
Then in your application code, execute the mappings:
```java
    Map<String, sObject> result = SObjectMapper.mapObject(lead);
    Account account = (Account)result.get('Account');
    Contact contact = (Contact)result.get('Contact');
```
For more details please see: [getting started guide](https://github.com/NikiforovAll/SF-Mapper/wiki/Getting-started).
### What can I map?
You can take as initial resource pretty much everything that implements *IResourceProviderInterface*. 
But SObject to SObjects and JSON to SObjects supported out of the box.  
### Where can I get it?
You can use awesome sf deployment tool [githubsfdeploy](https://github.com/afawcett/githubsfdeploy).

<a href="https://githubsfdeploy.herokuapp.com?owner=NikiforovAll&repo=SF-Mapper">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>