import { PlayerWorkerState } from "../workers/playerWorker";

export const GLOBAL = _G as any;

export interface GlobalState {
  init: boolean;
  playerWorkerState?: PlayerWorkerState;
}

export { GUID_LIST } from "./guidList";

export const log = (message: string) => {
  GLOBAL.log(message);
};

export enum AvailableColors {
  "White" = "White",
  "Red" = "Red",
  "Orange" = "Orange",
  "Yellow" = "Yellow",
  "Green" = "Green",
  "Blue" = "Blue",
  "Purple" = "Purple",
}
