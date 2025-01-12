import { GLOBAL, log, AvailableColors } from "../utils";
import { Player } from "../models/player";

export interface PlayerWorkerState {
  seatedPlayers: { [key: string]: Player };
}

export class PlayerWorker {
  seatedPlayers: { [key: string]: Player } = {};

  initSeatedPlayers() {
    log("Iniializing seated players.");

    Object.values(GLOBAL.getSeatedPlayers()).forEach((playerColor) => {
      log("Player color: " + playerColor);
      this.seatedPlayers[playerColor as AvailableColors] = new Player(
        playerColor as AvailableColors
      );
    });

    log("Seated players: " + this.seatedPlayers.length);

    Object.keys(this.seatedPlayers).forEach((key) => {
      log("Seated player: " + key);
    });
  }

  onSave(): PlayerWorkerState {
    const seatedPlayers: { [key: string]: any } = {};

    // TODO: Implement this
    Object.entries(this.seatedPlayers).forEach(([color, player]) => {
      seatedPlayers[color] = player.onSave();
    });

    return {
      seatedPlayers,
    };
  }

  onLoad(scriptState: PlayerWorkerState) {
    log("PlayerWorker onLoad");

    Object.entries(scriptState.seatedPlayers).forEach(
      ([color, playerState]) => {
        this.seatedPlayers[color] = new Player(color as AvailableColors);
        this.seatedPlayers[color].onLoad(playerState);
      }
    );
  }
}
