import { AvailableColors, log } from "../utils";

export interface BaseModelState {
  guid: string;
  color: AvailableColors;
  state: { [key: string]: string | number | boolean };
}

export class BaseModel {
  guid!: string;
  color: AvailableColors;
  state: { [key: string]: string | number | boolean };

  constructor(color: AvailableColors) {
    this.color = color;
    this.state = {};
  }

  onSave() {
    log("MISSING IMPLEMENTATION: onSave");
  }

  onLoad(scriptState: BaseModelState) {
    log("MISSING IMPLEMENTATION: onLoad");
  }
}
