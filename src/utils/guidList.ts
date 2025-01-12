import { AvailableColors } from "./";

export const DECK_LIST: {
  [key: string]: string;
} = {
  coffee: "eda415",
  wax: "84899d",
  red: "fc4f11",
  garden: "11fc02",
  blue: "f3a88f",
  chili: "1e490c",
  stink: "a7bf33",
  black: "0bd6af",
  soy: "3e8500",
  green: "f2d49c",
  cocoa: "d228c8",
};

export const PLAYER_LIST: {
  [key in AvailableColors]: { [key: string]: string };
} = {
  White: {
    hand: "affd30",
    panelLeft: "eafd7f",
    panelMiddle: "254cb4",
    panelRight: "37c672",
    scriptLeft: "c7c272",
    scriptMiddle: "5bf04a",
    scriptRight: "34ec4e",
  },
  Red: {
    hand: "d3ce1f",
    panelLeft: "956d84",
    panelMiddle: "c85946",
    panelRight: "cdd915",
    scriptLeft: "789551",
    scriptMiddle: "6eab5b",
    scriptRight: "34e460",
  },
  Orange: {
    hand: "a26a01",
    panelLeft: "09d1b6",
    panelMiddle: "bf1403",
    panelRight: "ede488",
    scriptLeft: "3e4467",
    scriptMiddle: "8594ed",
    scriptRight: "eee6ba",
  },
  Yellow: {
    hand: "455778",
    panelLeft: "16e303",
    panelMiddle: "2d1fb6",
    panelRight: "f2f243",
    scriptLeft: "b8b1fb",
    scriptMiddle: "820707",
    scriptRight: "d82e1b",
  },
  Blue: {
    hand: "267ce0",
    panelLeft: "c72440",
    panelMiddle: "0ec208",
    panelRight: "baf2c9",
    scriptLeft: "326808",
    scriptMiddle: "74bc5f",
    scriptRight: "540406",
  },
  Green: {
    hand: "c4e41f",
    panelLeft: "6bbca0",
    panelMiddle: "7f1b96",
    panelRight: "f55151",
    scriptLeft: "2c18c5",
    scriptMiddle: "6e7b9f",
    scriptRight: "415e10",
  },
  Purple: {
    hand: "150902",
    panelLeft: "f0c909",
    panelMiddle: "2ca1cb",
    panelRight: "9a817f",
    scriptLeft: "edfc21",
    scriptMiddle: "e39338",
    scriptRight: "e89dde",
  },
};

export const MISC_LIST: {
  [key: string]: string;
} = {
  scriptDrawDeck: "105aa0",
  scriptDiscardDeck: "264205",
};
