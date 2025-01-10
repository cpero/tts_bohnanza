import { GLOBAL, log } from "../utils/constants";
import { Player } from "../models/player";

// Singleton class that manages various player operations.
export class PlayerWorker {
  seatedPlayers: Player[] = [];

  constructor() {
    log("Initializing player worker.");
  }

  initSeatedPlayers() {
    log("Init seated players.");

    this.seatedPlayers = GLOBAL.getSeatedPlayers().map(
      (playerColor: string) => {
        const player = new Player();
        player.color = playerColor;

        return player;
      }
    );

    log("Seated players: " + this.seatedPlayers.length);

    this.seatedPlayers.forEach((player) => {
      log(player.color);
    });
  }

  toJson() {
    return this.seatedPlayers
      .map((player) => {
        return player;
      })
      .reduce(
        (acc, player) => {
          acc[player.color] = player;
          return acc;
        },
        {} as { [playerColor: string]: Player }
      );
  }
}
