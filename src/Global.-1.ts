import { GLOBAL, GlobalState } from "./utils/constants";
import { PlayerWorker } from "./workers/playerWorker";

let state: GlobalState;
const playerWorker = new PlayerWorker();

GLOBAL.onLoad = (script_state: string) => {
  if (script_state === "") {
    log("State is empty. Initializing state.");

    state = initState();
  } else {
    log("Loading state.");
    state = JSON.decode(script_state);

    if (state.playerWorkerState) {
      playerWorker.onLoad(state.playerWorkerState);
    }
  }

  return JSON.encode(state);
};

GLOBAL.onSave = () => {
  // log("Saving state.");
  state = stateSnapshot();
  return JSON.encode(state);
};

const stateSnapshot = (): GlobalState => {
  state = {
    ...state,
    playerWorkerState: playerWorker.onSave(),
  };

  return state;
};

const initState = (): GlobalState => {
  return {
    init: true,
  };
};
