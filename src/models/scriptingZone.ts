import { BaseModel, BaseModelState } from "./baseModel";
import { log, PLAYER_LIST, capitalize, AvailableColors } from "../utils";

export interface ScriptingZoneState extends BaseModelState {
  position: string;
}

export class ScriptingZone extends BaseModel {
  position: string;
  guid: string = "";

  constructor(color: AvailableColors, position: string) {
    super(color);

    this.position = position;
    this.guid = PLAYER_LIST[color][`script${capitalize(position)}`];
  }

  onSave(): ScriptingZoneState {
    return {
      color: this.color,
      guid: this.guid,
      state: this.state,
      position: this.position,
    };
  }

  onLoad(scriptingZoneState: ScriptingZoneState) {
    this.color = scriptingZoneState.color;
    this.guid = scriptingZoneState.guid;
    this.state = scriptingZoneState.state;
    this.position = scriptingZoneState.position;
  }
}
