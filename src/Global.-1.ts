import { GLOBAL } from "./utils/constants";
import { PlayerWorker } from "./workers/playerWorker";

interface PlayerState {
  init: boolean;
  seatedPlayers?: {
    [playerColor: string]: Player;
  };
}

let state: PlayerState;
let playerWorker: PlayerWorker;

GLOBAL.onLoad = (script_state: string) => {
  initWorkers();

  if (script_state === "") {
    log("State is empty. Initializing state.");

    state = initState();
    log("State: " + JSON.encode(state));
  } else {
    log("Loading state.");
    log("State: " + JSON.decode(script_state));
    state = JSON.decode(script_state);
  }

  for (const [key, value] of pairs(state)) {
    print(tostring(key) + ": " + tostring(value));
  }

  return JSON.encode(state);
};

GLOBAL.onSave = () => {
  return JSON.encode(state);
};

const initState = () => {
  // TODO: Move this to a button click event.
  log("Init seated players.");
  playerWorker.initSeatedPlayers();

  return {
    init: true,
  };
};

const initWorkers = () => {
  playerWorker = new PlayerWorker();
};
