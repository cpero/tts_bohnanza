const GLOBAL = _G as any;

GLOBAL.onLoad = () => {
  broadcastToAll("Global script loaded");
};
