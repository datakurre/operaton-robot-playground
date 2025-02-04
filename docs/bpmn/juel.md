# Expression language

The default expression language in Operaton BPMN models is JUEL, Java Unified Expression Language. JUEL is a simple expression language that can be used to reference objects in a Java environment.


## Syntax

The syntax for JUEL expressions is `${}` for immediate evaluation and `#{}` for deferred evaluation. Yet, in Operaton, all expressions are evaluated during runtime, when the element containing the expression is executed, so it is best to just use `${}` for all expressions.

Here are some examples of JUEL expressions:

| Expression             | Expected Type | Result          |
|------------------------|---------------|-----------------|
| Hello, World!          | String        | "Hello, World!" |
| Hello, ${"World!"}     | String        | "Hello, World!" |
| ${3.14}                | double        | 3.14            |
| ${null}                | null          | null            |
| ${true && false}       | Boolean       | false           |
| ${5 + 10}              | int           | 15              |
| ${4 > 3}               | Boolean       | true            |
| ${5 > 3 ? "Yes" : "No"}| String        | "Yes"           |
| ${3 > 5 ? "Yes" : "No"}| String        | "No"            |
| ${empty ""}            | Boolean       | true            |
| ${empty null}          | Boolean       | true            |
| ${empty "text"}        | Boolean       | false           |


## Operators in expressions

JUEL supports the following operators:

| Type        | Operators                                                                 |
|-------------|---------------------------------------------------------------------------|
| Arithmetic  | `+`, `-` (binary), `*`, `/`, `div`, `%`, `mod`, `-` (unary)               |
| Logical     | `and`, `&&`, `or`, `||`, `not`, `!`                                       |
| Relational  | `==`, `eq`, `!=`, `ne`, `<`, `lt`, `>`, `gt`, `<=`, `ge`, `>=`, `le`      |
| Empty       | `empty` (checks if a value is null or empty)                              |
| Conditional | `A ? B : C`                                                               |


## Reserved words

The following words are reserved in JUEL and cannot be used as variable names:

| Word         | Description                                    |
|--------------|------------------------------------------------|
| `and`        | Logical AND                                    |
| `or`         | Logical OR                                     |
| `not`        | Logical NOT                                    |
| `eq`         | Equal to                                       |
| `ne`         | Not equal to                                   |
| `lt`         | Less than                                      |
| `gt`         | Greater than                                   |
| `le`         | Less than or equal to                          |
| `ge`         | Greater than or equal to                       |
| `true`       | Boolean true                                   |
| `false`      | Boolean false                                  |
| `null`       | Null value                                     |
| `instanceof` | Checks if an object is an instance of a class  |
| `empty`      | Checks if a value is null or empty             |
| `div`        | Division                                       |
| `mod`        | Modulus                                        |

## Objects in expressions

To refer to variables or objects and their properties and methods, you can use the following syntax:

| Syntax                        | Description                          |
|-------------------------------|--------------------------------------|
| `${variableName}`             | Refers to a variable                 |
| `${objectName.propertyName}`  | Refers to an object's property       |
| `${objectName.methodName()}`  | Calls an object's method             |

For example, if you have an execution object (like in Operaton expressions), you can refer to its properties and methods as follows:

| Expression                                   | Description                          |
|----------------------------------------------|--------------------------------------|
| `${execution.getBusinessKey()}`              | Refers to the business key property  |
| `${execution.getProcessInstancesId()}`       | Refers to the process instance ID    |
| `${execution.getVariable("variableName")}`   | Calls `getVariable` method on execution |
| `${filevariable.getFilename()}`              | Calls `getFilename` method on file variable |
| `${jsonvariable.prop("key").booleanValue()}` | Calls `prop("key")` and `booleanValue` methods on JSON variable |