///|
struct Store {
  counted : Int
  states : @respo.RespoStatesTree
} derive(ToJson, @json.FromJson, Eq)

///|
impl Default for Store with default() -> Store {
  { counted: 0, states: @respo.RespoStatesTree::default() }
}

///|
struct Task {
  id : String
  done : Bool
  content : String
  time : Double
} derive(Default, Eq, Hash, ToJson, @json.FromJson)

///|
enum ActionOp {
  StatesChange(@respo.RespoUpdateState)
  Increment
  Decrement
  IncTwice
}

///|
impl @respo_node.RespoAction for ActionOp with build_states_action(cursor, a, j) {
  StatesChange({ cursor, data: a.map(@dom_ffi.js_obscure_to_v), backup: j })
}

///|
impl Show for ActionOp with output(self, logger) -> Unit {
  let s = match self {
    StatesChange(state) =>
      "StatesChange(\{state.cursor} \{state.backup.to_json()})"
    // Intent(_intent) => "Intent(...)"
    Increment => "Increment"
    Decrement => "Decrement"
    IncTwice => "IncTwice"
  }
  logger.write_string(s)
}

///|
/// update store immutably
fn Store::update(self : Store, op : ActionOp) -> Store {
  match op {
    Increment => { ..self, counted: self.counted + 1 }
    StatesChange(states) => { ..self, states: self.states.set_in(states) }
    Decrement => { ..self, counted: self.counted - 1 }
    _ => self
  }
}
