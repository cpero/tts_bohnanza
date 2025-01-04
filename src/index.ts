import { GUID_CONST } from "./Constants";

export const Main = {
  onLoad: onLoad,
};

function onLoad(state: string) {
  broadcastToAll("Welcome to the game!", [0, 0, 0]);
}
