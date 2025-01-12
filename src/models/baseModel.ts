import { log } from "../utils/constants";

export interface BaseModelState {
  guid: string;
  color: string;
  state: { [key: string]: string | number | boolean };
}

export class BaseModel {
  guid!: string;
  color: string;
  state: { [key: string]: string | number | boolean };

  constructor(color: string) {
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
