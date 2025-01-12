import { BaseModel, BaseModelState } from "./baseModel";
import { log, GLOBAL, GUID_LIST } from "../utils/constants";

export interface PlayerState extends BaseModelState {}

export class Player extends BaseModel {
  handGUID: string = "";

  constructor(color: keyof typeof GUID_LIST.players) {
    super(color);

    this.handGUID = GUID_LIST.players[color].hand;
    log(color + " player hand GUID: " + this.handGUID);
  }

  onSave(): PlayerState {
    return {
      color: this.color,
      guid: this.guid,
      state: this.state,
    };
  }

  onLoad(playerState: PlayerState) {
    this.color = playerState.color;
    this.guid = playerState.guid;
    this.state = playerState.state;
  }
}
