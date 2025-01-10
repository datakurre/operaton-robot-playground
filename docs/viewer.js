import TokenSimulationModule from '../../lib/viewer';
import BpmnViewer from 'bpmn-js/lib/NavigatedViewer';
import RobotTask from './robot-task';

function openDiagram(id, diagram) {
  const viewer = new BpmnViewer({
    container: '#' + id,
    additionalModules: [
      TokenSimulationModule,
      RobotTask
    ],
  });
  return viewer.importXML(diagram)
    .then(({ warnings }) => {
      if (warnings.length) {
        console.warn(warnings);
      }
      viewer.get('canvas').zoom('fit-viewport', true);
      if (typeof jQuery === 'function') {
        jQuery('#' + id + ' .bts-toggle-mode').click();
      }
    })
    .catch(err => {
      console.error(err);
    });
}

window.TokenSimulation = (id, url) => {
  fetch(url).then(
    r => {
      if (r.ok) {
        return r.text();
      }
    }
  ).then(
    text => openDiagram(id, text)
  ).catch(
    err => {
        console.warn(err);
    }
  );
}
