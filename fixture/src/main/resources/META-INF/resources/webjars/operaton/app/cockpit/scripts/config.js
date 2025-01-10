export default {
  customScripts: [
    'scripts/definition-historic-activities.js',
    'scripts/instance-historic-activities.js',
    'scripts/instance-route-history.js'
  ],
  bpmnJs: {
    additionalModules: [
      'scripts/robot-module.js'
    ],
  },
  disableWelcomeMessage: true,
  previewHtml: true
};
