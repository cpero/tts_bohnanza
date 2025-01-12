import { GLOBAL } from "./constants";

export function capitalize(val: string) {
  return String(val).charAt(0).toUpperCase() + String(val).slice(1);
}

export const log = (message: string) => {
  GLOBAL.log(message);
};
