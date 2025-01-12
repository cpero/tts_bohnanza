import { BaseModel, BaseModelState } from "./baseModel";
import {
  log,
  GUID_LIST,
  Positions,
  positions,
  AvailableColors,
} from "../utils";
import { Panel, PanelState } from "./panel";
import { ScriptingZone, ScriptingZoneState } from "./scriptingZone";

export interface PlayerState extends BaseModelState {
  handGUID: string;
  panels: { [key: string]: PanelState };
  scriptingZones: { [key: string]: ScriptingZoneState };
}

export class Player extends BaseModel {
  handGUID: string = "";

  panels: { [key: string]: Panel } = {};
  scriptingZones: { [key: string]: ScriptingZone } = {};

  constructor(color: AvailableColors) {
    super(color);

    this.handGUID = GUID_LIST.players[color].hand;
    log(color + " player hand GUID: " + this.handGUID);

    positions.forEach((position) => {
      this.panels[position] = new Panel(color, position);
      // this.scriptingZones[position] = new ScriptingZone(color, position);
    });
  }

  onSave(): PlayerState {
    return {
      color: this.color,
      guid: this.guid,
      state: this.state,
      handGUID: this.handGUID,
      panels: this.panels,
      scriptingZones: this.scriptingZones,
    };
  }

  onLoad(playerState: PlayerState) {
    this.color = playerState.color;
    this.guid = playerState.guid;
    this.state = playerState.state;

    Object.entries(playerState.panels).forEach(([position, panelState]) => {
      this.panels[position] = new Panel(this.color, position);
      this.panels[position].onLoad(panelState as PanelState);
    });

    Object.entries(playerState.scriptingZones).forEach(
      ([position, scriptingZoneState]) => {
        this.scriptingZones[position] = new ScriptingZone(this.color, position);
        this.scriptingZones[position].onLoad(
          scriptingZoneState as ScriptingZoneState
        );
      }
    );
  }
}
