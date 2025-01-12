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
      this.seatedPlayers[playerColor as AvailableColors] = new Player(
        playerColor as AvailableColors
      );
    });

    log("# of seated players: " + Object.keys(this.seatedPlayers).length);
  }

  onSave(): PlayerWorkerState {
    const seatedPlayers: { [key: string]: any } = {};

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
