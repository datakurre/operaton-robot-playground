# Open source ecosystem

The Business Process Model and Notation (BPMN) 2.0 standard has fostered a rich and diverse ecosystem of open-source tools. These projects range from powerful execution engines to web-based modelers and entire low-code platforms, enabling developers and organizations to implement process automation freely.


## Operaton BPM

For many years, **Camunda 7 Community Edition (CE)** was a cornerstone of the open-source BPMN world. As a robust, embeddable Java-based engine, it gained widespread adoption. However, with Camunda shifting focus to its cloud-native Camunda 8 platform, the community edition of Camunda 7 is now at (or approaching) end-of-life.

To fill this gap and ensure the continuation of the classic Camunda 7 architecture, the **Operaton** project was born. Operaton is a community-driven fork of Camunda 7, dedicated to maintaining and extending the legacy codebase. It provides a future for projects that rely on the embeddable, Java-centric approach to workflow automation. Yet, with its comprehensive REST API, it works as well as an external process orchestration service.

- Camunda 7 CE (engine): <https://github.com/camunda/camunda-bpm-platform> (Apache-2.0)
- Operaton (project site): <https://operaton.org/>
- Operaton (source): <https://github.com/operaton> (Apache-2.0)


## bpmn.io

At the heart of modern web-based BPMN tooling is **bpmn.io**. It is a suite of JavaScript libraries for rendering and modeling BPMN, DMN (Decision Model and Notation) and forms directly in the browser. Core libraries include a BPMN modeler, DMN editor and form builder. These libraries are used also in [Camunda Desktop Modeler](https://github.com/camunda/camunda-modeler), which still supports Camunda 7 (and also Operaton) compatible modeling.

- bpmn.io: <https://bpmn.io/> (Custom)
- bpmn-js: <https://github.com/bpmn-io/bpmn-js>
- dmn-js: <https://github.com/bpmn-io/dmn-js>
- form-js: <https://github.com/bpmn-io/form-js>

```{warning}
The core bpmn.io libraries are not distributed under an OSI‑approved open source license. They use a custom license (see https://bpmn.io/license/) that is largely based on the MIT license but requires the bpmn.io watermark and a link to bpmn.io to remain visible. 
```


### Selected plugins

- Token Simulation: <https://github.com/bpmn-io/bpmn-js-token-simulation> (MIT)
- bpmnlint rules: <https://github.com/bpmn-io/bpmnlint> (MIT)
- bpmn-js-bpmnlint integration: <https://github.com/bpmn-io/bpmn-js-bpmnlint> (MIT)
- Transaction Boundaries overlay: <https://github.com/bpmn-io/camunda-transaction-boundaries> (MIT)
- MCP: <https://github.com/datakurre/bpmn-js-mcp> (MIT)


## WKS Platform

The **WKS Platform** is an example of a comprehensive, open-source Adaptive Case Management (ACM) solution built upon this ecosystem. It leverages the power of the Camunda engine on the backend and often utilizes `bpmn.io` for the front-end modeling experience. It demonstrates how foundational open-source components can be assembled into a feature-rich, low-code platform for managing complex and unpredictable workflows.

- WKS Platform (org): <https://github.com/wkspower/wks-platform> (MIT)


## BPM Crafters

BPM Crafters is a small open-source GitHub organization focused on building implementation-agnostic tooling for workflow and business process management (BPM), mainly using Kotlin. Its core project is a portable Process Engine API that lets developers write workflow-driven applications independent of a specific engine, supported by adapters for platforms such as Camunda 7 and Camunda 8. The organization also provides Spring Boot–based worker tooling, shared build configuration, documentation, and a website, aiming to make process automation more flexible, reusable, and engine-neutral across different BPM technologies.

- BPM Crafters (website): <https://bpm-crafters.dev/>
- BPM Crafters (org): <https://github.com/bpm-crafters> (Apache-2.0)


## SpiffWorkflow and SpiffArena

For those preferring Python native approach, **SpiffWorkflow** could provise a promising alternative in the future.


### SpiffWorkflow


**SpiffWorkflow** is a mature, pure-Python library that can parse and execute the most elements in BPMN 2.0 diagrams. It is highly flexible and designed to be integrated into any Python application, offering developers a robust base for a BPMN capable workflow engine without requiring a Java virtual machine.

- SpiffWorkflow website: <https://spiffworkflow.org/>
- SpiffWorkflow source: <https://github.com/sartography/SpiffWorkflow> (LGPL-3.0)


### SpiffArena

Built on top of SpiffWorkflow, **SpiffArena** aims to be a full-featured, low-code web application. It provides a complete user interface for designing, launching, and managing workflows. Users can interact with task lists, fill out forms, and monitor process execution.

- SpiffWorks website: https://spiff.works/
- SpiffArena source: <https://github.com/sartography/spiff-arena> (LGPL-2.1)
