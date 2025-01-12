import { BaseModel, BaseModelState } from "./baseModel";
import {
  log,
  GUID_LIST,
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
    log("Position: " + position);
    log(JSON.stringify(GUID_LIST.players[color]));
    this.guid =
      GUID_LIST.players[color][
        `panel${capitalize(position)}` as keyof (typeof GUID_LIST.players)[keyof typeof GUID_LIST.players]
      ];

    log(color + " panel GUID: " + this.guid);
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
