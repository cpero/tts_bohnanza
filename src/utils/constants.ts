export const GLOBAL = _G as any;

export const GUID_LIST = {
  decks: {
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
  },
  players: {
    white: {
      hand: "affd30",
      panelLeft: "eafd7f",
      panelMid: "254cb4",
      panelRight: "37c672",
      scriptLeft: "c7c272",
      scriptMid: "5bf04a",
      scriptRight: "34ec4e",
    },
    red: {
      hand: "d3ce1f",
      panelLeft: "956d84",
      panelMid: "c85946",
      panelRight: "cdd915",
      scriptLeft: "789551",
      scriptMid: "6eab5b",
      scriptRight: "34e460",
    },
    orange: {
      hand: "a26a01",
      panelLeft: "09d1b6",
      panelMid: "bf1403",
      panelRight: "ede488",
      scriptLeft: "3e4467",
      scriptMid: "8594ed",
      scriptRight: "eee6ba",
    },
    yellow: {
      hand: "455778",
      panelLeft: "16e303",
      panelMid: "2d1fb6",
      panelRight: "f2f243",
      scriptLeft: "b8b1fb",
      scriptMid: "820707",
      scriptRight: "d82e1b",
    },
    blue: {
      hand: "267ce0",
      panelLeft: "c72440",
      panelMid: "0ec208",
      panelRight: "baf2c9",
      scriptLeft: "326808",
      scriptMid: "74bc5f",
      scriptRight: "540406",
    },
    green: {
      hand: "c4e41f",
      panelLeft: "6bbca0",
      panelMid: "7f1b96",
      panelRight: "f55151",
      scriptLeft: "2c18c5",
      scriptMid: "6e7b9f",
      scriptRight: "415e10",
    },
    purple: {
      hand: "150902",
      panelLeft: "f0c909",
      panelMid: "2ca1cb",
      panelRight: "9a817f",
      scriptLeft: "edfc21",
      scriptMid: "e39338",
      scriptRight: "e89dde",
    },
  },
  scriptDrawDeck: "105aa0",
  scriptDiscardDeck: "264205",
};

export const log = (message: string) => {
  GLOBAL.log(message);
};
