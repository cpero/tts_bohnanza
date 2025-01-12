import { BaseModel, BaseModelState } from "./baseModel";
import {
  log,
  GUID_LIST,
  capitalize,
  AvailableColors,
  Positions,
} from "../utils";

export interface ScriptingZoneState extends BaseModelState {
  position: string;
}

export class ScriptingZone extends BaseModel {
  position: string;
  guid: string = "";

  constructor(color: AvailableColors, position: string) {
    super(color);

    this.position = position;
    const scriptKey =
      `script${capitalize(position)}` as keyof (typeof GUID_LIST.players)[keyof typeof GUID_LIST.players];
    this.guid = GUID_LIST.players[color][scriptKey];
    log(color + " scripting zone GUID: " + this.guid);
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
