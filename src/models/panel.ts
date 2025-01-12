import { BaseModel, BaseModelState } from "./baseModel";
import {
  log,
  PLAYER_LIST,
  capitalize,
  AvailableColors,
  Positions,
} from "../utils";

export interface PanelState extends BaseModelState {
  position: string;
}

export class Panel extends BaseModel {
  position: string;
  guid: string = "";

  constructor(color: AvailableColors, position: string) {
    super(color);

    this.position = position;
    this.guid = PLAYER_LIST[color][`panel${capitalize(position)}`];
  }

  onSave(): PanelState {
    return {
      color: this.color,
      guid: this.guid,
      state: this.state,
      position: this.position,
    };
  }

  onLoad(panelState: PanelState) {
    this.color = panelState.color;
    this.guid = panelState.guid;
    this.state = panelState.state;
    this.position = panelState.position;
  }
}
