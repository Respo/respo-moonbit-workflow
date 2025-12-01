///|
struct Store {
  mut counted : Int
  tasks : Array[Task]
  states : @respo.RespoStatesTree
} derive(ToJson, @json.FromJson)

///|
impl Default for Store with default() -> Store {
  { counted: 0, tasks: [], states: @respo.RespoStatesTree::default() }
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
  Noop
  StatesChange(@respo.RespoUpdateState)
  Increment
  Decrement
  IncTwice
}

///|
pub impl Default for ActionOp with default() -> ActionOp {
  Noop
}

///|
impl @respo_node.RespoAction for ActionOp with build_states_action(cursor, a, j) {
  StatesChange({
    cursor,
    data: if a is Some(a) {
      Some(@dom_ffi.js_obscure_to_v(a))
    } else {
      None
    },
    backup: j,
  })
}

///|
impl Show for ActionOp with output(self, logger) -> Unit {
  let s = match self {
    Noop => "Noop"
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
fn Store::get_states(self : Store) -> @respo.RespoStatesTree {
  self.states
}

///|
/// TODO mutation might break memoization in future
fn Store::update(self : Store, op : ActionOp) -> Unit {
  match op {
    Increment => self.counted += 1
    StatesChange(states) => self.states.set_in_mut(states)
    Decrement => self.counted -= 1
    _ => ()
  }
}
