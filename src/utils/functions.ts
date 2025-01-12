import { GLOBAL } from "./constants";

export function capitalize(val: string) {
  return val.charAt(0).toUpperCase() + val.slice(1);
}

export const log = (message: string) => {
  GLOBAL.log(message);
};
