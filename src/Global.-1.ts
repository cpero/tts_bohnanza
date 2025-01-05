const GLOBAL = _G as any;

GLOBAL.onLoad = (script_state: string) => {
  let state;

  if (script_state === "") {
    state = initState();
  } else {
    state = JSON.decode(script_state);
  }

  for (const [key, value] of pairs(state)) {
    print(tostring(key) + ": " + tostring(value));
  }
};

GLOBAL.onSave = () => {
  const state = initState();
  // Set state values here

  return JSON.encode(state);
};

const initState = () => {
  return {
    // State
  };
};
