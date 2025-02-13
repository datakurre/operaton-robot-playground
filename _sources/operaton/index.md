# Modeling for execution

BPMN does not end with visual modeling. BPMN 2.0 models can also contain all necessary execution instructions.

This is the use case of the properties panel of the modeler:

![Modeler Sidebar](./modeler-sidebar.png)

```{tip}
At the playground, you can create a new BPMN file with the `pur bpm create hello-world.bpmn` command in the terminal and then open the created BPMN file in the editor.
```


## Process name and Id

Every BPMN 2.0 model (*process definition*) for executable processes should have a descriptive display **Name** and a unique definition **ID** set, with the Executable option checked. These settings are available on the properties panel when no element is selected.

![Process name and Id](./process-name-and-id.png)

```{note}
When using Pools and Lanes, the process Name and ID should be set at the Pool element.
```


## External task pattern

**External** {bpmn}`../bpmn/service-task` **Service task** is the feature of Operaton engine that allows to delegate work to be performed outside the BPM engine. Such work could include calling external services or performing long-running operations. And, of course, orchestrating {bpmn}`../bpmn/robot-task` **Robot Framework tasks**.

To configure an external task in your BPMN model:

1. **Add a {bpmn}`../bpmn/service-task` Service task** onto your process diagram.

2. **Set implementation** type in the properties panel to `External`.

3. **Specify topic**. Define a topic name that external workers will subscribe to. This topic acts as a queue for tasks that workers will fetch and complete.

![External Task Configuration](./service-task.png)

External task workers, like `pur`(jo) will then poll Operaton engine REST API for tasks with the specified topic, execute the required work, and report the completion results back to the engine.

```{tip}
At the playground, a [dedicated plugin](https://github.com/datakurre/camunda-modeler-robot-plugin) renders {bpmn}`../bpmn/robot-task` **robot icon** for all {bpmn}`../bpmn/service-task` **Service Tasks** with a word *robot* in their *ID*.
```

## Inputs and outputs

**Process variables** store data that can be accessed and manipulated throughout the lifecycle of a process instance. In addition to process level variables, Operaton engine supports nested **variables scopes**. These scopes are most often managed with **input and output mappings** for {bpmn}`../bpmn/task` tasks and {bpmn}`../bpmn/start-event` sub-processes.

Use of **inputs and outputs is not mandatory**, but they support separation of generic re-usable services tasks with generic "arguments" for domain specific process variables. Use of inputs and outputs also protects for possible concurrent tasks later overriding each others process variables.

To configure input and output mappings for {bpmn}`../bpmn/service-task` **Service task**, select the task in the modeler and navigate to the properties panel sections **inputs** and **outputs**.

![Inputs and outputs mapping in properties panel](./inputs-and-outputs.png)

The default expression language available for inputs mapping in Operaton is [JUEL](../bpmn/juel.md). This language allows you to reference process variables and perform simple operations on them.

```{warning}
Variables mapped in {bpmn}`../bpmn/service-task` **Service task inputs are only available within the task**. Once the task is completed, the variables are no longer accessible **unless they are exported at outputs**.
```

```{tip}
**Inputs and outputs** can be used to map domain-specific process-level variables to generic task-level variables, to **allow for generic, reusable, external task workers**. This is similar to how functions in traditional programming are implemented and used.
```

```{tip}
File variables need to be mapped with the special expression `${execution.getVariableTyped("name")}` or they could be coerced to the "Bytes" variable type.
```


## Gateway paths

Execution instructions include how {bpmn}`../bpmn/exclusive-gateway` **Exclusive Gateways** and {bpmn}`../bpmn/inclusive-gateway` **Inclusive Gateways** determine which path the token should be directed to.

One of the outgoing paths from an exclusive gateway can be configured as **the default path** using the element context modeling palette.

![Setting exclusive gateway default path](./default-path.png)

The rest of the paths should have **condition expressions** defined, using [the expression language](../bpmn/juel.md).

![Setting exclusive gateway condition](./conditional-path.png)


## User tasks

{bpmn}`../bpmn/user-task` **User Tasks** are tasks performed by human actors. These tasks are typically used to model interactions between the process and users.

In practice, user tasks {bpmn}`../bpmn/user-task` **User Tasks** are implemented by displaying the user a form. The implementation can be a completely custom "tasklist application". The form can be configured to display process variables and allow the user to manipulate them. The **filled form is submitted back to the engine** by calling using its API.

![User Task configuration](./user-task.png)

Operaton's built-in tasklist application supports a few alternative form types. The **modeler used in the playground**, however, does not support "Camunda Forms", but only **Generated task Forms**.

```{warning}
The form definitions options supported by Operaton's builtin tasklist application may change before its final 1.0 release.
```
