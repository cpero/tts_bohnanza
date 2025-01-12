import { GLOBAL, GlobalState } from "./utils/constants";
import { PlayerWorker } from "./workers/playerWorker";

let state: GlobalState;

GLOBAL.onLoad = (script_state: string) => {
  if (script_state === "") {
    log("State is empty. Initializing state.");

    state = initState();
  } else {
    log("Loading state.");
    state = JSON.decode(script_state);

    if (state.init) {
      state = initState();
    }

    if (state.playerWorkerState) {
      const playerWorker = new PlayerWorker();
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
  const playerWorker = new PlayerWorker();

  state = {
    ...state,
    playerWorkerState: playerWorker.onSave(),
  };

  return state;
};

const initState = (): GlobalState => {
  const playerWorker = new PlayerWorker();
  playerWorker.initSeatedPlayers();

  return {
    init: true,
  };
};
