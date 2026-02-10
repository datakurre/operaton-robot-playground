These three BPMN diagrams demonstrate a simple “process chaining” pattern using message correlation with a shared business key:

* A starts, then immediately ends with a message end event that programmatically correlates the message StartB to trigger process B for the same business key

* B begins on a message start event waiting for StartB, then ends by correlating and sending StartC (again targeting the same business key) to trigger process C

* C starts on a message start event for StartC, waits on an intermediate timer catch event for PT1M (1 minute), and then ends—so overall it’s A → (message StartB) → B → (message StartC) → C, with correlation ensuring the “next” process instance links to the “current” one via the business key.